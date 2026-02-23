#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Full Init Pipeline
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# One-time onboarding: generates all SQL files from cached JSON/HTML.
# CASA currently has no match events to scrape.
#
# Prerequisites:
#   - Cached data in database/scraped-html/casa/ (run scrape.sh first)
#   - APSL and CSL must be parsed first (curate reads their sql/ files)
#   - Database running with bootstrap data + APSL + CSL loaded
#     (make rebuild && make load-apsl && make load-csl)
#
# Steps:
#   1. Parse JSON → generate SQL files (100-106, offline)
#   2. Curate SQL against APSL + CSL (match duplicate clubs)
#   3. Load SQL into database
#
# Note: CASA does not have match events yet (roster scraping not implemented).
# When implemented, steps 4+5 (scrape events + export) will be added here.
#
# After running:
#   - All SQL files in sql/ are complete and ready to commit
#   - Database contains full CASA data
#
# Usage:
#   ./init.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../../.."

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏗️  CASA Full Init"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1+2: Parse + Curate
echo ""
echo "📄 Step 1/3: Generating SQL from cached data..."
node database/scripts/leagues/usa-casa/generate-sql.js

echo ""
echo "🔍 Step 2/3: Curating SQL against APSL + CSL..."
node database/scripts/leagues/usa-casa/curate-sql.js

# Step 3: Load into database
echo ""
echo "📥 Step 3/3: Loading SQL into database..."
cd database/scripts/leagues/usa-casa && ./load.sh && cd - > /dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ CASA init complete"
echo ""
echo "SQL files ready in database/scripts/leagues/usa-casa/sql/"
echo "Next: git add/commit the SQL files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
