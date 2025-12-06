#!/bin/bash

# APSL Data Scraper Wrapper Script
# 
# Manages scraping of APSL league data with duplicate detection
# and conditional execution based on APSL_SCRAPE environment variable.
#
# Usage:
#   APSL_SCRAPE=true ./scrape-apsl.sh      # Force scrape
#   APSL_SCRAPE=false ./scrape-apsl.sh     # Skip scrape
#   ./scrape-apsl.sh                       # Auto-decide (scrape if stale)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/apsl-data.sql"
SCRAPER_SCRIPT="$SCRIPT_DIR/scrape-apsl.js"
STALE_HOURS=24

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}APSL Data Scraper${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Error: Node.js is not installed${NC}"
    echo "Please install Node.js to run the scraper"
    exit 1
fi

# Check if scraper script exists
if [ ! -f "$SCRAPER_SCRIPT" ]; then
    echo -e "${RED}✗ Error: Scraper script not found: $SCRAPER_SCRIPT${NC}"
    exit 1
fi

# Check if jsdom is installed
if ! node -e "require('jsdom')" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: jsdom not installed${NC}"
    echo "Installing jsdom..."
    cd "$SCRIPT_DIR"
    npm install jsdom
fi

# Function to check if file is stale
is_stale() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        return 0  # File doesn't exist, needs scraping
    fi
    
    local file_age=$(( $(date +%s) - $(stat -c %Y "$OUTPUT_FILE" 2>/dev/null || stat -f %m "$OUTPUT_FILE" 2>/dev/null) ))
    local stale_seconds=$((STALE_HOURS * 3600))
    
    if [ $file_age -gt $stale_seconds ]; then
        return 0  # File is stale
    else
        return 1  # File is fresh
    fi
}

# Determine if we should scrape
SHOULD_SCRAPE=false

if [ "$APSL_SCRAPE" = "true" ]; then
    echo -e "${GREEN}✓ APSL_SCRAPE=true: Forcing scrape${NC}"
    SHOULD_SCRAPE=true
elif [ "$APSL_SCRAPE" = "false" ]; then
    echo -e "${YELLOW}✓ APSL_SCRAPE=false: Skipping scrape${NC}"
    SHOULD_SCRAPE=false
else
    # Auto-decide based on staleness
    if is_stale; then
        echo -e "${YELLOW}⚠ apsl-data.sql is stale (>$STALE_HOURS hours old)${NC}"
        echo -e "${GREEN}✓ Auto-triggering scrape${NC}"
        SHOULD_SCRAPE=true
    else
        echo -e "${GREEN}✓ apsl-data.sql is fresh (<$STALE_HOURS hours old)${NC}"
        echo -e "${BLUE}ℹ Skipping scrape (set APSL_SCRAPE=true to force)${NC}"
        SHOULD_SCRAPE=false
    fi
fi

# Execute scraper if needed
if [ "$SHOULD_SCRAPE" = true ]; then
    echo ""
    echo -e "${BLUE}Starting APSL scrape...${NC}"
    echo "This may take several minutes..."
    echo ""
    
    # Run scraper and save to file
    if node "$SCRAPER_SCRIPT" > "$OUTPUT_FILE"; then
        echo ""
        echo -e "${GREEN}✓ Scrape successful!${NC}"
        
        # Auto-convert to COPY format
        echo -e "${BLUE}Auto-converting to COPY format...${NC}"
        "$SCRIPT_DIR/post-scrape.sh"
    else
        echo ""
        echo -e "${RED}✗ Scrape failed!${NC}"
        # Don't delete old file on failure, just warn
        echo "Check output above for errors"
        exit 1
    fi
else
    # If we skipped scraping, we should still ensure the data is loaded if it exists
    if [ -f "$OUTPUT_FILE" ]; then
        echo -e "${BLUE}Using existing data file: $OUTPUT_FILE${NC}"
        # We don't need to do anything else, the main init script will pick it up
    else
        echo -e "${RED}✗ Error: No data file found and scraping skipped${NC}"
        exit 1
    fi
fi
        echo -e "${GREEN}✓ Data saved to: $OUTPUT_FILE${NC}"
        
        # Show file size
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
        echo -e "${BLUE}ℹ File size: $FILE_SIZE${NC}"
        
        # Count records
        CLUBS=$(grep -c "INSERT INTO clubs" "$OUTPUT_FILE" || echo "0")
        TEAMS=$(grep -c "INSERT INTO teams" "$OUTPUT_FILE" || echo "0")
        PLAYERS=$(grep -c "INSERT INTO players" "$OUTPUT_FILE" || echo "0")
        
        echo ""
        echo -e "${BLUE}========================================${NC}"
        echo -e "${GREEN}Scraped Data Summary:${NC}"
        echo -e "${BLUE}  Clubs:   $CLUBS${NC}"
        echo -e "${BLUE}  Teams:   $TEAMS${NC}"
        echo -e "${BLUE}  Players: $PLAYERS${NC}"
        echo -e "${BLUE}========================================${NC}"
        
        # Automatically convert to COPY format for fast loading
        echo ""
        if [ -x "$SCRIPT_DIR/post-scrape.sh" ]; then
            "$SCRIPT_DIR/post-scrape.sh"
        else
            echo -e "${YELLOW}⚠ post-scrape.sh not found or not executable${NC}"
            echo "Run manually: ./post-scrape.sh"
        fi
    else
        echo ""
        echo -e "${RED}✗ Scrape failed!${NC}"
        echo "Check the error messages above"
        exit 1
    fi
else
    if [ -f "$OUTPUT_FILE" ]; then
        echo -e "${GREEN}✓ Using existing apsl-data.sql${NC}"
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
        echo -e "${BLUE}ℹ File size: $FILE_SIZE${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: apsl-data.sql does not exist${NC}"
        echo "Run with APSL_SCRAPE=true to generate it"
    fi
fi

echo ""
echo -e "${GREEN}✓ Done!${NC}"
