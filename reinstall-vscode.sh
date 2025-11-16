#!/bin/bash

# VS Code Complete Removal and Reinstallation Script for macOS
# This script completely removes VS Code and all its data, then reinstalls it

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}VS Code Complete Reinstallation Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to ask for user confirmation
confirm() {
    while true; do
        read -p "$(echo -e "${YELLOW}$1 (y/n): ${NC}")" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Warning about data loss
echo -e "${RED}⚠️  WARNING: This script will completely remove VS Code and ALL of its data!${NC}"
echo -e "${RED}   This includes:${NC}"
echo -e "${RED}   • All extensions${NC}"
echo -e "${RED}   • All settings and configurations${NC}"
echo -e "${RED}   • All workspace data${NC}"
echo -e "${RED}   • All user snippets${NC}"
echo -e "${RED}   • Command history${NC}"
echo ""

if ! confirm "Are you sure you want to proceed?"; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Stopping VS Code processes${NC}"

# Kill all VS Code processes
echo -e "${YELLOW}🔄 Stopping all VS Code processes...${NC}"
pkill -f "Visual Studio Code" 2>/dev/null || echo -e "${GREEN}No VS Code processes running${NC}"
pkill -f "Code Helper" 2>/dev/null || echo -e "${GREEN}No Code Helper processes running${NC}"
pkill -f "code" 2>/dev/null || echo -e "${GREEN}No code CLI processes running${NC}"

sleep 2
echo -e "${GREEN}✓ VS Code processes stopped${NC}"

echo ""
echo -e "${BLUE}Step 2: Removing VS Code application${NC}"

# Remove VS Code from Applications
if [ -d "/Applications/Visual Studio Code.app" ]; then
    echo -e "${YELLOW}🗑️  Removing VS Code from Applications...${NC}"
    sudo rm -rf "/Applications/Visual Studio Code.app"
    echo -e "${GREEN}✓ VS Code application removed${NC}"
else
    echo -e "${YELLOW}VS Code not found in /Applications${NC}"
fi

# Remove Homebrew installation if present
if command -v brew >/dev/null 2>&1; then
    if brew list --cask visual-studio-code >/dev/null 2>&1; then
        echo -e "${YELLOW}🗑️  Removing Homebrew VS Code installation...${NC}"
        brew uninstall --cask visual-studio-code
        echo -e "${GREEN}✓ Homebrew VS Code removed${NC}"
    else
        echo -e "${GREEN}No Homebrew VS Code installation found${NC}"
    fi
fi

echo ""
echo -e "${BLUE}Step 3: Removing VS Code user data and settings${NC}"

# Remove user data directories
USER_DATA_PATHS=(
    "$HOME/Library/Application Support/Code"
    "$HOME/Library/Preferences/com.microsoft.VSCode.plist"
    "$HOME/Library/Preferences/com.microsoft.VSCode.helper.plist"
    "$HOME/Library/Caches/com.microsoft.VSCode"
    "$HOME/Library/Caches/com.microsoft.VSCode.ShipIt"
    "$HOME/Library/Saved Application State/com.microsoft.VSCode.savedState"
    "$HOME/Library/Logs/Visual Studio Code"
    "$HOME/.vscode"
    "$HOME/.vscode-insiders"
)

for path in "${USER_DATA_PATHS[@]}"; do
    if [ -e "$path" ]; then
        echo -e "${YELLOW}🗑️  Removing: $path${NC}"
        rm -rf "$path"
        echo -e "${GREEN}✓ Removed: $path${NC}"
    else
        echo -e "${GRAY}Not found: $path${NC}"
    fi
done

echo ""
echo -e "${BLUE}Step 4: Removing VS Code from PATH${NC}"

# Remove code command from PATH
CODE_PATHS=(
    "/usr/local/bin/code"
    "/opt/homebrew/bin/code"
)

for path in "${CODE_PATHS[@]}"; do
    if [ -L "$path" ] || [ -f "$path" ]; then
        echo -e "${YELLOW}🗑️  Removing code command: $path${NC}"
        sudo rm -f "$path"
        echo -e "${GREEN}✓ Removed: $path${NC}"
    fi
done

echo ""
echo -e "${BLUE}Step 5: Cleaning up remaining files${NC}"

# Clean up any remaining VS Code related files
echo -e "${YELLOW}🧹 Cleaning up any remaining VS Code files...${NC}"
find "$HOME/Library" -name "*vscode*" -type d -exec rm -rf {} + 2>/dev/null || true
find "$HOME/Library" -name "*VSCode*" -type f -delete 2>/dev/null || true

echo -e "${GREEN}✓ Cleanup completed${NC}"

echo ""
echo -e "${BLUE}Step 6: Installing VS Code${NC}"

# Ask user for installation method
echo -e "${YELLOW}Choose installation method:${NC}"
echo "1) Download from Microsoft (recommended)"
echo "2) Install via Homebrew"
echo ""

while true; do
    read -p "$(echo -e "${YELLOW}Enter your choice (1 or 2): ${NC}")" choice
    case $choice in
        1)
            echo -e "${YELLOW}🔄 Downloading VS Code from Microsoft...${NC}"
            
            # Download VS Code
            curl -L "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal" -o "/tmp/VSCode-darwin-universal.zip"
            
            # Extract and install
            echo -e "${YELLOW}📦 Installing VS Code...${NC}"
            unzip -q "/tmp/VSCode-darwin-universal.zip" -d "/tmp/"
            sudo cp -R "/tmp/Visual Studio Code.app" "/Applications/"
            
            # Set permissions
            sudo chown -R $(whoami):staff "/Applications/Visual Studio Code.app"
            
            # Clean up download
            rm -f "/tmp/VSCode-darwin-universal.zip"
            rm -rf "/tmp/Visual Studio Code.app"
            
            echo -e "${GREEN}✓ VS Code installed successfully${NC}"
            break
            ;;
        2)
            if ! command -v brew >/dev/null 2>&1; then
                echo -e "${RED}❌ Homebrew not found. Please install Homebrew first or choose option 1.${NC}"
                continue
            fi
            
            echo -e "${YELLOW}🔄 Installing VS Code via Homebrew...${NC}"
            brew install --cask visual-studio-code
            echo -e "${GREEN}✓ VS Code installed successfully via Homebrew${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}"
            ;;
    esac
done

echo ""
echo -e "${BLUE}Step 7: Setting up code command in PATH${NC}"

# Install code command
if [ -d "/Applications/Visual Studio Code.app" ]; then
    echo -e "${YELLOW}🔗 Setting up 'code' command...${NC}"
    sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "/usr/local/bin/code"
    echo -e "${GREEN}✓ 'code' command available in terminal${NC}"
else
    echo -e "${YELLOW}⚠️  VS Code app not found in expected location${NC}"
fi

echo ""
echo -e "${GREEN}🎉 VS Code reinstallation completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Launch VS Code from Applications or run ${GREEN}code${NC} in terminal"
echo -e "2. Sign in to sync your extensions and settings (if desired)"
echo -e "3. Install your preferred extensions"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  Launch VS Code:           ${GREEN}code${NC}"
echo -e "  Open current directory:   ${GREEN}code .${NC}"
echo -e "  Open specific file:       ${GREEN}code filename${NC}"
echo ""

# Ask if user wants to launch VS Code
if confirm "Would you like to launch VS Code now?"; then
    echo -e "${YELLOW}🚀 Launching VS Code...${NC}"
    open "/Applications/Visual Studio Code.app"
    echo -e "${GREEN}✓ VS Code launched${NC}"
fi

echo ""
echo -e "${GREEN}Script completed successfully!${NC}"