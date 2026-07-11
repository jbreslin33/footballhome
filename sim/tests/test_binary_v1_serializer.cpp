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
using fh::sim::net::kEntityRecordBytes;
using fh::sim::net::kFlagActive;
using fh::sim::net::kFlagHumanControlled;
using fh::sim::net::kFlagIsBall;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kSnapshotHeaderBytes;
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

FH_TEST_MAIN()
