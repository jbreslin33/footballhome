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
# Step 1: Install/Check Podman
# ============================================================
print_status "Checking Podman..."

if ! command -v podman &> /dev/null; then
    print_warning "Podman not found, installing..."
    
    if [ "$OS_TYPE" == "Linux" ]; then
        print_status "Installing Podman..."
        sudo apt-get update
        sudo apt-get install -y podman
        
        print_status "Starting Podman socket..."
        systemctl --user enable --now podman.socket || true
    elif [ "$OS_TYPE" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew is required to install Podman"
            echo ""
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo ""
            exit 1
        fi
        
        print_status "Installing Podman via Homebrew..."
        brew install podman
        
        print_status "Initializing Podman machine..."
        podman machine init --cpus=4 --memory=8192 --disk-size=50 2>/dev/null || true
        
        print_status "Starting Podman machine..."
        podman machine start
        
        print_success "Podman installed and started"
    else
        print_error "Unsupported operating system: $OS_TYPE"
        exit 1
    fi
else
    print_success "Podman is installed: $(podman --version)"
    
    # On macOS, ensure podman machine is running
    if [ "$OS_TYPE" == "Darwin" ]; then
        if ! podman machine list | grep -q "Currently running"; then
            print_status "Starting Podman machine..."
            podman machine start
        fi
    fi
fi

# ============================================================
# Step 2: Install/Check Docker Compose (podman-compose)
# ============================================================
print_status "Checking Docker Compose..."

# Add Python user bin to PATH first (in case podman-compose is already installed there)
PYTHON_USER_BIN=$(python3 -m site --user-base)/bin
if [[ ":$PATH:" != *":$PYTHON_USER_BIN:"* ]]; then
    export PATH="$PYTHON_USER_BIN:$PATH"
fi

if ! command -v podman-compose &> /dev/null; then
    print_warning "podman-compose not found, installing..."
    
    # Install podman-compose (Python-based docker-compose for podman)
    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        print_status "Installing pip..."
        if [ "$OS_TYPE" == "Linux" ]; then
            sudo apt-get update
            sudo apt-get install -y python3-pip
        elif [ "$OS_TYPE" == "Darwin" ]; then
            # pip should come with Python on macOS
            if ! command -v python3 &> /dev/null; then
                brew install python3
            fi
        fi
    fi
    
    print_status "Installing podman-compose..."
    pip3 install --user podman-compose 2>/dev/null || pip install --user podman-compose
    
    # Persist PATH change to shell config
    if ! grep -q "PYTHON_USER_BIN" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# Python user packages" >> ~/.zshrc
        echo "export PATH=\"$PYTHON_USER_BIN:\$PATH\"" >> ~/.zshrc
    fi
    
    print_success "podman-compose installed"
else
    print_success "podman-compose is installed"
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
# Step 3: Install Node Dependencies
# ============================================================
print_status "Installing Node.js dependencies..."

if [ -f "package.json" ]; then
    npm install --silent
    print_success "Node dependencies installed"
fi

# ============================================================
# Step 4: Verify Podman is Running
# ============================================================
print_status "Verifying Podman..."

if ! podman ps &> /dev/null 2>&1; then
    if [ "$OS_TYPE" == "Darwin" ]; then
        print_error "Podman machine is not running"
        echo ""
        echo "Try starting it:"
        echo "  podman machine start"
        echo ""
        exit 1
    elif [ "$OS_TYPE" == "Linux" ]; then
        print_error "Podman is not responding"
        echo ""
        echo "Try restarting the socket:"
        echo "  systemctl --user restart podman.socket"
        exit 1
    fi
else
    print_success "Podman is running and accessible"
fi

# ============================================================
# Step 4.5: Create env file
# ============================================================
print_status "Checking env file..."

if [ -f env ]; then
    print_success "env file exists"
else
    print_status "Creating env template..."
    cat > env << 'EOF'
# Football Home Environment Variables
# Created by setup.sh

# Twilio SMS (optional - for SMS notifications)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_PHONE=

# Google OAuth (optional - for Google login)
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=
GOOGLE_OAUTH_REDIRECT_URI=http://localhost:3000/oauth/google/callback
EOF
    print_success "env file created"
    echo ""
    print_warning "Optional: Edit env to add Twilio/Google credentials"
    echo "  • Twilio: For SMS notifications (RSVPs, reminders)"
    echo "  • Google OAuth: For Google sign-in"
    echo ""
fi

# ============================================================
# Step 5: Final Verification
# ============================================================
print_status "Running final checks..."

PODMAN_VERSION=$(podman --version 2>/dev/null || echo "unknown")
NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
NPM_VERSION=$(npm --version 2>/dev/null || echo "unknown")

print_success "System ready:"
echo "  • $PODMAN_VERSION"
echo "  • Node.js $NODE_VERSION"
echo "  • npm $NPM_VERSION"

# ============================================================
# Step 6: Success and Next Steps
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
echo "  3. Log in with credentials:"
echo "     Email:    soccer@lighthouse1893.org"
echo "     Password: 1893Soccer!"
echo "     Name:     James Breslin"
echo ""
echo "For more information, see DEVELOPMENT.md or run:"
echo "  ${YELLOW}./dev.sh --help${NC}"
echo ""
