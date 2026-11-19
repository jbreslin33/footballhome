#!/bin/bash
# Off-site database backup to GitHub — encrypted, every day.
#
# Owner 2026-11-19: "we need the db to get backeup up to github right every
# day right?" → "we need backups so we can start on new server if needed if
# this one crashes".  The old push (whole plain .sql into git) died silently
# in October once the dump passed GitHub's 100 MB file limit.
#
#   1. pg_dump -Fc (Postgres's compressed format, whole database)
#   2. age-encrypted to scripts/backup-age-recipient.txt — only the owner's
#      private key (password manager; on this box ~jbreslin/.config/
#      footballhome/backup-age-key.txt) can open it
#   3. split into 45 MB parts (GitHub refuses files over 100 MB, warns over 50)
#   4. repo $OFFSITE keeps daily/<date>/ for the last $DAILY_KEEP days and
#      weekly/<date>/ (Sundays) for the last $WEEKLY_KEEP weeks; each run
#      commits that tree as ONE fresh commit and force-pushes it, so the
#      GitHub repo never piles up history past those copies
#
# Restore: docs/disaster-recovery.md.  Run by backup-db.sh (root) nightly;
# by hand: sudo bash scripts/backup-offsite.sh
# Exit non-zero on any failure, so the unit shows failed in systemctl.
set -euo pipefail

PROJECT_DIR=/srv/footballhome
OFFSITE=/home/jbreslin/footballhome-backups-offsite
REMOTE=https://github.com/jbreslin33/footballhome-backups.git
CONTAINER=footballhome_db
OWNER=jbreslin
DAILY_KEEP=7
WEEKLY_KEEP=4
PART_SIZE=45m
RECIPIENT_FILE="$PROJECT_DIR/scripts/backup-age-recipient.txt"

as_owner() { if [ "$(id -un)" = "$OWNER" ]; then bash -c "$1"; else sudo -u "$OWNER" -H bash -c "$1"; fi; }
pg() { if [ "$(id -u)" = 0 ]; then podman "$@"; else sudo -n podman "$@"; fi; }

STAMP=$(date +%Y%m%d)
[ -s "$RECIPIENT_FILE" ] || { echo "ERROR: no age recipient in $RECIPIENT_FILE" >&2; exit 1; }

# The repo dir: owned by the owner (his git identity + GitHub credential).
if [ ! -d "$OFFSITE/.git" ]; then
    mkdir -p "$OFFSITE"; chown "$OWNER":footballhome "$OFFSITE" 2>/dev/null || true
    as_owner "cd '$OFFSITE' && git init -q -b main && git remote add origin '$REMOTE'"
fi

DAY_DIR="$OFFSITE/daily/$STAMP"
TMP="$OFFSITE/.tmp-$STAMP"
rm -rf "$TMP"; mkdir -p "$TMP"
echo "Dumping (pg_dump -Fc) + encrypting..."
pg exec "$CONTAINER" sh -c 'pg_dump -U "$POSTGRES_USER" -Fc "$POSTGRES_DB"' < /dev/null \
    | age -R "$RECIPIENT_FILE" > "$TMP/footballhome.dump.age"
SIZE=$(stat -c %s "$TMP/footballhome.dump.age")
[ "$SIZE" -gt 10000000 ] || { echo "ERROR: encrypted dump only $SIZE bytes — refusing to rotate" >&2; rm -rf "$TMP"; exit 1; }
( cd "$TMP" && split -b "$PART_SIZE" -d -a 2 footballhome.dump.age footballhome.dump.age.part- \
    && rm footballhome.dump.age && sha256sum footballhome.dump.age.part-* > SHA256SUMS )
cat > "$TMP/README.txt" <<EOF
Football Home database, $(date '+%Y-%m-%d %H:%M %Z'), pg_dump -Fc, age-encrypted, split.
Restore (docs/disaster-recovery.md in the footballhome repo):
  sha256sum -c SHA256SUMS
  cat footballhome.dump.age.part-* | age -d -i backup-age-key.txt > footballhome.dump
  pg_restore -U <user> -d <empty db> --no-owner footballhome.dump
EOF
rm -rf "$DAY_DIR"; mkdir -p "$OFFSITE/daily"; mv "$TMP" "$DAY_DIR"
echo "Encrypted dump: $((SIZE / 1000000)) MB in $(ls "$DAY_DIR"/*.part-* | wc -l) part(s)"

# Sundays: the same files as a weekly copy (git stores identical blobs once).
if [ "$(date +%u)" -eq 7 ]; then
    rm -rf "$OFFSITE/weekly/$STAMP"; mkdir -p "$OFFSITE/weekly"; cp -al "$DAY_DIR" "$OFFSITE/weekly/$STAMP"
fi
# Rotate (directory names sort by date).
ls -1d "$OFFSITE"/daily/*/  2>/dev/null | sort | head -n -"$DAILY_KEEP"  | xargs -r rm -rf || true
ls -1d "$OFFSITE"/weekly/*/ 2>/dev/null | sort | head -n -"$WEEKLY_KEEP" | xargs -r rm -rf || true

cat > "$OFFSITE/README.md" <<'EOF'
# Football Home — encrypted database backups

daily/<YYYYMMDD>/ (last 7) and weekly/<YYYYMMDD>/ (Sundays, last 4).
Each: pg_dump -Fc of the whole database, encrypted with age, split into
45 MB parts. Only the owner's age private key opens them.
This repo is rewritten every night (one commit) — no history is kept.
How to restore / start a new server: docs/disaster-recovery.md in the
footballhome repo.
EOF
[ "$(id -u)" = 0 ] && chown -R "$OWNER":footballhome "$OFFSITE"

# One fresh commit of the current tree, force-pushed; the previous push's
# blobs are still on GitHub, so only today's new parts upload.
as_owner "
  set -e
  cd '$OFFSITE'
  git add -A
  git -c user.name='Football Home backup' -c user.email='backup@footballhome.org' \
      commit-tree \$(git write-tree) -m 'backup $STAMP' > .git/NEW_HEAD
  git update-ref refs/heads/main \$(cat .git/NEW_HEAD)
  git symbolic-ref HEAD refs/heads/main
  git push -q --force origin main
  git reflog expire --expire=now --all
  git gc -q --prune=now
"
echo "Pushed off-site backup $STAMP → $REMOTE"
