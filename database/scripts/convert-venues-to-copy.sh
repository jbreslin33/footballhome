#!/bin/bash
set -e

# Convert venues INSERT file to COPY format for faster loading
# This is a ONE-TIME conversion script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
INPUT_FILE="$DATA_DIR/02-venues.sql"
OUTPUT_SQL="$DATA_DIR/02-venues.sql.new"
OUTPUT_COPY="$DATA_DIR/02-venues.copy.sql"

echo "=========================================="
echo "Converting Venues to COPY Format"
echo "=========================================="
echo ""

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: $INPUT_FILE not found"
    exit 1
fi

echo "📄 Input:  $INPUT_FILE"
echo "📝 Output: $OUTPUT_SQL (INSERT format)"
echo "📦 Output: $OUTPUT_COPY (COPY format)"
echo ""

# Use Node.js to parse and convert
node << 'EOF'
const fs = require('fs');

const inputFile = process.env.INPUT_FILE;
const outputSql = process.env.OUTPUT_SQL;
const outputCopy = process.env.OUTPUT_COPY;

console.log('📖 Reading input file...');
const content = fs.readFileSync(inputFile, 'utf8');

// Extract the header comments
const headerMatch = content.match(/^(--.*?\n)+/);
const header = headerMatch ? headerMatch[0] : '';

console.log('🔍 Parsing INSERT statements...');

// Extract all INSERT statements
const insertRegex = /INSERT INTO venues \(([\s\S]*?)\) VALUES \(([\s\S]*?)\);/g;
const venues = [];
let match;
let columnNames = null;

while ((match = insertRegex.exec(content)) !== null) {
    if (!columnNames) {
        // Parse column names from first INSERT
        columnNames = match[1]
            .split(',')
            .map(col => col.trim())
            .filter(col => col.length > 0);
    }
    
    // Parse values - this is tricky due to nested quotes and commas
    const valuesStr = match[2];
    venues.push(valuesStr);
}

console.log(`✅ Found ${venues.length} venue records`);

if (venues.length === 0) {
    console.error('❌ No venues found in input file');
    process.exit(1);
}

// Parse one INSERT to understand the structure
function parseInsertValues(valuesStr) {
    const values = [];
    let current = '';
    let inString = false;
    let stringChar = null;
    let depth = 0;
    let escapeNext = false;
    
    for (let i = 0; i < valuesStr.length; i++) {
        const char = valuesStr[i];
        
        if (escapeNext) {
            current += char;
            escapeNext = false;
            continue;
        }
        
        if (char === '\\') {
            escapeNext = true;
            current += char;
            continue;
        }
        
        if (!inString && (char === "'" || char === '"')) {
            inString = true;
            stringChar = char;
            current += char;
        } else if (inString && char === stringChar && valuesStr[i-1] !== '\\') {
            current += char;
            inString = false;
            stringChar = null;
        } else if (!inString && char === '(') {
            depth++;
            current += char;
        } else if (!inString && char === ')') {
            depth--;
            current += char;
        } else if (!inString && depth === 0 && char === ',') {
            values.push(current.trim());
            current = '';
        } else {
            current += char;
        }
    }
    
    if (current.trim()) {
        values.push(current.trim());
    }
    
    return values;
}

// Convert value to COPY format (tab-delimited, escape special chars)
function valueToCopyFormat(value) {
    if (value === 'NULL' || value === 'null') {
        return '\\N';
    }
    
    // Remove surrounding quotes
    if ((value.startsWith("'") && value.endsWith("'")) ||
        (value.startsWith('"') && value.endsWith('"'))) {
        value = value.slice(1, -1);
    }
    
    // Handle JSONB casting
    value = value.replace(/::jsonb$/, '');
    
    // Handle CURRENT_TIMESTAMP
    if (value === 'CURRENT_TIMESTAMP') {
        return new Date().toISOString();
    }
    
    // Handle booleans
    if (value === 'true') return 't';
    if (value === 'false') return 'f';
    
    // Escape special characters for COPY format
    value = value
        .replace(/\\/g, '\\\\')     // Escape backslashes
        .replace(/\n/g, '\\n')       // Escape newlines
        .replace(/\r/g, '\\r')       // Escape carriage returns
        .replace(/\t/g, '\\t');      // Escape tabs
    
    return value;
}

console.log('🔄 Converting to COPY format...');

// Generate INSERT version (with ON CONFLICT)
let sqlContent = header;
sqlContent += `
-- =============================================================================
-- VENUES (INSERT FORMAT WITH ON CONFLICT)
-- =============================================================================
-- Total venues: ${venues.length}
-- Generated: ${new Date().toISOString()}
-- =============================================================================

`;

for (const venueValues of venues) {
    sqlContent += `INSERT INTO venues (\n`;
    sqlContent += `    ${columnNames.join(',\n    ')}\n`;
    sqlContent += `) VALUES (\n    ${venueValues}\n`;
    sqlContent += `) ON CONFLICT (place_id) DO UPDATE SET\n`;
    sqlContent += `    name = EXCLUDED.name,\n`;
    sqlContent += `    formatted_address = EXCLUDED.formatted_address,\n`;
    sqlContent += `    rating = EXCLUDED.rating,\n`;
    sqlContent += `    user_ratings_total = EXCLUDED.user_ratings_total,\n`;
    sqlContent += `    last_google_update = EXCLUDED.last_google_update;\n\n`;
}

console.log(`💾 Writing INSERT format to ${outputSql}...`);
fs.writeFileSync(outputSql, sqlContent);

// Generate COPY version
let copyContent = header;
copyContent += `
-- =============================================================================
-- VENUES (COPY FORMAT - FAST BULK LOAD)
-- =============================================================================
-- Total venues: ${venues.length}
-- Generated: ${new Date().toISOString()}
-- Format: PostgreSQL COPY with tab-delimited values
-- =============================================================================

COPY venues (
    ${columnNames.join(',\n    ')}
) FROM stdin;
`;

for (const venueValues of venues) {
    const parsedValues = parseInsertValues(venueValues);
    const copyValues = parsedValues.map(valueToCopyFormat);
    copyContent += copyValues.join('\t') + '\n';
}

copyContent += '\\.\n';

console.log(`💾 Writing COPY format to ${outputCopy}...`);
fs.writeFileSync(outputCopy, copyContent);

console.log('');
console.log('✅ Conversion complete!');
console.log('');
console.log('📊 Summary:');
console.log(`   Venues converted: ${venues.length}`);
console.log(`   Columns: ${columnNames.length}`);
console.log('');
console.log('🔄 Next steps:');
console.log('   1. Review the generated files');
console.log('   2. Backup original: mv 02-venues.sql 02-venues.sql.backup');
console.log('   3. Use new version: mv 02-venues.sql.new 02-venues.sql');
console.log('   4. Test with ./dev.sh');

EOF

echo ""
echo "✨ Done!"
