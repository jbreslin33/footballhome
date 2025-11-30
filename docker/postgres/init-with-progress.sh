#!/bin/bash
set -e

# This script runs SQL files with progress indicators
SQL_DIR="/docker-entrypoint-initdb.d"

echo "=========================================="
echo "📊 Initializing Football Home Database"
echo "=========================================="
echo ""

# Build list of files to load, preferring .copy.sql when available
FILES_TO_LOAD=()
for sql_file in $(find "$SQL_DIR" -maxdepth 1 -name "*.sql" -type f ! -name "*.copy.sql" | sort); do
    BASENAME=$(basename "$sql_file" .sql)
    COPY_FILE="$SQL_DIR/${BASENAME}.copy.sql"
    
    if [ -f "$COPY_FILE" ]; then
        # Use COPY version (faster)
        FILES_TO_LOAD+=("$COPY_FILE")
    else
        # Use INSERT version (slower)
        FILES_TO_LOAD+=("$sql_file")
    fi
done

TOTAL_FILES=${#FILES_TO_LOAD[@]}
CURRENT=0

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "⚠️  No SQL files found in $SQL_DIR"
    exit 0
fi

echo "📁 Found $TOTAL_FILES SQL files to process"
echo ""

# Process each SQL file
for sql_file in "${FILES_TO_LOAD[@]}"; do
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
        
        # Track current table and row count for this table
        CURRENT_TABLE=""
        TABLE_INSERT_COUNT=0
        
        # Run psql with detailed output
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            --echo-all \
            -f "$sql_file" 2>&1 | while IFS= read -r line; do
            
            # Show CREATE TABLE statements (handle IF NOT EXISTS)
            if echo "$line" | grep -qE "^CREATE TABLE"; then
                # Extract table name properly, handling IF NOT EXISTS syntax
                TABLE_NAME=$(echo "$line" | sed -n 's/^CREATE TABLE \(IF NOT EXISTS \)\?\([^ (;]*\).*/\2/p')
                if [ -n "$TABLE_NAME" ]; then
                    echo "   ✨ Creating table: $TABLE_NAME"
                fi
            
            # Show INSERT statements with per-table counts
            elif echo "$line" | grep -qE "^INSERT INTO"; then
                TABLE_NAME=$(echo "$line" | grep -oP "INSERT INTO \K[^ ]+")
                # Reset counter if we're on a new table
                if [ "$TABLE_NAME" != "$CURRENT_TABLE" ]; then
                    if [ -n "$CURRENT_TABLE" ] && [ "$TABLE_INSERT_COUNT" -gt 0 ]; then
                        echo "   ✅ Inserted $TABLE_INSERT_COUNT rows into $CURRENT_TABLE"
                    fi
                    CURRENT_TABLE="$TABLE_NAME"
                    TABLE_INSERT_COUNT=0
                fi
                TABLE_INSERT_COUNT=$((TABLE_INSERT_COUNT + 1))
                # Only show progress every 50 rows to reduce spam
                if [ $((TABLE_INSERT_COUNT % 50)) -eq 0 ]; then
                    echo "   ➕ $CURRENT_TABLE: $TABLE_INSERT_COUNT rows..."
                fi
            
            # Show COPY statements (bulk inserts) - this is the start of COPY
            elif echo "$line" | grep -qE "^COPY [a-z_]+.*FROM stdin"; then
                TABLE_NAME=$(echo "$line" | grep -oP "COPY \K[^ (]+")
                echo "   📥 BULK LOADING into: $TABLE_NAME (COPY format - fast!)"
                CURRENT_TABLE="$TABLE_NAME"
                TABLE_INSERT_COUNT=0
            
            # Show completion of COPY - this shows how many rows were loaded
            elif echo "$line" | grep -qE "^COPY [0-9]+"; then
                ROW_COUNT=$(echo "$line" | grep -oP "^COPY \K[0-9]+")
                echo "   ✅ Loaded $ROW_COUNT rows into $CURRENT_TABLE"
                CURRENT_TABLE=""
                TABLE_INSERT_COUNT=0
            
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
        
        # Show final count for last table if we were tracking INSERTs
        if [ -n "$CURRENT_TABLE" ] && [ "$TABLE_INSERT_COUNT" -gt 0 ]; then
            echo "   ✅ Inserted $TABLE_INSERT_COUNT rows into $CURRENT_TABLE"
        fi
        
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
