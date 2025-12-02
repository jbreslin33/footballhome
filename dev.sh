#!/bin/bash
# Football Home - Development Script
#
# Usage:
#   ./dev.sh                  # Full rebuild (no scraping)
#   ./dev.sh --apsl           # Full rebuild + scrape APSL data
#   ./dev.sh --venues         # Full rebuild + scrape Google venues
#   ./dev.sh --apsl --venues  # Full rebuild + scrape both

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

APSL_SCRAPE=false
VENUE_SCRAPE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --apsl)
            APSL_SCRAPE=true
            ;;
        --venues)
            VENUE_SCRAPE=true
            ;;
        --help|-h)
            echo "Football Home Development Script"
            echo ""
            echo "Usage:"
            echo "  ./dev.sh                  Full rebuild (no scraping)"
            echo "  ./dev.sh --apsl           Full rebuild + scrape APSL data"
            echo "  ./dev.sh --venues         Full rebuild + scrape Google venues"
            echo "  ./dev.sh --apsl --venues  Full rebuild + scrape both"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --apsl, --venues, --help"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Full Rebuild${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show plan
echo -e "${YELLOW}📋 Plan:${NC}"
echo "  ✓ Delete all containers and volumes"
echo "  ✓ Clear Docker build cache"
echo "  ✓ Rebuild all images (no cache)"
if [ "$APSL_SCRAPE" = true ]; then
    echo "  ✓ Scrape APSL data"
fi
if [ "$VENUE_SCRAPE" = true ]; then
    echo "  ✓ Scrape Google venues"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: SCRAPE (if requested)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$APSL_SCRAPE" = true ]; then
    echo -e "${YELLOW}📊 Step 1a: Scraping APSL...${NC}"
    if [ -f "database/scripts/apsl-scraper/scrape-apsl.js" ]; then
        node database/scripts/apsl-scraper/scrape-apsl.js
        echo -e "${GREEN}✓ APSL scraping complete${NC}"
    else
        echo -e "${RED}✗ Scraper not found: database/scripts/apsl-scraper/scrape-apsl.js${NC}"
        exit 1
    fi
    echo ""
fi

if [ "$VENUE_SCRAPE" = true ]; then
    echo -e "${YELLOW}📍 Step 1b: Scraping Google Venues...${NC}"
    if [ -f "database/scripts/venue-scraper/scrape-google-venues.js" ]; then
        node database/scripts/venue-scraper/scrape-google-venues.js
        echo -e "${GREEN}✓ Venue scraping complete${NC}"
    else
        echo -e "${YELLOW}⚠ Venue scraper not found, skipping${NC}"
    fi
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: CLEAN EVERYTHING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🧹 Step 2: Cleaning up...${NC}"
docker compose down -v 2>/dev/null || true
docker builder prune -af 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: BUILD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🔨 Step 3: Building images (no cache)...${NC}"
docker compose build --no-cache
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 4: START
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🚀 Step 4: Starting containers...${NC}"
docker compose up -d

# Wait for containers to be fully running
echo -n "  Waiting for containers to initialize"
for i in $(seq 1 30); do
    RUNNING=$(docker compose ps --status running -q 2>/dev/null | wc -l)
    if [ "$RUNNING" -ge 3 ]; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo -e "${GREEN}✓ Containers started${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 5: WAIT FOR SERVICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}⏳ Step 5: Waiting for services...${NC}"

# Wait for database to be healthy first
echo -n "  Database: "
for i in $(seq 1 60); do
    if docker compose exec -T db pg_isready -U footballhome > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo -e "${RED}✗ Timeout after 60s${NC}"
        docker compose logs db | tail -20
        exit 1
    fi
    sleep 1
done

# Wait for backend (includes DB init time)
echo -n "  Backend: "
for i in $(seq 1 120); do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 120 ]; then
        echo -e "${RED}✗ Timeout after 120s${NC}"
        echo ""
        echo "Check logs:"
        echo "  docker compose logs backend"
        docker compose logs backend | tail -30
        exit 1
    fi
    sleep 1
done

# Check frontend
echo -n "  Frontend: "
for i in $(seq 1 30); do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo -e "${YELLOW}⚠ Not ready yet (may need a moment)${NC}"
    fi
    sleep 1
done
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 6: SETUP PG_CRON
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}⏰ Step 6: Setting up pg_cron...${NC}"
docker compose exec -T db bash /docker-entrypoint-initdb.d/ZZ-pg-cron-setup.sh 2>/dev/null || true
echo -e "${GREEN}✓ pg_cron configured${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DONE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All services ready!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Frontend:  http://localhost:3000"
echo "Backend:   http://localhost:3001"
echo "pgAdmin:   http://localhost:5050"
echo ""
echo "Login: jbreslin@footballhome.org / 1893Soccer!"
