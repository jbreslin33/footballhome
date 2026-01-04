#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Scrape Historical APSL Seasons
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Usage:
#   ./scrape-historical.sh [season_id]
#
# Examples:
#   ./scrape-historical.sh 2    # Scrape 2022/2023 season
#   ./scrape-historical.sh 3    # Scrape 2023/2024 season
#   ./scrape-historical.sh 4    # Scrape 2024/2025 season
#   ./scrape-historical.sh all  # Scrape all historical seasons
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SEASON_ID=$1

if [ -z "$SEASON_ID" ]; then
    echo "Usage: ./scrape-historical.sh [season_id|all]"
    echo ""
    echo "Available seasons:"
    echo "  2 = 2022/2023"
    echo "  3 = 2023/2024"
    echo "  4 = 2024/2025"
    echo "  all = All historical seasons"
    exit 1
fi

enable_season() {
    local id=$1
    echo "Enabling scrape_target $id..."
    podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
        "UPDATE scrape_targets SET is_active = true WHERE id = $id;"
}

disable_season() {
    local id=$1
    echo "Disabling scrape_target $id..."
    podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
        "UPDATE scrape_targets SET is_active = false WHERE id = $id;"
}

scrape_season() {
    local id=$1
    local label=$2
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Scraping: $label"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    enable_season $id
    ./update.sh
    disable_season $id
    
    echo "✓ Completed: $label"
}

if [ "$SEASON_ID" = "all" ]; then
    scrape_season 2 "APSL 2022/2023"
    scrape_season 3 "APSL 2023/2024"
    scrape_season 4 "APSL 2024/2025"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ All historical seasons scraped!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
elif [ "$SEASON_ID" = "2" ]; then
    scrape_season 2 "APSL 2022/2023"
elif [ "$SEASON_ID" = "3" ]; then
    scrape_season 3 "APSL 2023/2024"
elif [ "$SEASON_ID" = "4" ]; then
    scrape_season 4 "APSL 2024/2025"
else
    echo "Error: Invalid season_id. Use 2, 3, 4, or 'all'"
    exit 1
fi
