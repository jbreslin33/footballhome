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
#
# After building, sync leagues:
#   make lighthouse         # Sync Lighthouse data
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# Change to script directory (project root)
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
OS_TYPE="$(uname -s)"

# ============================================================
# ARGUMENT PARSING
# ============================================================
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Football Home Build Script"
            echo ""
            echo "Usage:"
            echo "  ./build.sh           Build images and start services"
            echo ""
            echo "Recommended entrypoints:"
            echo "  sudo make rebuild    Clean volumes, then run this script"
            echo "  sudo make deploy     Rebuild and replace backend/frontend"
            echo "  sudo make lighthouse Sync Lighthouse data after rebuild"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Valid options: --help"
            exit 1
            ;;
    esac
done

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
DOCKER=()
DOCKER_COMPOSE=()
if command -v podman &> /dev/null; then
    PODMAN_BIN="$(command -v podman)"
    DOCKER=("$PODMAN_BIN")
    if [ "$OS_TYPE" = "Linux" ] && [ "$EUID" -ne 0 ]; then
        DOCKER=(sudo "$PODMAN_BIN")
    fi
    if command -v podman-compose &> /dev/null; then
        COMPOSE_BIN="$(command -v podman-compose)"
        DOCKER_COMPOSE=("$COMPOSE_BIN" --env-file env)
        if [ "$OS_TYPE" = "Linux" ] && [ "$EUID" -ne 0 ]; then
            DOCKER_COMPOSE=(sudo "$COMPOSE_BIN" --env-file env)
        fi
    else
        echo -e "${RED}Error: podman-compose not found${NC}"
        echo "Run ./setup.sh, or install podman-compose manually."
        exit 1
    fi
elif command -v docker &> /dev/null; then
    DOCKER_BIN="$(command -v docker)"
    DOCKER=("$DOCKER_BIN")
    if command -v docker-compose &> /dev/null; then
        COMPOSE_BIN="$(command -v docker-compose)"
        DOCKER_COMPOSE=("$COMPOSE_BIN" --env-file env)
    else
        echo -e "${RED}Error: docker-compose not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: No container engine found${NC}"
    echo ""
    echo "Install podman or docker to continue."
    echo ""
    exit 1
fi

"${DOCKER[@]}" ps

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

# Regenerate the sim registry catalog header from the registry-seeding
# migrations. The sim container build context is ./sim, so the migration
# files (which live in ./database/) are not visible during `podman build`
# — the header must be produced on the host first. See sim/DESIGN.md
# section 22.11.
#
# Migration sources (order = registry-id order; awk processes each
# INSERT INTO sim_attribute_registry / sim_concept_registry block it
# encounters, independent of file boundaries):
#   200 = baseline (attrs 1..9 + run_to_point concept + empty_pitch scenario)
#   208 = physical.dribble_efficiency (attr 10, Slice 16.1)
#   209 = physical.max_dribble_speed + max_carry_sprint_speed (attrs 11+12, Slice 25.2)
#   216 = physical.press_resistance (attr 13, Slice 24.3b)
#   217 = physical.pass_power (attr 14, Slice 26.1)
#   220 = physical.body_mass (attr 15, Slice 27.3)
#   224 = pressing concept (Slice 30.2)
#   225 = marking + jockey concepts (Slice 31.1)
#   226 = M3 behavior attribute batch (Slice 31.3)
echo -e "${YELLOW}🔧 Regenerating sim registry header from migrations 200 + 208 + 209 + 216 + 217 + 220 + 224 + 225 + 226...${NC}"
awk -f sim/scripts/gen_registry_header.awk \
    database/migrations/200-sim-registries.sql \
    database/migrations/208-sim-attr-dribble-efficiency.sql \
    database/migrations/209-sim-attr-carry-speeds.sql \
    database/migrations/216-sim-attr-press-resistance.sql \
    database/migrations/217-sim-attr-pass-power.sql \
    database/migrations/220-sim-attr-body-mass.sql \
    database/migrations/224-sim-concept-pressing.sql \
    database/migrations/225-sim-concept-marking-jockey.sql \
    database/migrations/226-sim-attr-m3-batch.sql \
    > sim/src/common/M0Registry.generated.hpp
echo -e "${GREEN}✓ sim/src/common/M0Registry.generated.hpp regenerated${NC}"
echo ""

echo -e "${YELLOW}🔨 Building images...${NC}"
# Compute + export the sim's build-time version so docker-compose can
# forward it to the sim Dockerfile ARG (see sim/DESIGN.md §16.6 task 7).
# Falls back to "unknown" if this isn't a git checkout.
export FH_SIM_GIT_DESCRIBE="$(git describe --tags --dirty --always 2>/dev/null || echo unknown)"
echo -e "${BLUE}  FH_SIM_GIT_DESCRIBE=${FH_SIM_GIT_DESCRIBE}${NC}"
"${DOCKER_COMPOSE[@]}" build
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: START
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}🚀 Starting containers...${NC}"

# Start database first
echo -n "  Starting database"
"${DOCKER_COMPOSE[@]}" up -d db
for i in $(seq 1 120); do
    if "${DOCKER[@]}" ps --format "{{.Names}}" | grep -q "footballhome_db"; then
        DB_HEALTH=$("${DOCKER[@]}" inspect --format '{{.State.Health.Status}}' footballhome_db 2>/dev/null || echo "starting")
        if [ "$DB_HEALTH" = "healthy" ]; then
            echo -e " ${GREEN}✓ Healthy (${i}s)${NC}"
            break
        fi
    fi
    echo -n "."
    sleep 1
    if [ "$i" -eq 120 ]; then
        echo -e " ${RED}✗ Timeout${NC}"
        "${DOCKER[@]}" logs footballhome_db
        exit 1
    fi
done

# Start remaining services
echo -n "  Starting remaining services"
"${DOCKER_COMPOSE[@]}" up -d
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
    if "${DOCKER_COMPOSE[@]}" exec -T db pg_isready -U footballhome_user > /dev/null 2>&1; then
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
echo "  sudo make lighthouse                           # Sync Lighthouse data"
echo "  sudo make sync                                 # Sync all leagues"
echo ""
