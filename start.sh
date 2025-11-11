#!/bin/bash

# Football Home - Database Start Script
# 
# This script prepares and starts the Football Home application.
# It handles APSL data scraping before launching Docker containers.
#
# Environment Variables:
#   APSL_SCRAPE=true   - Force fresh scrape of APSL data
#   APSL_SCRAPE=false  - Skip scraping, use existing data
#   (not set)          - Auto-scrape if data is >24 hours old

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Step 1: Run APSL scraper (if needed)
echo -e "${BLUE}Step 1: Checking APSL data...${NC}"
if [ -f "./database/scrape-apsl.sh" ]; then
    chmod +x ./database/scrape-apsl.sh
    ./database/scrape-apsl.sh
else
    echo -e "${YELLOW}⚠ Warning: scrape-apsl.sh not found${NC}"
fi

echo ""
echo -e "${BLUE}Step 2: Starting Docker containers...${NC}"

# Check if this is a fresh start (volumes deleted)
if ! docker volume ls | grep -q footballhome_db_data; then
    echo -e "${YELLOW}⚠ Fresh database detected - will initialize from SQL files${NC}"
fi

# Start containers
docker compose up -d

echo ""
echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo -e "  Database:    ${GREEN}localhost:5432${NC}"
echo -e "  Backend:     ${GREEN}localhost:3001${NC}"
echo -e "  Frontend:    ${GREEN}localhost:3000${NC}"
echo -e "  pgAdmin:     ${GREEN}localhost:5050${NC}"
echo ""
echo -e "${BLUE}To view logs:${NC}    docker compose logs -f"
echo -e "${BLUE}To stop:${NC}        docker compose down"
echo -e "${BLUE}To rebuild:${NC}     docker compose down -v && APSL_SCRAPE=true ./start.sh"
echo ""
