#!/usr/bin/env bash
# sim/scripts/attribute_pool_assign_latency.sh — §21.7 item 1 step 6
#
# Measures the pool-path spawn latency — the user-visible replacement for
# attribute_warm_image_spawn.sh's B1+B2 podman-side floor now that steps
# 5A–5F have shipped the warm-daemon pool. The pool amortizes B1+B2 into
# the refill thread's background work; the hot path a user request travels
# is:
#
#   pool.take()                          — O(1), in-process, ~µs
#   HttpClient::postJson(admin/assign)   — one HTTP round-trip on the
#                                          compose bridge to the daemon's
#                                          admin port 9101
#   sim's hot-phase boot                 — upsertMatch + MatchStart insert
#                                          + WS transport bind (~85 ms
#                                          median per step 5A's B4)
#
# This script measures the two wire-hop components separately so operators
# can attribute where any remaining spend goes:
#
#   P1  postAssignMatch round-trip       (host → sim admin :9101 → sim
#                                          gate.assign(a) → HTTP 200)
#   P2  hot-phase boot                    (assign response → "listening on
#                                          0.0.0.0:9100")
#
# §23.4 box 5 exit criterion:  MEDIAN P1 ≤ 50 ms   over N=5 iterations,
# un-contended, empty_pitch scenario. That target reflects the substitution
# of a single-digit HTTP hop for the ~800 ms podman B1+B2 floor documented
# in §21.7 item 1's baseline.
#
# Runs against the LIVE stack but uses test-namespaced containers
# (footballhome_sim_test_warm_${i}) to avoid colliding with the real pool's
# footballhome_sim_warm_${warm_id} range. Each iteration:
#
#   1. Spawn a test warm daemon (byte-identical to SimOrchestrator::
#      spawnWarm — image, network, env manifest with empty SIM_MATCH_ID).
#   2. Wait for the "SIM_MATCH_ID unset — waiting for POST /admin/assign_match"
#      log (marks the daemon as READY to receive an assign).
#   3. Resolve the container's compose-network IP via `podman inspect`.
#   4. curl POST /admin/assign_match with the FH_SIM_ADMIN_TOKEN bearer;
#      record time_total → P1_ms.
#   5. Wait for "listening on 0.0.0.0:9100" log; delta from P1 completion
#      → P2_ms.
#   6. podman stop -t 5 + rm + DELETE FROM sim_matches WHERE id=...
#
# Reports min/median/max for P1, P2, and their sum + the first iteration's
# full podman log timeline so an operator can eyeball the internal markers
# ("assigned via admin", "loaded registries", "WebSocketTransport bound",
# …) if desired.
#
# READ-ONLY against podman config and DB schema. No container restart, no
# DB config change, no source-code change. Pure diagnostic instrument.
#
# Standing directives (identical to attribute_warm_image_spawn.sh):
#   - Rootful podman: all podman calls use `sudo`; never `sudo -E`.
#   - No output filtering with head/tail/grep in user-visible output —
#     internal parsing uses head/grep for value extraction, not display
#     truncation.
#   - Sleeps 1 s between iterations to let the podman socket queue drain.

set -euo pipefail

# ─── config ────────────────────────────────────────────────────────────
readonly ENV_FILE=/srv/footballhome/env
readonly SOCK=/run/podman/podman.sock
readonly API_BASE=http://d/v1.41
readonly IMAGE=localhost/footballhome_footballhome_sim:latest
readonly NETWORK=footballhome_footballhome_network
readonly N_ITERATIONS=5
readonly NAME_PREFIX=footballhome_sim_test_warm_
readonly WAIT_MARKER='waiting for POST /admin/assign_match'
readonly LISTEN_MARKER='listening on 0.0.0.0:9100'
readonly WAIT_TIMEOUT_S=10
readonly LISTEN_TIMEOUT_S=10
readonly SCENARIO_ID=0             # scenario_id=0 → empty_pitch; matches
                                   # attribute_warm_image_spawn.sh's choice
readonly SEED=42
readonly MATCH_ID_BASE=910000      # disjoint from the cold-spawn script's
                                   # 900000+ range and disjoint from any
                                   # production match_id range

# ─── prereqs ───────────────────────────────────────────────────────────
[[ -r $ENV_FILE ]] || { echo "ERROR: $ENV_FILE not readable" >&2; exit 1; }
[[ -S $SOCK    ]] || { echo "ERROR: $SOCK not a socket (podman rootful not up?)" >&2; exit 1; }
command -v jq   >/dev/null || { echo "ERROR: jq required"   >&2; exit 1; }
command -v curl >/dev/null || { echo "ERROR: curl required" >&2; exit 1; }

# Load env — JWT_SECRET, FH_SIM_ADMIN_TOKEN, and any DB overrides. Same
# `set -a` / `source` / `set +a` sandwich as attribute_warm_image_spawn.sh.
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a
: "${POSTGRES_HOST:=db}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_DB:=footballhome}"
: "${POSTGRES_USER:=footballhome_user}"
: "${POSTGRES_PASSWORD:=footballhome_pass}"
export POSTGRES_HOST POSTGRES_PORT POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD
: "${JWT_SECRET:?required in $ENV_FILE}"
: "${FH_SIM_ADMIN_TOKEN:?required in $ENV_FILE — assign_match auth requires it}"

# ─── helpers ───────────────────────────────────────────────────────────
now_ms() { date +%s%3N; }

iso_to_ms() {
    local iso=$1
    date -u -d "$iso" +%s%3N 2>/dev/null || echo ""
}

psql_cmd() {
    sudo podman exec -i footballhome_db \
        psql -U footballhome_user -d footballhome -At -c "$1"
}

cleanup_iteration() {
    local i=$1
    local name="${NAME_PREFIX}${i}"
    local match_id=$((MATCH_ID_BASE + i))
    sudo podman rm -f "$name" >/dev/null 2>&1 || true
    # sim_matches → cascades to sim_match_events + sim_match_inputs.
    psql_cmd "DELETE FROM sim_matches WHERE id = ${match_id};" >/dev/null 2>&1 || true
}

cleanup_all() {
    local i
    for i in $(seq 1 "$N_ITERATIONS"); do
        cleanup_iteration "$i"
    done
}

trap cleanup_all EXIT

echo "── attribute_pool_assign_latency.sh ──────────────────────────────────"
echo "config: N=${N_ITERATIONS}  image=${IMAGE}  network=${NETWORK}"
echo "        scenario_id=${SCENARIO_ID}  seed=${SEED}"
echo "        containers=${NAME_PREFIX}1..${NAME_PREFIX}${N_ITERATIONS}"
echo "        match_ids=$((MATCH_ID_BASE+1))..$((MATCH_ID_BASE+N_ITERATIONS))"
echo

# ─── measurement ────────────────────────────────────────────────────────
declare -a P1_ARR P2_ARR SUM_ARR
FIRST_ITER_TIMELINE=""

for iter in $(seq 1 "$N_ITERATIONS"); do
    name="${NAME_PREFIX}${iter}"
    match_id=$((MATCH_ID_BASE + iter))

    cleanup_iteration "$iter"

    # Build create body — mirrors SimOrchestrator::spawnWarm (5A) exactly:
    #   Image / Env (SIM_* including EMPTY-STRING overrides for
    #     SIM_MATCH_ID/SEED/SCENARIO so the image's ENV defaults don't
    #     leak through and the sim takes the assign-wait branch —
    #     see §21.7 item 1 step 5A note in sim/DESIGN.md)
    #   HostConfig.NetworkMode + RestartPolicy=no
    #   NetworkingConfig.EndpointsConfig aliases
    body=$(jq -n \
        --arg image "$IMAGE" \
        --arg net "$NETWORK" \
        --arg name "$name" \
        --arg pg_host "${POSTGRES_HOST:-db}" \
        --arg pg_port "${POSTGRES_PORT:-5432}" \
        --arg pg_db   "${POSTGRES_DB:-footballhome}" \
        --arg pg_user "${POSTGRES_USER:-footballhome_user}" \
        --arg pg_pw   "$POSTGRES_PASSWORD" \
        --arg jwt     "$JWT_SECRET" \
        --arg admin   "$FH_SIM_ADMIN_TOKEN" \
    '{
        Image: $image,
        Env: [
            "SIM_MATCH_ID=",
            "SIM_MATCH_SEED=",
            "SIM_SCENARIO=",
            "SIM_BIND_ADDRESS=0.0.0.0",
            "SIM_PORT=9100",
            "SIM_ADMIN_BIND_ADDRESS=0.0.0.0",
            "SIM_ADMIN_PORT=9101",
            "POSTGRES_HOST="         + $pg_host,
            "POSTGRES_PORT="         + $pg_port,
            "POSTGRES_DB="           + $pg_db,
            "POSTGRES_USER="         + $pg_user,
            "POSTGRES_PASSWORD="     + $pg_pw,
            "JWT_SECRET="            + $jwt,
            "FH_SIM_ADMIN_TOKEN="    + $admin
        ],
        HostConfig: {
            NetworkMode:   $net,
            RestartPolicy: { Name: "no", MaximumRetryCount: 0 }
        },
        NetworkingConfig: {
            EndpointsConfig: {
                ($net): { Aliases: [$name] }
            }
        }
    }')

    # ─── spawn: create + start (amortized in the real pool by the
    # refill thread; timed here only for total-cost bookkeeping, NOT
    # counted toward P1 or P2 which represent the user-visible hot path)
    create_resp=$(sudo curl -s --unix-socket "$SOCK" \
        -H 'Content-Type: application/json' \
        -X POST -d "$body" \
        "${API_BASE}/containers/create?name=${name}")
    container_id=$(echo "$create_resp" | jq -r '.Id // empty')
    if [[ -z $container_id ]]; then
        echo "iter=${iter} create failed:" >&2
        echo "$create_resp" >&2
        exit 1
    fi

    start_status=$(sudo curl -s --unix-socket "$SOCK" \
        -X POST -o /tmp/poolassign.start.$$ -w "%{http_code}" \
        "${API_BASE}/containers/${container_id}/start")
    if [[ $start_status -lt 200 || $start_status -ge 300 ]]; then
        echo "iter=${iter} start returned HTTP ${start_status}:" >&2
        cat /tmp/poolassign.start.$$ >&2
        rm -f /tmp/poolassign.start.$$
        exit 1
    fi
    rm -f /tmp/poolassign.start.$$

    # ─── wait for the "waiting for POST /admin/assign_match" log — this
    # confirms the daemon has reached the pre-assignment gate. Under a
    # real pool the refill thread has already done this before any user
    # request arrives, so this wait is amortized out.
    deadline_s=$(( $(date +%s) + WAIT_TIMEOUT_S ))
    wait_ts_iso=""
    while :; do
        logs=$(sudo podman logs --timestamps "$name" 2>&1 || true)
        if [[ -n $logs ]]; then
            wait_line=$(echo "$logs" | grep -m1 -F "$WAIT_MARKER" || true)
            if [[ -n $wait_line ]]; then
                wait_ts_iso=$(echo "$wait_line" | awk '{print $1}')
                break
            fi
        fi
        if (( $(date +%s) > deadline_s )); then
            echo "iter=${iter} timeout after ${WAIT_TIMEOUT_S}s waiting for '${WAIT_MARKER}'" >&2
            echo "── logs so far ──" >&2
            echo "$logs" >&2
            exit 1
        fi
        sleep 0.05
    done

    # ─── resolve compose-network IP for direct curl (aardvark DNS is
    # container-only; host curl uses raw IP on the bridge, which lives
    # in the host netns under rootful podman).
    container_ip=$(sudo podman inspect "$name" \
        --format "{{ (index .NetworkSettings.Networks \"${NETWORK}\").IPAddress }}")
    if [[ -z $container_ip ]]; then
        echo "iter=${iter} could not resolve compose-network IP for ${name}" >&2
        exit 1
    fi

    # ─── P1: postAssignMatch round-trip.
    #
    # Body shape matches AdminHttpServer's parseAssignMatchJson (three
    # fields: match_id u64>0, seed u64, scenario_id i16 0..32767) and
    # SimOrchestrator::postAssignMatch's on-wire payload byte-for-byte.
    # `%{time_total}` reports total wall time in seconds with 6-decimal
    # precision — dropping the leading "0." and pad-truncating to 3
    # digits yields ms.
    assign_body=$(jq -n \
        --argjson match_id "$match_id" \
        --argjson seed "$SEED" \
        --argjson scenario_id "$SCENARIO_ID" \
    '{ match_id: $match_id, seed: $seed, scenario_id: $scenario_id }')

    assign_out=$(sudo curl -sS \
        -o /tmp/poolassign.resp.$$ \
        -w '%{http_code} %{time_total}' \
        -X POST \
        -H "Authorization: Bearer ${FH_SIM_ADMIN_TOKEN}" \
        -H 'Content-Type: application/json' \
        -d "$assign_body" \
        "http://${container_ip}:9101/admin/assign_match")

    assign_status=$(echo "$assign_out" | awk '{print $1}')
    assign_time_s=$(echo "$assign_out" | awk '{print $2}')
    assign_body_resp=$(cat /tmp/poolassign.resp.$$)
    rm -f /tmp/poolassign.resp.$$

    if [[ $assign_status -ne 200 ]]; then
        echo "iter=${iter} assign returned HTTP ${assign_status}:" >&2
        echo "$assign_body_resp" >&2
        exit 1
    fi

    # Convert seconds (e.g. "0.007345") to ms integer via awk (portable
    # against locales that use "," decimal separator would break here;
    # our ENV_FILE-sourced LC is C so the "." form is safe).
    p1=$(awk -v s="$assign_time_s" 'BEGIN { printf "%d", s * 1000.0 + 0.5 }')

    # Timestamp of assign response arrival (host clock, ms) for P2
    # anchoring below.
    assign_done_ms=$(now_ms)

    # ─── P2: wait for "listening on 0.0.0.0:9100" — the WS bind marker.
    deadline_s=$(( $(date +%s) + LISTEN_TIMEOUT_S ))
    listen_ts_iso=""
    while :; do
        logs=$(sudo podman logs --timestamps "$name" 2>&1 || true)
        if [[ -n $logs ]]; then
            listen_line=$(echo "$logs" | grep -m1 -F "$LISTEN_MARKER" || true)
            if [[ -n $listen_line ]]; then
                listen_ts_iso=$(echo "$listen_line" | awk '{print $1}')
                break
            fi
        fi
        if (( $(date +%s) > deadline_s )); then
            echo "iter=${iter} timeout after ${LISTEN_TIMEOUT_S}s waiting for '${LISTEN_MARKER}'" >&2
            echo "── logs so far ──" >&2
            echo "$logs" >&2
            exit 1
        fi
        sleep 0.02
    done

    listen_ms=$(iso_to_ms "$listen_ts_iso")
    if [[ -z $listen_ms ]]; then
        echo "iter=${iter} failed to parse listen iso ts '${listen_ts_iso}'" >&2
        exit 1
    fi
    p2=$(( listen_ms - assign_done_ms ))
    (( p2 < 0 )) && p2=0    # small host↔container clock skew clamp
    sum=$(( p1 + p2 ))

    P1_ARR+=("$p1")
    P2_ARR+=("$p2")
    SUM_ARR+=("$sum")

    printf 'iter=%d  P1=%4dms  P2=%4dms  P1+P2=%4dms  (status=%s body=%s)\n' \
        "$iter" "$p1" "$p2" "$sum" "$assign_status" "$assign_body_resp"

    if (( iter == 1 )); then
        FIRST_ITER_TIMELINE=$(sudo podman logs --timestamps "$name" 2>&1 || true)
    fi

    sudo podman stop -t 5 "$name" >/dev/null 2>&1 || true
    cleanup_iteration "$iter"
    sleep 1
done

# ─── aggregate ─────────────────────────────────────────────────────────
stats() {
    local label=$1
    shift
    local n=$#
    local sorted
    sorted=$(printf '%s\n' "$@" | sort -n)
    local min max med
    min=$(echo "$sorted" | head -n 1)
    max=$(echo "$sorted" | tail -n 1)
    med=$(echo "$sorted" | sed -n "$(( (n + 1) / 2 ))p")
    printf '%-6s  min=%5dms  median=%5dms  max=%5dms\n' "$label" "$min" "$med" "$max"
}

echo
echo "── per-bucket summary (N=${N_ITERATIONS}) ────────────────────────────"
stats "P1"    "${P1_ARR[@]}"
stats "P2"    "${P2_ARR[@]}"
stats "P1+P2" "${SUM_ARR[@]}"

echo
echo "── §23.4 box 5 exit criterion check ─────────────────────────────────"
median_p1=$(printf '%s\n' "${P1_ARR[@]}" | sort -n | sed -n "$(( (N_ITERATIONS + 1) / 2 ))p")
if (( median_p1 <= 50 )); then
    printf 'PASS  median P1 = %dms ≤ 50ms — box 5 flips to [x]\n' "$median_p1"
else
    printf 'FAIL  median P1 = %dms > 50ms — investigate before flipping box 5\n' "$median_p1"
fi

echo
echo "── first-iteration full timeline (podman logs --timestamps) ─────────"
echo "$FIRST_ITER_TIMELINE"
