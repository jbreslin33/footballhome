#!/usr/bin/env bash
# =============================================================================
# sim/scripts/load_test_orchestrator.sh
# =============================================================================
#
# Slice 14.7 — 20 concurrent matches spawn + tick 60s each + tear down.
#
# Exercises the full M1 orchestration surface end-to-end against a live
# stack. Runs against localhost by default; overridable for
# staging/CI hosts via BACKEND_URL.
#
# Per sim/DESIGN.md §16.7 (Multi-match orchestration) exit criteria:
#   - 20 concurrent matches per host without spawn errors or orphans.
#   - Post-tear-down: zero orphan containers matching
#     footballhome_sim_${id}, zero sim_running_matches rows for
#     the test-created match_ids.
#
# What this test does NOT assert (deferred to follow-up slices):
#   - Cold-start < 2 s / warm-image start < 500 ms per §16.7. Those are
#     un-contended single-spawn budgets; under 20-way concurrent load
#     the aggregate wall-clock is a more useful signal. We record p50
#     and max spawn latency for observation, and only fail on egregious
#     hangs. Under FH_SIM_LAUNCH_MAX_CONCURRENCY=4 default, the 20th
#     caller in a CONCURRENT=20 burst queues behind ~5 batches of 4;
#     total wall time ≈ 15–25 s, so SPAWN_BUDGET_MS defaults to 60000
#     (matches the curl --max-time in spawn_one)—anything over that
#     is a genuine hang, not queue latency.
#   - Effective tick rate ≥ 19.9 Hz per daemon (§16.7 exit criterion).
#     Requires a real WS client harness to measure per-daemon TickPacket
#     cadence — out of scope for a shell-level integration test.
#   - Cross-match input isolation on `sim_match_inputs` — vacuously true
#     when no clients drive inputs; the structural invariant (per-daemon
#     `AsyncPgLog<InputRow>` keyed on SIM_MATCH_ID env) is unit-tested
#     in sim/tests/test_async_pg_log.cpp.
#
# Usage:
#   sim/scripts/load_test_orchestrator.sh
#     BACKEND_URL       base URL (default: http://localhost:3001)
#     CONCURRENT        number of matches to spawn (default: 20)
#     TICK_HOLD_SECONDS how long to let daemons tick before stop (default: 60)
#     SPAWN_BUDGET_MS   per-match spawn latency budget (default: 60000)
#     USER_ID           users.id whose JWT authorizes the spawn (default: 2)
#
# Prereqs:
#   - Backend + db + footballhome_footballhome_sim image up.
#   - FH_SIM_ORCHESTRATOR_ENABLED=1 in the backend's env.
#   - env file at repo root with JWT_SECRET (used to mint the test JWT).
#
# Exit codes:
#   0   all assertions passed
#   1   at least one assertion failed
#   2   setup error (missing env, backend unreachable, etc.)
# =============================================================================
set -euo pipefail

# --- paths + config ---------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

BACKEND_URL="${BACKEND_URL:-http://localhost:3001}"
CONCURRENT="${CONCURRENT:-20}"
TICK_HOLD_SECONDS="${TICK_HOLD_SECONDS:-60}"
SPAWN_BUDGET_MS="${SPAWN_BUDGET_MS:-60000}"
USER_ID="${USER_ID:-2}"

STATE_DIR="$(mktemp -d /tmp/sim-load-XXXXXX)"
MATCH_IDS_FILE="${STATE_DIR}/match_ids.txt"
SPAWN_LATENCY_FILE="${STATE_DIR}/spawn_latency_ms.txt"
STOP_LATENCY_FILE="${STATE_DIR}/stop_latency_ms.txt"

: > "${MATCH_IDS_FILE}"
: > "${SPAWN_LATENCY_FILE}"
: > "${STOP_LATENCY_FILE}"

failures=0

# --- output helpers ---------------------------------------------------------
say()   { printf '\n\033[1;36m=== %s ===\033[0m\n' "$*"; }
ok()    { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
fail()  { printf '  \033[1;31m✗\033[0m %s\n' "$*"; failures=$((failures + 1)); }
info()  { printf '  · %s\n' "$*"; }

# --- cleanup trap -----------------------------------------------------------
# Fires on ANY exit path so a mid-test failure still tries to reap any
# still-running containers we spawned. Race-safe: iterating a snapshot of
# ${MATCH_IDS_FILE} we appended to during spawn.
cleanup() {
    local rc=$?
    if [[ -s "${MATCH_IDS_FILE}" ]]; then
        say "cleanup — stopping any lingering matches"
        while read -r mid; do
            [[ -z "${mid}" ]] && continue
            curl -sS -o /dev/null -X POST \
                "${BACKEND_URL}/api/sim/matches/${mid}/stop" \
                -H "Authorization: Bearer ${TOKEN:-}" \
                --max-time 15 || true
        done < "${MATCH_IDS_FILE}"
    fi
    rm -rf "${STATE_DIR}"
    exit "${rc}"
}
trap cleanup EXIT

# --- 0) sanity: backend reachable + JWT_SECRET available -------------------
say "0) preflight"

if ! command -v jq >/dev/null 2>&1; then
    fail "jq not on PATH — required for JSON parsing"
    exit 2
fi
if ! command -v openssl >/dev/null 2>&1; then
    fail "openssl not on PATH — required for JWT signing"
    exit 2
fi

env_file="${REPO_ROOT}/env"
if [[ ! -f "${env_file}" ]]; then
    fail "missing ${env_file}"
    exit 2
fi
JWT_SECRET="$(grep -E '^JWT_SECRET=' "${env_file}" | tail -n1 | cut -d= -f2-)"
if [[ -z "${JWT_SECRET}" ]]; then
    fail "JWT_SECRET empty in ${env_file}"
    exit 2
fi

# Ping backend health-ish (any 2xx / 4xx is fine — 5xx or connect refused fails).
# NOTE: on connect refused, curl writes "000" to stdout (from -w) *and*
# exits non-zero. A trailing `|| echo 000` would concatenate to "000000"
# and defeat the check below. Instead, run curl and inspect $? explicitly.
set +e
http_code="$(curl -sS -o /dev/null -w '%{http_code}' \
                 "${BACKEND_URL}/api/sim/matches" --max-time 5)"
curl_rc=$?
set -e
if [[ ${curl_rc} -ne 0 ]] \
   || ! [[ "${http_code}" =~ ^[0-9]{3}$ ]] \
   || (( http_code >= 500 )); then
    fail "backend unreachable at ${BACKEND_URL} (curl rc=${curl_rc}, http ${http_code:-none})"
    exit 2
fi
ok "backend reachable (${BACKEND_URL})"

# --- mint a backend-shape JWT (userId claim, HS256) ------------------------
# Matches SimLobbyController::personIdFromLoginJwtPayload which looks for
# {"userId":"<int-as-string>"} in the login-JWT payload and maps to
# users.id → persons.id.
b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }
now="$(date -u +%s)"
exp=$(( now + 3600 ))
header_b64="$(printf '{"alg":"HS256","typ":"JWT"}' | b64url)"
payload_b64="$(printf '{"userId":"%s","iat":%s,"exp":%s}' \
                       "${USER_ID}" "${now}" "${exp}" | b64url)"
signing_input="${header_b64}.${payload_b64}"
sig_b64="$(printf '%s' "${signing_input}" \
    | openssl dgst -sha256 -hmac "${JWT_SECRET}" -binary \
    | b64url)"
TOKEN="${signing_input}.${sig_b64}"
export TOKEN
ok "minted test JWT (userId=${USER_ID}, ttl=1h)"

# --- 1) parallel spawn ------------------------------------------------------
say "1) spawn ${CONCURRENT} matches in parallel"

# Worker fn — spawned CONCURRENT times in the background. Writes one line
# per success to ${MATCH_IDS_FILE} and one line per attempt to
# ${SPAWN_LATENCY_FILE}. Uses flock to serialize appends (bash echo >>
# is atomic for lines < PIPE_BUF but flock is bulletproof).
spawn_one() {
    local seed="$1"
    local t0 t1 elapsed_ms body http_code mid
    t0="$(date +%s%3N)"
    # --max-time 60: the backend's SimOrchestrator caps concurrent
    # podman create+start calls at FH_SIM_LAUNCH_MAX_CONCURRENCY
    # (default 4). Under CONCURRENT=20 the 20th caller waits for
    # ~5 batches × ~3 s each ≈ 15 s of queue time plus its own
    # ~3 s podman work, so give a comfortable ceiling.
    body="$(curl -sS -X POST "${BACKEND_URL}/api/sim/matches" \
                 -H "Authorization: Bearer ${TOKEN}" \
                 -H "Content-Type: application/json" \
                 -d "{\"scenario_id\":0,\"seed\":${seed},\"tick_hz\":20}" \
                 -w '\n%{http_code}' \
                 --max-time 60 2>&1 || echo -e "\nERR")"
    t1="$(date +%s%3N)"
    elapsed_ms=$(( t1 - t0 ))
    http_code="$(printf '%s' "${body}" | tail -n1)"
    body="$(printf '%s' "${body}" | sed '$d')"

    if [[ "${http_code}" == "200" ]]; then
        mid="$(printf '%s' "${body}" | jq -r '.id')"
        (
            flock 200
            echo "${mid}"        >> "${MATCH_IDS_FILE}"
            echo "${elapsed_ms}" >> "${SPAWN_LATENCY_FILE}"
        ) 200> "${STATE_DIR}/spawn.lock"
    else
        (
            flock 200
            echo "${elapsed_ms}" >> "${SPAWN_LATENCY_FILE}"
        ) 200> "${STATE_DIR}/spawn.lock"
        printf '    spawn-seed=%s HTTP %s: %s\n' \
               "${seed}" "${http_code}" "${body}" >&2
    fi
}
export -f spawn_one b64url
export BACKEND_URL TOKEN MATCH_IDS_FILE SPAWN_LATENCY_FILE STATE_DIR

spawn_wall_start="$(date +%s%3N)"
# Feed seed indices 1..CONCURRENT through xargs; -P N runs in parallel.
seq 1 "${CONCURRENT}" \
    | xargs -I{} -P "${CONCURRENT}" bash -c 'spawn_one "$@"' _ {}
spawn_wall_ms=$(( $(date +%s%3N) - spawn_wall_start ))

spawned_count="$(wc -l < "${MATCH_IDS_FILE}")"
info "spawn wall-clock: ${spawn_wall_ms} ms"
info "successful spawns: ${spawned_count}/${CONCURRENT}"
if [[ "${spawned_count}" -eq "${CONCURRENT}" ]]; then
    ok "all ${CONCURRENT} matches spawned"
else
    fail "only ${spawned_count}/${CONCURRENT} matches spawned"
fi

# Spawn latency assertion — every individual match must be under budget.
if [[ -s "${SPAWN_LATENCY_FILE}" ]]; then
    max_ms="$(sort -n "${SPAWN_LATENCY_FILE}" | tail -n1)"
    min_ms="$(sort -n "${SPAWN_LATENCY_FILE}" | head -n1)"
    # median = middle element after sort
    n="$(wc -l < "${SPAWN_LATENCY_FILE}")"
    mid_idx=$(( (n + 1) / 2 ))
    p50_ms="$(sort -n "${SPAWN_LATENCY_FILE}" | sed -n "${mid_idx}p")"
    info "spawn latency ms: min=${min_ms} p50=${p50_ms} max=${max_ms} (budget=${SPAWN_BUDGET_MS})"
    if [[ "${max_ms}" -le "${SPAWN_BUDGET_MS}" ]]; then
        ok "worst-case spawn ${max_ms}ms ≤ ${SPAWN_BUDGET_MS}ms budget"
    else
        fail "worst-case spawn ${max_ms}ms > ${SPAWN_BUDGET_MS}ms budget"
    fi
fi

# --- 2) verify containers running + DB rows consistent ---------------------
say "2) verify container + DB row for each spawned match"

running_container_count=0
running_srm_row_count=0
while read -r mid; do
    [[ -z "${mid}" ]] && continue
    # podman ps -a --filter name=... could match substrings; use exact name.
    if sudo podman ps --filter "name=^footballhome_sim_${mid}$" \
                       --format '{{.Names}}' 2>/dev/null \
            | grep -qxF "footballhome_sim_${mid}"; then
        running_container_count=$((running_container_count + 1))
    fi
done < "${MATCH_IDS_FILE}"

# One DB probe for all match_ids — cheaper than N round-trips.
if [[ -s "${MATCH_IDS_FILE}" ]]; then
    id_csv="$(paste -sd, "${MATCH_IDS_FILE}")"
    running_srm_row_count="$(sudo podman exec footballhome_db psql \
        -U footballhome_user -d footballhome -t -A -c \
        "SELECT COUNT(*) FROM sim_running_matches WHERE match_id IN (${id_csv});" \
        2>/dev/null | tr -d '[:space:]')"
    running_srm_row_count="${running_srm_row_count:-0}"
fi

info "containers up: ${running_container_count}/${spawned_count}"
info "sim_running_matches rows: ${running_srm_row_count}/${spawned_count}"

if [[ "${running_container_count}" -eq "${spawned_count}" ]]; then
    ok "all ${spawned_count} containers are Running"
else
    fail "only ${running_container_count}/${spawned_count} containers are Running"
fi
if [[ "${running_srm_row_count}" -eq "${spawned_count}" ]]; then
    ok "sim_running_matches rows match spawned set"
else
    fail "sim_running_matches rows: ${running_srm_row_count} != ${spawned_count}"
fi

# --- 3) let daemons tick idle for TICK_HOLD_SECONDS ------------------------
say "3) tick idle for ${TICK_HOLD_SECONDS} s"
info "daemons run at 20 Hz internally; no clients connected."
info "purpose: exercise the concurrent-tick path + reveal any crash-restart loops."

# Count containers whose name is exactly footballhome_sim_${mid} for
# each mid we spawned. Avoids miscounting the M0 legacy `footballhome_sim`
# and any leftover per-match containers from a prior test run.
count_our_containers_running() {
    local n=0
    while read -r mid; do
        [[ -z "${mid}" ]] && continue
        if sudo podman ps --filter "name=^footballhome_sim_${mid}$" \
                           --format '{{.Names}}' 2>/dev/null \
                | grep -qxF "footballhome_sim_${mid}"; then
            n=$((n + 1))
        fi
    done < "${MATCH_IDS_FILE}"
    echo "${n}"
}

for ((i = 0; i < TICK_HOLD_SECONDS; i += 5)); do
    sleep 5
    alive="$(count_our_containers_running)"
    info "t+$((i + 5))s: ${alive}/${spawned_count} test containers alive"
done

final_alive="$(count_our_containers_running)"
if [[ "${final_alive}" -eq "${spawned_count}" ]]; then
    ok "all ${spawned_count} containers still running after ${TICK_HOLD_SECONDS}s hold"
else
    fail "only ${final_alive}/${spawned_count} still running after hold"
fi

# --- 4) parallel stop ------------------------------------------------------
say "4) stop ${spawned_count} matches in parallel"

stop_one() {
    local mid="$1"
    local t0 t1 elapsed_ms http_code
    t0="$(date +%s%3N)"
    # --max-time 60: stopMatch shares the same launch-concurrency
    # semaphore as spawns (see SimOrchestrator.cpp). Under a 20-way
    # parallel tear-down the 20th caller queues behind ~5 batches of
    # 4 × ~5 s SIGTERM-grace each ≈ 25 s of queue time plus its own
    # ~5 s stop work. 60 s gives a comfortable ceiling.
    http_code="$(curl -sS -o /dev/null -X POST \
                     "${BACKEND_URL}/api/sim/matches/${mid}/stop" \
                     -H "Authorization: Bearer ${TOKEN}" \
                     -w '%{http_code}' \
                     --max-time 60 || echo 000)"
    t1="$(date +%s%3N)"
    elapsed_ms=$(( t1 - t0 ))
    (
        flock 200
        echo "${elapsed_ms}" >> "${STOP_LATENCY_FILE}"
    ) 200> "${STATE_DIR}/stop.lock"
    if [[ "${http_code}" != "200" ]]; then
        printf '    stop match_id=%s HTTP %s\n' "${mid}" "${http_code}" >&2
    fi
}
export -f stop_one
export STOP_LATENCY_FILE

stop_wall_start="$(date +%s%3N)"
xargs -I{} -P "${CONCURRENT}" bash -c 'stop_one "$@"' _ {} < "${MATCH_IDS_FILE}"
stop_wall_ms=$(( $(date +%s%3N) - stop_wall_start ))
info "stop wall-clock: ${stop_wall_ms} ms"

if [[ -s "${STOP_LATENCY_FILE}" ]]; then
    max_ms="$(sort -n "${STOP_LATENCY_FILE}" | tail -n1)"
    info "stop latency ms: max=${max_ms} (SIGTERM grace=5s → expect ~5000-7000 ms)"
fi

# --- 5) verify tear-down completeness --------------------------------------
say "5) verify no orphan containers or DB rows"

# Give podman a moment to reflect deletions.
sleep 2

orphan_containers=0
while read -r mid; do
    [[ -z "${mid}" ]] && continue
    if sudo podman ps -a --filter "name=^footballhome_sim_${mid}$" \
                          --format '{{.Names}}' 2>/dev/null \
            | grep -qxF "footballhome_sim_${mid}"; then
        orphan_containers=$((orphan_containers + 1))
        info "orphan container found: footballhome_sim_${mid}"
    fi
done < "${MATCH_IDS_FILE}"

if [[ "${orphan_containers}" -eq 0 ]]; then
    ok "zero orphan containers"
else
    fail "${orphan_containers} orphan container(s) survived stop"
fi

if [[ -s "${MATCH_IDS_FILE}" ]]; then
    id_csv="$(paste -sd, "${MATCH_IDS_FILE}")"
    orphan_srm="$(sudo podman exec footballhome_db psql \
        -U footballhome_user -d footballhome -t -A -c \
        "SELECT COUNT(*) FROM sim_running_matches WHERE match_id IN (${id_csv});" \
        2>/dev/null | tr -d '[:space:]')"
    orphan_srm="${orphan_srm:-0}"
    if [[ "${orphan_srm}" -eq 0 ]]; then
        ok "zero orphan sim_running_matches rows"
    else
        fail "${orphan_srm} orphan sim_running_matches row(s)"
    fi

    ended_count="$(sudo podman exec footballhome_db psql \
        -U footballhome_user -d footballhome -t -A -c \
        "SELECT COUNT(*) FROM sim_matches WHERE id IN (${id_csv}) AND ended_at IS NOT NULL;" \
        2>/dev/null | tr -d '[:space:]')"
    ended_count="${ended_count:-0}"
    if [[ "${ended_count}" -eq "${spawned_count}" ]]; then
        ok "all ${spawned_count} sim_matches rows have ended_at set"
    else
        fail "only ${ended_count}/${spawned_count} sim_matches rows have ended_at set"
    fi
fi

# Match IDs already reaped — clear the file so the cleanup trap doesn't
# double-fire /stop for them.
: > "${MATCH_IDS_FILE}"

# --- summary ---------------------------------------------------------------
say "summary"
if [[ "${failures}" -eq 0 ]]; then
    printf '  \033[1;32mALL ASSERTIONS PASSED\033[0m (concurrent=%s, hold=%ss)\n' \
           "${CONCURRENT}" "${TICK_HOLD_SECONDS}"
    exit 0
else
    printf '  \033[1;31m%s ASSERTION(S) FAILED\033[0m\n' "${failures}"
    exit 1
fi
