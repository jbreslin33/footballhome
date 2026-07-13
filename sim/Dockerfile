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
        libpqxx-dev \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Sources only — build/ deliberately excluded via .dockerignore.
COPY CMakeLists.txt ./
COPY src ./src
COPY tests ./tests
COPY scripts ./scripts

# Lint gate: enforce determinism-critical hygiene BEFORE we compile — if a
# banned pattern crept in, we want the failure loud and early rather than
# a subtle runtime desync months later. See DESIGN.md §10, §22.10.
RUN bash scripts/check_no_floats.sh \
    && bash scripts/check_no_bad_rng.sh \
    && bash scripts/check_no_hardcoded_attrs.sh \
    && bash scripts/check_profile_write_policy.sh

# ---- Build-time version (§16.6 task 7) --------------------------------------
# The build context is ./sim so .git is NOT visible here. The host-side
# build.sh runs `git describe --tags --dirty --always` and forwards the
# result via docker-compose build args → this ARG → cmake -D. Falls
# back to "unknown" for ad-hoc `podman build sim/` invocations that
# don't set the arg. The value is stamped into MatchRow.server_version
# and the HELLO_ACK frame.
ARG FH_SIM_GIT_DESCRIBE=unknown

# Configure + build (Release, no sanitizers).
RUN cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DFH_SIM_GIT_DESCRIBE="${FH_SIM_GIT_DESCRIBE}" \
    && cmake --build build --parallel

# Run the full test suite as part of the image build — image build FAILS
# if any test fails. Bind-to-loopback integration tests work fine inside
# the container.
RUN cd build && ctest --output-on-failure

# ---- Runtime stage ----------------------------------------------------------
FROM debian:trixie-slim AS runtime

# libssl3 provides libcrypto.so.3 which sim_auth links against for
# HMAC-SHA256 / SHA1 / constant-time compare.
# libpqxx-7.10 is the C++ Postgres client used by sim_persistence
# (see DESIGN.md §22.12). Version tracks trixie's `libpqxx-dev`.
# iproute2 provides `ss`, used by the compose healthcheck.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 \
        libssl3 \
        libpqxx-7.10 \
        iproute2 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/footballhome_sim /usr/local/bin/footballhome_sim
COPY --from=build /src/build/fh-sim-replay    /usr/local/bin/fh-sim-replay

# The sim listens on SIM_PORT (default 9100) inside the container.
# The admin HTTP endpoint (POST /admin/replay) listens on
# SIM_ADMIN_PORT (default 9101) when FH_SIM_ADMIN_TOKEN is set.
# See sim/DESIGN.md §16.6 sub-slice 8.1 and §22.12.
EXPOSE 9100
EXPOSE 9101

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
