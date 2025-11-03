#!/bin/bash

# Football Home Development Environment Manager

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Start the database environment
start() {
    print_status "Starting Football Home development environment..."
    check_docker
    
    # Create network if it doesn't exist
    docker network create footballhome_network 2>/dev/null || true
    
    # Start services
    docker compose up -d
    
    print_status "Waiting for database to be ready..."
    sleep 5
    
    # Check database health
    if docker compose exec -T db pg_isready -U footballhome_user -d footballhome >/dev/null 2>&1; then
        print_success "Database is ready!"
    else
        print_warning "Database may still be initializing. Please wait a moment."
    fi
    
    echo ""
    print_success "Football Home development environment is running!"
    echo ""
    echo "📋 Service URLs:"
    echo "  🗄️  Database:  postgresql://footballhome_user:footballhome_pass@localhost:5432/footballhome"
    echo "  🔧 pgAdmin:   http://localhost:5050"
    echo ""
    echo "📝 pgAdmin Login:"
    echo "  Email:    admin@footballhome.local"
    echo "  Password: admin123"
    echo ""
    echo "Use './dev.sh logs' to view logs"
    echo "Use './dev.sh stop' to stop services"
}

# Stop the environment
stop() {
    print_status "Stopping Football Home development environment..."
    docker compose down
    print_success "Environment stopped."
}

# Show logs
logs() {
    print_status "Showing logs (Press Ctrl+C to exit)..."
    docker compose logs -f
}

# Show status
status() {
    print_status "Football Home Development Environment Status:"
    echo ""
    docker compose ps
    echo ""
    
    # Check database connection
    if docker compose exec -T db pg_isready -U footballhome_user -d footballhome >/dev/null 2>&1; then
        print_success "✅ Database is healthy"
    else
        print_warning "⚠️  Database is not responding"
    fi
    
    # Check if pgAdmin is responding
    if curl -s http://localhost:5050 >/dev/null 2>&1; then
        print_success "✅ pgAdmin is accessible"
    else
        print_warning "⚠️  pgAdmin is not responding"
    fi
}

# Reset database (removes all data and recreates)
reset() {
    print_warning "This will delete ALL database data. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Resetting database..."
        docker compose down -v  # Remove volumes
        docker compose up -d
        print_success "Database reset complete!"
    else
        print_status "Reset cancelled."
    fi
}

# Connect to database via psql
connect() {
    print_status "Connecting to database..."
    docker compose exec db psql -U footballhome_user -d footballhome
}

# Show help
help() {
    echo "Football Home Development Environment Manager"
    echo ""
    echo "Usage: ./dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     Start the development environment"
    echo "  stop      Stop the development environment" 
    echo "  restart   Restart the development environment"
    echo "  logs      Show service logs"
    echo "  status    Show service status"
    echo "  reset     Reset database (deletes all data)"
    echo "  connect   Connect to database via psql"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./dev.sh start"
    echo "  ./dev.sh logs"
    echo "  ./dev.sh connect"
}

# Handle script arguments
case "${1:-}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 2
        start
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    reset)
        reset
        ;;
    connect)
        connect
        ;;
    help|--help|-h)
        help
        ;;
    "")
        print_error "No command specified. Use './dev.sh help' for usage."
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        print_status "Use './dev.sh help' for usage."
        exit 1
        ;;
esac