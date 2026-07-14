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
//   [u8  flags]              // bit 0 = wants_sprint,
//                            // bit 1 = wants_walk,
//                            // bit 2 = wants_dribble    (Slice 16.2)
//   [u8  reserved[3]]
//
// Additive-only rule: existing bits keep their meaning forever; new
// features consume the next free bit. Old servers ignore unknown bits
// (they mask `flags & kInputFlagWantsSprint | kInputFlagWantsWalk`);
// new servers reading an old client's frame see bit 2 = 0, i.e. "no
// explicit dribble request" — HumanController still auto-emits on
// ball-proximity so UX is preserved.
// -----------------------------------------------------------------------
inline constexpr std::size_t   kInputPayloadBytes  = 16;
inline constexpr std::size_t   kInputFrameBytes    = kFrameHeaderBytes + kInputPayloadBytes;   // 20
inline constexpr std::uint8_t  kInputFlagWantsSprint  = 1u << 0;
inline constexpr std::uint8_t  kInputFlagWantsWalk    = 1u << 1;
inline constexpr std::uint8_t  kInputFlagWantsDribble = 1u << 2;   // Slice 16.2

struct DecodedInput {
    std::uint32_t client_tick   = 0;
    float         desired_dir_x = 0.0F;   // this file IS the f32 boundary
    float         desired_dir_y = 0.0F;
    bool          wants_sprint  = false;
    bool          wants_walk    = false;
    bool          wants_dribble = false;   // Slice 16.2
};

// Decode a client-sent INPUT message (frame header + payload). Returns
// nullopt on any malformation: wrong version, wrong msg_type, wrong
// payload length, or short buffer. Never throws.
std::optional<DecodedInput> decodeInputFrame(std::span<const std::uint8_t> frame);

// Encode an INPUT message ready to hand to the transport's send(). Used
// by tests + the debug/replay path to synthesize wire-shape input rows
// with the same byte layout the live server accepts. Returns exactly
// kInputFrameBytes (20) bytes.
//
// `wants_walk` sets bit 1 of the flags byte, `wants_dribble` sets bit 2
// (Slice 16.2). Both are exposed as defaulted args so older callers
// (pre-Slice 16.2) keep compiling unchanged with bit 2 = 0.
std::vector<std::uint8_t> encodeInputFrame(std::uint32_t client_tick,
                                           float         desired_dir_x,
                                           float         desired_dir_y,
                                           bool          wants_sprint,
                                           bool          wants_walk    = false,
                                           bool          wants_dribble = false);

// -----------------------------------------------------------------------
// HELLO_ACK payload (§7.1 + Slice 15.4 addendum): 16 bytes
//   [u64 match_id]
//   [u16 your_slot_or_0]
//   [u32 tick_hz]
//   [u16 wire_capability_bits]     // Slice 15.4 (§7.1 addendum)
// -----------------------------------------------------------------------
inline constexpr std::size_t kHelloAckPayloadBytes = 16;
inline constexpr std::size_t kHelloAckFrameBytes   = kFrameHeaderBytes + kHelloAckPayloadBytes;   // 20

// Encode a HELLO_ACK message ready to hand to the transport's send().
// Returns exactly kHelloAckFrameBytes (20) bytes. `your_slot` is 0 if the
// client is spectator-only (no slot was assigned).
//
// `wire_capability_bits` advertises which optional wire features this
// server will emit for the session — see WireFormat.hpp §7.1 addendum
// for bit assignments. Defaults to 0 (bare M0 wire) so any legacy caller
// remains functional at the C++ API level.
std::vector<std::uint8_t> encodeHelloAckFrame(std::uint64_t match_id,
                                              std::uint16_t your_slot,
                                              std::uint32_t tick_hz,
                                              std::uint16_t wire_capability_bits = 0);

} // namespace fh::sim::net
