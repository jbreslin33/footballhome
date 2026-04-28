#!/bin/bash
# scripts/setup/setup-scraper.sh — wireguard-tools + scraper container image
set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

if ! command -v wg &> /dev/null; then
  if [ "$OS_TYPE" = "Linux" ]; then
    print_status "Installing wireguard-tools..."
    sudo apt-get install -y wireguard-tools
    print_success "wireguard-tools installed"
  elif [ "$OS_TYPE" = "Darwin" ]; then
    command -v brew &> /dev/null && brew install wireguard-tools \
      || print_warning "Homebrew not found — skipping wireguard-tools"
  fi
else
  print_success "wireguard-tools already installed"
fi

if [ -f "$REPO_ROOT/.docker/scraper/Dockerfile" ]; then
  print_status "Building scraper+VPN container image..."
  if podman build -t footballhome-scraper:latest "$REPO_ROOT/.docker/scraper" > /tmp/scraper-build.log 2>&1; then
    print_success "Scraper image built: footballhome-scraper:latest"
  else
    print_warning "Scraper image build failed — see /tmp/scraper-build.log"
  fi
else
  print_warning ".docker/scraper/Dockerfile missing — skipping scraper image build"
fi
