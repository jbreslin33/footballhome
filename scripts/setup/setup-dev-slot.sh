#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# setup-dev-slot.sh — idempotent bootstrap of ONE developer stack
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Creates /srv/footballhome-dev-<slug>, starts db+backend+frontend on that
# slot's ports, restores the prod DB mirror, installs the host nginx
# vhost. Safe to re-run (server migrate / rebuild).
#
# Usage:
#   ./scripts/setup/setup-dev-slot.sh jbreslin
#   DEV=lbreslin ./scripts/setup/setup-dev-slot.sh
#   sudo DEV_SLOTS_OBTAIN_CERT=1 LE_EMAIL=you@example.com \
#     ./scripts/setup/setup-dev-slot.sh jbreslin
#
# Called by: setup-dev-slots.sh (all rows in config/dev-slots.conf)
#            setup-dev-jbreslin.sh / setup-dev-lbreslin.sh wrappers
#            setup.sh step `dev-slots` (Linux)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lib.sh
source "$SCRIPT_DIR/_lib.sh"
REPO_ROOT="$(setup_repo_root)"
cd "$REPO_ROOT"

# shellcheck source=../dev/lib-dev-slot.sh
source "$REPO_ROOT/scripts/dev/lib-dev-slot.sh"

SLUG="${DEV:-${1:-}}"
if [ -z "$SLUG" ]; then
  print_error "Usage: $0 <slug>   (e.g. jbreslin)"
  exit 2
fi

if [ "$OS_TYPE" != "Linux" ]; then
  print_warning "dev slots are for the Linux server host — skipping ($SLUG)"
  exit 0
fi

load_dev_slot "$SLUG"
print_status "Bootstrapping developer slot: $FH_DEV_SLUG"
print_status "  dir=$FH_DEV_DIR  fe=:$FH_DEV_FRONTEND_PORT  be=:$FH_DEV_BACKEND_PORT"
print_status "  url=$FH_DEV_FRONTEND_URL"

# ── 1. Worktree / clone + env symlink ─────────────────────────────────
PROD_ROOT="${PROD_ROOT:-/srv/footballhome}"
export PROD_ROOT
export FH_DEV_DIR
DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-init.sh"

# Prefer running compose from the slot checkout so bind-mounts match the
# branch that developer is working on.
SLOT_ROOT="$FH_DEV_DIR"
if [ ! -d "$SLOT_ROOT" ]; then
  print_error "dev-init did not create $SLOT_ROOT"
  exit 1
fi

# Ensure slot has latest scripts from the checkout we're setting up from
# (worktree already shares git; clone path may lag — pull).
if [ -d "$SLOT_ROOT/.git" ] || [ -f "$SLOT_ROOT/.git" ]; then
  git -C "$SLOT_ROOT" fetch origin main 2>/dev/null || true
fi

# ── 2. Ensure a mirror dump exists on the host ────────────────────────
MIRROR_GZ="$PROD_ROOT/backups/dev-mirror.sql.gz"
MIRROR_SQL="$PROD_ROOT/backups/dev-mirror.sql"
if [ ! -f "$MIRROR_GZ" ] && [ ! -f "$MIRROR_SQL" ]; then
  if [ -d "$PROD_ROOT" ] && [ -f "$PROD_ROOT/Makefile" ]; then
    print_status "No mirror dump yet — taking prod backup + dev-mirror"
    ( cd "$PROD_ROOT" && make backup && make dev-mirror ) || \
      print_warning "Could not build mirror (prod DB down?). Slot will start empty."
  else
    print_warning "No $MIRROR_GZ and no prod checkout at $PROD_ROOT"
  fi
fi

# ── 3. Bring stack up (from slot checkout) ────────────────────────────
print_status "Starting containers for $FH_DEV_SLUG"
(
  cd "$SLOT_ROOT"
  # Slot may be on older commit during first migrate — always prefer the
  # orchestrating repo's compose/scripts if slot lacks them.
  if [ ! -f "$SLOT_ROOT/docker-compose.dev.yml" ]; then
    print_warning "slot missing docker-compose.dev.yml — using $REPO_ROOT"
    cd "$REPO_ROOT"
    FH_DEV_DIR="$SLOT_ROOT" DEV="$FH_DEV_SLUG" ./scripts/dev/dev-up.sh
  else
    DEV="$FH_DEV_SLUG" ./scripts/dev/dev-up.sh
  fi
)

# ── 4. Restore mirror into this slot's DB ─────────────────────────────
print_status "Restoring DB mirror into $FH_DEV_SLUG"
(
  cd "$SLOT_ROOT"
  if [ -f ./scripts/dev/dev-restore-mirror.sh ]; then
    DEV="$FH_DEV_SLUG" ./scripts/dev/dev-restore-mirror.sh || \
      print_warning "mirror restore failed for $FH_DEV_SLUG (stack is still up)"
  else
    cd "$REPO_ROOT"
    DEV="$FH_DEV_SLUG" ./scripts/dev/dev-restore-mirror.sh || \
      print_warning "mirror restore failed for $FH_DEV_SLUG"
  fi
)

# ── 5. Membership sync (LeagueApps → this slot's DB) ──────────────────
# Same as Club Admin → Members → "Sync now". Needs healthy backend + LA keys
# from the shared env symlink. Skip with DEV_SLOTS_SKIP_MEMBERSHIP_SYNC=1.
if [ "${DEV_SLOTS_SKIP_MEMBERSHIP_SYNC:-0}" = "1" ]; then
  print_warning "skipping membership sync (DEV_SLOTS_SKIP_MEMBERSHIP_SYNC=1)"
else
  print_status "Running LeagueApps membership sync for $FH_DEV_SLUG"
  if [ -f "$REPO_ROOT/scripts/dev/dev-membership-sync.sh" ]; then
    DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-membership-sync.sh" || \
      print_warning "membership sync failed for $FH_DEV_SLUG — use Members → Sync now in the UI"
  else
    print_warning "dev-membership-sync.sh missing — skip"
  fi
fi

# ── 6. Host nginx vhost ───────────────────────────────────────────────
print_status "Installing nginx vhost for ${FH_DEV_HOST_PREFIX}.dev.footballhome.org"
if [ "$EUID" -eq 0 ]; then
  DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-nginx.sh"
else
  sudo DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-nginx.sh" || \
    print_warning "nginx install needs sudo — run: sudo make dev-nginx DEV=$FH_DEV_SLUG"
fi

# ── 7. Optional TLS (only when asked — needs DNS) ─────────────────────
DOMAIN="${FH_DEV_HOST_PREFIX}.dev.footballhome.org"
if [ "${DEV_SLOTS_OBTAIN_CERT:-0}" = "1" ] || [ "${DEV_SLOTS_OBTAIN_CERT:-}" = "yes" ]; then
  if command -v dig >/dev/null 2>&1; then
    if ! dig +short "$DOMAIN" A | grep -q .; then
      print_warning "DNS for $DOMAIN not resolving yet — skip certbot (re-run later)"
    else
      print_status "Obtaining TLS cert for $DOMAIN"
      EMAIL="${LE_EMAIL:-}"
      if [ -z "$EMAIL" ] && [ -f "$REPO_ROOT/env" ]; then
        # shellcheck disable=SC1091
        EMAIL="$(set -a; source "$REPO_ROOT/env"; set +a; echo "${LE_EMAIL:-}")"
      fi
      if [ -n "$EMAIL" ]; then
        sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect \
          || print_warning "certbot failed for $DOMAIN — check DNS / rate limits"
      else
        print_warning "LE_EMAIL unset — skip certbot for $DOMAIN"
      fi
    fi
  else
    print_warning "dig not installed — skip cert DNS check; run certbot manually"
  fi
else
  print_status "TLS skipped (set DEV_SLOTS_OBTAIN_CERT=1 after DNS is live)"
fi

print_success "Developer slot ready: $FH_DEV_SLUG"
echo "     http://127.0.0.1:${FH_DEV_FRONTEND_PORT}"
echo "     https://${DOMAIN}   (after DNS + cert)"
echo "     Checkout: $SLOT_ROOT"
