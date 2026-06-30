#!/usr/bin/env bash
#
# Refresh the long-lived Instagram User Access Token.
#
# Long-lived IG tokens live 60 days. Calling the refresh_access_token
# endpoint while the token is still valid mints a new one with another
# 60-day lifetime. Run via cron at ~50-day cadence so we always have
# a 10-day safety margin inside the expiry window.
#
# Side effects:
#   - Rewrites the INSTAGRAM_ACCESS_TOKEN= line in $REPO/env in place.
#   - Appends a timestamped line to $REPO/scripts/refresh-instagram-token.log
#   - Does NOT re-encrypt env.age (that needs the passphrase, which
#     can't live in cron). Re-encrypt manually after a refresh:
#         age -p -o env.age env
#     then commit env.age.
#
# Exit codes:
#   0  refreshed (or no-op if token unchanged)
#   1  curl failed / network error
#   2  Meta returned an error payload (token expired? scope dropped?)
#   3  env file missing or unparseable

set -euo pipefail

REPO="${REPO:-$(cd "$(dirname "$0")/.." && pwd)}"
ENV_FILE="${ENV_FILE:-$REPO/env}"
LOG_FILE="${LOG_FILE:-$REPO/scripts/refresh-instagram-token.log}"

log() {
    printf '[%s] %s\n' "$(date -Iseconds)" "$*" >> "$LOG_FILE"
}

die() {
    log "ERROR: $*"
    exit "${2:-1}"
}

[[ -r "$ENV_FILE" ]] || die "env file not readable: $ENV_FILE" 3

OLD_TOKEN="$(grep -E '^INSTAGRAM_ACCESS_TOKEN=' "$ENV_FILE" | head -n1 | cut -d= -f2-)"
[[ -n "$OLD_TOKEN" ]] || die "INSTAGRAM_ACCESS_TOKEN not found in $ENV_FILE" 3

RESPONSE="$(
    curl -sS -G \
        --data-urlencode "grant_type=ig_refresh_token" \
        --data-urlencode "access_token=$OLD_TOKEN" \
        "https://graph.instagram.com/refresh_access_token"
)" || die "curl failed" 1

# Look for error first — Meta returns {"error":{...}} on auth failures.
if printf '%s' "$RESPONSE" | grep -q '"error"'; then
    die "Meta error: $RESPONSE" 2
fi

NEW_TOKEN="$(
    printf '%s' "$RESPONSE" \
        | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])'
)" || die "could not parse access_token from response: $RESPONSE" 2

EXPIRES_IN="$(
    printf '%s' "$RESPONSE" \
        | python3 -c 'import json,sys; print(json.load(sys.stdin).get("expires_in","?"))'
)" || EXPIRES_IN="?"

if [[ "$NEW_TOKEN" == "$OLD_TOKEN" ]]; then
    log "no-op: refreshed token identical to existing (expires_in=$EXPIRES_IN)"
    exit 0
fi

# Rewrite the env line in place. Use python to avoid any sed-escaping
# headaches with the long token string.
python3 - "$ENV_FILE" "$NEW_TOKEN" <<'PY'
import re, sys
path, new = sys.argv[1], sys.argv[2]
src = open(path).read()
out, n = re.subn(
    r'^INSTAGRAM_ACCESS_TOKEN=.*$',
    'INSTAGRAM_ACCESS_TOKEN=' + new,
    src,
    count=1,
    flags=re.M,
)
assert n == 1, 'INSTAGRAM_ACCESS_TOKEN line not found'
open(path, 'w').write(out)
PY

log "refreshed token (expires_in=$EXPIRES_IN); env.age still holds the old token — re-encrypt manually"
exit 0
