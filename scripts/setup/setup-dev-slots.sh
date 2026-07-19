#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# setup-dev-slots.sh — bootstrap EVERY row in config/dev-slots.conf
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Idempotent. Re-run after a server migrate to recreate jbreslin +
# lbreslin (and any future slugs) stacks.
#
# Fail-fast: stops on the first slot failure so it can be diagnosed.
# Prints "100% SUCCESS" only when every requested slot completed.
#
# Usage:
#   ./scripts/setup/setup-dev-slots.sh
#   DEV_SLOTS=jbreslin ./scripts/setup/setup-dev-slots.sh   # subset
#   sudo DEV_SLOTS_OBTAIN_CERT=1 LE_EMAIL=you@x.com ./scripts/setup/setup-dev-slots.sh
#
# Wired into ./setup.sh as the `dev-slots` step (Linux only).
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lib.sh
source "$SCRIPT_DIR/_lib.sh"
REPO_ROOT="$(setup_repo_root)"
cd "$REPO_ROOT"

SLOTS_FILE="$REPO_ROOT/config/dev-slots.conf"
if [ ! -f "$SLOTS_FILE" ]; then
  print_error "missing $SLOTS_FILE"
  exit 1
fi

if [ "$OS_TYPE" != "Linux" ]; then
  print_warning "dev-slots setup is Linux/server-only — skipping"
  exit 0
fi

FILTER="${DEV_SLOTS:-}"

print_status "Setting up developer slots from config/dev-slots.conf"
print_status "fail-fast=on — first error stops the run"

mapfile -t LINES < <(awk '!/^#/ && NF { print $1 }' "$SLOTS_FILE")
if [ "${#LINES[@]}" -eq 0 ]; then
  print_error "no slots defined in $SLOTS_FILE"
  exit 1
fi

REQUESTED=()
for slug in "${LINES[@]}"; do
  if [ -n "$FILTER" ]; then
    case ",$FILTER," in
      *",$slug,"*) ;;
      *) print_status "skip $slug (not in DEV_SLOTS=$FILTER)"; continue ;;
    esac
  fi
  REQUESTED+=("$slug")
done

if [ "${#REQUESTED[@]}" -eq 0 ]; then
  print_error "no slots selected (DEV_SLOTS=$FILTER)"
  exit 1
fi

echo "     will set up: ${REQUESTED[*]}"

COMPLETED=()
for slug in "${REQUESTED[@]}"; do
  echo ""
  print_status "════════════════════════════════════════"
  print_status "slot: $slug  (${#COMPLETED[@]}/${#REQUESTED[@]} done so far)"
  print_status "════════════════════════════════════════"
  if ! DEV_SLOTS_OBTAIN_CERT="${DEV_SLOTS_OBTAIN_CERT:-0}" \
       DEV_SLOTS_SKIP_MEMBERSHIP_SYNC="${DEV_SLOTS_SKIP_MEMBERSHIP_SYNC:-0}" \
       DEV_SLOTS_SKIP_NGINX="${DEV_SLOTS_SKIP_NGINX:-0}" \
       LE_EMAIL="${LE_EMAIL:-}" \
       PROD_ROOT="${PROD_ROOT:-/srv/footballhome}" \
       "$SCRIPT_DIR/setup-dev-slot.sh" "$slug"; then
    echo ""
    print_error "STOPPED — slot '$slug' failed"
    print_error "completed before failure: ${COMPLETED[*]:-(none)}"
    print_error "remaining: $(printf '%s ' "${REQUESTED[@]:${#COMPLETED[@]}}")"
    print_error "fix the error above, then re-run:"
    echo "     ./scripts/setup/setup-dev-slots.sh"
    echo "     # or just the failed slot:"
    echo "     ./scripts/setup/setup-dev-slot.sh $slug"
    exit 1
  fi
  COMPLETED+=("$slug")
  print_success "slot $slug complete (${#COMPLETED[@]}/${#REQUESTED[@]})"
done

echo ""
print_success "100% SUCCESS — all ${#COMPLETED[@]}/${#REQUESTED[@]} developer slots ready"
for slug in "${COMPLETED[@]}"; do
  echo "     ✓ $slug"
done
echo ""
echo "     Re-run anytime:  ./scripts/setup/setup-dev-slots.sh"
echo "     Or one person:   ./scripts/setup/setup-dev-jbreslin.sh"
echo "     After DNS:       sudo DEV_SLOTS_OBTAIN_CERT=1 LE_EMAIL=you@x.com ./scripts/setup/setup-dev-slots.sh"
