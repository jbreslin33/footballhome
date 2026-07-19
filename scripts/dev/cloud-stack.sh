#!/usr/bin/env bash
# Cursor Cloud — bring up the Football Home stack for agent testing.
#
# Uses Docker Compose (Makefile falls back when Podman is absent). Requires
# decrypted `env` (from AGE_PASSPHRASE + setup-age). After first successful
# boot, save a Cursor Environment snapshot so later agents start warm.
set -euo pipefail

cd "$(dirname "$0")/../.."
ROOT="$PWD"

log() { echo "[cloud-stack] $*"; }

if [ ! -f "$ROOT/env" ]; then
  if [ -n "${AGE_PASSPHRASE:-}" ]; then
    log "decrypting env"
    AGE_PASSPHRASE="$AGE_PASSPHRASE" ./scripts/setup/setup-age.sh
  else
    log "ERROR: no env file and AGE_PASSPHRASE unset."
    log "Add AGE_PASSPHRASE as a Cursor Runtime Secret for this environment."
    # Keep the terminal alive so the agent can still work on code-only tasks.
    exec sleep infinity
  fi
fi

# Ensure docker is up (idempotent if cloud-start already ran).
if ! docker info >/dev/null 2>&1; then
  ./scripts/dev/cloud-start.sh
fi

COMPOSE=(docker compose --env-file env)

log "building/starting db + backend + frontend"
# Skip sim + scraper VPN on cloud agents — not needed for Members/Person UI.
"${COMPOSE[@]}" up -d --build db backend frontend

log "waiting for postgres"
for i in $(seq 1 90); do
  if "${COMPOSE[@]}" exec -T db pg_isready -U footballhome_user -d footballhome >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

log "applying migrations"
make migrate || true

log "stack status"
"${COMPOSE[@]}" ps

log "frontend http://localhost:3000  backend http://localhost:3001"
log "Members/Person can sync live LeagueApps data via decrypted env."
log "keeping terminal alive"
exec sleep infinity
