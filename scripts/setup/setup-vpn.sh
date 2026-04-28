#!/bin/bash
# scripts/setup/setup-vpn.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VPN setup — required for APSL scraping (apslsoccer.com IP-blocks us).
#
# Steps performed (each idempotent):
#   1. Locate a WireGuard provider config.
#      Search order:
#        a. $WIREGUARD_CONFIG_FILE  (env var, may be set in ./env)
#        b. $REPO_ROOT/scrape-vpn.conf  (gitignored, drop it here)
#        c. $HOME/scrape-vpn.conf
#        d. Already imported at /etc/wireguard/scrape-vpn.conf  → reuse
#   2. Import it to /etc/wireguard/scrape-vpn.conf (chmod 600, root).
#   3. Start the dedicated scraper+VPN container (SSH-safe, isolated NS).
#   4. Verify the tunnel: container IP must differ from host IP.
#
# Skip with:  ./setup.sh --skip vpn   (Lighthouse APSL data won't refresh)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

WG_CONF="/etc/wireguard/scrape-vpn.conf"

# ── 0. macOS: containerized WireGuard requires Linux kernel — skip ────
if [ "$OS_TYPE" != "Linux" ]; then
  print_warning "VPN container is Linux-only — skipping on $OS_TYPE"
  print_warning "  (scrape from a Linux host, or set NO_VPN=1 to bypass)"
  exit 0
fi

# ── 1. Locate config ──────────────────────────────────────────────────
SOURCE=""
if [ -n "${WIREGUARD_CONFIG_FILE:-}" ] && [ -f "$WIREGUARD_CONFIG_FILE" ]; then
  SOURCE="$WIREGUARD_CONFIG_FILE"
elif [ -f "$REPO_ROOT/scrape-vpn.conf" ]; then
  SOURCE="$REPO_ROOT/scrape-vpn.conf"
elif [ -f "$HOME/scrape-vpn.conf" ]; then
  SOURCE="$HOME/scrape-vpn.conf"
elif sudo test -f "$WG_CONF" 2>/dev/null; then
  print_success "WireGuard config already at $WG_CONF — reusing"
else
  print_error "No WireGuard config found."
  cat >&2 <<EOF

  APSL scraping requires a VPN. To finish setup:

    1. Get a WireGuard config from your provider:
         - Mullvad:   https://mullvad.net/en/account#/wireguard-config
         - ProtonVPN: https://account.protonvpn.com/downloads#wireguard-configuration
    2. Drop it as one of:
         $REPO_ROOT/scrape-vpn.conf      (gitignored — recommended)
         $HOME/scrape-vpn.conf
       Or set in ./env:
         WIREGUARD_CONFIG_FILE=/path/to/provider.conf
    3. Re-run:  ./setup.sh --only vpn

  To skip the VPN entirely (Lighthouse APSL data won't refresh):
    ./setup.sh --skip vpn

EOF
  exit 1
fi

# ── 2. Import (only if we found a source file and dest is missing/older) ─
if [ -n "$SOURCE" ]; then
  if sudo test -f "$WG_CONF" 2>/dev/null && ! sudo test "$SOURCE" -nt "$WG_CONF" 2>/dev/null; then
    print_success "WireGuard config at $WG_CONF is up to date (source: $SOURCE)"
  else
    print_status "Importing $SOURCE → $WG_CONF"
    sudo "$REPO_ROOT/scripts/setup/setup-wireguard.sh" import "$SOURCE"
  fi
fi

# ── 3. Bring scraper container up ─────────────────────────────────────
print_status "Starting scraper+VPN container..."
"$REPO_ROOT/scripts/scrape-vpn.sh" up

# ── 4. Verify tunnel ──────────────────────────────────────────────────
print_status "Verifying VPN tunnel..."
HOST_IP=$(curl -s --max-time 6 https://api.ipify.org 2>/dev/null || echo "")
VPN_IP=$("$REPO_ROOT/scripts/scrape-vpn.sh" exec curl -s --max-time 6 https://api.ipify.org 2>/dev/null || echo "")

echo "   host IP:      ${HOST_IP:-unknown}"
echo "   container IP: ${VPN_IP:-unknown}"

if [ -z "$VPN_IP" ] || [ "$VPN_IP" = "unknown" ]; then
  print_error "VPN container could not reach the internet."
  echo "   Inspect:  make scrape-vpn-logs" >&2
  exit 1
fi

if [ -z "$HOST_IP" ]; then
  print_warning "Could not determine host IP — VPN reachable, but cannot confirm tunneling"
elif [ "$HOST_IP" = "$VPN_IP" ]; then
  print_error "VPN tunnel NOT active — container IP matches host IP."
  echo "   The WireGuard config may be invalid or the peer is unreachable." >&2
  echo "   Inspect:  make scrape-vpn-logs" >&2
  exit 1
else
  print_success "VPN tunnel active (host $HOST_IP ≠ container $VPN_IP)"
fi
