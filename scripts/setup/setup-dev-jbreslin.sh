#!/usr/bin/env bash
# Convenience wrapper — same as: ./scripts/setup/setup-dev-slot.sh jbreslin
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/setup-dev-slot.sh" jbreslin "$@"
