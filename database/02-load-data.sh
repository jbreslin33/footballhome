#!/bin/bash
# Load all SQL data files in dependency order

set -e

echo "Loading data files..."

# Define load order based on foreign key dependencies
FOLDERS=(
    "seed-data"
    "venues"
    "leagues"
    "conferences"
    "league-divisions"
    "sport-divisions"
    "clubs"
    "users"
    "admins"
    "coaches"
    "teams"
    "team-coaches"
    "players"
    "rosters"
)

for folder in "${FOLDERS[@]}"; do
    if [ -d "/data/$folder" ]; then
        for file in /data/$folder/*.sql; do
            if [ -f "$file" ]; then
                echo "  Loading: $file"
                psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$file"
            fi
        done
    fi
done

echo "Data loading complete!"
