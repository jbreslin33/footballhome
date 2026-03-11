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
  need_root

  if ! command -v wg &> /dev/null; then
    error "WireGuard not installed. Run: sudo ./setup-wireguard.sh install"
    exit 1
  fi

  if [ ! -f "$CONFIG_FILE" ]; then
    error "No config found at $CONFIG_FILE"
    echo "Import one: sudo ./setup-wireguard.sh import /path/to/config.conf"
    exit 1
  fi

  # Check if already up
  if wg show "$INTERFACE" &> /dev/null 2>&1; then
    warn "VPN already connected ($INTERFACE)"
    return 0
  fi

  echo "Connecting VPN ($INTERFACE)..."
  wg-quick up "$INTERFACE"

  # Verify with external IP check
  sleep 1
  local vpn_ip
  vpn_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unknown")
  info "VPN connected — external IP: $vpn_ip"
}

cmd_down() {
  need_root

  if ! wg show "$INTERFACE" &> /dev/null 2>&1; then
    warn "VPN not connected ($INTERFACE)"
    return 0
  fi

  wg-quick down "$INTERFACE"
  sleep 1
  local real_ip
  real_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unknown")
  info "VPN disconnected — external IP: $real_ip"
}

cmd_status() {
  if wg show "$INTERFACE" &> /dev/null 2>&1; then
    local vpn_ip
    vpn_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unknown")
    info "VPN is UP ($INTERFACE) — external IP: $vpn_ip"
    echo ""
    wg show "$INTERFACE"
  else
    local real_ip
    real_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unknown")
    warn "VPN is DOWN ($INTERFACE) — external IP: $real_ip"
  fi
}

cmd_scrape() {
  need_root
  local target="$1"

  if [ -z "$target" ]; then
    error "Usage: setup-wireguard.sh scrape <make-target>"
    echo "  Example: sudo ./setup-wireguard.sh scrape scrape-apsl"
    echo "  Example: sudo ./setup-wireguard.sh scrape sync"
    exit 1
  fi

  # Find project root
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  local project_root="$script_dir"
  while [ ! -f "$project_root/Makefile" ]; do
    project_root="$(dirname "$project_root")"
  done

  # Connect VPN
  cmd_up

  # Run the make target, ensure VPN goes down even on failure
  echo ""
  echo "Running: make $target"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  local exit_code=0
  (cd "$project_root" && make "$target") || exit_code=$?
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Disconnect VPN
  echo ""
  cmd_down

  if [ "$exit_code" -ne 0 ]; then
    error "make $target failed (exit code $exit_code)"
    exit "$exit_code"
  fi

  info "Scrape complete via VPN"
}

# ── Help ──────────────────────────────────────────────────────────────
cmd_help() {
  echo "WireGuard VPN for Scraping"
  echo ""
  echo "Usage: setup-wireguard.sh <command> [args]"
  echo ""
  echo "Commands:"
  echo "  install                    Install WireGuard"
  echo "  import <config.conf>       Import VPN provider config"
  echo "  up                         Connect VPN"
  echo "  down                       Disconnect VPN"
  echo "  status                     Show VPN status + external IP"
  echo "  scrape <make-target>       Connect VPN, run make target, disconnect"
  echo "  help                       Show this help"
  echo ""
  echo "Examples:"
  echo "  sudo ./setup-wireguard.sh install"
  echo "  sudo ./setup-wireguard.sh import ~/Downloads/mullvad-us25.conf"
  echo "  sudo ./setup-wireguard.sh scrape scrape-apsl"
  echo "  sudo ./setup-wireguard.sh scrape sync"
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
