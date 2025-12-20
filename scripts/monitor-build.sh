#!/bin/bash
# Monitor podman image downloads during build

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Podman Build Monitor${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Track what we've seen
declare -A seen_images

while true; do
    echo -e "${YELLOW}$(date +%H:%M:%S) - Checking image status...${NC}"
    
    # Show current images
    podman images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null | grep -E "(REPOSITORY|gcc|postgres|nginx)" || echo "No images downloaded yet"
    
    # Show current downloads in progress (if any)
    podman ps -a --format "{{.Image}} {{.Status}}" 2>/dev/null | head -5
    
    echo ""
    echo -e "${BLUE}Waiting... (Ctrl+C to stop monitoring)${NC}"
    echo "----------------------------------------"
    sleep 5
done
