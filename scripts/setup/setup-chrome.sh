#!/bin/bash
# scripts/setup/setup-chrome.sh — Google Chrome (host scrape paths)
set -e
source "$(dirname "$0")/_lib.sh"

CHROME_FOUND=false
if [ "$OS_TYPE" = "Darwin" ]; then
  [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] && CHROME_FOUND=true
elif [ "$OS_TYPE" = "Linux" ]; then
  command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null && CHROME_FOUND=true
fi

if [ "$CHROME_FOUND" = true ]; then
  print_success "Google Chrome already installed"
  exit 0
fi

if [ "$OS_TYPE" = "Linux" ]; then
  print_status "Installing Google Chrome via apt..."
  curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg 2>/dev/null || true
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y google-chrome-stable
  print_success "Google Chrome installed: $(google-chrome-stable --version)"
elif [ "$OS_TYPE" = "Darwin" ]; then
  if command -v brew &> /dev/null; then
    print_status "Installing Google Chrome via Homebrew Cask..."
    brew install --cask google-chrome
    print_success "Google Chrome installed"
  else
    print_warning "Install Chrome manually: https://www.google.com/chrome/"
  fi
fi
