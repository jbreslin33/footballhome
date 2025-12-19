#!/bin/bash
# Football Home - First-Time Setup Script
#
# This script installs all system dependencies needed to run the application.
# Run this ONCE when first cloning the repository.
#
# After this script completes, use:
#   ./dev.sh              # Full rebuild with data scraping
#   ./dev.sh --quick      # Quick restart after code changes
#   ./dev.sh --replay-only # Fast rebuild from saved state
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - First-Time Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running on macOS or Linux
OS_TYPE=$(uname -s)

# Request sudo access early for Linux systems
if [ "$OS_TYPE" == "Linux" ] && [ "$EUID" -ne 0 ]; then
    print_status "Requesting sudo access for package installation..."
    sudo -v
fi

# ============================================================
# Step 0: Install curl if missing (needed for Docker install)
# ============================================================
if ! command -v curl &> /dev/null; then
    print_status "Installing curl (required for Docker installation)..."
    
    if [ "$OS_TYPE" == "Linux" ]; then
        sudo apt-get update > /dev/null 2>&1
        sudo apt-get install -y curl > /dev/null 2>&1
    elif [ "$OS_TYPE" == "Darwin" ]; then
        # curl should be pre-installed on macOS, but just in case
        if ! command -v brew &> /dev/null; then
            print_error "curl not found and Homebrew not available"
            print_error "Please install Homebrew from: https://brew.sh"
            exit 1
        fi
        brew install curl
    fi
    print_success "curl installed"
fi

# ============================================================
# Step 1: Install/Check Docker
# ============================================================
print_status "Checking Docker..."

if ! command -v docker &> /dev/null; then
    print_warning "Docker not found, installing..."
    
    if [ "$OS_TYPE" == "Linux" ]; then
        print_status "Running Docker installation script..."
        curl -fsSL https://get.docker.com | sh
        
        print_status "Adding current user to docker group..."
        sudo usermod -aG docker $USER
        
        print_warning "You may need to log out and log back in for docker group permissions to take effect"
        print_warning "Or run: newgrp docker"
        
        print_status "Starting Docker service..."
        sudo systemctl start docker || true
        sudo systemctl enable docker || true
    elif [ "$OS_TYPE" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew is required to install Docker Desktop"
            echo ""
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo ""
            echo "Then re-run this setup script, or install Docker Desktop manually:"
            echo "  https://docs.docker.com/desktop/install/mac-install/"
            exit 1
        fi
        
        print_status "Installing Docker Desktop via Homebrew..."
        brew install --cask docker
        
        print_success "Docker Desktop installed"
        print_warning "Please start Docker Desktop from Applications and wait for it to finish starting"
        print_warning "Then re-run this setup script to continue"
        echo ""
        echo "Starting Docker Desktop now..."
        open -a Docker
        echo ""
        echo "Waiting for Docker to start (this may take a minute)..."
        
        # Wait for Docker daemon to be ready (max 60 seconds)
        for i in {1..60}; do
            if docker ps &> /dev/null; then
                print_success "Docker is now running!"
                break
            fi
            sleep 1
            echo -n "."
        done
        echo ""
        
        if ! docker ps &> /dev/null; then
            print_warning "Docker Desktop is installed but not yet running"
            echo ""
            echo "Please:"
            echo "  1. Make sure Docker Desktop has finished starting"
            echo "  2. Accept any permission prompts"
            echo "  3. Re-run this setup script"
            echo ""
            exit 1
        fi
    else
        print_error "Unsupported operating system: $OS_TYPE"
        exit 1
    fi
else
    print_success "Docker is installed: $(docker --version)"
fi

# ============================================================
# Step 2: Install/Check Docker Compose
# ============================================================
print_status "Checking Docker Compose..."

if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose not found, installing..."
    
    if [ "$OS_TYPE" == "Linux" ]; then
        print_status "Installing docker-compose-plugin..."
        sudo apt-get update
        sudo apt-get install -y docker-compose-plugin
    elif [ "$OS_TYPE" == "Darwin" ]; then
        print_status "Installing Docker Compose via Homebrew..."
        brew install docker-compose
        print_success "Docker Compose installed"
    fi
else
    print_success "Docker Compose is installed"
fi

# ============================================================
# Step 3: Install/Check Node.js
# ============================================================
print_status "Checking Node.js..."

if ! command -v node &> /dev/null; then
    print_warning "Node.js not found, installing..."
    
    if [ "$OS_TYPE" == "Linux" ]; then
        print_status "Installing Node.js 20.x..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [ "$OS_TYPE" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew not found"
            echo ""
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo ""
            echo "Or visit: https://brew.sh"
            exit 1
        fi
        print_status "Installing Node.js via Homebrew..."
        brew install node@20
        # Add node@20 to PATH if needed
        if [[ ":$PATH:" != *":/opt/homebrew/opt/node@20/bin:"* ]] && [[ ":$PATH:" != *":/usr/local/opt/node@20/bin:"* ]]; then
            if [ -d "/opt/homebrew/opt/node@20/bin" ]; then
                echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
                export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
            elif [ -d "/usr/local/opt/node@20/bin" ]; then
                echo 'export PATH="/usr/local/opt/node@20/bin:$PATH"' >> ~/.zshrc
                export PATH="/usr/local/opt/node@20/bin:$PATH"
            fi
        fi
    fi
    print_success "Node.js installed: $(node --version)"
else
    print_success "Node.js is installed: $(node --version)"
fi

# ============================================================
# Step 4: Install git-crypt for encrypted credentials
# ============================================================
print_status "Checking for git-crypt..."

if ! command -v git-crypt &> /dev/null; then
    print_warning "git-crypt not found, installing..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        print_status "Installing git-crypt via Homebrew..."
        brew install git-crypt
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
            print_status "Installing git-crypt via apt..."
            sudo apt-get update > /dev/null 2>&1
            sudo apt-get install -y git-crypt
        elif command -v yum &> /dev/null; then
            print_status "Installing git-crypt via yum..."
            sudo yum install -y git-crypt
        fi
    fi
    print_success "git-crypt installed"
else
    print_success "git-crypt is installed: $(git-crypt --version | head -1)"
fi

# ============================================================
# Step 5: Install Node Dependencies
# ============================================================
print_status "Installing Node.js dependencies..."

if [ -f "package.json" ]; then
    npm install --silent
    print_success "Node dependencies installed"
fi

# ============================================================
# Step 6: Configure Docker Group Permissions (Linux)
# ============================================================
if [ "$OS_TYPE" == "Linux" ]; then
    print_status "Configuring Docker group permissions..."
    
    # Check if docker group exists
    if ! getent group docker > /dev/null; then
        print_status "Creating docker group..."
        sudo groupadd docker
    fi
    
    # Add current user to docker group
    if ! id -nG "$USER" | grep -qw docker; then
        print_status "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
        
        print_warning "Docker group added"
        print_warning "You must log out and log back in for permissions to take effect"
        print_warning ""
        print_warning "Quick fix without logout (run this):"
        print_warning "  exec su -l \$USER"
        print_warning ""
        print_status "Attempting to switch to docker group in this session..."
        
        # Try to apply in current session
        if ! newgrp docker <<ENDOFGROUP
sleep 1
ENDOFGROUP
        then
            print_warning "Could not apply in current session - you must log out/in"
        fi
    else
        print_success "Docker group permissions configured"
    fi
    
    # Fix socket permissions as additional safety measure
    if [ -S /var/run/docker.sock ]; then
        sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
    fi
fi

# ============================================================
# Step 6: Verify Docker Daemon is Running
# ============================================================
print_status "Verifying Docker daemon..."

# Try docker command (with sudo if needed on Linux)
DOCKER_CMD="docker"
if ! docker ps &> /dev/null 2>&1; then
    if [ "$OS_TYPE" == "Linux" ]; then
        # If docker fails without sudo on Linux, try with sudo
        if sudo docker ps &> /dev/null 2>&1; then
            DOCKER_CMD="sudo docker"
            print_warning "Docker requires sudo - permissions may need adjustment after login"
        else
            print_error "Docker daemon is not responding"
            echo ""
            echo "Try restarting Docker:"
            echo "  sudo systemctl restart docker"
            exit 1
        fi
    elif [ "$OS_TYPE" == "Darwin" ]; then
        print_error "Docker daemon is not responding"
        echo ""
        echo "Please ensure Docker Desktop is running:"
        echo "  1. Open Docker Desktop from Applications"
        echo "  2. Wait for Docker to fully start"
        echo "  3. Re-run this setup script"
        echo ""
        exit 1
    fi
else
    if [ "$OS_TYPE" == "Linux" ]; then
        print_success "Docker is accessible without sudo"
    else
        print_success "Docker is accessible"
    fi
fi

print_success "Docker daemon is running and accessible"

# ============================================================
# Step 7: Final Verification
# ============================================================
print_status "Running final checks..."

DOCKER_VERSION=$(docker --version 2>/dev/null || echo "unknown")
NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
NPM_VERSION=$(npm --version 2>/dev/null || echo "unknown")

print_success "System ready:"
echo "  • $DOCKER_VERSION"
echo "  • Node.js $NODE_VERSION"
echo "  • npm $NPM_VERSION"

# ============================================================
# Step 8: Success and Next Steps
# ============================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your development environment is ready!"
echo ""
echo "Next steps:"
echo ""
echo "  1. Start the application:"
echo "     ${YELLOW}./dev.sh${NC}"
echo ""
echo "  2. Once running, open in your browser:"
echo "     ${YELLOW}http://localhost:3000${NC}"
echo ""
echo "  3. Log in with demo credentials:"
echo "     Email:    jbreslin@footballhome.org"
echo "     Password: 1893Soccer!"
echo ""
echo "For more information, see DEVELOPMENT.md or run:"
echo "  ${YELLOW}./dev.sh --help${NC}"
echo ""
