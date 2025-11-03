#!/bin/bash

# Football Home - Automated Setup Script
# This script installs all required dependencies and sets up the system

set -e  # Exit on any error

echo "🚀 Football Home - Automated Setup Starting..."
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running on supported OS
check_os() {
    print_info "Checking operating system..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_status "Detected Linux OS"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_status "Detected macOS"
    else
        print_error "Unsupported OS: $OSTYPE"
        print_info "This script supports Linux and macOS only"
        exit 1
    fi
}

# Install Docker
install_docker() {
    print_info "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_warning "Docker already installed: $(docker --version)"
        return
    fi
    
    if [[ "$OS" == "linux" ]]; then
        sudo apt update
        sudo apt install -y docker.io docker-compose-plugin
        sudo usermod -aG docker $USER
        print_status "Docker installed successfully"
        print_warning "Please log out and back in to use Docker without sudo"
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew not found. Please install Homebrew first:"
            print_info "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        brew install docker docker-compose
        print_status "Docker installed successfully"
    fi
}

# Install Node.js
install_nodejs() {
    print_info "Installing Node.js..."
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_warning "Node.js already installed: $NODE_VERSION"
        
        # Check if version is 18.x
        if [[ $NODE_VERSION == v18* ]]; then
            print_status "Node.js version is compatible"
            return
        else
            print_warning "Node.js version should be 18.x for best compatibility"
        fi
        return
    fi
    
    if [[ "$OS" == "linux" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [[ "$OS" == "macos" ]]; then
        brew install node@18
    fi
    
    print_status "Node.js installed: $(node --version)"
}

# Install additional tools
install_tools() {
    print_info "Installing additional tools..."
    
    if [[ "$OS" == "linux" ]]; then
        sudo apt install -y git postgresql-client jq curl
    elif [[ "$OS" == "macos" ]]; then
        brew install git postgresql jq curl
    fi
    
    print_status "Additional tools installed"
}

# Setup project
setup_project() {
    print_info "Setting up project structure..."
    
    # Check if we're in the project directory
    if [[ ! -f "docker-compose.yml" ]]; then
        print_error "Please run this script from the Football Home project root directory"
        exit 1
    fi
    
    # Create .env from example if it doesn't exist
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            print_status "Created .env file from .env.example"
            print_warning "Please edit .env file with your Google Maps API key and other settings"
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_warning ".env file already exists"
    fi
    
    # Install backend dependencies
    if [[ -d "backend" ]]; then
        print_info "Installing backend dependencies..."
        cd backend
        npm install
        cd ..
        print_status "Backend dependencies installed"
    fi
}

# Start services
start_services() {
    print_info "Starting Docker services..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not available. Please restart your terminal or log out/in"
        return
    fi
    
    # Start database services
    docker compose up -d footballhome_db footballhome_pgadmin
    
    print_status "Database services started"
    print_info "Waiting for database to be ready..."
    sleep 10
    
    # Check if database is accessible
    if docker exec footballhome_db pg_isready -U footballhome_user > /dev/null 2>&1; then
        print_status "Database is ready"
    else
        print_warning "Database may still be starting up. Please wait a few more seconds."
    fi
}

# Verify installation
verify_installation() {
    print_info "Verifying installation..."
    
    # Check Docker
    if docker --version > /dev/null 2>&1; then
        print_status "Docker: $(docker --version)"
    else
        print_error "Docker verification failed"
    fi
    
    # Check Node.js
    if node --version > /dev/null 2>&1; then
        print_status "Node.js: $(node --version)"
    else
        print_error "Node.js verification failed"
    fi
    
    # Check database
    if docker ps | grep -q footballhome_db; then
        print_status "Database container running"
    else
        print_error "Database container not running"
    fi
    
    # Check if .env exists and has Google Maps key
    if [[ -f ".env" ]]; then
        if grep -q "GOOGLE_MAPS_API_KEY=your_actual_api_key_here" .env; then
            print_warning "Please update your Google Maps API key in .env file"
        elif grep -q "GOOGLE_MAPS_API_KEY=AIza" .env; then
            print_status "Google Maps API key found in .env"
        fi
    fi
}

# Test the system
test_system() {
    print_info "Testing system components..."
    
    # Start backend server in background for testing
    if [[ -f "backend/server.js" ]]; then
        cd backend
        timeout 10 node server.js &
        SERVER_PID=$!
        cd ..
        
        sleep 3
        
        # Test health endpoint
        if curl -s http://localhost:3001/health > /dev/null 2>&1; then
            print_status "Backend server responds to health check"
        else
            print_warning "Backend server may not be ready yet"
        fi
        
        # Kill test server
        kill $SERVER_PID 2>/dev/null || true
    fi
}

# Main execution
main() {
    echo
    print_info "Starting Football Home setup process..."
    echo
    
    check_os
    echo
    
    install_docker
    echo
    
    install_nodejs
    echo
    
    install_tools
    echo
    
    setup_project
    echo
    
    start_services
    echo
    
    verify_installation
    echo
    
    test_system
    echo
    
    print_status "Setup completed!"
    echo
    print_info "Next steps:"
    print_info "1. Edit .env file with your Google Maps API key"
    print_info "2. Start the backend server: cd backend && node server.js"
    print_info "3. (Optional) Populate Google venue data: ./scripts/populate-google-venues.sh"
    print_info "4. Access pgAdmin at: http://localhost:5050"
    print_info "5. Test API at: http://localhost:3001/health"
    echo
    print_info "For detailed information, see DEPLOYMENT_GUIDE.md"
    echo
}

# Run main function
main "$@"
