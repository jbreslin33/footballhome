# sim/tests/CMakeLists.txt
#
# Simple test framework: each test is its own executable + `add_test` entry.
# No gtest dependency in M0 — we ship one tiny test.h header for assertions
# and stay deterministic and dependency-free.

add_library(sim_test_harness INTERFACE)
target_include_directories(sim_test_harness INTERFACE .)
target_link_libraries(sim_test_harness INTERFACE sim_flags)

function(fh_add_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_math sim_test_harness)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

# Tests that additionally need the data layer (registries, Sets, awareness).
function(fh_add_data_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_data sim_test_harness)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

# Tests for the gameplay stack (physics, controllers, scenario, match).
function(fh_add_gameplay_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_gameplay sim_test_harness)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

# Tests for the wire / networking layer.
function(fh_add_net_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_net sim_test_harness)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

# Tests for the auth layer (JWT verification). Links OpenSSL directly so
# tests can mint tokens; production sim_auth already pulls OpenSSL::Crypto.
function(fh_add_auth_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_auth sim_test_harness OpenSSL::Crypto)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

# Tests for the server layer (SimServer). Needs OpenSSL to mint JWTs
# same as the auth/websocket-transport integration tests.
function(fh_add_server_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_server sim_test_harness OpenSSL::Crypto)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

# Tests for the persistence layer (IPgClient + InMemoryPgClient).
function(fh_add_persistence_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE sim_persistence sim_test_harness)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

fh_add_test(test_fixed64)
fh_add_test(test_fixed_math)
fh_add_test(test_vec3)
fh_add_test(test_rng_det)
fh_add_test(test_trig_lut)

fh_add_data_test(test_registry)
fh_add_data_test(test_attribute_set)
fh_add_data_test(test_concept_set)
fh_add_data_test(test_recognition_set)
fh_add_data_test(test_recognition_passthrough)

fh_add_gameplay_test(test_stub_physics)
fh_add_gameplay_test(test_basic_physics)
fh_add_gameplay_test(test_ball_physics)
fh_add_gameplay_test(test_match_clock)
fh_add_gameplay_test(test_human_controller)
fh_add_gameplay_test(test_empty_pitch_scenario)
fh_add_gameplay_test(test_ball_on_pitch_scenario)
fh_add_gameplay_test(test_ball_on_pitch_with_defender_scenario)
fh_add_gameplay_test(test_goal_drill_scenario)
fh_add_gameplay_test(test_one_v_one_attack_defend_scenario)
fh_add_gameplay_test(test_wander_controller)
fh_add_gameplay_test(test_pursue_ball_carrier_behavior)
fh_add_gameplay_test(test_feint_1v1_behavior)
fh_add_gameplay_test(test_jockey_behavior)
fh_add_gameplay_test(test_mark_opponent_behavior)
fh_add_gameplay_test(test_ai_controller)
fh_add_gameplay_test(test_mechanics)
fh_add_gameplay_test(test_stamina)
fh_add_gameplay_test(test_match_tick)
fh_add_gameplay_test(test_match_ball)
fh_add_gameplay_test(test_match_goal_detection)
fh_add_gameplay_test(test_ball_control)
fh_add_gameplay_test(test_playable_area_hard)
fh_add_gameplay_test(test_playable_area_soft)
fh_add_gameplay_test(test_match_playable_area)
fh_add_gameplay_test(test_half_pitch_scenario)
fh_add_gameplay_test(test_soft_drill_scenario)
fh_add_gameplay_test(test_determinism)
fh_add_gameplay_test(test_canonical_hash)

fh_add_net_test(test_binary_v1_serializer)
fh_add_net_test(test_websocket_frame)
fh_add_net_test(test_websocket_handshake)
fh_add_net_test(test_websocket_transport)
fh_add_net_test(test_input_frame)
fh_add_net_test(test_scenario_meta_frame)
fh_add_net_test(test_match_event_frame)

fh_add_auth_test(test_jwt_verifier)

fh_add_server_test(test_sim_server)

# End-to-end match-lifecycle persistence assertion (§16.5 exit criterion:
# every match played end-to-end writes sim_matches ended_at + result,
# sim_match_inputs rows, and MatchStart/Connect/Claim/Release/Disconnect/
# MatchEnd events). Needs sim_server (the class under test), sim_persistence
# (InMemoryPgClient), sim_gameplay (canonical hash) and OpenSSL (JWT mint).
add_executable(test_match_lifecycle_persistence
    test_match_lifecycle_persistence.cpp)
target_link_libraries(test_match_lifecycle_persistence PRIVATE
    sim_server sim_persistence sim_gameplay sim_test_harness OpenSSL::Crypto)
add_test(NAME test_match_lifecycle_persistence
         COMMAND test_match_lifecycle_persistence)

fh_add_persistence_test(test_in_memory_pg_client)

fh_add_persistence_test(test_pg_client)

fh_add_persistence_test(test_registry_loader)
fh_add_persistence_test(test_profile_store)
fh_add_persistence_test(test_async_pg_log)
fh_add_persistence_test(test_async_pg_log_load)

# fh-sim-replay integration test — needs the full replay driver
# (sim_tools) plus the InMemoryPgClient it drives (sim_persistence)
# and the gameplay layer for canonical hash comparison.
add_executable(test_replay test_replay.cpp)
target_link_libraries(test_replay PRIVATE
    sim_tools sim_persistence sim_gameplay sim_net sim_test_harness)
add_test(NAME test_replay COMMAND test_replay)

# AdminHttpServer test (§16.6 sub-slice 8.1) — parser + JSON + full
# loopback socket e2e. Needs sim_admin for the class under test,
# sim_persistence for InMemoryPgClient, sim_tools for replayMatch
# (pulled in transitively by sim_admin but named for clarity).
add_executable(test_admin_http_server test_admin_http_server.cpp)
target_link_libraries(test_admin_http_server PRIVATE
    sim_admin sim_persistence sim_tools sim_test_harness)
add_test(NAME test_admin_http_server COMMAND test_admin_http_server)
