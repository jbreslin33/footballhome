#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Scrape All (Standings + Team Pages)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches everything needed for CSL:
#   1. Standings page (1 Chrome request)
#   2. Team detail pages (rosters + schedule, ~30 requests with cache)
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

echo "🌐 CSL: Scraping all data..."
echo ""

# 1. Standings
"$SCRIPT_DIR/scrape-standings.sh"
echo ""

# 2. Team pages (rosters + schedule)
"$SCRIPT_DIR/scrape-teams.sh"

echo "✓ CSL scrape complete"
