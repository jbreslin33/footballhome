#!/bin/bash
# Daily database backup with rotation
# Keeps last 7 daily backups + last 4 weekly backups
#
# Install: scripts/setup/setup-jobs.sh (systemd backup-db.timer, runs as
# root — see that unit file for why: this box's rootful podman + the
# root:footballhome backups/ dir ownership both need root, not jbreslin).
#
# Manual run: sudo ./scripts/backup-db.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
CONTAINER="footballhome_db"
DB_USER="footballhome_user"
DB_NAME="footballhome"
DAILY_KEEP=7
WEEKLY_KEEP=4

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DAY_OF_WEEK=$(date +%u)  # 1=Monday, 7=Sunday
BACKUP_FILE="$BACKUP_DIR/backup-${TIMESTAMP}.sql"

# Run pg_dump
echo "Backing up $DB_NAME..."
podman exec "$CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

if [ ! -s "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file is empty, aborting"
    rm -f "$BACKUP_FILE"
    exit 1
fi

SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Backup saved: $BACKUP_FILE ($SIZE)"

# On Sundays, copy as weekly backup
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    WEEKLY_FILE="$BACKUP_DIR/weekly-${TIMESTAMP}.sql"
    cp "$BACKUP_FILE" "$WEEKLY_FILE"
    echo "Weekly backup: $WEEKLY_FILE"
fi

# Rotate: keep last N daily backups
DAILY_COUNT=$(find "$BACKUP_DIR" -name 'backup-*.sql' | wc -l)
if [ "$DAILY_COUNT" -gt "$DAILY_KEEP" ]; then
    REMOVE_COUNT=$((DAILY_COUNT - DAILY_KEEP))
    ls -1t "$BACKUP_DIR"/backup-*.sql | tail -n "$REMOVE_COUNT" | xargs rm -f
    echo "Rotated $REMOVE_COUNT old daily backup(s)"
fi

# Rotate: keep last N weekly backups
WEEKLY_COUNT=$(find "$BACKUP_DIR" -name 'weekly-*.sql' | wc -l)
if [ "$WEEKLY_COUNT" -gt "$WEEKLY_KEEP" ]; then
    REMOVE_COUNT=$((WEEKLY_COUNT - WEEKLY_KEEP))
    ls -1t "$BACKUP_DIR"/weekly-*.sql | tail -n "$REMOVE_COUNT" | xargs rm -f
    echo "Rotated $REMOVE_COUNT old weekly backup(s)"
fi

echo "Done. Daily: $DAILY_COUNT/$DAILY_KEEP, Weekly: $WEEKLY_COUNT/$WEEKLY_KEEP"

# Push to backup git repo
BACKUP_REPO="/srv/footballhome-backups"
if [ -d "$BACKUP_REPO/.git" ]; then
    cp "$BACKUP_FILE" "$BACKUP_REPO/"
    # Also sync weekly if created
    if [ "$DAY_OF_WEEK" -eq 7 ]; then
        cp "$WEEKLY_FILE" "$BACKUP_REPO/"
    fi
    chown jbreslin:footballhome "$BACKUP_REPO"/*.sql 2>/dev/null || true
    # git commit/push need jbreslin's identity + stored GitHub credential
    # (~/.git-credentials) — this script itself now runs as root (see
    # backup-db.service), so hand the git steps off via sudo -u rather
    # than duplicating jbreslin's credentials into root's home dir.
    sudo -u jbreslin -H bash -c "
        cd '$BACKUP_REPO' &&
        git add -A &&
        git commit -m 'backup $(date +%Y-%m-%d)' --allow-empty &&
        git push origin main
    "
    echo "Pushed to git backup repo"
else
    echo "WARNING: Backup repo not found at $BACKUP_REPO, skipping git push"
fi
