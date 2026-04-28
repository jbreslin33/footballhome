#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Scraper container entrypoint
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Brings up WireGuard (if a config is present and NO_VPN!=1), then execs
# the container CMD. The VPN lives entirely inside this container's
# network namespace — the host is never touched.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

INTERFACE="${WG_INTERFACE:-scrape-vpn}"
CONFIG="/etc/wireguard/${INTERFACE}.conf"

if [ "${NO_VPN:-0}" = "1" ]; then
  echo "[scraper] NO_VPN=1 — skipping WireGuard"
elif [ ! -r "$CONFIG" ]; then
  echo "[scraper] ⚠️  No WireGuard config at $CONFIG (or unreadable) — running without VPN"
else
  echo "[scraper] 🔒 Bringing up WireGuard interface: $INTERFACE"
  # iptables-legacy is more compatible with wg-quick's default rules
  # in containers that don't have nftables fully wired up.
  update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
  wg-quick up "$INTERFACE"
  EXTERNAL_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "unknown")
  echo "[scraper] 🔒 VPN up — external IP: $EXTERNAL_IP"

  # Tear down on exit so a restart leaves a clean namespace.
  trap 'echo "[scraper] 🔓 Stopping WireGuard"; wg-quick down "$INTERFACE" 2>/dev/null || true' EXIT
fi

exec "$@"
