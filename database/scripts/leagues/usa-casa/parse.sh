#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")/../../../.."

echo "📄 Parsing CASA HTML..."

# Parse HTML → populate database (APSL + CSL must be loaded first for curation)
SCRAPE_MODE=parse SCRAPE_LEAGUE=usa-casa SCRAPE_USE_CACHE=true ./update.sh

# Export database → SQL files
echo "  Exporting to SQL..."
cd database/scripts
EXPORT_LEAGUE=usa-casa EXPORT_LEAGUE_ID=00002 EXPORT_OUTPUT_DIR=../scripts/leagues/usa-casa/sql node export-correct-structure.js

# Generate curation SQL
echo "  Generating curation..."
cd leagues/usa-casa
node curate.js

echo "✓ CASA SQL files generated in database/scripts/leagues/usa-casa/sql/"
