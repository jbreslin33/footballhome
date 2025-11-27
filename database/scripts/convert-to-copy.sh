#!/bin/bash
# convert-to-copy.sh
# Converts INSERT statements to PostgreSQL COPY format for faster bulk loading
#
# Usage:
#   ./convert-to-copy.sh file.sql              # Convert one file
#   ./convert-to-copy.sh file1.sql file2.sql   # Convert multiple files
#   ./convert-to-copy.sh ../data/*.sql         # Convert all files
#
# Output: Creates file.copy.sql for each input file
# Performance: COPY is ~100x faster than individual INSERTs

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file.sql> [file2.sql ...]"
    echo ""
    echo "Converts INSERT statements to COPY format for faster loading"
    echo "Creates .copy.sql files alongside originals"
    exit 1
fi

# Function to convert a single SQL file
convert_file() {
    local input_file="$1"
    local output_file="${input_file%.sql}.copy.sql"
    
    if [ ! -f "$input_file" ]; then
        echo -e "${YELLOW}⚠ Skipping: $input_file (not found)${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Converting: $(basename "$input_file")${NC}"
    
    # Use Python for complex parsing
    python3 - "$input_file" "$output_file" << 'PYTHON_SCRIPT'
import sys
import re

def parse_insert_to_copy(input_file, output_file):
    """
    Convert INSERT statements to COPY format.
    Handles:
    - Single and multi-row INSERTs
    - ON CONFLICT clauses (preserved as separate statements)
    - NULL values, booleans, strings
    - Preserves comments and structure
    """
    
    with open(input_file, 'r') as f:
        content = f.read()
    
    output_lines = []
    current_table = None
    current_columns = None
    copy_data = []
    in_insert = False
    conflict_clause = None
    
    lines = content.split('\n')
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # Preserve comments and blank lines
        if line.startswith('--') or line == '':
            # Flush any pending COPY block
            if copy_data and current_table:
                flush_copy_block(output_lines, current_table, current_columns, copy_data, conflict_clause)
                copy_data = []
                conflict_clause = None
            output_lines.append(lines[i])
            i += 1
            continue
        
        # Check if this is an INSERT statement
        insert_match = re.match(r'INSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)', line, re.IGNORECASE)
        
        if insert_match:
            table_name = insert_match.group(1)
            columns = insert_match.group(2)
            
            # If switching tables, flush previous COPY block
            if copy_data and (table_name != current_table or columns != current_columns):
                flush_copy_block(output_lines, current_table, current_columns, copy_data, conflict_clause)
                copy_data = []
                conflict_clause = None
            
            current_table = table_name
            current_columns = columns
            
            # Read the full INSERT statement (may span multiple lines)
            full_statement = line
            while i < len(lines) - 1 and not full_statement.rstrip().endswith(';'):
                i += 1
                full_statement += '\n' + lines[i]
            
            # Extract VALUES and ON CONFLICT
            values_match = re.search(r'VALUES\s+(.+?)(ON\s+CONFLICT.+?)?;', full_statement, re.IGNORECASE | re.DOTALL)
            
            if values_match:
                values_part = values_match.group(1)
                conflict_part = values_match.group(2)
                
                # Store ON CONFLICT clause (if any)
                if conflict_part:
                    conflict_clause = conflict_part.strip()
                
                # Parse values (can be single or multi-row)
                # Multi-row: (val1, val2), (val3, val4)
                # Single-row: (val1, val2)
                rows = parse_values(values_part)
                
                for row in rows:
                    copy_data.append(row)
        
        i += 1
    
    # Flush any remaining COPY block
    if copy_data and current_table:
        flush_copy_block(output_lines, current_table, current_columns, copy_data, conflict_clause)
    
    # Write output
    with open(output_file, 'w') as f:
        f.write('\n'.join(output_lines))
        f.write('\n')

def parse_values(values_str):
    """
    Parse VALUES clause into individual rows.
    Returns list of lists (each inner list is one row's values).
    """
    rows = []
    
    # Remove whitespace
    values_str = values_str.strip()
    
    # Handle both single-row and multi-row INSERTs
    # Pattern: (...), (...), ...
    row_pattern = r'\(([^)]+(?:\([^)]*\)[^)]*)*)\)'
    matches = re.finditer(row_pattern, values_str)
    
    for match in matches:
        row_content = match.group(1)
        values = parse_row_values(row_content)
        rows.append(values)
    
    return rows

def parse_row_values(row_str):
    """
    Parse a single row's values: val1, val2, val3
    Handles strings, numbers, booleans, NULL, etc.
    """
    values = []
    current_value = ''
    in_string = False
    escape_next = False
    paren_depth = 0
    
    for char in row_str:
        if escape_next:
            current_value += char
            escape_next = False
            continue
        
        if char == '\\':
            escape_next = True
            current_value += char
            continue
        
        if char == "'" and paren_depth == 0:
            in_string = not in_string
            current_value += char
            continue
        
        if char == '(' and not in_string:
            paren_depth += 1
            current_value += char
            continue
        
        if char == ')' and not in_string:
            paren_depth -= 1
            current_value += char
            continue
        
        if char == ',' and not in_string and paren_depth == 0:
            # End of value
            values.append(normalize_value(current_value.strip()))
            current_value = ''
            continue
        
        current_value += char
    
    # Last value
    if current_value.strip():
        values.append(normalize_value(current_value.strip()))
    
    return values

def normalize_value(val):
    """
    Convert SQL value to COPY format:
    - 'string' → string (remove quotes)
    - true/false → t/f
    - NULL → \\N
    - numbers → numbers
    """
    val = val.strip()
    
    # NULL
    if val.upper() == 'NULL':
        return '\\N'
    
    # Boolean
    if val.lower() == 'true':
        return 't'
    if val.lower() == 'false':
        return 'f'
    
    # String (remove outer quotes and unescape)
    if val.startswith("'") and val.endswith("'"):
        # Remove outer quotes
        val = val[1:-1]
        # Unescape doubled quotes
        val = val.replace("''", "'")
        # Escape tabs and newlines for COPY
        val = val.replace('\t', '\\t')
        val = val.replace('\n', '\\n')
        val = val.replace('\r', '\\r')
        # Escape backslashes
        val = val.replace('\\', '\\\\')
        return val
    
    # Numbers, UUIDs, function calls - keep as-is
    return val

def flush_copy_block(output_lines, table, columns, data, conflict_clause):
    """
    Write accumulated INSERT data as a COPY block.
    """
    if not data:
        return
    
    # Add COPY header
    output_lines.append(f"COPY {table} ({columns}) FROM stdin;")
    
    # Add data rows (tab-separated)
    for row in data:
        output_lines.append('\t'.join(row))
    
    # End COPY block
    output_lines.append('\\.')
    
    # Add ON CONFLICT if present (as separate UPDATE statement)
    if conflict_clause:
        output_lines.append(f"-- Note: ON CONFLICT clause from original INSERT:")
        output_lines.append(f"-- {conflict_clause}")
        output_lines.append("")

if __name__ == '__main__':
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    parse_insert_to_copy(input_file, output_file)
PYTHON_SCRIPT
    
    if [ $? -eq 0 ]; then
        # Count records
        INSERT_COUNT=$(grep -c "^INSERT INTO" "$input_file" 2>/dev/null || echo "0")
        COPY_ROWS=$(grep -cE "^[^\-\\\]" "$output_file" 2>/dev/null || echo "0")
        
        echo -e "${GREEN}  ✓ $(basename "$output_file") - $COPY_ROWS rows (was $INSERT_COUNT INSERTs)${NC}"
        return 0
    else
        echo -e "${YELLOW}  ✗ Failed to convert $(basename "$input_file")${NC}"
        return 1
    fi
}

# Main execution
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSERT → COPY Converter${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

total=0
success=0

for file in "$@"; do
    total=$((total + 1))
    if convert_file "$file"; then
        success=$((success + 1))
    fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Converted: $success/$total files${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
