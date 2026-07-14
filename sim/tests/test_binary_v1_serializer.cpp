// footballhome sim - BinaryV1Serializer tests
//
// Locks the fh-sim.v1 SNAPSHOT wire format. Any accidental change to byte
// layout, byte ordering, or flag bit assignment will trip a golden here
// before the client ever sees it.
//
// See DESIGN.md §7 for the spec.

#include "net/BinaryV1Serializer.hpp"
#include "net/LeCodec.hpp"
#include "net/WireFormat.hpp"

#include "common/EntityState.hpp"
#include "match/Snapshot.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <cstdio>
#include <vector>

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::match::EntityFlags;
using fh::sim::match::Snapshot;
using fh::sim::match::SnapshotEntity;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::net::BinaryV1Serializer;
using fh::sim::net::kBallOwnerLoose;
using fh::sim::net::kBallRegionBytes;
using fh::sim::net::kEntityRecordBytes;
using fh::sim::net::kFlagActive;
using fh::sim::net::kFlagHumanControlled;
using fh::sim::net::kFlagIsBall;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kSnapshotHeaderBytes;
using fh::sim::net::kSnapshotTrailerLenBytes;
using fh::sim::net::kWireVersionV1;
using fh::sim::net::MsgType;
using fh::sim::net::read_f32_le;
using fh::sim::net::read_u16_le;
using fh::sim::net::read_u32_le;

namespace {

SnapshotEntity makeEntity(std::uint16_t slot,
                          Fixed64 x, Fixed64 y,
                          Fixed64 vx, Fixed64 vy,
                          Fixed64 heading,
                          MotionState motion,
                          bool human)
{
    SnapshotEntity e{};
    e.state.id       = EntityId{0};   // not on wire
    e.state.slot_id  = SlotId{slot};
    e.state.position = Vec3{x, y, Fixed64::zero()};
    e.state.velocity = Vec3{vx, vy, Fixed64::zero()};
    e.state.heading  = heading;
    e.state.motion   = motion;
    e.flags.human_controlled = human;
    e.flags.is_ball          = false;
    e.flags.active           = true;
    return e;
}

// Slice 15.4: helper for tests that need a ball entity in the snapshot.
// Matches the shape Match::snapshot() produces (Slice 15.2): slot_id 0,
// is_ball + active set, human_controlled clear, motion Idle.
SnapshotEntity makeBallEntity(Fixed64 x, Fixed64 y, Fixed64 z,
                              Fixed64 vx, Fixed64 vy, Fixed64 vz)
{
    SnapshotEntity e{};
    e.state.id       = EntityId{0};
    e.state.slot_id  = SlotId{0};
    e.state.position = Vec3{x, y, z};
    e.state.velocity = Vec3{vx, vy, vz};
    e.state.heading  = Fixed64::zero();
    e.state.motion   = MotionState::Idle;
    e.flags.is_ball          = true;
    e.flags.active           = true;
    e.flags.human_controlled = false;
    return e;
}

Snapshot canonicalSnapshot() {
    Snapshot s;
    s.tick          = TickNum{42};
    s.match_time_ms = 2100u;
    s.entities.push_back(makeEntity(
        1,
        Fixed64::fromInt(3),           // pos.x = 3.0
        Fixed64::fromInt(-4),          // pos.y = -4.0
        Fixed64::fromInt(1),           // vel.x = 1.0
        Fixed64::fromInt(0),           // vel.y = 0.0
        Fixed64::fromFraction(1, 2),   // heading = 0.5 rad
        MotionState::Jog,
        false));
    s.entities.push_back(makeEntity(
        2,
        Fixed64::fromInt(0),
        Fixed64::fromInt(0),
        Fixed64::fromInt(0),
        Fixed64::fromInt(0),
        Fixed64::zero(),
        MotionState::Idle,
        true /* human */));
    return s;
}

// FNV-1a-64 for byte-golden hashing.
constexpr std::uint64_t kFnvOffset = 0xcbf29ce484222325ULL;
constexpr std::uint64_t kFnvPrime  = 0x100000001b3ULL;
std::uint64_t fnv1a(const std::vector<std::uint8_t>& v) noexcept {
    std::uint64_t h = kFnvOffset;
    for (const std::uint8_t b : v) { h ^= b; h *= kFnvPrime; }
    return h;
}

} // namespace

FH_TEST(wire_constants_match_spec) {
    // §7.2 byte breakdown: 2+2+4*3+4*2+4+1+1 = 30
    FH_EXPECT_EQ(kEntityRecordBytes,  30u);
    // Snapshot payload header: u32 tick + u32 match_time + u16 count = 10
    FH_EXPECT_EQ(kSnapshotHeaderBytes, 10u);
    // Frame header: u8 ver + u8 type + u16 len = 4
    FH_EXPECT_EQ(kFrameHeaderBytes,     4u);
    FH_EXPECT_EQ(kWireVersionV1,        1u);
    FH_EXPECT_EQ(static_cast<std::uint8_t>(MsgType::Snapshot), 0x10u);
}

FH_TEST(empty_snapshot_encodes_to_14_bytes) {
    BinaryV1Serializer s;
    Snapshot snap;
    snap.tick = TickNum{0};
    snap.match_time_ms = 0;

    const auto bytes = s.serialize(snap);
    FH_EXPECT_EQ(bytes.size(), 14u);   // 4 (frame) + 10 (snapshot header)

    // Frame header: ver=1, type=0x10, payload_len=10 LE.
    FH_EXPECT_EQ(bytes[0], 1u);
    FH_EXPECT_EQ(bytes[1], 0x10u);
    FH_EXPECT_EQ(read_u16_le(bytes.data() + 2), 10u);

    // Payload: tick=0, match_time=0, count=0.
    FH_EXPECT_EQ(read_u32_le(bytes.data() + 4),  0u);
    FH_EXPECT_EQ(read_u32_le(bytes.data() + 8),  0u);
    FH_EXPECT_EQ(read_u16_le(bytes.data() + 12), 0u);
}

FH_TEST(canonical_snapshot_size_and_frame_fields) {
    BinaryV1Serializer s;
    Snapshot snap = canonicalSnapshot();
    const auto bytes = s.serialize(snap);

    // 4 frame + 10 header + 2 * 30 entities = 74
    FH_EXPECT_EQ(bytes.size(), 74u);

    FH_EXPECT_EQ(bytes[0], kWireVersionV1);
    FH_EXPECT_EQ(bytes[1], static_cast<std::uint8_t>(MsgType::Snapshot));
    FH_EXPECT_EQ(read_u16_le(bytes.data() + 2), 70u);   // payload bytes

    FH_EXPECT_EQ(read_u32_le(bytes.data() + 4), 42u);   // tick
    FH_EXPECT_EQ(read_u32_le(bytes.data() + 8), 2100u); // match_time_ms
    FH_EXPECT_EQ(read_u16_le(bytes.data() + 12), 2u);   // num_entities
}

FH_TEST(entity_record_layout_slot1) {
    BinaryV1Serializer s;
    Snapshot snap = canonicalSnapshot();
    const auto bytes = s.serialize(snap);

    // First entity starts at offset 4 (frame) + 10 (snapshot hdr) = 14.
    const std::uint8_t* e0 = bytes.data() + 14;

    FH_EXPECT_EQ(read_u16_le(e0 + 0), 1u);              // slot_id
    // flags: only kFlagActive (bit 2) set = 0b100 = 4.
    FH_EXPECT_EQ(read_u16_le(e0 + 2), kFlagActive);

    FH_EXPECT_EQ(read_f32_le(e0 + 4),  3.0f);
    FH_EXPECT_EQ(read_f32_le(e0 + 8),  -4.0f);
    FH_EXPECT_EQ(read_f32_le(e0 + 12), 0.0f);
    FH_EXPECT_EQ(read_f32_le(e0 + 16), 1.0f);
    FH_EXPECT_EQ(read_f32_le(e0 + 20), 0.0f);
    FH_EXPECT_EQ(read_f32_le(e0 + 24), 0.5f);           // heading
    FH_EXPECT_EQ(e0[28], static_cast<std::uint8_t>(MotionState::Jog));   // 2
    FH_EXPECT_EQ(e0[29], 0u);                           // reserved
}

FH_TEST(entity_record_layout_slot2_human) {
    BinaryV1Serializer s;
    Snapshot snap = canonicalSnapshot();
    const auto bytes = s.serialize(snap);

    const std::uint8_t* e1 = bytes.data() + 14 + kEntityRecordBytes;
    FH_EXPECT_EQ(read_u16_le(e1 + 0), 2u);
    // Human + active = bit0 | bit2 = 0b101 = 5.
    FH_EXPECT_EQ(read_u16_le(e1 + 2), kFlagHumanControlled | kFlagActive);
    FH_EXPECT_EQ(e1[28], static_cast<std::uint8_t>(MotionState::Idle));   // 0
}

FH_TEST(roundtrip_preserves_fields) {
    BinaryV1Serializer s;
    Snapshot in = canonicalSnapshot();

    const auto bytes = s.serialize(in);
    const auto out   = s.deserialize(bytes);

    FH_EXPECT_EQ(out.tick,          in.tick);
    FH_EXPECT_EQ(out.match_time_ms, in.match_time_ms);
    FH_EXPECT_EQ(out.entities.size(), in.entities.size());
    for (std::size_t i = 0; i < in.entities.size(); ++i) {
        const auto& a = in.entities[i];
        const auto& b = out.entities[i];
        FH_EXPECT_EQ(a.state.slot_id, b.state.slot_id);
        // Position / velocity / heading go through Fixed64 → f32 → Fixed64.
        // f32 has ~7 decimal digits; the test snapshot uses exactly-
        // representable values (integers + 0.5) so the round-trip is exact
        // at the Fixed64 raw level.
        FH_EXPECT_EQ(a.state.position.x.raw, b.state.position.x.raw);
        FH_EXPECT_EQ(a.state.position.y.raw, b.state.position.y.raw);
        FH_EXPECT_EQ(a.state.position.z.raw, b.state.position.z.raw);
        FH_EXPECT_EQ(a.state.velocity.x.raw, b.state.velocity.x.raw);
        FH_EXPECT_EQ(a.state.velocity.y.raw, b.state.velocity.y.raw);
        FH_EXPECT_EQ(a.state.heading.raw,    b.state.heading.raw);
        FH_EXPECT(a.state.motion == b.state.motion);
        FH_EXPECT_EQ(a.flags.human_controlled, b.flags.human_controlled);
        FH_EXPECT_EQ(a.flags.is_ball,          b.flags.is_ball);
        FH_EXPECT_EQ(a.flags.active,           b.flags.active);
    }
}

FH_TEST(encode_is_idempotent) {
    // encode(decode(encode(x))) == encode(x)
    BinaryV1Serializer s;
    Snapshot in = canonicalSnapshot();

    const auto once  = s.serialize(in);
    const auto twice = s.serialize(s.deserialize(once));
    FH_EXPECT_EQ(once.size(), twice.size());
    for (std::size_t i = 0; i < once.size(); ++i) {
        FH_EXPECT_EQ(once[i], twice[i]);
    }
}

FH_TEST(decode_rejects_truncated_frame) {
    BinaryV1Serializer s;
    const std::vector<std::uint8_t> bytes{1, 0x10};   // only 2 of 4 header bytes
    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
    FH_EXPECT_EQ(snap.tick, TickNum{0});
}

FH_TEST(decode_rejects_wrong_wire_version) {
    BinaryV1Serializer s;
    Snapshot in = canonicalSnapshot();
    auto bytes = s.serialize(in);
    bytes[0] = 2;   // corrupt wire version
    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
    FH_EXPECT_EQ(snap.tick, TickNum{0});
}

FH_TEST(decode_rejects_wrong_msg_type) {
    BinaryV1Serializer s;
    Snapshot in = canonicalSnapshot();
    auto bytes = s.serialize(in);
    bytes[1] = static_cast<std::uint8_t>(MsgType::Input);   // 0x20
    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
}

FH_TEST(decode_rejects_length_mismatch) {
    BinaryV1Serializer s;
    Snapshot in = canonicalSnapshot();
    auto bytes = s.serialize(in);
    // Shrink by one byte — payload_bytes header still says 70, so the frame
    // is now inconsistent and must be rejected outright (no silent partial).
    bytes.pop_back();
    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
}

FH_TEST(decode_rejects_bad_num_entities) {
    // Frame length says one entity's worth of payload, but num_entities
    // claims two. Must reject.
    BinaryV1Serializer s;
    std::vector<std::uint8_t> bytes(kFrameHeaderBytes + kSnapshotHeaderBytes
                                    + kEntityRecordBytes, 0);
    // Frame: ver=1, type=Snapshot, payload_bytes = 10 + 30 = 40.
    bytes[0] = 1;
    bytes[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    bytes[2] = 40;
    bytes[3] = 0;
    // Payload: tick=0, match_time=0, but num_entities=2 (lie).
    bytes[4 + 8]  = 2;
    bytes[4 + 9]  = 0;
    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
}

FH_TEST(unknown_motion_state_falls_back_to_idle) {
    BinaryV1Serializer s;
    Snapshot in = canonicalSnapshot();
    auto bytes = s.serialize(in);
    // Corrupt the first entity's motion_state byte to a value outside the
    // enum (7). Must clamp to Idle without corrupting downstream code.
    bytes[14 + 28] = 7;
    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 2u);
    FH_EXPECT(snap.entities[0].state.motion == MotionState::Idle);
}

FH_TEST(golden_hash_canonical_snapshot) {
    // Locks the exact byte layout of a well-known snapshot. Any drift
    // (byte order, offsets, f32 representation of exactly-representable
    // values) fails this hash first. Update only when the wire format is
    // intentionally revised.
    BinaryV1Serializer s;
    const auto bytes = s.serialize(canonicalSnapshot());
    const std::uint64_t h = fnv1a(bytes);
    constexpr std::uint64_t kExpected = 0x4937890abb4edfb6ULL;   // canonical fh-sim.v1 layout, baked from first-successful encode
    if (h != kExpected) {
        std::fprintf(stderr,
            "  wire-format drift: got hash 0x%016lx, expected 0x%016lx\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpected));
    }
    FH_EXPECT_EQ(h, kExpected);
}

// ---------------------------------------------------------------------------
// v1.1 ball trailer (Slice 15.4)
//
// Backward-compat guarantee: no-ball snapshots MUST be byte-identical to M0.
// The trailer only appears when snap.entities contains a ball-flagged entity.
// ---------------------------------------------------------------------------
FH_TEST(no_ball_snapshot_omits_trailer) {
    // canonicalSnapshot has zero balls. Its byte size must be exactly
    // header + 2*entity records — no trailing bytes for a phantom trailer.
    BinaryV1Serializer s;
    const auto bytes = s.serialize(canonicalSnapshot());
    FH_EXPECT_EQ(bytes.size(), kFrameHeaderBytes + kSnapshotHeaderBytes
                               + 2u * kEntityRecordBytes);
    FH_EXPECT_EQ(read_u16_le(bytes.data() + 2),
                 kSnapshotHeaderBytes + 2u * kEntityRecordBytes);
}

FH_TEST(ball_only_snapshot_bytes_layout) {
    // Ball at (5.0, -3.0, 0.25) with velocity (1.5, 0.0, 0.0). Exactly-
    // representable f32 values so round-trip is bit-exact.
    Snapshot snap;
    snap.tick          = TickNum{100};
    snap.match_time_ms = 5000u;
    snap.entities.push_back(makeBallEntity(
        Fixed64::fromInt(5), Fixed64::fromInt(-3), Fixed64::fromFraction(1, 4),
        Fixed64::fromFraction(3, 2), Fixed64::zero(), Fixed64::zero()));

    BinaryV1Serializer s;
    const auto bytes = s.serialize(snap);

    // Frame: 4 header + 10 snap header + 0 entities + 2 trailer_len + 30 ball region = 46
    const std::size_t expected_payload = kSnapshotHeaderBytes
                                       + kSnapshotTrailerLenBytes
                                       + kBallRegionBytes;
    FH_EXPECT_EQ(bytes.size(), kFrameHeaderBytes + expected_payload);
    FH_EXPECT_EQ(read_u16_le(bytes.data() + 2),
                 static_cast<std::uint16_t>(expected_payload));

    // num_entities = 0 — the ball lives in the trailer, not the entities region.
    FH_EXPECT_EQ(read_u16_le(bytes.data() + kFrameHeaderBytes + 8), 0u);

    // Trailer length prefix comes immediately after the (empty) entities region.
    const std::uint8_t* trailer = bytes.data() + kFrameHeaderBytes + kSnapshotHeaderBytes;
    FH_EXPECT_EQ(read_u16_le(trailer), static_cast<std::uint16_t>(kBallRegionBytes));

    const std::uint8_t* ball = trailer + kSnapshotTrailerLenBytes;
    FH_EXPECT_EQ(read_f32_le(ball +  0),  5.0f);
    FH_EXPECT_EQ(read_f32_le(ball +  4), -3.0f);
    FH_EXPECT_EQ(read_f32_le(ball +  8),  0.25f);
    FH_EXPECT_EQ(read_f32_le(ball + 12),  1.5f);
    FH_EXPECT_EQ(read_f32_le(ball + 16),  0.0f);
    FH_EXPECT_EQ(read_f32_le(ball + 20),  0.0f);
    FH_EXPECT_EQ(read_f32_le(ball + 24),  0.0f);           // spin reserved
    FH_EXPECT_EQ(read_u16_le(ball + 28),  kBallOwnerLoose);
}

FH_TEST(ball_plus_players_roundtrip) {
    // Match::snapshot() emits the ball at entities[0] followed by player
    // entities in ascending slot_id. Verify the encoder splits correctly
    // and the decoder reconstructs the same in-memory shape.
    Snapshot in;
    in.tick          = TickNum{7};
    in.match_time_ms = 350u;
    in.entities.push_back(makeBallEntity(
        Fixed64::fromInt(0), Fixed64::fromInt(0), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));
    in.entities.push_back(makeEntity(
        1, Fixed64::fromInt(10), Fixed64::fromInt(20),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero(),
        MotionState::Walk, /*human*/ false));
    in.entities.push_back(makeEntity(
        2, Fixed64::fromInt(-5), Fixed64::fromInt(3),
        Fixed64::fromInt(1), Fixed64::zero(), Fixed64::fromFraction(1, 2),
        MotionState::Sprint, /*human*/ true));

    BinaryV1Serializer s;
    const auto bytes = s.serialize(in);

    // 4 + 10 + 2*30 + 2 + 30 = 106
    FH_EXPECT_EQ(bytes.size(),
                 kFrameHeaderBytes + kSnapshotHeaderBytes
                 + 2u * kEntityRecordBytes
                 + kSnapshotTrailerLenBytes + kBallRegionBytes);

    // num_entities = 2 (players only, ball not counted here).
    FH_EXPECT_EQ(read_u16_le(bytes.data() + kFrameHeaderBytes + 8), 2u);

    const auto out = s.deserialize(bytes);
    FH_EXPECT_EQ(out.entities.size(), 3u);            // ball reinserted at [0]
    FH_EXPECT_EQ(out.tick,            in.tick);
    FH_EXPECT_EQ(out.match_time_ms,   in.match_time_ms);

    // Ball first, at slot 0 with is_ball flag set.
    FH_EXPECT_EQ(static_cast<std::uint16_t>(out.entities[0].state.slot_id), 0u);
    FH_EXPECT(out.entities[0].flags.is_ball);
    FH_EXPECT(out.entities[0].flags.active);
    FH_EXPECT(!out.entities[0].flags.human_controlled);

    // Players preserve slot_id ordering.
    FH_EXPECT_EQ(static_cast<std::uint16_t>(out.entities[1].state.slot_id), 1u);
    FH_EXPECT_EQ(static_cast<std::uint16_t>(out.entities[2].state.slot_id), 2u);
    FH_EXPECT(out.entities[2].flags.human_controlled);
}

FH_TEST(ball_roundtrip_preserves_position_and_velocity) {
    Snapshot in;
    in.tick = TickNum{0};
    in.entities.push_back(makeBallEntity(
        Fixed64::fromFraction(7, 2),      // 3.5
        Fixed64::fromFraction(-9, 4),     // -2.25
        Fixed64::fromFraction(1, 8),      // 0.125
        Fixed64::fromFraction(-3, 2),     // -1.5
        Fixed64::fromFraction(5, 4),      // 1.25
        Fixed64::zero()));

    BinaryV1Serializer s;
    const auto bytes = s.serialize(in);
    const auto out   = s.deserialize(bytes);

    FH_EXPECT_EQ(out.entities.size(), 1u);
    const auto& b = out.entities[0];
    FH_EXPECT_EQ(b.state.position.x.raw, in.entities[0].state.position.x.raw);
    FH_EXPECT_EQ(b.state.position.y.raw, in.entities[0].state.position.y.raw);
    FH_EXPECT_EQ(b.state.position.z.raw, in.entities[0].state.position.z.raw);
    FH_EXPECT_EQ(b.state.velocity.x.raw, in.entities[0].state.velocity.x.raw);
    FH_EXPECT_EQ(b.state.velocity.y.raw, in.entities[0].state.velocity.y.raw);
    FH_EXPECT_EQ(b.state.velocity.z.raw, in.entities[0].state.velocity.z.raw);
}

// ---------------------------------------------------------------------------
// Slice 16.3: ball_owner surfacing in the trailer.
// ---------------------------------------------------------------------------

FH_TEST(no_owner_defaults_to_ball_owner_loose_on_wire) {
    // Snapshot with a ball but ball_owner = nullopt → trailer's owner
    // slot MUST be kBallOwnerLoose (0xFFFF). This is the invariant
    // that guarantees pre-Slice-16.3 clients (which treat 0xFFFF as
    // "no owner ring") continue to work with mid-flight snapshots.
    Snapshot in;
    in.tick = TickNum{3};
    in.entities.push_back(makeBallEntity(
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));
    // in.ball_owner intentionally left nullopt.

    BinaryV1Serializer s;
    const auto bytes = s.serialize(in);
    const std::uint8_t* trailer = bytes.data()
                                + kFrameHeaderBytes
                                + kSnapshotHeaderBytes
                                + kSnapshotTrailerLenBytes;
    FH_EXPECT_EQ(read_u16_le(trailer + 28), kBallOwnerLoose);
}

FH_TEST(owner_slot_id_written_to_trailer) {
    // ball_owner = SlotId{5} → trailer's owner slot MUST be 5, not
    // kBallOwnerLoose. Locks the Slice 16.3 wire behaviour that
    // Slice 16.5's client-side owner-ring renderer will depend on.
    Snapshot in;
    in.tick = TickNum{7};
    in.entities.push_back(makeBallEntity(
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));
    in.ball_owner = SlotId{5};

    BinaryV1Serializer s;
    const auto bytes = s.serialize(in);
    const std::uint8_t* trailer = bytes.data()
                                + kFrameHeaderBytes
                                + kSnapshotHeaderBytes
                                + kSnapshotTrailerLenBytes;
    FH_EXPECT_EQ(read_u16_le(trailer + 28), static_cast<std::uint16_t>(5));
}

FH_TEST(ball_owner_roundtrip_owned_and_loose) {
    // Owned round-trip: encode → decode → same ball_owner.
    Snapshot owned;
    owned.tick = TickNum{1};
    owned.entities.push_back(makeBallEntity(
        Fixed64::one(), Fixed64::zero(), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));
    owned.ball_owner = SlotId{9};

    BinaryV1Serializer s;
    const auto owned_out = s.deserialize(s.serialize(owned));
    FH_EXPECT(owned_out.ball_owner.has_value());
    FH_EXPECT_EQ(static_cast<std::uint16_t>(*owned_out.ball_owner), 9u);

    // Loose round-trip: kBallOwnerLoose in the trailer must decode
    // back to nullopt, not to SlotId{0xFFFF}. Otherwise the client
    // would keep drawing a stale owner ring on the "loose" slot 65535.
    Snapshot loose;
    loose.tick = TickNum{1};
    loose.entities.push_back(makeBallEntity(
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));
    // loose.ball_owner stays nullopt.

    const auto loose_out = s.deserialize(s.serialize(loose));
    FH_EXPECT(!loose_out.ball_owner.has_value());
}

FH_TEST(decode_rejects_trailer_len_smaller_than_ball_region) {
    // Hand-craft a snapshot whose trailer_len says 20 (< kBallRegionBytes=30).
    // Payload_sz would be 10 (snap hdr) + 0 (entities) + 2 (trailer len) + 20
    // = 32. That's malformed for v1.1 — reject.
    BinaryV1Serializer s;
    const std::size_t payload_sz = kSnapshotHeaderBytes
                                 + kSnapshotTrailerLenBytes + 20u;
    std::vector<std::uint8_t> bytes(kFrameHeaderBytes + payload_sz, 0);
    bytes[0] = kWireVersionV1;
    bytes[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    bytes[2] = static_cast<std::uint8_t>(payload_sz & 0xFFu);
    bytes[3] = static_cast<std::uint8_t>((payload_sz >> 8) & 0xFFu);
    // tick=0, match_time=0, num_entities=0 already zeroed.
    // trailer_len = 20 at offset kFrameHeaderBytes + kSnapshotHeaderBytes.
    bytes[kFrameHeaderBytes + kSnapshotHeaderBytes + 0] = 20;
    bytes[kFrameHeaderBytes + kSnapshotHeaderBytes + 1] = 0;

    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
}

FH_TEST(decode_rejects_trailer_len_mismatch_with_payload) {
    // Trailer_len = 30 but the payload has fewer bytes than trailer_len + 2
    // — the decoder must not read past the payload.
    BinaryV1Serializer s;
    const std::size_t payload_sz = kSnapshotHeaderBytes
                                 + kSnapshotTrailerLenBytes + 10u;   // short by 20
    std::vector<std::uint8_t> bytes(kFrameHeaderBytes + payload_sz, 0);
    bytes[0] = kWireVersionV1;
    bytes[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    bytes[2] = static_cast<std::uint8_t>(payload_sz & 0xFFu);
    bytes[3] = static_cast<std::uint8_t>((payload_sz >> 8) & 0xFFu);
    bytes[kFrameHeaderBytes + kSnapshotHeaderBytes + 0] = kBallRegionBytes;   // 30
    bytes[kFrameHeaderBytes + kSnapshotHeaderBytes + 1] = 0;

    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
}

FH_TEST(decode_rejects_dangling_trailer_len_byte) {
    // Exactly one byte after entities — not enough for even the trailer_len
    // u16. Must reject.
    BinaryV1Serializer s;
    const std::size_t payload_sz = kSnapshotHeaderBytes + 1u;
    std::vector<std::uint8_t> bytes(kFrameHeaderBytes + payload_sz, 0);
    bytes[0] = kWireVersionV1;
    bytes[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    bytes[2] = static_cast<std::uint8_t>(payload_sz & 0xFFu);
    bytes[3] = static_cast<std::uint8_t>((payload_sz >> 8) & 0xFFu);

    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
}

FH_TEST(decode_tolerates_empty_trailer) {
    // trailer_len = 0 is legal (just wasteful). Decoder must accept and
    // return zero entities — the sender chose to advertise "no ball this tick"
    // even though omitting the trailer entirely is more efficient.
    BinaryV1Serializer s;
    const std::size_t payload_sz = kSnapshotHeaderBytes + kSnapshotTrailerLenBytes;
    std::vector<std::uint8_t> bytes(kFrameHeaderBytes + payload_sz, 0);
    bytes[0] = kWireVersionV1;
    bytes[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    bytes[2] = static_cast<std::uint8_t>(payload_sz & 0xFFu);
    bytes[3] = static_cast<std::uint8_t>((payload_sz >> 8) & 0xFFu);
    // trailer_len = 0 (already zeroed).

    const auto snap = s.deserialize(bytes);
    FH_EXPECT_EQ(snap.entities.size(), 0u);
    // But snap itself decoded successfully — tick and match_time both 0.
    FH_EXPECT_EQ(snap.tick, TickNum{0});
}

FH_TEST(encode_rejects_multiple_balls) {
    // Only one ball per snapshot is supported on the wire; the encoder
    // returns {} rather than silently dropping the extra.
    Snapshot in;
    in.tick = TickNum{0};
    in.entities.push_back(makeBallEntity(
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));
    in.entities.push_back(makeBallEntity(
        Fixed64::fromInt(1), Fixed64::fromInt(1), Fixed64::zero(),
        Fixed64::zero(), Fixed64::zero(), Fixed64::zero()));

    BinaryV1Serializer s;
    const auto bytes = s.serialize(in);
    FH_EXPECT_EQ(bytes.size(), 0u);
}

FH_TEST_MAIN()
