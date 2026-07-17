#!/bin/bash
# scripts/setup/setup-aider.sh — aider (terminal AI coding agent)
#
# Installs the aider CLI on this host.  The LLM itself is NOT installed
# here — aider is configured to talk to an ollama server on
# 127.0.0.1:11434, which you expose over an SSH reverse tunnel from
# whatever client machine (Mac / laptop) is doing the heavy lifting:
#
#   ssh -R 11434:localhost:11434 user@this-host
#
# See .aider.conf.yml at the repo root for the default model + settings.
set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

# ── pipx (isolated Python app manager) ────────────────────────────────
if ! command -v pipx &> /dev/null; then
  if [ "$OS_TYPE" = "Linux" ]; then
    print_status "Installing pipx..."
    sudo apt-get update -qq
    sudo apt-get install -y pipx
  elif [ "$OS_TYPE" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
      print_error "Homebrew required on macOS: https://brew.sh"
      exit 1
    fi
    brew install pipx
  fi
  # Add pipx's bin dir to PATH for future shells (idempotent)
  pipx ensurepath >/dev/null 2>&1 || true
  # Make it available for THIS shell right now
  export PATH="$HOME/.local/bin:$PATH"
  print_success "pipx installed: $(pipx --version)"
else
  print_success "pipx already installed: $(pipx --version)"
fi

# ── aider ─────────────────────────────────────────────────────────────
# Detect three states: (a) fully installed & on PATH, (b) pipx venv
# exists but binary is missing (previous run was cancelled mid-install),
# (c) not installed at all.
AIDER_VENV="$HOME/.local/share/pipx/venvs/aider-chat"
AIDER_BIN="$HOME/.local/bin/aider"

if command -v aider &> /dev/null; then
  print_status "Upgrading aider-chat..."
  pipx upgrade aider-chat >/dev/null 2>&1 || true
  print_success "aider ready: $(aider --version 2>&1 | head -1)"
elif [ -d "$AIDER_VENV" ] && [ ! -x "$AIDER_BIN" ]; then
  # Pipx thinks aider is installed but the binary is missing — a
  # previous install was cancelled mid-run.  Force-reinstall.
  print_warning "Detected incomplete aider install (venv exists, binary missing) — force-reinstalling..."
  pipx install aider-chat --force
  export PATH="$HOME/.local/bin:$PATH"
  print_success "aider installed: $(aider --version 2>&1 | head -1)"
else
  print_status "Installing aider-chat (may take a minute)..."
  pipx install aider-chat
  export PATH="$HOME/.local/bin:$PATH"
  print_success "aider installed: $(aider --version 2>&1 | head -1)"
fi

# ── Repo-root .aider.conf.yml (only if missing — don't clobber edits) ─
CONF="$REPO_ROOT/.aider.conf.yml"
if [ ! -f "$CONF" ]; then
  print_status "Writing default .aider.conf.yml..."
  cat > "$CONF" <<'YAML'
# aider config — talks to an ollama server on the client machine over
# SSH reverse tunnel.  See scripts/setup/setup-aider.sh for the tunnel
# command.
#
# To change the model:
#   1. On your client (Mac/laptop):  ollama pull qwen2.5-coder:14b
#   2. Edit `model:` below to match.
#
# Model sizing on a typical Mac:
#   qwen2.5-coder:7b   ~4.7 GB  — safe on any 16 GB Mac
#   qwen2.5-coder:14b  ~9 GB    — great on 16 GB+ Mac
#   qwen2.5-coder:32b  ~19 GB   — needs 32 GB+ Mac (best quality)

model: ollama_chat/qwen2.5-coder:7b

# Don't let aider make its own git commits — we curate messages by hand.
auto-commits: false
dirty-commits: false

# UI
dark-mode: true
pretty: true
stream: true

# Don't send analytics
analytics: false

# ollama endpoint (default; the SSH reverse tunnel makes this the client's ollama)
# Override at runtime with:  OLLAMA_API_BASE=http://host:11434 aider
YAML
  print_success "Created .aider.conf.yml (edit to change model)"
else
  print_success ".aider.conf.yml already exists — leaving it alone"
fi

# ── Sanity: warn if OLLAMA_API_BASE reachable now (informational) ─────
if command -v curl &> /dev/null; then
  if curl -fsS --max-time 1 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    print_success "ollama tunnel detected on 127.0.0.1:11434 — aider is ready to use"
  else
    print_warning "No ollama on 127.0.0.1:11434 yet — open the tunnel from your client:"
    echo "         ssh -R 11434:localhost:11434 $(whoami)@$(hostname -f 2>/dev/null || hostname)"
  fi
fi
