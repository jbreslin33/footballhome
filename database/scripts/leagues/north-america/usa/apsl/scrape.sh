#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Scrape All (Standings + Team Pages)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches everything needed for APSL:
#   1. Standings page (1 Chrome request)
#   2. Team detail pages (rosters + schedule, ~40 requests with cache)
#
# Usage:
#   ./scrape.sh                  # Skip if cache < 7 days old
#   FORCE_SCRAPE=1 ./scrape.sh   # Force re-fetch everything
#
# For targeted scraping, use:
#   ./scrape-standings.sh        # Just the standings page
#   ./scrape-teams.sh            # Just team pages (rosters + schedule)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

# ── VPN (connect once for all sub-scripts) ────────────────────────────
if [ "${VPN_ACTIVE:-0}" != "1" ] && [ "${NO_VPN:-0}" != "1" ]; then
  exec "$PROJECT_ROOT/scripts/vpn-wrap.sh" env VPN_ACTIVE=1 "$0" "$@"
fi

echo "🌐 APSL: Scraping all data..."
echo ""

# 1. Standings (VPN_ACTIVE passed through — no reconnect)
VPN_ACTIVE=1 "$SCRIPT_DIR/scrape-standings.sh"
echo ""

# 2. Team pages (rosters + schedule)
VPN_ACTIVE=1 "$SCRIPT_DIR/scrape-teams.sh"

echo "✓ APSL scrape complete"
