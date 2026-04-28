#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VPN Wrapper — runs a command behind WireGuard (CONTAINER ONLY)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Used by APSL and CSL scrape scripts. These sites (LeagueApps platform)
# block our IP, so requests must go through WireGuard.
#
# WireGuard ALWAYS runs inside a dedicated podman/docker container in its
# own network namespace. Host routing is never modified, so SSH sessions
# survive. There is intentionally no host-VPN backend.
#
# Usage:
#   ./vpn-wrap.sh <command> [args...]
#
# Skip VPN entirely (testing, or for sites that aren't IP-blocked):
#   NO_VPN=1 ./vpn-wrap.sh ./scrape-standings.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# ── Refuse legacy host backend ────────────────────────────────────────
if [ "${VPN_BACKEND:-}" = "host" ]; then
  echo "❌ VPN_BACKEND=host is no longer supported." >&2
  echo "   The host VPN backend was removed because it routes ALL host" >&2
  echo "   traffic through WireGuard and drops SSH sessions." >&2
  echo "   Use the container backend instead:" >&2
  echo "     make scrape-vpn-up && make sync-lighthouse" >&2
  exit 1
fi

# ── Skip VPN if requested ─────────────────────────────────────────────
if [ "${NO_VPN:-0}" = "1" ]; then
  echo "   ⚠️  NO_VPN=1 — skipping VPN, running directly"
  exec "$@"
fi

# ── Already inside the scraper container? Just run the command. ───────
# The container's entrypoint already brought up WireGuard.
if [ -f /.dockerenv ] || [ "${container:-}" = "podman" ] || [ "${VPN_ACTIVE:-0}" = "1" ]; then
  exec "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Container backend is mandatory ────────────────────────────────────
if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
  echo "❌ Neither podman nor docker is installed." >&2
  echo "   The scraper VPN runs in a container to keep your SSH session alive." >&2
  echo "   Install podman:  sudo apt install -y podman" >&2
  echo "   (Or set NO_VPN=1 to bypass the VPN entirely.)" >&2
  exit 1
fi

echo "   🔒 Routing through scraper container (host SSH unaffected)..."
exec "$SCRIPT_DIR/scrape-vpn.sh" exec "$@"
