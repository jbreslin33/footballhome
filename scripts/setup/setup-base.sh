#!/bin/bash
# scripts/setup/setup-base.sh — curl, make, build-essential, vm.swappiness
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

# Keep the backend + postgres in RAM: at the default swappiness (60) the
# kernel swaps idle app memory out even with GBs free, and on a spinning
# disk every request then waits on swap-ins ("loading" on every screen,
# 2026-10-29).
if [ "$OS_TYPE" = "Linux" ]; then
  SWAPPINESS_CONF=/etc/sysctl.d/99-swappiness.conf
  if [ "$(cat /proc/sys/vm/swappiness)" != "10" ] || [ ! -f "$SWAPPINESS_CONF" ]; then
    print_status "Setting vm.swappiness=10..."
    echo 'vm.swappiness=10' | sudo tee "$SWAPPINESS_CONF" > /dev/null
    sudo sysctl -q -p "$SWAPPINESS_CONF"
    print_success "vm.swappiness=10"
  else
    print_success "vm.swappiness already 10"
  fi
fi
