#!/bin/bash

# Football Home - Start Script
# Usage: ./start.sh [--quick]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

QUICK_MODE=false

for arg in "$@"; do
    case $arg in
        --quick)
            QUICK_MODE=true
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$QUICK_MODE" = true ]; then
    echo -e "${BLUE}Mode: Quick Restart${NC}"
    echo -e "  - Keeping volumes (preserving data)"
    echo -e "  - Rebuilding images"
    echo ""
    echo -e "${YELLOW}🛑 Stopping containers...${NC}"
    docker compose down
    echo -e "${GREEN}✓ Containers stopped${NC}"
    echo ""
    echo -e "${YELLOW}🔨 Building images...${NC}"
    echo -e "  - Building backend (C++ compilation)..."
    echo -e "  - Building frontend (nginx + static files)..."
    docker compose build --no-cache
    echo -e "${GREEN}✓ Images built${NC}"
else
    echo -e "${BLUE}Mode: Full Rebuild${NC}"
    echo -e "  - Removing all volumes (fresh database)"
    echo -e "  - Clearing all caches"
    echo -e "  - Rebuilding all images"
    echo ""
    echo -e "${YELLOW}🛑 Stopping containers and removing volumes...${NC}"
    docker compose down -v
    echo -e "${GREEN}✓ Containers stopped and volumes removed${NC}"
    echo ""
    echo -e "${YELLOW}🗑️  Clearing Docker build cache...${NC}"
    docker builder prune -f > /dev/null 2>&1
    echo -e "${GREEN}✓ Build cache cleared${NC}"
    echo ""
    echo -e "${YELLOW}🔨 Building images from scratch...${NC}"
    docker compose build --no-cache
    echo -e "${GREEN}✓ Images built${NC}"
fi

echo ""
echo -e "${YELLOW}🚀 Starting services...${NC}"
echo -e "  📦 Starting database container..."
docker compose up -d db
sleep 2
echo -e "  ${GREEN}✓${NC} Database container started"

echo -e "  📦 Starting backend container..."
docker compose up -d backend
sleep 1
echo -e "  ${GREEN}✓${NC} Backend container started"

echo -e "  📦 Starting frontend container..."
docker compose up -d frontend
sleep 1
echo -e "  ${GREEN}✓${NC} Frontend container started"

echo -e "  📦 Starting pgAdmin container..."
docker compose up -d pgadmin
echo -e "  ${GREEN}✓${NC} pgAdmin container started"

echo -e "${GREEN}✓ All containers started${NC}"

echo ""
echo -e "${YELLOW}⏳ Waiting for services to be healthy...${NC}"

# Wait for database to be healthy with more verbose output
MAX_WAIT=60
ELAPSED=0
echo -e "  🔍 Checking database health..."
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if docker compose ps | grep footballhome_db | grep -q "healthy"; then
        echo -e "  ${GREEN}✓${NC} Database is healthy (took ${ELAPSED}s)"
        break
    fi
    if [ $((ELAPSED % 5)) -eq 0 ]; then
        echo -e "  ⏱️  Still waiting for database... ${ELAPSED}s elapsed"
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo -e "  ${YELLOW}⚠${NC} Database health check timeout after ${MAX_WAIT}s - may still be initializing"
fi

# Additional wait for database initialization to complete (SQL files loading)
echo ""
echo -e "${YELLOW}⏳ Waiting for database initialization...${NC}"
echo -e "  📊 Loading SQL files and populating tables..."
echo ""
echo -e "  ${BLUE}━━━━━━━━━━ Database Log (live) ━━━━━━━━━━${NC}"

# Show live database logs filtered for SQL activity
(timeout 30 docker logs -f footballhome_db 2>&1 | grep --line-buffered -E "(CREATE TABLE|INSERT|COPY.*FROM|processing|complete)" | head -n 20 | while IFS= read -r line; do
    echo -e "  ${YELLOW}│${NC} $line"
done) 2>/dev/null || true

echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ⏱️  (Continuing in background, check: ${GREEN}docker logs footballhome_db${NC})"
echo -e "  ${GREEN}✓${NC} Database initialization window complete"

# Check container status with details
echo ""
echo -e "${YELLOW}🔍 Checking container status...${NC}"

DB_STATUS=$(docker compose ps footballhome_db --format "{{.State}}" 2>/dev/null || echo "unknown")
BACKEND_STATUS=$(docker compose ps footballhome_simple_backend --format "{{.State}}" 2>/dev/null || echo "unknown")
FRONTEND_STATUS=$(docker compose ps footballhome_frontend --format "{{.State}}" 2>/dev/null || echo "unknown")
PGADMIN_STATUS=$(docker compose ps footballhome_pgadmin --format "{{.State}}" 2>/dev/null || echo "unknown")

echo -e "  Database:  ${DB_STATUS}"
echo -e "  Backend:   ${BACKEND_STATUS}"
echo -e "  Frontend:  ${FRONTEND_STATUS}"
echo -e "  pgAdmin:   ${PGADMIN_STATUS}"

if [ "$DB_STATUS" = "running" ] && [ "$BACKEND_STATUS" = "running" ] && [ "$FRONTEND_STATUS" = "running" ]; then
    echo -e "${GREEN}✓ All critical services are running${NC}"
else
    echo -e "${YELLOW}⚠ Some services may still be starting${NC}"
fi

echo ""
echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo "  Frontend:  http://localhost:3000"
echo "  Backend:   http://localhost:3001"
echo "  Database:  localhost:5432"
echo "  pgAdmin:   http://localhost:5050"
echo ""
echo -e "${BLUE}Testing connectivity...${NC}"

# Wait for backend to be ready (poll indefinitely with progress)
echo -e "  Backend:  Waiting for health check..."
echo -e "            (Backend is waiting for database to initialize - this can take 1-2 minutes)"
BACKEND_READY=false
i=0
while true; do
    i=$((i + 1))
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "\r  Backend:  ${GREEN}✓ Responding (took ${i}s)${NC}                              "
        BACKEND_READY=true
        break
    fi
    printf "\r  Backend:  Checking... %ds elapsed" "$i"
    sleep 1
done

# Test frontend
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "  Frontend: ${GREEN}✓ Responding${NC}"
else
    echo -e "  Frontend: ${YELLOW}⚠ Not responding yet${NC}"
fi

# Test database
if docker compose exec -T db psql -U footballhome_user -d footballhome -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "  Database: ${GREEN}✓ Accepting connections${NC}"
    
    # Count loaded data
    USER_COUNT=$(docker compose exec -T db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | xargs || echo "0")
    TEAM_COUNT=$(docker compose exec -T db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM teams;" 2>/dev/null | xargs || echo "0")
    
    echo ""
    echo -e "${BLUE}Database Contents:${NC}"
    echo "  Users: $USER_COUNT"
    echo "  Teams: $TEAM_COUNT"
else
    echo -e "  Database: ${YELLOW}⚠ Not ready yet${NC}"
fi

echo ""
echo -e "${GREEN}🚀 System is ready!${NC}"
echo ""
