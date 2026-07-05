#!/usr/bin/env bash
# Weekly recurring-RSVP rollover worker.
#
# Called by cron (see scripts/rollover-cron.sample) at Sunday 20:00
# America/New_York — the exact moment RsvpMaterialization considers the
# next Mon–Sun window "open".  Mints a short-lived HS256 JWT signed with
# JWT_SECRET and POSTs to /api/match-series/rollover.
#
# Idempotent: the rollover service uses ON CONFLICT DO NOTHING, so a
# double-fire (e.g. re-running by hand) is a no-op.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Load env — JWT_SECRET lives here.  Not exported by default.
if [[ ! -f ./env ]]; then
  echo "[rollover] $(date -Iseconds) missing ./env" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1091
. ./env
set +a

if [[ -z "${JWT_SECRET:-}" ]]; then
  echo "[rollover] $(date -Iseconds) JWT_SECRET not set in env" >&2
  exit 1
fi

# Mint a 5-minute admin JWT.  requireBearer() presently only checks
# header presence, but we sign properly so this keeps working if that
# gate is tightened.  userId=1 is the seed system user (James / owner).
TOKEN=$(JWT_SECRET="$JWT_SECRET" python3 - <<'PY'
import base64, hashlib, hmac, json, os, time
def b64(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()
now = int(time.time())
hdr = b64(json.dumps({"alg":"HS256","typ":"JWT"}, separators=(",", ":")).encode())
pl  = b64(json.dumps({"userId":"1","email":"system@footballhome.org",
                     "iat":now,"exp":now+300}, separators=(",", ":")).encode())
sig = b64(hmac.new(os.environ["JWT_SECRET"].encode(),
                   f"{hdr}.{pl}".encode(),
                   hashlib.sha256).digest())
print(f"{hdr}.{pl}.{sig}")
PY
)

# Fire the rollover.  --fail-with-body: non-2xx → non-zero exit AND print body.
BODY=$(curl -sS --fail-with-body \
  -X POST http://localhost:3001/api/match-series/rollover \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}' 2>&1) || {
    echo "[rollover] $(date -Iseconds) FAILED: $BODY" >&2
    exit 1
  }

echo "[rollover] $(date -Iseconds) ok: $BODY"
