#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL League Initialization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Parse CSL HTML files and generate SQL files.
# Curates CSL clubs/orgs against existing APSL data.
#
# Creates:
#   100.00003-organizations-usa-csl.sql
#   101.00003-clubs-usa-csl.sql
#   102.00003-teams-usa-csl.sql
#   900.00003-curation-usa-csl.sql (merges CSL duplicates into APSL)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

cd "$(dirname "$0")/../../../.."

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODE=${1:-parse}

echo -e "${YELLOW}⚽ CSL Initialization (mode: $MODE)${NC}"

# Step 1: Load APSL (prerequisite)
echo "  1. Loading prerequisites (APSL)..."
./build.sh > /dev/null 2>&1

# Step 2: Parse CSL HTML → database
echo "  2. Parsing CSL HTML..."
if [ "$MODE" = "scrape" ]; then
    SCRAPE_MODE=download SCRAPE_LEAGUE=usa-csl ./update.sh
else
    SCRAPE_MODE=parse SCRAPE_LEAGUE=usa-csl SCRAPE_USE_CACHE=true ./update.sh
fi

# Step 3: Export CSL data to SQL
echo "  3. Exporting to SQL..."
cd database/scripts
EXPORT_LEAGUE=usa-csl EXPORT_LEAGUE_ID=00003 node export-correct-structure.js

# Step 4: Generate curation (CSL merging into APSL)
echo "  4. Generating curation..."
cd database/scripts/leagues/usa-csl
node curate.js

echo -e "${GREEN}  ✓ CSL initialized${NC}"
echo "     Created: 100.00003, 101.00003, 102.00003, 900.00003"
