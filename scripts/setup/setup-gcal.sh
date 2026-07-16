#!/bin/bash
# scripts/setup/setup-gcal.sh — install the gcal-sync systemd timer
#
# Installs (or reinstalls) systemd/gcal-sync.service +
# systemd/gcal-sync.timer into /etc/systemd/system/ and enables the
# timer. Idempotent — safe to re-run after editing the unit files.
#
# Prereqs (setup.sh handles these earlier in the run):
#   * setup-node.sh    — node + npm deps (googleapis, pg, dotenv)
#   * setup-age.sh     — env decrypted from env.age
#   * setup-podman.sh  — footballhome_db running on port 5432
#   * migrations 119 + 120 applied via `make migrate`
#
# After this step, verify with:
#   sudo systemctl status gcal-sync.timer
#   sudo systemctl list-timers | grep gcal
#   sudo journalctl -u gcal-sync.service --since '10 min ago'
#
# Linux-only — this step is a no-op on macOS.

set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

if [ "$OS_TYPE" != "Linux" ]; then
  print_status "setup-gcal: skipping on $OS_TYPE (systemd not available)"
  exit 0
fi

if ! command -v systemctl &> /dev/null; then
  print_warning "setup-gcal: systemctl not found — skipping timer install"
  exit 0
fi

SRC="$REPO_ROOT/systemd"
if [ ! -f "$SRC/gcal-sync.service" ] || [ ! -f "$SRC/gcal-sync.timer" ]; then
  print_error "setup-gcal: unit files missing in $SRC"
  exit 1
fi

# Basic sanity: env must have GCAL_SA_JSON populated (setup-age.sh
# should have decrypted it). If not, install units anyway so the user
# can fix env and `systemctl restart gcal-sync.timer` — but warn.
if [ -f "$REPO_ROOT/env" ] && ! grep -q '^GCAL_SA_JSON=' "$REPO_ROOT/env"; then
  print_warning "setup-gcal: GCAL_SA_JSON not found in env — timer will fail until you populate it"
fi

print_status "Installing gcal-sync.service + gcal-sync.timer..."
sudo install -m 0644 "$SRC/gcal-sync.service" /etc/systemd/system/gcal-sync.service
sudo install -m 0644 "$SRC/gcal-sync.timer"   /etc/systemd/system/gcal-sync.timer

print_status "Reloading systemd..."
sudo systemctl daemon-reload

print_status "Enabling + starting gcal-sync.timer..."
sudo systemctl enable --now gcal-sync.timer

# Kick off one sync right now so the user sees output; failures show
# up in `journalctl -u gcal-sync.service`.
print_status "Firing one-shot sync now (async)..."
sudo systemctl start --no-block gcal-sync.service

print_success "gcal-sync installed."
print_status  "Verify:  sudo systemctl list-timers | grep gcal"
print_status  "Logs:    sudo journalctl -u gcal-sync.service --since '10 min ago'"
