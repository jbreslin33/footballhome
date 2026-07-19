#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# dev-membership-sync.sh — LeagueApps Membership → Sync now (CLI)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Same action as Club Admin → Members → "Sync now":
#   POST /api/admin/membership/sync?variant=all
#
# Usage:
#   DEV=jbreslin ./scripts/dev/dev-membership-sync.sh
#   make dev-membership-sync DEV=jbreslin
#
# Credentials (defaults match the bootstrap club-admin account):
#   DEV_ADMIN_EMAIL / DEV_ADMIN_PASSWORD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib-dev-slot.sh
source "$ROOT/scripts/dev/lib-dev-slot.sh"

load_dev_slot "${DEV:-${1:-}}"

EMAIL="${DEV_ADMIN_EMAIL:-soccer@lighthouse1893.org}"
PASSWORD="${DEV_ADMIN_PASSWORD:-1893Soccer!}"
BE="http://127.0.0.1:${FH_DEV_BACKEND_PORT}"
# Full LA fan-out can take several minutes on a cold slot.
CURL_MAX="${DEV_MEMBERSHIP_SYNC_TIMEOUT:-900}"

echo "[dev-membership-sync] slug=$FH_DEV_SLUG backend=$BE"

echo "[dev-membership-sync] waiting for backend health"
ready=0
for _ in $(seq 1 90); do
  if curl -fsS "$BE/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done
if [ "$ready" -ne 1 ]; then
  echo "ERROR: backend not healthy at $BE after ~3m" >&2
  exit 1
fi

echo "[dev-membership-sync] logging in as $EMAIL"
LOGIN_JSON="$(curl -fsS -X POST "$BE/api/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}")"

TOKEN="$(printf '%s' "$LOGIN_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("data") or {}).get("token") or "")')"
if [ -z "$TOKEN" ]; then
  echo "ERROR: login did not return a token" >&2
  printf '%s\n' "$LOGIN_JSON" | head -c 400 >&2
  echo >&2
  exit 1
fi

echo "[dev-membership-sync] POST /api/admin/membership/sync?variant=all (timeout ${CURL_MAX}s)"
SYNC_JSON="$(curl -fsS --max-time "$CURL_MAX" -X POST \
  "$BE/api/admin/membership/sync?variant=all" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json')"

printf '%s' "$SYNC_JSON" | python3 -c '
import json, sys
body = json.load(sys.stdin)
ok = bool(body.get("success"))
data = body.get("data") or {}
prog_ok = data.get("programsOk", "?")
prog_fail = data.get("programsFailed", "?")
elapsed = data.get("elapsedMs", "?")
if not ok:
    print("ERROR: membership sync reported success=false", file=sys.stderr)
    print(json.dumps(body, indent=2)[:800], file=sys.stderr)
    sys.exit(1)
print(f"[dev-membership-sync] ok programsOk={prog_ok} programsFailed={prog_fail} elapsedMs={elapsed}")
if isinstance(prog_fail, int) and prog_fail > 0:
    print(f"[dev-membership-sync] WARNING: {prog_fail} program(s) failed — UI Sync now can retry", file=sys.stderr)
'

echo "[dev-membership-sync] done — Members screen should show fresh LA data"
