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
    # Skip API key setup - user will configure manually
    # Check if key exists in environment
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo "$ANTHROPIC_API_KEY"
        return
    fi
    
    # Return empty - tools will be installed but unconfigured
    echo ""
}


# Save API key to shell profile
save_api_key() {
    local api_key="$1"
    
    # Skip if no key provided
    if [ -z "$api_key" ]; then
        print_warning "No API key provided - user will configure manually"
        return
    fi
    
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
    # Skip test if no API key configured
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        print_warning "Skipping test - API key not configured"
        return
    fi
    
    print_info "Testing Claude CLI..."
    echo ""
    
    local test_response=$("$PROJECT_ROOT/claude" query "Say 'Hello!' in 2 words" 2>&1)
    
    if [ $? -eq 0 ]; then
        print_success "Claude CLI is working!"
        echo ""
        echo "Response: $test_response"
        echo ""
    else
        print_warning "Failed to communicate with Claude API - check your API key"
        echo ""
        echo "Error: $test_response"
        # Don't exit - continue with setup
    fi
}

# Create usage examples
show_usage() {
    echo ""
    print_success "✨ Setup complete!"
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
    
    print_info "How to use Claude:"
    echo ""
    echo -e "  ${GREEN}./claude chat${NC}           - Interactive mode"
    echo -e "  ${GREEN}./claude query \"text\"${NC}  - Quick query"
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
