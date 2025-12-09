#!/bin/bash
# Run a migration file against production database

set -e

MIGRATION_FILE="$1"

if [ -z "$MIGRATION_FILE" ]; then
    echo "Usage: ./scripts/run-migration.sh migrations/V001__example.sql"
    exit 1
fi

if [ ! -f "$MIGRATION_FILE" ]; then
    echo "Error: File not found: $MIGRATION_FILE"
    exit 1
fi

echo "========================================="
echo "Running Migration: $(basename "$MIGRATION_FILE")"
echo "========================================="

# Check if database is running
if ! docker compose ps | grep -q "footballhome_db.*running"; then
    echo "Error: Database container is not running"
    exit 1
fi

# Show current schema version
echo ""
echo "Current schema versions:"
docker exec footballhome_db psql -U footballhome_user -d footballhome -c \
    "SELECT version, description, applied_at FROM schema_version ORDER BY version DESC LIMIT 5;"

echo ""
read -p "Apply migration? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled"
    exit 0
fi

# Apply migration
echo "Applying migration..."
docker exec -i footballhome_db psql -U footballhome_user -d footballhome < "$MIGRATION_FILE"

echo ""
echo "✓ Migration complete"
echo ""
echo "Updated schema versions:"
docker exec footballhome_db psql -U footballhome_user -d footballhome -c \
    "SELECT version, description, applied_at FROM schema_version ORDER BY version DESC LIMIT 5;"
