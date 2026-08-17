#!/bin/bash
# scripts/setup/setup-gcal.sh — install the gcal-sync systemd timer
#
# Installs (or reinstalls) systemd/gcal-sync.{service,timer} into
# /etc/systemd/system/ and enables it. Idempotent — safe to re-run
# after editing the unit files.
#
# gcal-rsvp-apply-standing (the standing/recurring RSVP auto-applier)
# was removed 2026-08-16 along with the rest of the standing-RSVP
# feature — it silently auto-marked people "going" on stale
# preferences with no way to see or change them from the UI. This
# script now also cleans up that timer/service if a prior run of this
# script installed them on this box.
#
# Prereqs (setup.sh handles these earlier in the run):
#   * setup-node.sh    — node + npm deps (googleapis, pg, dotenv)
#   * setup-age.sh     — env decrypted from env.age
#   * setup-podman.sh  — footballhome_db running on port 5432
#   * migrations 119 + 120 + 121 applied via `make migrate`
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
  print_error "setup-gcal: gcal-sync unit files missing in $SRC"
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

# Retired unit cleanup — remove if a prior run installed it.
if [ -f /etc/systemd/system/gcal-rsvp-apply-standing.timer ]; then
  print_status "Removing retired gcal-rsvp-apply-standing.timer + service..."
  sudo systemctl disable --now gcal-rsvp-apply-standing.timer 2>/dev/null || true
  sudo rm -f /etc/systemd/system/gcal-rsvp-apply-standing.service \
             /etc/systemd/system/gcal-rsvp-apply-standing.timer
fi

print_status "Reloading systemd..."
sudo systemctl daemon-reload

print_status "Enabling + starting gcal-sync.timer..."
sudo systemctl enable --now gcal-sync.timer

# Kick off one sync right now so the user sees output; failures show
# up in the journalctl stream.
print_status "Firing one-shot sync now (async)..."
sudo systemctl start --no-block gcal-sync.service

print_success "gcal-sync installed."
print_status  "Verify:  sudo systemctl list-timers | grep gcal"
print_status  "Logs:    sudo journalctl -u gcal-sync.service --since '10 min ago'"
