#!/bin/bash

# DBeaver Installation Script for Ubuntu
# This script installs DBeaver Community Edition (free version)

echo "🚀 Installing DBeaver Community Edition..."

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install required dependencies
echo "📦 Installing dependencies..."
sudo apt install -y wget gnupg2 software-properties-common apt-transport-https ca-certificates

# Add DBeaver GPG key
echo "🔑 Adding DBeaver GPG key..."
wget -qO - https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg

# Add DBeaver repository
echo "📂 Adding DBeaver repository..."
echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

# Update package list again
echo "📦 Updating package list with DBeaver repository..."
sudo apt update

# Install DBeaver
echo "💾 Installing DBeaver Community Edition..."
sudo apt install -y dbeaver-ce

echo ""
echo "✅ DBeaver installation complete!"
echo ""
echo "🎯 To connect to your Football Home database:"
echo "   1. Launch DBeaver from Applications menu or run: dbeaver"
echo "   2. Create New Connection → PostgreSQL"
echo "   3. Use these connection details:"
echo "      Server Host: footballhome.org"
echo "      Port: 5432"
echo "      Database: footballhome"
echo "      Username: footballapp"
echo "      Password: footballpass123"
echo ""
echo "🔍 Once connected, you can:"
echo "   - Right-click database → Generate ER Diagram"
echo "   - Browse tables and relationships"
echo "   - Run SQL queries"
echo ""
echo "🚀 Launch DBeaver now with: dbeaver &"