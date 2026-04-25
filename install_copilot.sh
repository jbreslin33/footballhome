#!/bin/bash
set -e

echo "📦 Installing Node.js v22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

echo "🤖 Installing Copilot CLI globally..."
sudo npm install -g @github/copilot

echo "📝 Setting up shell alias..."
SHELL_RC="$HOME/.bashrc"
if ! grep -q 'copilot alias' "$SHELL_RC"; then
    echo 'eval "$(copilot alias -- bash)"' >> "$SHELL_RC"
fi

echo "✅ Done! Refreshing shell..."
