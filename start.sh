#!/bin/bash

# Football Home - Quick Start Script
# For when Podman/Docker is already installed

set -e

echo "🚀 Starting Football Home..."

# Detect available container runtime
if command -v podman-compose &> /dev/null; then
    echo "Using Podman..."
    podman-compose down 2>/dev/null || true
    podman-compose up -d --build
    COMPOSE_CMD="podman-compose"
elif command -v docker-compose &> /dev/null; then
    echo "Using Docker..."
    docker-compose down 2>/dev/null || true
    docker-compose up -d --build
    COMPOSE_CMD="docker-compose"
else
    echo "❌ No container runtime found. Please run ./setup.sh first."
    exit 1
fi

echo "⏳ Waiting for services..."
sleep 8

# Quick health check
if curl -f -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ API is ready"
else
    echo "⏳ API starting... (checking logs if needed)"
    sleep 5
fi

if curl -f -s http://localhost > /dev/null 2>&1; then
    echo "✅ Frontend is ready"
else
    echo "❌ Frontend not ready - check logs:"
    $COMPOSE_CMD logs web
    exit 1
fi

echo ""
echo "🎉 Football Home is running!"
echo "Frontend: http://localhost"
echo "API: http://localhost:3000"
echo ""
echo "Stop with: $COMPOSE_CMD down"