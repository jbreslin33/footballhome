#!/bin/bash
# scripts/setup/setup-base.sh — curl, make, build-essential
set -e
source "$(dirname "$0")/_lib.sh"

if ! command -v curl &> /dev/null; then
  print_status "Installing curl..."
  if [ "$OS_TYPE" = "Linux" ]; then
    sudo apt-get update -qq
    sudo apt-get install -y curl
  elif [ "$OS_TYPE" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
      print_error "curl missing and Homebrew not installed. Install Homebrew: https://brew.sh"
      exit 1
    fi
    brew install curl
  fi
  print_success "curl installed"
else
  print_success "curl already installed"
fi

if ! command -v make &> /dev/null; then
  print_status "Installing make + build essentials..."
  if [ "$OS_TYPE" = "Linux" ]; then
    sudo apt-get update -qq
    sudo apt-get install -y make build-essential
  elif [ "$OS_TYPE" = "Darwin" ]; then
    xcode-select --install 2>/dev/null || true
  fi
  print_success "make installed"
else
  print_success "make already installed"
fi
