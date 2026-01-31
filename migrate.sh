#!/bin/bash

# Migrate a new league into existing database
# Usage: ./migrate.sh <country-league>
# Example: ./migrate.sh usa-apsl
# Example: ./migrate.sh portugal-liganos

set -e

if [ -z "$1" ]; then
    echo "Usage: ./migrate.sh <country-league>"
    echo "Example: ./migrate.sh usa-apsl"
    echo "Example: ./migrate.sh portugal-liganos"
    exit 1
fi

LEAGUE="$1"

echo "=========================================="
echo "Migrating league: $LEAGUE"
echo "=========================================="
echo ""

# Check if database is running
if ! docker ps | grep -q "footballhome_db"; then
    echo "ERROR: Database container not running!"
    exit 1
fi

# Find all SQL files for this league
SQL_FILES=$(ls database/data/*-${LEAGUE}.sql 2>/dev/null | sort)

if [ -z "$SQL_FILES" ]; then
    echo "ERROR: No SQL files found for league: $LEAGUE"
    echo "Expected files like: 042.X-teams-${LEAGUE}.sql"
    exit 1
fi

echo "Found SQL files:"
echo "$SQL_FILES"
echo ""

# Execute each SQL file
for sql_file in $SQL_FILES; do
    filename=$(basename "$sql_file")
    echo "Running: $filename"
    docker exec footballhome_db sh -c "PGPASSWORD=\$POSTGRES_PASSWORD psql -U \$POSTGRES_USER -d footballhome -f /app/data/$filename"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to execute $filename"
        exit 1
    fi
    echo "✓ $filename completed"
    echo ""
done

echo "=========================================="
echo "Running post-migration curation..."
echo "=========================================="
echo ""

# Run auto-create-clubs for any orphan teams
if [ -f "database/data/050.0-auto-create-missing-clubs.sql" ]; then
    echo "Running: 050.0-auto-create-missing-clubs.sql"
    docker exec footballhome_db sh -c "PGPASSWORD=\$POSTGRES_PASSWORD psql -U \$POSTGRES_USER -d footballhome -f /app/data/050.0-auto-create-missing-clubs.sql"
    echo "✓ Completed"
    echo ""
fi

# Run cross-league curation
if [ -f "database/data/051.0-cross-league-curation.sql" ]; then
    echo "Running: 051.0-cross-league-curation.sql"
    docker exec footballhome_db sh -c "PGPASSWORD=\$POSTGRES_PASSWORD psql -U \$POSTGRES_USER -d footballhome -f /app/data/051.0-cross-league-curation.sql"
    echo "✓ Completed"
    echo ""
fi

echo "=========================================="
echo "✓ Migration complete: $LEAGUE"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Verify data: ./database/scripts/run-sql.sh \"SELECT * FROM teams WHERE name LIKE '%YourTeam%'\""
echo "  2. Run update.sh to fetch live data"
