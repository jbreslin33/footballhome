#!/usr/bin/env bash
#
# scripts/check_determinism_cross_arch.sh
#
# Builds sim inside a linux/arm64 container (via podman + qemu-user binfmt)
# and runs test_determinism there. Compares stdout byte-for-byte against a
# native amd64 run. Any drift means Fixed64 math or tick-loop ordering is
# NOT bit-exact across ISAs — a P0 bug for the engine's core promise.
#
# Runs on demand, not in every commit; slow (qemu emulation).
#
# Design ref: DESIGN.md §9, §16.1 (Determinism CI).

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

# ------------------------------------------------------------------------
# Preconditions
# ------------------------------------------------------------------------
if ! command -v podman >/dev/null 2>&1; then
    echo "SKIP: podman not installed" >&2
    exit 0
fi

# Cheap probe: try to run a trivial arm64 image. If binfmt/qemu isn't
# registered, this exits non-zero and we skip.
if ! podman run --rm --platform=linux/arm64 docker.io/library/alpine:3 \
        /bin/sh -c 'uname -m' >/dev/null 2>&1; then
    cat >&2 <<'EOF'
SKIP: linux/arm64 emulation not available.

To enable on this host (Ubuntu/Debian):
    sudo apt install qemu-user-static binfmt-support
    sudo update-binfmts --enable qemu-aarch64
EOF
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

NATIVE_OUT="$TMP/native.txt"
ARM64_OUT="$TMP/arm64.txt"

# ------------------------------------------------------------------------
# Native (amd64) run
# ------------------------------------------------------------------------
echo "[1/2] Running native test_determinism..."
if [[ ! -x "sim/build/tests/test_determinism" ]]; then
    echo "ERROR: sim/build/tests/test_determinism missing. Build first:" >&2
    echo "       cmake --build sim/build" >&2
    exit 1
fi
# Filter stdout to the canonical dump sections only (ignore harness banners
# which are not fully deterministic in their exact form).
"sim/build/tests/test_determinism" \
    | awk '/^=== / {p=1} p {print}' \
    > "$NATIVE_OUT"

# ------------------------------------------------------------------------
# arm64 run inside container. Build sim fresh in an ephemeral image so the
# arm64 binary is compiled by an arm64 GCC — the whole point of this test.
# ------------------------------------------------------------------------
echo "[2/2] Building + running test_determinism under linux/arm64 (this takes a while)..."
podman run --rm --platform=linux/arm64 \
    -v "$ROOT/sim":/work/sim:ro,z \
    docker.io/library/ubuntu:24.04 \
    bash -c '
        set -euo pipefail
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >/dev/null
        apt-get install -y -qq build-essential cmake >/dev/null
        cp -R /work/sim /tmp/sim
        cd /tmp/sim
        cmake -S . -B build-arm -DCMAKE_BUILD_TYPE=Release >/dev/null
        cmake --build build-arm --target test_determinism -j2 >/dev/null
        ./build-arm/tests/test_determinism
    ' \
    | awk '/^=== / {p=1} p {print}' \
    > "$ARM64_OUT"

# ------------------------------------------------------------------------
# Compare
# ------------------------------------------------------------------------
if diff -u "$NATIVE_OUT" "$ARM64_OUT"; then
    echo "check_determinism_cross_arch.sh: OK — amd64 and arm64 produce byte-identical output"
    exit 0
fi

echo "ERROR: cross-arch determinism drift detected." >&2
echo "       See diff above. Native and arm64 outputs are in $TMP." >&2
exit 1
