#!/usr/bin/env bash
# Cursor Cloud — idempotent update script (environment.json "install").
#
# Keep this light: decrypt secrets, refresh npm deps. Heavy image builds and
# compose up belong in start/terminals so boots stay fast after snapshotting.
set -euo pipefail

cd "$(dirname "$0")/../.."
ROOT="$PWD"

echo "[cloud-install] repo root: $ROOT"

# Decrypt committed *.age bundles when AGE_PASSPHRASE is present (Cursor
# Runtime Secret). Without it, agents can still edit code but cannot boot
# the stack against LeagueApps / real auth.
if [ -n "${AGE_PASSPHRASE:-}" ]; then
  echo "[cloud-install] decrypting secrets via scripts/setup/setup-age.sh"
  AGE_PASSPHRASE="$AGE_PASSPHRASE" ./scripts/setup/setup-age.sh
else
  echo "[cloud-install] WARNING: AGE_PASSPHRASE unset — skipping decrypt."
  echo "  Add it as a Cursor Environment Runtime Secret, then re-run."
fi

if [ -f package-lock.json ]; then
  echo "[cloud-install] npm ci"
  npm ci --no-audit --no-fund || npm install --no-audit --no-fund
elif [ -f package.json ]; then
  echo "[cloud-install] npm install"
  npm install --no-audit --no-fund
fi

echo "[cloud-install] done"
