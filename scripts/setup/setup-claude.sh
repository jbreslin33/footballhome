#!/bin/bash
# Setup Claude Code CLI - Interactive installer for Claude terminal mode
#
# Usage:
#   ./scripts/setup-claude-cli.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Check if curl is installed
check_curl() {
    if ! command_exists curl; then
        print_error "curl is not installed"
        print_info "Install curl:"
        print_info "  macOS: curl is pre-installed"
        print_info "  Ubuntu/Debian: sudo apt-get install curl"
        print_info "  RHEL/CentOS: sudo yum install curl"
        exit 1
    fi
    print_success "curl found"
}

# Check if jq is installed (optional but recommended)
check_jq() {
    if ! command_exists jq; then
        print_warning "jq not found (optional, for prettier output)"
        print_info "Install jq:"
        print_info "  macOS: brew install jq"
        print_info "  Ubuntu/Debian: sudo apt-get install jq"
        print_info "  RHEL/CentOS: sudo yum install jq"
        return 1
    fi
    print_success "jq found"
    return 0
}

# Get API key from user
get_api_key() {
    echo ""
    print_info "🔑 Anthropic API Key Setup"
    echo ""
    
    # Check if key already exists in environment or profile
    local existing_key=""
    local shell_profile=""
    
    # Detect shell and profile file
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_profile="$HOME/.bashrc"
    else
        shell_profile="$HOME/.profile"
    fi
    
    # Check environment variable first
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        existing_key="$ANTHROPIC_API_KEY"
    # Then check profile file
    elif grep -q "ANTHROPIC_API_KEY" "$shell_profile" 2>/dev/null; then
        existing_key=$(grep "ANTHROPIC_API_KEY" "$shell_profile" | grep -o 'sk-ant-[^"]*' | head -1)
    fi
    
    # If key exists, ask if user wants to use it
    if [ -n "$existing_key" ]; then
        local masked_key="${existing_key:0:12}...${existing_key: -8}"
        print_success "Found existing API key: $masked_key"
        echo ""
        read -p "Use existing key? (y/n): " use_existing
        
        if [[ "$use_existing" == "y" ]]; then
            echo "$existing_key"
            return
        fi
        echo ""
        print_info "Entering new API key..."
    fi
    
    echo "To get your API key:"
    echo "  1. Go to: ${BLUE}https://console.anthropic.com/${NC}"
    echo "  2. Sign up or log in"
    echo "  3. Click 'API Keys' in the sidebar"
    echo "  4. Click 'Create Key'"
    echo "  5. Copy the key"
    echo ""
    print_warning "Note: You'll need to add billing credits (minimum ~\$5)"
    echo ""
    
    read -p "Enter your Anthropic API key (starts with sk-ant-): " api_key
    
    if [[ ! "$api_key" =~ ^sk-ant- ]]; then
        print_error "Invalid API key format (should start with 'sk-ant-')"
        exit 1
    fi
    
    echo "$api_key"
}

# Save API key to shell profile
save_api_key() {
    local api_key="$1"
    local shell_profile=""
    
    # Detect shell and profile file
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_profile="$HOME/.bashrc"
    else
        shell_profile="$HOME/.profile"
    fi
    
    # Check if this key is already saved (user chose to use existing)
    if [ -n "$ANTHROPIC_API_KEY" ] && [ "$ANTHROPIC_API_KEY" = "$api_key" ]; then
        if grep -q "$api_key" "$shell_profile" 2>/dev/null; then
            print_success "Using existing API key from $shell_profile"
            export ANTHROPIC_API_KEY="$api_key"
            return
        fi
    fi
    
    print_info "Saving API key to $shell_profile..."
    
    # Check if key already exists in profile
    if grep -q "ANTHROPIC_API_KEY" "$shell_profile" 2>/dev/null; then
        # Remove old key
        sed -i.bak '/ANTHROPIC_API_KEY/d' "$shell_profile"
    fi
    
    # Add new key
    echo "" >> "$shell_profile"
    echo "# Anthropic Claude API Key" >> "$shell_profile"
    echo "export ANTHROPIC_API_KEY=\"$api_key\"" >> "$shell_profile"
    
    print_success "API key saved to $shell_profile"
    
    # Export for current session
    export ANTHROPIC_API_KEY="$api_key"
    print_success "API key exported for current session"
}

# Create Claude CLI wrapper script
create_wrapper() {
    local wrapper="$PROJECT_ROOT/claude"
    
    print_info "Creating Claude CLI tool at root..."
    
    cat > "$wrapper" << 'WRAPPEREOF'
#!/bin/bash
set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CLAUDE_MODEL="claude-sonnet-4-20250514"
CLAUDE_API_URL="https://api.anthropic.com/v1/messages"

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}✗${NC} ANTHROPIC_API_KEY not set"
    echo -e "${BLUE}ℹ${NC} Run: ./scripts/setup-claude-cli.sh"
    exit 1
fi

call_claude() {
    local prompt="$1"
    local system_prompt="$2"
    
    local escaped_prompt=$(python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' <<< "$prompt")
    local escaped_system=$(python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' <<< "$system_prompt")
    
    local json_payload=$(cat <<JSONEOF
{
  "model": "$CLAUDE_MODEL",
  "max_tokens": 4096,
  "system": $escaped_system,
  "messages": [{"role": "user", "content": $escaped_prompt}]
}
JSONEOF
)
    
    local response=$(curl -s -X POST "$CLAUDE_API_URL" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_payload")
    
    if echo "$response" | grep -q '"type":"error"'; then
        echo -e "${RED}✗${NC} API Error:"
        echo "$response"
        exit 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "$response" | jq -r '.content[0].text'
    else
        python3 -c 'import json,sys; print(json.loads(sys.stdin.read())["content"][0]["text"])' <<< "$response"
    fi
}

start_chat() {
    echo -e "${BLUE}ℹ${NC} 🤖 Claude AI - Football Home Context"
    echo -e "${GREEN}✓${NC} Ready! (Type 'exit' to quit)"
    echo ""
    
    SYSTEM_PROMPT="You are an expert coding assistant for Football Home. Tech stack: C++17 backend with libpqxx, Vanilla JavaScript frontend, PostgreSQL. Help with code, debugging, SQL. Be concise."
    
    while true; do
        echo -ne "${BLUE}You:${NC} "
        read -r user_input
        
        [[ "$user_input" =~ ^(exit|quit|q)$ ]] && break
        [ -z "$user_input" ] && continue
        
        echo -e "\n${GREEN}Claude:${NC}"
        call_claude "$user_input" "$SYSTEM_PROMPT"
        echo ""
    done
    echo -e "${GREEN}✓${NC} Goodbye!"
}

case "${1:-}" in
    chat) start_chat ;;
    query) call_claude "$2" "You are a coding assistant for Football Home (C++, JS, PostgreSQL). Be concise." ;;
    *) echo "Usage: $0 {chat|query \"text\"}" ;;
esac
WRAPPEREOF
    
    chmod +x "$wrapper"
    print_success "Created $wrapper"
}

# Test Claude CLI
test_claude() {
    print_info "Testing Claude CLI..."
    echo ""
    
    local test_response=$("$PROJECT_ROOT/claude" query "Say 'Hello!' in 2 words" 2>&1)
    
    if [ $? -eq 0 ]; then
        print_success "Claude CLI is working!"
        echo ""
        echo "Response: $test_response"
        echo ""
    else
        print_error "Failed to communicate with Claude API"
        echo ""
        echo "Error: $test_response"
        exit 1
    fi
}

# Create usage examples
show_usage() {
    echo ""
    print_success "✨ Setup complete!"
    echo ""
    print_info "How to use Claude:"
    echo ""
    echo -e "  ${GREEN}./claude chat${NC}           - Interactive mode"
    echo -e "  ${GREEN}./claude query \"text\"${NC}  - Quick query"
    echo ""
    print_warning "Restart terminal or run: source ~/.zshrc"
    echo ""
}

# Main
main() {
    echo ""
    print_info "🤖 Claude CLI Setup (distro-agnostic)"
    echo ""
    
    check_curl
    check_jq || true
    echo ""
    
    api_key=$(get_api_key)
    save_api_key "$api_key"
    echo ""
    
    create_wrapper
    echo ""
    
    test_claude
    show_usage
}

main
