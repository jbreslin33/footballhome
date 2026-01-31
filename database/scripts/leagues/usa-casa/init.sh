#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA League Initialization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Parse CASA HTML files and generate SQL files.
# Curates CASA clubs/orgs against existing APSL+CSL data.
#
# Creates:
#   100.00002-organizations-usa-casa.sql
#   101.00002-clubs-usa-casa.sql
#   102.00002-teams-usa-casa.sql
#   900.00002-curation-usa-casa.sql (merges CASA duplicates into APSL+CSL)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

cd "$(dirname "$0")/../../../.."

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODE=${1:-parse}

echo -e "${YELLOW}⚽ CASA Initialization (mode: $MODE)${NC}"

# Step 1: Parse CASA HTML → database (APSL+CSL must already be loaded)
echo "  1. Parsing CASA HTML..."
if [ "$MODE" = "scrape" ]; then
    SCRAPE_MODE=download SCRAPE_LEAGUE=usa-casa ./update.sh
else
    SCRAPE_MODE=parse SCRAPE_LEAGUE=usa-casa SCRAPE_USE_CACHE=true ./update.sh
fi

# Step 2: Export CASA data to SQL
echo "  2. Exporting to SQL..."
cd database/scripts
EXPORT_LEAGUE=usa-casa EXPORT_LEAGUE_ID=00002 node export-correct-structure.js

# Step 3: Generate curation (CASA merging into APSL+CSL)
echo "  3. Generating curation..."
cd database/scripts/leagues/usa-casa
node curate.js

echo -e "${GREEN}  ✓ CASA initialized${NC}"
echo "     Created: 100.00002, 101.00002, 102.00002, 900.00002"
