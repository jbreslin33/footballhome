#!/usr/bin/env bash
# Start a per-developer stack (db + backend + frontend).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib-dev-slot.sh
source "$ROOT/scripts/dev/lib-dev-slot.sh"

load_dev_slot "${DEV:-${1:-}}"

if [ ! -f "$ROOT/env" ]; then
  echo "ERROR: $ROOT/env missing — decrypt env.age or symlink from prod" >&2
  exit 1
fi

echo "[dev-up] slug=$FH_DEV_SLUG project=$COMPOSE_PROJECT_NAME"
echo "[dev-up] frontend=:$FH_DEV_FRONTEND_PORT backend=:$FH_DEV_BACKEND_PORT db=:$FH_DEV_DB_PORT"
echo "[dev-up] url=$FH_DEV_FRONTEND_URL"

cd "$ROOT"
dev_compose up -d --build db backend frontend

echo "[dev-up] waiting for db"
for i in $(seq 1 60); do
  if dev_compose exec -T db pg_isready -U footballhome_user -d footballhome >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[dev-up] migrate"
FH_DB_CONTAINER="footballhome_db_${FH_DEV_SLUG}" ./database/migrations/run-migrations.sh || true

echo "[dev-up] status"
dev_compose ps
echo "[dev-up] open http://127.0.0.1:$FH_DEV_FRONTEND_PORT"
echo "[dev-up] (optional) sudo make dev-restore-mirror DEV=$FH_DEV_SLUG"
