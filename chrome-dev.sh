#!/bin/bash
# Launch Chrome with caching completely disabled for development

echo "🚀 Launching Chrome in Development Mode (No Cache)"
echo "=================================================="

google-chrome \
  --disable-application-cache \
  --disable-cache \
  --disable-gpu-shader-disk-cache \
  --disable-offline-load-stale-cache \
  --disk-cache-size=1 \
  --media-cache-size=1 \
  --user-data-dir=/tmp/chrome-dev-profile \
  https://footballhome.org &

echo ""
echo "✅ Chrome launched with caching disabled"
echo "💡 This uses a temporary profile, so you'll need to log in again"
