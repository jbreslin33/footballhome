#!/usr/bin/env bash
# Stop a per-developer stack (keeps the DB volume).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib-dev-slot.sh
source "$ROOT/scripts/dev/lib-dev-slot.sh"

load_dev_slot "${DEV:-${1:-}}"
cd "$ROOT"
dev_compose down
echo "[dev-down] stopped $COMPOSE_PROJECT_NAME (volume fhdev_${FH_DEV_SLUG}_db_data kept)"
echo "  Wipe DB volume: sudo make dev-down DEV=$FH_DEV_SLUG DEV_WIPE=1"
if [ "${DEV_WIPE:-0}" = "1" ]; then
  dev_compose down -v
  echo "[dev-down] volume removed"
fi
