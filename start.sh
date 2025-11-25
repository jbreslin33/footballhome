#!/bin/bash

# Football Home - Simplified Start Script
# Loads ALL *.sql files from database/data folders automatically
#
# Usage:
#   ./start.sh              - Fresh start (delete volumes, rebuild)
#   ./start.sh --volumes    - Preserve existing volumes
#   ./start.sh --cache      - Use Docker build cache

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
PRESERVE_VOLUMES=false
NO_CACHE=true

for arg in "$@"; do
    case $arg in
        --volumes)
            PRESERVE_VOLUMES=true
            ;;
        --cache)
            NO_CACHE=false
            ;;
        --help|-h)
            echo -e "${BLUE}Football Home - Start Script${NC}"
            echo ""
            echo "Usage:"
            echo "  ./start.sh              Fresh start (delete volumes, rebuild)"
            echo "  ./start.sh --volumes    Preserve existing volumes"
            echo "  ./start.sh --cache      Use Docker build cache"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown parameter '$arg'${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}Step 1: Docker Container Management${NC}"

# Handle volume management FIRST
if [ "$PRESERVE_VOLUMES" = true ]; then
    echo -e "${GREEN}📦 Preserving existing Docker volumes${NC}"
    docker compose down
else
    echo -e "${YELLOW}🗑️  Removing Docker volumes for fresh start${NC}"
    docker compose down -v
    echo -e "${GREEN}✓ Volumes removed${NC}"
    
    echo -e "${YELLOW}🗑️  Removing project Docker images${NC}"
    docker rmi footballhome-frontend footballhome-backend 2>/dev/null || true
    echo -e "${GREEN}✓ Images removed${NC}"
    
    echo -e "${YELLOW}🗑️  Clearing Docker build cache${NC}"
    docker builder prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Cache cleared${NC}"
fi

echo ""
echo -e "${BLUE}Step 2: Build and Start Containers${NC}"

echo ""
echo -e "${BLUE}Step 2: Build and Start Containers${NC}"

# Build
if [ "$NO_CACHE" = true ]; then
    echo -e "${YELLOW}🔄 Building without cache...${NC}"
    docker compose build --no-cache
else
    echo -e "${BLUE}🏗️ Building with cache...${NC}"
    docker compose build
fi

echo -e "${YELLOW}🚀 Starting all services...${NC}"
docker compose up -d
echo -e "${GREEN}✓ All services started${NC}"

echo ""
echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo -e "  Database:  localhost:5432"
echo -e "  Backend:   localhost:3001"
echo -e "  Frontend:  localhost:3000"
echo -e "  pgAdmin:   localhost:5050"
echo ""
