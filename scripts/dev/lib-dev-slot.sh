#!/usr/bin/env bash
# Load a developer slot from config/dev-slots.conf into the environment.
# Usage: source scripts/dev/lib-dev-slot.sh <slug>
set -euo pipefail

_lib_dev_slot_root() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  echo "$here"
}

load_dev_slot() {
  local slug="${1:-}"
  local root slots line
  root="$(_lib_dev_slot_root)"
  slots="$root/config/dev-slots.conf"

  if [ -z "$slug" ]; then
    echo "ERROR: DEV slug required (example: DEV=jbreslin)" >&2
    echo "Known slots:" >&2
    awk '!/^#/ && NF { print "  " $1 "  frontend:" $2 " backend:" $3 " db:" $4 }' "$slots" >&2
    return 1
  fi
  # sanitize slug
  if ! [[ "$slug" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    echo "ERROR: invalid DEV slug '$slug' (use lowercase letters/digits/_/-)" >&2
    return 1
  fi
  if [ ! -f "$slots" ]; then
    echo "ERROR: missing $slots" >&2
    return 1
  fi

  line="$(awk -v s="$slug" '!/^#/ && $1==s { print; exit }' "$slots")"
  if [ -z "$line" ]; then
    echo "ERROR: DEV='$slug' not in $slots — add a row (ports + host prefix)." >&2
    return 1
  fi

  # shellcheck disable=SC2086
  set -- $line
  export FH_DEV_SLUG="$1"
  export FH_DEV_FRONTEND_PORT="$2"
  export FH_DEV_BACKEND_PORT="$3"
  export FH_DEV_DB_PORT="$4"
  export FH_DEV_HOST_PREFIX="${5:-$1}"
  export COMPOSE_PROJECT_NAME="fhdev_${FH_DEV_SLUG}"
  export FH_DEV_DIR="${FH_DEV_DIR:-/srv/footballhome-dev-${FH_DEV_SLUG}}"
  export FH_DEV_FRONTEND_URL="${FH_DEV_FRONTEND_URL:-https://${FH_DEV_HOST_PREFIX}.dev.footballhome.org}"
}

dev_compose() {
  local root
  root="$(_lib_dev_slot_root)"
  # Prefer docker compose, then podman-compose — same as Makefile.
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose --env-file "$root/env" -f "$root/docker-compose.dev.yml" "$@"
  elif command -v podman-compose >/dev/null 2>&1; then
    podman-compose --env-file "$root/env" -f "$root/docker-compose.dev.yml" "$@"
  else
    echo "ERROR: need docker compose or podman-compose" >&2
    return 1
  fi
}
