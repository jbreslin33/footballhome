#!/bin/bash

# Football Home - Google Venue Data Population Script
# Populates the database with Google Places venue data during setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo "🏟️  Football Home - Google Venue Population"
echo "=========================================="

# Check if API is running
if ! curl -s http://localhost:3001/health > /dev/null 2>&1; then
    print_error "Backend API is not running. Please start it first:"
    print_info "cd backend && node server.js"
    exit 1
fi

# Check if Google API key is configured
if ! curl -s http://localhost:3001/health | grep -q "google_maps_configured.*true"; then
    print_warning "Google Maps API key not configured. Venue population will be skipped."
    print_info "Add your API key to .env file: GOOGLE_MAPS_API_KEY=your_key_here"
    exit 0
fi

print_status "Google Maps API configured, proceeding with venue population..."

# Define locations to populate with soccer venues
declare -a locations=(
    "Denver, CO"
    "Boulder, CO" 
    "Aurora, CO"
    "Westminster, CO"
    "Thornton, CO"
)

declare -a search_types=(
    "soccer"
    "football" 
    "sports_complex"
)

print_info "Populating venues from ${#locations[@]} locations with ${#search_types[@]} search types..."

total_imported=0
failed_requests=0

# Function to import venues from a location
import_venues() {
    local location="$1"
    local search_type="$2"
    local radius="${3:-8000}"  # Default 8km radius
    
    print_info "Importing $search_type venues near $location (${radius}m radius)..."
    
    response=$(curl -s -X POST "http://localhost:3001/api/venues/import/google-places" \
        -H "Content-Type: application/json" \
        -d "{\"location\": \"$location\", \"radius\": $radius, \"type\": \"$search_type\"}" \
        2>/dev/null)
    
    if [ $? -eq 0 ] && echo "$response" | grep -q "imported"; then
        imported_count=$(echo "$response" | jq -r '.imported // 0' 2>/dev/null || echo "0")
        total_imported=$((total_imported + imported_count))
        print_status "Imported $imported_count venues from $location ($search_type)"
        
        # Rate limiting: wait 2 seconds between requests
        sleep 2
    else
        print_warning "Failed to import venues from $location ($search_type)"
        failed_requests=$((failed_requests + 1))
    fi
}

# Import venues from each location and type combination
for location in "${locations[@]}"; do
    for search_type in "${search_types[@]}"; do
        import_venues "$location" "$search_type" 8000
    done
done

# Get final statistics
venue_stats=$(curl -s http://localhost:3001/api/venues/stats 2>/dev/null || echo '{}')

if [ $? -eq 0 ]; then
    total_venues=$(echo "$venue_stats" | jq -r '.total_venues // 0' 2>/dev/null || echo "0")
    google_venues=$(echo "$venue_stats" | jq -r '.google_venues // 0' 2>/dev/null || echo "0")
    avg_rating=$(echo "$venue_stats" | jq -r '.average_rating // "N/A"' 2>/dev/null || echo "N/A")
    
    echo
    print_status "Venue Population Complete!"
    print_info "📊 Total venues in database: $total_venues"
    print_info "🗺️  Venues from Google Places: $google_venues" 
    print_info "⭐ Average Google rating: $avg_rating"
    print_info "📥 Venues imported this session: $total_imported"
    
    if [ $failed_requests -gt 0 ]; then
        print_warning "⚠️  Failed requests: $failed_requests"
    fi
else
    print_warning "Could not retrieve final statistics"
fi

echo
print_info "🎯 Next Steps:"
print_info "• View venues: curl http://localhost:3001/api/venues"
print_info "• Check pgAdmin: http://localhost:5050"
print_info "• Import more areas by running this script again with different locations"
echo
print_info "To add more venues later:"
print_info "curl -X POST \"http://localhost:3001/api/venues/import/google-places\" \\"
print_info "  -H \"Content-Type: application/json\" \\"
print_info "  -d '{\"location\": \"Your City, State\", \"radius\": 10000}'"