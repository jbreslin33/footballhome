#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Full Init Pipeline
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# One-time onboarding: generates all SQL files from cached HTML including
# match events. After running, all SQL files (100-109) are committed to git.
#
# Prerequisites:
#   - Cached HTML in database/scraped-html/csl/ (run scrape.sh first)
#   - APSL must be parsed first (curate reads APSL sql/ files)
#   - Database running with bootstrap data + APSL + CSL SQL loaded
#     (make rebuild && make load-apsl && make load-csl)
#
# Steps:
#   1. Parse HTML → generate SQL files (100-107, offline)
#   2. Curate SQL against APSL (match duplicate clubs)
#   3. Load SQL into database
#   4. Scrape match events from cached HTML into database
#   5. Export match events from database to SQL files (109)
#
# After running:
#   - All SQL files in sql/ are complete and ready to commit
#   - Database contains full CSL data including events
#
# Usage:
#   ./init.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Find project root (look for Makefile)
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ] && [ "$PROJECT_ROOT" != "/" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏗️  CSL Full Init"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1+2: Parse + Curate
echo ""
echo "📄 Step 1/5: Generating SQL from cached HTML..."
node --max-old-space-size=16384 database/scripts/leagues/north-america/usa/csl/generate-sql.js

echo ""
echo "🔍 Step 2/5: Curating SQL against APSL..."
node database/scripts/leagues/north-america/usa/csl/curate-sql.js

# Step 3: Load into database
echo ""
echo "📥 Step 3/5: Loading SQL into database..."
cd database/scripts/leagues/north-america/usa/csl && ./load.sh && cd - > /dev/null

# Step 4: Scrape events
echo ""
echo "⚽ Step 4/5: Scraping match events from cached HTML..."
cd database/scripts/scrapers && node CslMatchEventScraper.js && cd - > /dev/null

# Step 5: Export events to SQL
echo ""
echo "📤 Step 5/5: Exporting events to SQL files..."
node database/scripts/export-events-sql.js --league csl

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ CSL init complete"
echo ""
echo "SQL files ready in database/scripts/leagues/north-america/usa/csl/sql/"
echo "Next: git add/commit the SQL files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
