#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# setup-dev-slots.sh — bootstrap EVERY row in config/dev-slots.conf
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Idempotent. Re-run after a server migrate to recreate jbreslin +
# lbreslin (and any future slugs) stacks.
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

# Optional filter: DEV_SLOTS=jbreslin,lbreslin
FILTER="${DEV_SLOTS:-}"

print_status "Setting up developer slots from config/dev-slots.conf"

mapfile -t LINES < <(awk '!/^#/ && NF { print $1 }' "$SLOTS_FILE")
if [ "${#LINES[@]}" -eq 0 ]; then
  print_warning "no slots defined in $SLOTS_FILE"
  exit 0
fi

FAILED=0
for slug in "${LINES[@]}"; do
  if [ -n "$FILTER" ]; then
    case ",$FILTER," in
      *",$slug,"*) ;;
      *) print_status "skip $slug (not in DEV_SLOTS=$FILTER)"; continue ;;
    esac
  fi
  echo ""
  print_status "══ slot: $slug ══"
  if ! DEV_SLOTS_OBTAIN_CERT="${DEV_SLOTS_OBTAIN_CERT:-0}" \
       LE_EMAIL="${LE_EMAIL:-}" \
       PROD_ROOT="${PROD_ROOT:-/srv/footballhome}" \
       "$SCRIPT_DIR/setup-dev-slot.sh" "$slug"; then
    print_error "slot $slug failed"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
if [ "$FAILED" -gt 0 ]; then
  print_error "$FAILED slot(s) failed"
  exit 1
fi
print_success "All requested developer slots are up"
echo "     Re-run anytime:  ./scripts/setup/setup-dev-slots.sh"
echo "     Or one person:   ./scripts/setup/setup-dev-jbreslin.sh"
echo "     After DNS:       sudo DEV_SLOTS_OBTAIN_CERT=1 LE_EMAIL=you@x.com ./scripts/setup/setup-dev-slots.sh"
