#!/bin/bash
set -e

# Simple venues COPY converter using awk
# Converts INSERT statements to PostgreSQL COPY format

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
INPUT_FILE="$DATA_DIR/02-venues.sql"
OUTPUT_FILE="$DATA_DIR/02-venues.copy.sql"

echo "Converting venues to COPY format..."

# Extract header and generate COPY format using awk
awk '
BEGIN {
    in_insert = 0
    in_values = 0
    current_values = ""
    row_count = 0
}

# Skip comments and empty lines at start, save them as header
/^--/ && !started {
    header = header $0 "\n"
    next
}

/^$/ && !started {
    next
}

# When we hit first INSERT, output COPY header
/^INSERT INTO venues/ && !started {
    started = 1
    # Extract column names from first INSERT
    getline
    cols = $0
    gsub(/^[ \t]+/, "", cols)
    gsub(/[ \t]+$/, "", cols)
    
    print header
    print "-- Converted to COPY format for fast bulk loading"
    print "-- Generated: " strftime("%Y-%m-%d %H:%M:%S")
    print ""
    print "COPY venues ("
    print "    " cols
    print ") FROM stdin;"
    
    # Now read the VALUES line
    getline
    in_values = 1
    current_values = ""
    next
}

# Collect VALUES content until we hit the closing paren and semicolon
in_values {
    # Check if this line ends the VALUES clause
    if ($0 ~ /\);$/) {
        # Add this line minus the closing paren and semicolon
        line = $0
        gsub(/\);$/, "", line)
        current_values = current_values line
        
        # Process the complete VALUES string
        processValues(current_values)
        row_count++
        
        # Reset for next INSERT
        in_values = 0
        current_values = ""
    } else {
        # Continue accumulating
        current_values = current_values $0 "\n"
    }
    next
}

# Start of new INSERT
/^INSERT INTO venues/ {
    getline  # Skip column names line
    getline  # Skip VALUES keyword line
    in_values = 1
    current_values = ""
    next
}

END {
    print "\\."
    print ""
    print "-- Converted " row_count " venues"
}

function processValues(vals) {
    # This is a simplified parser - we will just extract values between quotes/nulls
    # For complex JSON, we keep the entire quoted string as-is
    
    # Start fresh
    gsub(/^[ \t]+/, "", vals)
    gsub(/[ \t]+$/, "", vals)
    
    # Split by commas, but respect quotes
    n = split_respecting_quotes(vals, fields)
    
    # Convert each field to COPY format
    output = ""
    for (i = 1; i <= n; i++) {
        field = fields[i]
        gsub(/^[ \t]+/, "", field)
        gsub(/[ \t]+$/, "", field)
        
        # Handle NULL
        if (field == "NULL" || field == "null") {
            output = output "\\N"
        }
        # Handle CURRENT_TIMESTAMP
        else if (field == "CURRENT_TIMESTAMP") {
            output = output strftime("%Y-%m-%d %H:%M:%S")
        }
        # Handle booleans
        else if (field == "true") {
            output = output "t"
        }
        else if (field == "false") {
            output = output "f"
        }
        # Handle quoted strings (remove quotes and ::jsonb casting)
        else if (field ~ /^'\''/) {
            # Remove leading quote
            gsub(/^'\''/, "", field)
            # Remove trailing quote and any ::jsonb
            gsub(/'\''(::jsonb)?$/, "", field)
            # Escape special chars for COPY
            gsub(/\\/, "\\\\", field)
            gsub(/\n/, "\\n", field)
            gsub(/\r/, "\\r", field)
            gsub(/\t/, "\\t", field)
            output = output field
        }
        # Numeric values
        else {
            output = output field
        }
        
        if (i < n) output = output "\t"
    }
    
    print output
}

function split_respecting_quotes(str, arr,    i, n, in_quote, quote_char, current, depth) {
    n = 0
    current = ""
    in_quote = 0
    quote_char = ""
    depth = 0
    
    for (i = 1; i <= length(str); i++) {
        c = substr(str, i, 1)
        
        if (!in_quote && c == "'\''") {
            in_quote = 1
            quote_char = "'\''
            current = current c
        }
        else if (in_quote && c == quote_char && substr(str, i-1, 1) != "\\") {
            in_quote = 0
            current = current c
            # Check for ::jsonb
            if (substr(str, i+1, 7) == "::jsonb") {
                current = current "::jsonb"
                i += 7
            }
        }
        else if (!in_quote && c == "(") {
            depth++
            current = current c
        }
        else if (!in_quote && c == ")") {
            depth--
            current = current c
        }
        else if (!in_quote && depth == 0 && c == ",") {
            arr[++n] = current
            current = ""
        }
        else {
            current = current c
        }
    }
    
    if (current != "") {
        arr[++n] = current
    }
    
    return n
}
' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✓ Created $OUTPUT_FILE"
echo "  Converted $(grep -c "^INSERT INTO venues" "$INPUT_FILE") venues"
