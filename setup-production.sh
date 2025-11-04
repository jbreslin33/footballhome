#!/bin/bash

# Football Home Production Setup Script
# This script sets up Football Home for production deployment with SSL
# Usage: ./setup-production.sh

set -e

echo "🚀 Football Home Production Setup"
echo "=================================="

# Check if running as root for some operations
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  Running as root - this is fine for server setup"
else
    echo "ℹ️  Running as user - some steps may require sudo"
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. You may need to log out and back in for group changes."
fi

# Check if nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "📦 Installing nginx..."
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl enable nginx
    echo "✅ Nginx installed"
fi

# Create SSL directory
echo "🔐 Setting up SSL certificates..."
mkdir -p ssl

# Generate self-signed certificates if they don't exist (for development)
if [ ! -f "ssl/footballhome.org.crt" ] || [ ! -f "ssl/footballhome.org.key" ]; then
    echo "🔒 Generating self-signed SSL certificates for development..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/footballhome.org.key \
        -out ssl/footballhome.org.crt \
        -subj "/C=US/ST=PA/L=Philadelphia/O=Football Home/CN=footballhome.org/subjectAltName=DNS:footballhome.org,DNS:www.footballhome.org"
    echo "⚠️  Self-signed certificates created. For production, replace with proper SSL certificates."
else
    echo "✅ SSL certificates already exist"
fi

# Set correct permissions on SSL files
chmod 600 ssl/footballhome.org.key
chmod 644 ssl/footballhome.org.crt

# Configure nginx
echo "🌐 Configuring nginx..."
if [ -f "nginx-footballhome.conf" ]; then
    # Copy SSL certificates to nginx directory
    sudo mkdir -p /etc/letsencrypt/live/footballhome.org/
    sudo cp ssl/footballhome.org.crt /etc/letsencrypt/live/footballhome.org/fullchain.pem
    sudo cp ssl/footballhome.org.key /etc/letsencrypt/live/footballhome.org/privkey.pem
    
    # Install nginx configuration
    sudo cp nginx-footballhome.conf /etc/nginx/sites-available/footballhome
    
    # Remove default nginx site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Enable Football Home site
    sudo ln -sf /etc/nginx/sites-available/footballhome /etc/nginx/sites-enabled/footballhome
    
    # Test nginx configuration
    if sudo nginx -t; then
        echo "✅ Nginx configuration is valid"
        sudo systemctl reload nginx
        echo "✅ Nginx reloaded with Football Home configuration"
    else
        echo "❌ Nginx configuration error"
        exit 1
    fi
else
    echo "❌ nginx-footballhome.conf not found"
    exit 1
fi

# Add domain to hosts file
if ! grep -q "footballhome.org" /etc/hosts; then
    echo "🌍 Adding footballhome.org to /etc/hosts..."
    echo "127.0.0.1 footballhome.org www.footballhome.org" | sudo tee -a /etc/hosts
    echo "✅ Domain added to hosts file"
else
    echo "✅ Domain already in hosts file"
fi

# Run the main setup
echo "🏈 Running Football Home application setup..."
./setup-complete.sh

# Final checks
echo ""
echo "🔍 Final system checks..."

# Check if nginx is serving the site
if curl -k -f https://footballhome.org &>/dev/null; then
    echo "✅ HTTPS site is accessible"
else
    echo "❌ HTTPS site is not accessible"
    echo "   Check nginx status: sudo systemctl status nginx"
    echo "   Check nginx logs: sudo tail -f /var/log/nginx/error.log"
fi

# Check if API is working
if curl -k -f https://footballhome.org/api/auth/me &>/dev/null; then
    echo "✅ API endpoint is accessible"
else
    echo "⚠️  API endpoint check failed (may need authentication)"
fi

echo ""
echo "🎊 Football Home Production Setup Complete!"
echo "=========================================="
echo "🌐 Visit: https://footballhome.org"
echo "🔑 Login with: jbreslin@footballhome.org / m13m13m1"
echo ""
echo "📋 Next Steps:"
echo "   1. Replace self-signed certificates with proper SSL certificates"
echo "   2. Update DNS records to point footballhome.org to this server"
echo "   3. Configure firewall to allow ports 80, 443"
echo "   4. Set up automated SSL certificate renewal (Let's Encrypt)"
echo "   5. Configure backup procedures for database"
echo ""
echo "🔧 Management Commands:"
echo "   View logs: docker compose logs -f"
echo "   Restart: docker compose restart"
echo "   Stop: docker compose down"
echo "   Update: git pull && docker compose up -d --build"