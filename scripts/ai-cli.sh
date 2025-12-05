#!/bin/bash
# AI CLI - Command-line interface for Football Home AI features using Ollama + DeepSeek-Coder
#
# Usage:
#   ./scripts/ai-cli.sh install        # Install Ollama and DeepSeek-Coder
#   ./scripts/ai-cli.sh chat           # Start interactive chat
#   ./scripts/ai-cli.sh query "text"   # Single query
#   ./scripts/ai-cli.sh code "task"    # Generate code
#   ./scripts/ai-cli.sh help           # Show help

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration - DeepSeek-Coder is best for coding tasks
OLLAMA_MODEL="deepseek-coder:6.7b"

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

# Install Ollama and DeepSeek-Coder
install_deps() {
    print_info "Installing Ollama + DeepSeek-Coder (free, open-source, local AI)..."
    echo ""
    
    # Check if ollama is already installed
    if command_exists ollama; then
        print_success "Ollama already installed"
    else
        print_info "Downloading and installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        print_success "Ollama installed successfully"
    fi
    
    # Start ollama service if not running
    if ! pgrep -x "ollama" > /dev/null; then
        print_info "Starting Ollama service..."
        ollama serve > /dev/null 2>&1 &
        sleep 3
        print_success "Ollama service started"
    else
        print_success "Ollama service already running"
    fi
    
    # Check if model is already downloaded
    if ollama list | grep -q "$OLLAMA_MODEL"; then
        print_success "DeepSeek-Coder already downloaded"
    else
        print_info "Downloading DeepSeek-Coder model (~4GB, this will take a few minutes)..."
        print_warning "First time only - future uses will be instant!"
        ollama pull "$OLLAMA_MODEL"
        print_success "DeepSeek-Coder downloaded successfully"
    fi
    
    echo ""
    print_success "✨ Installation complete!"
    echo ""
    print_info "What you just got:"
    echo "  • Ollama (AI runtime)"
    echo "  • DeepSeek-Coder 6.7B (coding AI model)"
    echo "  • 100% free, open-source, runs locally"
    echo "  • No API keys, no subscriptions, no internet needed"
    echo ""
    print_info "Try it now:"
    echo "  ${GREEN}$0 chat${NC}              - Interactive coding assistant"
    echo "  ${GREEN}$0 code \"write a function...\"${NC} - Generate code"
    echo "  ${GREEN}$0 query \"how to...\"${NC}  - Ask questions"
    echo ""
}

# Interactive chat mode using Ollama + DeepSeek-Coder
start_chat() {
    # Check if ollama is available
    if ! command_exists ollama; then
        print_error "Ollama not installed. Run: $0 install"
        exit 1
    fi
    
    # Start ollama service if not running
    if ! pgrep -x "ollama" > /dev/null; then
        print_info "Starting Ollama service..."
        ollama serve > /dev/null 2>&1 &
        sleep 2
    fi
    
    # Check if model exists
    if ! ollama list | grep -q "$OLLAMA_MODEL"; then
        print_error "DeepSeek-Coder not found. Run: $0 install"
        exit 1
    fi
    
    print_info "🤖 AI Coding Assistant - DeepSeek-Coder"
    print_info "Context: Football Home (C++ backend, JavaScript frontend, PostgreSQL)"
    echo ""
    print_success "I can help you write code, debug issues, explain concepts, and more!"
    echo ""
    print_info "Commands:"
    echo "  ${YELLOW}exit${NC} or ${YELLOW}quit${NC}  - Exit chat"
    echo "  ${YELLOW}clear${NC}         - Clear conversation history"
    echo ""
    
    # System prompt for Football Home context
    SYSTEM_PROMPT="You are an expert coding assistant for Football Home, a sports team management application. 

Tech stack:
- Backend: C++ with libpqxx (PostgreSQL)
- Frontend: Vanilla JavaScript (no frameworks)
- Database: PostgreSQL
- Infrastructure: Docker

Help with: writing code, debugging, refactoring, SQL queries, explaining code, best practices. Be concise and provide working code examples."
    
    # Temporary file for conversation
    CONV_FILE=$(mktemp)
    echo "$SYSTEM_PROMPT" > "$CONV_FILE"
    
    while true; do
        echo -ne "${BLUE}You:${NC} "
        read -r user_input
        
        if [[ "$user_input" =~ ^(exit|quit|q)$ ]]; then
            print_success "Goodbye!"
            rm -f "$CONV_FILE"
            break
        fi
        
        if [[ "$user_input" == "clear" ]]; then
            echo "$SYSTEM_PROMPT" > "$CONV_FILE"
            print_success "Conversation cleared"
            echo ""
            continue
        fi
        
        if [ -z "$user_input" ]; then
            continue
        fi
        
        # Add user message to conversation
        echo -e "\nUser: $user_input" >> "$CONV_FILE"
        
        # Get AI response
        echo ""
        echo -e "${GREEN}AI:${NC}"
        RESPONSE=$(ollama run "$OLLAMA_MODEL" "$(cat "$CONV_FILE")" 2>/dev/null)
        echo "$RESPONSE"
        
        # Add AI response to conversation
        echo -e "\nAssistant: $RESPONSE" >> "$CONV_FILE"
        
        echo ""
    done
}

# Single query mode
run_query() {
    if ! command_exists ollama; then
        print_error "Ollama not installed. Run: $0 install"
        exit 1
    fi
    
    if [ -z "$1" ]; then
        print_error "No query provided"
        exit 1
    fi
    
    # Start ollama service if not running
    if ! pgrep -x "ollama" > /dev/null; then
        ollama serve > /dev/null 2>&1 &
        sleep 2
    fi
    
    PROMPT="You are a coding assistant for Football Home (C++ backend, JavaScript frontend, PostgreSQL). Be concise and practical.

Question: $1"
    
    ollama run "$OLLAMA_MODEL" "$PROMPT" 2>/dev/null
}

# Code generation mode
generate_code() {
    if ! command_exists ollama; then
        print_error "Ollama not installed. Run: $0 install"
        exit 1
    fi
    
    if [ -z "$1" ]; then
        print_error "No task provided"
        exit 1
    fi
    
    # Start ollama service if not running
    if ! pgrep -x "ollama" > /dev/null; then
        ollama serve > /dev/null 2>&1 &
        sleep 2
    fi
    
    PROMPT="You are a coding assistant for Football Home application.

Tech stack:
- Backend: C++ with libpqxx
- Frontend: Vanilla JavaScript
- Database: PostgreSQL

Task: $1

Provide only the code with minimal explanation. Make it production-ready."
    
    ollama run "$OLLAMA_MODEL" "$PROMPT" 2>/dev/null
}

# Show help
show_help() {
    cat <<EOF
${BLUE}Football Home AI CLI${NC} - Powered by Ollama + DeepSeek-Coder

${YELLOW}Usage:${NC}
  $0 install              Install Ollama and DeepSeek-Coder
  $0 chat                 Start interactive coding assistant
  $0 query "question"     Ask a quick question
  $0 code "task"          Generate code for a task
  $0 help                 Show this help

${YELLOW}Examples:${NC}
  $0 install
  $0 chat
  $0 query "How do I optimize this SQL query?"
  $0 code "Write a C++ function to validate email addresses"
  $0 code "Create a JavaScript component for RSVP buttons"
  
${YELLOW}Features:${NC}
  ✓ 100% free and open-source
  ✓ Runs locally (no internet needed after install)
  ✓ No API keys or subscriptions
  ✓ Specialized for coding tasks
  ✓ Understands your Football Home tech stack
  
${YELLOW}Chat Mode Commands:${NC}
  exit, quit, q          Exit chat
  clear                  Clear conversation history

${YELLOW}What can it do:${NC}
  • Write code in any language (C++, JavaScript, SQL, etc.)
  • Debug and fix code
  • Explain complex code
  • Refactor and optimize
  • Generate SQL queries
  • Write tests
  • Convert between languages

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
    code)
        generate_code "$2"
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
