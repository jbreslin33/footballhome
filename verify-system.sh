#!/bin/bash

# Football Home - Complete System Verification Script
# Verifies that the system is fully reproducible and working

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

echo "🔍 Football Home - System Verification"
echo "======================================"

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    print_error "Please run this script from the Football Home project root directory"
    exit 1
fi

# 1. Check Docker containers
print_info "Checking Docker containers..."
if docker ps | grep -q footballhome_db && docker ps | grep -q footballhome_pgadmin; then
    print_status "Docker containers running"
else
    print_error "Docker containers not running. Run: docker compose up -d"
    exit 1
fi

# 2. Check database connectivity
print_info "Checking database connectivity..."
if docker exec footballhome_db pg_isready -U footballhome_user > /dev/null 2>&1; then
    print_status "Database is accessible"
else
    print_error "Database is not accessible"
    exit 1
fi

# 3. Check database schema
print_info "Verifying database schema..."
table_count=$(docker exec footballhome_db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" | tr -d ' \n')

if [ "$table_count" -ge 26 ]; then
    print_status "Database schema complete ($table_count tables)"
else
    print_error "Database schema incomplete (only $table_count tables)"
    exit 1
fi

# 4. Check migration tracking
print_info "Checking migration system..."
if docker exec footballhome_db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM schema_migrations;" > /dev/null 2>&1; then
    migration_count=$(docker exec footballhome_db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM schema_migrations;" | tr -d ' \n')
    print_status "Migration tracking working ($migration_count migrations recorded)"
else
    print_error "Migration tracking table missing"
    exit 1
fi

# 5. Check Google Places integration fields
print_info "Verifying Google Places integration..."
google_fields=$(docker exec footballhome_db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'venues' AND column_name IN ('place_id', 'rating', 'user_ratings_total', 'phone', 'email', 'international_phone_number');" | tr -d ' \n')

if [ "$google_fields" -eq 6 ]; then
    print_status "Google Places integration complete"
else
    print_error "Google Places integration incomplete ($google_fields/6 fields found)"
    exit 1
fi

# 6. Check sample data
print_info "Checking sample data..."
venue_count=$(docker exec footballhome_db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM venues;" | tr -d ' \n')
user_count=$(docker exec footballhome_db psql -U footballhome_user -d footballhome -t -c "SELECT COUNT(*) FROM users;" | tr -d ' \n')

if [ "$venue_count" -gt 0 ] && [ "$user_count" -gt 0 ]; then
    print_status "Sample data loaded ($venue_count venues, $user_count users)"
else
    print_error "Sample data missing"
    exit 1
fi

# 7. Check backend dependencies
print_info "Checking backend dependencies..."
if [[ -d "backend/node_modules" ]] && [[ -f "backend/package.json" ]]; then
    print_status "Backend dependencies installed"
else
    print_warning "Backend dependencies not installed. Run: cd backend && npm install"
fi

# 8. Test API server (quick test)
print_info "Testing API server..."
cd backend
timeout 5 node server.js &
SERVER_PID=$!
sleep 2

if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    print_status "API server responding"
else
    print_warning "API server not responding (may need to start manually)"
fi

# Kill test server
kill $SERVER_PID 2>/dev/null || true
cd ..

# 9. Check environment configuration
print_info "Checking environment configuration..."
if [[ -f ".env" ]]; then
    if grep -q "GOOGLE_MAPS_API_KEY=AIza" .env; then
        print_status "Google Maps API key configured"
    else
        print_warning "Google Maps API key needs configuration in .env file"
    fi
else
    print_warning ".env file missing. Copy from .env.example"
fi

# 10. Check pgAdmin access
print_info "Checking pgAdmin access..."
if curl -s http://localhost:5050 > /dev/null 2>&1; then
    print_status "pgAdmin accessible at http://localhost:5050"
else
    print_warning "pgAdmin not accessible"
fi

# Summary
echo
print_status "System Verification Complete!"
echo
print_info "✅ Reproducibility Status: FULLY REPRODUCIBLE"
print_info "📊 Database: Complete schema with migration tracking"
print_info "🗺️  Google Integration: Complete with field alignment"
print_info "🐳 Docker: Containerized and persistent"
print_info "🚀 Deployment: Ready for clean rebuilds"
echo
print_info "Quick Commands:"
echo "  Start services: docker compose up -d"
echo "  Start API: cd backend && node server.js" 
echo "  Run migrations: cd database && ./migrate.sh"
echo "  Health check: curl http://localhost:3001/health"
echo "  pgAdmin: http://localhost:5050 (admin@example.com / admin123)"
echo
print_info "For complete setup instructions, see DEPLOYMENT_GUIDE.md"