// footballhome sim - fh-sim.v1 SCENARIO_META frame (§7.4, Slice 17.7a)
//
// SCENARIO_META is sent exactly once per session, immediately after
// HELLO_ACK, when the server advertises kWireCapScenarioMeta. It carries
// the playable-area polygon + constraint mode declared by the match's
// scenario (see scenario::PlayableArea).
//
// This file is the C++ codec — encode by primitives (mode byte + span of
// XY vertices) so the net layer stays free of scenario types. Callers
// (SimServer) translate scenario::PlayableArea → primitives → encode.
// Decode returns a DecodedScenarioMeta with an owning vertex vector, so
// tests + client tools don't have to manage buffer lifetime.
//
// Byte layout is fully specified in WireFormat.hpp §7.4 addendum.

#pragma once

#include "net/WireFormat.hpp"
#include "scenario/Scenario.hpp"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <vector>

namespace fh::sim::net {

// Compile-time lock: the mode byte on the wire is a direct cast of
// scenario::PlayableArea::Mode. Any renumbering in Scenario.hpp fails the
// build here so wire drift is impossible to introduce silently.
static_assert(static_cast<std::uint8_t>(scenario::PlayableArea::Mode::Hard)
                  == kScenarioModeHard,
              "scenario::PlayableArea::Mode::Hard must remain wire value 0");
static_assert(static_cast<std::uint8_t>(scenario::PlayableArea::Mode::Soft)
                  == kScenarioModeSoft,
              "scenario::PlayableArea::Mode::Soft must remain wire value 1");
static_assert(static_cast<std::uint8_t>(scenario::PlayableArea::Mode::Advisory)
                  == kScenarioModeAdvisory,
              "scenario::PlayableArea::Mode::Advisory must remain wire value 2");

// One polygon vertex on the wire — XY plane only (see §7.4). The
// scenario polygon is defined on the ground plane so z is not
// transmitted.
struct ScenarioMetaVertex {
    float x = 0.0F;
    float y = 0.0F;
};

// Decoder output. Vertices owned by the returned struct.
struct DecodedScenarioMeta {
    std::uint8_t                    mode = kScenarioModeAdvisory;
    std::vector<ScenarioMetaVertex> vertices;
};

// Encode a SCENARIO_META frame (header + payload). Returns the exact
// on-the-wire bytes. `mode` MUST be one of kScenarioMode{Hard,Soft,
// Advisory} — the encoder writes it verbatim. `vertices.size()` MUST be
// <= kMaxScenarioMetaVertices (the u16 payload cap); on overflow the
// encoder returns an empty vector so callers can surface the error
// without exceptions. All floats are written little-endian.
std::vector<std::uint8_t>
encodeScenarioMetaFrame(std::uint8_t mode,
                        std::span<const ScenarioMetaVertex> vertices);

// Decode a SCENARIO_META frame (header + payload). Returns nullopt on
// any malformation: wrong version, wrong msg_type, truncated header,
// truncated vertex region, or payload length mismatch. Never throws.
std::optional<DecodedScenarioMeta>
decodeScenarioMetaFrame(std::span<const std::uint8_t> frame);

} // namespace fh::sim::net
