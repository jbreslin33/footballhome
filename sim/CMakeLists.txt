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
# Registry catalog codegen (see DESIGN.md section 22.11).
#
# `sim/src/common/M0Registry.generated.hpp` is generated from
# `database/migrations/200-sim-registries.sql` — the single source of truth
# for attribute + concept IDs. The generated header contains inline
# constexpr AttrId / ConceptId constants plus a seedRegistries() helper.
#
# Two modes:
#   * Host build: the migration file is visible at
#     ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/... — CMake wires
#     an add_custom_command so editing the migration regenerates the
#     header automatically on the next build.
#   * Container build: the migration file is NOT in the sim/ build context;
#     the header must have been pre-generated on the host and COPY'd in.
#     CMake fails loudly with a clear error if it's missing.
# -----------------------------------------------------------------------------
set(SIM_MIGRATION_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/200-sim-registries.sql)
# Additional migration files that extend the two registry tables (each
# added the same way: hand-managed stable integer id, INSERT ... ON
# CONFLICT DO NOTHING). The awk generator concatenates every INSERT
# INTO sim_attribute_registry / sim_concept_registry block it finds
# across the input files in the order they're passed.
#   208 = physical.dribble_efficiency (Slice 16.1)
#   209 = physical.max_dribble_speed + max_carry_sprint_speed (Slice 25.2)
#   216 = physical.press_resistance (Slice 24.3b)
#   217 = physical.pass_power (Slice 26.1)
#   220 = physical.body_mass (Slice 27.3)
#   224 = pressing concept (Slice 30.2)
#   225 = marking + jockey concepts (Slice 31.1)
#   226 = M3 behavior attribute batch (Slice 31.3)
set(SIM_MIGRATION_EXTRA_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/208-sim-attr-dribble-efficiency.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/209-sim-attr-carry-speeds.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/216-sim-attr-press-resistance.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/217-sim-attr-pass-power.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/220-sim-attr-body-mass.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/224-sim-concept-pressing.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/225-sim-concept-marking-jockey.sql
    ${CMAKE_CURRENT_SOURCE_DIR}/../database/migrations/226-sim-attr-m3-batch.sql)
set(SIM_GEN_HEADER
    ${CMAKE_CURRENT_SOURCE_DIR}/src/common/M0Registry.generated.hpp)
set(SIM_GEN_SCRIPT
    ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gen_registry_header.awk)

if(EXISTS ${SIM_MIGRATION_FILE})
    message(STATUS
        "sim: registry codegen wired against ${SIM_MIGRATION_FILE} + ${SIM_MIGRATION_EXTRA_FILES}")
    add_custom_command(
        OUTPUT  ${SIM_GEN_HEADER}
        COMMAND awk -f ${SIM_GEN_SCRIPT} ${SIM_MIGRATION_FILE} ${SIM_MIGRATION_EXTRA_FILES} > ${SIM_GEN_HEADER}
        DEPENDS ${SIM_MIGRATION_FILE} ${SIM_MIGRATION_EXTRA_FILES} ${SIM_GEN_SCRIPT}
        COMMENT "Regenerating M0Registry.generated.hpp from migrations 200 + 208 + 209 + 216 + 217 + 220 + 224 + 225 + 226"
        VERBATIM)
    add_custom_target(gen_m0_registry ALL DEPENDS ${SIM_GEN_HEADER})
else()
    if(NOT EXISTS ${SIM_GEN_HEADER})
        message(FATAL_ERROR
            "sim: neither migration source nor pre-generated header found.\n"
            "  Missing: ${SIM_MIGRATION_FILE}\n"
            "  Missing: ${SIM_GEN_HEADER}\n"
            "  Pre-generate on the host before building the sim container:\n"
            "    awk -f sim/scripts/gen_registry_header.awk \\\n"
            "        database/migrations/200-sim-registries.sql \\\n"
            "        database/migrations/208-sim-attr-dribble-efficiency.sql \\\n"
            "        database/migrations/209-sim-attr-carry-speeds.sql \\\n"
            "        database/migrations/216-sim-attr-press-resistance.sql \\\n"
            "        database/migrations/217-sim-attr-pass-power.sql \\\n"
            "        database/migrations/220-sim-attr-body-mass.sql \\\n"
            "        database/migrations/224-sim-concept-pressing.sql \\\n"
            "        database/migrations/225-sim-concept-marking-jockey.sql \\\n"
            "        database/migrations/226-sim-attr-m3-batch.sql \\\n"
            "        > sim/src/common/M0Registry.generated.hpp")
    endif()
    message(STATUS
        "sim: using pre-generated ${SIM_GEN_HEADER} "
        "(migration source not in build context)")
    # No custom target needed; the header is a static input file.
    add_custom_target(gen_m0_registry)
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
    src/profile/AttributeSet.cpp
    src/profile/ConceptSet.cpp
    src/profile/RecognitionSet.cpp
    src/awareness/RecognitionSystem.cpp
    src/common/M0Attributes.cpp
)
target_include_directories(sim_data PUBLIC src)
target_link_libraries(sim_data PUBLIC sim_math sim_flags)
add_dependencies(sim_data gen_m0_registry)

# -----------------------------------------------------------------------------
# Persistence library (Postgres boundary; see DESIGN.md §22.12).
#
# IPgClient is the interface; InMemoryPgClient is the in-process test double
# / replay driver, shipped in production sources so `fh-sim-replay` can
# drive replays from memory as well as from Postgres. The concrete
# libpqxx-backed PgClient is the third TU below.
#
# Depends only on sim_flags for warnings — the interface uses domain ID
# types from `common/IdTypes.hpp` (header-only) and std::byte spans, so
# no compiled sim_math / sim_data code is needed to link the interface.
# libpqxx (found via pkg-config) is a PRIVATE dep — only PgClient.cpp
# includes <pqxx/pqxx.h>, so downstream targets don't transitively see it.
# -----------------------------------------------------------------------------
find_package(PkgConfig REQUIRED)
pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)

# AsyncPgLog (§16.6 task 8) uses std::thread / std::mutex /
# std::condition_variable and is header-only — templated header
# instantiated in SimServer.cpp (sim_server), main.cpp
# (footballhome_sim exe), and each async-log test. Threads is
# PUBLIC on sim_persistence so every consumer picks up the pthread
# link line transitively.
find_package(Threads REQUIRED)

add_library(sim_persistence STATIC
    src/persistence/InMemoryPgClient.cpp
    src/persistence/PgClient.cpp
    src/persistence/ProfileStore.cpp
    src/persistence/RegistryLoader.cpp
)
target_include_directories(sim_persistence PUBLIC src)
target_link_libraries(sim_persistence PUBLIC sim_flags sim_data Threads::Threads)
target_link_libraries(sim_persistence PRIVATE PkgConfig::PQXX)
add_dependencies(sim_persistence gen_m0_registry)

# -----------------------------------------------------------------------------
# Gameplay stack (physics, controllers, scenarios, match orchestration).
#
# Depends on sim_data (which owns registries + profile + awareness). Together
# they form everything a headless match needs before the networking slice.
# -----------------------------------------------------------------------------
add_library(sim_gameplay STATIC
    src/physics/StubPhysics.cpp
    src/physics/BasicPhysics.cpp
    src/physics/BallPhysics.cpp
    src/physics/PlayableAreaConstraint.cpp
    src/controller/HumanController.cpp
    src/controller/WanderController.cpp
    src/controller/AiController.cpp
    src/behavior/JockeyBehavior.cpp
    src/behavior/MarkOpponentBehavior.cpp
    src/behavior/PursueBallCarrierBehavior.cpp
    src/scenario/EmptyPitchScenario.cpp
    src/scenario/BallOnPitchScenario.cpp
    src/scenario/BallOnPitch2v0Scenario.cpp
    src/scenario/BallOnPitchWithDefenderScenario.cpp
    src/scenario/GoalDrillScenario.cpp
    src/scenario/HalfPitchScenario.cpp
    src/scenario/SoftDrillScenario.cpp
    src/match/MatchClock.cpp
    src/match/Mechanics.cpp
    src/match/Match.cpp
    src/match/CanonicalHash.cpp
    src/mechanics/BallControl.cpp
)
target_include_directories(sim_gameplay PUBLIC src)
target_link_libraries(sim_gameplay PUBLIC sim_data sim_flags)
add_dependencies(sim_gameplay gen_m0_registry)

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
    src/net/MatchEventFrame.cpp
    src/net/ScenarioMetaFrame.cpp
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
target_link_libraries(sim_server PUBLIC sim_net sim_gameplay sim_persistence sim_flags)

# -----------------------------------------------------------------------------
# Tools (offline utilities: fh-sim-replay).
#
# `sim_tools` holds the shared Replay driver library so test_replay can
# link it without duplicating the source. Depends on the full gameplay
# + persistence + net stack because replay reconstructs a live Match
# and decodes wire InputFrame payloads.
# -----------------------------------------------------------------------------
add_library(sim_tools STATIC
    src/tools/Replay.cpp
)
target_include_directories(sim_tools PUBLIC src)
target_link_libraries(sim_tools PUBLIC
    sim_gameplay sim_persistence sim_net sim_flags)

add_executable(fh-sim-replay src/tools/replay_main.cpp)
target_link_libraries(fh-sim-replay PRIVATE sim_tools sim_flags)
# Same GIT_DESCRIBE stamp as footballhome_sim so `--help` shows the
# build version. Value is resolved a few lines below.
# (target_compile_definitions call is at the bottom of the file after
# FH_SIM_GIT_DESCRIBE is resolved — kept together with the daemon's
# stamp to avoid duplicating the resolver logic.)

# -----------------------------------------------------------------------------
# Admin HTTP server (§16.6 sub-slice 8.1).
#
# Serves POST /admin/replay on an internal port (default 9101) so the
# backend container can proxy /api/sim/debug/matches/:id/state?tick=T
# without either container needing to spawn subprocesses or share
# binaries. Depends on sim_tools for the Replay driver and on
# sim_persistence for the IPgClient interface.
# -----------------------------------------------------------------------------
add_library(sim_admin STATIC
    src/admin/AdminHttpServer.cpp
)
target_include_directories(sim_admin PUBLIC src)
target_link_libraries(sim_admin PUBLIC
    sim_tools sim_persistence sim_flags Threads::Threads)

# -----------------------------------------------------------------------------
# Executable (footballhome_sim daemon).
# -----------------------------------------------------------------------------
add_executable(footballhome_sim src/main.cpp)
target_link_libraries(footballhome_sim PRIVATE
    sim_server sim_persistence sim_admin sim_flags)

# -----------------------------------------------------------------------------
# Build-time version string (§16.6 task 7).
#
# Populated in one of two ways (first hit wins):
#   1. Explicit -DFH_SIM_GIT_DESCRIBE=<string> on the cmake command line.
#      This is how container builds inject the value — the podman/docker
#      build context is ./sim so the .git directory isn't visible, and
#      build.sh runs `git describe` on the host + forwards it via
#      docker-compose build args → Dockerfile ARG → cmake -D.
#   2. Local `git describe --tags --dirty --always` when this CMakeLists
#      sits inside a checkout (developer builds outside a container).
# Falls back to "unknown" if neither source is available.
#
# The value is passed through as the FH_SIM_GIT_DESCRIBE compile define
# so main.cpp can stringify it into:
#   * MatchConfig::server_version (sent in HELLO_ACK payload, DESIGN §7)
#   * MatchRow::server_version   (written to sim_matches.server_version)
#
# Scoped to the executable target because it's the only translation
# unit that legitimately needs it — libraries stay build-cache-friendly.
# -----------------------------------------------------------------------------
if(NOT DEFINED FH_SIM_GIT_DESCRIBE OR FH_SIM_GIT_DESCRIBE STREQUAL "")
    find_program(GIT_EXECUTABLE git)
    set(FH_SIM_GIT_DESCRIBE "unknown")
    if(GIT_EXECUTABLE AND EXISTS "${CMAKE_SOURCE_DIR}/../.git")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --dirty --always
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/.."
            OUTPUT_VARIABLE   _git_describe_out
            RESULT_VARIABLE   _git_describe_rc
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(_git_describe_rc EQUAL 0 AND _git_describe_out)
            set(FH_SIM_GIT_DESCRIBE "${_git_describe_out}")
        endif()
    endif()
endif()
message(STATUS "sim: FH_SIM_GIT_DESCRIBE = ${FH_SIM_GIT_DESCRIBE}")
target_compile_definitions(footballhome_sim
    PRIVATE FH_SIM_GIT_DESCRIBE="${FH_SIM_GIT_DESCRIBE}")
target_compile_definitions(fh-sim-replay
    PRIVATE FH_SIM_GIT_DESCRIBE="${FH_SIM_GIT_DESCRIBE}")

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------
enable_testing()
add_subdirectory(tests)
