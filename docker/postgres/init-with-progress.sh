#!/bin/bash
set -e

# This script runs SQL files with progress indicators
SQL_DIR="/docker-entrypoint-initdb.d"

echo "=========================================="
echo "📊 Initializing Football Home Database"
echo "=========================================="
echo ""

# Count total SQL files (exclude this script)
TOTAL_FILES=$(find "$SQL_DIR" -maxdepth 1 -name "*.sql" -type f 2>/dev/null | wc -l)
CURRENT=0

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "⚠️  No SQL files found in $SQL_DIR"
    exit 0
fi

echo "📁 Found $TOTAL_FILES SQL files to process"
echo ""

# Process each SQL file
for sql_file in $(find "$SQL_DIR" -maxdepth 1 -name "*.sql" -type f | sort); do
    if [ -f "$sql_file" ]; then
        CURRENT=$((CURRENT + 1))
        FILENAME=$(basename "$sql_file")
        PERCENT=$((CURRENT * 100 / TOTAL_FILES))
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "[$CURRENT/$TOTAL_FILES - ${PERCENT}%] 🔄 Processing: $FILENAME"
        
        # Get file size for context
        SIZE=$(du -h "$sql_file" | cut -f1)
        echo "   📦 Size: $SIZE"
        
        # Execute with verbose output showing what's happening
        START=$(date +%s)
        
        # Run psql with detailed output
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            --echo-all \
            -f "$sql_file" 2>&1 | while IFS= read -r line; do
            
            # Show CREATE TABLE statements
            if echo "$line" | grep -qE "^CREATE TABLE"; then
                TABLE_NAME=$(echo "$line" | grep -oP "CREATE TABLE \K[^ ]+")
                echo "   ✨ Creating table: $TABLE_NAME"
            
            # Show INSERT statements with details
            elif echo "$line" | grep -qE "^INSERT INTO"; then
                TABLE_NAME=$(echo "$line" | grep -oP "INSERT INTO \K[^ ]+")
                VALUES=$(echo "$line" | grep -oP "VALUES \(\K[^)]*" | head -c 100)
                echo "   ➕ Inserting into $TABLE_NAME: ${VALUES:0:80}..."
            
            # Show COPY statements (bulk inserts)
            elif echo "$line" | grep -qE "^COPY"; then
                TABLE_NAME=$(echo "$line" | grep -oP "COPY \K[^ ]+")
                echo "   📥 Bulk loading data into: $TABLE_NAME"
            
            # Show completion of COPY
            elif echo "$line" | grep -qE "^COPY [0-9]+"; then
                ROW_COUNT=$(echo "$line" | grep -oP "^COPY \K[0-9]+")
                echo "   ✅ Loaded $ROW_COUNT rows"
            
            # Show ALTER TABLE
            elif echo "$line" | grep -qE "^ALTER TABLE"; then
                TABLE_NAME=$(echo "$line" | grep -oP "ALTER TABLE \K[^ ]+")
                echo "   🔧 Altering table: $TABLE_NAME"
            
            # Show CREATE INDEX
            elif echo "$line" | grep -qE "^CREATE.*INDEX"; then
                INDEX_NAME=$(echo "$line" | grep -oP "INDEX \K[^ ]+")
                echo "   🗂️  Creating index: $INDEX_NAME"
            
            # Show errors prominently
            elif echo "$line" | grep -qE "^ERROR"; then
                echo "   ❌ ERROR: $line"
            
            # Show warnings
            elif echo "$line" | grep -qE "^WARNING"; then
                echo "   ⚠️  WARNING: $line"
            fi
        done
        
        END=$(date +%s)
        DURATION=$((END - START))
        
        echo "   ✅ Completed $FILENAME in ${DURATION}s"
        echo ""
    fi
done

echo "=========================================="
echo "✅ Database initialization complete!"
echo "   Processed $TOTAL_FILES files"
echo "=========================================="
