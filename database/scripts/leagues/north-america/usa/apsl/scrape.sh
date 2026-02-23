#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Scrape HTML from Web
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches fresh HTML from APSL website and saves to database/scraped-html/apsl/
#
# Usage:
#   ./scrape.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Get to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

echo "🌐 Scraping APSL HTML from web..."
export SCRAPE_MODE=download
export SCRAPE_USE_CACHE=false
node database/scripts/scrapers/ApslStructureScraper.js

echo "✓ APSL HTML saved to database/scraped-html/apsl/"
