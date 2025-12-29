#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home - Development Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# OOP SCRAPER ARCHITECTURE:
#   All scrapers use database/scripts/index.js with unified OOP base classes:
#   - ApslScraper       → APSL league (apslsoccer.com)
#   - CasaScraper       → CASA league (casasoccerleagues.com + Google Sheets)
#   - GroupMeScraper    → 4 chat implementations (Training, APSL, Boys Club, Old Timers)
#   - VenueScraper      → Google Places API
#
#   Benefits: Reusable components, consistent SQL output, team filters, mode support
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Usage:
#   ./dev.sh                                      # FULL REBUILD: Delete volumes/cache, rebuild from committed SQL files (no scraping)
#   ./dev.sh --apsl --casa                        # Re-scrape APSL + CASA, then rebuild
#   ./dev.sh --lighthouse                         # Re-scrape Lighthouse teams + GroupMe, then rebuild
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Aggregate Flags (Convenience):
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   ./dev.sh --lighthouse                         # All Lighthouse data (APSL/CASA + GroupMe: 4 chats)
#   ./dev.sh --apsl                               # All APSL data (all teams + rosters + schedules)
#   ./dev.sh --casa                               # All CASA data (all teams + rosters)
#   ./dev.sh --groupme                            # All GroupMe data (4 chats: Training, APSL, Boys Club, Old Timers)
#   ./dev.sh --venues                             # Venue details from Google Places API
#   ./dev.sh --groupme-old-timers-external        # Lighthouse Old Timers Club Liga 2 chat → external_identities
#   ./dev.sh --groupme-old-timers-schedule        # Lighthouse Old Timers Club Liga 2 game schedule
#   ./dev.sh --groupme-old-timers-rsvps           # Lighthouse Old Timers Club Liga 2 game RSVPs
#   ./dev.sh --venues                             # Scrape Google Places venues

#
# Typical Workflows:
#   ./dev.sh
#     → Daily development: Full rebuild (wipes DB, loads all SQL files from scratch)
#
#   ./dev.sh --lighthouse
#     → Lighthouse update: Re-scrape structure + rosters + schedules + GroupMe for 4 teams
#
#   ./dev.sh --apsl --casa
#     → New season: Full APSL + CASA scrape (all teams)

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

APSL_SCRAPE_MODE=""
CASA_SCRAPE_MODE=""
GROUPME_MODE=""
VENUE_SCRAPE=false
ENVIRONMENT="dev"
WIPE_U=false
WIPE_P=false
BUILD_BACKEND_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --lighthouse)
            # Convenience flag: All Lighthouse data (structure + rosters + GroupMe)
            APSL_SCRAPE_MODE="lighthouse"
            CASA_SCRAPE_MODE="lighthouse"
            GROUPME_MODE="all"
            ;;
        --groupme)
            # All GroupMe data for all Lighthouse chats
            GROUPME_MODE="all"
            ;;
        --apsl)
            # Full APSL scrape: all teams + rosters + schedules
            APSL_SCRAPE_MODE="players"
            ;;
        --casa)
            # Full CASA scrape (all teams + rosters)
            CASA_SCRAPE_MODE="full"
            ;;
        --venues)
            VENUE_SCRAPE=true
            ;;
        --backend-only)
            BUILD_BACKEND_ONLY=true
            ;;
        --production)
            ENVIRONMENT="production"
            ;;
        --wipe-u)
            WIPE_U=true
            ;;
        --wipe-p)
            WIPE_P=true
            ;;
        --help|-h)
            echo "Football Home Development Script"
            echo ""
            echo "Usage:"
            echo "  ./dev.sh                                   Full rebuild (dev mode, loads ##u files)"
            echo "  ./dev.sh --production                      Full rebuild (production mode, loads ##p files)"
            echo "  ./dev.sh --wipe-u                          Wipe dev app data before rebuild"
            echo "  ./dev.sh --wipe-p                          Wipe production app data before rebuild"
            echo "  ./dev.sh --apsl --casa                     Re-scrape all leagues, then rebuild"
            echo "  ./dev.sh --lighthouse                      Re-scrape Lighthouse teams + GroupMe, then rebuild"
            echo ""
            echo "Aggregate Flags (Convenience):"
            echo "  --lighthouse                               All Lighthouse data (APSL/CASA structure + rosters + schedules + GroupMe)"
            echo "  --apsl                                     All APSL data (structure + all teams + rosters + schedules)"
            echo "  --casa                                     All CASA data (structure + all teams + rosters)"
            echo "  --groupme                                  All GroupMe data (all 4 Lighthouse chats)"
            echo ""
            echo "APSL Scraping Flags:"
            echo "  --apsl                                     Scrape all APSL data (structure + all teams + rosters + schedules)"
            echo ""
            echo "CASA Scraping Flags:"
            echo "  --casa                                     Scrape all CASA data (structure + all teams + rosters)"
            echo ""
            echo "Other Scraping:"
            echo "  --venues                                   Scrape Google Places venues (rarely needed)"
            echo ""
            echo "GroupMe Flags:"
            echo "  --groupme-apsl-external                    APSL Lighthouse: users → external_identities"
            echo "  --groupme-apsl-schedule                    APSL Lighthouse: schedule"
            echo "  --groupme-apsl-rsvps                       APSL Lighthouse: game RSVPs"
            echo "  --groupme-training-lighthouse-external     Training Lighthouse: users → external_identities (division context)"
            echo "  --groupme-training-lighthouse-schedule     Training Lighthouse: practices/events schedule"
            echo "  --groupme-training-lighthouse-rsvps        Training Lighthouse: RSVPs for trainings"
            echo "  --groupme-boys-club-external               Lighthouse Boys Club Liga 1: users → external_identities"
            echo "  --groupme-boys-club-schedule               Lighthouse Boys Club Liga 1: game schedule"
            echo "  --groupme-boys-club-rsvps                  Lighthouse Boys Club Liga 1: game RSVPs"
            echo "  --groupme-old-timers-external              Lighthouse Old Timers Club Liga 2: users → external_identities"
            echo "  --groupme-old-timers-schedule              Lighthouse Old Timers Club Liga 2: game schedule"
            echo "  --groupme-old-timers-rsvps                 Lighthouse Old Timers Club Liga 2: game RSVPs"
            echo ""
            echo "Workflow Flags:"
            echo "  --backend-only                             Rebuild and restart backend container only"
            echo ""
            echo "Examples:"
            echo "  ./dev.sh --apsl --casa"
            echo "    → New season: Full APSL + Full CASA scrape"
            echo ""
            echo "  ./dev.sh --lighthouse"
            echo "    → Weekly update: Lighthouse rosters + Training/GroupMe sync"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --lighthouse, --apsl, --casa, --groupme, --venues, --backend-only, --production, --wipe-u, --help"
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
echo "  ✓ All database init scripts will run (including admin data)"
if [ -n "$APSL_SCRAPE_MODE" ]; then
    echo "  ✓ Scrape APSL (Mode: $APSL_SCRAPE_MODE, includes schedules)"
fi
if [ -n "$CASA_SCRAPE_MODE" ]; then
    echo "  ✓ Scrape CASA (Mode: $CASA_SCRAPE_MODE)"
fi
if [ "$VENUE_SCRAPE" = true ]; then
    echo "  ✓ Scrape Google venues"
fi
if [ "$GROUPME_MODE" = "all" ]; then
    echo "  ✓ GroupMe: All 4 Lighthouse chats (Training, APSL, Boys Club, Old Timers)"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 0: Install dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}📦 Installing npm dependencies...${NC}"
npm install --silent

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: SCRAPE (if requested)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # ──────────────────────────────────────────────────────────────────
    # APSL League Scraping (OOP)
    # ──────────────────────────────────────────────────────────────────
    if [ -n "$APSL_SCRAPE_MODE" ]; then
        echo -e "${YELLOW}📊 Step 1a: Scraping APSL (Mode: $APSL_SCRAPE_MODE)...${NC}"
        
        # Convert mode to lowercase for OOP CLI
        MODE_LOWER=$(echo "$APSL_SCRAPE_MODE" | tr '[:upper:]' '[:lower:]')
        
        # Build command with actual mode (always include schedules)
        CMD="node database/scripts/index.js apsl $MODE_LOWER --schedules"
        
        # Add --team filter if lighthouse mode
        if [ "$APSL_SCRAPE_MODE" = "lighthouse" ]; then
            CMD="$CMD --team Lighthouse"
        fi
        
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ APSL scraping complete ($APSL_SCRAPE_MODE)${NC}"
        echo ""
    fi

    # ──────────────────────────────────────────────────────────────────
    # CASA League Scraping (OOP)
    # ──────────────────────────────────────────────────────────────────
    if [ -n "$CASA_SCRAPE_MODE" ]; then
        echo -e "${YELLOW}📋 Step 1b: Scraping CASA (Mode: $CASA_SCRAPE_MODE)...${NC}"
        
        # Convert mode to lowercase for OOP CLI
        MODE_LOWER=$(echo "$CASA_SCRAPE_MODE" | tr '[:upper:]' '[:lower:]')
        
        # Build command with options
        CMD="node database/scripts/index.js casa $MODE_LOWER"
        
        # Always include schedules for CASA (has calendar data)
        CMD="$CMD --schedules"
        
        # Add --team filter if lighthouse mode
        if [ "$CASA_SCRAPE_MODE" = "lighthouse" ]; then
            CMD="$CMD --team Lighthouse"
        fi
        
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ CASA scraping complete ($CASA_SCRAPE_MODE)${NC}"
        echo ""
    fi

    # ──────────────────────────────────────────────────────────────────
    # Google Places Venue Scraping (OOP)
    # ──────────────────────────────────────────────────────────────────
    if [ "$VENUE_SCRAPE" = true ]; then
        echo -e "${YELLOW}📍 Step 1c: Scraping Google Places Venues...${NC}"
        
        # Philadelphia area default
        CMD="node database/scripts/index.js venues full --location 39.9526,-75.1652 --radius 50000"
        
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ Venue scraping complete${NC}"
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
# STEP 2.5: WIPE APP DATA (if requested)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$WIPE_U" = true ]; then
    echo -e "${YELLOW}🗑️  Wiping dev app data (##u files)...${NC}"
    # Truncate all u files
    for file in database/data/*u-*-app.sql; do
        [ -f "$file" ] && : > "$file"
    done
    
    # Ensure standard placeholders exist if they were deleted
    for num in 02 03 04 05 06 07 08 21 22 23 24 25 30 31 50 51 54 55 56 75 76; do
        # Find if any file starts with this number and has u-*-app.sql pattern
        if ! ls database/data/${num}u-*-app.sql 1> /dev/null 2>&1; then
            # Create a default one if missing
            case $num in
                02) name="venues" ;;
                03) name="leagues" ;;
                04) name="conferences" ;;
                05) name="league-divisions" ;;
                06) name="clubs" ;;
                07) name="sport-divisions" ;;
                08) name="users" ;;
                21) name="teams" ;;
                22) name="players" ;;
                23) name="team_players" ;;
                24) name="coaches" ;;
                25) name="team_coaches" ;;
                30) name="schedule" ;;
                31) name="tactical-boards" ;;
                50) name="auth-credentials" ;;
                51) name="admins" ;;
                54) name="parents" ;;
                55) name="player-parents" ;;
                56) name="sport-admins" ;;
                75) name="club-admins" ;;
                76) name="team-admins" ;;
            esac
            touch "database/data/${num}u-${name}-app.sql"
        fi
    done
    echo -e "${GREEN}✓ Dev app data wiped${NC}"
    echo ""
fi

if [ "$WIPE_P" = true ]; then
    echo -e "${YELLOW}🗑️  Wiping production app data (##p files)...${NC}"
    # Truncate all p files
    for file in database/data/*p-*-app.sql; do
        [ -f "$file" ] && : > "$file"
    done

    # Ensure standard placeholders exist if they were deleted
    for num in 02 03 04 05 06 07 08 21 22 23 24 25 30 31 50 51 54 55 56 75 76; do
        # Find if any file starts with this number and has p-*-app.sql pattern
        if ! ls database/data/${num}p-*-app.sql 1> /dev/null 2>&1; then
            # Create a default one if missing
            case $num in
                02) name="venues" ;;
                03) name="leagues" ;;
                04) name="conferences" ;;
                05) name="league-divisions" ;;
                06) name="clubs" ;;
                07) name="sport-divisions" ;;
                08) name="users" ;;
                21) name="teams" ;;
                22) name="players" ;;
                23) name="team_players" ;;
                24) name="coaches" ;;
                25) name="team_coaches" ;;
                30) name="schedule" ;;
                31) name="tactical-boards" ;;
                50) name="auth-credentials" ;;
                51) name="admins" ;;
                54) name="parents" ;;
                55) name="player-parents" ;;
                56) name="sport-admins" ;;
                75) name="club-admins" ;;
                76) name="team-admins" ;;
            esac
            touch "database/data/${num}p-${name}-app.sql"
        fi
    done

    echo -e "${GREEN}✓ Production app data wiped${NC}"
    echo ""
fi

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

# Export ENVIRONMENT for docker-compose
export ENVIRONMENT

echo -e "${YELLOW}🚀 Step 4: Starting containers (Environment: $ENVIRONMENT)...${NC}"

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
$DOCKER_COMPOSE exec -T db bash /docker-entrypoint-initdb.d/ZZ-pg-cron-setup.sh 2>/dev/null || true
echo -e "${GREEN}✓ pg_cron configured${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 7: GROUPME CHAT IMPORTS (Chat-specific)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$GROUPME_MODE" = "all" ]; then
    echo -e "${YELLOW}💬 Step 7: GroupMe Chats (4 Lighthouse chats)...${NC}"
    
    # Check GroupMe token
    GROUPME_TOKEN_EXISTS=false
    if grep -q "GROUPME_ACCESS_TOKEN=" env 2>/dev/null; then
        GROUPME_TOKEN_EXISTS=true
    fi
    
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        # APSL Lighthouse Chat (Group ID: 109785985)
        echo "  7a: APSL Lighthouse Chat..."
        node database/scripts/index.js groupme-apsl full --schedules
        echo -e "${GREEN}  ✓ APSL Lighthouse chat imported${NC}"
        
        # Training Lighthouse Chat (Group ID: 108640377)
        echo "  7b: Training Lighthouse Chat..."
        node database/scripts/index.js groupme-training full --schedules
        echo -e "${GREEN}  ✓ Training Lighthouse chat imported${NC}"
        
        # Lighthouse Boys Club Liga 1 Chat (Group ID: 109786182)
        echo "  7c: Lighthouse Boys Club Liga 1 Chat..."
        node database/scripts/index.js groupme-boys-club full --schedules
        echo -e "${GREEN}  ✓ Boys Club chat imported${NC}"
        
        # Lighthouse Old Timers Club Liga 2 Chat (Group ID: 109786278)
        echo "  7d: Lighthouse Old Timers Club Liga 2 Chat..."
        node database/scripts/index.js groupme-old-timers full --schedules
        echo -e "${GREEN}  ✓ Old Timers chat imported${NC}"
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env - skipping GroupMe imports${NC}"
    fi
    echo ""
fi

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
