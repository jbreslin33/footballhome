#!/bin/bash
# scripts/setup/setup-gcal.sh — install the gcal-sync + apply-standing systemd timers
#
# Installs (or reinstalls) systemd/gcal-sync.{service,timer} +
# systemd/gcal-rsvp-apply-standing.{service,timer} into
# /etc/systemd/system/ and enables both timers. Idempotent — safe to
# re-run after editing any unit file.
#
# The two timers run independently:
#   * gcal-sync              — every 5 min from OnBootSec=30s
#   * gcal-rsvp-apply-standing — every 5 min from OnBootSec=60s
# They touch different tables (gcal_events / fh_events / classifier
# vs. fh_event_rsvps / standing_applied_at stamp) so parallel runs
# are safe.
#
# Prereqs (setup.sh handles these earlier in the run):
#   * setup-node.sh    — node + npm deps (googleapis, pg, dotenv)
#   * setup-age.sh     — env decrypted from env.age
#   * setup-podman.sh  — footballhome_db running on port 5432
#   * migrations 119 + 120 + 121 applied via `make migrate`
#
# After this step, verify with:
#   sudo systemctl status gcal-sync.timer gcal-rsvp-apply-standing.timer
#   sudo systemctl list-timers | grep gcal
#   sudo journalctl -u gcal-sync.service --since '10 min ago'
#   sudo journalctl -u gcal-rsvp-apply-standing.service --since '10 min ago'
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
if [ ! -f "$SRC/gcal-rsvp-apply-standing.service" ] || \
   [ ! -f "$SRC/gcal-rsvp-apply-standing.timer" ]; then
  print_error "setup-gcal: gcal-rsvp-apply-standing unit files missing in $SRC"
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

print_status "Installing gcal-rsvp-apply-standing.service + timer..."
sudo install -m 0644 "$SRC/gcal-rsvp-apply-standing.service" \
     /etc/systemd/system/gcal-rsvp-apply-standing.service
sudo install -m 0644 "$SRC/gcal-rsvp-apply-standing.timer" \
     /etc/systemd/system/gcal-rsvp-apply-standing.timer

print_status "Reloading systemd..."
sudo systemctl daemon-reload

print_status "Enabling + starting gcal-sync.timer..."
sudo systemctl enable --now gcal-sync.timer
print_status "Enabling + starting gcal-rsvp-apply-standing.timer..."
sudo systemctl enable --now gcal-rsvp-apply-standing.timer

# Kick off one sync + one apply-standing right now so the user sees
# output; failures show up in the respective journalctl streams.
print_status "Firing one-shot sync now (async)..."
sudo systemctl start --no-block gcal-sync.service
print_status "Firing one-shot apply-standing now (async)..."
sudo systemctl start --no-block gcal-rsvp-apply-standing.service

print_success "gcal-sync + gcal-rsvp-apply-standing installed."
print_status  "Verify:  sudo systemctl list-timers | grep gcal"
print_status  "Logs:    sudo journalctl -u gcal-sync.service --since '10 min ago'"
print_status  "         sudo journalctl -u gcal-rsvp-apply-standing.service --since '10 min ago'"
