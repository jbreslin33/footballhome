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
#   ./dev.sh --apsl                               # All APSL data (structure + all teams + rosters + schedules)
#   ./dev.sh --casa                               # All CASA data (structure + all teams + rosters + schedules)
#   ./dev.sh --groupme                            # All GroupMe data (4 chats: Training, APSL, Boys Club, Old Timers)
#
# APSL Flags:
#   ./dev.sh --apsl-structure                     # APSL structure only (conferences/divisions, no teams)
#   ./dev.sh --apsl-teams                         # APSL teams (conferences/divisions/teams, no rosters)
#   ./dev.sh --apsl-players-lighthouse            # APSL Lighthouse 1893 SC roster only (creates Users/Players)
#   ./dev.sh --apsl-players                       # APSL all teams + all rosters (creates Users/Players for all)
#   ./dev.sh --apsl-schedule-lighthouse           # APSL Lighthouse 1893 SC game schedule only
#   ./dev.sh --apsl-schedule                      # APSL game schedules for all teams
#
# CASA Flags:
#   ./dev.sh --casa-structure                     # CASA structure only (teams/standings)
#   ./dev.sh --casa-players-lighthouse            # CASA Lighthouse teams only (creates Users/Players)
#
# GroupMe Flags:
#   ./dev.sh --groupme-apsl-external              # APSL Lighthouse chat → external_identities
#   ./dev.sh --groupme-apsl-schedule              # APSL Lighthouse chat: schedule
#   ./dev.sh --groupme-apsl-rsvps                 # APSL Lighthouse chat: RSVPs
#   ./dev.sh --groupme-training-lighthouse-external  # Training Lighthouse chat → external_identities (division context)
#   ./dev.sh --groupme-training-lighthouse-schedule  # Training Lighthouse chat: schedule
#   ./dev.sh --groupme-training-lighthouse-rsvps  # Training Lighthouse chat: RSVPs
#   ./dev.sh --groupme-boys-club-external         # Lighthouse Boys Club Liga 1 chat → external_identities
#   ./dev.sh --groupme-boys-club-schedule         # Lighthouse Boys Club Liga 1 game schedule
#   ./dev.sh --groupme-boys-club-rsvps            # Lighthouse Boys Club Liga 1 game RSVPs
#   ./dev.sh --groupme-old-timers-external        # Lighthouse Old Timers Club Liga 2 chat → external_identities
#   ./dev.sh --groupme-old-timers-schedule        # Lighthouse Old Timers Club Liga 2 game schedule
#   ./dev.sh --groupme-old-timers-rsvps           # Lighthouse Old Timers Club Liga 2 game RSVPs
#   ./dev.sh --venues                             # Scrape Google Places venues
#   ./dev.sh --save                               # Export manual edits before rebuild
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
    DOCKER_COMPOSE="sudo docker compose --env-file env"
else
    # Docker works without sudo
    DOCKER="docker"
    DOCKER_COMPOSE="docker compose --env-file env"
fi

APSL_SCRAPE_MODE=""
APSL_SCHEDULE=false
CASA_SCRAPE_MODE=""
VENUE_SCRAPE=false
GROUPME_APSL_EXTERNAL=false
GROUPME_APSL_SCHEDULE=false
GROUPME_APSL_RSVPS=false
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
ENVIRONMENT="dev"
WIPE_U=false
WIPE_P=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --lighthouse)
            # Convenience flag: All Lighthouse data (structure + rosters + GroupMe)
            APSL_SCRAPE_MODE="structure"
            APSL_SCHEDULE=true
            if [ "$APSL_SCRAPE_MODE" != "FULL" ]; then
                APSL_SCRAPE_MODE="lighthouse"
            fi
            CASA_SCRAPE_MODE="structure"
            if [ "$CASA_SCRAPE_MODE" != "full" ]; then
                CASA_SCRAPE_MODE="lighthouse"
            fi
            GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL=true
            GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE=true
            GROUPME_TRAINING_LIGHTHOUSE_RSVPS=true
            GROUPME_BOYS_CLUB_EXTERNAL=true
            GROUPME_BOYS_CLUB_SCHEDULE=true
            GROUPME_BOYS_CLUB_RSVPS=true
            GROUPME_OLD_TIMERS_EXTERNAL=true
            GROUPME_OLD_TIMERS_SCHEDULE=true
            GROUPME_OLD_TIMERS_RSVPS=true
            ;;
        --groupme)
            # All GroupMe data for all Lighthouse chats
            GROUPME_APSL_EXTERNAL=true
            GROUPME_APSL_SCHEDULE=true
            GROUPME_APSL_RSVPS=true
            GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL=true
            GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE=true
            GROUPME_TRAINING_LIGHTHOUSE_RSVPS=true
            GROUPME_BOYS_CLUB_EXTERNAL=true
            GROUPME_BOYS_CLUB_SCHEDULE=true
            GROUPME_BOYS_CLUB_RSVPS=true
            GROUPME_OLD_TIMERS_EXTERNAL=true
            GROUPME_OLD_TIMERS_SCHEDULE=true
            GROUPME_OLD_TIMERS_RSVPS=true
            ;;
        --apsl)
            # Full APSL scrape: all teams + rosters + schedules
            APSL_SCRAPE_MODE="players"
            APSL_SCHEDULE=true
            ;;
        --apsl-players)
            # All teams + all rosters (no schedule)
            if [ "$APSL_SCRAPE_MODE" != "players" ]; then
                APSL_SCRAPE_MODE="players"
            fi
            ;;
        --apsl-structure)
            # Only set if not already set to a more inclusive mode
            if [ "$APSL_SCRAPE_MODE" != "players" ] && [ "$APSL_SCRAPE_MODE" != "lighthouse" ] && [ "$APSL_SCRAPE_MODE" != "teams" ]; then
                APSL_SCRAPE_MODE="structure"
            fi
            ;;
        --apsl-teams)
            # Only set if not already set to a more inclusive mode
            if [ "$APSL_SCRAPE_MODE" != "players" ] && [ "$APSL_SCRAPE_MODE" != "lighthouse" ]; then
                APSL_SCRAPE_MODE="teams"
            fi
            ;;
        --apsl-players-lighthouse|--apsl-lighthouse)
            # Only set if not already set to players mode
            if [ "$APSL_SCRAPE_MODE" != "players" ]; then
                APSL_SCRAPE_MODE="lighthouse"
            fi
            ;;
        --apsl-schedule-lighthouse)
            APSL_SCHEDULE=true
            APSL_SCHEDULE_MODE="lighthouse"
            ;;
        --apsl-schedule)
            APSL_SCHEDULE=true
            ;;
        --casa|--casa-players)
            # Full CASA scrape (all teams + rosters)
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
        --groupme-apsl-external)
            GROUPME_APSL_EXTERNAL=true
            ;;
        --groupme-apsl-schedule)
            GROUPME_APSL_SCHEDULE=true
            ;;
        --groupme-apsl-rsvps)
            GROUPME_APSL_RSVPS=true
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
            echo "Environment Flags:"
            echo "  --production                               Build in production mode (loads ##p files instead of ##u)"
            echo "  --wipe-u                                   Delete all ##u-*-app.sql files (dev data) before rebuild"
            echo "  --wipe-p                                   Delete all ##p-*-app.sql files (production data) before rebuild"
            echo ""
            echo "Aggregate Flags (Convenience):"
            echo "  --lighthouse                               All Lighthouse data (APSL/CASA structure + rosters + schedules + GroupMe)"
            echo "  --apsl                                     All APSL data (structure + all teams + rosters + schedules)"
            echo "  --casa                                     All CASA data (structure + all teams + rosters)"
            echo "  --groupme                                  All GroupMe data (all 4 Lighthouse chats)"
            echo ""
            echo "APSL Scraping Flags:"
            echo "  --apsl-structure                           Scrape APSL structure only (conferences/divisions, no teams)"
            echo "  --apsl-teams                               Scrape APSL teams (conferences/divisions/teams, no rosters)"
            echo "  --apsl-players-lighthouse                  Scrape Lighthouse 1893 SC roster only"
            echo "  --apsl-players                             Scrape all teams + all rosters (creates Users/Players)"
            echo "  --apsl-schedule-lighthouse                 Scrape Lighthouse 1893 SC game schedule only"
            echo "  --apsl-schedule                            Scrape APSL game schedules for all teams"
            echo ""
            echo "CASA Scraping Flags:"
            echo "  --casa-structure                           Scrape CASA structure (Liga 1 & 2 teams/standings/schedule)"
            echo "  --casa-players-lighthouse                  Scrape Lighthouse Boys Club Liga 1 + Old Timers Club Liga 2 rosters"
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
            echo "  --save                                     Export manual edits before rebuild"
            echo ""
            echo "Examples:"
            echo "  ./dev.sh --apsl --casa --save"
            echo "    → New season: Full APSL + Full CASA scrape"
            echo ""
            echo "  ./dev.sh --apsl-players-lighthouse --casa-players-lighthouse --groupme-training-lighthouse-external --groupme-training-lighthouse-schedule --save"
            echo "    → Weekly update: Lighthouse rosters + Training chat sync"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --lighthouse, --apsl, --apsl-structure, --apsl-teams, --apsl-players, --apsl-lighthouse, --apsl-players-lighthouse, --apsl-schedule-lighthouse, --apsl-schedule, --casa, --casa-players, --casa-structure, --casa-players-lighthouse, --groupme, --groupme-apsl-external, --groupme-apsl-schedule, --groupme-apsl-rsvps, --groupme-training-lighthouse-external, --groupme-training-lighthouse-schedule, --groupme-training-lighthouse-rsvps, --groupme-boys-club-external, --groupme-boys-club-schedule, --groupme-boys-club-rsvps, --groupme-old-timers-external, --groupme-old-timers-schedule, --groupme-old-timers-rsvps, --venues, --save, --help"
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
if [ "$SAVE_MANUAL" = true ]; then
    echo "  ✓ Save manual edits from running database (if available)"
fi
echo "  ✓ Delete all containers and volumes (fresh database)"
echo "  ✓ Clear Docker build cache"
echo "  ✓ Rebuild all images (no cache)"
echo "  ✓ All database init scripts will run (including admin data)"
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
if [ "$GROUPME_APSL_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: APSL Lighthouse users → external_identities"
fi
if [ "$GROUPME_APSL_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: APSL Lighthouse schedule"
fi
if [ "$GROUPME_APSL_RSVPS" = true ]; then
    echo "  ✓ GroupMe: APSL Lighthouse RSVPs"
fi
if [ "$GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: Training Lighthouse users → external_identities"
fi
if [ "$GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: Training chat schedule"
fi
if [ "$GROUPME_TRAINING_LIGHTHOUSE_RSVPS" = true ]; then
    echo "  ✓ GroupMe: Training chat RSVPs"
fi
if [ "$GROUPME_BOYS_CLUB_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: Lighthouse Boys Club Liga 1 users → external_identities"
fi
if [ "$GROUPME_BOYS_CLUB_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: Lighthouse Boys Club Liga 1 schedule"
fi
if [ "$GROUPME_BOYS_CLUB_RSVPS" = true ]; then
    echo "  ✓ GroupMe: Lighthouse Boys Club Liga 1 RSVPs"
fi
if [ "$GROUPME_OLD_TIMERS_EXTERNAL" = true ]; then
    echo "  ✓ GroupMe: Lighthouse Old Timers Club Liga 2 users → external_identities"
fi
if [ "$GROUPME_OLD_TIMERS_SCHEDULE" = true ]; then
    echo "  ✓ GroupMe: Lighthouse Old Timers Club Liga 2 schedule"
fi
if [ "$GROUPME_OLD_TIMERS_RSVPS" = true ]; then
    echo "  ✓ GroupMe: Lighthouse Old Timers Club Liga 2 RSVPs"
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
        
        # Build command with options
        CMD="node database/scripts/index.js apsl $MODE_LOWER"
        
        # Add --schedules if requested
        if [ "$APSL_SCHEDULE" = true ]; then
            CMD="$CMD --schedules"
        fi
        
        # Add --team filter if lighthouse mode
        if [ "$APSL_SCRAPE_MODE" = "LIGHTHOUSE" ]; then
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
        if [ "$CASA_SCRAPE_MODE" = "LIGHTHOUSE" ]; then
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
$DOCKER_COMPOSE down -v 2>/dev/null || true
echo "  ✓ Clearing Docker build cache..."
$DOCKER builder prune -af 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup complete (fresh start guaranteed)${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2.5: WIPE APP DATA (if requested)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$WIPE_U" = true ]; then
    echo -e "${YELLOW}🗑️  Wiping dev app data (##u files)...${NC}"
    rm -f database/data/*u-*-app.sql
    # Recreate empty placeholders
    for num in 08 21 22 23 24 25 30; do
        cat > "database/data/${num}u-"*"-app.sql" 2>/dev/null || true
    done
    echo -e "${GREEN}✓ Dev app data wiped${NC}"
    echo ""
fi

if [ "$WIPE_P" = true ]; then
    echo -e "${YELLOW}🗑️  Wiping production app data (##p files)...${NC}"
    rm -f database/data/*p-*-app.sql
    # Recreate empty placeholders
    for num in 08 21 22 23 24 25 30; do
        cat > "database/data/${num}p-"*"-app.sql" 2>/dev/null || true
    done
    echo -e "${GREEN}✓ Production app data wiped${NC}"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: BUILD (ALWAYS)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🔨 Step 3: Building images (no cache)...${NC}"
$DOCKER_COMPOSE build --no-cache
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
    if [ "$($DOCKER_COMPOSE ps db --status running -q 2>/dev/null | wc -l)" -eq 1 ]; then
        DB_HEALTH=$($DOCKER_COMPOSE ps db --format json 2>/dev/null | grep -o '"Health":"[^"]*"' | cut -d'"' -f4 || echo "starting")
        if [ "$DB_HEALTH" = "healthy" ]; then
            echo -e " ${GREEN}✓ Healthy (${i}s)${NC}"
            break
        fi
    fi
    echo -n "."
    sleep 1
    if [ "$i" -eq 120 ]; then
        echo -e " ${RED}✗ Timeout${NC}"
        $DOCKER_COMPOSE logs db | tail -20
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

# Check GroupMe token once for all operations
GROUPME_TOKEN_EXISTS=false
if grep -q "GROUPME_ACCESS_TOKEN=" env 2>/dev/null; then
    GROUPME_TOKEN_EXISTS=true
fi

# ──────────────────────────────────────────────────────────────────
# APSL Lighthouse Chat (OOP) - Group ID: 109785985
# ──────────────────────────────────────────────────────────────────
if [ "$GROUPME_APSL_EXTERNAL" = true ] || [ "$GROUPME_APSL_SCHEDULE" = true ] || [ "$GROUPME_APSL_RSVPS" = true ]; then
    echo -e "${YELLOW}💬 Step 7a: APSL Lighthouse Chat...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        # Single command imports users, schedule, and RSVPs
        CMD="node database/scripts/index.js groupme-apsl full"
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ APSL Lighthouse chat imported (users, schedule, RSVPs)${NC}"
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env${NC}"
    fi
    echo ""
fi

# ──────────────────────────────────────────────────────────────────
# Training Lighthouse Chat (OOP) - Group ID: 108640377
# Division-wide training (all Lighthouse 1893 SC teams)
# ──────────────────────────────────────────────────────────────────
if [ "$GROUPME_TRAINING_LIGHTHOUSE_EXTERNAL" = true ] || [ "$GROUPME_TRAINING_LIGHTHOUSE_SCHEDULE" = true ] || [ "$GROUPME_TRAINING_LIGHTHOUSE_RSVPS" = true ]; then
    echo -e "${YELLOW}💬 Step 7b: Training Lighthouse Chat...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        # Single command imports users, schedule, and RSVPs
        CMD="node database/scripts/index.js groupme-training full"
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ Training Lighthouse chat imported (users, schedule, RSVPs)${NC}"
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env${NC}"
    fi
    echo ""
fi

# ──────────────────────────────────────────────────────────────────
# Lighthouse Boys Club Liga 1 Chat (OOP) - Group ID: 109786182
# ──────────────────────────────────────────────────────────────────
if [ "$GROUPME_BOYS_CLUB_EXTERNAL" = true ] || [ "$GROUPME_BOYS_CLUB_SCHEDULE" = true ] || [ "$GROUPME_BOYS_CLUB_RSVPS" = true ]; then
    echo -e "${YELLOW}💬 Step 7c: Lighthouse Boys Club Liga 1 Chat...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        # Single command imports users, schedule, and RSVPs
        CMD="node database/scripts/index.js groupme-boys-club full"
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ Lighthouse Boys Club Liga 1 chat imported (users, schedule, RSVPs)${NC}"
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env${NC}"
    fi
    echo ""
fi

# Lighthouse Boys Club Liga 1 Chat - Schedule
if [ "$GROUPME_BOYS_CLUB_SCHEDULE" = true ]; then
    echo -e "${YELLOW}📅 Step 7e: Lighthouse Boys Club Liga 1 - Schedule...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-boys-club-schedule.js" ]; then
            echo "  Importing Lighthouse Boys Club Liga 1 game schedule..."
            node scripts/import-groupme-boys-club-schedule.js
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Lighthouse Boys Club Liga 1 schedule imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-boys-club-schedule.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env${NC}"
    fi
    echo ""
fi

# Lighthouse Boys Club Liga 1 Chat - RSVPs
if [ "$GROUPME_BOYS_CLUB_RSVPS" = true ]; then
    echo -e "${YELLOW}✅ Step 7f: Lighthouse Boys Club Liga 1 - RSVPs...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        if [ -f "scripts/import-groupme-boys-club-rsvps.js" ]; then
            echo "  Importing Lighthouse Boys Club Liga 1 game RSVPs..."
            node scripts/import-groupme-boys-club-rsvps.js 2>&1 | sed 's/^/  /'
            [ $? -eq 0 ] && echo -e "${GREEN}✓ Lighthouse Boys Club Liga 1 RSVPs imported${NC}" || echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        else
            echo -e "${YELLOW}⚠ Script not found: scripts/import-groupme-boys-club-rsvps.js${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env${NC}"
    fi
    echo ""
fi

# ──────────────────────────────────────────────────────────────────
# Lighthouse Old Timers Club Liga 2 Chat (OOP) - Group ID: 109786278
# ──────────────────────────────────────────────────────────────────
if [ "$GROUPME_OLD_TIMERS_EXTERNAL" = true ] || [ "$GROUPME_OLD_TIMERS_SCHEDULE" = true ] || [ "$GROUPME_OLD_TIMERS_RSVPS" = true ]; then
    echo -e "${YELLOW}💬 Step 7d: Lighthouse Old Timers Club Liga 2 Chat...${NC}"
    if [ "$GROUPME_TOKEN_EXISTS" = true ]; then
        # Single command imports users, schedule, and RSVPs
        CMD="node database/scripts/index.js groupme-old-timers full"
        echo "  Running: $CMD"
        $CMD
        echo -e "${GREEN}✓ Lighthouse Old Timers Club Liga 2 chat imported (users, schedule, RSVPs)${NC}"
    else
        echo -e "${YELLOW}⚠ GROUPME_ACCESS_TOKEN not set in env${NC}"
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
