#!/usr/bin/env bash
# Install a host nginx vhost for DEV=<slug> from the template.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib-dev-slot.sh
source "$ROOT/scripts/dev/lib-dev-slot.sh"

load_dev_slot "${DEV:-${1:-}}"

TEMPLATE="$ROOT/config/nginx-dev-slot.conf.template"
OUT="/etc/nginx/sites-available/footballhome-dev-${FH_DEV_SLUG}.conf"
LINK="/etc/nginx/sites-enabled/footballhome-dev-${FH_DEV_SLUG}.conf"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: missing $TEMPLATE" >&2
  exit 1
fi

TMP="$(mktemp)"
sed \
  -e "s/__HOST_PREFIX__/${FH_DEV_HOST_PREFIX}/g" \
  -e "s/__FRONTEND_PORT__/${FH_DEV_FRONTEND_PORT}/g" \
  -e "s/__BACKEND_PORT__/${FH_DEV_BACKEND_PORT}/g" \
  "$TEMPLATE" > "$TMP"

if [ "$(id -u)" -ne 0 ]; then
  echo "[dev-nginx] need root to install into /etc/nginx — printing config instead:"
  cat "$TMP"
  echo ""
  echo "Install with: sudo make dev-nginx DEV=$FH_DEV_SLUG"
  rm -f "$TMP"
  exit 0
fi

install -m 644 "$TMP" "$OUT"
rm -f "$TMP"
ln -sfn "$OUT" "$LINK"
nginx -t
systemctl reload nginx || service nginx reload
echo "[dev-nginx] installed $OUT"
echo "  DNS: ${FH_DEV_HOST_PREFIX}.dev.footballhome.org → this host"
echo "  TLS: sudo certbot --nginx -d ${FH_DEV_HOST_PREFIX}.dev.footballhome.org"
echo "  Or use http://127.0.0.1:${FH_DEV_FRONTEND_PORT} without DNS"
