#!/bin/bash
# scripts/setup/setup-vendor.sh — download vis-network for the schema viewer
set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

VENDOR_DIR="$REPO_ROOT/frontend/vendor"
VIS_VERSION="9.1.9"
mkdir -p "$VENDOR_DIR"

fetch_if_missing() {
  local url="$1" dest="$2"
  if [ ! -f "$dest" ]; then
    curl -sL "$url" -o "$dest"
    print_success "Downloaded $(basename "$dest")"
  else
    print_success "$(basename "$dest") already present"
  fi
}

fetch_if_missing \
  "https://unpkg.com/vis-network@${VIS_VERSION}/standalone/umd/vis-network.min.js" \
  "$VENDOR_DIR/vis-network.min.js"

fetch_if_missing \
  "https://unpkg.com/vis-network@${VIS_VERSION}/styles/vis-network.min.css" \
  "$VENDOR_DIR/vis-network.min.css"
