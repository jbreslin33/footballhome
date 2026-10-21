#!/usr/bin/env bash
# sim/scripts/mint-dev-jwt.sh
#
# Mint a sim-side HS256 JWT for local development. The claims are:
#   { "person_id": <int>, "iat": <now>, "exp": <now + hours*3600> }
# matching what sim/src/net/JwtVerifier expects.
#
# The signing key is JWT_SECRET, read from ../env by default (the
# repo-root env file, same one docker-compose consumes). Override with
# --secret-file <path> or the JWT_SECRET environment variable.
#
# Usage:
#   sim/scripts/mint-dev-jwt.sh [PERSON_ID] [HOURS]
#     PERSON_ID  integer person_id claim (default: 42)
#     HOURS      lifetime in hours    (default: 8)
#
# Prints the token on stdout. A convenience URL is printed on stderr.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

person_id="${1:-42}"
hours="${2:-8}"

if ! [[ "${person_id}" =~ ^[0-9]+$ ]]; then
    echo "error: PERSON_ID must be a non-negative integer" >&2
    exit 2
fi
if ! [[ "${hours}" =~ ^[0-9]+$ ]] || (( hours == 0 )); then
    echo "error: HOURS must be a positive integer" >&2
    exit 2
fi

# Resolve JWT_SECRET.
if [[ -z "${JWT_SECRET:-}" ]]; then
    env_file="${REPO_ROOT}/env"
    if [[ ! -f "${env_file}" ]]; then
        echo "error: JWT_SECRET not set and ${env_file} not found" >&2
        exit 3
    fi
    # shellcheck disable=SC2046
    JWT_SECRET="$(grep -E '^JWT_SECRET=' "${env_file}" | tail -n1 | cut -d= -f2-)"
fi
if [[ -z "${JWT_SECRET}" ]]; then
    echo "error: JWT_SECRET is empty" >&2
    exit 3
fi

# --- b64url helpers ---------------------------------------------------------
b64url() {
    # stdin → base64url (no padding). openssl is available everywhere the
    # sim itself is buildable.
    openssl base64 -A | tr '+/' '-_' | tr -d '='
}

now="$(date -u +%s)"
exp=$(( now + hours * 3600 ))

header='{"alg":"HS256","typ":"JWT"}'
payload="{\"person_id\":${person_id},\"iat\":${now},\"exp\":${exp}}"

header_b64="$(printf '%s' "${header}"  | b64url)"
payload_b64="$(printf '%s' "${payload}" | b64url)"
signing_input="${header_b64}.${payload_b64}"

sig_b64="$(printf '%s' "${signing_input}" \
    | openssl dgst -sha256 -hmac "${JWT_SECRET}" -binary \
    | b64url)"

token="${signing_input}.${sig_b64}"

echo "${token}"

# Emit a click-ready URL on stderr so `... > /tmp/tok` still works cleanly.
{
    echo
    echo "person_id: ${person_id}"
    echo "expires:   $(date -u -d "@${exp}" '+%Y-%m-%dT%H:%M:%SZ')"
    echo "demo URL:  http://localhost:3000/sim.html?token=${token}"
} >&2
