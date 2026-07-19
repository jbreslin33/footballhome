#!/usr/bin/env bash
# Restore prod DB mirror into a per-developer stack's Postgres.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib-dev-slot.sh
source "$ROOT/scripts/dev/lib-dev-slot.sh"

load_dev_slot "${DEV:-${1:-}}"
cd "$ROOT"

# Point restore-mirror at this slot's db container via docker/podman exec.
export COMPOSE_PROJECT_NAME
export FH_DEV_SLUG

# Prefer dump from prod backups/ if present on host
if [ ! -f "$ROOT/backups/dev-mirror.sql.gz" ] && [ ! -f "$ROOT/backups/dev-mirror.sql" ]; then
  if [ -f /srv/footballhome/backups/dev-mirror.sql.gz ]; then
    mkdir -p "$ROOT/backups"
    ln -sfn /srv/footballhome/backups/dev-mirror.sql.gz "$ROOT/backups/dev-mirror.sql.gz"
    echo "[dev-restore] linked mirror from /srv/footballhome/backups/"
  elif [ -f /srv/footballhome/backups/dev-mirror.sql ]; then
    mkdir -p "$ROOT/backups"
    ln -sfn /srv/footballhome/backups/dev-mirror.sql "$ROOT/backups/dev-mirror.sql"
  fi
fi

# Override DB accessors for this named container
restore_into_slot() {
  local dump="${1:-}"
  local cname="footballhome_db_${FH_DEV_SLUG}"
  local engine=""
  if command -v podman >/dev/null 2>&1 && podman inspect "$cname" >/dev/null 2>&1; then
    engine=podman
  elif command -v docker >/dev/null 2>&1 && docker inspect "$cname" >/dev/null 2>&1; then
    engine=docker
  else
    echo "ERROR: container $cname not running — sudo make dev-up DEV=$FH_DEV_SLUG first" >&2
    exit 1
  fi

  if [ -z "$dump" ]; then
    dump="$(ls -t "$ROOT"/backups/dev-mirror.sql.gz "$ROOT"/backups/dev-mirror.sql \
      "$ROOT"/backups/backup-*.sql.gz "$ROOT"/backups/backup-*.sql 2>/dev/null | head -1 || true)"
  fi
  if [ -z "$dump" ] && [ -n "${DEV_MIRROR_URL:-}" ]; then
    ./scripts/dev/restore-mirror.sh
    return
  fi
  if [ -z "$dump" ]; then
    echo "ERROR: no mirror dump. On prod: sudo make backup && sudo make dev-mirror" >&2
    exit 2
  fi

  echo "[dev-restore] $dump → $cname"
  $engine exec -i "$cname" psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1 <<'SQL'
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO footballhome_user;
GRANT ALL ON SCHEMA public TO public;
SQL
  if [[ "$dump" == *.gz ]]; then
    gzip -dc "$dump" | $engine exec -i "$cname" psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1
  else
    $engine exec -i "$cname" psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1 < "$dump"
  fi
  echo "[dev-restore] done — open http://127.0.0.1:$FH_DEV_FRONTEND_PORT"
  echo "[dev-restore] (optional) make dev-membership-sync DEV=$FH_DEV_SLUG"
}

restore_into_slot "${BACKUP:-}"
