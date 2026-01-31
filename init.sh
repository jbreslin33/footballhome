#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home - Parse HTML to SQL Files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Reads HTML files from database/scraped-html/ and generates SQL files.
# Each team gets its own club and org (1:1:1 mapping - no curation).
#
# Flow:
#   1. Start temp database with schema + bootstrap data
#   2. Run scrapers to parse HTML → write to database
#   3. Export database → SQL files (100.X orgs, 101.X clubs, 102.X teams)
#   4. SQL files ready for git commit
#
# After this, build.sh just loads SQL files (no HTML parsing needed).
#
# Usage:
#   ./read_init_html_to_sql.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Initialize All Leagues from HTML${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Mode: scrape (fetch fresh HTML) or parse (use cached HTML)
MODE=${1:-parse}

if [ "$MODE" = "scrape" ]; then
    echo "Mode: SCRAPE (fetching fresh HTML from websites)"
elif [ "$MODE" = "parse" ]; then
    echo "Mode: PARSE (using cached HTML files - reproducible)"
else
    echo -e "${RED}Invalid mode: $MODE${NC}"
    echo "Usage: ./init.sh [scrape|parse]"
    exit 1
fi

echo ""

# Run each league init script in order
echo -e "${YELLOW}📦 League 1: APSL${NC}"
./database/scripts/leagues/usa-apsl/init.sh $MODE

echo ""
echo -e "${YELLOW}📦 League 2: CSL${NC}"
./database/scripts/leagues/usa-csl/init.sh $MODE

echo ""
echo -e "${YELLOW}📦 League 3: CASA${NC}"
./database/scripts/leagues/usa-casa/init.sh $MODE

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All leagues initialized!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "SQL files created in database/data/:"
echo "  100.00001, 101.00001, 102.00001, 900.00001 (APSL)"
echo "  100.00003, 101.00003, 102.00003, 900.00003 (CSL)"
echo "  100.00002, 101.00002, 102.00002, 900.00002 (CASA)"
echo ""
echo "Next steps:"
echo "  1. Review SQL files"
echo "  2. Run ./build.sh to test full load"
echo "  3. git add database/data/10*.sql database/data/900.*.sql"
echo "  4. git commit -m 'Initialize APSL, CSL, CASA from HTML'"
echo ""
