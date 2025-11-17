#!/bin/bash
# Development Reload Script
# Quick rebuild and restart of frontend container with cache clearing

echo "🔄 Development Reload - Frontend"
echo "================================"

# Rebuild and restart frontend container
echo "📦 Rebuilding frontend container..."
docker compose build --no-cache frontend

echo "🚀 Restarting frontend..."
docker compose up -d frontend

# Get the current timestamp for cache busting
TIMESTAMP=$(date +%s)

echo ""
echo "✅ Frontend reloaded!"
echo ""
echo "🌐 Access your app at: https://footballhome.org?nocache=$TIMESTAMP"
echo ""
echo "💡 Tip: Copy the URL above and paste it in your browser to bypass all caches"
echo "    Or press Ctrl+Shift+R (Cmd+Shift+R on Mac) after refreshing"
echo ""
