#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WireGuard VPN Setup for Scraping
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Installs WireGuard and configures a VPN tunnel for scraping league sites
# that have IP-blocked this network. System-level VPN means all scraping
# methods (Chrome --dump-dom, Node fetch, Puppeteer) are automatically
# routed through the VPN with zero code changes.
#
# Prerequisites:
#   - A WireGuard config file from your VPN provider (Mullvad, ProtonVPN, etc.)
#     OR a self-hosted WireGuard server config
#
# Usage:
#   # Install WireGuard
#   ./setup-wireguard.sh install
#
#   # Import a config file from your VPN provider
#   ./setup-wireguard.sh import /path/to/provider-config.conf
#
#   # Connect / disconnect / check status
#   ./setup-wireguard.sh up
#   ./setup-wireguard.sh down
#   ./setup-wireguard.sh status
#
#   # Run a scrape through VPN (auto up + scrape + auto down)
#   ./setup-wireguard.sh scrape <make-target>
#   ./setup-wireguard.sh scrape scrape-apsl
#   ./setup-wireguard.sh scrape sync
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# ── Config ────────────────────────────────────────────────────────────
INTERFACE="scrape-vpn"
CONFIG_DIR="/etc/wireguard"
CONFIG_FILE="$CONFIG_DIR/$INTERFACE.conf"

# ── Colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ── Helpers ───────────────────────────────────────────────────────────
info()  { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }

need_root() {
  if [ "$EUID" -ne 0 ]; then
    error "This command requires root. Run with sudo."
    exit 1
  fi
}

# ── Commands ──────────────────────────────────────────────────────────

cmd_install() {
  need_root
  echo "Installing WireGuard..."

  if command -v apt-get &> /dev/null; then
    apt-get update -qq
    apt-get install -y wireguard wireguard-tools
  elif command -v dnf &> /dev/null; then
    dnf install -y wireguard-tools
  elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm wireguard-tools
  elif command -v brew &> /dev/null; then
    brew install wireguard-tools
  else
    error "Unsupported package manager. Install WireGuard manually: https://www.wireguard.com/install/"
    exit 1
  fi

  info "WireGuard installed"
  echo ""
  echo "Next steps:"
  echo "  1. Get a WireGuard config file from your VPN provider"
  echo "     - Mullvad: https://mullvad.net/en/account#/wireguard-config"
  echo "     - ProtonVPN: https://account.protonvpn.com/downloads#wireguard-configuration"
  echo "  2. Import it:"
  echo "     sudo ./setup-wireguard.sh import /path/to/downloaded.conf"
}

cmd_import() {
  need_root
  local source_file="$1"

  if [ -z "$source_file" ]; then
    error "Usage: setup-wireguard.sh import /path/to/provider-config.conf"
    exit 1
  fi

  if [ ! -f "$source_file" ]; then
    error "File not found: $source_file"
    exit 1
  fi

  # Validate it looks like a WireGuard config
  if ! grep -q '\[Interface\]' "$source_file"; then
    error "Does not look like a WireGuard config (missing [Interface] section)"
    exit 1
  fi

  if ! grep -q '\[Peer\]' "$source_file"; then
    error "Does not look like a WireGuard config (missing [Peer] section)"
    exit 1
  fi

  mkdir -p "$CONFIG_DIR"
  cp "$source_file" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"

  info "Config imported to $CONFIG_FILE"
  echo ""
  echo "Test it:"
  echo "  sudo ./setup-wireguard.sh up"
  echo "  curl -s https://api.ipify.org     # Should show VPN IP"
  echo "  sudo ./setup-wireguard.sh down"
}

cmd_up() {
  error "'up' on the host is disabled — it would drop your SSH session."
  echo "   The VPN ALWAYS runs inside the scraper container." >&2
  echo "   Use:  make scrape-vpn-up" >&2
  exit 1
}

cmd_down() {
  error "'down' on the host is disabled."
  echo "   Use:  make scrape-vpn-down" >&2
  exit 1
}

cmd_status() {
  error "'status' on the host is disabled."
  echo "   Use:  make scrape-vpn-status" >&2
  exit 1
}

cmd_scrape() {
  error "'scrape' via host VPN is disabled — it would drop your SSH session."
  echo "   Use:  make scrape-vpn-up && make sync-lighthouse" >&2
  exit 1
}

# ── Help ──────────────────────────────────────────────────────────────
cmd_help() {
  echo "WireGuard VPN for Scraping (container-only)"
  echo ""
  echo "The VPN ALWAYS runs inside an isolated podman container so it"
  echo "cannot drop your SSH session. This script only handles"
  echo "installing wireguard-tools and importing the provider config"
  echo "that the scraper container will read."
  echo ""
  echo "Usage: setup-wireguard.sh <command> [args]"
  echo ""
  echo "Commands:"
  echo "  install                    Install wireguard-tools on host"
  echo "  import <config.conf>       Stage VPN provider config for the container"
  echo "  help                       Show this help"
  echo ""
  echo "Then bring the VPN up inside the container:"
  echo "  make scrape-vpn-up"
  echo "  make scrape-vpn-status"
  echo "  make sync-lighthouse"
}

# ── Main ──────────────────────────────────────────────────────────────
case "${1:-help}" in
  install) cmd_install ;;
  import)  cmd_import "$2" ;;
  up)      cmd_up ;;
  down)    cmd_down ;;
  status)  cmd_status ;;
  scrape)  cmd_scrape "$2" ;;
  help)    cmd_help ;;
  *)
    error "Unknown command: $1"
    cmd_help
    exit 1
    ;;
esac
