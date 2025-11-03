#!/bin/bash

# Database Query Script for Football Home
# Usage: ./query.sh "SELECT * FROM teams;"
# Usage: ./query.sh -f filename.sql
# Usage: ./query.sh -i (interactive mode)

set -e

# Default values
DB_CONTAINER="footballhome_db"
DB_USER="footballhome_user"
DB_NAME="footballhome"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] \"SQL_QUERY\""
    echo ""
    echo "Options:"
    echo "  -f FILE     Execute SQL from file"
    echo "  -i          Interactive psql session"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 \"SELECT * FROM teams;\""
    echo "  $0 -f my_query.sql"
    echo "  $0 -i"
    echo ""
}

# Function to check if database is running
check_db() {
    if ! docker compose ps | grep -q "${DB_CONTAINER}.*Up"; then
        echo -e "${RED}Error: Database container is not running${NC}"
        echo "Please start it with: docker compose up -d"
        exit 1
    fi
}

# Function to execute SQL query
execute_sql() {
    local sql="$1"
    echo -e "${YELLOW}Executing SQL:${NC} $sql"
    echo ""
    docker compose exec db psql -U "$DB_USER" -d "$DB_NAME" -c "$sql"
}

# Function to execute SQL file
execute_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Error: File '$file' not found${NC}"
        exit 1
    fi
    echo -e "${YELLOW}Executing SQL file:${NC} $file"
    echo ""
    docker compose exec -T db psql -U "$DB_USER" -d "$DB_NAME" < "$file"
}

# Function for interactive mode
interactive_mode() {
    echo -e "${GREEN}Starting interactive psql session...${NC}"
    echo "Type \\q to quit"
    echo ""
    docker compose exec db psql -U "$DB_USER" -d "$DB_NAME"
}

# Main script logic
check_db

# Parse command line arguments
while getopts "f:ih" opt; do
    case $opt in
        f)
            execute_file "$OPTARG"
            exit 0
            ;;
        i)
            interactive_mode
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
            usage
            exit 1
            ;;
    esac
done

# Shift past the processed options
shift $((OPTIND-1))

# Check if SQL query was provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}Error: No SQL query provided${NC}"
    usage
    exit 1
fi

# Execute the SQL query
execute_sql "$1"
