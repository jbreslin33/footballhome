# Football Home Game (v2) — build + tests.
#
# game/DESIGN.md is the source of truth; this file grows with the G0 slices.
# Non-negotiables enforced here as targets land: fixed-point only in the sim
# loop, every slice green via `ctest`, container gate via `make game-deploy`
# (slice G0.5).

cmake_minimum_required(VERSION 3.22)
project(footballhome_game LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

add_compile_options(-Wall -Wextra)

# ── game_math — fixed-point core (G0.1) ────────────────────────────────
# Adopted from v1 (archive/sim-2d-v1/src/math) after review: Q32.32
# Fixed64, FixedMath, trig LUTs, deterministic RNG, Vec3. Namespace
# renamed to fh::game::math; behavior byte-identical to v1's goldens.
add_library(game_math STATIC
  src/math/Fixed64.cpp
  src/math/FixedMath.cpp
  src/math/TrigLUT.cpp
)
target_include_directories(game_math PUBLIC src)

# ── game_core — world, tick loop, canonical hash (G0.2) ────────────────
add_library(game_core STATIC
  src/core/World.cpp
  src/core/CanonicalHash.cpp
)
target_link_libraries(game_core PUBLIC game_math)

# ── game_net — fh-game.v1 codec (G0.3) ─────────────────────────────────
add_library(game_net STATIC
  src/net/Codec.cpp
)
target_link_libraries(game_net PUBLIC game_math)

# ── game_ws — WebSocket transport + JWT auth (G0.4) ─────────────────────
# [v1] RFC 6455 transport (poll(2) event loop) + HMAC-SHA256 JwtVerifier,
# adopted from archive/sim-2d-v1 with the subprotocol rebranded fh-game.v1.
find_package(OpenSSL REQUIRED)
add_library(game_ws STATIC
  src/net/WebSocketFrame.cpp
  src/net/WebSocketHandshake.cpp
  src/net/WebSocketTransport.cpp
  src/auth/JwtVerifier.cpp
)
target_link_libraries(game_ws PUBLIC game_math OpenSSL::Crypto)

# ── game_ai — formations + first team brains (G2) ───────────────────────
add_library(game_ai STATIC
  src/ai/Formation.cpp
  src/ai/Brain.cpp
)
target_link_libraries(game_ai PUBLIC game_core)

# Calibration harness v0 [FH] — headless AI-vs-AI matches + stats (G2.5).
add_executable(fh-game-calibrate src/tools/calibrate_main.cpp)
target_link_libraries(fh-game-calibrate PRIVATE game_ai)

# ── game_server + daemon (G0.4) ─────────────────────────────────────────
add_library(game_server STATIC
  src/server/GameServer.cpp
)
target_link_libraries(game_server PUBLIC game_ai game_core game_net game_ws)

add_executable(fh-game src/main.cpp)
target_link_libraries(fh-game PRIVATE game_server)

# ── tests ──────────────────────────────────────────────────────────────
enable_testing()

function(game_test name)
  add_executable(${name} tests/${name}.cpp)
  target_link_libraries(${name} PRIVATE game_server)
  target_include_directories(${name} PRIVATE tests)
  add_test(NAME ${name} COMMAND ${name})
endfunction()

game_test(test_fixed64)
game_test(test_fixed_math)
game_test(test_trig_lut)
game_test(test_rng_det)
game_test(test_vec3)
game_test(test_world)
game_test(test_ball)
game_test(test_ai_match)
game_test(test_canonical_hash)
game_test(test_determinism_core)
game_test(test_codec)
game_test(test_websocket_frame)
game_test(test_websocket_handshake)
game_test(test_websocket_transport)
game_test(test_jwt_verifier)
game_test(test_game_server)
