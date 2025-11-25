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
echo -e "${BLUE}Step 2: Configure Database Loading${NC}"

# Back up original docker-compose.yml if it doesn't have a backup
if [ ! -f "docker-compose.yml.original" ]; then
    cp docker-compose.yml docker-compose.yml.original
fi

# Start building the volumes section for db service
SQL_MOUNTS="      # Mount database initialization files (loaded in alphabetical order)\n"
SQL_MOUNTS+="      - ./database/schema/01-create-tables.sql:/docker-entrypoint-initdb.d/01-create-tables.sql:ro\n"

# Counter for file ordering
MOUNT_NUMBER=2

# Function to add all SQL files from a folder
add_all_sql_files() {
    local folder=$1
    
    if [ -d "database/data/$folder" ]; then
        local files_found=false
        # Find all *.sql files and sort them
        for file in $(find database/data/$folder -name "*.sql" -type f | sort); do
            files_found=true
            local filename=$(basename "$file")
            SQL_MOUNTS+="      - ./$file:/docker-entrypoint-initdb.d/$(printf "%02d" $MOUNT_NUMBER)-$folder-$filename:ro\n"
            ((MOUNT_NUMBER++))
        done
        
        if [ "$files_found" = true ]; then
            local folder_name=$(echo $folder | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
            echo -e "${GREEN}✓ Loading all $folder_name files${NC}"
        fi
    fi
}

# Load ALL SQL files from all data folders in order
echo -e "${YELLOW}Loading ALL SQL files from database/data folders...${NC}"
for folder in seed-data venues leagues conferences league-divisions clubs sport-divisions users admins coaches teams team-coaches players rosters; do
    add_all_sql_files "$folder"
done

# Add persistent data volume mount
SQL_MOUNTS+="      # Persistent data storage\n"
SQL_MOUNTS+="      - db_data:/var/lib/postgresql/data"

# Update docker-compose.yml with the new volumes
# Use sed to replace the volumes section for db service
awk -v mounts="$SQL_MOUNTS" '
    /^  db:$/,/^  [a-z]/ {
        if (/^    volumes:$/) {
            print "    volumes:"
            printf "%b\n", mounts
            in_volumes=1
            next
        }
        if (in_volumes && /^      -/) {
            next
        }
        if (in_volumes && !/^      /) {
            in_volumes=0
        }
    }
    { print }
' docker-compose.yml.original > docker-compose.yml

echo -e "${GREEN}✓ docker-compose.yml configured with all SQL files${NC}"
echo ""

echo -e "${BLUE}Step 3: Build and Start Containers${NC}"

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
