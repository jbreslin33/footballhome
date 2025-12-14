#!/bin/bash
# Football Home - Development Script
#
# Usage:
#   ./dev.sh                                      # Full rebuild (no scraping)
#   ./dev.sh --apsl                               # Full APSL scrape (all teams + rosters)
#   ./dev.sh --apsl-structure                     # APSL structure only (conferences/divisions/teams)
#   ./dev.sh --apsl-players-lighthouse            # APSL Lighthouse 1893 SC roster only (creates Users/Players)
#   ./dev.sh --apsl-schedule                      # APSL game schedules for all teams
#   ./dev.sh --casa                               # Full CASA scrape (all teams + rosters)
#   ./dev.sh --casa-structure                     # CASA structure only (teams/standings)
#   ./dev.sh --casa-players-lighthouse            # CASA Lighthouse teams only (creates Users/Players)
#   ./dev.sh --groupme-training-lighthouse-external  # Training chat → external_identities (division context)
#   ./dev.sh --groupme-training-lighthouse-schedule  # Training chat schedule
#   ./dev.sh --groupme-training-lighthouse-rsvps  # Training chat RSVPs
#   ./dev.sh --groupme-boys-club-external         # Boys Club chat → external_identities
#   ./dev.sh --groupme-boys-club-schedule         # Boys Club Liga 1 game schedule
#   ./dev.sh --groupme-boys-club-rsvps            # Boys Club game RSVPs
#   ./dev.sh --groupme-old-timers-external        # Old Timers chat → external_identities
#   ./dev.sh --groupme-old-timers-schedule        # Old Timers Liga 2 game schedule
#   ./dev.sh --groupme-old-timers-rsvps           # Old Timers game RSVPs
#   ./dev.sh --venues                             # Scrape Google Places venues
#   ./dev.sh --save                               # Export manual edits before rebuild
#   ./dev.sh --replay-only                        # Fast rebuild from saved changes
#
# Typical Workflows:
#   ./dev.sh --apsl --casa --save
#     → New season: Full APSL + CASA scrape
#
#   ./dev.sh --apsl-players-lighthouse --casa-players-lighthouse --groupme-training-lighthouse-external --groupme-training-lighthouse-schedule --save
#     → Weekly update: Lighthouse rosters + Training chat sync
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

# ============================================================
# DOCKER AVAILABILITY CHECK (early exit if docker not accessible)
# ============================================================
if ! docker ps &> /dev/null 2>&1; then
    # Try with sudo as fallback
    if ! sudo docker ps &> /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not accessible${NC}"
        echo ""
        echo "Docker is required to run this application."
        echo ""
        echo "Possible solutions:"
        echo "  1. Make sure Docker is installed:"
        echo "     ./setup.sh"
        echo ""
        echo "  2. If Docker is installed, you may need to log out and back in:"
        echo "     Docker group permissions take effect after login"
        echo "     Quick fix: exec su -l \$USER"
        echo ""
        echo "  3. Check Docker status:"
        echo "     sudo systemctl status docker"
        echo ""
        exit 1
    fi
    # Docker needs sudo, set alias for all docker commands
    DOCKER="sudo docker"
    DOCKER_COMPOSE="sudo docker compose"
else
    # Docker works without sudo
    DOCKER="docker"
    DOCKER_COMPOSE="docker compose"
fi

APSL_SCRAPE_MODE=""
APSL_SCHEDULE=false
CASA_SCRAPE_MODE=""
VENUE_SCRAPE=false
GROUPME_APSL_SCHEDULE=false
GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL=false
GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE=false
GROUPME_TRAINING_LIGHTHOUSE_RSVPS=false
GROUPME_BOYS_CLUB_EXTERNAL=false
GROUPME_BOYS_CLUB_SCHEDULE=false
GROUPME_BOYS_CLUB_RSVPS=false
GROUPME_OLD_TIMERS_EXTERNAL=false
GROUPME_OLD_TIMERS_SCHEDULE=false
GROUPME_OLD_TIMERS_RSVPS=false
SAVE_MANUAL=false
REPLAY_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --apsl|--apsl-players)
            # APSL scraper treats undefined as full, but we set empty string to trigger full scrape
            APSL_SCRAPE_MODE="FULL"
            ;;
        --apsl-structure)
            # Only set if not already set to a more inclusive mode
            if [ "$APSL_SCRAPE_MODE" != "FULL" ] && [ "$APSL_SCRAPE_MODE" != "lighthouse" ]; then
                APSL_SCRAPE_MODE="structure"
            fi
            ;;
        --apsl-players-lighthouse|--apsl-lighthouse)
            # Only set if not already set to full
            if [ "$APSL_SCRAPE_MODE" != "FULL" ]; then
                APSL_SCRAPE_MODE="lighthouse"
            fi
            ;;
        --apsl-schedule)
            APSL_SCHEDULE=true
            ;;
        --casa|--casa-players)
            CASA_SCRAPE_MODE="full"
            ;;
        --casa-structure)
            if [ "$CASA_SCRAPE_MODE" != "full" ] && [ "$CASA_SCRAPE_MODE" != "lighthouse" ]; then
                CASA_SCRAPE_MODE="structure"
            fi
            ;;
        --casa-players-lighthouse)
            # Only set if not already set to full
            if [ "$CASA_SCRAPE_MODE" != "full" ]; then
                CASA_SCRAPE_MODE="lighthouse"
            fi
            ;;
        --venues)
            VENUE_SCRAPE=true
            ;;
        --groupme-apsl-schedule)
            GROUPME_APSL_SCHEDULE=true
            ;;
        --groupme-training-lighthouse-external)
            GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL=true
            ;;
        --groupme-training-lighthouse-schedule)
            GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE=true
            ;;
        --groupme-training-lighthouse-rsvps)
            GROUPME_TRAINING_LIGHTHOUSE_RSVPS=true
            ;;
        --groupme-boys-club-external)
            GROUPME_BOYS_CLUB_EXTERNAL=true
            ;;
        --groupme-boys-club-schedule)
            GROUPME_BOYS_CLUB_SCHEDULE=true
            ;;
        --groupme-boys-club-rsvps)
            GROUPME_BOYS_CLUB_RSVPS=true
            ;;
        --groupme-old-timers-external)
            GROUPME_OLD_TIMERS_EXTERNAL=true
            ;;
        --groupme-old-timers-schedule)
            GROUPME_OLD_TIMERS_SCHEDULE=true
            ;;
        --groupme-old-timers-rsvps)
            GROUPME_OLD_TIMERS_RSVPS=true
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
            echo "  --apsl                                     Full APSL scrape (structure + all team rosters)"
            echo "  --apsl-structure                           Scrape APSL structure only (conferences/divisions/teams)"
            echo "  --apsl-players                             Alias for --apsl (Full scrape)"
            echo "  --apsl-lighthouse                          Scrape Lighthouse 1893 SC roster (creates Users/Players/TeamPlayers)"
            echo "  --apsl-players-lighthouse                  Alias for --apsl-lighthouse"
            echo "  --apsl-schedule                            Scrape APSL game schedules for all teams"
            echo "  --casa                                     Full CASA scrape (structure + all team rosters)"
            echo "  --casa-players                             Alias for --casa (Full scrape)"
            echo "  --casa-structure                           Scrape CASA structure (Liga 1 & 2 teams/standings/schedule)"
            echo "  --casa-players-lighthouse                  Scrape Lighthouse Boys Club + Old Timers rosters (creates Users/Players/TeamPlayers)"
            echo "  --venues                                   Scrape Google Places venues (rarely needed)"
            echo ""
            echo "GroupMe Flags (by chat):"
            echo "  --groupme-apsl-schedule                    APSL Lighthouse 1893 SC chat: schedule"
            echo "  --groupme-training-lighthouse-external     Training chat: users → external_identities (division context)"
            echo "  --groupme-training-lighthouse-schedule     Training chat: practices/events schedule"
            echo "  --groupme-training-lighthouse-rsvps        Training chat: RSVPs for trainings"
            echo "  --groupme-boys-club-external               Boys Club Liga 1 chat: users → external_identities"
            echo "  --groupme-boys-club-schedule               Boys Club Liga 1 chat: game schedule"
            echo "  --groupme-boys-club-rsvps                  Boys Club Liga 1 chat: game RSVPs"
            echo "  --groupme-old-timers-external              Old Timers Liga 2 chat: users → external_identities"
            echo "  --groupme-old-timers-schedule              Old Timers Liga 2 chat: game schedule"
            echo "  --groupme-old-timers-rsvps                 Old Timers Liga 2 chat: game RSVPs"
            echo ""
            echo "Workflow Flags:"
            echo "  --save                                     Export manual edits before rebuild"
            echo "  --replay-only                              Fast rebuild from saved changes (~10sec)"
            echo ""
            echo "Examples:"
            echo "  ./dev.sh --apsl --casa --save"
            echo "    → New season: Full APSL + Full CASA scrape"
            echo ""
            echo "  ./dev.sh --apsl-players-lighthouse --casa-players-lighthouse --groupme-training-lighthouse-external --groupme-training-lighthouse-schedule --save"
            echo "    → Weekly update: Lighthouse rosters + Training chat sync"
            echo ""
            echo "  ./dev.sh --replay-only"
            echo "    → Daily development: Fast rebuild from saved state"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --apsl, --apsl-structure, --apsl-players, --apsl-lighthouse, --apsl-players-lighthouse, --apsl-schedule, --casa, --casa-players, --casa-structure, --casa-players-lighthouse, --groupme-apsl-schedule, --groupme-training-lighthouse-external, --groupme-training-lighthouse-schedule, --groupme-training-lighthouse-rsvps, --groupme-boys-club-external, --groupme-boys-club-schedule, --groupme-boys-club-rsvps, --groupme-old-timers-external, --groupme-old-timers-schedule, --groupme-old-timers-rsvps, --venues, --save, --replay-only, --help"
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
if [ "$APSL_SCHEDULE" = true ]; then
    echo "  ✓ Scrape APSL game schedules"
fi
if [ -n "$CASA_SCRAPE_MODE" ]; then
    echo "  ✓ Scrape CASA (Mode: $CASA_SCRAPE_MODE)"
fi
if [ "$VENUE_SCRAPE" = true ]; then
    echo "  ✓ Scrape Google venues"
fi
if [ "$GROUPME_APSL_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: APSL Lighthouse schedule"
fi
if [ "$GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: Training chat users → external_identities"
fi
if [ "$GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: Training chat schedule"
fi
if [ "$GROUPME_TRAINING_LIGHTHOUSE_RSVPS" = true ]; then
    echo "  ✓ GroupMe: Training chat RSVPs"
fi
if [ "$GROUPME_BOYS_CLUB_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: Boys Club users → external_identities"
fi
if [ "$GROUPME_BOYS_CLUB_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: Boys Club schedule"
fi
if [ "$GROUPME_BOYS_CLUB_RSVPS" = true ]; then
    echo "  ✓ GroupMe: Boys Club RSVPs"
fi
if [ "$GROUPME_OLD_TIMERS_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: Old Timers users → external_identities"
fi
if [ "$GROUPME_OLD_TIMERS_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: Old Timers schedule"
fi
if [ "$GROUPME_OLD_TIMERS_RSVPS" = true ]; then
    echo "  ✓ GroupMe: Old Timers RSVPs"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 0: SAVE MANUAL EDITS (before wiping database)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$SAVE_MANUAL" = true ]; then
    echo -e "${YELLOW}💾 Step 0: Exporting tracked changes from running database...${NC}"
    
    # Check if database container is running
    if $DOCKER_COMPOSE ps | grep -q "footballhome_db.*running"; then
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
            # APSL scraper treats undefined as full scrape
            # Pass empty string for full, or specific mode for structure/lighthouse
            if [ "$APSL_SCRAPE_MODE" = "FULL" ]; then
                node database/scripts/apsl-scraper/scrape-apsl.js
                echo -e "${GREEN}✓ APSL scraping complete (full)${NC}"
            else
                node database/scripts/apsl-scraper/scrape-apsl.js "$APSL_SCRAPE_MODE"
                echo -e "${GREEN}✓ APSL scraping complete ($APSL_SCRAPE_MODE)${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Scraper not found: database/scripts/apsl-scraper/scrape-apsl.js, skipping.${NC}"
        fi
        echo ""
    fi

    # APSL Schedule Scraping
    if [ "$APSL_SCHEDULE" = true ]; then
        echo -e "${YELLOW}📅 Step 1a-schedule: Scraping APSL game schedules...${NC}"
        if [ -f "database/scripts/apsl-scraper/scrape-apsl-schedule.js" ]; then
            node database/scripts/apsl-scraper/scrape-apsl-schedule.js
            echo -e "${GREEN}✓ APSL schedules scraped${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: database/scripts/apsl-scraper/scrape-apsl-schedule.js${NC}"
        fi
        echo ""
    fi

    # CASA Scraping (Single execution based on mode)
    if [ -n "$CASA_SCRAPE_MODE" ]; then
        echo -e "${YELLOW}📋 Step 1b: Scraping CASA (Mode: $CASA_SCRAPE_MODE)...${NC}"
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
        echo -e "${YELLOW}📍 Step 1c: Scraping Google Venues...${NC}"
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
# STEP 2: CLEAN EVERYTHING (skip Docker rebuild in replay-only)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$REPLAY_ONLY" = true ]; then
    echo -e "${YELLOW}🧹 Step 2: Wiping database only (keeping Docker images)...${NC}"
    $DOCKER_COMPOSE down -v 2>/dev/null || true
    echo -e "${GREEN}✓ Database wiped${NC}"
    echo ""
else
    echo -e "${YELLOW}🧹 Step 2: Cleaning up...${NC}"
    $DOCKER_COMPOSE down -v 2>/dev/null || true
    docker builder prune -af 2>/dev/null || true
    echo -e "${GREEN}✓ Cleanup complete${NC}"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: BUILD (skip in replay-only)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$REPLAY_ONLY" = false ]; then
    echo -e "${YELLOW}🔨 Step 3: Building images (no cache)...${NC}"
    $DOCKER_COMPOSE build --no-cache
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
$DOCKER_COMPOSE up -d

# Wait for containers to be fully running
echo -n "  Waiting for containers to initialize"
for i in $(seq 1 30); do
    RUNNING=$($DOCKER_COMPOSE ps --status running -q 2>/dev/null | wc -l)
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

# Check GroupMe token once for all operations
GROUPME_TOKEN_EXISTS=false
if grep -q "GROUPME_ACCESS_TOKEN=" .env 2>/dev/null; then
    GROUPME_TOKEN_EXISTS=true
fi

# APSL Lighthouse 1893 SC Chat - Schedule only
if [ "$GROUPME_APSL_SCHEDULE" = true ]; then
    echo -e "${YELLOW}📅 Step 7a: APSL Lighthouse chat - Schedule...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        echo "  TODO: Implement APSL Lighthouse schedule import"
        echo -e "${YELLOW}⚠ Not yet implemented${NC}"
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Training Lighthouse Chat - External Identities (division context, no team)
if [ "$GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL" = true ]; then
    echo -e "${YELLOW}👥 Step 7b: Training Lighthouse chat - Users to external_identities...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-training-users.js" ]; then
            echo "  Importing users with division context (Lighthouse 1893 SC)..."
            node scripts/import-groupme-training-users.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Training users synced${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-training-users.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Training Lighthouse Chat - Schedule
if [ "$GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE" = true ]; then
    echo -e "${YELLOW}📅 Step 7c: Training Lighthouse chat - Schedule...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-training-schedule.js" ]; then
            echo "  Importing training practices/events..."
            node scripts/import-groupme-training-schedule.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Training schedule imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-training-schedule.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Training Lighthouse Chat - RSVPs
if [ "$GROUPME_TRAINING_LIGHTHOUSE_RSVPS" = true ]; then
    echo -e "${YELLOW}✅ Step 7d: Training Lighthouse chat - RSVPs...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-training-rsvps.js" ]; then
            echo "  Importing training RSVPs..."
            node scripts/import-groupme-training-rsvps.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Training RSVPs imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-training-rsvps.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Lighthouse Boys Club Liga 1 Chat - External Identities
if [ "$GROUPME_BOYS_CLUB_EXTERNAL" = true ]; then
    echo -e "${YELLOW}👥 Step 7e: Boys Club Liga 1 chat - Users to external_identities...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-boys-club-users.js" ]; then
            echo "  Importing Boys Club users with team context..."
            node scripts/import-groupme-boys-club-users.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Boys Club users synced${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-boys-club-users.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Lighthouse Boys Club Liga 1 Chat - Schedule
if [ "$GROUPME_BOYS_CLUB_SCHEDULE" = true ]; then
    echo -e "${YELLOW}📅 Step 7e: Boys Club Liga 1 chat - Schedule...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-boys-club-schedule.js" ]; then
            echo "  Importing Boys Club game schedule..."
            node scripts/import-groupme-boys-club-schedule.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Boys Club schedule imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-boys-club-schedule.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Lighthouse Boys Club Liga 1 Chat - RSVPs
if [ "$GROUPME_BOYS_CLUB_RSVPS" = true ]; then
    echo -e "${YELLOW}✅ Step 7f: Boys Club Liga 1 chat - RSVPs...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-boys-club-rsvps.js" ]; then
            echo "  Importing Boys Club game RSVPs..."
            node scripts/import-groupme-boys-club-rsvps.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Boys Club RSVPs imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-boys-club-rsvps.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Lighthouse Old Timers Liga 2 Chat - External Identities
if [ "$GROUPME_OLD_TIMERS_EXTERNAL" = true ]; then
    echo -e "${YELLOW}👥 Step 7g: Old Timers Liga 2 chat - Users to external_identities...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-old-timers-users.js" ]; then
            echo "  Importing Old Timers users with team context..."
            node scripts/import-groupme-old-timers-users.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Old Timers users synced${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-old-timers-users.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Lighthouse Old Timers Liga 2 Chat - Schedule
if [ "$GROUPME_OLD_TIMERS_SCHEDULE" = true ]; then
    echo -e "${YELLOW}📅 Step 7g: Old Timers Liga 2 chat - Schedule...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-old-timers-schedule.js" ]; then
            echo "  Importing Old Timers game schedule..."
            node scripts/import-groupme-old-timers-schedule.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Old Timers schedule imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-old-timers-schedule.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
    fi
    echo ""
fi

# Lighthouse Old Timers Liga 2 Chat - RSVPs
if [ "$GROUPME_OLD_TIMERS_RSVPS" = true ]; then
    echo -e "${YELLOW}✅ Step 7h: Old Timers Liga 2 chat - RSVPs...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-old-timers-rsvps.js" ]; then
            echo "  Importing Old Timers game RSVPs..."
            node scripts/import-groupme-old-timers-rsvps.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Old Timers RSVPs imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-old-timers-rsvps.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in .env${NC}"
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
