#!/usr/bin/env bash
#
# check_registry_consistency.sh
# =============================
#
# Slice 30.1 / §21.8 M3-blocker item 1 remedy — guards the fresh sim runtime
# image against `verifyM0RegistryConsistency` bootstrap crashes.
#
# Symptom this script prevents:
#   Root cause discovered 2026-07-17 (see sim/DESIGN.md §21.8): Slice 27.3's
#   migration 220 added `physical.body_mass` (attribute id=15) to the DB, but
#   the sim runtime image tagged `localhost/footballhome_footballhome_sim:latest`
#   (the tag hard-coded at backend/src/orchestration/SimOrchestrator.cpp
#   `kSimImageTag`) had not been rebuilt, so its compile-time count was 14 while
#   the DB now had 15 rows. Every new match spawn crashed the sim at boot with:
#
#     footballhome_sim: registry bootstrap failed: verifyM0RegistryConsistency:
#       attribute registry size mismatch: compile-time=14 db=15
#       (regenerate M0Registry.generated.hpp?)
#
#   Because SimOrchestrator's HTTP-side launchMatch call succeeds regardless of
#   whether the sim binary boots (podman-start returns 200 the moment the
#   container starts running, not when the sim opens port 9100), the failure
#   presents on the browser as "nothing renders on 2v0" — no error surfaced to
#   the operator without direct `sudo podman logs` inspection.
#
# What this script does:
#   1. Spawn a throwaway probe container from the latest built sim image on
#      the shared `footballhome_footballhome_network` so it can reach the live
#      footballhome_db.
#   2. Exercise the exact bootstrap path (registry SELECT + drift check) that
#      new matches will hit.
#   3. Poll the probe's stderr for up to 10 s. If the probe emits
#      `verifyM0RegistryConsistency`, fail LOUDLY with the exact stderr and a
#      remediation hint pointing at `gen_registry_header.awk`. If the probe
#      reaches the "listening on ..." line, we know the drift check passed —
#      kill the probe and exit 0.
#   4. Never leave a probe container running: always `sudo podman rm -f`
#      before exit.
#
# Intended caller: `make sim-deploy` (Makefile target added in the same slice).
# Standalone use is fine — no arguments required. Honors env overrides:
#
#   SIM_IMAGE      (default: localhost/footballhome_footballhome_sim:latest)
#   SIM_NETWORK    (default: footballhome_footballhome_network)
#   PROBE_TIMEOUT  (default: 10 seconds — 10 × 1 s polls; sim boot is ~90 ms
#                   per §21.7 item 1 attribution data, so 10 s is 100× the
#                   observed clean-boot floor)
#
# Exit codes:
#   0  — drift check passed (sim booted cleanly against the live DB)
#   1  — drift detected OR probe failed to reach the "listening" line inside
#        PROBE_TIMEOUT seconds (both are treated as "do not deploy this
#        image").
#
# Design constraint: script produces FULL logs on failure — never truncated,
# no `head`/`tail`/`grep` filtering of the stderr surfaced to the operator
# (see .github/copilot-instructions.md "Terminal Command Rules"). Internal
# `grep -q` for existence tests is fine.

set -euo pipefail

readonly SIM_IMAGE="${SIM_IMAGE:-localhost/footballhome_footballhome_sim:latest}"
readonly SIM_NETWORK="${SIM_NETWORK:-footballhome_footballhome_network}"
readonly PROBE_TIMEOUT="${PROBE_TIMEOUT:-10}"

# Verify prerequisites before we do anything destructive.
if ! sudo podman image exists "$SIM_IMAGE"; then
    echo "❌ sim image '$SIM_IMAGE' not found — run 'make sim-deploy' or 'podman-compose build footballhome_sim' first." >&2
    exit 1
fi

if ! sudo podman network exists "$SIM_NETWORK"; then
    echo "❌ network '$SIM_NETWORK' not found — is the stack up? Try 'make up' first." >&2
    exit 1
fi

readonly PROBE_NAME="fh_sim_registry_probe_$$"

cleanup() {
    sudo podman rm -f "$PROBE_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Match the container env vars docker-compose.yml sets on the real sim
# service. SIM_MATCH_ID=999999 is out of the real match_id range (which
# grows sequentially from 1 via `sim_matches` PK) so the probe's transient
# upsertMatch row is trivially identifiable + cleanable if ever needed.
# NOTE: no --rm here — we want the exit code / stderr preserved after early
# exit so cleanup() can still surface a useful message. `trap cleanup EXIT`
# will still hard-remove the container on any exit path.
#
# JWT_SECRET is a mandatory env var for the sim binary (see sim/src/main.cpp
# line 216) — the probe never actually verifies a JWT (no client connects),
# so any non-empty placeholder works. Using a distinctive throwaway makes it
# obvious in logs that this is not a real secret.
sudo podman run -d \
    --name "$PROBE_NAME" \
    --network "$SIM_NETWORK" \
    -e JWT_SECRET=fh-sim-registry-probe-placeholder-not-a-real-secret \
    -e POSTGRES_HOST=footballhome_db \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_DB=footballhome \
    -e POSTGRES_USER=footballhome_user \
    -e POSTGRES_PASSWORD=footballhome_pass \
    -e SIM_BIND_ADDRESS=0.0.0.0 \
    -e SIM_PORT=9100 \
    -e SIM_MATCH_ID=999999 \
    -e SIM_MATCH_SEED=42 \
    "$SIM_IMAGE" >/dev/null

# Poll for either failure or success marker.
probe_exited_early=0
for _ in $(seq 1 "$PROBE_TIMEOUT"); do
    sleep 1
    probe_logs="$(sudo podman logs "$PROBE_NAME" 2>&1 || true)"
    if grep -q 'verifyM0RegistryConsistency' <<<"$probe_logs"; then
        echo "❌ REGISTRY DRIFT DETECTED — freshly-built sim image aborts at bootstrap." >&2
        echo "" >&2
        echo "The compile-time M0Registry.generated.hpp does not match the live DB's" >&2
        echo "sim_attribute_registry + sim_concept_registry row counts. Full sim stderr:" >&2
        echo "" >&2
        # Indent probe logs by 4 spaces for readability; full content, no truncation.
        sed 's/^/    /' <<<"$probe_logs" >&2
        echo "" >&2
        echo "Remediation:" >&2
        echo "  1. Regenerate the header on host (from sim/DESIGN.md §22.11):" >&2
        echo "" >&2
        echo "       awk -f sim/scripts/gen_registry_header.awk \\" >&2
        echo "           \$(grep -l 'INTO sim_attribute_registry\\|INTO sim_concept_registry' \\" >&2
        echo "                    database/migrations/*.sql | sort) \\" >&2
        echo "           > sim/src/common/M0Registry.generated.hpp" >&2
        echo "" >&2
        echo "  2. Commit the regenerated header." >&2
        echo "  3. Re-run 'make sim-deploy'." >&2
        exit 1
    fi
    if grep -q 'listening on' <<<"$probe_logs"; then
        echo "✓ Registry consistency verified — sim probe booted cleanly against the live DB."
        exit 0
    fi
    # If the container is no longer running (exited without emitting either
    # marker), abandon the loop — waiting longer won't produce new logs.
    probe_state="$(sudo podman inspect "$PROBE_NAME" --format '{{.State.Status}}' 2>/dev/null || echo unknown)"
    if [[ "$probe_state" != "running" ]]; then
        probe_exited_early=1
        break
    fi
done

# Either we timed out or the probe exited early. Grab final logs (container
# is still present because we dropped --rm) and treat as failure.
final_logs="$(sudo podman logs "$PROBE_NAME" 2>&1 || echo '(no logs available)')"
final_state="$(sudo podman inspect "$PROBE_NAME" --format '{{.State.Status}} exit={{.State.ExitCode}}' 2>/dev/null || echo unknown)"
if [[ "$probe_exited_early" -eq 1 ]]; then
    echo "❌ Registry probe container exited early ($final_state) without hitting 'listening on' or a known bootstrap error." >&2
else
    echo "❌ Registry probe timed out after ${PROBE_TIMEOUT}s without hitting 'listening on' or a bootstrap error (container state: $final_state)." >&2
fi
echo "" >&2
echo "This usually means one of:" >&2
echo "  - A required env var is missing (JWT_SECRET, POSTGRES_PASSWORD, …)." >&2
echo "  - The DB is unreachable from the probe (network / host / creds)." >&2
echo "  - The sim binary hung mid-bootstrap (regression not previously seen)." >&2
echo "  - PROBE_TIMEOUT is too short for this host (raise it and retry)." >&2
echo "" >&2
echo "Full probe stderr:" >&2
echo "" >&2
sed 's/^/    /' <<<"$final_logs" >&2
exit 1
