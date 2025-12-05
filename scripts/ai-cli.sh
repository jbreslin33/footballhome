#!/bin/bash
# AI CLI - Command-line interface for Football Home AI features using GitHub Copilot
#
# Usage:
#   ./scripts/ai-cli.sh install        # Install GitHub Copilot CLI
#   ./scripts/ai-cli.sh chat           # Start interactive chat
#   ./scripts/ai-cli.sh query "text"   # Single query
#   ./scripts/ai-cli.sh help           # Show help

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Change to project root
cd "$(dirname "$0")/.."

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

# Install GitHub CLI and Copilot extension
install_deps() {
    print_info "Installing GitHub Copilot CLI..."
    
    # Check if gh is installed
    if ! command_exists gh; then
        print_warning "GitHub CLI (gh) not found. Installing..."
        
        # Detect OS and install gh
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Check if we're on Ubuntu/Debian
            if command_exists apt; then
                print_info "Installing via apt..."
                type -p curl >/dev/null || sudo apt install curl -y
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
                && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
                && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
                && sudo apt update \
                && sudo apt install gh -y
            else
                print_error "Please install GitHub CLI manually: https://cli.github.com/"
                exit 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command_exists brew; then
                brew install gh
            else
                print_error "Please install GitHub CLI manually: https://cli.github.com/"
                exit 1
            fi
        else
            print_error "Unsupported OS. Please install GitHub CLI manually: https://cli.github.com/"
            exit 1
        fi
    fi
    
    print_success "GitHub CLI found: $(gh --version | head -n1)"
    
    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        print_warning "GitHub CLI not authenticated"
        print_info "Authenticating with GitHub..."
        gh auth login
    else
        print_success "GitHub CLI authenticated"
    fi
    
    # Install Copilot extension
    print_info "Installing GitHub Copilot extension..."
    if gh extension list | grep -q "github/gh-copilot"; then
        print_success "GitHub Copilot extension already installed"
    else
        gh extension install github/gh-copilot
        print_success "GitHub Copilot extension installed"
    fi
    
    print_success "Installation complete! You can now use: $0 chat"
}

# Interactive chat mode using GitHub Copilot
start_chat() {
    # Check if gh copilot is available
    if ! command_exists gh; then
        print_error "GitHub CLI not installed. Run: $0 install"
        exit 1
    fi
    
    if ! gh extension list | grep -q "github/gh-copilot"; then
        print_error "GitHub Copilot extension not installed. Run: $0 install"
        exit 1
    fi
    
    print_info "Starting AI Chat with GitHub Copilot..."
    print_info "Context: Football Home - Team management application"
    echo ""
    print_success "Ask me anything about your Football Home app!"
    print_info "Commands: 'exit', 'suggest', 'explain'"
    echo ""
    
    while true; do
        echo -e "${BLUE}You:${NC} \c"
        read -r user_input
        
        if [[ "$user_input" =~ ^(exit|quit|q)$ ]]; then
            print_success "Goodbye!"
            break
        fi
        
        if [ -z "$user_input" ]; then
            continue
        fi
        
        # Check if it's a command suggestion request
        if [[ "$user_input" =~ ^suggest ]]; then
            query="${user_input#suggest }"
            echo ""
            gh copilot suggest "$query"
        # Check if it's an explanation request
        elif [[ "$user_input" =~ ^explain ]]; then
            query="${user_input#explain }"
            echo ""
            gh copilot explain "$query"
        else
            # Use suggest as the default for general queries
            echo ""
            echo -e "${GREEN}AI:${NC}"
            gh copilot suggest "$user_input" 2>&1 | sed 's/^/  /'
        fi
        
        echo ""
    done
}

# Single query mode using GitHub Copilot
run_query() {
    if ! command_exists gh; then
        print_error "GitHub CLI not installed. Run: $0 install"
        exit 1
    fi
    
    if [ -z "$1" ]; then
        print_error "No query provided"
        exit 1
    fi
    
    gh copilot suggest "$1"
}

# Show help
show_help() {
    cat <<EOF
${BLUE}Football Home AI CLI${NC} - Powered by GitHub Copilot

${YELLOW}Usage:${NC}
  $0 install              Install GitHub Copilot CLI
  $0 chat                 Start interactive chat mode
  $0 query "text"         Run a single query
  $0 help                 Show this help

${YELLOW}Examples:${NC}
  $0 install
  $0 chat
  $0 query "How do I schedule a practice?"
  $0 query "explain docker compose up -d"
  
${YELLOW}Requirements:${NC}
  - GitHub account with Copilot access
  - GitHub CLI authenticated
  
${YELLOW}Commands in Chat Mode:${NC}
  exit, quit, q          Exit chat
  suggest <query>        Get command suggestions
  explain <query>        Get explanations

${YELLOW}Note:${NC}
  This uses your GitHub Copilot subscription - no additional API keys needed!

EOF
}

# Main command dispatcher
case "${1:-}" in
    install)
        install_deps
        ;;
    chat)
        start_chat
        ;;
    query)
        run_query "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: ${1:-}"
        echo ""
        show_help
        exit 1
        ;;
esac
