#!/bin/bash

# Football Home - Database Start Script
# 
# This script prepares and starts the Football Home application with granular control over data loading.
#
# Usage:
#   ./start.sh                              - Load core schema + Lighthouse team only (minimal)
#   ./start.sh --leagues                    - Include APSL league structure
#   ./start.sh --teams                      - Include all APSL teams
#   ./start.sh --players                    - Include all APSL players
#   ./start.sh --venues                     - Include Google Places venues
#   ./start.sh --all                        - Load everything
#   ./start.sh --volumes                    - Preserve existing Docker volumes
#   ./start.sh --cache                      - Use Docker build cache
#   ./start.sh --leagues --teams --volumes  - Custom combination
#
# Flags:
#   --leagues   Load APSL league structure (leagues, conferences, divisions)
#   --teams     Load all APSL teams (requires --leagues)
#   --players   Load all APSL player accounts (requires --teams, adds ~1600 users)
#   --venues    Load Google Places venue data
#   --all       Load all data (leagues + teams + players + venues)
#   --volumes   Preserve existing Docker volumes (default: delete and rebuild)
#   --cache     Use Docker build cache (default: no cache for fresh builds)
#   --help      Show this help message

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse command line arguments
LOAD_LEAGUES=false
LOAD_TEAMS=false
LOAD_USERS=false
LOAD_PLAYERS=false
LOAD_VENUES=false
PRESERVE_VOLUMES=false
NO_CACHE=true  # Default to no cache for development
SHOW_HELP=false

for arg in "$@"; do
    case $arg in
        --leagues)
            LOAD_LEAGUES=true
            ;;
        --teams)
            LOAD_TEAMS=true
            ;;
        --users)
            LOAD_USERS=true
            ;;
        --players)
            LOAD_PLAYERS=true
            ;;
        --venues)
            LOAD_VENUES=true
            ;;
        --all)
            LOAD_LEAGUES=true
            LOAD_TEAMS=true
            LOAD_USERS=true
            LOAD_PLAYERS=true
            LOAD_VENUES=true
            ;;
        --volumes)
            PRESERVE_VOLUMES=true
            ;;
        --cache)
            NO_CACHE=false
            ;;
        --help|-h)
            SHOW_HELP=true
            ;;
        *)
            echo -e "${RED}Error: Unknown parameter '$arg'${NC}"
            SHOW_HELP=true
            ;;
    esac
done

# Show help if requested or on error
if [ "$SHOW_HELP" = true ]; then
    echo -e "${BLUE}Football Home - Database Start Script${NC}"
    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ./start.sh                                  - Load core + Lighthouse team (minimal)"
    echo -e "  ./start.sh --leagues                        - Add APSL league structure"
    echo -e "  ./start.sh --leagues --teams                - Add leagues + all teams"
    echo -e "  ./start.sh --leagues --teams --users        - Add leagues + teams + APSL user accounts"
    echo -e "  ./start.sh --leagues --teams --users --players - Add leagues + teams + users + player roles"
    echo -e "  ./start.sh --all                        - Load everything"
    echo -e "  ./start.sh --volumes                    - Preserve existing volumes"
    echo -e "  ./start.sh --cache                      - Use Docker build cache"
    echo -e "  ./start.sh --all --volumes --cache      - Full data, keep volumes, use cache"
    echo ""
    echo -e "${BLUE}Flags:${NC}"
    echo -e "  --leagues   Load APSL league structure (leagues, conferences, divisions)"
    echo -e "  --teams     Load all APSL teams (~53 teams, requires --leagues)"
    echo -e "  --users     Load all APSL user accounts (~1600 accounts, requires --teams)"
    echo -e "  --players   Load all APSL player roles (requires --users)"
    echo -e "  --venues    Load Google Places venue data"
    echo -e "  --all       Load all data (leagues + teams + users + players + venues)"
    echo -e "  --volumes   Preserve existing Docker volumes (default: delete)"
    echo -e "  --cache     Use Docker build cache (default: no cache)"
    echo -e "  --help      Show this message"
    echo ""
    echo -e "${BLUE}Data Loading Order:${NC}"
    echo -e "  Always:     Schema, Core lookups, Lighthouse team, jbreslin user"
    echo -e "  --venues:   Add Google Places venues"
    echo -e "  --leagues:  Add APSL league structure"
    echo -e "  --teams:    Add APSL teams (requires leagues)"
    echo -e "  --users:    Add APSL user accounts (requires teams)"
    echo -e "  --players:  Add APSL player roles (requires users)"
    echo -e "  --teams:    Add APSL teams (requires leagues)"
    echo -e "  --players:  Add APSL player accounts (requires teams)"
    echo ""
    exit 0
fi

# Validate dependencies
if [ "$LOAD_TEAMS" = true ] && [ "$LOAD_LEAGUES" = false ]; then
    echo -e "${RED}Error: --teams requires --leagues${NC}"
    exit 1
fi

if [ "$LOAD_USERS" = true ] && [ "$LOAD_TEAMS" = false ]; then
    echo -e "${RED}Error: --users requires --teams (and --leagues)${NC}"
    exit 1
fi

if [ "$LOAD_PLAYERS" = true ] && [ "$LOAD_USERS" = false ]; then
    echo -e "${RED}Error: --players requires --users (and --teams and --leagues)${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  Load Leagues:     ${GREEN}$LOAD_LEAGUES${NC}"
echo -e "  Load Teams:       ${GREEN}$LOAD_TEAMS${NC}"
echo -e "  Load Users:       ${GREEN}$LOAD_USERS${NC}"
echo -e "  Load Players:     ${GREEN}$LOAD_PLAYERS${NC}"
echo -e "  Load Venues:      ${GREEN}$LOAD_VENUES${NC}"
echo -e "  Preserve Volumes: ${GREEN}$PRESERVE_VOLUMES${NC}"
echo -e "  Fresh Builds:     ${GREEN}$NO_CACHE${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}Step 1: Configure Docker Compose Override${NC}"

# Build docker-compose.override.yml based on flags
cat > docker-compose.override.yml << 'EOF_HEADER'
services:
  db:
    volumes:
      # Schema and seed data (always loaded)
      - ./database/schema/01-create-tables.sql:/docker-entrypoint-initdb.d/01-create-tables.sql:ro
      - ./database/seed-data/01-core-lookups.sql:/docker-entrypoint-initdb.d/02-core-lookups.sql:ro
EOF_HEADER

# Conditionally add venues
if [ "$LOAD_VENUES" = true ]; then
    echo "      - ./database/seed-data/02-venues.sql:/docker-entrypoint-initdb.d/03-venues.sql:ro" >> docker-compose.override.yml
    echo -e "${GREEN}✓ Including Google Places venues${NC}"
fi

# Conditionally add leagues
if [ "$LOAD_LEAGUES" = true ]; then
    cat >> docker-compose.override.yml << 'EOF_LEAGUES'
      
      # League structure (10-12)
      - ./database/leagues/01-leagues.sql:/docker-entrypoint-initdb.d/10-leagues.sql:ro
      - ./database/leagues/02-conferences.sql:/docker-entrypoint-initdb.d/11-conferences.sql:ro
      - ./database/leagues/03-divisions.sql:/docker-entrypoint-initdb.d/12-divisions.sql:ro
      
      # Clubs (20-21)
      - ./database/clubs/01-clubs.sql:/docker-entrypoint-initdb.d/20-clubs.sql:ro
      - ./database/clubs/02-divisions.sql:/docker-entrypoint-initdb.d/21-divisions.sql:ro
EOF_LEAGUES
    echo -e "${GREEN}✓ Including APSL league structure${NC}"
fi

# Conditionally add teams
if [ "$LOAD_TEAMS" = true ]; then
    cat >> docker-compose.override.yml << 'EOF_TEAMS'
      
      # APSL Teams (35)
      - ./database/teams/02-apsl-teams.sql:/docker-entrypoint-initdb.d/35-apsl-teams.sql:ro
EOF_TEAMS
    echo -e "${GREEN}✓ Including all APSL teams (~53 teams)${NC}"
fi

# Always add core users (jbreslin) and coaches and Lighthouse team
cat >> docker-compose.override.yml << 'EOF_CORE_USERS'
      
      # Core users and roles (30, 32)
      - ./database/users/01-core-users.sql:/docker-entrypoint-initdb.d/30-core-users.sql:ro
      - ./database/coaches/01-coaches.sql:/docker-entrypoint-initdb.d/32-coaches.sql:ro
      
      # Core team (Lighthouse 1893 SC - loaded after coaches exist)
      - ./database/teams/01-lighthouse-team.sql:/docker-entrypoint-initdb.d/35-lighthouse-team.sql:ro
EOF_CORE_USERS

# Conditionally add APSL users
if [ "$LOAD_USERS" = true ]; then
    echo "      - ./database/users/02-apsl-users.sql:/docker-entrypoint-initdb.d/43-apsl-users.sql:ro" >> docker-compose.override.yml
    echo -e "${GREEN}✓ Including all APSL user accounts (~1600 accounts)${NC}"
fi

# Conditionally add APSL players
if [ "$LOAD_PLAYERS" = true ]; then
    echo "      - ./database/players/02-apsl-players.sql:/docker-entrypoint-initdb.d/44-apsl-players.sql:ro" >> docker-compose.override.yml
    echo -e "${GREEN}✓ Including all APSL player roles${NC}"
fi

# Conditionally add rosters
if [ "$LOAD_TEAMS" = true ]; then
    cat >> docker-compose.override.yml << 'EOF_ROSTERS'
      
      # APSL Rosters (50)
      - ./database/rosters/01-rosters.sql:/docker-entrypoint-initdb.d/50-apsl-rosters.sql:ro
EOF_ROSTERS
    echo -e "${GREEN}✓ Including APSL team rosters${NC}"
fi

echo -e "${GREEN}✓ docker-compose.override.yml configured${NC}"
echo ""

echo -e "${BLUE}Step 2: Docker Container Management${NC}"

# Handle volume management based on PRESERVE_VOLUMES flag
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
    
    echo -e "${YELLOW}🗑️  Removing dangling images${NC}"
    docker image prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Dangling images removed${NC}"
fi

# Build and start
if [ "$NO_CACHE" = true ]; then
    echo -e "${YELLOW}🔄 Building without cache...${NC}"
    docker compose build --no-cache
else
    echo -e "${BLUE}🏗️ Building with cache...${NC}"
    docker compose build
fi

docker compose up -d

# Clear reverse proxy cache
echo ""
echo -e "${BLUE}Step 3: Reverse Proxy Cache${NC}"
if systemctl is-active --quiet nginx 2>/dev/null; then
    sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
    sudo systemctl restart nginx
    echo -e "${GREEN}✓ Nginx cache cleared${NC}"
elif systemctl is-active --quiet caddy 2>/dev/null; then
    sudo systemctl restart caddy
    echo -e "${GREEN}✓ Caddy restarted${NC}"
else
    echo -e "${GREEN}✓ No reverse proxy detected${NC}"
fi

echo ""
echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo -e "  Database:  localhost:5432"
echo -e "  Backend:   localhost:3001"
echo -e "  Frontend:  localhost:3000"
echo -e "  pgAdmin:   localhost:5050"
echo ""

# Handle volume management based on PRESERVE_VOLUMES flag
if [ "$PRESERVE_VOLUMES" = true ]; then
    echo -e "${GREEN}📦 Preserving existing Docker volumes${NC}"
    # Stop containers but keep volumes
    docker compose down
else
    echo -e "${YELLOW}🗑️  Removing Docker volumes for fresh start${NC}"
    # Stop containers and remove volumes
    docker compose down -v
    echo -e "${GREEN}✓ Volumes removed - will initialize fresh database${NC}"
    
    # Remove all project images to ensure truly fresh builds
    echo -e "${YELLOW}🗑️  Removing all project Docker images${NC}"
    docker rmi footballhome-frontend footballhome_frontend-frontend footballhome-backend footballhome_backend-backend 2>/dev/null || true
    echo -e "${GREEN}✓ Project images removed${NC}"
    
    # Clear Docker build cache
    echo -e "${YELLOW}🗑️  Clearing Docker build cache${NC}"
    docker builder prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Build cache cleared${NC}"
    
    # Remove dangling images
    echo -e "${YELLOW}🗑️  Removing dangling Docker images${NC}"
    docker image prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Dangling images removed${NC}"
fi

echo -e "${BLUE}🐳 Starting Docker containers...${NC}"

# Check if this is a fresh start (volumes deleted)
if ! docker volume ls | grep -q footballhome_db_data; then
    echo -e "${YELLOW}⚠ Fresh database detected - will initialize from SQL files${NC}"
fi

# Build containers based on NO_CACHE flag
if [ "$NO_CACHE" = true ]; then
    echo -e "${YELLOW}🔄 Building Docker images without cache (default for development)...${NC}"
    docker compose build --no-cache
    echo -e "${GREEN}✓ Fresh Docker images built${NC}"
else
    echo -e "${BLUE}🏗️ Building Docker images with cache (faster but may use stale files)...${NC}"
    docker compose build
    echo -e "${GREEN}✓ Docker images built from cache${NC}"
fi

# Start containers
docker compose up -d

# Restart system nginx to clear its cache (if it exists)
echo ""
echo -e "${BLUE}Step 5: Reverse Proxy Cache Management${NC}"
if systemctl is-active --quiet nginx 2>/dev/null; then
    echo -e "${YELLOW}�️  Clearing system nginx cache...${NC}"
    # Clear nginx cache directories
    sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
    sudo rm -rf /var/lib/nginx/proxy/* 2>/dev/null || true
    echo -e "${GREEN}✓ Nginx cache cleared${NC}"
    
    echo -e "${YELLOW}🔄 Restarting system nginx...${NC}"
    sudo systemctl restart nginx
    echo -e "${GREEN}✓ System nginx restarted${NC}"
elif systemctl is-active --quiet caddy 2>/dev/null; then
    echo -e "${YELLOW}🔄 Restarting Caddy to clear cache...${NC}"
    sudo systemctl restart caddy
    echo -e "${GREEN}✓ Caddy restarted${NC}"
else
    echo -e "${GREEN}✓ No system reverse proxy detected${NC}"
fi

echo ""
echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo -e "  Database:    ${GREEN}localhost:5432${NC}"
echo -e "  Backend:     ${GREEN}localhost:3001${NC}"
echo -e "  Frontend:    ${GREEN}localhost:3000${NC}"
echo -e "  pgAdmin:     ${GREEN}localhost:5050${NC}"
echo ""
echo -e "${BLUE}Usage Examples:${NC}"
echo -e "  View logs:               ${GREEN}docker compose logs -f${NC}"
echo -e "  Stop services:           ${GREEN}docker compose down${NC}"
echo -e "  Fresh start (minimal):   ${GREEN}./start.sh${NC}"
echo -e "  Fresh start (full data): ${GREEN}./start.sh apslsql${NC}"
echo -e "  Fast start (cached):     ${GREEN}./start.sh cache${NC}"
echo -e "  Preserve data:           ${GREEN}./start.sh volumes${NC}"
echo -e "  Fresh + APSL scraping:   ${GREEN}./start.sh apsl${NC}"
echo -e "  Preserve + APSL:         ${GREEN}./start.sh apsl volumes${NC}"
echo -e "  Fast cached start:       ${GREEN}./start.sh cache${NC}"
echo -e "  Preserve + fast start:   ${GREEN}./start.sh volumes cache${NC}"
echo ""
