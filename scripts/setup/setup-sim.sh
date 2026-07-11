#!/bin/bash
# scripts/setup/setup-sim.sh — native build deps for footballhome_sim
#
# The sim tests build natively on the host (not in a container), so we
# need the same libraries the sim container will link. Right now that's:
#   - cmake     (build system, C++20)
#   - libssl-dev (OpenSSL headers/lib for HMAC-SHA256 in JwtVerifier;
#                 keeps the sim on the same crypto stack as the backend)
#   - qemu-user-static (optional — enables cross-arch determinism test)
#
# Everything here is idempotent.
set -e
source "$(dirname "$0")/_lib.sh"

if [ "$OS_TYPE" != "Linux" ]; then
  print_warning "sim setup only supports Linux hosts right now (macOS uses container build); skipping."
  exit 0
fi

# ── cmake ─────────────────────────────────────────────────────────────
if ! command -v cmake &> /dev/null; then
  print_status "Installing cmake..."
  sudo apt-get update -qq
  sudo apt-get install -y cmake
  print_success "cmake installed"
else
  print_success "cmake already installed ($(cmake --version | head -1))"
fi

# ── libssl-dev ────────────────────────────────────────────────────────
if ! dpkg -s libssl-dev >/dev/null 2>&1; then
  print_status "Installing libssl-dev (OpenSSL headers for sim JwtVerifier)..."
  sudo apt-get update -qq
  sudo apt-get install -y libssl-dev
  print_success "libssl-dev installed"
else
  print_success "libssl-dev already installed"
fi

# ── qemu-user-static (optional cross-arch determinism) ────────────────
if ! dpkg -s qemu-user-static >/dev/null 2>&1; then
  print_warning "qemu-user-static not installed — sim/scripts/check_determinism_cross_arch.sh will SKIP."
  print_warning "Optional; install with: sudo apt-get install -y qemu-user-static binfmt-support"
else
  print_success "qemu-user-static present (cross-arch determinism test enabled)"
fi
