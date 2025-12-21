#!/bin/bash
# Show all content from development (u) SQL files
# These files contain app-generated data from the development environment

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Development (u) Files Content${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$(dirname "$0")/../database/data" || exit 1

# Find all u files and display their content
for file in *u-*.sql; do
    if [ -f "$file" ] && [ -s "$file" ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}📄 $file${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Get file size and line count
        lines=$(wc -l < "$file" | tr -d ' ')
        size=$(ls -lh "$file" | awk '{print $5}')
        
        echo -e "${YELLOW}Lines: $lines | Size: $size${NC}"
        echo ""
        
        # Show content
        cat "$file"
        
        echo ""
        echo ""
    fi
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"

# Count total files and total SQL statements
total_files=$(ls -1 *u-*.sql 2>/dev/null | wc -l | tr -d ' ')
total_inserts=$(grep -h "^INSERT" *u-*.sql 2>/dev/null | wc -l | tr -d ' ')

echo "Total u files: $total_files"
echo "Total INSERT statements: $total_inserts"
echo ""
