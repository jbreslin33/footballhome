#!/bin/bash

# Football Home - SSL Setup Script
# This script sets up SSL certificates using Certbot for footballhome.org

set -e

echo "🚀 Setting up SSL for footballhome.org..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Install certbot if not present
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing Certbot..."
    apt update
    apt install -y certbot
fi

# Stop any running containers to free up ports
echo "🛑 Stopping containers to free up ports..."
podman-compose down || true

# Start a temporary nginx container for domain verification
echo "🌐 Starting temporary web server for domain verification..."
podman run -d --name temp-nginx \
    -p 80:80 \
    -v /home/jbreslin/sandbox/footballhome/ssl:/etc/ssl/certs \
    -v /tmp/acme-challenge:/usr/share/nginx/html/.well-known/acme-challenge \
    nginx:alpine

# Wait a moment for nginx to start
sleep 2

# Create SSL certificates directory
mkdir -p /home/jbreslin/sandbox/footballhome/ssl

# Request SSL certificate
echo "🔒 Requesting SSL certificate from Let's Encrypt..."
certbot certonly \
    --webroot \
    --webroot-path=/tmp/acme-challenge \
    --email admin@footballhome.org \
    --agree-tos \
    --no-eff-email \
    --domains footballhome.org,www.footballhome.org

# Copy certificates to our SSL directory
echo "📋 Copying certificates..."
cp /etc/letsencrypt/live/footballhome.org/fullchain.pem /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.crt
cp /etc/letsencrypt/live/footballhome.org/privkey.pem /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.key

# Set proper permissions
chown -R $SUDO_USER:$SUDO_USER /home/jbreslin/sandbox/footballhome/ssl
chmod 600 /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.key
chmod 644 /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.crt

# Stop temporary container
echo "🛑 Stopping temporary container..."
podman stop temp-nginx
podman rm temp-nginx

# Create renewal script
echo "📝 Creating certificate renewal script..."
cat > /home/jbreslin/sandbox/footballhome/scripts/renew-ssl.sh << 'EOF'
#!/bin/bash
# Auto-renewal script for SSL certificates

certbot renew --quiet

# Copy renewed certificates
if [[ -f /etc/letsencrypt/live/footballhome.org/fullchain.pem ]]; then
    cp /etc/letsencrypt/live/footballhome.org/fullchain.pem /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.crt
    cp /etc/letsencrypt/live/footballhome.org/privkey.pem /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.key
    
    # Restart nginx container if running
    if podman ps | grep -q footballhome_web; then
        podman restart footballhome_web
    fi
fi
EOF

chmod +x /home/jbreslin/sandbox/footballhome/scripts/renew-ssl.sh

# Add to crontab for automatic renewal
echo "⏰ Setting up automatic certificate renewal..."
(crontab -l 2>/dev/null; echo "0 2 * * 0 /home/jbreslin/sandbox/footballhome/scripts/renew-ssl.sh") | crontab -

echo "✅ SSL setup complete!"
echo ""
echo "Next steps:"
echo "1. Start your application: podman-compose up -d"
echo "2. Visit https://footballhome.org to test"
echo "3. Certificates will auto-renew every Sunday at 2 AM"
echo ""