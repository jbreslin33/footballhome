// footballhome sim - fh-sim.v1 MATCH_EVENT frame (§7.6, Slice 28.4)
//
// MATCH_EVENT is the wire-side sibling to the storage-side ADR §22.25.
// The server broadcasts one MATCH_EVENT per row it writes to
// sim_match_events when a client needs to observe it live (Slice 28.4
// only emits Goal events — future events plug in without a codec
// change). The wire payload is byte-identical to the DB payload so the
// migration-221 decoders and any client-side sim_decode_event port stay
// in lock-step.
//
// See WireFormat.hpp §7.6 addendum for the authoritative byte layout.

#pragma once

#include "net/WireFormat.hpp"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <vector>

namespace fh::sim::net {

// Decoder output. `event_payload` owns its bytes (copied out of the
// input span) so callers can outlive the frame buffer.
struct DecodedMatchEvent {
    std::uint32_t             tick_num      = 0;
    std::uint8_t              event_type    = 0;
    std::vector<std::uint8_t> event_payload;
};

// Encode a MATCH_EVENT frame (header + payload). Returns the exact
// on-the-wire bytes. `event_payload` MAY be empty (some event types
// carry no payload); its size MUST fit into the u16 event_payload_len
// AND together with the 7-byte MATCH_EVENT header must fit into the
// u16 frame payload_len (i.e. event_payload.size() + kMatchEventHeaderBytes
// <= kMaxPayloadBytes). Overflow returns an empty vector so the
// transport-level send is a visible no-op — callers should check.
std::vector<std::uint8_t>
encodeMatchEventFrame(std::uint32_t tick_num,
                      std::uint8_t  event_type,
                      std::span<const std::uint8_t> event_payload);

// Decode a MATCH_EVENT frame (header + payload). Returns nullopt on
// any malformation: wrong version, wrong msg_type, truncated header,
// payload length mismatch, or event_payload_len exceeding the outer
// payload cap. Never throws.
std::optional<DecodedMatchEvent>
decodeMatchEventFrame(std::span<const std::uint8_t> frame);

} // namespace fh::sim::net
