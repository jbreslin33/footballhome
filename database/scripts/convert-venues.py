#!/usr/bin/env python3
"""
Convert venues SQL file from INSERT to COPY format
Handles complex nested JSON and multi-line VALUES
"""

import re
import json
import sys
from datetime import datetime

INPUT_FILE = '../data/02-venues.sql'
OUTPUT_SQL = '../data/02-venues.sql.new'
OUTPUT_COPY = '../data/02-venues.copy.sql'

print("=" * 60)
print("Converting Venues to COPY Format")
print("=" * 60)
print()

# Read input file
print(f"📖 Reading {INPUT_FILE}...")
with open(INPUT_FILE, 'r') as f:
    content = f.read()

# Extract header comments
header_match = re.match(r'(^--.*?\n)+', content, re.MULTILINE)
header = header_match.group(0) if header_match else ''

print("🔍 Parsing INSERT statements...")

# Find all INSERT statements using a more robust regex
insert_pattern = r'INSERT INTO venues\s*\(([\s\S]*?)\)\s*VALUES\s*\(([\s\S]*?)\);'
matches = list(re.finditer(insert_pattern, content))

print(f"✅ Found {len(matches)} venue records")

if not matches:
    print("❌ No venues found!")
    sys.exit(1)

# Parse column names from first INSERT
columns_text = matches[0].group(1)
columns = [col.strip() for col in columns_text.split(',')]
print(f"📊 Columns: {len(columns)}")

# Generate COPY version
print(f"\n💾 Writing COPY format to {OUTPUT_COPY}...")

with open(OUTPUT_COPY, 'w') as f:
    # Write header
    f.write(header)
    f.write(f"""
-- =============================================================================
-- VENUES (COPY FORMAT - FAST BULK LOAD)
-- =============================================================================
-- Total venues: {len(matches)}
-- Generated: {datetime.now().isoformat()}
-- Format: PostgreSQL COPY with tab-delimited values
-- =============================================================================

COPY venues (
    {', '.join(columns)}
) FROM stdin;
""")
    
    # Process each venue
    for i, match in enumerate(matches, 1):
        values_text = match.group(2)
        
        # Parse values - this is complex due to nested quotes and JSONB
        values = []
        current = ''
        in_string = False
        string_char = None
        paren_depth = 0
        bracket_depth = 0
        escape_next = False
        
        for char in values_text:
            if escape_next:
                current += char
                escape_next = False
                continue
            
            if char == '\\':
                escape_next = True
                current += char
                continue
            
            if not in_string:
                if char in ("'", '"'):
                    in_string = True
                    string_char = char
                    current += char
                elif char == '(':
                    paren_depth += 1
                    current += char
                elif char == ')':
                    paren_depth -= 1
                    current += char
                elif char == '[':
                    bracket_depth += 1
                    current += char
                elif char == ']':
                    bracket_depth -= 1
                    current += char
                elif char == ',' and paren_depth == 0 and bracket_depth == 0:
                    values.append(current.strip())
                    current = ''
                else:
                    current += char
            else:
                current += char
                if char == string_char:
                    in_string = False
                    string_char = None
        
        if current.strip():
            values.append(current.strip())
        
        # Convert to COPY format
        copy_values = []
        for val in values:
            val = val.strip()
            
            # Handle NULL
            if val.upper() in ('NULL', 'DEFAULT'):
                copy_values.append('\\N')
                continue
            
            # Handle CURRENT_TIMESTAMP
            if 'CURRENT_TIMESTAMP' in val:
                copy_values.append(datetime.now().isoformat())
                continue
            
            # Handle booleans
            if val == 'true':
                copy_values.append('t')
                continue
            if val == 'false':
                copy_values.append('f')
                continue
            
            # Remove ::jsonb casting
            val = re.sub(r'::jsonb$', '', val)
            
            # Remove outer quotes
            if (val.startswith("'") and val.endswith("'")) or \
               (val.startswith('"') and val.endswith('"')):
                val = val[1:-1]
            
            # Escape special characters for COPY format
            val = val.replace('\\', '\\\\')  # Escape backslashes first
            val = val.replace('\n', '\\n')   # Escape newlines
            val = val.replace('\r', '\\r')   # Escape carriage returns
            val = val.replace('\t', '\\t')   # Escape tabs
            
            copy_values.append(val)
        
        # Write tab-delimited line
        f.write('\t'.join(copy_values) + '\n')
        
        if i % 10 == 0:
            print(f"  Progress: {i}/{len(matches)} venues processed")
    
    # End COPY
    f.write('\\.\n')

print(f"\n💾 Writing INSERT format to {OUTPUT_SQL}...")

# Generate updated INSERT version with ON CONFLICT
with open(OUTPUT_SQL, 'w') as f:
    f.write(header)
    f.write(f"""
-- =============================================================================
-- VENUES (INSERT FORMAT WITH ON CONFLICT)
-- =============================================================================
-- Total venues: {len(matches)}
-- Generated: {datetime.now().isoformat()}
-- =============================================================================

""")
    
    for match in matches:
        columns_text = match.group(1)
        values_text = match.group(2)
        
        f.write(f"INSERT INTO venues (\n    {columns_text}\n) VALUES (\n    {values_text}\n)\n")
        f.write("ON CONFLICT (place_id) DO UPDATE SET\n")
        f.write("    name = EXCLUDED.name,\n")
        f.write("    formatted_address = EXCLUDED.formatted_address,\n")
        f.write("    rating = EXCLUDED.rating,\n")
        f.write("    user_ratings_total = EXCLUDED.user_ratings_total,\n")
        f.write("    last_google_update = EXCLUDED.last_google_update;\n\n")

print()
print("✅ Conversion complete!")
print()
print("📊 Summary:")
print(f"   Venues converted: {len(matches)}")
print(f"   Columns: {len(columns)}")
print()
print("🔄 Next steps:")
print("   1. Review the generated files")
print("   2. Backup original: mv 02-venues.sql 02-venues.sql.backup")
print("   3. Use new version: mv 02-venues.sql.new 02-venues.sql")
print("   4. Test with ./dev.sh")
