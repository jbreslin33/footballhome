#!/bin/bash
# Launch aider with OpenRouter credentials loaded from the repo-local env file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/env"
CONFIG_FILE="$REPO_ROOT/.aider.openrouter.yml"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "OPENROUTER_API_KEY is not set in $ENV_FILE" >&2
  exit 1
fi

if [ -f "$CONFIG_FILE" ]; then
  exec aider --config "$CONFIG_FILE" "$@"
fi

exec aider \
  --model "${AIDER_OPENROUTER_MODEL:-openrouter/anthropic/claude-sonnet-4}" \
  --no-auto-commits \
  --no-dirty-commits \
  "$@"