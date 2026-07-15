#!/usr/bin/env bash
# sim/scripts/attribute_warm_image_spawn.sh — §21.7 item 1 investigation
#
# Attribute the ~1 s warm-image spawn floor observed by Slice 14.7's baseline
# load test (measured 865–1137 ms per warm-image single-shot spawn) across
# four buckets, so the §21.7 item 1 Fix line can point at a specific remedy
# proportional to which bucket dominates:
#
#   B1  POST /v1.41/containers/create              (podman REST create latency)
#   B2  POST /v1.41/containers/{id}/start          (podman REST start latency)
#   B3  start-API-return → sim's first stderr line (compound: podman container-
#                                                    boot + libc exec + main()
#                                                    entry + JWT/env parse +
#                                                    PgClient connect + 3× reg
#                                                    SELECTs + drift-check +
#                                                    ProfileStore construct +
#                                                    admin-conditional)
#   B4  sim's first stderr line → "listening on"   (registry-loaded log line +
#                                                    admin HTTP server bind +
#                                                    WS transport bind +
#                                                    upsertMatch + MatchStart
#                                                    insert)
#
# Wall-clock spawn latency ≈ B1 + B2 + B3 + B4.
#
# The four buckets sum to the observable wall-clock but do NOT further attribute
# the podman-side vs sim-side split inside B3 — B3 is deliberately compound
# because the sim binary emits no stderr line between exec() and the "loaded
# registries" line (verified against sim/src/main.cpp). Further attribution
# requires code-side instrumentation (out of scope for §21.7 item 1's first
# investigation pass; land as a follow-up if B3 dominates).
#
# Reads /srv/footballhome/env for POSTGRES_* + JWT_SECRET + FH_SIM_ADMIN_TOKEN
# (the same secrets backend/src/orchestration/SimOrchestrator.cpp buildSimEnv
# forwards to spawned daemons — so the daemon we spawn here is byte-identical
# to a production spawn modulo SIM_MATCH_ID / SIM_MATCH_SEED / SIM_SCENARIO).
#
# Runs N=5 iterations against the LIVE stack. Each iteration:
#   - Spawns footballhome_sim_${MATCH_ID} for MATCH_ID in [900001..900005]
#     using the actual production `SimOrchestrator::buildCreateRequest` shape
#     (Image / Env / HostConfig.NetworkMode / NetworkingConfig.Aliases /
#     Healthcheck all mirrored).
#   - Waits for "listening on 0.0.0.0:9100" in stderr or aborts at 10 s.
#   - Captures per-bucket ms timings via `date +%s%3N` on the host side and
#     `podman logs --timestamps` ISO-8601 timestamps on the container side.
#   - `podman stop -t 5` (SIGTERM, lets the daemon emit MatchEnd) then
#     `DELETE FROM sim_matches WHERE id = ${MATCH_ID}` (cascades to
#     sim_match_events + sim_match_inputs per the sim's own drift-guard hint).
#
# Reports min/median/max per bucket + overall wall-clock, plus the first
# iteration's full podman-log timeline so an operator can eyeball the internal
# markers ("loaded registries", "FH_SIM_ADMIN_TOKEN not set", …) if desired.
#
# READ-ONLY against podman config and DB schema. No container restart, no
# DB config change, no source-code change. Pure diagnostic instrument.
#
# Standing directives:
#   - Rootful podman: all podman calls use `sudo`; never `sudo -E`.
#   - No output filtering with head/tail/grep in user-visible output — internal
#     parsing uses head/grep for value extraction, not display truncation.
#   - Sleeps 1 s between iterations to let the podman socket queue drain.

set -euo pipefail

# ─── config ────────────────────────────────────────────────────────────
readonly ENV_FILE=/srv/footballhome/env
readonly SOCK=/run/podman/podman.sock
readonly API_BASE=http://d/v1.41
readonly IMAGE=localhost/footballhome_footballhome_sim:latest
readonly NETWORK=footballhome_footballhome_network
readonly N_ITERATIONS=5
readonly MATCH_ID_BASE=900000
readonly LISTEN_TIMEOUT_S=10
readonly LISTEN_MARKER='listening on 0.0.0.0:9100'
readonly SCENARIO=empty_pitch    # matches production default; ~0 ms scenario-
                                 # construct cost so it doesn't skew B4.
readonly SEED=42

# ─── prereqs ───────────────────────────────────────────────────────────
[[ -r $ENV_FILE ]] || { echo "ERROR: $ENV_FILE not readable" >&2; exit 1; }
[[ -S $SOCK    ]] || { echo "ERROR: $SOCK not a socket (podman rootful not up?)" >&2; exit 1; }
command -v jq   >/dev/null || { echo "ERROR: jq required"   >&2; exit 1; }
command -v curl >/dev/null || { echo "ERROR: curl required" >&2; exit 1; }

# Load env — JWT_SECRET, FH_SIM_ADMIN_TOKEN, and any DB overrides. The
# `set -a` / `set +a` sandwich causes every variable defined inside `source`
# to be exported into our environment, which is what the production
# SimOrchestrator relies on (its `envOrDefault` reads process env).
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a
# POSTGRES_* defaults mirror docker-compose.yml's `environment:` block for
# the backend service — that's the same source SimOrchestrator sees at
# runtime, and the value `footballhome_pass` is already committed to git
# (not a secret; the DB is not reachable outside the pod network).
: "${POSTGRES_HOST:=db}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_DB:=footballhome}"
: "${POSTGRES_USER:=footballhome_user}"
: "${POSTGRES_PASSWORD:=footballhome_pass}"
export POSTGRES_HOST POSTGRES_PORT POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD
# JWT_SECRET is a real secret and MUST come from $ENV_FILE — no default.
: "${JWT_SECRET:?required in $ENV_FILE}"

# ─── helpers ───────────────────────────────────────────────────────────
now_ms() { date +%s%3N; }

# Convert an ISO 8601 ns-precision timestamp (as emitted by
# `podman logs --timestamps`) to unix milliseconds. Falls back to empty
# string on parse failure so callers can detect it explicitly.
iso_to_ms() {
    local iso=$1
    date -u -d "$iso" +%s%3N 2>/dev/null || echo ""
}

psql_cmd() {
    sudo podman exec -i footballhome_db \
        psql -U footballhome_user -d footballhome -At -c "$1"
}

cleanup_iteration() {
    local mid=$1
    local name="footballhome_sim_${mid}"
    sudo podman rm -f "$name" >/dev/null 2>&1 || true
    # sim_matches → cascades to sim_match_events + sim_match_inputs per the
    # sim's own drift-guard hint at sim/src/main.cpp:303.
    psql_cmd "DELETE FROM sim_matches WHERE id = ${mid};" >/dev/null 2>&1 || true
}

cleanup_all() {
    local i
    for i in $(seq 1 "$N_ITERATIONS"); do
        cleanup_iteration $((MATCH_ID_BASE + i))
    done
}

trap cleanup_all EXIT

echo "── attribute_warm_image_spawn.sh ─────────────────────────────────────"
echo "config: N=${N_ITERATIONS}  image=${IMAGE}  network=${NETWORK}"
echo "        scenario=${SCENARIO}  seed=${SEED}  match_ids=$((MATCH_ID_BASE+1))..$((MATCH_ID_BASE+N_ITERATIONS))"
echo

# ─── measurement ────────────────────────────────────────────────────────
declare -a B1_ARR B2_ARR B3_ARR B4_ARR WALL_ARR
FIRST_ITER_TIMELINE=""

for iter in $(seq 1 "$N_ITERATIONS"); do
    match_id=$((MATCH_ID_BASE + iter))
    name="footballhome_sim_${match_id}"

    cleanup_iteration "$match_id"

    # Build create body — mirrors SimOrchestrator::buildCreateRequest
    # (backend/src/orchestration/SimOrchestrator.cpp) exactly:
    #   Image / Env (SIM_* + POSTGRES_* + JWT_SECRET + FH_SIM_ADMIN_TOKEN)
    #   HostConfig.NetworkMode + RestartPolicy (using "no" for diagnostic
    #     isolation — production uses on-failure/3 but RestartPolicy only
    #     fires on container EXIT so has zero effect on spawn timing)
    #   NetworkingConfig.EndpointsConfig aliases
    body=$(jq -n \
        --arg image "$IMAGE" \
        --arg net "$NETWORK" \
        --arg name "$name" \
        --arg match_id "$match_id" \
        --arg seed "$SEED" \
        --arg scenario "$SCENARIO" \
        --arg pg_host "${POSTGRES_HOST:-db}" \
        --arg pg_port "${POSTGRES_PORT:-5432}" \
        --arg pg_db   "${POSTGRES_DB:-footballhome}" \
        --arg pg_user "${POSTGRES_USER:-footballhome_user}" \
        --arg pg_pw   "$POSTGRES_PASSWORD" \
        --arg jwt     "$JWT_SECRET" \
        --arg admin   "${FH_SIM_ADMIN_TOKEN:-}" \
    '{
        Image: $image,
        Env: [
            "SIM_MATCH_ID="          + $match_id,
            "SIM_MATCH_SEED="        + $seed,
            "SIM_SCENARIO="          + $scenario,
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

    # ─── B1: POST /containers/create ──────────────────────────────────
    t0=$(now_ms)
    create_resp=$(sudo curl -s --unix-socket "$SOCK" \
        -H 'Content-Type: application/json' \
        -X POST -d "$body" \
        "${API_BASE}/containers/create?name=${name}")
    t1=$(now_ms)
    b1=$((t1 - t0))
    container_id=$(echo "$create_resp" | jq -r '.Id // empty')
    if [[ -z $container_id ]]; then
        echo "iter=${iter} create failed:" >&2
        echo "$create_resp" >&2
        exit 1
    fi

    # ─── B2: POST /containers/{id}/start ──────────────────────────────
    t2=$(now_ms)
    start_status=$(sudo curl -s --unix-socket "$SOCK" \
        -X POST -o /tmp/attrspawn.start.$$ -w "%{http_code}" \
        "${API_BASE}/containers/${container_id}/start")
    t3=$(now_ms)
    b2=$((t3 - t2))
    if [[ $start_status -lt 200 || $start_status -ge 300 ]]; then
        echo "iter=${iter} start returned HTTP ${start_status}:" >&2
        cat /tmp/attrspawn.start.$$ >&2
        rm -f /tmp/attrspawn.start.$$
        exit 1
    fi
    rm -f /tmp/attrspawn.start.$$

    # ─── B3+B4: poll logs for first-line ts and "listening" ts ────────
    deadline_s=$(( $(date +%s) + LISTEN_TIMEOUT_S ))
    listen_ts_iso=""
    first_ts_iso=""
    while :; do
        logs=$(sudo podman logs --timestamps "$name" 2>&1 || true)
        if [[ -n $logs ]]; then
            first_ts_iso=$(echo "$logs" | head -n 1 | awk '{print $1}')
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
        sleep 0.05
    done

    first_ms=$(iso_to_ms "$first_ts_iso")
    listen_ms=$(iso_to_ms "$listen_ts_iso")
    if [[ -z $first_ms || -z $listen_ms ]]; then
        echo "iter=${iter} failed to parse iso timestamps first='${first_ts_iso}' listen='${listen_ts_iso}'" >&2
        exit 1
    fi
    # Clamp negatives to 0 — small clock skew between the host `date +%s%3N`
    # and podman-recorded log timestamps can produce negative small values.
    b3=$(( first_ms - t3 ));   (( b3 < 0 )) && b3=0
    b4=$(( listen_ms - first_ms )); (( b4 < 0 )) && b4=0
    wall=$(( listen_ms - t0 ))

    B1_ARR+=("$b1")
    B2_ARR+=("$b2")
    B3_ARR+=("$b3")
    B4_ARR+=("$b4")
    WALL_ARR+=("$wall")

    printf 'iter=%d  B1=%4dms  B2=%4dms  B3=%4dms  B4=%4dms  wall=%4dms\n' \
        "$iter" "$b1" "$b2" "$b3" "$b4" "$wall"

    # Capture full timeline for the first iteration only
    if (( iter == 1 )); then
        FIRST_ITER_TIMELINE=$(sudo podman logs --timestamps "$name" 2>&1 || true)
    fi

    # SIGTERM + rm + DB cleanup. `podman stop -t 5` waits up to 5 s for the
    # daemon's shutdown sequence (writes MatchEnd + updateMatchEnded) to
    # complete before returning, so our DELETE below can't race the daemon.
    sudo podman stop -t 5 "$name" >/dev/null 2>&1 || true
    cleanup_iteration "$match_id"

    sleep 1  # let podman socket queue drain between iterations
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
stats "B1"   "${B1_ARR[@]}"
stats "B2"   "${B2_ARR[@]}"
stats "B3"   "${B3_ARR[@]}"
stats "B4"   "${B4_ARR[@]}"
stats "wall" "${WALL_ARR[@]}"

echo
echo "── first-iteration full timeline (podman logs --timestamps) ─────────"
echo "$FIRST_ITER_TIMELINE"
