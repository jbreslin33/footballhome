#!/bin/bash

# Football Home - SSL Setup Script
# This script sets up SSL certificates using Certbot

set -e

# Configuration
DOMAIN="${1:-footballhome.org}"
EMAIL="${2:-admin@$DOMAIN}"
PROJECT_ROOT="/home/jbreslin/sandbox/footballhome"
SSL_DIR="$PROJECT_ROOT/ssl"

echo "🚀 Setting up SSL for $DOMAIN..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   echo "Usage: sudo $0 [domain] [email]"
   echo "Example: sudo $0 footballhome.org admin@footballhome.org"
   exit 1
fi

# Verify domain is accessible
echo "🔍 Checking if domain $DOMAIN is accessible..."
if ! ping -c 1 "$DOMAIN" &> /dev/null; then
    echo "⚠️  Warning: $DOMAIN is not accessible. Make sure:"
    echo "   1. DNS records point to this server"
    echo "   2. Firewall allows ports 80 and 443"
    read -p "Continue anyway? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Detect container runtime
COMPOSE_CMD=""
if command -v podman-compose &> /dev/null; then
    COMPOSE_CMD="podman-compose"
    CONTAINER_CMD="podman"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    CONTAINER_CMD="docker"
else
    echo "❌ No container runtime found (podman or docker)"
    exit 1
fi

echo "✅ Using $COMPOSE_CMD"

# Install certbot if not present
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing Certbot..."
    apt update
    apt install -y certbot python3-certbot-nginx
fi

# Create SSL certificates directory
mkdir -p "$SSL_DIR"

# Stop any running containers to free up ports
echo "🛑 Stopping containers to free up ports..."
cd "$PROJECT_ROOT"
$COMPOSE_CMD down || true

# Create temporary webroot for ACME challenge
mkdir -p /tmp/acme-challenge

# Start a temporary nginx container for domain verification
echo "🌐 Starting temporary web server for domain verification..."
$CONTAINER_CMD run -d --name temp-nginx \
    -p 80:80 \
    -v /tmp/acme-challenge:/usr/share/nginx/html/.well-known/acme-challenge \
    nginx:alpine

# Wait for nginx to start
echo "⏳ Waiting for temporary web server..."
sleep 5

# Verify temporary server is working
if ! curl -f -s http://localhost > /dev/null; then
    echo "❌ Temporary web server failed to start"
    $CONTAINER_CMD stop temp-nginx 2>/dev/null || true
    $CONTAINER_CMD rm temp-nginx 2>/dev/null || true
    exit 1
fi

# Request SSL certificate
echo "🔒 Requesting SSL certificate from Let's Encrypt..."
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"

if certbot certonly \
    --webroot \
    --webroot-path=/tmp/acme-challenge \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --domains "$DOMAIN,www.$DOMAIN" \
    --non-interactive; then
    
    echo "✅ SSL certificate obtained successfully!"
    
    # Copy certificates to our SSL directory
    echo "📋 Copying certificates to project directory..."
    cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" "$SSL_DIR/$DOMAIN.crt"
    cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" "$SSL_DIR/$DOMAIN.key"
    
    # Set proper permissions
    chown -R $SUDO_USER:$SUDO_USER "$SSL_DIR"
    chmod 600 "$SSL_DIR/$DOMAIN.key"
    chmod 644 "$SSL_DIR/$DOMAIN.crt"
    
    echo "✅ Certificates copied and permissions set"
else
    echo "❌ Failed to obtain SSL certificate"
    echo "   Make sure:"
    echo "   1. Domain DNS points to this server's public IP"
    echo "   2. Port 80 is accessible from the internet" 
    echo "   3. No other web server is running on port 80"
fi

# Stop and cleanup temporary container
echo "🛑 Stopping temporary container..."
$CONTAINER_CMD stop temp-nginx 2>/dev/null || true
$CONTAINER_CMD rm temp-nginx 2>/dev/null || true
rm -rf /tmp/acme-challenge

# Only create renewal script if certificates were obtained
if [[ -f "$SSL_DIR/$DOMAIN.crt" ]]; then
    # Create renewal script
    echo "📝 Creating certificate renewal script..."
    cat > "$PROJECT_ROOT/scripts/renew-ssl.sh" << EOF
#!/bin/bash
# Auto-renewal script for SSL certificates

DOMAIN="$DOMAIN"
PROJECT_ROOT="$PROJECT_ROOT"
SSL_DIR="$PROJECT_ROOT/ssl"

# Detect container runtime
if command -v podman-compose &> /dev/null; then
    COMPOSE_CMD="podman-compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "No container runtime found"
    exit 1
fi

echo "\$(date): Renewing SSL certificates for \$DOMAIN"

# Renew certificates
certbot renew --quiet

# Copy renewed certificates if they exist
if [[ -f /etc/letsencrypt/live/\$DOMAIN/fullchain.pem ]]; then
    cp /etc/letsencrypt/live/\$DOMAIN/fullchain.pem \$SSL_DIR/\$DOMAIN.crt
    cp /etc/letsencrypt/live/\$DOMAIN/privkey.pem \$SSL_DIR/\$DOMAIN.key
    
    # Set permissions
    chmod 644 \$SSL_DIR/\$DOMAIN.crt
    chmod 600 \$SSL_DIR/\$DOMAIN.key
    
    # Restart nginx container if running
    cd "\$PROJECT_ROOT"
    if \$COMPOSE_CMD ps | grep -q footballhome_web; then
        echo "Restarting web container to reload certificates"
        \$COMPOSE_CMD restart web
    fi
    
    echo "\$(date): Certificates renewed and containers restarted"
else
    echo "\$(date): No certificate renewal needed"
fi
EOF

    chmod +x "$PROJECT_ROOT/scripts/renew-ssl.sh"

    # Add to crontab for automatic renewal (weekly on Sunday at 2 AM)
    echo "⏰ Setting up automatic certificate renewal..."
    if ! crontab -l 2>/dev/null | grep -q "renew-ssl.sh"; then
        (crontab -l 2>/dev/null; echo "0 2 * * 0 $PROJECT_ROOT/scripts/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1") | crontab -
        echo "✅ Added automatic renewal to crontab"
    else
        echo "✅ Automatic renewal already configured"
    fi
    
    echo ""
    echo "🎉 SSL setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Update your application to use SSL:"
    echo "   cd $PROJECT_ROOT"
    echo "   # Edit frontend/Dockerfile to use nginx.conf instead of nginx-simple.conf"
    echo "   $COMPOSE_CMD up -d --build"
    echo ""
    echo "2. Test your SSL setup:"
    echo "   curl -I https://$DOMAIN"
    echo ""
    echo "3. Certificates will auto-renew every Sunday at 2 AM"
    echo "   Check renewal logs: tail -f /var/log/ssl-renewal.log"
    echo ""
else
    echo "❌ SSL setup failed - certificates not found"
    exit 1
fi