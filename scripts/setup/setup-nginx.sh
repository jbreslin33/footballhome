#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# setup-nginx.sh — install + configure nginx + Let's Encrypt for the
# public-facing footballhome.org server.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Idempotent. Safe to re-run.
#
# What it does:
#   1. apt-installs nginx + certbot + python3-certbot-nginx
#   2. If TLS certs already exist -> installs the real HTTPS site config
#      from config/nginx-footballhome.conf
#      Otherwise -> installs an HTTP-only stub so nginx will start and
#      the LE HTTP-01 challenge can run
#   3. Reloads nginx
#   4. If TLS certs DON'T exist AND --obtain-cert is passed (or
#      LE_EMAIL is set in the environment), runs certbot --nginx
#      non-interactively to get them, then swaps in the real config.
#
# Usage:
#   sudo ./scripts/setup/setup-nginx.sh                  # config only
#   sudo LE_EMAIL=you@example.com ./scripts/setup/setup-nginx.sh --obtain-cert
#   sudo ./scripts/setup/setup-nginx.sh --obtain-cert    # will prompt for email
#
# Override domains:
#   DOMAINS="footballhome.org www.footballhome.org" sudo ./scripts/setup/setup-nginx.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# ── Config ────────────────────────────────────────────────────────────
DOMAINS="${DOMAINS:-footballhome.org www.footballhome.org}"
PRIMARY_DOMAIN="$(echo "$DOMAINS" | awk '{print $1}')"
SITE_NAME="footballhome"
NGINX_AVAIL="/etc/nginx/sites-available/$SITE_NAME"
NGINX_ENAB="/etc/nginx/sites-enabled/$SITE_NAME"

OBTAIN_CERT=0
case "${1:-}" in
    --obtain-cert) OBTAIN_CERT=1 ;;
    "") : ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
esac

# ── Locate repo root ──────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
while [ ! -f "$REPO_ROOT/Makefile" ]; do
    REPO_ROOT="$(dirname "$REPO_ROOT")"
    if [ "$REPO_ROOT" = "/" ]; then
        echo "❌ Could not find repo root" >&2
        exit 1
    fi
done
NGINX_SRC="$REPO_ROOT/config/nginx-footballhome.conf"
LE_LIVE="/etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem"

# ── Sudo gate ─────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo "❌ Run with sudo: sudo $0 $*" >&2
    exit 1
fi

# ── Helpers ───────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${BLUE}→${NC} $1"; }
ok()      { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
err()     { echo -e "${RED}✗${NC} $1" >&2; }

# ── 1. Install packages ───────────────────────────────────────────────
if ! command -v nginx &> /dev/null; then
    info "Installing nginx..."
    apt-get update -qq
    apt-get install -y nginx
    ok "nginx installed"
else
    ok "nginx already installed"
fi

if ! command -v certbot &> /dev/null; then
    info "Installing certbot + nginx plugin..."
    apt-get install -y certbot python3-certbot-nginx
    ok "certbot installed"
else
    ok "certbot already installed"
fi

# ── 2. Site config ────────────────────────────────────────────────────
if [ ! -f "$NGINX_SRC" ]; then
    err "Missing $NGINX_SRC"
    exit 1
fi

install_real_config() {
    info "Installing full HTTPS nginx config from $NGINX_SRC"
    cp "$NGINX_SRC" "$NGINX_AVAIL"
}

install_stub_config() {
    info "Installing HTTP-only stub config (no certs yet)"
    cat > "$NGINX_AVAIL" <<STUB
# Temporary HTTP-only config installed by setup-nginx.sh.
# Replaced with config/nginx-footballhome.conf once Let's Encrypt
# certs exist (re-run this script).
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name $DOMAINS _;
    client_max_body_size 100M;

    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
STUB
}

if [ -f "$LE_LIVE" ]; then
    install_real_config
else
    install_stub_config
fi

ln -sf "$NGINX_AVAIL" "$NGINX_ENAB"
rm -f /etc/nginx/sites-enabled/default

# ── 3. Reload nginx ───────────────────────────────────────────────────
NGINX_TEST_LOG="$(mktemp)"
if nginx -t 2>"$NGINX_TEST_LOG"; then
    systemctl enable --now nginx
    systemctl reload nginx
    ok "nginx reloaded"
    rm -f "$NGINX_TEST_LOG"
else
    err "nginx config test failed:"
    cat "$NGINX_TEST_LOG" >&2
    rm -f "$NGINX_TEST_LOG"
    exit 1
fi

# ── 4. Optional: obtain cert ──────────────────────────────────────────
if [ "$OBTAIN_CERT" = "1" ] && [ ! -f "$LE_LIVE" ]; then
    info "Obtaining TLS cert via certbot --nginx for: $DOMAINS"
    info "Requires: ports 80/443 reachable from the public internet,"
    info "and DNS A/AAAA records for $DOMAINS pointing here."
    echo

    DOMAIN_ARGS=""
    for d in $DOMAINS; do
        DOMAIN_ARGS="$DOMAIN_ARGS -d $d"
    done

    if [ -n "${LE_EMAIL:-}" ]; then
        certbot --nginx --non-interactive --agree-tos --redirect \
            -m "$LE_EMAIL" $DOMAIN_ARGS
    else
        # Interactive -- certbot prompts for email + ToS.
        certbot --nginx --redirect $DOMAIN_ARGS
    fi

    if [ -f "$LE_LIVE" ]; then
        ok "TLS cert obtained"
        # certbot --nginx will have rewritten our config to add SSL.
        # Replace its rewritten version with our canonical one.
        install_real_config
        nginx -t && systemctl reload nginx
        ok "Real nginx config restored + reloaded"
    else
        warn "certbot did not produce $LE_LIVE — check output above"
    fi
elif [ ! -f "$LE_LIVE" ]; then
    echo
    warn "No TLS cert installed yet. To get one:"
    echo -e "    ${YELLOW}sudo LE_EMAIL=you@example.com $0 --obtain-cert${NC}"
    echo "  or interactively:"
    echo -e "    ${YELLOW}sudo $0 --obtain-cert${NC}"
fi

ok "nginx setup complete"
