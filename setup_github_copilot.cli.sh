#!/bin/bash

# 1. Update and install Node.js v22
echo "📦 Updating Node.js to v22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 2. Install Copilot CLI
echo "🤖 Installing GitHub Copilot..."
sudo npm install -g @github/copilot

# 3. Add shell alias (so you can use '??')
SHELL_RC="$HOME/.bashrc"
if ! grep -q 'copilot alias' "$SHELL_RC"; then
    echo 'eval "$(copilot alias -- bash)"' >> "$SHELL_RC"
fi

echo "✅ Script complete. Please run: source ~/.bashrc"
