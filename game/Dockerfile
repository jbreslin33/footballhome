# game/Dockerfile
#
# Two-stage build for the fh-game match daemon ([v1] Dockerfile pattern:
# the image build IS the test gate — any failing lint or ctest fails the
# build, so a bad image can never exist).
#
# Stage 1 (build): lint gates + compile Release + full ctest suite.
# Stage 2 (runtime): minimal image with the binary and libssl.

# ---- Build stage ------------------------------------------------------------
FROM debian:trixie-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        cmake \
        make \
        pkg-config \
        libssl-dev \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Sources only — build/ excluded via .dockerignore.
COPY CMakeLists.txt ./
COPY src ./src
COPY tests ./tests
COPY scripts ./scripts

# Determinism lint gates BEFORE compiling (DESIGN.md §3): loud early
# failure beats a subtle desync later.
RUN bash scripts/check_no_floats.sh && bash scripts/check_no_bad_rng.sh

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel

# Full test suite as part of the image build — the build FAILS if any
# test fails (includes the determinism golden and the loopback-socket
# transport tests, which run fine in-container).
RUN ctest --test-dir build --output-on-failure

# ---- Runtime stage ----------------------------------------------------------
FROM debian:trixie-slim AS runtime

# libssl3 → libcrypto.so.3 for HMAC-SHA256 / SHA1. iproute2 provides `ss`
# for the compose healthcheck.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 \
        libssl3 \
        iproute2 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/fh-game /usr/local/bin/fh-game

# The daemon listens on GAME_PORT (default 9200), internal network only —
# nginx terminates TLS and proxies /game here (PROTOCOL.md §1).
EXPOSE 9200

# Non-root — nothing here needs privileged access.
RUN useradd --system --uid 10002 --home-dir /nonexistent \
            --shell /usr/sbin/nologin game
USER game

# JWT_SECRET is mandatory and flows in from the compose env_file.
ENV GAME_BIND_ADDRESS=0.0.0.0 \
    GAME_PORT=9200 \
    GAME_MATCH_ID=1 \
    GAME_SLOT_COUNT=22 \
    GAME_SPEED=1

ENTRYPOINT ["/usr/local/bin/fh-game"]
