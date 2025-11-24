#!/bin/bash

# Football Home - Database Start Script
# 
# This script prepares and starts the Football Home application with granular control over data loading.
#
# Usage:
#   ./start.sh                              - Load core schema + Lighthouse team only (minimal)
#   ./start.sh --leagues                    - Include APSL league structure
#   ./start.sh                              - Fast development (minimum datasets)
#   ./start.sh --full                       - Load all data (full datasets)
#   ./start.sh --volumes                    - Preserve existing Docker volumes
#   ./start.sh --cache                      - Use Docker build cache
#   ./start.sh --full --volumes --cache     - Full data, keep volumes, use cache
#
# Flags:
#   --full      Load full datasets from all database folders
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
PRESERVE_VOLUMES=false
NO_CACHE=true  # Default to no cache for development
LOAD_FULL=false  # Default to minimum datasets for fast development
SHOW_HELP=false

for arg in "$@"; do
    case $arg in
        --full)
            LOAD_FULL=true
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
    echo -e "Usage:"
    echo -e "  ${GREEN}./start.sh${NC}                    - Fast development mode (minimum datasets only)"
    echo -e "  ${GREEN}./start.sh --full${NC}             - Load complete datasets from all folders"
    echo -e "  ${GREEN}./start.sh --volumes${NC}          - Preserve existing volumes"
    echo -e "  ${GREEN}./start.sh --cache${NC}            - Use Docker build cache"
    echo -e "  ${GREEN}./start.sh --full --volumes${NC}   - Full data, keep volumes"
    echo ""
    echo -e "Flags:"
    echo -e "  ${YELLOW}--full${NC}      Load ALL SQL files from all database folders"
    echo -e "  ${YELLOW}--volumes${NC}   Preserve existing Docker volumes (default: delete)"
    echo -e "  ${YELLOW}--cache${NC}     Use Docker build cache (default: no cache)"
    echo -e "  ${YELLOW}--help${NC}      Show this message"
    echo ""
    echo -e "How it works:"
    echo -e "  ${BLUE}Without --full:${NC}  Loads only *-minimum.sql files (or all files if no minimum exists)"
    echo -e "  ${BLUE}With --full:${NC}     Loads ALL *.sql files from all database folders"
    echo ""
    exit 0
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  Load Full Data:   ${GREEN}$LOAD_FULL${NC}"
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
      # Schema (always loaded)
      - ./database/schema/01-create-tables.sql:/docker-entrypoint-initdb.d/01-create-tables.sql:ro
EOF_HEADER

# Counter for docker-entrypoint-initdb.d file ordering
MOUNT_NUMBER=2

# Function to add SQL files to docker-compose.override.yml
add_sql_files() {
    local folder=$1
    local pattern=$2
    local description=$3
    
    if [ -d "database/$folder" ]; then
        local files_found=false
        for file in database/$folder/$pattern; do
            if [ -f "$file" ]; then
                files_found=true
                local filename=$(basename "$file")
                echo "      - ./$file:/docker-entrypoint-initdb.d/$(printf "%02d" $MOUNT_NUMBER)-$folder-$filename:ro" >> docker-compose.override.yml
                ((MOUNT_NUMBER++))
            fi
        done
        
        if [ "$files_found" = true ]; then
            echo -e "${GREEN}✓ $description${NC}"
        fi
    fi
}

# Load data based on --full flag
if [ "$LOAD_FULL" = true ]; then
    echo -e "${YELLOW}Loading FULL datasets from all folders...${NC}"
    
    # Load ALL SQL files from each folder (alphabetically)
    for folder in seed-data venues leagues conferences league-divisions clubs sport-divisions teams users coaches players rosters; do
        if [ -d "database/$folder" ]; then
            folder_name=$(echo $folder | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
            add_sql_files "$folder" "*.sql" "Including all $folder_name data"
        fi
    done
else
    echo -e "${YELLOW}Loading MINIMUM datasets (fast development mode)...${NC}"
    
    # Load seed-data (always)
    add_sql_files "seed-data" "*.sql" "Including core lookups"
    
    # Load only -minimum.sql files from each folder
    for folder in venues leagues conferences league-divisions clubs sport-divisions teams users coaches players rosters; do
        if [ -d "database/$folder" ]; then
            # Check for minimum files first
            has_minimum=false
            for file in database/$folder/*-minimum.sql; do
                if [ -f "$file" ]; then
                    has_minimum=true
                    break
                fi
            done
            
            if [ "$has_minimum" = true ]; then
                # Load only minimum files
                folder_name=$(echo $folder | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
                add_sql_files "$folder" "*-minimum.sql" "Including minimum $folder_name"
            else
                # No minimum files, load all files in folder
                folder_name=$(echo $folder | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
                add_sql_files "$folder" "*.sql" "Including $folder_name"
            fi
        fi
    done
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
