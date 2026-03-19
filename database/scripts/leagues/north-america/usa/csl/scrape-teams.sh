#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Scrape Team Pages (Rosters + Schedule) (VPN required)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches team detail pages from cosmosoccerleague.com.
# Automatically connects VPN (cosmosoccerleague.com blocks our IP).
# Each team page contains both the roster and schedule.
#
# Usage:
#   ./scrape-teams.sh                  # Uses VPN, skip if cache < 7 days
#   FORCE_SCRAPE=1 ./scrape-teams.sh   # Force re-fetch all team pages
#   NO_VPN=1 ./scrape-teams.sh         # Skip VPN (testing only)
#   VPN_ACTIVE=1 ./scrape-teams.sh     # Called from parent (VPN already up)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

# ── VPN (auto-connect unless parent already handled it) ───────────────
if [ "${VPN_ACTIVE:-0}" != "1" ] && [ "${NO_VPN:-0}" != "1" ]; then
  exec "$PROJECT_ROOT/scripts/vpn-wrap.sh" env VPN_ACTIVE=1 "$SCRIPT_DIR/$(basename "$0")" "$@"
fi

FORCE_FLAG=""
if [ "${FORCE_SCRAPE:-0}" = "1" ]; then
  FORCE_FLAG="--force"
fi

node database/scripts/scrapers/scrape-team-pages.js --league csl $FORCE_FLAG
node "$PROJECT_ROOT/database/scripts/update-scrape-status.js" csl-teams success
