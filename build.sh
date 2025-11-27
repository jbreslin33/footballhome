#!/bin/bash

# Football Home - Build Script
# Full rebuild workflow: scrape APSL data, rebuild containers, load database
#
# Usage:
#   ./build.sh                    # Full rebuild with fresh APSL scrape
#   ./build.sh --skip-scrape      # Rebuild without scraping (use existing data)
#   ./build.sh --scrape-only      # Only scrape APSL data, don't rebuild

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Flags
SKIP_SCRAPE=false
SCRAPE_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-scrape)
            SKIP_SCRAPE=true
            ;;
        --scrape-only)
            SCRAPE_ONLY=true
            ;;
        --help|-h)
            echo "Football Home Build Script"
            echo ""
            echo "Usage:"
            echo "  ./build.sh                 Full rebuild (scrape + rebuild)"
            echo "  ./build.sh --skip-scrape   Rebuild without scraping"
            echo "  ./build.sh --scrape-only   Only scrape APSL data"
            echo "  ./build.sh --help          Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Build & Deploy${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Scrape APSL Data
if [ "$SKIP_SCRAPE" = false ]; then
    echo -e "${YELLOW}📊 Step 1: Scraping APSL Data${NC}"
    echo -e "  This will take 5-15 minutes..."
    echo ""
    
    if node database/scripts/apsl-scraper/scrape-apsl.js; then
        echo ""
        echo -e "${GREEN}✓ APSL data scraped successfully${NC}"
    else
        echo -e "${RED}✗ APSL scraping failed${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}⏭️  Step 1: Skipping APSL scrape (using existing data)${NC}"
fi

# Exit if scrape-only mode
if [ "$SCRAPE_ONLY" = true ]; then
    echo ""
    echo -e "${GREEN}✓ Scrape complete! (scrape-only mode)${NC}"
    echo ""
    echo "Review changes with:"
    echo "  git status"
    echo "  git diff database/data/"
    exit 0
fi

# Step 2: Show git status
echo ""
echo -e "${YELLOW}📋 Step 2: Checking for changes${NC}"
git status --short database/data/ || true

# Step 3: Rebuild containers and database
echo ""
echo -e "${YELLOW}🔨 Step 3: Rebuilding containers${NC}"
echo -e "  This will:"
echo -e "    - Stop all containers"
echo -e "    - Delete volumes (fresh database)"
echo -e "    - Clear Docker cache"
echo -e "    - Rebuild images"
echo -e "    - Start with new data"
echo ""

if ./start.sh; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Build Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Test login at http://localhost:3000"
    echo "     Email: jbreslin@footballhome.org"
    echo "     Password: 1893Soccer!"
    echo ""
    echo "  2. If everything works, commit changes:"
    echo "     git add database/data/ database/scripts/"
    echo "     git commit -m \"Update APSL data\""
    echo "     git push"
    echo ""
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
