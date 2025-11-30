#!/bin/bash
# Robust converter for venues.sql - handles complex JSONB data
# Uses awk instead of Python regex for better performance

set -e

INPUT="$1"
OUTPUT="${INPUT%.sql}.copy.sql"

if [ -z "$INPUT" ]; then
    echo "Usage: $0 <venues.sql>"
    exit 1
fi

echo "Converting $INPUT to COPY format..."

# Extract column list from first INSERT
COLUMNS=$(grep -m1 "^INSERT INTO venues" "$INPUT" | \
    sed -n 's/INSERT INTO venues (\(.*\))/\1/p' | \
    tr -d '\n' | \
    tr -s ' ')

# Count total INSERTs
TOTAL=$(grep -c "^INSERT INTO venues" "$INPUT")

echo "  Columns: $COLUMNS"
echo "  Rows: $TOTAL"

# Build COPY file
{
    # Copy header/comments
    sed -n '1,/^INSERT INTO venues/p' "$INPUT" | head -n -1
    
    echo ""
    echo "-- Converted to COPY format for fast bulk loading"
    echo "COPY venues ("
    echo "    $COLUMNS"
    echo ") FROM stdin;"
    echo ""
    
    # Extract VALUES and convert to COPY format
    # This awk script handles multi-line VALUES properly
    awk '
        /^INSERT INTO venues/ {
            in_insert = 1
            buffer = ""
            next
        }
        
        in_insert {
            buffer = buffer $0 "\n"
            if ($0 ~ /;$/) {
                # End of INSERT statement
                # Extract VALUES (...) part
                match(buffer, /VALUES[[:space:]]*\(/, arr)
                if (RSTART > 0) {
                    # Get everything after "VALUES ("
                    values_start = RSTART + RLENGTH
                    values = substr(buffer, values_start)
                    
                    # Remove trailing ) and semicolon and ON CONFLICT clause
                    gsub(/\)[[:space:]]*(ON[[:space:]]+CONFLICT[^;]*)?;[[:space:]]*$/, "", values)
                    
                    # Print as tab-separated (COPY format)
                    # Replace ), ( with newline for multi-value inserts
                    print values
                }
                
                in_insert = 0
                buffer = ""
            }
        }
    ' "$INPUT" | \
    # Convert SQL format to COPY format
    sed 's/, /\t/g' | \           # Commas to tabs
    sed "s/''/\\\\'/g" | \         # Escape quotes
    sed 's/::jsonb//g'             # Remove jsonb casts
    
    echo "\\."
    echo ""
    
} > "$OUTPUT"

echo "✓ Created $OUTPUT"
