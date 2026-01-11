#!/bin/bash
# Setup Aider - AI pair programming in your terminal
#
# Usage:
#   ./scripts/setup/setup-aider.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Python/pip is installed
check_python() {
    if ! command_exists python3; then
        print_error "Python 3 is not installed"
        print_info "Install Python 3:"
        print_info "  macOS: brew install python3"
        print_info "  Ubuntu/Debian: sudo apt-get install python3 python3-pip"
        exit 1
    fi
    print_success "Python 3 found: $(python3 --version)"
    
    if ! command_exists pip3; then
        print_error "pip3 is not installed"
        print_info "Install pip3:"
        print_info "  macOS: python3 -m ensurepip"
        print_info "  Ubuntu/Debian: sudo apt-get install python3-pip"
        exit 1
    fi
    print_success "pip3 found"
}

# Check for Anthropic API key
check_api_key() {
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        print_warning "ANTHROPIC_API_KEY not set - Aider will need manual configuration"
        return
    fi
    
    local masked_key="${ANTHROPIC_API_KEY:0:12}...${ANTHROPIC_API_KEY: -8}"
    print_success "Found API key: $masked_key"
}

# Install Aider
install_aider() {
    print_info "Installing Aider..."
    
    if command_exists aider; then
        print_success "Aider already installed: $(aider --version | head -1)"
        # Skip upgrade - user can manually upgrade if needed
    else
        pip3 install aider-chat
        print_success "Aider installed successfully"
    fi
}

# Configure Aider
configure_aider() {
    print_info "Configuring Aider for Claude..."
    
    local shell_profile=""
    
    # Detect shell and profile file
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_profile="$HOME/.bashrc"
    else
        shell_profile="$HOME/.profile"
    fi
    
    # Check if already configured
    if grep -q "AIDER_MODEL" "$shell_profile" 2>/dev/null; then
        print_success "Aider already configured in $shell_profile"
    else
        echo "" >> "$shell_profile"
        echo "# Aider AI configuration" >> "$shell_profile"
        echo "export AIDER_MODEL=claude-sonnet-4-20250514" >> "$shell_profile"
        echo "export AIDER_DARK_MODE=true" >> "$shell_profile"
        
        print_success "Aider configured in $shell_profile"
    fi
    
    # Export for current session
    export AIDER_MODEL=claude-sonnet-4-20250514
    export AIDER_DARK_MODE=true
}

# Create convenience wrapper
create_wrapper() {
    local wrapper="$PROJECT_ROOT/aider"
    
    print_info "Creating Aider wrapper at root..."
    
    cat > "$wrapper" << 'EOFWRAPPER'
#!/bin/bash
# Aider wrapper - AI pair programming with Claude
#
# Usage:
#   ./aider                    # Start in current directory
#   ./aider file1.cpp file2.h  # Start with specific files
#   ./aider --help             # See all options

# Ensure we're in project root
cd "$(dirname "$0")"

# Check for API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "\033[0;31m✗\033[0m ANTHROPIC_API_KEY not set"
    echo -e "\033[0;34mℹ\033[0m Run: ./scripts/setup/setup-aider.sh"
    exit 1
fi

# Run aider with Claude
exec aider \
    --model claude-sonnet-4-20250514 \
    --dark-mode \
    --no-auto-commits \
    "$@"
EOFWRAPPER
    
    chmod +x "$wrapper"
    print_success "Created $wrapper"
}

# Create .aider.conf.yml
create_config() {
    local config="$PROJECT_ROOT/.aider.conf.yml"
    
    if [ -f "$config" ]; then
        print_success ".aider.conf.yml already exists"
        return
    fi
    
    print_info "Creating .aider.conf.yml..."
    
    cat > "$config" << 'EOFCONFIG'
# Aider configuration for Football Home
model: claude-sonnet-4-20250514
dark-mode: true
no-auto-commits: true
pretty: true
stream: true

# Context files (always included)
read:
  - README.md
  - .github/copilot-instructions.md

# Ignore patterns
ignore:
  - node_modules/
  - build/
  - .git/
  - "*.log"
  - "*.pyc"
  - __pycache__/
  - dist/
  - .vscode/
EOFCONFIG
    
    print_success "Created .aider.conf.yml"
}

# Test Aider
test_aider() {
    print_info "Testing Aider installation..."
    echo ""
    
    if aider --version >/dev/null 2>&1; then
        print_success "Aider is working!"
        echo ""
        aider --version
        echo ""
    else
        print_error "Aider test failed"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo ""
    print_success "✨ Aider setup complete!"
    echo ""
    
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        print_info "To configure your API key:"
        echo ""
        echo -e "  1. Add to ${GREEN}~/.zshrc${NC}:"
        echo -e "     ${GREEN}export ANTHROPIC_API_KEY='your-api-key-here'${NC}"
        echo ""
        echo -e "  2. Then reload: ${GREEN}source ~/.zshrc${NC}"
        echo ""
    fi
    
    print_info "How to use Aider:"
    echo ""
    echo -e "  ${GREEN}./aider${NC}"
    echo "    - Start interactive session (AI can edit any file)"
    echo ""
    echo -e "  ${GREEN}./aider src/main.cpp backend/src/Router.cpp${NC}"
    echo "    - Start with specific files in context"
    echo ""
    echo -e "  ${GREEN}./aider --help${NC}"
    echo "    - See all options"
    echo ""
    print_info "Example session:"
    echo ""
    echo "  ${BLUE}You:${NC} Add error handling to the Router class"
    echo "  ${GREEN}Aider:${NC} [edits files, shows diff, asks to confirm]"
    echo ""
    print_info "Aider features:"
    echo "  ✓ Edits files directly (with your approval)"
    echo "  ✓ Understands entire codebase"
    echo "  ✓ Multi-file refactoring"
    echo "  ✓ Git integration"
    echo "  ✓ Uses Claude Sonnet 4"
    echo ""
}

# Main
main() {
    echo ""
    print_info "🤖 Aider Setup - AI Pair Programming with Claude"
    echo ""
    
    check_python
    echo ""
    
    check_api_key
    echo ""
    
    install_aider
    echo ""
    
    configure_aider
    echo ""
    
    create_wrapper
    echo ""
    
    create_config
    echo ""
    
    test_aider
    
    show_usage
}

main
