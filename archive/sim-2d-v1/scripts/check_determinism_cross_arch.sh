#!/usr/bin/env bash
#
# scripts/check_determinism_cross_arch.sh
#
# Cross-architecture determinism proof for the footballhome sim engine.
# Runs on demand, not in every commit (qemu emulation is slow).
#
# Three claims are proved in sequence:
#
#   [1] Live amd64 == Live arm64 (test_determinism)
#       Byte-for-byte match of canonicalDump() output across ISAs.
#       Any diff means Fixed64 math or tick-loop ordering is NOT
#       bit-exact — a P0 bug for the engine's core promise.
#
#   [2] Replay amd64 == Live amd64 (test_replay, in amd64 container)
#       The `tools::replayMatch` driver reconstructs the same
#       canonical hash the live match produced (both on amd64).
#       Guards against replay-path drift.
#
#   [3] Replay arm64 == Live arm64 (test_replay, in arm64 container
#       under qemu-aarch64).
#       Combined with [1] this transitively proves
#       Replay arm64 == Live amd64, closing the last leg of the
#       three-way equality that DESIGN.md §16.5 exit criterion
#       "cross-arch determinism CI green with DB-sourced replay"
#       requires.
#
# Both arches build inside ephemeral debian:trixie-slim containers to
# match sim/Dockerfile — no libpqxx-dev / OpenSSL-dev / cmake required
# on the host. Only podman + qemu-user-static are needed.
#
# Runtime cost: ~2 min for amd64, ~5–10 min for arm64 under qemu on a
# cold apt cache. Both phases run apt-get inside their containers, so
# the first invocation is slowest.
#
# Design ref: DESIGN.md §9, §16.1 (Determinism CI), §16.5 (Slice 13 exit
# criteria), §16.6 sub-slice 6.1 (this extension).

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

# The repo runs podman rootful (see .github/copilot-instructions.md), so
# `sudo podman` is the default access path. Fall back to plain podman if
# sudo isn't available (rootless setups still work for arm64 emulation,
# but the copilot-instructions convention is rootful).
if [[ ${EUID} -eq 0 ]]; then
    PODMAN=(podman)
elif command -v sudo >/dev/null 2>&1; then
    PODMAN=(sudo podman)
else
    PODMAN=(podman)
fi

# Cheap probe: try to run a trivial arm64 image. If binfmt/qemu isn't
# registered, this exits non-zero and we skip.
if ! "${PODMAN[@]}" run --rm --platform=linux/arm64 docker.io/library/alpine:3 \
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

AMD64_COMBINED="$TMP/amd64.combined.txt"
ARM64_COMBINED="$TMP/arm64.combined.txt"
AMD64_DUMP="$TMP/amd64.determinism.txt"
ARM64_DUMP="$TMP/arm64.determinism.txt"
AMD64_REPLAY_LOG="$TMP/amd64.replay.log"
ARM64_REPLAY_LOG="$TMP/arm64.replay.log"

# ------------------------------------------------------------------------
# In-container build + run recipe. Same script body used for both
# platforms — only the --platform flag differs.
#
# Emits two marker-delimited sections on stdout:
#   ===BEGIN_DETERMINISM===    (canonical dump lines from test_determinism)
#   ===END_DETERMINISM===
#   ===BEGIN_REPLAY===         (test_replay's harness output)
#   ===END_REPLAY===
# ------------------------------------------------------------------------
CONTAINER_SCRIPT='
    set -euo pipefail
    apt-get update -qq >/dev/null
    apt-get install -y -qq --no-install-recommends \
        g++ cmake ninja-build make pkg-config \
        libssl-dev libpqxx-dev ca-certificates >/dev/null
    cp -R /work/sim /tmp/sim
    cd /tmp/sim
    cmake -S . -B build-x -G Ninja -DCMAKE_BUILD_TYPE=Release >/dev/null
    cmake --build build-x --target test_determinism test_replay >/dev/null

    echo "===BEGIN_DETERMINISM==="
    ./build-x/tests/test_determinism
    echo "===END_DETERMINISM==="

    echo "===BEGIN_REPLAY==="
    ./build-x/tests/test_replay
    echo "===END_REPLAY==="
'

run_platform () {
    local platform="$1"
    local out="$2"
    "${PODMAN[@]}" run --rm --platform="$platform" \
        -v "$ROOT/sim":/work/sim:ro,z \
        -e DEBIAN_FRONTEND=noninteractive \
        docker.io/library/debian:trixie-slim \
        bash -c "$CONTAINER_SCRIPT" \
        > "$out"
}

extract_sections () {
    local combined="$1"
    local dump_out="$2"
    local replay_out="$3"
    awk '
        /^===BEGIN_DETERMINISM===$/ { mode="det"; next }
        /^===END_DETERMINISM===$/   { mode="";    next }
        /^===BEGIN_REPLAY===$/      { mode="rep"; next }
        /^===END_REPLAY===$/        { mode="";    next }
        mode=="det" && /^=== /      { p=1 }
        mode=="det" && p            { print > det }
        mode=="rep"                 { print > rep }
    ' det="$dump_out" rep="$replay_out" "$combined"
}

# ------------------------------------------------------------------------
# Phase 1: build + run under amd64 container.
# ------------------------------------------------------------------------
echo "[1/3] Building test_determinism + test_replay under linux/amd64..."
run_platform linux/amd64 "$AMD64_COMBINED"
extract_sections "$AMD64_COMBINED" "$AMD64_DUMP" "$AMD64_REPLAY_LOG"

# ------------------------------------------------------------------------
# Phase 2: build + run under arm64 container (slow — qemu-aarch64).
# ------------------------------------------------------------------------
echo "[2/3] Building test_determinism + test_replay under linux/arm64 (slow)..."
run_platform linux/arm64 "$ARM64_COMBINED"
extract_sections "$ARM64_COMBINED" "$ARM64_DUMP" "$ARM64_REPLAY_LOG"

# ------------------------------------------------------------------------
# Phase 3: verdict.
# ------------------------------------------------------------------------
echo "[3/3] Verdict..."

failures=0

if diff -u "$AMD64_DUMP" "$ARM64_DUMP" >"$TMP/determinism.diff"; then
    echo "  [1] Live amd64 == Live arm64             OK (test_determinism byte-identical)"
else
    echo "  [1] Live amd64 == Live arm64             FAIL — diff:"
    sed 's/^/       /' "$TMP/determinism.diff" >&2
    failures=$((failures + 1))
fi

# [2] and [3] were verified by test_replay having exited 0 inside each
# container. If either had failed, the outer `podman run` would have
# exited non-zero, which `set -e` would have caught before we got here.
# Still, grep the logs for the harness's failure markers as extra defense.
if grep -qE '\bFAIL\b|\bERROR\b' "$AMD64_REPLAY_LOG"; then
    echo "  [2] Replay amd64 == Live amd64           FAIL — test_replay reported failure:"
    sed 's/^/       /' "$AMD64_REPLAY_LOG" >&2
    failures=$((failures + 1))
else
    echo "  [2] Replay amd64 == Live amd64           OK (amd64 test_replay passed)"
fi

if grep -qE '\bFAIL\b|\bERROR\b' "$ARM64_REPLAY_LOG"; then
    echo "  [3] Replay arm64 == Live arm64           FAIL — test_replay reported failure:"
    sed 's/^/       /' "$ARM64_REPLAY_LOG" >&2
    failures=$((failures + 1))
else
    echo "  [3] Replay arm64 == Live arm64           OK (arm64 test_replay passed under qemu)"
fi

if [[ $failures -gt 0 ]]; then
    echo "" >&2
    echo "ERROR: $failures cross-arch check(s) failed." >&2
    echo "       Artifacts kept in $TMP for inspection." >&2
    trap - EXIT
    exit 1
fi

echo ""
echo "check_determinism_cross_arch.sh: OK"
echo "  Three-way equality proved:"
echo "    Live amd64 == Live arm64 == Replay amd64 == Replay arm64"
exit 0
