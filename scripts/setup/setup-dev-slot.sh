#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# setup-dev-slot.sh — idempotent bootstrap of ONE developer stack
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Creates /srv/footballhome-dev-<slug>, starts db+backend+frontend on that
# slot's ports, restores the prod DB mirror, runs Membership sync, installs
# the host nginx vhost.
#
# Fail-fast + verbose: any step failure exits non-zero immediately so it
# can be diagnosed. Prints "100% SUCCESS" only when every required step
# completed.
#
# Usage:
#   ./scripts/setup/setup-dev-slot.sh jbreslin
#   DEV=lbreslin ./scripts/setup/setup-dev-slot.sh
#   sudo DEV_SLOTS_OBTAIN_CERT=1 LE_EMAIL=you@example.com \
#     ./scripts/setup/setup-dev-slot.sh jbreslin
#
# Optional skips (explicit only):
#   DEV_SLOTS_SKIP_MEMBERSHIP_SYNC=1
#   DEV_SLOTS_SKIP_NGINX=1
#
# Called by: setup-dev-slots.sh / setup-dev-jbreslin.sh / setup.sh `dev-slots`
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

STEP=0
step() {
  STEP=$((STEP + 1))
  echo ""
  print_status "── step ${STEP}: $* ──"
}

fail() {
  print_error "$*"
  print_error "slot $SLUG STOPPED — fix above, then re-run: ./scripts/setup/setup-dev-slot.sh $SLUG"
  exit 1
}

load_dev_slot "$SLUG"
DOMAIN="${FH_DEV_HOST_PREFIX}.dev.footballhome.org"
PROD_ROOT="${PROD_ROOT:-/srv/footballhome}"
export PROD_ROOT
export FH_DEV_DIR

echo ""
print_status "Bootstrapping developer slot: $FH_DEV_SLUG"
echo "     dir=$FH_DEV_DIR"
echo "     frontend=:$FH_DEV_FRONTEND_PORT  backend=:$FH_DEV_BACKEND_PORT  db=:$FH_DEV_DB_PORT"
echo "     url=$FH_DEV_FRONTEND_URL"
echo "     prod=$PROD_ROOT"
echo "     fail-fast=on  verbose=on"

# ── 1. Worktree / clone + env symlink ─────────────────────────────────
step "dev-init (worktree + env symlink)"
DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-init.sh" \
  || fail "dev-init failed"

SLOT_ROOT="$FH_DEV_DIR"
[ -d "$SLOT_ROOT" ] || fail "dev-init did not create $SLOT_ROOT"
print_success "checkout ready: $SLOT_ROOT"

if [ -d "$SLOT_ROOT/.git" ] || [ -f "$SLOT_ROOT/.git" ]; then
  git -C "$SLOT_ROOT" fetch origin main 2>/dev/null || true
fi

# ── 2. Ensure a mirror dump exists on the host ────────────────────────
step "ensure prod DB mirror dump"
MIRROR_GZ="$PROD_ROOT/backups/dev-mirror.sql.gz"
MIRROR_SQL="$PROD_ROOT/backups/dev-mirror.sql"
if [ -f "$MIRROR_GZ" ]; then
  print_status "using existing $MIRROR_GZ ($(du -h "$MIRROR_GZ" | awk '{print $1}'))"
elif [ -f "$MIRROR_SQL" ]; then
  print_status "using existing $MIRROR_SQL ($(du -h "$MIRROR_SQL" | awk '{print $1}'))"
else
  [ -d "$PROD_ROOT" ] && [ -f "$PROD_ROOT/Makefile" ] \
    || fail "no mirror dump and no prod checkout at $PROD_ROOT"
  print_status "no mirror yet — running: make backup && make dev-mirror (in $PROD_ROOT)"
  ( cd "$PROD_ROOT" && make backup && make dev-mirror ) \
    || fail "could not build mirror (is prod DB up?)"
  [ -f "$MIRROR_GZ" ] || [ -f "$MIRROR_SQL" ] \
    || fail "backup/dev-mirror finished but no dump at $MIRROR_GZ"
  print_success "mirror dump created"
fi

# ── 3. Bring stack up (from slot checkout) ────────────────────────────
step "dev-up (containers db+backend+frontend)"
(
  if [ -f "$SLOT_ROOT/docker-compose.dev.yml" ]; then
    cd "$SLOT_ROOT"
    DEV="$FH_DEV_SLUG" ./scripts/dev/dev-up.sh
  else
    print_status "slot missing docker-compose.dev.yml — using $REPO_ROOT"
    cd "$REPO_ROOT"
    FH_DEV_DIR="$SLOT_ROOT" DEV="$FH_DEV_SLUG" ./scripts/dev/dev-up.sh
  fi
) || fail "dev-up failed — check podman/docker logs for footballhome_*_${FH_DEV_SLUG}"
print_success "containers up for $FH_DEV_SLUG"

# ── 4. Restore mirror into this slot's DB ─────────────────────────────
step "dev-restore-mirror"
RESTORE_SCRIPT="$REPO_ROOT/scripts/dev/dev-restore-mirror.sh"
[ -f "$SLOT_ROOT/scripts/dev/dev-restore-mirror.sh" ] && RESTORE_SCRIPT="$SLOT_ROOT/scripts/dev/dev-restore-mirror.sh"
(
  cd "$(dirname "$RESTORE_SCRIPT")/../.."
  DEV="$FH_DEV_SLUG" "$RESTORE_SCRIPT"
) || fail "mirror restore failed"
print_success "DB mirror restored into $FH_DEV_SLUG"

# ── 5. Membership sync (LeagueApps → this slot's DB) ──────────────────
step "membership sync (LeagueApps → Sync now)"
if [ "${DEV_SLOTS_SKIP_MEMBERSHIP_SYNC:-0}" = "1" ]; then
  print_warning "SKIPPED membership sync (DEV_SLOTS_SKIP_MEMBERSHIP_SYNC=1)"
else
  [ -f "$REPO_ROOT/scripts/dev/dev-membership-sync.sh" ] \
    || fail "missing $REPO_ROOT/scripts/dev/dev-membership-sync.sh"
  DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-membership-sync.sh" \
    || fail "membership sync failed — diagnose LA keys / network, then re-run"
  print_success "membership sync 100% for $FH_DEV_SLUG"
fi

# ── 6. Host nginx vhost ───────────────────────────────────────────────
step "nginx vhost ($DOMAIN)"
if [ "${DEV_SLOTS_SKIP_NGINX:-0}" = "1" ]; then
  print_warning "SKIPPED nginx (DEV_SLOTS_SKIP_NGINX=1)"
else
  if [ "$EUID" -eq 0 ]; then
    DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-nginx.sh" \
      || fail "dev-nginx failed"
  else
    sudo DEV="$FH_DEV_SLUG" "$REPO_ROOT/scripts/dev/dev-nginx.sh" \
      || fail "dev-nginx needs sudo — re-run with sudo or: sudo make dev-nginx DEV=$FH_DEV_SLUG"
  fi
  print_success "nginx vhost installed for $DOMAIN"
fi

# ── 7. Optional TLS (only when asked — needs DNS) ─────────────────────
step "TLS certbot (optional)"
if [ "${DEV_SLOTS_OBTAIN_CERT:-0}" = "1" ] || [ "${DEV_SLOTS_OBTAIN_CERT:-}" = "yes" ]; then
  command -v dig >/dev/null 2>&1 || fail "dig not installed — needed to verify DNS before certbot"
  if ! dig +short "$DOMAIN" A | grep -q .; then
    fail "DNS for $DOMAIN not resolving yet — create A record, then re-run with DEV_SLOTS_OBTAIN_CERT=1"
  fi
  print_status "DNS OK for $DOMAIN"
  EMAIL="${LE_EMAIL:-}"
  if [ -z "$EMAIL" ] && [ -f "$REPO_ROOT/env" ]; then
    # shellcheck disable=SC1091
    EMAIL="$(set -a; source "$REPO_ROOT/env"; set +a; echo "${LE_EMAIL:-}")"
  fi
  [ -n "$EMAIL" ] || fail "LE_EMAIL unset — export LE_EMAIL=you@example.com for certbot"
  print_status "certbot --nginx -d $DOMAIN -m $EMAIL"
  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect \
    || fail "certbot failed for $DOMAIN — check DNS / rate limits"
  print_success "TLS cert issued for $DOMAIN"
else
  print_status "TLS skipped (set DEV_SLOTS_OBTAIN_CERT=1 after DNS is live)"
fi

echo ""
print_success "100% SUCCESS — developer slot ready: $FH_DEV_SLUG"
echo "     http://127.0.0.1:${FH_DEV_FRONTEND_PORT}"
echo "     https://${DOMAIN}   (after DNS + cert)"
echo "     Checkout: $SLOT_ROOT"
echo "     Re-run:   ./scripts/setup/setup-dev-slot.sh $FH_DEV_SLUG"
