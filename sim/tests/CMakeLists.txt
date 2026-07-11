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
fh_add_gameplay_test(test_match_clock)
fh_add_gameplay_test(test_human_controller)
fh_add_gameplay_test(test_empty_pitch_scenario)
fh_add_gameplay_test(test_wander_controller)
fh_add_gameplay_test(test_mechanics)
fh_add_gameplay_test(test_stamina)
fh_add_gameplay_test(test_match_tick)
fh_add_gameplay_test(test_determinism)

fh_add_net_test(test_binary_v1_serializer)
fh_add_net_test(test_websocket_frame)
fh_add_net_test(test_websocket_handshake)
fh_add_net_test(test_websocket_transport)
fh_add_net_test(test_input_frame)

fh_add_auth_test(test_jwt_verifier)

fh_add_server_test(test_sim_server)
