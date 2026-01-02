#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home - Development Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# THREE-TIER DATA PIPELINE:
#   
#   1. ./dev.sh (default)
#      → Use committed SQL files (fastest, no network/parsing)
#      → Data: database/data/*.sql files in git
#   
#   2. ./dev.sh --reparse
#      → Parse cached HTML → regenerate SQL files
#      → Data: database/scraped-html/ (HTML cache)
#      → Medium speed: no network, but re-parsing HTML
#   
#   3. ./dev.sh --rescrape
#      → Fetch live websites → save HTML → parse → generate SQL
#      → Data: Live APSL/CASA websites
#      → Slowest: network calls + parsing (auto-implies --reparse)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SCRAPERS (database/scripts/index.js):
#   - ApslScraper       → APSL league (apslsoccer.com)
#   - CasaScraper       → CASA league (casasoccerleagues.com + Google Sheets)
#   - GroupMeScraper    → 4 chat implementations (Training, APSL, Boys Club, Old Timers)
#   - VenueScraper      → Google Places API
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Typical Workflows:
#   ./dev.sh
#     → Daily development: Full rebuild from committed SQL
#
#   ./dev.sh --reparse
#     → Re-generate SQL from cached HTML (after manual HTML fixes)
#
#   ./dev.sh --rescrape
#     → Fetch fresh data from websites (weekly/new season)

set -e

# Change to script directory (project root)
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================
# ADD PYTHON USER BIN TO PATH (for podman-compose)
# ============================================================
if command -v python3 &> /dev/null; then
    PYTHON_USER_BIN=$(python3 -m site --user-base)/bin
    export PATH="$PYTHON_USER_BIN:$PATH"
fi

# ============================================================
# ENVIRONMENT FILE CHECK
# ============================================================
if [ ! -f "env" ]; then
    echo -e "${RED}Error: env file not found${NC}"
    echo ""
    echo "Download the env file and place it in the project root:"
    echo "  $(pwd)/env"
    echo ""
    echo "Contact the team for access to the credentials file."
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Found env file${NC}"

# ============================================================
# PODMAN AVAILABILITY CHECK (early exit if not accessible)
# ============================================================
if podman ps &> /dev/null 2>&1; then
    # Works without sudo
    DOCKER="podman"
    # Fallback to docker-compose if podman-compose is missing
    if command -v podman-compose &> /dev/null; then
        DOCKER_COMPOSE="podman-compose --env-file env"
    else
        DOCKER_COMPOSE="docker-compose --env-file env"
    fi
elif sudo podman ps &> /dev/null 2>&1; then
    # Needs sudo, set alias for all commands
    DOCKER="sudo podman"
    # Fallback to docker-compose if podman-compose is missing
    if command -v podman-compose &> /dev/null; then
        DOCKER_COMPOSE="sudo podman-compose --env-file env"
    else
        DOCKER_COMPOSE="sudo docker-compose --env-file env"
    fi
else
    echo -e "${RED}Error: Podman is not accessible${NC}"
    echo ""
    echo "Podman is required to run this application."
    echo ""
    echo "Possible solutions:"
    echo "  1. Make sure Podman is installed:"
    echo "     ./setup.sh"
    echo ""
    echo "  2. If installed, you may need to log out and back in:"
    echo "     Group permissions take effect after login"
    echo "     Quick fix: exec su -l \$USER"
    echo ""
    echo "  3. Check Podman status (macOS):"
    echo "     podman machine start"
    echo ""
    exit 1
fi

RESCRAPE=false
REPARSE=false
BUILD_BACKEND_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --rescrape)
            RESCRAPE=true
            REPARSE=true  # Rescraping auto-implies reparsing
            ;;
        --reparse)
            REPARSE=true
            ;;
        --backend-only)
            BUILD_BACKEND_ONLY=true
            ;;
        --help|-h)
            echo "Football Home Development Script"
            echo ""
            echo "THREE-TIER DATA PIPELINE:"
            echo "  1. ./dev.sh              → Use committed SQL files (fastest)"
            echo "  2. ./dev.sh --reparse    → Parse cached HTML → regenerate SQL"
            echo "  3. ./dev.sh --rescrape   → Fetch websites → parse → regenerate SQL"
            echo ""
            echo "Usage:"
            echo "  ./dev.sh                       Full rebuild from committed SQL (fastest)"
            echo "  ./dev.sh --reparse             Parse cached HTML → regenerate SQL → rebuild"
            echo "  ./dev.sh --rescrape            Fetch websites → parse → regenerate SQL → rebuild"
            echo "  ./dev.sh --backend-only        Rebuild backend container only (fast iteration)"
            echo ""
            echo "Examples:"
            echo "  ./dev.sh"
            echo "    → Daily development: Load from committed SQL (no network)"
            echo ""
            echo "  ./dev.sh --reparse"
            echo "    → After fixing HTML parsers: Re-generate SQL from cached HTML"
            echo ""
            echo "  ./dev.sh --rescrape"
            echo "    → Weekly update: Fetch fresh data from websites (reads scrape_targets table)"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --rescrape, --reparse, --backend-only, --help"
            exit 1
            ;;
    esac
done

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FAST PATH: BACKEND REBUILD ONLY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ "$BUILD_BACKEND_ONLY" = true ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Football Home - Backend Rebuild${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    echo -e "${YELLOW}🔨 Rebuilding backend container...${NC}"
    $DOCKER_COMPOSE build backend
    
    echo -e "${YELLOW}🚀 Restarting backend container...${NC}"
    # Force remove backend and frontend to avoid dependency errors with Podman
    $DOCKER rm -f footballhome_frontend footballhome_backend || true
    
    $DOCKER_COMPOSE up -d backend
    $DOCKER_COMPOSE up -d frontend
    
    echo -e "${GREEN}✓ Backend rebuilt and restarted${NC}"
    exit 0
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Full Rebuild${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show plan
echo -e "${YELLOW}📋 Plan:${NC}"
echo "  ✓ Delete all containers and volumes (fresh database)"
echo "  ✓ Clear Docker build cache"
echo "  ✓ Rebuild all images (cache dependencies, rebuild app code)"
if [ "$RESCRAPE" = true ]; then
    echo "  ✓ Fetch live websites → save HTML cache"
    echo "  ✓ Parse HTML → regenerate SQL files"
elif [ "$REPARSE" = true ]; then
    echo "  ✓ Parse cached HTML → regenerate SQL files"
else
    echo "  ✓ Use committed SQL files (no scraping/parsing)"
fi
echo "  ✓ Load all database init scripts"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 0: Install dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}📦 Installing npm dependencies...${NC}"
npm install --silent

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: SCRAPE/PARSE (if requested)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$RESCRAPE" = true ]; then
    echo -e "${YELLOW}🌐 Step 1: Scraping live websites...${NC}"
    echo "  → Reading targets from scrape_targets table..."
    node database/scripts/index.js --fetch
    echo -e "${GREEN}✓ HTML cached to database/scraped-html/${NC}"
    echo ""
fi

if [ "$REPARSE" = true ]; then
    echo -e "${YELLOW}🔍 Step 1b: Parsing HTML → generating SQL...${NC}"
    echo "  → Processing cached HTML files..."
    node database/scripts/index.js --parse
    echo -e "${GREEN}✓ SQL files regenerated in database/data/${NC}"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: CLEAN EVERYTHING (ALWAYS - ensures fresh database on every run)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ALWAYS do full cleanup: delete containers, volumes, and build cache
# This ensures database init scripts (like 51-admins.sql, 75-club-admins.sql) run every time
echo -e "${YELLOW}🧹 Step 2: Full cleanup (containers, volumes, build cache)...${NC}"
echo "  ✓ Stopping and removing containers and volumes..."

# Stop containers first
$DOCKER_COMPOSE down 2>&1 | grep -v "no container with" | grep -v "Error:" || true

# Force remove any remaining containers
$DOCKER stop footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
$DOCKER rm -f footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true

# Remove volumes explicitly
$DOCKER volume rm footballhome_db_data 2>/dev/null || true
$DOCKER volume rm footballhome_footballhome_network 2>/dev/null || true

# Remove network
$DOCKER network rm footballhome_footballhome_network 2>/dev/null || true

# Remove pod if it exists
$DOCKER pod rm -f pod_footballhome 2>/dev/null || true

# Only remove dangling/unused footballhome images, keep base images (postgres, gcc, nginx)
echo "  ✓ Removing old footballhome images..."
$DOCKER images | grep footballhome | awk '{print $3}' | xargs -r $DOCKER rmi -f 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup complete (fresh start guaranteed)${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: BUILD (ALWAYS)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🔨 Step 3: Building images (no cache)...${NC}"
echo -e "${BLUE}Note: First-time image downloads can take 5-15 minutes${NC}"
echo ""

# Start background monitoring
(
    sleep 10  # Give build time to start
    while kill -0 $$ 2>/dev/null; do
        echo -e "${BLUE}📊 Image status:${NC}"
        $DOCKER images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null | grep -E "(REPOSITORY|gcc|postgres|nginx|footballhome)" | head -10
        echo ""
        sleep 10
    done
) &
MONITOR_PID=$!

# Run the build
$DOCKER_COMPOSE build

# Stop monitoring
kill $MONITOR_PID 2>/dev/null

echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 4: START
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🚀 Step 4: Starting containers...${NC}"

# Start database first
echo -n "  Starting database"
$DOCKER_COMPOSE up -d db
for i in $(seq 1 120); do
    # Check if container exists and is running
    if $DOCKER ps --format "{{.Names}}" | grep -q "footballhome_db"; then
        DB_HEALTH=$($DOCKER inspect --format '{{.State.Health.Status}}' footballhome_db 2>/dev/null || echo "starting")
        if [ "$DB_HEALTH" = "healthy" ]; then
            echo -e " ${GREEN}✓ Healthy (${i}s)${NC}"
            break
        fi
    fi
    echo -n "."
    sleep 1
    if [ "$i" -eq 120 ]; then
        echo -e " ${RED}✗ Timeout${NC}"
        $DOCKER logs footballhome_db | tail -20
        exit 1
    fi
done

# Start remaining services
echo -n "  Starting remaining services"
$DOCKER_COMPOSE up -d
echo -e " ${GREEN}✓${NC}"

echo -e "${GREEN}✓ Containers started${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 5: WAIT FOR SERVICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}⏳ Step 5: Waiting for services...${NC}"

# Wait for database to be healthy first
echo -n "  Database: "
for i in $(seq 1 60); do
    if $DOCKER_COMPOSE exec -T db pg_isready -U footballhome > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo -e "${RED}✗ Timeout after 60s${NC}"
        $DOCKER_COMPOSE logs db | tail -20
        exit 1
    fi
    sleep 1
done

# Wait for backend (includes DB init time - can take 3+ minutes with APSL data)
echo -n "  Backend: "
for i in $(seq 1 240); do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 240 ]; then
        echo -e "${RED}✗ Timeout after 240s${NC}"
        echo ""
        echo "Check logs:"
        echo "  docker compose logs backend"
        $DOCKER_COMPOSE logs backend | tail -30
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
$DOCKER_COMPOSE exec -T db bash /docker-entrypoint-initdb.d/999-pg-cron-setup.sh 2>/dev/null || true
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
echo ""
echo "Login: soccer@lighthouse1893.org / 1893Soccer!"
echo ""
if [ "$RESCRAPE" = true ]; then
    echo -e "${YELLOW}📁 Generated files:${NC}"
    echo "  → database/scraped-html/ (HTML cache from live websites)"
    echo "  → database/data/028-*.sql (teams)"
    echo "  → database/data/032-*.sql (players)"
    echo "  → database/data/050-*.sql (matches)"
elif [ "$REPARSE" = true ]; then
    echo -e "${YELLOW}📁 Regenerated files:${NC}"
    echo "  → database/data/028-*.sql (teams)"
    echo "  → database/data/032-*.sql (players)"
    echo "  → database/data/050-*.sql (matches)"
fi
