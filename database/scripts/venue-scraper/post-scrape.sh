#!/bin/bash
# Post-scrape conversion for venue scraper
# Converts generated INSERT SQL files to COPY format for fast loading

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERT_SCRIPT="$SCRIPT_DIR/../convert-to-copy.sh"
DATA_DIR="$SCRIPT_DIR/../../data"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Skipping COPY conversion for venues (only 521 rows, INSERT is fine)${NC}"
echo ""

# NOTE: venues.sql is kept in INSERT format because:
# 1. Only 521 rows - fast enough with INSERT
# 2. convert-to-copy.sh fails on venues.sql (produces file with only comments)
# 3. Manual data - not regenerated frequently

echo -e "${GREEN}✓ Venue processing complete${NC}"
echo ""
