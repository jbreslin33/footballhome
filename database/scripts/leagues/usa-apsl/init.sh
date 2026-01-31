#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL League Initialization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Parse APSL HTML files and generate SQL files.
# This is the FIRST league loaded, so no curation needed.
#
# Creates:
#   100.00001-organizations-usa-apsl.sql
#   101.00001-clubs-usa-apsl.sql
#   102.00001-teams-usa-apsl.sql
#   900.00001-curation-usa-apsl.sql (empty - first league has no duplicates)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Get to project root (4 levels up from this script)
cd "$(dirname "$0")/../../../.."

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODE=${1:-parse}

echo -e "${YELLOW}⚽ APSL Initialization (mode: $MODE)${NC}"

# Step 1: Parse APSL HTML → database
echo "  1. Parsing APSL HTML..."
if [ "$MODE" = "scrape" ]; then
    SCRAPE_MODE=download SCRAPE_LEAGUE=usa-apsl ./update.sh
else
    SCRAPE_MODE=parse SCRAPE_LEAGUE=usa-apsl SCRAPE_USE_CACHE=true ./update.sh
fi

# Step 2: Export APSL data to SQL
echo "  2. Exporting to SQL..."
cd database/scripts
EXPORT_LEAGUE=usa-apsl EXPORT_LEAGUE_ID=00001 node export-correct-structure.js

# Step 3: Generate curation SQL
echo "  3. Generating curation..."
cd database/scripts/leagues/usa-apsl
node curate.js

echo -e "${GREEN}  ✓ APSL initialized${NC}"
echo "     Created: 100.00001, 101.00001, 102.00001, 900.00001"
