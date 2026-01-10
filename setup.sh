#!/bin/bash
# Football Home - First-Time Setup Script
#
# This script installs all system dependencies needed to run the application.
# Run this ONCE when first cloning the repository.
#
# After this script completes, use:
#   ./build.sh            # Full rebuild (destroys containers/volumes)
#   ./update.sh           # Run scrapers to populate/update data
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
export PATH="$PYTHON_USER_BIN:$PATH"

if ! command -v podman-compose &> /dev/null; then
    print_warning "podman-compose not found, installing..."
    
    INSTALLED=false
    
    # 1. Try system package manager (apt/brew)
    if [ "$OS_TYPE" == "Linux" ]; then
        print_status "Attempting to install podman-compose via apt..."
        # Check if package exists before trying to install to avoid error messages
        if sudo apt-cache show podman-compose &>/dev/null; then
            if sudo apt-get update && sudo apt-get install -y podman-compose; then
                INSTALLED=true
                print_success "Installed podman-compose via apt"
            fi
        fi
    elif [ "$OS_TYPE" == "Darwin" ]; then
        print_status "Attempting to install podman-compose via brew..."
        if brew install podman-compose; then
            INSTALLED=true
            print_success "Installed podman-compose via brew"
        fi
    fi
    
    # 2. Try pipx if system install failed
    if [ "$INSTALLED" = false ]; then
        # Try pipx first (recommended for managed environments like Debian 12/Ubuntu 24.04)
        if ! command -v pipx &> /dev/null; then
            print_status "Installing pipx..."
            if [ "$OS_TYPE" == "Linux" ]; then
                sudo apt-get update
                sudo apt-get install -y pipx || echo "pipx install failed, will try pip fallback"
            elif [ "$OS_TYPE" == "Darwin" ]; then
                brew install pipx
            fi
        fi

        if command -v pipx &> /dev/null; then
            print_status "Installing podman-compose via pipx..."
            if pipx install podman-compose; then
                INSTALLED=true
                # Ensure pipx bin path is in PATH (usually ~/.local/bin)
                export PATH="$HOME/.local/bin:$PATH"
                print_success "Installed podman-compose via pipx"
            fi
        fi
    fi

    # 3. Fallback to pip
    if [ "$INSTALLED" = false ]; then
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
        
        print_status "Installing podman-compose via pip..."
        # Try with --break-system-packages for newer pip versions in managed envs
        if pip3 install --user podman-compose --break-system-packages 2>/dev/null || \
           pip3 install --user podman-compose 2>/dev/null || \
           pip install --user podman-compose; then
            INSTALLED=true
            
            # Ensure the binary is executable and in path
            PYTHON_USER_BIN=$(python3 -m site --user-base)/bin
            export PATH="$PYTHON_USER_BIN:$PATH"
            
            if ! command -v podman-compose &> /dev/null; then
                print_warning "podman-compose installed but not found in PATH. Adding to .bashrc/.zshrc..."
                for rcfile in ~/.zshrc ~/.bashrc ~/.bash_profile; do
                    if [ -f "$rcfile" ]; then
                        if ! grep -q "# Python user packages" "$rcfile" 2>/dev/null; then
                            echo "" >> "$rcfile"
                            echo "# Python user packages" >> "$rcfile"
                            echo "export PATH=\"$PYTHON_USER_BIN:\$PATH\"" >> "$rcfile"
                        fi
                    fi
                done
            fi

            print_success "Installed podman-compose via pip"
        else
            print_error "Failed to install podman-compose. Please install it manually."
            exit 1
        fi
    fi
    
    # Refresh PATH after install
    export PATH="$PYTHON_USER_BIN:$PATH"
    
    # Persist PATH change to shell config files
    for rcfile in ~/.zshrc ~/.bashrc ~/.bash_profile; do
        if [ -f "$rcfile" ]; then
            if ! grep -q "# Python user packages" "$rcfile" 2>/dev/null; then
                echo "" >> "$rcfile"
                echo "# Python user packages" >> "$rcfile"
                echo "export PATH=\"$PYTHON_USER_BIN:\$PATH\"" >> "$rcfile"
            fi
        fi
    done
    
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
# Step 3.5: Ensure Puppeteer and plugins are installed
# ============================================================
print_status "Ensuring Puppeteer and plugins are installed..."
if [ -f "package.json" ]; then
    npm install --silent puppeteer puppeteer-extra puppeteer-extra-plugin-stealth || {
        print_error "Failed to install Puppeteer dependencies. Please check your npm setup."
        exit 1
    }
    print_success "Puppeteer and plugins installed"
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
# Step 4.3: Docker Hub Authentication (to avoid rate limits)
# ============================================================
print_status "Checking Docker Hub authentication..."

# Check if already logged in
if podman login --get-login docker.io &> /dev/null; then
    DOCKER_USER=$(podman login --get-login docker.io)
    print_success "Already logged in to Docker Hub as: $DOCKER_USER"
else
    # Try to login from env file if credentials exist
    if [ -f env ]; then
        source ./env
        if [ -n "$DOCKER_HUB_USERNAME" ] && [ -n "$DOCKER_HUB_TOKEN" ]; then
            print_status "Logging in to Docker Hub from env file..."
            echo "$DOCKER_HUB_TOKEN" | podman login docker.io -u "$DOCKER_HUB_USERNAME" --password-stdin &> /dev/null
            if [ $? -eq 0 ]; then
                print_success "Successfully logged in to Docker Hub"
            else
                print_warning "Login failed - check credentials in env file"
            fi
        else
            print_warning "No Docker Hub credentials in env file"
            echo ""
            echo "To avoid rate limits, add to your env file:"
            echo "  DOCKER_HUB_USERNAME=your_username"
            echo "  DOCKER_HUB_TOKEN=your_access_token"
            echo ""
            echo "Get a token from: https://hub.docker.com/settings/security"
        fi
    fi
fi

# ============================================================
# Step 4.5: Create env file
# ============================================================
print_status "Setting up env file..."

if [ -f env ]; then
    print_warning "env file already exists, skipping creation."
    print_status "If you want to reset it, delete it and run setup.sh again."
else
    print_status "Creating fresh env template..."
    cat > env << 'EOF'
# Football Home Environment Variables
# Created by setup.sh

# Docker Hub Authentication (to avoid rate limits)
# Get a free account at: https://hub.docker.com/signup
# Generate token at: https://hub.docker.com/settings/security
DOCKER_HUB_USERNAME=
DOCKER_HUB_TOKEN=

# Twilio SMS (optional - for SMS notifications)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_PHONE=

# Google OAuth (optional - for Google login)
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=
GOOGLE_OAUTH_REDIRECT_URI=http://localhost:3000/oauth/google/callback
EOF
    print_success "env file created successfully"
    echo ""
    print_warning "Optional: Edit env to add Docker Hub, Twilio, or Google credentials"
    echo "  • Docker Hub: To avoid rate limits (100 anon vs 200 authenticated pulls/6 hours)"
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
# Step 6: Optional AI Development Tools
# ============================================================
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Optional: AI Development Tools${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Install AI coding assistants for terminal use?"
echo "  • Claude CLI - Quick Q&A with Claude"
echo "  • Aider - Full agent mode (edits files)"
echo ""
read -p "Install AI dev tools? (y/n): " install_ai

if [[ "$install_ai" == "y" ]]; then
    echo ""
    print_status "Setting up Claude CLI..."
    if ./scripts/setup/setup-claude.sh; then
        print_success "Claude CLI installed"
    else
        print_warning "Claude CLI setup skipped or failed"
    fi
    
    echo ""
    print_status "Setting up Aider..."
    if 
echo "Optional AI tools (if installed):"
echo "  • Quick Q&A:     ./claude query \"your question\""
echo "  • Chat mode:     ./claude chat"
echo "  • Agent mode:    ./aider"
echo ""./scripts/setup/setup-aider.sh; then
        print_success "Aider installed"
    else
        print_warning "Aider setup skipped or failed"
    fi
else
    print_status "Skipping AI tools (you can run ./scripts/setup/setup-claude.sh later)"
fi

# ============================================================
# Step 7: Success and Next Steps
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
echo "  1. Build and start containers:"
echo -e "     ${YELLOW}./build.sh${NC}"
echo ""
echo "  2. Populate data (run scrapers):"
echo -e "     ${YELLOW}./update.sh${NC}"
echo ""
echo "  3. Once running, open in your browser:"
echo -e "     ${YELLOW}http://localhost:3000${NC}"
echo ""
echo "  4. Log in with credentials:"
echo "     Email:    soccer@lighthouse1893.org"
echo "     Password: 1893Soccer!"
echo "     Name:     James Breslin"
echo ""
