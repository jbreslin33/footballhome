#!/bin/bash

# Football Home - SSL Configuration Switcher
# Switch between HTTP-only and HTTPS configurations

set -e

PROJECT_ROOT="/home/jbreslin/sandbox/footballhome"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Detect container runtime
if command -v podman-compose &> /dev/null; then
    COMPOSE_CMD="podman-compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ No container runtime found"
    exit 1
fi

show_help() {
    echo "Football Home SSL Configuration Switcher"
    echo ""
    echo "Usage: $0 [http|https|status]"
    echo ""
    echo "Commands:"
    echo "  http    - Switch to HTTP-only mode (nginx-simple.conf)"
    echo "  https   - Switch to HTTPS mode (nginx.conf)"
    echo "  status  - Show current configuration"
    echo ""
    echo "Examples:"
    echo "  $0 http     # Switch to development HTTP mode"
    echo "  $0 https    # Switch to production HTTPS mode"
    echo "  $0 status   # Check current mode"
}

get_current_config() {
    if grep -q "nginx-simple.conf" "$FRONTEND_DIR/Dockerfile" 2>/dev/null; then
        echo "http"
    elif grep -q "nginx.conf" "$FRONTEND_DIR/Dockerfile" 2>/dev/null; then
        echo "https"
    else
        echo "unknown"
    fi
}

switch_to_http() {
    echo "🔄 Switching to HTTP-only configuration..."
    
    # Update Dockerfile to use simple config
    sed -i 's/COPY nginx\.conf /COPY nginx-simple.conf /' "$FRONTEND_DIR/Dockerfile"
    
    echo "✅ Switched to HTTP mode (nginx-simple.conf)"
    echo "   - Only port 80 active"
    echo "   - No SSL/HTTPS"
    echo "   - Good for development"
}

switch_to_https() {
    echo "🔄 Switching to HTTPS configuration..."
    
    # Check if SSL certificates exist
    if [[ ! -f "$PROJECT_ROOT/ssl/footballhome.org.crt" ]]; then
        echo "⚠️  SSL certificates not found!"
        echo "   Run: sudo ./scripts/setup-ssl.sh"
        echo "   Then try again."
        return 1
    fi
    
    # Update Dockerfile to use full config
    sed -i 's/COPY nginx-simple\.conf /COPY nginx.conf /' "$FRONTEND_DIR/Dockerfile"
    
    echo "✅ Switched to HTTPS mode (nginx.conf)"
    echo "   - Ports 80 (redirect) and 443 (HTTPS)"
    echo "   - SSL/TLS encryption"
    echo "   - Security headers"
    echo "   - Good for production"
}

show_status() {
    local current_config=$(get_current_config)
    
    echo "🔍 Current SSL Configuration Status"
    echo "=================================="
    
    case $current_config in
        "http")
            echo "Mode: HTTP-only (Development)"
            echo "Config: nginx-simple.conf"
            echo "Ports: 80"
            echo "SSL: Disabled"
            ;;
        "https")
            echo "Mode: HTTPS (Production)"
            echo "Config: nginx.conf"
            echo "Ports: 80 (redirect), 443 (HTTPS)"
            echo "SSL: Enabled"
            
            # Check certificate status
            if [[ -f "$PROJECT_ROOT/ssl/footballhome.org.crt" ]]; then
                echo "Certificates: ✅ Found"
                # Show certificate expiry if openssl is available
                if command -v openssl &> /dev/null; then
                    local expiry=$(openssl x509 -in "$PROJECT_ROOT/ssl/footballhome.org.crt" -noout -enddate 2>/dev/null | cut -d= -f2)
                    if [[ -n "$expiry" ]]; then
                        echo "Expires: $expiry"
                    fi
                fi
            else
                echo "Certificates: ❌ Missing"
                echo "Run: sudo ./scripts/setup-ssl.sh"
            fi
            ;;
        *)
            echo "Mode: Unknown configuration"
            echo "Check: $FRONTEND_DIR/Dockerfile"
            ;;
    esac
    
    echo ""
    echo "To rebuild and restart:"
    echo "  cd $PROJECT_ROOT"
    echo "  $COMPOSE_CMD up -d --build"
}

# Main script
case "${1:-status}" in
    "http")
        switch_to_http
        echo ""
        echo "💡 To apply changes:"
        echo "   cd $PROJECT_ROOT"
        echo "   $COMPOSE_CMD up -d --build"
        ;;
    "https")
        if switch_to_https; then
            echo ""
            echo "💡 To apply changes:"
            echo "   cd $PROJECT_ROOT"
            echo "   $COMPOSE_CMD up -d --build"
        fi
        ;;
    "status")
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Invalid command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac