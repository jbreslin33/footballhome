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
    ScenarioMeta = 0x03,   // Slice 17.7a (§7.4): scenario metadata, once
                           //                     immediately after HELLO_ACK
    MatchEvent   = 0x04,   // Slice 28.4 (§7.6, ADR §22.25 wire-side sibling):
                           //   server-pushed match-event frame carrying one
                           //   sim_match_events row (event_type + versioned
                           //   payload). Broadcast per-tick when the server
                           //   advertises kWireCapMatchEventFrame.
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
//   bit 1 = ScenarioMeta          // Server WILL emit SCENARIO_META once,
//                                 // immediately after HELLO_ACK (Slice 17.7a)
//   bit 2 = MatchEventFrame       // Server WILL emit MATCH_EVENT frames
//                                 // (msg_type 0x04) for match events whose
//                                 // storage-side row is written to
//                                 // sim_match_events (Slice 28.4, wire-side
//                                 // sibling to storage ADR §22.25). Clients
//                                 // that see this bit unset MUST NOT expect
//                                 // any 0x04 traffic and should treat any
//                                 // stray 0x04 frame as a protocol error.
//   bit 3 = InputKickTrailer      // Server accepts the length-prefixed
//                                 // kick trailer on INPUT frames; client
//                                 // MUST grey out its kick UI when this
//                                 // bit is unset (Slice 26.2 / ADR §22.23).
// -----------------------------------------------------------------------
inline constexpr std::uint16_t kWireCapSnapshotBallTrailer = 1u << 0;
inline constexpr std::uint16_t kWireCapScenarioMeta        = 1u << 1;
inline constexpr std::uint16_t kWireCapMatchEventFrame     = 1u << 2;   // Slice 28.4
inline constexpr std::uint16_t kWireCapInputKickTrailer    = 1u << 3;   // Slice 26.2

// -----------------------------------------------------------------------
// SCENARIO_META payload layout (§7.4, Slice 17.7a).
//
// Sent exactly once per session, immediately after HELLO_ACK, when the
// server advertises kWireCapScenarioMeta. Carries the playable-area
// polygon + constraint mode declared by the match's scenario at
// construction time (see scenario::PlayableArea). The client uses this
// to render a visual overlay for the constrained region.
//
// Payload (variable, min 3, max kMaxPayloadBytes):
//   [u8  mode]                    // matches scenario::PlayableArea::Mode:
//                                 //   0 = Hard, 1 = Soft, 2 = Advisory
//   [u16 num_vertices]            // 0 = no polygon (baseline scenarios)
//   [vertex[num_vertices]]        // kScenarioMetaVertexBytes each
//
// Per-vertex record (8 bytes, XY only — z=0 by convention since the
// scenario polygon is defined on the ground plane):
//   [f32 x][f32 y]
//
// Mode-byte value asserts live next to scenario::PlayableArea::Mode
// so any renumbering there fails the build (see ScenarioMetaFrame.hpp).
//
// Send-once-per-session semantics mean the frame is NOT a mid-match
// mutation channel; scenarios that intend to change their playable area
// during a match will need a new msg_type (e.g. SCENARIO_META_DELTA).
// See DESIGN.md §22.22 (ADR: separate metadata channel over
// HELLO_ACK-appended payload).
// -----------------------------------------------------------------------
inline constexpr std::size_t   kScenarioMetaHeaderBytes = 1 + 2;   // mode + count
inline constexpr std::size_t   kScenarioMetaVertexBytes = 4 + 4;   // f32 x + f32 y

inline constexpr std::uint8_t  kScenarioModeHard     = 0;
inline constexpr std::uint8_t  kScenarioModeSoft     = 1;
inline constexpr std::uint8_t  kScenarioModeAdvisory = 2;

// Payload has a 16-bit length field in the frame — any single message
// payload must fit in u16.
inline constexpr std::size_t kMaxPayloadBytes = 0xFFFFu;

// Max entities that fit in one SNAPSHOT under the u16 payload cap. Useful
// for early sanity-checks on both encode and decode paths.
inline constexpr std::size_t kMaxSnapshotEntities =
    (kMaxPayloadBytes - kSnapshotHeaderBytes) / kEntityRecordBytes;

// Max vertices that fit in one SCENARIO_META under the u16 payload cap.
inline constexpr std::size_t kMaxScenarioMetaVertices =
    (kMaxPayloadBytes - kScenarioMetaHeaderBytes) / kScenarioMetaVertexBytes;

// -----------------------------------------------------------------------
// MATCH_EVENT payload layout (§7.6, Slice 28.4 / ADR §22.25 wire-side).
//
// Sent by the server whenever it writes a row to `sim_match_events` that
// clients need to see live (Slice 28.4 currently emits Goal only; future
// events will piggy-back here). The frame wraps ONE sim_match_events row:
// event_type + tick_num + the exact versioned payload bytes that also
// landed in Postgres. Keeping DB and wire in byte-lockstep means every
// wire consumer (goal-flash HUD, live scoreboard) already knows the
// migration-221 decoder rules — no parallel wire-specific payload spec.
//
// Payload layout (variable, min = kMatchEventHeaderBytes = 7):
//   [u32 tick_num]                // matches sim_match_events.tick_num
//   [u8  event_type]              // matches persistence::EventType byte value
//   [u16 event_payload_len]       // == sim_match_events.payload length
//   [u8  event_payload[event_payload_len]]
//
// For a Goal event (event_type=9), event_payload_len == kGoalPayloadV1Bytes
// (=5) and the bytes are the ADR §22.25 v1 layout:
//   [u8 ver=1][u8 region][u16 kicker_slot_id LE][u8 reserved=0]
//
// Total on-the-wire for a Goal frame: kFrameHeaderBytes(4)
//                                     + kMatchEventHeaderBytes(7)
//                                     + kGoalPayloadV1Bytes(5) = 16 bytes.
//
// The u16 event_payload_len is the forward-compat hook: a Goal-v2 payload
// growing to 12 bytes bumps only event_payload_len; v1 decoders parse
// [0..4] and ignore [5..11] (per ADR §22.25's "readers parse what they
// know, skip the tail" convention). Unknown event_types are legitimate
// too — clients that don't recognise an event_type MUST skip the frame
// and continue reading, NOT tear down the session.
// -----------------------------------------------------------------------
inline constexpr std::size_t kMatchEventHeaderBytes = 4 + 1 + 2;   // 7

} // namespace fh::sim::net
