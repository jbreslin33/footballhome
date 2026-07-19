#!/usr/bin/env bash
# Create /srv/footballhome-dev-<slug> as a git worktree (or clone) and seed env.
# Run from the production checkout (/srv/footballhome) ideally.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib-dev-slot.sh
source "$ROOT/scripts/dev/lib-dev-slot.sh"

load_dev_slot "${DEV:-${1:-}}"

PROD_ROOT="${PROD_ROOT:-/srv/footballhome}"
mkdir -p "$(dirname "$FH_DEV_DIR")"

if [ -d "$FH_DEV_DIR/.git" ] || [ -f "$FH_DEV_DIR/.git" ]; then
  echo "[dev-init] $FH_DEV_DIR already exists — pulling main"
  git -C "$FH_DEV_DIR" fetch origin main
  git -C "$FH_DEV_DIR" checkout main
  git -C "$FH_DEV_DIR" pull --ff-only origin main || true
else
  if [ -d "$PROD_ROOT/.git" ] && [ "$ROOT" = "$PROD_ROOT" ] || [ -d "$ROOT/.git" ]; then
    SRC="$ROOT"
    if [ -d "$PROD_ROOT/.git" ]; then SRC="$PROD_ROOT"; fi
    echo "[dev-init] adding git worktree $FH_DEV_DIR from $SRC"
    git -C "$SRC" fetch origin main 2>/dev/null || true
    git -C "$SRC" worktree add -B "dev/${FH_DEV_SLUG}" "$FH_DEV_DIR" origin/main \
      || git -C "$SRC" worktree add "$FH_DEV_DIR" main
  else
    echo "[dev-init] cloning into $FH_DEV_DIR"
    git clone https://github.com/jbreslin33/footballhome.git "$FH_DEV_DIR"
  fi
fi

# Secrets: prefer symlink to prod env (same LeagueApps keys); never commit.
if [ ! -f "$FH_DEV_DIR/env" ]; then
  if [ -f "$PROD_ROOT/env" ]; then
    ln -sfn "$PROD_ROOT/env" "$FH_DEV_DIR/env"
    echo "[dev-init] symlinked env → $PROD_ROOT/env"
  elif [ -f "$ROOT/env" ]; then
    ln -sfn "$ROOT/env" "$FH_DEV_DIR/env"
    echo "[dev-init] symlinked env → $ROOT/env"
  else
    echo "[dev-init] WARNING: no env found — run ./setup.sh or copy env into $FH_DEV_DIR"
  fi
fi

# LeagueApps key material / config often lives in prod config/
if [ -d "$PROD_ROOT/config" ] && [ ! -e "$FH_DEV_DIR/config/.from-prod" ]; then
  # Keep checkout's tracked config; only note if p12 missing
  if [ ! -f "$FH_DEV_DIR/config/leagueapps.p12" ] && [ -f "$PROD_ROOT/config/leagueapps.p12" ]; then
    ln -sfn "$PROD_ROOT/config/leagueapps.p12" "$FH_DEV_DIR/config/leagueapps.p12" || true
  fi
fi

echo "$FH_DEV_SLUG" > "$FH_DEV_DIR/.dev-slot"
cat > "$FH_DEV_DIR/.dev-ports" <<EOF
FH_DEV_SLUG=$FH_DEV_SLUG
FH_DEV_FRONTEND_PORT=$FH_DEV_FRONTEND_PORT
FH_DEV_BACKEND_PORT=$FH_DEV_BACKEND_PORT
FH_DEV_DB_PORT=$FH_DEV_DB_PORT
FH_DEV_HOST_PREFIX=$FH_DEV_HOST_PREFIX
FH_DEV_FRONTEND_URL=$FH_DEV_FRONTEND_URL
EOF

echo "[dev-init] ready: $FH_DEV_DIR"
echo "  Next:"
echo "    cd $FH_DEV_DIR"
echo "    sudo make dev-up DEV=$FH_DEV_SLUG"
echo "    sudo make dev-restore-mirror DEV=$FH_DEV_SLUG"
echo "  Browse: http://127.0.0.1:$FH_DEV_FRONTEND_PORT"
echo "       or $FH_DEV_FRONTEND_URL  (after nginx/DNS)"
