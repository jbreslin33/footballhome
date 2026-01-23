#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home - Build Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Rebuilds containers and loads database schema.
# Does NOT scrape data - use update.sh for that.
#
# Usage:
#   ./build.sh              Full rebuild (destroys volumes)
#   ./build.sh --backend    Rebuild backend only (fast iteration)
#
# After building, populate data with:
#   ./update.sh
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
# PODMAN AVAILABILITY CHECK
# ============================================================
if podman ps &> /dev/null 2>&1; then
    DOCKER="podman"
    if command -v podman-compose &> /dev/null; then
        DOCKER_COMPOSE="podman-compose --env-file env"
    else
        DOCKER_COMPOSE="docker-compose --env-file env"
    fi
elif sudo podman ps &> /dev/null 2>&1; then
    DOCKER="sudo podman"
    if command -v podman-compose &> /dev/null; then
        DOCKER_COMPOSE="sudo podman-compose --env-file env"
    else
        DOCKER_COMPOSE="sudo docker-compose --env-file env"
    fi
else
    echo -e "${RED}Error: Podman is not accessible${NC}"
    echo ""
    echo "Podman is required. Install with: ./setup.sh"
    echo ""
    exit 1
fi

BUILD_BACKEND_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --backend|--backend-only)
            BUILD_BACKEND_ONLY=true
            ;;
        --help|-h)
            echo "Football Home Build Script"
            echo ""
            echo "Usage:"
            echo "  ./build.sh           Full rebuild (destroys volumes)"
            echo "  ./build.sh --backend Rebuild backend only (fast iteration)"
            echo ""
            echo "After building, populate data:"
            echo "  ./update.sh          Run all scrapers"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --backend, --help"
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
echo "  ✓ Rebuild all images"
echo "  ✓ Load database schema"
echo "  ✓ Start all services"
echo ""
echo -e "${BLUE}Note: To populate data after build, run: ./update.sh${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: Install dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}📦 Installing npm dependencies...${NC}"
npm install --silent

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: CLEAN EVERYTHING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}🧹 Cleaning containers, volumes, and build cache...${NC}"

$DOCKER_COMPOSE down 2>&1 | grep -v "no container with" | grep -v "Error:" || true
$DOCKER stop footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
$DOCKER rm -f footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
$DOCKER volume rm footballhome_db_data 2>/dev/null || true
$DOCKER volume rm footballhome_footballhome_network 2>/dev/null || true
$DOCKER network rm footballhome_footballhome_network 2>/dev/null || true
$DOCKER pod rm -f pod_footballhome 2>/dev/null || true
$DOCKER images | grep footballhome | awk '{print $3}' | xargs -r $DOCKER rmi -f 2>/dev/null || true

echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: BUILD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}🔨 Building images...${NC}"
$DOCKER_COMPOSE build
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 4: START
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}🚀 Starting containers...${NC}"

# Start database first
echo -n "  Starting database"
$DOCKER_COMPOSE up -d db
for i in $(seq 1 120); do
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
echo -e "${YELLOW}⏳ Waiting for services...${NC}"

# Wait for database
echo -n "  Database: "
for i in $(seq 1 60); do
    if $DOCKER_COMPOSE exec -T db pg_isready -U footballhome_user > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo -e "${RED}✗ Timeout${NC}"
        exit 1
    fi
    sleep 1
done

# Wait for backend
echo -n "  Backend: "
for i in $(seq 1 240); do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ready (${i}s)${NC}"
        break
    fi
    if [ "$i" -eq 240 ]; then
        echo -e "${RED}✗ Timeout${NC}"
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
        echo -e "${YELLOW}⚠ Not ready yet${NC}"
    fi
    sleep 1
done
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 6: SETUP PG_CRON
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}⏰ Setting up pg_cron...${NC}"
$DOCKER_COMPOSE exec -T db bash /docker-entrypoint-initdb.d/999-pg-cron-setup.sh 2>/dev/null || true
echo -e "${GREEN}✓ pg_cron configured${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DONE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Frontend:  http://localhost:3000"
echo "Backend:   http://localhost:3001"
echo ""
echo "Login: soccer@lighthouse1893.org / 1893Soccer!"
echo ""
echo -e "${YELLOW}📊 Check what loaded from SQL files:${NC}"
echo "  node database/scripts/audit-database.js"
echo ""
echo -e "${YELLOW}🔄 Next step: Populate dynamic data${NC}"
echo "  ./update.sh"
echo ""
