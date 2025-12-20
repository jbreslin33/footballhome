#!/bin/bash
# Clear all development (u) SQL files
# This removes all app-generated data from development environment files
# Useful when you want to reset app data but keep scraped/imported data

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Clear Development (u) Files${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$(dirname "$0")/../database/data" || exit 1

# Find all u files
u_files=($(ls -1 *u-*-app.sql 2>/dev/null))

if [ ${#u_files[@]} -eq 0 ]; then
    echo -e "${YELLOW}No u files found.${NC}"
    exit 0
fi

echo -e "${YELLOW}Found ${#u_files[@]} development (u) files:${NC}"
for file in "${u_files[@]}"; do
    echo "  - $file"
done
echo ""

# Show what will be cleared
echo -e "${RED}⚠️  WARNING: This will clear all app-generated data!${NC}"
echo ""
read -p "Are you sure you want to clear all u files? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
fi

# Clear each file (keep header comment if it exists)
echo ""
echo -e "${BLUE}Clearing files...${NC}"

for file in "${u_files[@]}"; do
    # Keep first 3-4 lines (header comments) and clear rest
    if [ -f "$file" ]; then
        # Get the header (first 4 lines or until first blank line after comments)
        header=$(head -n 10 "$file" | grep -E "^--" | head -n 4)
        
        # Recreate file with just header
        echo "$header" > "$file"
        echo "" >> "$file"
        
        echo -e "${GREEN}✓${NC} Cleared: $file"
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All u files cleared!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Files have been cleared but headers preserved."
echo "App-generated data will be re-logged on next use."
echo ""
