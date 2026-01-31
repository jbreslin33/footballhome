#!/bin/bash

# Generate Cross-League Curation SQL
# Analyzes database and generates 045-cross-league-curation.sql

set -e

echo "Generating curation SQL from database..."
echo "Make sure containers are running (./build.sh if needed)"
echo ""

# Check if database is running
if ! docker ps | grep -q "footballhome_db"; then
    echo "ERROR: Database container not running!"
    echo "Run ./build.sh first"
    exit 1
fi

# Generate curation SQL
cd database/scripts
node generate-curation.js > ../data/045-cross-league-curation.sql

echo "✓ Generated database/data/045-cross-league-curation.sql"
echo ""
echo "Next steps:"
echo "  1. Review the file: cat database/data/045-cross-league-curation.sql"
echo "  2. Edit any merges that don't look right"
echo "  3. Test: ./build.sh (rebuilds with curation applied)"
echo "  4. Commit: git add database/data/045-cross-league-curation.sql && git commit"
