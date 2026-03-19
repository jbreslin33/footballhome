#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VPN Wrapper — ensures VPN is up before running a command
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Used by APSL and CSL scrape scripts. These sites (LeagueApps platform)
# block our IP, so all requests must go through WireGuard VPN.
#
# Usage:
#   ./vpn-wrap.sh <command> [args...]
#
# Examples:
#   ./vpn-wrap.sh ./scrape-standings.sh
#   ./vpn-wrap.sh node scrape-team-pages.js --league apsl
#
# Behavior:
#   - If VPN is already up: runs command, leaves VPN up
#   - If VPN is down: brings it up, runs command, brings it down
#   - If VPN setup is missing: prints clear error and exits
#   - Requires sudo (WireGuard needs root for interface management)
#
# Skip VPN (for testing or when IP isn't blocked):
#   NO_VPN=1 ./vpn-wrap.sh ./scrape-standings.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

INTERFACE="scrape-vpn"

# ── Skip VPN if requested ─────────────────────────────────────────────
if [ "${NO_VPN:-0}" = "1" ]; then
  echo "   ⚠️  NO_VPN=1 — skipping VPN, running directly"
  exec "$@"
fi

# ── Check WireGuard is installed ──────────────────────────────────────
if ! command -v wg &> /dev/null; then
  echo "❌ WireGuard not installed."
  echo "   Run: sudo scripts/setup/setup-wireguard.sh install"
  echo "   Then: sudo scripts/setup/setup-wireguard.sh import /path/to/config.conf"
  echo ""
  echo "   To skip VPN (stale cache): NO_VPN=1 make scrape-apsl-standings"
  exit 1
fi

# ── Check config exists (needs sudo — /etc/wireguard is root-only) ──
if ! sudo test -f "/etc/wireguard/${INTERFACE}.conf"; then
  echo "❌ No VPN config found at /etc/wireguard/${INTERFACE}.conf"
  echo "   Run: sudo scripts/setup/setup-wireguard.sh import /path/to/config.conf"
  echo ""
  echo "   To skip VPN (stale cache): NO_VPN=1 make scrape-apsl-standings"
  exit 1
fi

# ── Determine if we started the VPN (so we know whether to stop it) ──
VPN_WAS_UP=0
if sudo wg show "$INTERFACE" &> /dev/null 2>&1; then
  VPN_WAS_UP=1
  echo "   🔒 VPN already connected"
else
  echo "   🔒 Connecting VPN..."
  sudo wg-quick up "$INTERFACE"
  sleep 1
  VPN_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unknown")
  echo "   🔒 VPN connected — IP: $VPN_IP"
fi

# ── Run the actual command ────────────────────────────────────────────
EXIT_CODE=0
"$@" || EXIT_CODE=$?

# ── Tear down VPN if we brought it up ─────────────────────────────────
if [ "$VPN_WAS_UP" = "0" ]; then
  echo "   🔓 Disconnecting VPN..."
  sudo wg-quick down "$INTERFACE" 2>/dev/null || true
fi

exit $EXIT_CODE
