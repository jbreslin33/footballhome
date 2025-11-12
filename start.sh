#!/bin/bash

# Football Home - Database Start Script
# 
# This script prepares and starts the Football Home application.
# It can optionally scrape external data sources.
#
# Usage:
#   ./start.sh                    - Use existing data only (no external API calls)
#   ./start.sh apsl               - Scrape APSL data only
#   ./start.sh google             - Scrape Google Places data only  
#   ./start.sh apsl google        - Scrape both APSL and Google data
#   ./start.sh --help             - Show this help message
#
# Parameters:
#   apsl    - Enable APSL league/team data scraping
#   google  - Enable Google Places venue data scraping
#   --help  - Show usage information

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse command line arguments
SCRAPE_APSL=false
SCRAPE_GOOGLE=false
SHOW_HELP=false

for arg in "$@"; do
    case $arg in
        apsl)
            SCRAPE_APSL=true
            ;;
        google)
            SCRAPE_GOOGLE=true
            ;;
        --help|-h)
            SHOW_HELP=true
            ;;
        *)
            echo -e "${RED}Error: Unknown parameter '$arg'${NC}"
            SHOW_HELP=true
            ;;
    esac
done

# Show help if requested or on error
if [ "$SHOW_HELP" = true ]; then
    echo -e "${BLUE}Football Home - Database Start Script${NC}"
    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ./start.sh                    - Use existing data only (no external API calls)"
    echo -e "  ./start.sh apsl               - Scrape APSL data only"
    echo -e "  ./start.sh google             - Scrape Google Places data only"
    echo -e "  ./start.sh apsl google        - Scrape both APSL and Google data"
    echo -e "  ./start.sh --help             - Show this help message"
    echo ""
    echo -e "${BLUE}Parameters:${NC}"
    echo -e "  apsl      Enable APSL league/team data scraping"
    echo -e "  google    Enable Google Places venue data scraping"
    echo -e "  --help    Show usage information"
    echo ""
    exit 0
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  APSL Scraping:    ${GREEN}$SCRAPE_APSL${NC}"
echo -e "  Google Scraping:  ${GREEN}$SCRAPE_GOOGLE${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Step 1: Handle APSL data scraping
echo -e "${BLUE}Step 1: APSL Data Management${NC}"
if [ "$SCRAPE_APSL" = true ]; then
    echo -e "${YELLOW}🔄 Scraping APSL data from external source...${NC}"
    if [ -f "./database/scrape-apsl.sh" ]; then
        chmod +x ./database/scrape-apsl.sh
        export APSL_SCRAPE=true
        ./database/scrape-apsl.sh
        echo -e "${GREEN}✓ APSL data scraped successfully${NC}"
    else
        echo -e "${RED}❌ Error: scrape-apsl.sh not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}📁 Using existing APSL data from SQL inserts (no external API calls)${NC}"
fi

# Step 2: Handle Google Places data scraping
echo -e "${BLUE}Step 2: Google Places Data Management${NC}"
if [ "$SCRAPE_GOOGLE" = true ]; then
    echo -e "${YELLOW}🔄 Scraping Google Places data...${NC}"
    if [ -f "./scripts/scrape-google-venues.sh" ]; then
        chmod +x ./scripts/scrape-google-venues.sh
        export GOOGLE_SCRAPE=true
        ./scripts/scrape-google-venues.sh
        echo -e "${GREEN}✓ Google Places data scraped successfully${NC}"
    else
        echo -e "${RED}⚠ Warning: Google Places scraper not found${NC}"
        echo -e "${YELLOW}  Will use existing venue data from SQL inserts${NC}"
    fi
else
    echo -e "${GREEN}📁 Using existing Google Places data from SQL inserts (no API costs)${NC}"
fi

echo ""
echo -e "${BLUE}Step 3: Starting Docker containers...${NC}"

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
echo -e "${BLUE}Usage Examples:${NC}"
echo -e "  View logs:       ${GREEN}docker compose logs -f${NC}"
echo -e "  Stop services:   ${GREEN}docker compose down${NC}"
echo -e "  Full rebuild:    ${GREEN}docker compose down -v && ./start.sh${NC}"
echo -e "  Rebuild + APSL:  ${GREEN}docker compose down -v && ./start.sh apsl${NC}"
echo -e "  Rebuild + Both:  ${GREEN}docker compose down -v && ./start.sh apsl google${NC}"
echo ""
