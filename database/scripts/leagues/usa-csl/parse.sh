#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")/../../../.."

echo "📄 Parsing CSL HTML..."

# Parse HTML → populate database (APSL must be loaded first for curation)
SCRAPE_MODE=parse SCRAPE_LEAGUE=usa-csl SCRAPE_USE_CACHE=true ./update.sh

# Export database → SQL files
echo "  Exporting to SQL..."
cd database/scripts
EXPORT_LEAGUE=usa-csl EXPORT_LEAGUE_ID=00003 EXPORT_OUTPUT_DIR=../scripts/leagues/usa-csl/sql node export-correct-structure.js

# Generate curation SQL
echo "  Generating curation..."
cd leagues/usa-csl
node curate.js

echo "✓ CSL SQL files generated in database/scripts/leagues/usa-csl/sql/"
