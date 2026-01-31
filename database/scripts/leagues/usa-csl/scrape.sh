#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Scrape HTML from Web
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")/../../../.."

echo "🌐 Scraping CSL HTML from web..."
export SCRAPE_MODE=download
export SCRAPE_USE_CACHE=false
node database/scripts/scrapers/CslStructureScraper.js

echo "✓ CSL HTML saved to database/scraped-html/csl/"
