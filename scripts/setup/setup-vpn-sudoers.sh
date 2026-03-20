#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Setup passwordless sudo for WireGuard VPN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Adds a sudoers rule so the scrape scripts can bring VPN up/down
# without prompting for a password.
#
# Only grants NOPASSWD for these specific commands:
#   - wg show scrape-vpn
#   - wg-quick up scrape-vpn
#   - wg-quick down scrape-vpn
#   - test -f /etc/wireguard/scrape-vpn.conf
#
# Usage:
#   sudo ./setup-vpn-sudoers.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Must run as root: sudo $0"
  exit 1
fi

SUDOERS_FILE="/etc/sudoers.d/wireguard-scrape-vpn"
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo jbreslin)}"

if [ -f "$SUDOERS_FILE" ]; then
  echo "⚠️  $SUDOERS_FILE already exists:"
  cat "$SUDOERS_FILE"
  echo ""
  echo "Remove with: sudo rm $SUDOERS_FILE"
  exit 0
fi

cat > "$SUDOERS_FILE" <<EOF
# Allow $TARGET_USER to manage the scrape-vpn WireGuard interface without password
$TARGET_USER ALL=(ALL) NOPASSWD: /usr/bin/wg show scrape-vpn
$TARGET_USER ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up scrape-vpn
$TARGET_USER ALL=(ALL) NOPASSWD: /usr/bin/wg-quick down scrape-vpn
$TARGET_USER ALL=(ALL) NOPASSWD: /usr/bin/test -f /etc/wireguard/scrape-vpn.conf
EOF

chmod 0440 "$SUDOERS_FILE"

# Validate syntax
if visudo -cf "$SUDOERS_FILE" > /dev/null 2>&1; then
  echo "✅ Sudoers rule installed: $SUDOERS_FILE"
  echo "   User: $TARGET_USER"
  echo "   Commands (NOPASSWD):"
  echo "     sudo wg show scrape-vpn"
  echo "     sudo wg-quick up scrape-vpn"
  echo "     sudo wg-quick down scrape-vpn"
  echo "     sudo test -f /etc/wireguard/scrape-vpn.conf"
  echo ""
  echo "   VPN automation is now ready — scrape scripts won't prompt for password."
else
  echo "❌ Syntax error in sudoers file — removing to be safe"
  rm -f "$SUDOERS_FILE"
  exit 1
fi
