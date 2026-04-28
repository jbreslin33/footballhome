#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# scrape-vpn.sh — manage the dedicated scraper+VPN container
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Why this exists:
#   The host-level WireGuard tunnel re-routes ALL host traffic through
#   the VPN, which kills inbound SSH sessions when working remotely.
#   This script runs WireGuard inside an isolated podman/docker container
#   network namespace so only scraper traffic is tunneled. Host SSH is
#   never affected.
#
# Commands:
#   ./scrape-vpn.sh up         Build (if needed) + start the container
#   ./scrape-vpn.sh down       Stop and remove the container
#   ./scrape-vpn.sh status     Show container status + external IP
#   ./scrape-vpn.sh shell      Open an interactive shell inside it
#   ./scrape-vpn.sh exec CMD   Run CMD inside it (auto-starts if down)
#   ./scrape-vpn.sh logs       Tail container logs
#   ./scrape-vpn.sh rebuild    Force a fresh image build
#
# Examples:
#   ./scrape-vpn.sh up
#   ./scrape-vpn.sh exec node database/scripts/scrapers/ApslMatchEventScraper.js
#   ./scrape-vpn.sh exec bash database/scripts/leagues/north-america/usa/apsl/scrape-standings.sh
#
# Environment overrides:
#   NO_VPN=1                   Skip WireGuard inside the container
#   WG_INTERFACE=other         Use a different /etc/wireguard/<name>.conf
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# ── Locate repo root ──────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
while [ ! -f "$REPO_ROOT/Makefile" ]; do
  REPO_ROOT="$(dirname "$REPO_ROOT")"
  if [ "$REPO_ROOT" = "/" ]; then
    echo "❌ Could not find repo root (no Makefile up the tree)" >&2
    exit 1
  fi
done
export REPO_ROOT

CONTAINER="footballhome_scraper"
IMAGE="footballhome-scraper:latest"
COMPOSE_FILE="$REPO_ROOT/compose/scrape-vpn.compose.yml"
PROJECT="footballhome_scrape"
WG_INTERFACE="${WG_INTERFACE:-scrape-vpn}"

# Per-user staging dir for the WireGuard config so rootless podman can
# read it (the canonical /etc/wireguard is root-only). The conf is
# copied here on `up` via sudo, then bind-mounted read-only into the
# container at /etc/wireguard.
WG_STAGE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/footballhome/wireguard"

# ── Detect engine ─────────────────────────────────────────────────────
ENGINE_BIN="$(command -v podman 2>/dev/null || command -v docker 2>/dev/null || true)"
if [ -z "$ENGINE_BIN" ]; then
  echo "❌ Neither podman nor docker is installed." >&2
  echo "   Install podman: sudo apt install -y podman podman-compose" >&2
  exit 1
fi

# WireGuard inside the container needs to set the per-netns sysctl
# net.ipv4.conf.all.src_valid_mark, which rootless podman blocks. Run
# this specific container rootful (via sudo) so wg-quick can succeed.
# (SSH stays safe — the VPN still only affects the container's netns.)
# Override with SCRAPER_ROOTFUL=0 to force rootless.
SCRAPER_ROOTFUL="${SCRAPER_ROOTFUL:-1}"
ENGINE_PREFIX=()
if [ "$SCRAPER_ROOTFUL" = "1" ] && [ "$EUID" -ne 0 ] && [[ "$ENGINE_BIN" == *podman ]]; then
  ENGINE_PREFIX=(sudo)
fi
# Run the container engine, with sudo if needed.
engine() { "${ENGINE_PREFIX[@]}" "$ENGINE_BIN" "$@"; }
# Back-compat: some helpers reference $ENGINE for display only.
ENGINE="${ENGINE_PREFIX[*]:+${ENGINE_PREFIX[*]} }$ENGINE_BIN"

COMPOSE="$(command -v podman-compose 2>/dev/null || command -v docker-compose 2>/dev/null || true)"

# ── Helpers ───────────────────────────────────────────────────────────
container_exists() { engine container exists "$CONTAINER" 2>/dev/null; }
container_running() {
  [ "$(engine inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null || echo false)" = "true" ]
}

image_exists() { engine image exists "$IMAGE" 2>/dev/null; }

build_image() {
  echo "🔨 Building scraper image..."
  engine build -t "$IMAGE" "$REPO_ROOT/.docker/scraper"
}

require_wg_config() {
  if [ "${NO_VPN:-0}" = "1" ]; then
    return 0
  fi
  if ! sudo test -r "/etc/wireguard/${WG_INTERFACE}.conf"; then
    echo "❌ Missing /etc/wireguard/${WG_INTERFACE}.conf" >&2
    echo "   Import a config first:" >&2
    echo "     sudo ./scripts/setup/setup-wireguard.sh import /path/to/provider.conf" >&2
    echo "   Or skip VPN: NO_VPN=1 $0 up" >&2
    exit 1
  fi
}

# Stage /etc/wireguard/<iface>.conf into a user-owned dir so rootless
# podman can bind-mount it. Re-copies if the source is newer.
stage_wg_config() {
  if [ "${NO_VPN:-0}" = "1" ]; then
    return 0
  fi
  mkdir -p "$WG_STAGE_DIR"
  chmod 700 "$WG_STAGE_DIR"
  local src="/etc/wireguard/${WG_INTERFACE}.conf"
  local dst="$WG_STAGE_DIR/${WG_INTERFACE}.conf"
  if [ ! -f "$dst" ] || sudo test "$src" -nt "$dst"; then
    echo "   📋 Staging $src → $dst (sudo, one-time)"
    sudo cat "$src" > "$dst"
    chmod 600 "$dst"
  fi
}

# ── Commands ──────────────────────────────────────────────────────────
cmd_up() {
  require_wg_config
  stage_wg_config
  if container_running; then
    echo "✓ $CONTAINER already running"
    cmd_status
    return 0
  fi

  if ! image_exists; then
    build_image
  fi

  if container_exists; then
    engine rm -f "$CONTAINER" >/dev/null
  fi

  echo "🚀 Starting $CONTAINER (VPN interface: $WG_INTERFACE)..."

  # Run the container with the same arguments compose would use. We use
  # `run` directly (not compose) because compose's privileges/cap_add
  # handling is inconsistent across podman versions, and we want this
  # script to work in plain podman/docker without compose installed.
  engine run -d \
    --name "$CONTAINER" \
    --hostname scraper \
    --restart unless-stopped \
    --privileged \
    --cap-add NET_ADMIN \
    --cap-add SYS_MODULE \
    --device /dev/net/tun:/dev/net/tun \
    --sysctl net.ipv4.conf.all.src_valid_mark=1 \
    --dns 1.1.1.1 --dns 8.8.8.8 \
    -e "WG_INTERFACE=$WG_INTERFACE" \
    -e "NO_VPN=${NO_VPN:-0}" \
    -e "PUPPETEER_SKIP_DOWNLOAD=1" \
    -e "PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium" \
    -v "$WG_STAGE_DIR:/etc/wireguard:ro" \
    -v "$REPO_ROOT:$REPO_ROOT:rw" \
    -w "$REPO_ROOT" \
    "$IMAGE" \
    sleep infinity >/dev/null

  # Wait for the entrypoint to bring up wg-quick.
  sleep 2
  cmd_status
}

cmd_down() {
  if container_exists; then
    echo "🛑 Stopping $CONTAINER..."
    engine rm -f "$CONTAINER" >/dev/null
    echo "✓ Removed"
  else
    echo "ℹ️  $CONTAINER is not present"
  fi
}

cmd_status() {
  if ! container_exists; then
    echo "○ $CONTAINER: not present"
    return 0
  fi
  if container_running; then
    echo "● $CONTAINER: running"
    HOST_IP=$(curl -s --max-time 4 https://api.ipify.org 2>/dev/null || echo "unknown")
    VPN_IP=$(engine exec "$CONTAINER" curl -s --max-time 4 https://api.ipify.org 2>/dev/null || echo "unknown")
    echo "   host IP:      $HOST_IP"
    echo "   container IP: $VPN_IP   ${VPN_IP:+$( [ "$VPN_IP" != "$HOST_IP" ] && [ "$VPN_IP" != "unknown" ] && echo "(✓ tunneled)" )}"
  else
    echo "○ $CONTAINER: stopped"
  fi
}

cmd_shell() {
  if ! container_running; then cmd_up; fi
  exec "${ENGINE_PREFIX[@]}" "$ENGINE_BIN" exec -it "$CONTAINER" bash
}

cmd_exec() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: $0 exec <command> [args...]" >&2
    exit 2
  fi
  if ! container_running; then cmd_up; fi
  # -i (no -t) so this works in non-tty environments like cron / make.
  exec "${ENGINE_PREFIX[@]}" "$ENGINE_BIN" exec -i \
    -w "$REPO_ROOT" \
    -e VPN_ACTIVE=1 \
    "$CONTAINER" "$@"
}

cmd_logs() {
  exec "${ENGINE_PREFIX[@]}" "$ENGINE_BIN" logs -f "$CONTAINER"
}

cmd_rebuild() {
  cmd_down
  engine rmi -f "$IMAGE" 2>/dev/null || true
  build_image
  cmd_up
}

# ── Dispatch ──────────────────────────────────────────────────────────
case "${1:-}" in
  up)       shift; cmd_up "$@" ;;
  down)     shift; cmd_down "$@" ;;
  status)   shift; cmd_status "$@" ;;
  shell)    shift; cmd_shell "$@" ;;
  exec)     shift; cmd_exec "$@" ;;
  logs)     shift; cmd_logs "$@" ;;
  rebuild)  shift; cmd_rebuild "$@" ;;
  ""|help|-h|--help)
    sed -n '2,40p' "$0"
    ;;
  *)
    echo "Unknown command: $1" >&2
    echo "Run: $0 help" >&2
    exit 2
    ;;
esac
