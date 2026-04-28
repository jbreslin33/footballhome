#!/bin/bash
# scripts/setup/setup-podman.sh — podman + podman-compose
set -e
source "$(dirname "$0")/_lib.sh"

# ── Podman ────────────────────────────────────────────────────────────
if ! command -v podman &> /dev/null; then
  if [ "$OS_TYPE" = "Linux" ]; then
    print_status "Installing Podman..."
    sudo apt-get update -qq
    sudo apt-get install -y podman
    systemctl --user enable --now podman.socket || true
  elif [ "$OS_TYPE" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
      print_error "Homebrew required to install Podman: https://brew.sh"
      exit 1
    fi
    brew install podman
    podman machine init --cpus=4 --memory=8192 --disk-size=50 2>/dev/null || true
    podman machine start
  fi
  print_success "Podman installed"
else
  print_success "Podman already installed: $(podman --version)"
  if [ "$OS_TYPE" = "Darwin" ] && ! podman machine list | grep -q "Currently running"; then
    print_status "Starting podman machine..."
    podman machine start
  fi
fi

# ── podman-compose ────────────────────────────────────────────────────
PYTHON_USER_BIN="$(python3 -m site --user-base 2>/dev/null)/bin"
export PATH="$PYTHON_USER_BIN:$PATH"

if command -v podman-compose &> /dev/null; then
  print_success "podman-compose already installed"
else
  INSTALLED=false

  # 1. apt / brew
  if [ "$OS_TYPE" = "Linux" ] && sudo apt-cache show podman-compose &>/dev/null; then
    print_status "Installing podman-compose via apt..."
    sudo apt-get install -y podman-compose && INSTALLED=true
  elif [ "$OS_TYPE" = "Darwin" ]; then
    print_status "Installing podman-compose via brew..."
    brew install podman-compose && INSTALLED=true
  fi

  # 2. pipx
  if [ "$INSTALLED" = false ]; then
    if ! command -v pipx &> /dev/null; then
      [ "$OS_TYPE" = "Linux" ]  && sudo apt-get install -y pipx || true
      [ "$OS_TYPE" = "Darwin" ] && brew install pipx || true
    fi
    if command -v pipx &> /dev/null; then
      print_status "Installing podman-compose via pipx..."
      pipx install podman-compose && INSTALLED=true
      export PATH="$HOME/.local/bin:$PATH"
    fi
  fi

  # 3. pip fallback
  if [ "$INSTALLED" = false ]; then
    if ! command -v pip3 &> /dev/null; then
      [ "$OS_TYPE" = "Linux" ] && sudo apt-get install -y python3-pip
    fi
    print_status "Installing podman-compose via pip..."
    if pip3 install --user podman-compose --break-system-packages 2>/dev/null \
       || pip3 install --user podman-compose 2>/dev/null \
       || pip install --user podman-compose; then
      INSTALLED=true
      export PATH="$PYTHON_USER_BIN:$PATH"
    fi
  fi

  if [ "$INSTALLED" = false ]; then
    print_error "Failed to install podman-compose"
    exit 1
  fi

  # Persist Python user bin in shells
  for rcfile in ~/.zshrc ~/.bashrc ~/.bash_profile; do
    [ -f "$rcfile" ] || continue
    grep -q "# Python user packages" "$rcfile" 2>/dev/null && continue
    {
      echo ""
      echo "# Python user packages"
      echo "export PATH=\"$PYTHON_USER_BIN:\$PATH\""
    } >> "$rcfile"
  done

  print_success "podman-compose installed"
fi

# ── Verify Podman is reachable ────────────────────────────────────────
if ! podman ps &> /dev/null; then
  if [ "$OS_TYPE" = "Darwin" ]; then
    print_error "Podman machine not running — try: podman machine start"
  else
    print_error "Podman not responding — try: systemctl --user restart podman.socket"
  fi
  exit 1
fi
print_success "Podman is running and accessible"
