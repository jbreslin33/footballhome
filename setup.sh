#!/bin/bash

# Football Home - Complete Setup Script
# This script installs dependencies and starts the soccer team management PWA

set -e  # Exit on any error

echo "🏈 Football Home Setup Script 🏈"
echo "================================="

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "ubuntu"
        elif command -v dnf &> /dev/null; then
            echo "fedora"
        elif command -v yum &> /dev/null; then
            echo "rhel"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to install Podman
install_podman() {
    local os=$(detect_os)
    echo "📦 Installing Podman for $os..."
    
    case $os in
        "ubuntu")
            sudo apt-get update
            sudo apt-get install -y podman podman-compose
            ;;
        "fedora")
            sudo dnf install -y podman podman-compose
            ;;
        "rhel")
            sudo yum install -y podman podman-compose
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install podman podman-compose
                echo "🔧 Initializing Podman VM..."
                podman machine init --now || true
                podman machine start || true
            else
                echo "❌ Please install Homebrew first: https://brew.sh/"
                exit 1
            fi
            ;;
        *)
            echo "❌ Unsupported OS. Please install Podman manually."
            echo "Visit: https://podman.io/getting-started/installation"
            exit 1
            ;;
    esac
}

# Function to install Docker as fallback
install_docker() {
    local os=$(detect_os)
    echo "📦 Installing Docker as fallback for $os..."
    
    case $os in
        "ubuntu")
            sudo apt-get update
            sudo apt-get install -y docker.io docker-compose
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker $USER
            echo "⚠️  You may need to log out and back in for Docker permissions"
            ;;
        "fedora"|"rhel")
            sudo dnf install -y docker docker-compose
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker $USER
            echo "⚠️  You may need to log out and back in for Docker permissions"
            ;;
        "macos")
            echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
            echo "Then re-run this script."
            exit 1
            ;;
        *)
            echo "❌ Please install Docker manually for your OS"
            exit 1
            ;;
    esac
}

# Check if Podman is available
check_podman() {
    if command -v podman &> /dev/null && command -v podman-compose &> /dev/null; then
        echo "✅ Podman and podman-compose found"
        return 0
    else
        return 1
    fi
}

# Check if Docker is available
check_docker() {
    if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        echo "✅ Docker and docker-compose found"
        return 0
    else
        return 1
    fi
}

# Function to build and start the project
start_project() {
    local use_podman=$1
    
    echo "🏗️  Building and starting Football Home..."
    
    if [ "$use_podman" = true ]; then
        echo "Using Podman..."
        podman-compose down || true  # Don't fail if nothing to stop
        podman-compose up -d --build
        COMPOSE_CMD="podman-compose"
    else
        echo "Using Docker..."
        docker-compose down || true  # Don't fail if nothing to stop
        docker-compose up -d --build
        COMPOSE_CMD="docker-compose"
    fi
    
    echo "⏳ Waiting for services to start..."
    sleep 10
    
    # Check if services are running
    echo "🔍 Checking services..."
    
    # Test database
    if curl -f -s http://localhost:3000/api/health > /dev/null 2>&1; then
        echo "✅ API service is running"
    else
        echo "❌ API service not responding"
        echo "Checking logs..."
        $COMPOSE_CMD logs api
        return 1
    fi
    
    # Test frontend
    if curl -f -s http://localhost > /dev/null 2>&1; then
        echo "✅ Frontend service is running"
    else
        echo "❌ Frontend service not responding"
        echo "Checking logs..."
        $COMPOSE_CMD logs web
        return 1
    fi
}

# Function to show final instructions
show_success() {
    echo ""
    echo "🎉 SUCCESS! Football Home is now running!"
    echo "=========================================="
    echo ""
    echo "🌐 Access your soccer team management app:"
    echo "   Frontend: http://localhost"
    echo "   API:      http://localhost:3000"
    echo ""
    echo "📋 What you have:"
    echo "   • Complete PWA with offline support"
    echo "   • Thunder FC sample team with events"
    echo "   • 3 sample events ready to test"
    echo "   • Coach and player accounts"
    echo ""
    echo "🔧 Management commands:"
    if command -v podman-compose &> /dev/null; then
        echo "   Stop:     podman-compose down"
        echo "   Start:    podman-compose up -d"
        echo "   Logs:     podman-compose logs"
        echo "   Rebuild:  podman-compose up -d --build"
    else
        echo "   Stop:     docker-compose down"
        echo "   Start:    docker-compose up -d"
        echo "   Logs:     docker-compose logs"
        echo "   Rebuild:  docker-compose up -d --build"
    fi
    echo ""
    echo "🏈 Ready to manage your soccer team!"
}

# Main script execution
main() {
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        echo "❌ docker-compose.yml not found. Please run this script from the footballhome directory."
        exit 1
    fi
    
    # Check for container runtime
    USE_PODMAN=false
    
    if check_podman; then
        USE_PODMAN=true
    elif check_docker; then
        USE_PODMAN=false
    else
        echo "📦 No container runtime found. Installing..."
        read -p "Install Podman (recommended) or Docker? [P/d]: " choice
        case $choice in
            [Dd]* ) 
                install_docker
                USE_PODMAN=false
                ;;
            * ) 
                install_podman
                USE_PODMAN=true
                ;;
        esac
    fi
    
    # Start the project
    if start_project $USE_PODMAN; then
        show_success
    else
        echo "❌ Setup failed. Check the logs above for details."
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Football Home Setup Script"
        echo "Usage: $0 [--help]"
        echo ""
        echo "This script will:"
        echo "1. Install Podman or Docker if needed"
        echo "2. Build and start all services"
        echo "3. Verify everything is working"
        echo ""
        echo "Run without arguments to start the interactive setup."
        exit 0
        ;;
    *)
        main
        ;;
esac