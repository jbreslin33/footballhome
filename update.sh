#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home - Data Update Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Runs scrapers to populate/update database.
# Runs all active league scrapers (hardcoded URLs in scraper files).
#
# Usage:
#   ./update.sh        Run all active scrapers
#
# This can be run:
#   - After ./build.sh (initial data population)
#   - Anytime to refresh data
#   - In a cron job for automated updates
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Change to script directory (project root)
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Data Update${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if containers are running
if ! podman ps --format "{{.Names}}" 2>/dev/null | grep -q "footballhome_db"; then
    if ! sudo podman ps --format "{{.Names}}" 2>/dev/null | grep -q "footballhome_db"; then
        echo -e "${RED}Error: Database container not running${NC}"
        echo "Start containers first: ./build.sh"
        exit 1
    fi
fi

echo -e "${YELLOW}🔄 Running data update orchestrator...${NC}"
echo ""

# Run the Node.js orchestrator
node update.js

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Data update complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}📊 Verify what was scraped:${NC}"
echo "  node database/scripts/audit-database.js"
echo ""
