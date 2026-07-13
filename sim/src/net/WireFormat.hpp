// footballhome sim - Wire protocol v1 constants
//
// Layout is little-endian throughout. See DESIGN.md §7 for the authoritative
// spec. Every runtime-observable size / offset / type-tag in the wire lives
// in this header; nothing else in the tree should hardcode magic numbers
// from the spec.

#pragma once

#include <cstdint>
#include <cstddef>

namespace fh::sim::net {

// -----------------------------------------------------------------------
// Framing (every message on the wire is prefixed with these 4 bytes).
// -----------------------------------------------------------------------
inline constexpr std::uint8_t  kWireVersionV1 = 1;
inline constexpr std::size_t   kFrameHeaderBytes = 4;   // ver + type + u16 len

// -----------------------------------------------------------------------
// Message types (§7.1).
// -----------------------------------------------------------------------
enum class MsgType : std::uint8_t {
    Hello        = 0x01,
    HelloAck     = 0x02,
    Snapshot     = 0x10,
    Input        = 0x20,
    ClaimSlot    = 0x30,
    ReleaseSlot  = 0x31,
    Event        = 0x40,
    Ping         = 0x50,
    Pong         = 0x51,
};

// -----------------------------------------------------------------------
// SNAPSHOT payload layout (§7.2).
//
//   [u32 tick_num]
//   [u32 match_time_ms]
//   [u16 num_entities]
//   [entity[num_entities]]        // kEntityRecordBytes bytes each
// -----------------------------------------------------------------------
inline constexpr std::size_t kSnapshotHeaderBytes = 4 + 4 + 2;   // 10

// Per-entity record (see byte breakdown in §7.2):
//   [u16 slot_id][u16 flags]
//   [f32 pos_x][f32 pos_y][f32 pos_z]
//   [f32 vel_x][f32 vel_y]
//   [f32 heading]
//   [u8  motion_state][u8 reserved]
inline constexpr std::size_t kEntityRecordBytes = 2 + 2 + 4*3 + 4*2 + 4 + 1 + 1; // 30

// Per-entity flag bit assignments (§7.2).
inline constexpr std::uint16_t kFlagHumanControlled = 1u << 0;
inline constexpr std::uint16_t kFlagIsBall          = 1u << 1;
inline constexpr std::uint16_t kFlagActive          = 1u << 2;

// -----------------------------------------------------------------------
// SNAPSHOT v1.1 trailer (§7.2 addendum, Slice 15.4).
//
// Immediately after the entities region, an OPTIONAL trailer carries the
// ball's state. Backward-compatible additive extension: no-ball snapshots
// are BYTE-IDENTICAL to M0 (no trailer emitted), so v1.0 receivers keep
// working. Ball snapshots grow the payload; v1.1 receivers know to expect
// the trailer because the server advertises the capability in HELLO_ACK.
//
// Trailer layout (present iff ball state is emitted):
//   [u16 trailer_bytes]               // 0 (absent) or >=kBallRegionBytes
//   [if trailer_bytes >= kBallRegionBytes:]
//     [f32 pos_x][f32 pos_y][f32 pos_z]     // offset 0..11
//     [f32 vel_x][f32 vel_y][f32 vel_z]     // offset 12..23
//     [f32 spin]                            // offset 24..27  (reserved; 0 in M1)
//     [u16 owner_slot]                      // offset 28..29  (kBallOwnerLoose in M1)
//     [remaining bytes reserved for future ball fields, ignored by v1.1]
//
// The u16 length prefix makes this region forward-extensible: a hypothetical
// v1.2 adding e.g. ball_temperature grows trailer_bytes to 34; v1.1 readers
// parse the first 30 they know and skip the extra 4.
//
// See DESIGN.md §22.20 (ADR: length-prefixed extension over fixed-layout).
// -----------------------------------------------------------------------
inline constexpr std::size_t   kSnapshotTrailerLenBytes = 2;   // u16 prefix
inline constexpr std::size_t   kBallRegionBytes         = 30;
inline constexpr std::uint16_t kBallOwnerLoose          = 0xFFFFu;

// -----------------------------------------------------------------------
// HELLO_ACK v1.1 addendum (§7.1 addendum, Slice 15.4).
//
// Extra u16 appended to the M0 14-byte payload advertises which optional
// wire features THIS server will emit for the duration of the session.
// Clients that see an unknown bit set are free to ignore it; clients that
// see a known bit UNSET should not attempt to parse the corresponding
// region. In M1 the server always sets kWireCapSnapshotBallTrailer.
//
// Bit assignments:
//   bit 0 = SnapshotBallTrailer   // SNAPSHOT may carry the v1.1 ball trailer
// -----------------------------------------------------------------------
inline constexpr std::uint16_t kWireCapSnapshotBallTrailer = 1u << 0;

// Payload has a 16-bit length field in the frame — any single message
// payload must fit in u16.
inline constexpr std::size_t kMaxPayloadBytes = 0xFFFFu;

// Max entities that fit in one SNAPSHOT under the u16 payload cap. Useful
// for early sanity-checks on both encode and decode paths.
inline constexpr std::size_t kMaxSnapshotEntities =
    (kMaxPayloadBytes - kSnapshotHeaderBytes) / kEntityRecordBytes;

} // namespace fh::sim::net
