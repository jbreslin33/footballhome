#!/bin/bash

# Football Home - Start Script
# Usage: ./start.sh [--full]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FULL_REBUILD=false

for arg in "$@"; do
    case $arg in
        --full)
            FULL_REBUILD=true
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"

if [ "$FULL_REBUILD" = true ]; then
    echo -e "${YELLOW}Full rebuild: removing volumes and cache...${NC}"
    docker compose down -v
    docker compose build --no-cache
else
    echo -e "${YELLOW}Restarting containers...${NC}"
    docker compose down
fi

echo -e "${YELLOW}Starting services...${NC}"
docker compose up -d

echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo "  Frontend:  http://localhost:3000"
echo "  Backend:   http://localhost:3001"
echo "  Database:  localhost:5432"
echo "  pgAdmin:   http://localhost:5050"
