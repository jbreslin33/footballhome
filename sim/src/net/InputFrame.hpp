// footballhome sim - fh-sim.v1 app-level frames (INPUT + HELLO_ACK)
//
// The BinaryV1Serializer handles SNAPSHOT (§7.2). This file covers the
// other two M0 message types that the server actually cares about:
//
//   * INPUT       (client → server) — decoded per §7.3
//   * HELLO_ACK   (server → client) — encoded per §7.1
//
// PING/PONG are handled inside WebSocketTransport (control frames), and
// HELLO / CLAIM_SLOT / RELEASE_SLOT / EVENT are M1+ concerns.
//
// f32 lives at this boundary per DESIGN.md §7 — decoded floats become
// Fixed64 the moment they cross into anything downstream (SimServer does
// that conversion, this file only shuffles bytes).

#pragma once

#include "net/WireFormat.hpp"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <vector>

namespace fh::sim::net {

// -----------------------------------------------------------------------
// INPUT payload (§7.3): 16 bytes
//   [u32 client_tick]
//   [f32 desired_dir_x]
//   [f32 desired_dir_y]
//   [u8  flags]              // bit 0 = wants_sprint, bit 1 = wants_walk
//   [u8  reserved[3]]
// -----------------------------------------------------------------------
inline constexpr std::size_t   kInputPayloadBytes  = 16;
inline constexpr std::size_t   kInputFrameBytes    = kFrameHeaderBytes + kInputPayloadBytes;   // 20
inline constexpr std::uint8_t  kInputFlagWantsSprint = 1u << 0;
inline constexpr std::uint8_t  kInputFlagWantsWalk   = 1u << 1;

struct DecodedInput {
    std::uint32_t client_tick   = 0;
    float         desired_dir_x = 0.0F;   // this file IS the f32 boundary
    float         desired_dir_y = 0.0F;
    bool          wants_sprint  = false;
    bool          wants_walk    = false;
};

// Decode a client-sent INPUT message (frame header + payload). Returns
// nullopt on any malformation: wrong version, wrong msg_type, wrong
// payload length, or short buffer. Never throws.
std::optional<DecodedInput> decodeInputFrame(std::span<const std::uint8_t> frame);

// Encode an INPUT message ready to hand to the transport's send(). Used
// by tests + the debug/replay path to synthesize wire-shape input rows
// with the same byte layout the live server accepts. Returns exactly
// kInputFrameBytes (20) bytes. `wants_walk` currently sets bit 1 of the
// flags byte; both flag bits are exposed even though the M0 mechanics
// only look at sprint.
std::vector<std::uint8_t> encodeInputFrame(std::uint32_t client_tick,
                                           float         desired_dir_x,
                                           float         desired_dir_y,
                                           bool          wants_sprint,
                                           bool          wants_walk = false);

// -----------------------------------------------------------------------
// HELLO_ACK payload (§7.1): 14 bytes
//   [u64 match_id]
//   [u16 your_slot_or_0]
//   [u32 tick_hz]
// -----------------------------------------------------------------------
inline constexpr std::size_t kHelloAckPayloadBytes = 14;
inline constexpr std::size_t kHelloAckFrameBytes   = kFrameHeaderBytes + kHelloAckPayloadBytes;   // 18

// Encode a HELLO_ACK message ready to hand to the transport's send().
// Returns exactly kHelloAckFrameBytes (18) bytes. `your_slot` is 0 if the
// client is spectator-only (no slot was assigned).
std::vector<std::uint8_t> encodeHelloAckFrame(std::uint64_t match_id,
                                              std::uint16_t your_slot,
                                              std::uint32_t tick_hz);

} // namespace fh::sim::net
