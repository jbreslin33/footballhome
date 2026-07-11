# footballhome sim - build system (M0 scaffolding)
#
# Determinism-first C++ project. Strict compiler flags, no unsafe math,
# no exceptions in the hot path, sanitizers in Debug.
#
# See sim/DESIGN.md sections 5.1, 10, 16, 17.

cmake_minimum_required(VERSION 3.24)
project(footballhome_sim
    VERSION 0.0.1
    LANGUAGES CXX
    DESCRIPTION "footballhome tactical football simulator")

# -----------------------------------------------------------------------------
# Global settings
# -----------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)          # -std=c++20, not -std=gnu++20

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Export compile_commands.json for clangd/editors
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# We rely on __int128 (GCC/Clang extension). MSVC not supported.
if(NOT (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR
        CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    message(FATAL_ERROR
        "footballhome_sim requires GCC or Clang (needs __int128). "
        "Detected: ${CMAKE_CXX_COMPILER_ID}")
endif()

# -----------------------------------------------------------------------------
# Determinism-safe compiler flags
#
# Explicitly BANNED (per DESIGN.md sec 10 rule 6):
#   -ffast-math, -Ofast, -funsafe-math-optimizations, -fassociative-math
#
# These are largely academic since the sim loop doesn't use floats, but the
# guardrails belong here anyway.
# -----------------------------------------------------------------------------
add_library(sim_flags INTERFACE)
target_compile_options(sim_flags INTERFACE
    -Wall
    -Wextra
    -Wpedantic
    -Wconversion
    -Wshadow
    -Wnon-virtual-dtor
    -Wold-style-cast
    -Wcast-align
    -Woverloaded-virtual
    -Wnull-dereference
    -Wdouble-promotion
    -Wformat=2
    -Wimplicit-fallthrough
    -Werror
    # Determinism guardrails
    -fno-fast-math
    -ffp-contract=off                # no fused multiply-add tricks
    -fno-associative-math
    -fno-reciprocal-math
    -fno-unsafe-math-optimizations
    -fno-finite-math-only
    -fsigned-char
    # __int128 needs no flag on GCC/Clang, just check support
)

# Sanitizers in Debug builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(sim_flags INTERFACE
        -O0 -g3
        -fsanitize=address,undefined
        -fno-omit-frame-pointer)
    target_link_options(sim_flags INTERFACE
        -fsanitize=address,undefined)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(sim_flags INTERFACE
        -O2                         # conservative; unsafe math flags are banned
        -DNDEBUG)
endif()

# -----------------------------------------------------------------------------
# The math foundation library (Fixed64, FixedMath, TrigLUT, Vec3, RngDet)
# -----------------------------------------------------------------------------
add_library(sim_math STATIC
    src/math/Fixed64.cpp
    src/math/FixedMath.cpp
    src/math/TrigLUT.cpp
)
target_include_directories(sim_math PUBLIC src)
target_link_libraries(sim_math PUBLIC sim_flags)

# -----------------------------------------------------------------------------
# Data-model layer (registries + player-profile Sets + awareness pass-through)
#
# Pure data types. Depends only on sim_math. No physics, no controllers, no
# runtime side effects. Adding new registries or Set fields does not require
# touching any downstream code.
# -----------------------------------------------------------------------------
add_library(sim_data STATIC
    src/registry/AttributeRegistry.cpp
    src/registry/ConceptRegistry.cpp
    src/registry/PatternRegistry.cpp
    src/profile/PackedU16F32.cpp
    src/profile/AttributeSet.cpp
    src/profile/ConceptSet.cpp
    src/profile/RecognitionSet.cpp
    src/awareness/RecognitionSystem.cpp
)
target_include_directories(sim_data PUBLIC src)
target_link_libraries(sim_data PUBLIC sim_math sim_flags)

# -----------------------------------------------------------------------------
# Gameplay stack (physics, controllers, scenarios, match orchestration).
#
# Depends on sim_data (which owns registries + profile + awareness). Together
# they form everything a headless match needs before the networking slice.
# -----------------------------------------------------------------------------
add_library(sim_gameplay STATIC
    src/common/M0Attributes.cpp
    src/physics/StubPhysics.cpp
    src/controller/HumanController.cpp
    src/controller/WanderController.cpp
    src/controller/AiController.cpp
    src/scenario/EmptyPitchScenario.cpp
    src/match/MatchClock.cpp
    src/match/Mechanics.cpp
    src/match/Match.cpp
)
target_include_directories(sim_gameplay PUBLIC src)
target_link_libraries(sim_gameplay PUBLIC sim_data sim_flags)

# -----------------------------------------------------------------------------
# Networking / wire (SNAPSHOT + INPUT serializers, transports later).
#
# This is the documented Fixed64 → f32 boundary (§7). f32 is allowed here
# and only here in the sim tree.
#
# WebSocketHandshake needs SHA1 for the Sec-WebSocket-Accept header, so
# OpenSSL::Crypto is a net-lib dependency alongside auth.
# -----------------------------------------------------------------------------
find_package(OpenSSL REQUIRED)

# -----------------------------------------------------------------------------
# Auth (JWT HS256 verification against the shared secret with backend).
#
# Depends on OpenSSL::Crypto for HMAC-SHA256 + constant-time compare — same
# stack the backend uses, so shared JWT_SECRET tokens verify byte-for-byte.
# -----------------------------------------------------------------------------
add_library(sim_auth STATIC
    src/auth/JwtVerifier.cpp
)
target_include_directories(sim_auth PUBLIC src)
target_link_libraries(sim_auth PUBLIC sim_flags OpenSSL::Crypto)

add_library(sim_net STATIC
    src/net/BinaryV1Serializer.cpp
    src/net/InputFrame.cpp
    src/net/WebSocketFrame.cpp
    src/net/WebSocketHandshake.cpp
    src/net/WebSocketTransport.cpp
)
target_include_directories(sim_net PUBLIC src)
target_link_libraries(sim_net PUBLIC sim_gameplay sim_flags sim_auth OpenSSL::Crypto)

# -----------------------------------------------------------------------------
# Server (SimServer: wires transport + serializer + match).
# -----------------------------------------------------------------------------
add_library(sim_server STATIC
    src/server/SimServer.cpp
)
target_include_directories(sim_server PUBLIC src)
target_link_libraries(sim_server PUBLIC sim_net sim_gameplay sim_flags)

# -----------------------------------------------------------------------------
# Executable (footballhome_sim daemon).
# -----------------------------------------------------------------------------
add_executable(footballhome_sim src/main.cpp)
target_link_libraries(footballhome_sim PRIVATE sim_server sim_flags)

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------
enable_testing()
add_subdirectory(tests)
