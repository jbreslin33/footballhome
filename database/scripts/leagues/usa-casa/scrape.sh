#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Scrape HTML from Web
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")/../../../.."

echo "🌐 Scraping CASA HTML from web..."
export SCRAPE_MODE=download
export SCRAPE_USE_CACHE=false
node database/scripts/scrapers/CasaStructureScraper.js

echo "✓ CASA HTML saved to database/scraped-html/casa/"
