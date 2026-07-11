# sim/Dockerfile
#
# Two-stage build for the footballhome_sim daemon.
# Base: Debian trixie-slim with GCC 13. Podman/Docker-compatible.
#
# Stage 1 (build): compile sim in Release + run the full test suite.
# Stage 2 (runtime): minimal image with just the binary and libssl.

# ---- Build stage ------------------------------------------------------------
FROM debian:trixie-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        cmake \
        ninja-build \
        make \
        pkg-config \
        libssl-dev \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Sources only — build/ deliberately excluded via .dockerignore.
COPY CMakeLists.txt ./
COPY src ./src
COPY tests ./tests
COPY scripts ./scripts

# Configure + build (Release, no sanitizers).
RUN cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel

# Run the full test suite as part of the image build — image build FAILS
# if any test fails. Bind-to-loopback integration tests work fine inside
# the container.
RUN cd build && ctest --output-on-failure

# ---- Runtime stage ----------------------------------------------------------
FROM debian:trixie-slim AS runtime

# libssl3 provides libcrypto.so.3 which sim_auth links against for
# HMAC-SHA256 / SHA1 / constant-time compare.
# iproute2 provides `ss`, used by the compose healthcheck.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 \
        libssl3 \
        iproute2 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/footballhome_sim /usr/local/bin/footballhome_sim

# The sim listens on SIM_PORT (default 9100) inside the container.
EXPOSE 9100

# Run as non-root — nothing here needs privileged access.
RUN useradd --system --uid 10001 --home-dir /nonexistent \
            --shell /usr/sbin/nologin sim
USER sim

# Config comes from the environment (JWT_SECRET is mandatory).
ENV SIM_BIND_ADDRESS=0.0.0.0 \
    SIM_PORT=9100 \
    SIM_MATCH_ID=1 \
    SIM_MATCH_SEED=42

ENTRYPOINT ["/usr/local/bin/footballhome_sim"]
