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

# ── tests ──────────────────────────────────────────────────────────────
enable_testing()

function(game_test name)
  add_executable(${name} tests/${name}.cpp)
  target_link_libraries(${name} PRIVATE game_core game_net)
  target_include_directories(${name} PRIVATE tests)
  add_test(NAME ${name} COMMAND ${name})
endfunction()

game_test(test_fixed64)
game_test(test_fixed_math)
game_test(test_trig_lut)
game_test(test_rng_det)
game_test(test_vec3)
game_test(test_world)
game_test(test_canonical_hash)
game_test(test_determinism_core)
game_test(test_codec)
