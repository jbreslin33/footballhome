#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Scrape All (Standings + Rosters + Schedule)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches everything needed for CASA:
#   1. Standings (SportsEngine iframes, 5 divisions)
#   2. Schedule (SportsEngine REST API, 5 divisions)
#   3. Rosters (Google Sheets XLSX downloads)
#
# Usage:
#   ./scrape.sh
#
# For targeted scraping, use:
#   ./scrape-standings.sh    # Just standings
#   ./scrape-schedule.sh     # Just schedule/results
#   ./scrape-rosters.sh      # Just rosters from Google Sheets
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🌐 CASA: Scraping all data..."
echo ""

# 1+2. Standings + Schedule (same scraper, target=all)
echo "🌐 Scraping CASA standings + schedule..."
export SCRAPE_MODE=download
export SCRAPE_USE_CACHE=false
node database/scripts/scrapers/CasaStructureScraper.js
echo ""

# 3. Rosters
"$SCRIPT_DIR/scrape-rosters.sh"

echo "✓ CASA scrape complete"
