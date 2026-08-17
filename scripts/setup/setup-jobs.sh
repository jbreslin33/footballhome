#!/bin/bash
# scripts/setup/setup-jobs.sh — install scheduled-maintenance systemd timers
#
# Installs (or reinstalls) systemd/backup-db.{service,timer} +
# systemd/refresh-instagram-token.{service,timer} into
# /etc/systemd/system/ and enables both timers. Idempotent — safe to
# re-run after editing any unit file.
#
# These replaced two plain `crontab -e` entries (2026-08-16) that had
# no matching setup step, so they were silently lost on every rebuild.
# One of them — backup-db — had also been silently FAILING for ~25
# days in place: it ran as the jbreslin user, but /srv/footballhome/
# backups is root:footballhome with no group-write bit, and the
# script's plain `podman exec` doesn't reach the rootful podman socket
# without sudo. Root couldn't write a log saying so because it never
# got that far. Fixed by running backup-db as root (see
# systemd/backup-db.service) instead of patching around both gaps.
#
#   * backup-db              — daily 3am DB dump + rotation + git push
#   * refresh-instagram-token — 1st/20th 3:30am IG long-lived token refresh
#
# backup-db also pushes each dump to the jbreslin33/footballhome-backups
# GitHub repo, cloned to /srv/footballhome-backups. That clone doesn't
# exist on a fresh box either, so this script clones it too (skipped
# quietly if jbreslin's stored git credential — ~/.git-credentials via
# `git config credential.helper store` — isn't set up yet; re-run this
# step once it is).
#
# Prereqs (setup.sh handles these earlier in the run):
#   * setup-podman.sh — footballhome_db running
#   * setup-age.sh    — env decrypted (refresh-instagram-token needs it)
#
# After this step, verify with:
#   sudo systemctl status backup-db.timer refresh-instagram-token.timer
#   sudo systemctl list-timers | grep -E 'backup-db|refresh-instagram'
#   sudo journalctl -u backup-db.service --since '1 day ago'
#
# Linux-only — this step is a no-op on macOS.

set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

if [ "$OS_TYPE" != "Linux" ]; then
  print_status "setup-jobs: skipping on $OS_TYPE (systemd not available)"
  exit 0
fi

if ! command -v systemctl &> /dev/null; then
  print_warning "setup-jobs: systemctl not found — skipping timer install"
  exit 0
fi

SRC="$REPO_ROOT/systemd"
for f in backup-db.service backup-db.timer \
         refresh-instagram-token.service refresh-instagram-token.timer; do
  if [ ! -f "$SRC/$f" ]; then
    print_error "setup-jobs: $f missing in $SRC"
    exit 1
  fi
done

BACKUP_REPO="/srv/footballhome-backups"
if [ -d "$BACKUP_REPO/.git" ]; then
  print_status "setup-jobs: $BACKUP_REPO already cloned, skipping"
elif sudo -u jbreslin -H git ls-remote https://github.com/jbreslin33/footballhome-backups.git &> /dev/null; then
  print_status "Cloning footballhome-backups to $BACKUP_REPO..."
  sudo -u jbreslin -H git clone https://github.com/jbreslin33/footballhome-backups.git "$BACKUP_REPO"
else
  print_warning "setup-jobs: can't reach jbreslin33/footballhome-backups (jbreslin's stored"
  print_warning "  git credential not set up yet?) — backup-db.sh will just skip the git"
  print_warning "  push step until $BACKUP_REPO exists. Re-run this step once creds are ready."
fi

print_status "Installing backup-db.service + backup-db.timer..."
sudo install -m 0644 "$SRC/backup-db.service" /etc/systemd/system/backup-db.service
sudo install -m 0644 "$SRC/backup-db.timer"   /etc/systemd/system/backup-db.timer

print_status "Installing refresh-instagram-token.service + timer..."
sudo install -m 0644 "$SRC/refresh-instagram-token.service" \
     /etc/systemd/system/refresh-instagram-token.service
sudo install -m 0644 "$SRC/refresh-instagram-token.timer" \
     /etc/systemd/system/refresh-instagram-token.timer

print_status "Reloading systemd..."
sudo systemctl daemon-reload

print_status "Enabling + starting backup-db.timer..."
sudo systemctl enable --now backup-db.timer
print_status "Enabling + starting refresh-instagram-token.timer..."
sudo systemctl enable --now refresh-instagram-token.timer

print_success "backup-db + refresh-instagram-token timers installed."
print_status  "Verify: sudo systemctl list-timers | grep -E 'backup-db|refresh-instagram'"
print_status  "Logs:   sudo journalctl -u backup-db.service --since '1 day ago'"
print_status  ""
print_warning "If you had the old crontab lines for these two jobs, remove them"
print_warning "now (crontab -e) so backups don't run twice a day:"
print_warning "  0 3 * * * .../backup-db.sh ..."
print_warning "  30 3 1,20 * * ... refresh-instagram-token.sh"
