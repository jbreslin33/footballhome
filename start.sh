#!/bin/bash

# Football Home - Database Start Script
# 
# This script prepares and starts the Football Home application.
# It can optionally scrape external data sources.
#
# Usage:
#   ./start.sh                    - Use Lighthouse team data only (minimal dataset)
#   ./start.sh apsl               - Scrape APSL data only
#   ./start.sh google             - Scrape Google Places data only  
#   ./start.sh apsl google        - Scrape both APSL and Google data
#   ./start.sh apslsql            - Load complete APSL dataset from SQL files
#   ./start.sh volumes            - Preserve existing Docker volumes
#   ./start.sh apsl volumes       - Scrape APSL data and preserve volumes
#   ./start.sh apslsql volumes    - Load APSL SQL data and preserve volumes
#   ./start.sh --help             - Show this help message
#
# Parameters:
#   apsl     - Enable APSL league/team data scraping
#   google   - Enable Google Places venue data scraping
#   apslsql  - Load complete APSL dataset from database/apsl/ SQL files
#   volumes  - Preserve existing Docker volumes (default: delete volumes)
#   --help   - Show usage information

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
PRESERVE_VOLUMES=false
LOAD_APSL_SQL=false
NO_CACHE=true  # Default to no cache for development
SHOW_HELP=false

for arg in "$@"; do
    case $arg in
        apsl)
            SCRAPE_APSL=true
            ;;
        google)
            SCRAPE_GOOGLE=true
            ;;
        volumes)
            PRESERVE_VOLUMES=true
            ;;
        apslsql)
            LOAD_APSL_SQL=true
            ;;
        nocache)
            NO_CACHE=true
            ;;
        cache)
            NO_CACHE=false
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
    echo -e "  ./start.sh                    - Use Lighthouse data with fresh builds (default: no cache)"
    echo -e "  ./start.sh apsl               - Scrape APSL data with fresh builds"
    echo -e "  ./start.sh google             - Scrape Google Places data with fresh builds"
    echo -e "  ./start.sh apsl google        - Scrape both APSL and Google data with fresh builds"
    echo -e "  ./start.sh apslsql            - Load complete APSL dataset with fresh builds"
    echo -e "  ./start.sh volumes            - Preserve existing Docker volumes with fresh builds"
    echo -e "  ./start.sh cache              - Use Docker build cache (faster, may have stale files)"
    echo -e "  ./start.sh apsl cache         - Scrape APSL data using cached Docker builds"
    echo -e "  ./start.sh volumes cache      - Preserve volumes and use cached builds"
    echo -e "  ./start.sh --help             - Show this help message"
    echo ""
    echo -e "${BLUE}Parameters:${NC}"
    echo -e "  apsl      Enable APSL league/team data scraping"
    echo -e "  google    Enable Google Places venue data scraping"
    echo -e "  apslsql   Load complete APSL dataset from database/apsl/ SQL files"
    echo -e "  volumes   Preserve existing Docker volumes (default: delete volumes)"
    echo -e "  cache     Use Docker build cache (default: no cache for fresh builds)"
    echo -e "  nocache   Force no cache builds (redundant, this is now default)"
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
echo -e "  Load APSL SQL:    ${GREEN}$LOAD_APSL_SQL${NC}"
echo -e "  Preserve Volumes: ${GREEN}$PRESERVE_VOLUMES${NC}"
echo -e "  Fresh Builds:     ${GREEN}$NO_CACHE${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Step 1: Handle APSL data scraping
echo -e "${BLUE}Step 1: APSL Data Management${NC}"
if [ "$SCRAPE_APSL" = true ]; then
    echo -e "${YELLOW}🔄 Scraping APSL data from external source...${NC}"
    if [ -f "./database/leagues/apsl/scrape-apsl.sh" ]; then
        chmod +x ./database/leagues/apsl/scrape-apsl.sh
        export APSL_SCRAPE=true
        ./database/leagues/apsl/scrape-apsl.sh
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
echo -e "${BLUE}Step 3: Database Configuration${NC}"

# Configure which SQL files to load
if [ "$LOAD_APSL_SQL" = true ]; then
    echo -e "${YELLOW}📊 Configuring for full APSL dataset (all teams and players)${NC}"
    # Ensure APSL data file is available for Docker mount
    if [ ! -f "./database/leagues/apsl/apsl-data.sql" ]; then
        echo -e "${RED}❌ Error: APSL data file not found at ./database/leagues/apsl/apsl-data.sql${NC}"
        exit 1
    fi
    # Create docker-compose override for APSL data
    cat > docker-compose.override.yml << EOF
services:
  db:
    volumes:
      - ./database/schema/01-create-tables.sql:/docker-entrypoint-initdb.d/01-create-tables.sql:ro
      - ./database/seed-data/01-core-lookups.sql:/docker-entrypoint-initdb.d/02-core-lookups.sql:ro
      - ./database/seed-data/02-venues.sql:/docker-entrypoint-initdb.d/03-venues.sql:ro
      - ./database/leagues/apsl/apsl-data.sql:/docker-entrypoint-initdb.d/04-apsl-data.sql:ro
      - ./database/clubs/lighthouse/01-club-setup.sql:/docker-entrypoint-initdb.d/05-lighthouse-club.sql:ro
      - ./database/clubs/lighthouse/02-additional-teams.sql:/docker-entrypoint-initdb.d/06-lighthouse-teams.sql:ro
      - ./database/clubs/lighthouse/03-users.sql:/docker-entrypoint-initdb.d/07-lighthouse-users.sql:ro
EOF
    echo -e "${GREEN}✓ Will load complete APSL dataset with all teams and venues${NC}"
else
    echo -e "${GREEN}📦 Configuring for Lighthouse-only dataset (minimal)${NC}"
    # Create docker-compose override for lighthouse data only (no APSL)
    cat > docker-compose.override.yml << EOF
services:
  db:
    volumes:
      - ./database/schema/01-create-tables.sql:/docker-entrypoint-initdb.d/01-create-tables.sql:ro
      - ./database/seed-data/01-core-lookups.sql:/docker-entrypoint-initdb.d/02-core-lookups.sql:ro
      - ./database/seed-data/02-venues.sql:/docker-entrypoint-initdb.d/03-venues.sql:ro
      - ./database/clubs/lighthouse/01-club-setup.sql:/docker-entrypoint-initdb.d/04-lighthouse-club.sql:ro
      - ./database/clubs/lighthouse/02-additional-teams.sql:/docker-entrypoint-initdb.d/05-lighthouse-teams.sql:ro
      - ./database/clubs/lighthouse/03-users.sql:/docker-entrypoint-initdb.d/06-lighthouse-users.sql:ro
EOF
    echo -e "${GREEN}✓ Will load Lighthouse 1893 SC data and venues${NC}"
fi

echo ""
echo -e "${BLUE}Step 4: Docker Container Management${NC}"

# Handle volume management based on PRESERVE_VOLUMES flag
if [ "$PRESERVE_VOLUMES" = true ]; then
    echo -e "${GREEN}📦 Preserving existing Docker volumes${NC}"
    # Stop containers but keep volumes
    docker compose down
else
    echo -e "${YELLOW}🗑️  Removing Docker volumes for fresh start${NC}"
    # Stop containers and remove volumes
    docker compose down -v
    echo -e "${GREEN}✓ Volumes removed - will initialize fresh database${NC}"
    
    # Remove all project images to ensure truly fresh builds
    echo -e "${YELLOW}🗑️  Removing all project Docker images${NC}"
    docker rmi footballhome-frontend footballhome_frontend-frontend footballhome-backend footballhome_backend-backend 2>/dev/null || true
    echo -e "${GREEN}✓ Project images removed${NC}"
    
    # Clear Docker build cache
    echo -e "${YELLOW}🗑️  Clearing Docker build cache${NC}"
    docker builder prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Build cache cleared${NC}"
    
    # Remove dangling images
    echo -e "${YELLOW}🗑️  Removing dangling Docker images${NC}"
    docker image prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Dangling images removed${NC}"
fi

echo -e "${BLUE}🐳 Starting Docker containers...${NC}"

# Check if this is a fresh start (volumes deleted)
if ! docker volume ls | grep -q footballhome_db_data; then
    echo -e "${YELLOW}⚠ Fresh database detected - will initialize from SQL files${NC}"
fi

# Build containers based on NO_CACHE flag
if [ "$NO_CACHE" = true ]; then
    echo -e "${YELLOW}🔄 Building Docker images without cache (default for development)...${NC}"
    docker compose build --no-cache
    echo -e "${GREEN}✓ Fresh Docker images built${NC}"
else
    echo -e "${BLUE}🏗️ Building Docker images with cache (faster but may use stale files)...${NC}"
    docker compose build
    echo -e "${GREEN}✓ Docker images built from cache${NC}"
fi

# Start containers
docker compose up -d

# Restart system nginx to clear its cache (if it exists)
echo ""
echo -e "${BLUE}Step 5: Reverse Proxy Cache Management${NC}"
if systemctl is-active --quiet nginx 2>/dev/null; then
    echo -e "${YELLOW}�️  Clearing system nginx cache...${NC}"
    # Clear nginx cache directories
    sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
    sudo rm -rf /var/lib/nginx/proxy/* 2>/dev/null || true
    echo -e "${GREEN}✓ Nginx cache cleared${NC}"
    
    echo -e "${YELLOW}🔄 Restarting system nginx...${NC}"
    sudo systemctl restart nginx
    echo -e "${GREEN}✓ System nginx restarted${NC}"
elif systemctl is-active --quiet caddy 2>/dev/null; then
    echo -e "${YELLOW}🔄 Restarting Caddy to clear cache...${NC}"
    sudo systemctl restart caddy
    echo -e "${GREEN}✓ Caddy restarted${NC}"
else
    echo -e "${GREEN}✓ No system reverse proxy detected${NC}"
fi

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
echo -e "  View logs:               ${GREEN}docker compose logs -f${NC}"
echo -e "  Stop services:           ${GREEN}docker compose down${NC}"
echo -e "  Fresh start (minimal):   ${GREEN}./start.sh${NC}"
echo -e "  Fresh start (full data): ${GREEN}./start.sh apslsql${NC}"
echo -e "  Fast start (cached):     ${GREEN}./start.sh cache${NC}"
echo -e "  Preserve data:           ${GREEN}./start.sh volumes${NC}"
echo -e "  Fresh + APSL scraping:   ${GREEN}./start.sh apsl${NC}"
echo -e "  Preserve + APSL:         ${GREEN}./start.sh apsl volumes${NC}"
echo -e "  Fast cached start:       ${GREEN}./start.sh cache${NC}"
echo -e "  Preserve + fast start:   ${GREEN}./start.sh volumes cache${NC}"
echo ""
