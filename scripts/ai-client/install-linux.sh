#!/bin/bash
# scripts/ai-client/install-linux.sh
#
# Installs ollama on Linux (any distro with systemd) and pulls a coding
# model.  Run this on the LINUX LAPTOP/DESKTOP you SSH into fishtown
# from, not on the server itself.
#
# See scripts/ai-client/README.md for the full topology + SSH tunnel
# instructions.
#
# Usage:
#   ./install-linux.sh                       # default model (auto-picked)
#   ./install-linux.sh --model qwen2.5-coder:14b
#   ./install-linux.sh --no-pull             # install ollama only, no model
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
info()    { echo -e "${BLUE}→${NC} $1"; }
ok()      { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
err()     { echo -e "${RED}✗${NC} $1" >&2; }

# ── Guard: Linux only ─────────────────────────────────────────────────
if [ "$(uname -s)" != "Linux" ]; then
  err "This script is for Linux.  On macOS use install-mac.sh."
  exit 1
fi

# ── Arg parsing ───────────────────────────────────────────────────────
MODEL=""
NO_PULL=0
while [ $# -gt 0 ]; do
  case "$1" in
    --model)     MODEL="$2"; shift 2 ;;
    --model=*)   MODEL="${1#*=}"; shift ;;
    --no-pull)   NO_PULL=1; shift ;;
    -h|--help)   sed -n '2,17p' "$0"; exit 0 ;;
    *) err "Unknown arg: $1"; exit 2 ;;
  esac
done

# ── GPU check (informational, not blocking) ───────────────────────────
GPU_KIND="cpu-only"
if command -v nvidia-smi &> /dev/null && nvidia-smi -L 2>&1 | grep -qi 'gpu'; then
  GPU_KIND="nvidia ($(nvidia-smi -L | head -1 | sed 's/(UUID.*//'))"
elif command -v rocm-smi &> /dev/null; then
  GPU_KIND="amd-rocm"
fi
info "GPU: $GPU_KIND"
if [ "$GPU_KIND" = "cpu-only" ]; then
  warn "No GPU detected — inference will be SLOW on this client."
  warn "You may want to run aider directly against fishtown's local ollama instead"
  warn "(this client offers no speed advantage over fishtown without a GPU)."
fi

# ── ollama install ────────────────────────────────────────────────────
if ! command -v ollama &> /dev/null; then
  info "Installing ollama (official installer — will prompt for sudo)..."
  curl -fsSL https://ollama.com/install.sh | sh
  ok "ollama installed: $(ollama --version 2>&1 | head -1)"
else
  info "ollama already installed: $(ollama --version 2>&1 | head -1)"
  info "To upgrade later: curl -fsSL https://ollama.com/install.sh | sh"
fi

# ── systemd service (installer creates it) ────────────────────────────
if systemctl list-unit-files | grep -q '^ollama\.service'; then
  if ! systemctl is-active --quiet ollama; then
    info "Starting ollama.service..."
    sudo systemctl enable --now ollama
  fi
  # Give it a moment
  for i in 1 2 3 4 5; do
    if curl -fsS --max-time 1 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
  if curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    ok "ollama serving on 127.0.0.1:11434 (systemd)"
  else
    err "ollama.service started but 127.0.0.1:11434 is not responding."
    err "Check: sudo systemctl status ollama"
    exit 1
  fi
else
  warn "No systemd unit found — you'll need to run 'ollama serve' manually in another terminal."
fi

# ── Auto-pick model from RAM if not specified ─────────────────────────
if [ -z "$MODEL" ]; then
  # /proc/meminfo MemTotal is in KiB
  RAM_KB="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)"
  RAM_GB=$(( RAM_KB / 1024 / 1024 ))
  if   [ "$RAM_GB" -ge 48 ]; then MODEL="qwen2.5-coder:32b"
  elif [ "$RAM_GB" -ge 24 ]; then MODEL="qwen2.5-coder:14b"
  elif [ "$RAM_GB" -ge 12 ]; then MODEL="qwen2.5-coder:7b"
  else                            MODEL="qwen2.5-coder:3b"
  fi
  info "Auto-picked model for ${RAM_GB} GB machine: ${MODEL}"
fi

# ── Pull model ────────────────────────────────────────────────────────
if [ "$NO_PULL" -eq 0 ]; then
  if ollama list 2>/dev/null | awk 'NR>1 {print $1}' | grep -Fxq "$MODEL"; then
    ok "Model already present: $MODEL"
  else
    info "Pulling $MODEL (this can take several minutes)..."
    ollama pull "$MODEL"
    ok "Model ready: $MODEL"
  fi
else
  warn "Skipping model pull (--no-pull)"
fi

# ── Guidance ──────────────────────────────────────────────────────────
echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Linux client ready${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "Next steps:"
echo
echo "  1. Add this to your ~/.ssh/config (edit HostName + User):"
echo
echo -e "     ${YELLOW}Host fishtown${NC}"
echo -e "     ${YELLOW}    HostName fishtown.example.com${NC}"
echo -e "     ${YELLOW}    User your-user${NC}"
echo -e "     ${YELLOW}    RemoteForward 11434 127.0.0.1:11434${NC}"
echo -e "     ${YELLOW}    ServerAliveInterval 60${NC}"
echo
echo "  2. SSH into fishtown (tunnel opens automatically):"
echo -e "     ${YELLOW}ssh fishtown${NC}"
echo
echo "  3. On fishtown, cd into the repo and run aider:"
echo -e "     ${YELLOW}cd /srv/footballhome && aider${NC}"
echo
echo "If aider picks a different model, edit .aider.conf.yml (or use --model)."
echo
