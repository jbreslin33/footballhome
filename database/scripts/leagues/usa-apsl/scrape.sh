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
cd "$(dirname "$0")/../../../.."

echo "🌐 Scraping APSL HTML from web..."
SCRAPE_MODE=download SCRAPE_LEAGUE=usa-apsl ./update.sh

echo "✓ APSL HTML saved to database/scraped-html/apsl/"
