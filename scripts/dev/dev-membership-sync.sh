#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# dev-membership-sync.sh — LeagueApps Membership → Sync now (CLI)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Same action as Club Admin → Members → "Sync now":
#   POST /api/admin/membership/sync?variant=all
#
# Fail-fast + verbose: any login/HTTP/program failure exits non-zero.
# Prints a per-program table and a 100% success line only when every
# program synced with zero failures.
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

die() { echo "ERROR: $*" >&2; exit 1; }

LOGIN_BODY="$(mktemp)"
SYNC_BODY="$(mktemp)"
cleanup() { rm -f "$LOGIN_BODY" "$SYNC_BODY"; }
trap cleanup EXIT

echo "==> [dev-membership-sync] slug=$FH_DEV_SLUG"
echo "    backend=$BE"
echo "    login=$EMAIL"
echo "    timeout=${CURL_MAX}s"

echo "==> waiting for backend health ($BE/health)"
ready=0
for i in $(seq 1 90); do
  if curl -fsS "$BE/health" >/dev/null 2>&1; then
    echo "    healthy after ~$((i * 2))s"
    ready=1
    break
  fi
  if [ $((i % 10)) -eq 0 ]; then
    echo "    still waiting… (${i}/90)"
  fi
  sleep 2
done
[ "$ready" -eq 1 ] || die "backend not healthy at $BE after ~3m — check: make dev-ps DEV=$FH_DEV_SLUG"

echo "==> POST $BE/api/auth/login"
HTTP_CODE="$(curl -sS -o "$LOGIN_BODY" -w '%{http_code}' -X POST "$BE/api/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}")"
echo "    HTTP $HTTP_CODE"
if [ "$HTTP_CODE" != "200" ]; then
  echo "---- login body ----" >&2
  head -c 800 "$LOGIN_BODY" >&2 || true
  echo >&2
  die "login failed (HTTP $HTTP_CODE) — check DEV_ADMIN_EMAIL/PASSWORD and that mirror has the club-admin user"
fi

TOKEN="$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print((d.get("data") or {}).get("token") or "")' "$LOGIN_BODY")"
[ -n "$TOKEN" ] || die "login 200 but no token in body"
echo "    got JWT (${#TOKEN} chars)"

echo "==> POST $BE/api/admin/membership/sync?variant=all"
HTTP_CODE="$(curl -sS --max-time "$CURL_MAX" -o "$SYNC_BODY" -w '%{http_code}' -X POST \
  "$BE/api/admin/membership/sync?variant=all" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json')"
echo "    HTTP $HTTP_CODE"
if [ "$HTTP_CODE" != "200" ]; then
  echo "---- sync body ----" >&2
  head -c 1200 "$SYNC_BODY" >&2 || true
  echo >&2
  die "membership sync HTTP $HTTP_CODE"
fi

python3 - "$SYNC_BODY" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f:
    body = json.load(f)

ok = bool(body.get("success"))
data = body.get("data") or {}
programs = data.get("programs") or []
prog_ok = data.get("programsOk", 0)
prog_fail = data.get("programsFailed", 0)
total = data.get("totalRecords", 0)
elapsed = data.get("elapsedMs", 0)

print("---- per-program results ----")
if not programs:
    print("  (no programs returned — leagueapps_programs empty after mirror?)")
else:
    for p in programs:
        status = "OK" if p.get("ok") else "FAIL"
        name = p.get("programName") or ""
        err = p.get("error") or ""
        print(
            f"  [{status}] id={p.get('programId')} "
            f"cat={p.get('category')} var={p.get('variant')} "
            f"records={p.get('recordCount')} "
            f"ms={p.get('elapsedMs')} {name}"
        )
        if err:
            print(f"         error: {err}")

print("---- summary ----")
print(f"  programsOk={prog_ok}  programsFailed={prog_fail}  totalRecords={total}  elapsedMs={elapsed}")

if not ok:
    print("ERROR: API success=false", file=sys.stderr)
    sys.exit(1)
if not programs:
    print("ERROR: zero programs synced — cannot claim success", file=sys.stderr)
    sys.exit(1)
if prog_fail:
    print(f"ERROR: {prog_fail} program(s) failed — fix LA keys / network and re-run", file=sys.stderr)
    sys.exit(1)

print(f"✓ 100% SUCCESS — membership sync ({prog_ok}/{prog_ok} programs, {total} records)")
PY
