#!/bin/bash

# Football Home Complete Setup Script
# This script sets up the entire Football Home application from scratch
# Usage: ./setup-complete.sh

set -e

echo "🏈 Football Home Complete Setup"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first:"
    echo "   sudo apt update && sudo apt install docker.io docker-compose-plugin"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install docker-compose-plugin"
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating environment configuration..."
    cat > .env << EOF
# Football Home Environment Configuration
# Database Configuration
POSTGRES_DB=footballhome
POSTGRES_USER=footballhome_user
POSTGRES_PASSWORD=footballhome_pass
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Backend Configuration
JWT_SECRET=football-home-super-secret-jwt-key-change-in-production-$(date +%s)
NODE_ENV=production
PORT=3001

# Frontend Configuration
REACT_APP_API_URL=https://footballhome.org/api
REACT_APP_APP_NAME=Football Home
FRONTEND_URL=https://footballhome.org

# pgAdmin Configuration
PGADMIN_DEFAULT_EMAIL=admin@footballhome.org
PGADMIN_DEFAULT_PASSWORD=admin123

# SSL Configuration (if using)
SSL_CERT_PATH=./ssl/footballhome.org.crt
SSL_KEY_PATH=./ssl/footballhome.org.key
EOF
    echo "✅ Environment file created"
else
    echo "✅ Environment file already exists"
fi

# Install backend dependencies if package.json exists
if [ -d "backend" ] && [ -f "backend/package.json" ]; then
    echo "📦 Installing backend dependencies..."
    cd backend
    
    # Ensure all required packages are in package.json
    echo "🔍 Checking backend dependencies..."
    
    # Check if required packages exist, if not add them
    if ! grep -q "jsonwebtoken" package.json; then
        npm install jsonwebtoken bcryptjs joi express-rate-limit --save
    fi
    
    cd ..
    echo "✅ Backend dependencies ready"
fi

# Install frontend dependencies if package.json exists
if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
    echo "📦 Installing frontend dependencies..."
    cd frontend
    
    # Check if required packages exist, if not add them
    if ! grep -q "react-router-dom" package.json; then
        npm install react-router-dom axios --save
    fi
    
    cd ..
    echo "✅ Frontend dependencies ready"
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker compose down --volumes --remove-orphans 2>/dev/null || true

# Clean up any existing images to ensure fresh build
echo "🧹 Cleaning up old images..."
docker compose build --no-cache --pull 2>/dev/null || true

# Build and start all services
echo "🚀 Building and starting Football Home services..."
docker compose up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check database
if docker compose exec -T db pg_isready -U footballhome_user -d footballhome &>/dev/null; then
    echo "✅ Database is ready"
else
    echo "❌ Database is not ready"
    docker compose logs db
    exit 1
fi

# Check backend
if curl -f http://localhost:3001/health &>/dev/null; then
    echo "✅ Backend API is ready"
else
    echo "❌ Backend API is not ready"
    docker compose logs backend
    exit 1
fi

# Check frontend
if curl -f http://localhost:3000 &>/dev/null; then
    echo "✅ Frontend is ready"
else
    echo "❌ Frontend is not ready"
    docker compose logs frontend
    exit 1
fi

# Create admin user and initial data
echo "👤 Creating admin user and initial data..."
if [ -f "scripts/create-admin-user.sql" ]; then
    docker compose exec -T db psql -U footballhome_user -d footballhome -f /docker-entrypoint-initdb.d/create-admin-user.sql &>/dev/null || \
    docker compose exec -T db psql -U footballhome_user -d footballhome < scripts/create-admin-user.sql &>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Admin user created successfully"
    else
        echo "⚠️  Admin user creation skipped (may already exist)"
    fi
else
    echo "⚠️  Admin user script not found"
fi

echo ""
echo "🎉 Football Home is ready!"
=========================="
echo "📱 Frontend:     https://footballhome.org (with SSL)"
echo "🔧 Backend API:  https://footballhome.org/api"
echo "🗄️  Database:    localhost:5432 (footballhome/footballhome_user)"
echo "⚡ pgAdmin:     http://footballhome.org:5050"
echo ""
echo "🔑 Default Admin Login:"
echo "  Email: jbreslin@footballhome.org"
echo "  Password: m13m13m1"
echo "  Roles: admin, coach, player"
echo "  Team: Lighthouse 1893 SC Men's First Team"
echo ""
echo "Default pgAdmin Login:"
echo "  Email: admin@footballhome.org"
echo "  Password: admin123"
echo ""
echo "⚠️  SSL Prerequisites:"
echo "  - SSL certificates must exist at ssl/footballhome.org.{crt,key}"
echo "  - Nginx configuration must be installed and active"
echo "  - Domain must resolve: echo '127.0.0.1 footballhome.org' | sudo tee -a /etc/hosts"
echo ""
echo "To view logs: docker compose logs -f [service]"
echo "To stop: docker compose down"
echo "To rebuild: docker compose up -d --build"