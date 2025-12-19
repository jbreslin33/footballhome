#!/bin/bash
# Fetch encrypted credentials from a private source
# This script downloads the .env file from a secure location

set -e

echo "🔐 Fetching credentials..."

# Option 1: Private GitHub Gist (recommended)
# Create a secret gist at https://gist.github.com with your .env file
# Then set FOOTBALLHOME_GIST_ID environment variable
if [ -n "$FOOTBALLHOME_GIST_ID" ]; then
    echo "📥 Downloading from GitHub Gist..."
    curl -H "Authorization: token $GITHUB_TOKEN" \
         "https://gist.githubusercontent.com/jbreslin33/$FOOTBALLHOME_GIST_ID/raw/.env" \
         -o .env
    echo "✅ Credentials downloaded from gist"
    exit 0
fi

# Option 2: Private git submodule
if [ -d ".credentials" ]; then
    echo "📥 Pulling from credentials submodule..."
    cd .credentials && git pull && cd ..
    cp .credentials/.env .env
    echo "✅ Credentials copied from submodule"
    exit 0
fi

# Option 3: Manual setup from example
echo "⚠️  No automatic credential source found."
echo ""
echo "Please set up credentials manually:"
echo "  1. Copy .env.example to .env"
echo "  2. Fill in your Twilio credentials"
echo ""
echo "Or set up automatic fetching:"
echo "  • GitHub Gist: export FOOTBALLHOME_GIST_ID=your_gist_id"
echo "  • Private repo: git submodule add <private-repo-url> .credentials"
