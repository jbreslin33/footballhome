#!/usr/bin/env bash
# Restore a production DB mirror into the local/cloud Postgres.
#
# Permanent dev needs a real data mirror (not an empty DB). Sources, in order:
#   1. BACKUP=path/to.sql(.gz) env override
#   2. backups/dev-mirror.sql.gz  or  backups/dev-mirror.sql
#   3. newest backups/backup-*.sql*
#   4. DEV_MIRROR_URL  (Cursor Runtime Secret / signed URL) → download once
#
# On the production host, refresh the mirror file with:
#   sudo make backup
#   cp "$(ls -t backups/backup-*.sql | head -1)" backups/dev-mirror.sql
#   gzip -kf backups/dev-mirror.sql   # optional, smaller to copy
# then copy backups/dev-mirror.sql.gz onto the machine that runs compose
# (or host it privately and set DEV_MIRROR_URL).
#
# Never point compose at production Postgres. This restores into the
# *dev* container named footballhome_db / compose service `db`.
set -euo pipefail

cd "$(dirname "$0")/../.."
ROOT="$PWD"
mkdir -p "$ROOT/backups"

log() { echo "[restore-mirror] $*"; }

# Prefer docker compose when Podman isn't available (Cursor Cloud).
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  DB_PSQL=(docker compose --env-file env exec -T db psql -U footballhome_user -d footballhome)
  DB_READY=(docker compose --env-file env exec -T db pg_isready -U footballhome_user -d footballhome)
elif command -v podman >/dev/null 2>&1; then
  DB_PSQL=(podman exec -i footballhome_db psql -U footballhome_user -d footballhome)
  DB_READY=(podman exec footballhome_db pg_isready -U footballhome_user -d footballhome)
else
  log "ERROR: neither docker nor podman available"
  exit 1
fi

for i in $(seq 1 60); do
  if "${DB_READY[@]}" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
if ! "${DB_READY[@]}" >/dev/null 2>&1; then
  log "ERROR: database not ready"
  exit 1
fi

resolve_dump() {
  if [ -n "${BACKUP:-}" ] && [ -f "$BACKUP" ]; then
    echo "$BACKUP"
    return
  fi
  for f in \
    "$ROOT/backups/dev-mirror.sql.gz" \
    "$ROOT/backups/dev-mirror.sql" \
    ; do
    if [ -f "$f" ]; then
      echo "$f"
      return
    fi
  done
  local latest
  latest="$(ls -t "$ROOT"/backups/backup-*.sql.gz "$ROOT"/backups/backup-*.sql 2>/dev/null | head -1 || true)"
  if [ -n "$latest" ]; then
    echo "$latest"
    return
  fi
  if [ -n "${DEV_MIRROR_URL:-}" ]; then
    local dest="$ROOT/backups/dev-mirror.download"
    log "downloading DEV_MIRROR_URL → $dest"
    curl -fsSL "$DEV_MIRROR_URL" -o "$dest"
    # sniff gzip magic
    if gzip -t "$dest" 2>/dev/null; then
      mv "$dest" "$ROOT/backups/dev-mirror.sql.gz"
      echo "$ROOT/backups/dev-mirror.sql.gz"
    else
      mv "$dest" "$ROOT/backups/dev-mirror.sql"
      echo "$ROOT/backups/dev-mirror.sql"
    fi
    return
  fi
  return 1
}

DUMP="$(resolve_dump || true)"
if [ -z "${DUMP:-}" ]; then
  log "No mirror dump found."
  log "  On prod:  sudo make backup && cp \$(ls -t backups/backup-*.sql | head -1) backups/dev-mirror.sql"
  log "  Copy that file here, or set DEV_MIRROR_URL / BACKUP=..."
  exit 2
fi

log "restoring from $DUMP"

# Drop + recreate public schema so restore is idempotent on a non-empty volume.
"${DB_PSQL[@]}" -v ON_ERROR_STOP=1 <<'SQL'
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO footballhome_user;
GRANT ALL ON SCHEMA public TO public;
SQL

if [[ "$DUMP" == *.gz ]]; then
  gzip -dc "$DUMP" | "${DB_PSQL[@]}" -v ON_ERROR_STOP=1
else
  "${DB_PSQL[@]}" -v ON_ERROR_STOP=1 < "$DUMP"
fi

log "mirror restore complete"
log "optional: open Members → Sync now to refresh LeagueApps-derived rows"
