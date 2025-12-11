#!/bin/bash
# Football Home - Development Script
#
# Usage:
#   ./dev.sh                                      # Full rebuild (no scraping)
#   ./dev.sh --apsl-structure                     # Scrape APSL structure (conferences/divisions/teams)
#   ./dev.sh --apsl-players-lighthouse            # Scrape Lighthouse 1893 SC players only
#   ./dev.sh --casa-lighthouse                    # Scrape Lighthouse Boys Club + Old Timers
#   ./dev.sh --groupme-users                      # Sync GroupMe users to external_identities
#   ./dev.sh --groupme-schedule                   # Import practices/games from GroupMe
#   ./dev.sh --save                               # Export manual edits before rebuild
#   ./dev.sh --replay-only                        # Fast rebuild from saved changes
#
# Typical Workflows:
#   ./dev.sh --apsl-structure --apsl-players-lighthouse --casa-lighthouse --groupme-users --groupme-schedule --save
#     → New season: Full structure + Lighthouse players + GroupMe sync
#
#   ./dev.sh --apsl-players-lighthouse --casa-lighthouse --groupme-users --groupme-schedule --save
#     → Weekly update: Player data + GroupMe sync (uses saved structure)
#
#   ./dev.sh --replay-only
#     → Daily development: Fast rebuild from saved state (~10 seconds)

set -e

# Change to script directory (project root)
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

APSL_SCRAPE_MODE=""
CASA_SCRAPE_MODE=""
VENUE_SCRAPE=false
GROUPME_USERS=false
GROUPME_SCHEDULE=false
SAVE_MANUAL=false
REPLAY_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --apsl|--apsl-players)
            APSL_SCRAPE_MODE="full"
            ;;
        --apsl-structure)
            # Only set if not already set to a more inclusive mode
            if [ "$APSL_SCRAPE_MODE" != "full" ] && [ "$APSL_SCRAPE_MODE" != "lighthouse" ]; then
                APSL_SCRAPE_MODE="structure"
            fi
            ;;
        --apsl-players-lighthouse|--apsl-lighthouse)
            # Only set if not already set to full
            if [ "$APSL_SCRAPE_MODE" != "full" ]; then
                APSL_SCRAPE_MODE="lighthouse"
            fi
            ;;
        --casa-structure)
            if [ "$CASA_SCRAPE_MODE" != "full" ] && [ "$CASA_SCRAPE_MODE" != "lighthouse" ]; then
                CASA_SCRAPE_MODE="structure"
            fi
            ;;
        --casa-lighthouse)
            CASA_SCRAPE_MODE="lighthouse"
            ;;
        --venues)
            VENUE_SCRAPE=true
            ;;
        --groupme-users)
            GROUPME_USERS=true
            ;;
        --groupme-schedule)
            GROUPME_SCHEDULE=true
            ;;
        --groupme-lighthouse)
            # Legacy flag - enable both for backward compatibility
            GROUPME_USERS=true
            GROUPME_SCHEDULE=true
            ;;
        --save)
            SAVE_MANUAL=true
            ;;
        --replay-only)
            REPLAY_ONLY=true
            ;;
        --help|-h)
            echo "Football Home Development Script"
            echo ""
            echo "Usage:"
            echo "  ./dev.sh                                   Full rebuild (uses saved SQL files)"
            echo ""
            echo "Scraping Flags:"
            echo "  --apsl                                     Full APSL scrape (structure + all players)"
            echo "  --apsl-structure                           Scrape APSL structure only (conferences/divisions/teams)"
            echo "  --apsl-players                             Alias for --apsl (Full scrape)"
            echo "  --apsl-lighthouse                          Scrape Lighthouse 1893 SC players only (plus structure)"
            echo "  --apsl-players-lighthouse                  Alias for --apsl-lighthouse"
            echo "  --casa-structure                           Scrape CASA structure (Liga 1 & 2 teams/standings/schedule)"
            echo "  --casa-lighthouse                          Scrape Lighthouse Boys Club + Old Timers (weekly)"
            echo "  --venues                                   Scrape Google Places venues (rarely needed)"
            echo ""
            echo "GroupMe Flags:"
            echo "  --groupme-users                            Sync GroupMe users to external_identities (weekly)"
            echo "  --groupme-schedule                         Import practices/games/RSVPs from GroupMe (weekly)"
            echo "  --groupme-lighthouse                       Legacy: enables both --groupme-users and --groupme-schedule"
            echo ""
            echo "Workflow Flags:"
            echo "  --save                                     Export manual edits before rebuild"
            echo "  --replay-only                              Fast rebuild from saved changes (~10sec)"
            echo ""
            echo "Examples:"
            echo "  ./dev.sh --apsl --casa-lighthouse --groupme-users --groupme-schedule --save"
            echo "    → New season: Full structure + All players + GroupMe sync"
            echo ""
            echo "  ./dev.sh --apsl-players-lighthouse --casa-lighthouse --groupme-users --groupme-schedule --save"
            echo "    → Weekly update: Lighthouse Player data + GroupMe sync"
            echo ""
            echo "  ./dev.sh --replay-only"
            echo "    → Daily development: Fast rebuild from saved state"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --apsl, --apsl-structure, --apsl-players, --apsl-lighthouse, --apsl-players-lighthouse, --casa-structure, --casa-lighthouse, --groupme-users, --groupme-schedule, --groupme-lighthouse, --venues, --save, --replay-only, --help"
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
if [ "$REPLAY_ONLY" = true ]; then
    echo "  ✓ Fast rebuild from saved replay file (98-audit-replay.sql)"
    echo "  ✓ Skip scraping, skip Docker rebuild, just restore database"
elif [ "$SAVE_MANUAL" = true ]; then
    echo "  ✓ Save manual edits from running database (if available)"
fi
if [ "$REPLAY_ONLY" = false ]; then
    echo "  ✓ Delete all containers and volumes"
    echo "  ✓ Clear Docker build cache"
    echo "  ✓ Rebuild all images (no cache)"
fi
if [ -n "$APSL_SCRAPE_MODE" ]; then
    echo "  ✓ Scrape APSL (Mode: $APSL_SCRAPE_MODE)"
fi
if [ -n "$CASA_SCRAPE_MODE" ]; then
    echo "  ✓ Scrape CASA (Mode: $CASA_SCRAPE_MODE)"
fi
if [ "$VENUE_SCRAPE" = true ]; then
    echo "  ✓ Scrape Google venues"
fi
if [ "$GROUPME_USERS" = true ]; then
    echo "  ✓ Sync GroupMe users to external_identities"
fi
if [ "$GROUPME_SCHEDULE" = true ]; then
    echo "  ✓ Import practices/games/RSVPs from GroupMe"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 0: SAVE MANUAL EDITS (before wiping database)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$SAVE_MANUAL" = true ]; then
    echo -e "${YELLOW}💾 Step 0: Exporting tracked changes from running database...${NC}"
    
    # Check if database container is running
    if docker compose ps | grep -q "footballhome_db.*running"; then
        if [ -f "scripts/export-audit-log.js" ]; then
            node scripts/export-audit-log.js
            echo -e "${GREEN}✓ Audit log exported to database/data/98-audit-replay.sql${NC}"
        else
            echo -e "${YELLOW}⚠ Export script not found: scripts/export-audit-log.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Database not running, skipping export (no data to preserve)${NC}"
    fi
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: SCRAPE (if requested, skip if replay-only)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$REPLAY_ONLY" = true ]; then
    echo -e "${YELLOW}⏭️  Skipping scrapers (replay-only mode)${NC}"
    echo ""
else
    # APSL Scraping (Single execution based on mode)
    if [ -n "$APSL_SCRAPE_MODE" ]; then
        echo -e "${YELLOW}📊 Step 1a: Scraping APSL (Mode: $APSL_SCRAPE_MODE)...${NC}"
        if [ -f "database/scripts/apsl-scraper/scrape-apsl.js" ]; then
            # Pass 'full' explicitly if mode is full, or the specific mode
            # The JS script treats anything other than 'structure' or 'lighthouse' as full
            node database/scripts/apsl-scraper/scrape-apsl.js "$APSL_SCRAPE_MODE"
            echo -e "${GREEN}✓ APSL scraping complete ($APSL_SCRAPE_MODE)${NC}"
        else
            echo -e "${YELLOW}⚠ Scraper not found: database/scripts/apsl-scraper/scrape-apsl.js, skipping.${NC}"
        fi
        echo ""
    fi

    # CASA Scraping (Single execution based on mode)
    if [ -n "$CASA_SCRAPE_MODE" ]; then
        echo -e "${YELLOW}📋 Step 1c: Scraping CASA (Mode: $CASA_SCRAPE_MODE)...${NC}"
        if [ -f "database/scripts/casa-scraper/scrape-casa.js" ]; then
            node database/scripts/casa-scraper/scrape-casa.js "$CASA_SCRAPE_MODE"
            echo -e "${GREEN}✓ CASA scraping complete ($CASA_SCRAPE_MODE)${NC}"
        else
            echo -e "${YELLOW}⚠ CASA scraper not found, skipping${NC}"
        fi
        echo ""
    fi

    # Venue Scraping
    if [ "$VENUE_SCRAPE" = true ]; then
        echo -e "${YELLOW}📍 Step 1d: Scraping Google Venues...${NC}"
        if [ -f "database/scripts/venue-scraper/scrape-google-venues.js" ]; then
            node database/scripts/venue-scraper/scrape-google-venues.js
            echo -e "${GREEN}✓ Venue scraping complete${NC}"
        else
            echo -e "${YELLOW}⚠ Venue scraper not found, skipping${NC}"
        fi
        echo ""
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1c: COPY TEST DATA (if requested)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# First, clean up any previous test data from data folder
rm -f database/data/99-*.sql

if [ "$TEST_DATA" = true ]; then
    echo -e "${YELLOW}🧪 Step 1c: Copying test data...${NC}"
    if [ -d "database/test-data" ]; then
        cp database/test-data/*.sql database/data/
        echo -e "${GREEN}✓ Test data files copied to database/data/${NC}"
    else
        echo -e "${YELLOW}⚠ No test-data folder found${NC}"
    fi
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: CLEAN EVERYTHING (skip Docker rebuild in replay-only)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$REPLAY_ONLY" = true ]; then
    echo -e "${YELLOW}🧹 Step 2: Wiping database only (keeping Docker images)...${NC}"
    docker compose down -v 2>/dev/null || true
    echo -e "${GREEN}✓ Database wiped${NC}"
    echo ""
else
    echo -e "${YELLOW}🧹 Step 2: Cleaning up...${NC}"
    docker compose down -v 2>/dev/null || true
    docker builder prune -af 2>/dev/null || true
    echo -e "${GREEN}✓ Cleanup complete${NC}"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: BUILD (skip in replay-only)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$REPLAY_ONLY" = false ]; then
    echo -e "${YELLOW}🔨 Step 3: Building images (no cache)...${NC}"
    docker compose build --no-cache
    echo -e "${GREEN}✓ Build complete${NC}"
    echo ""
else
    echo -e "${YELLOW}⏭️  Step 3: Skipping Docker build (replay-only mode)${NC}"
    echo ""
fi

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
# STEP 7: SYNC GROUPME USERS TO EXTERNAL_IDENTITIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$GROUPME_USERS" = true ]; then
    echo -e "${YELLOW}👥 Step 7a: Syncing GroupMe users to external_identities...${NC}"
    
    # Check if .env has GroupMe token
    if grep -q "GROUPME_ACCESS_TOKEN=" .env 2>/dev/null; then
        if [ -f "scripts/import-all-groupme-users.js" ]; then
            echo "  Importing users from all GroupMe groups..."
            node scripts/import-all-groupme-users.js lighthouse 2>&1 | sed 's/^/  /'
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ GroupMe users synced to external_identities${NC}"
            else
                echo -e "${YELLOW}⚠ GroupMe user sync completed with warnings${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ GroupMe user sync script not found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
        echo "  Add to .env: GROUPME_ACCESS_TOKEN=your-token"
        echo "  Get token from: https://dev.groupme.com/"
    fi
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 7B: IMPORT GROUPME SCHEDULE (PRACTICES/GAMES/RSVPS)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$GROUPME_SCHEDULE" = true ]; then
    echo -e "${YELLOW}📅 Step 7b: Importing GroupMe schedule (practices/games/RSVPs)...${NC}"
    
    # Check if .env has GroupMe token
    if grep -q "GROUPME_ACCESS_TOKEN=" .env 2>/dev/null; then
        GROUPME_GROUP_ID="108640377"  # Training Lighthouse chat
        
        if [ -f "scripts/import-groupme-practices.js" ]; then
            echo "  Importing practices/games and RSVPs from GroupMe..."
            node scripts/import-groupme-practices.js $GROUPME_GROUP_ID 2>&1 | sed 's/^/  /'
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ GroupMe schedule & RSVPs imported${NC}"
            else
                echo -e "${YELLOW}⚠ GroupMe schedule import completed with warnings${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ GroupMe schedule import script not found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
        echo "  Add to .env: GROUPME_ACCESS_TOKEN=your-token"
        echo "  Get token from: https://dev.groupme.com/"
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
echo "pgAdmin:   http://localhost:5050"
echo ""
echo "Login: soccer@lighthouse1893.org / 1893Soccer!"
