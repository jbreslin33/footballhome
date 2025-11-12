#!/bin/bash
# Script to execute SQL commands against the footballhome database
# Usage: ./run-sql.sh "SELECT * FROM users;"
# Or: ./run-sql.sh "SELECT * FROM users;" -f (for formatted output)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database connection details
DB_CONTAINER="footballhome_db"
DB_NAME="footballhome"
DB_USER="footballhome_user"

# Check if SQL query is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No SQL query provided${NC}"
    echo "Usage: $0 \"SQL_QUERY\" [-f for formatted output]"
    echo ""
    echo "Examples:"
    echo "  $0 \"SELECT * FROM users;\""
    echo "  $0 \"SELECT COUNT(*) FROM teams;\" -f"
    echo "  $0 \"INSERT INTO clubs (name, display_name, slug) VALUES ('Test Club', 'Test Club', 'test-club');\""
    exit 1
fi

SQL_QUERY="$1"
FORMAT_FLAG=""

# Check if formatting is requested
if [ "$2" = "-f" ]; then
    FORMAT_FLAG="-x"
fi

# Check if Docker container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    echo -e "${RED}Error: Database container '${DB_CONTAINER}' is not running${NC}"
    echo "Start it with: docker compose up -d db"
    exit 1
fi

# Execute the SQL query
echo -e "${YELLOW}Executing SQL:${NC}"
echo "$SQL_QUERY"
echo ""

docker compose exec -T db psql -U "$DB_USER" -d "$DB_NAME" $FORMAT_FLAG -c "$SQL_QUERY"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}✓ Query executed successfully${NC}"
else
    echo -e "\n${RED}✗ Query failed with exit code $EXIT_CODE${NC}"
    exit $EXIT_CODE
fi
