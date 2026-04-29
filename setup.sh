#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Football Home — first-time setup orchestrator
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Runs the per-concern setup scripts under scripts/setup/ in order.
# Each step is idempotent and runnable on its own.
#
# Override which steps run with --skip / --only:
#   ./setup.sh --only base,podman,node
#   ./setup.sh --skip nginx
#
# Public-server cert bootstrap (one-shot, optional):
#   LE_EMAIL=you@example.com ./setup.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

cd "$(dirname "$0")"
source scripts/setup/_lib.sh

# Load LE_EMAIL (and any other vars) from env file if present, so the
# nginx step can auto-issue a cert without the caller exporting it.
# On a fresh clone env may not exist yet (it's decrypted from env.age by
# the `age` step below) — we re-source after that step runs.
load_env() {
  if [ -f env ]; then
    set -a; source ./env; set +a
  fi
}
load_env

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - First-Time Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Order matters: base -> age -> podman -> node -> chrome -> env -> scraper -> vendor -> vpn -> nginx
# (age must precede vpn so scrape-vpn.conf.age is decrypted before vpn step reads it)
STEPS=(base age podman node chrome env scraper vendor)
[ "$OS_TYPE" = "Linux" ] && STEPS+=(vpn nginx)

# ── Arg parsing ───────────────────────────────────────────────────────
SKIP=""
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --skip) SKIP="$2"; shift 2 ;;
    --only) ONLY="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,16p' "$0"
      exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

step_enabled() {
  local s="$1"
  if [ -n "$ONLY" ]; then
    [[ ",$ONLY," == *",$s,"* ]] || return 1
  fi
  if [ -n "$SKIP" ]; then
    [[ ",$SKIP," == *",$s,"* ]] && return 1
  fi
  return 0
}

# ── Pre-warm sudo on Linux so individual steps don't re-prompt ────────
if [ "$OS_TYPE" = "Linux" ] && [ "$EUID" -ne 0 ]; then
  print_status "Requesting sudo access..."
  sudo -v
fi

# ── Run steps ─────────────────────────────────────────────────────────
for step in "${STEPS[@]}"; do
  if ! step_enabled "$step"; then
    print_warning "Skipping: $step"
    continue
  fi
  echo ""
  echo -e "${BLUE}── $step ──${NC}"

  case "$step" in
    nginx)
      # Cert issuance is opt-in via LE_EMAIL (needs public DNS + ports 80/443)
      if [ -n "${LE_EMAIL:-}" ]; then
        sudo LE_EMAIL="$LE_EMAIL" ./scripts/setup/setup-nginx.sh --obtain-cert
      else
        sudo ./scripts/setup/setup-nginx.sh
      fi
      ;;
    vpn)
      # Pass through provider config hint from env (if set)
      WIREGUARD_CONFIG_FILE="${WIREGUARD_CONFIG_FILE:-}" \
        ./scripts/setup/setup-vpn.sh
      ;;
    *)
      ./scripts/setup/setup-${step}.sh
      ;;
  esac

  # After age decrypts env.age (on first clone), pick up env vars
  # so subsequent steps (nginx LE_EMAIL, env Docker Hub creds) see them.
  [ "$step" = "age" ] && load_env
done

# ── Done ──────────────────────────────────────────────────────────────
HAS_CERT=0
[ -f /etc/letsencrypt/live/footballhome.org/fullchain.pem ] && HAS_CERT=1

STEP=1
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  ${STEP}. Build app containers + load schema/bootstrap data:"
echo -e "     ${YELLOW}make rebuild${NC}"
STEP=$((STEP+1))
echo ""
echo "  ${STEP}. Sync all Lighthouse data (APSL + CASA + GroupMe):"
echo -e "     ${YELLOW}make lighthouse${NC}"
STEP=$((STEP+1))
echo ""
echo "  ${STEP}. Open in your browser:"
if [ "$HAS_CERT" -eq 1 ]; then
  echo -e "     ${YELLOW}https://footballhome.org${NC}    (public)"
fi
echo -e "     ${YELLOW}http://localhost:3000${NC}        (local)"
STEP=$((STEP+1))
echo ""

if [ "$OS_TYPE" = "Linux" ] && [ "$HAS_CERT" -eq 0 ]; then
  echo "  ${STEP}. (Public server only) Issue a TLS cert:"
  if [ -n "${LE_EMAIL:-}" ]; then
    echo -e "     ${YELLOW}sudo LE_EMAIL=$LE_EMAIL ./scripts/setup/setup-nginx.sh --obtain-cert${NC}"
  else
    echo -e "     ${YELLOW}sudo LE_EMAIL=you@example.com ./scripts/setup/setup-nginx.sh --obtain-cert${NC}"
    echo "     (or set LE_EMAIL in ./env and re-run setup.sh)"
  fi
  STEP=$((STEP+1))
  echo ""
fi

echo "  ${STEP}. Log in:"
echo "     Email:    soccer@lighthouse1893.org"
echo "     Password: 1893Soccer!"
echo "     Name:     James Breslin"
echo ""
