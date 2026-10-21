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
// INPUT payload — baseline (§7.3): 16 bytes
//   [u32 client_tick]                       // offset 0..3
//   [f32 desired_dir_x]                     // offset 4..7
//   [f32 desired_dir_y]                     // offset 8..11
//   [u8  flags]                             // offset 12
//                            // bit 0 = wants_sprint,
//                            // bit 1 = wants_walk,
//                            // bit 2 = wants_dribble    (Slice 16.2)
//                            // bit 3 = wants_release    (Slice 16.4)
//                            // bit 4 = wants_kick       (Slice 26.2)
//   [u8  reserved[3]]                       // offset 13..15
//
// INPUT payload — with-kick (§7.3 v1.1 addendum, Slice 26.2 / ADR §22.23):
// 28 bytes = baseline (16) + trailer_len prefix (2) + kick region (10)
//   [baseline 16 bytes exactly as above, with bit 4 of flags = 1]
//   [u16 trailer_len]                       // offset 16..17 — must be 10
//                                           //   (or >= 10 for forward-compat)
//   [f32 kick_dir_x]                        // offset 18..21
//   [f32 kick_dir_y]                        // offset 22..25
//   [u16 kick_power_hint]                   // offset 26..27
//                                           //   0 = profile default (Slice 26.3
//                                           //   reads physical.pass_power).
//
// Additive-only rule: existing bits keep their meaning forever; new
// features consume the next free bit. Old servers ignore unknown bits
// (they mask `flags & kInputFlagWantsSprint | kInputFlagWantsWalk`);
// new servers reading an old client's frame see bit 2 = 0, i.e. "no
// explicit dribble request" — HumanController still auto-emits on
// ball-proximity so UX is preserved. Same story for bit 3: old clients
// never set wants_release, and Slice 16.4 semantics only kick in when
// a caller (or, eventually, a client UI) explicitly sends it.
//
// Slice 26.2 (ADR §22.23) — INPUT gained an optional length-prefixed
// trailer for the kick primitive. `wants_kick == 0` frames encode to
// exactly `kInputFrameBaselineBytes` (20) — byte-identical to M0/M1 —
// so servers and ops decoders that predate Slice 26.2 continue to work
// on those rows unchanged. `wants_kick == 1` frames grow to
// `kInputFrameWithKickBytes` (32) and carry the kick direction + power
// hint in the trailer. The wire version stays v1 — no `WIRE_VERSION`
// bump is needed because the length prefix is the forward-compat hook,
// same pattern as the SNAPSHOT ball trailer (§22.20).
// -----------------------------------------------------------------------

// M0 baseline payload/frame sizes (no kick trailer).
inline constexpr std::size_t   kInputPayloadBaselineBytes = 16;
inline constexpr std::size_t   kInputFrameBaselineBytes   = kFrameHeaderBytes + kInputPayloadBaselineBytes;   // 20

// Slice 26.2 (ADR §22.23) — with-kick payload/frame sizes.
inline constexpr std::size_t   kInputTrailerLenBytes      = 2;    // u16 prefix
inline constexpr std::size_t   kInputKickRegionBytes      = 10;   // 2×f32 + u16
inline constexpr std::size_t   kInputPayloadWithKickBytes = kInputPayloadBaselineBytes
                                                          + kInputTrailerLenBytes
                                                          + kInputKickRegionBytes;   // 28
inline constexpr std::size_t   kInputFrameWithKickBytes   = kFrameHeaderBytes + kInputPayloadWithKickBytes;   // 32

inline constexpr std::uint8_t  kInputFlagWantsSprint  = 1u << 0;
inline constexpr std::uint8_t  kInputFlagWantsWalk    = 1u << 1;
inline constexpr std::uint8_t  kInputFlagWantsDribble = 1u << 2;   // Slice 16.2
inline constexpr std::uint8_t  kInputFlagWantsRelease = 1u << 3;   // Slice 16.4
inline constexpr std::uint8_t  kInputFlagWantsKick    = 1u << 4;   // Slice 26.2 / ADR §22.23

// Slice 26.2 (ADR §22.23) — kick_dir must be a roughly-unit vector.
// Accept a generous [0.5, 1.5] band so a client that forgets to
// normalise doesn't get silently zero'd, but reject anything wildly
// off (e.g. an un-scaled screen-space delta of hundreds). Values here
// are magnitude-squared (kick region carries the raw f32 dir, decoder
// computes dx*dx + dy*dy to skip a sqrt in the reject path).
inline constexpr float         kKickDirMinMagnitude = 0.5F;
inline constexpr float         kKickDirMaxMagnitude = 1.5F;

struct DecodedInput {
    std::uint32_t client_tick   = 0;
    float         desired_dir_x = 0.0F;   // this file IS the f32 boundary
    float         desired_dir_y = 0.0F;
    bool          wants_sprint  = false;
    bool          wants_walk    = false;
    bool          wants_dribble = false;   // Slice 16.2
    bool          wants_release = false;   // Slice 16.4
    // Slice 26.2 (ADR §22.23): kick trailer. When `wants_kick == false`
    // these three fields stay at their default zeros — the trailer was
    // absent on the wire. When `wants_kick == true` they carry the
    // (client-local) kick direction plus optional power hint in m/s
    // (0 = "use profile default", which Slice 26.3's ball-impulse code
    // will fill from `physical.pass_power`).
    bool          wants_kick      = false;
    float         kick_dir_x      = 0.0F;
    float         kick_dir_y      = 0.0F;
    std::uint16_t kick_power_hint = 0;
};

// Decode a client-sent INPUT message (frame header + payload). Returns
// nullopt on any malformation: wrong version, wrong msg_type, wrong
// payload length, or short buffer. Never throws.
//
// Slice 26.2 (ADR §22.23) — accepts either kInputFrameBaselineBytes
// (20) or kInputFrameWithKickBytes (32) frames. Any other length is
// rejected. Additional consistency rules:
//   * baseline (20 bytes): bit 4 (wants_kick) in flags MUST be 0 —
//     the kick trailer is absent on the wire so the flag would lie.
//   * with-kick (32 bytes): bit 4 (wants_kick) MUST be 1, trailer_len
//     MUST equal kInputKickRegionBytes (10) exactly, and
//     (kick_dir_x, kick_dir_y) must have magnitude within
//     [kKickDirMinMagnitude, kKickDirMaxMagnitude]. A future M3+
//     extension that widens the kick region will bump both
//     kInputKickRegionBytes and kInputPayloadWithKickBytes in
//     lockstep and accept the new outer size in addition; the
//     forward-compat hook is a THIRD length variant, not a relaxed
//     equality on the current one.
std::optional<DecodedInput> decodeInputFrame(std::span<const std::uint8_t> frame);

// Encode an INPUT message ready to hand to the transport's send(). Used
// by tests + the debug/replay path to synthesize wire-shape input rows
// with the same byte layout the live server accepts. Returns exactly
// `kInputFrameBaselineBytes` (20) bytes when `wants_kick == false`, or
// `kInputFrameWithKickBytes` (32) bytes when `wants_kick == true`.
//
// `wants_walk` sets bit 1 of the flags byte, `wants_dribble` sets bit 2
// (Slice 16.2), `wants_release` sets bit 3 (Slice 16.4), `wants_kick`
// sets bit 4 (Slice 26.2). All defaulted so older callers keep
// compiling unchanged with those bits = 0 and the return value stays
// byte-identical to M0.
//
// When `wants_kick` is true, `kick_dir_x` / `kick_dir_y` should be a
// roughly-unit vector (decoder rejects magnitude outside
// [kKickDirMinMagnitude, kKickDirMaxMagnitude]); `kick_power_hint` in
// m/s where 0 means "server picks from physical.pass_power" (Slice 26.3).
std::vector<std::uint8_t> encodeInputFrame(std::uint32_t client_tick,
                                           float         desired_dir_x,
                                           float         desired_dir_y,
                                           bool          wants_sprint,
                                           bool          wants_walk    = false,
                                           bool          wants_dribble = false,
                                           bool          wants_release = false,
                                           bool          wants_kick      = false,
                                           float         kick_dir_x      = 0.0F,
                                           float         kick_dir_y      = 0.0F,
                                           std::uint16_t kick_power_hint = 0);

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
