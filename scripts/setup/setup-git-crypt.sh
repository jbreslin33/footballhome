#!/bin/bash
# Setup script to install git-crypt for encrypted credential management

echo "🔐 Installing git-crypt for credential encryption..."

# Detect OS and install git-crypt
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    brew install git-crypt
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git-crypt
    elif command -v yum &> /dev/null; then
        sudo yum install -y git-crypt
    else
        echo "❌ Unsupported Linux distribution. Please install git-crypt manually."
        exit 1
    fi
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "✅ git-crypt installed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Initialize git-crypt: git-crypt init"
echo "   2. Share the key with team members: git-crypt export-key /path/to/key"
echo "   3. On new machines: git-crypt unlock /path/to/key"
