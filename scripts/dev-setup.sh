#!/bin/bash

# Football Home - Development Setup Script
# Quick start script for development environment

set -e

echo "⚽ Football Home - Development Setup"
echo "=================================="

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    echo "❌ Podman is not installed. Please install it first:"
    echo "   Ubuntu/Debian: sudo apt install podman"
    echo "   RHEL/CentOS: sudo dnf install podman"
    exit 1
fi

# Check if podman-compose is available
if ! command -v podman-compose &> /dev/null; then
    echo "❌ podman-compose is not installed. Please install it first:"
    echo "   pip3 install podman-compose"
    exit 1
fi

echo "✅ Podman and podman-compose are available"

# Build and start the containers
echo "🏗️  Building containers..."
podman-compose build

echo "🚀 Starting services..."
podman-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check database
if podman exec footballhome_db pg_isready -U footballapp > /dev/null 2>&1; then
    echo "✅ Database is ready"
else
    echo "❌ Database is not ready"
fi

# Check API
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ API is responding"
else
    echo "❌ API is not responding"
fi

# Check frontend
if curl -s http://localhost > /dev/null; then
    echo "✅ Frontend is serving"
else
    echo "❌ Frontend is not serving"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📱 Access your application:"
echo "   Local: http://localhost"
echo "   External: http://$(curl -s ifconfig.me || echo 'YOUR-SERVER-IP')"
echo ""
echo "🔧 Useful commands:"
echo "   View logs: podman-compose logs -f"
echo "   Stop services: podman-compose down"
echo "   Rebuild: podman-compose build --no-cache"
echo ""
echo "📊 Service status:"
podman-compose ps
echo ""

# Show next steps for SSL
if [[ ! -f /home/jbreslin/sandbox/footballhome/ssl/footballhome.org.crt ]]; then
    echo "🔒 To set up SSL for production:"
    echo "   sudo ./scripts/setup-ssl.sh"
    echo ""
fi