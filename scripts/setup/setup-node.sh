#!/bin/bash
# scripts/setup/setup-node.sh — Node 20 + npm dependencies
set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

if ! command -v node &> /dev/null; then
  if [ "$OS_TYPE" = "Linux" ]; then
    print_status "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif [ "$OS_TYPE" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
      print_error "Homebrew required: https://brew.sh"
      exit 1
    fi
    brew install node@20
    for d in /opt/homebrew/opt/node@20/bin /usr/local/opt/node@20/bin; do
      if [ -d "$d" ] && [[ ":$PATH:" != *":$d:"* ]]; then
        echo "export PATH=\"$d:\$PATH\"" >> ~/.zshrc
        export PATH="$d:$PATH"
      fi
    done
  fi
  print_success "Node.js installed: $(node --version)"
else
  print_success "Node.js already installed: $(node --version)"
fi

if [ -f "$REPO_ROOT/package.json" ]; then
  print_status "Installing Node.js dependencies..."
  (cd "$REPO_ROOT" && npm install --silent)
  print_success "Node dependencies installed"
fi
