#!/bin/bash
set -e

# This script runs SQL files with progress indicators
SQL_DIR="/docker-entrypoint-initdb.d"

echo "=========================================="
echo "📊 Initializing Football Home Database"
echo "=========================================="
echo ""

# Count total SQL files
TOTAL_FILES=$(ls -1 "$SQL_DIR"/*.sql 2>/dev/null | wc -l)
CURRENT=0

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "⚠️  No SQL files found in $SQL_DIR"
    exit 0
fi

echo "📁 Found $TOTAL_FILES SQL files to process"
echo ""

# Process each SQL file
for sql_file in "$SQL_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        CURRENT=$((CURRENT + 1))
        FILENAME=$(basename "$sql_file")
        PERCENT=$((CURRENT * 100 / TOTAL_FILES))
        
        echo "[$CURRENT/$TOTAL_FILES - ${PERCENT}%] 🔄 Processing: $FILENAME"
        
        # Get file size for context
        SIZE=$(du -h "$sql_file" | cut -f1)
        echo "   📦 Size: $SIZE"
        
        # Count approximate number of statements (rough estimate)
        STATEMENTS=$(grep -c ";" "$sql_file" || echo "?")
        echo "   📝 ~$STATEMENTS statements"
        
        # Execute with timing
        START=$(date +%s)
        
        # Run psql with some verbosity
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            -f "$sql_file" 2>&1 | while IFS= read -r line; do
            # Filter out noise, show important messages
            if echo "$line" | grep -qE "(ERROR|WARNING|NOTICE|INSERT|CREATE|ALTER)"; then
                echo "   💬 $line"
            fi
        done
        
        END=$(date +%s)
        DURATION=$((END - START))
        
        echo "   ✅ Completed in ${DURATION}s"
        echo ""
    fi
done

echo "=========================================="
echo "✅ Database initialization complete!"
echo "   Total time: Processed $TOTAL_FILES files"
echo "=========================================="
