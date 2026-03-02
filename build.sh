#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home - Build Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Builds container images, starts services, and waits for health checks.
# Called by: make rebuild (which runs make clean first)
#
# Usage:
#   make rebuild            # Recommended: clean + build (via Makefile)
#   ./build.sh              # Build only (assumes already cleaned)
#   ./build.sh --backend    # Rebuild backend only (fast iteration)
#
# After building, sync leagues:
#   make sync              # Sync all leagues
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
# CONTAINER ENGINE AVAILABILITY CHECK
# ============================================================
# Prefer podman, fall back to docker
if podman ps &> /dev/null 2>&1; then
    DOCKER="podman"
    if command -v podman-compose &> /dev/null; then
        DOCKER_COMPOSE="podman-compose --env-file env"
    else
        DOCKER_COMPOSE="docker-compose --env-file env"
    fi
elif /usr/local/bin/docker ps &> /dev/null 2>&1; then
    DOCKER="/usr/local/bin/docker"
    DOCKER_COMPOSE="/usr/local/bin/docker-compose --env-file env"
else
    echo -e "${RED}Error: No container engine found${NC}"
    echo ""
    echo "Install podman or docker to continue."
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
            echo "After building, sync league data:"
            echo "  make sync            Sync all leagues"
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
echo "  ✓ Rebuild all images"
echo "  ✓ Load database schema"
echo "  ✓ Start all services"
echo ""
echo -e "${BLUE}Note: To load league data, run: make sync${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: BUILD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}🔨 Building images...${NC}"
$DOCKER_COMPOSE build
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: START
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
# STEP 3: WAIT FOR SERVICES
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
echo -e "${YELLOW}🔄 Next step: Sync league data${NC}"
echo "  make sync                                      # Sync all leagues"
echo "  make sync-apsl                                 # Sync one league"
echo ""
