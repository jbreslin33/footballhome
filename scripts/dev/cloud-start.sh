#!/usr/bin/env bash
# Cursor Cloud — start Docker daemon before terminals launch.
set -euo pipefail

echo "[cloud-start] starting docker daemon"
if command -v service >/dev/null 2>&1; then
  sudo service docker start || true
elif command -v systemctl >/dev/null 2>&1; then
  sudo systemctl start docker || true
else
  sudo dockerd >/tmp/dockerd.log 2>&1 &
fi

# Wait until the daemon answers.
for i in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    echo "[cloud-start] docker is ready"
    exit 0
  fi
  sleep 1
done

echo "[cloud-start] ERROR: docker daemon did not become ready" >&2
exit 1
