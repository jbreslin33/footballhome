// footballhome sim - fh-sim.v1 SNAPSHOT serializer implementation
//
// Byte layout is exactly what §7.2 specifies. Every LE / bit_cast primitive
// lives in LeCodec.hpp; this file is pure wiring.

#include "net/BinaryV1Serializer.hpp"

#include "net/LeCodec.hpp"
#include "net/WireFormat.hpp"

#include <cstdint>

namespace fh::sim::net {

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::match::EntityFlags;
using fh::sim::match::Snapshot;
using fh::sim::match::SnapshotEntity;

// ---------------------------------------------------------------------------
// serialize
// ---------------------------------------------------------------------------
std::vector<std::uint8_t> BinaryV1Serializer::serialize(const Snapshot& snap)
{
    // Slice 15.4: split entities into (player entities, optional ball). The
    // ball moves out of the main entities region into the v1.1 trailer so
    // it can carry richer per-ball state (spin, owner) than the fixed 30-byte
    // entity record. Player entities keep the exact M0 wire layout.
    const SnapshotEntity* ball_entity = nullptr;
    std::size_t player_count = 0;
    for (const SnapshotEntity& e : snap.entities) {
        if (e.flags.is_ball) {
            // Only one ball per snapshot is supported on the wire; extra
            // ball-flagged entities would silently vanish, which is worse
            // than refusing to encode. Slice 15.2 emits at most one.
            if (ball_entity != nullptr) { return {}; }
            ball_entity = &e;
        } else {
            ++player_count;
        }
    }

    // Refuse to encode more player entities than fit in the u16 count field.
    // Hard error, not silent truncation — losing entities would be a safety bug.
    if (player_count > kMaxSnapshotEntities) {
        return {};
    }

    const std::size_t entities_bytes = player_count * kEntityRecordBytes;
    const std::size_t trailer_bytes  = ball_entity
        ? (kSnapshotTrailerLenBytes + kBallRegionBytes)
        : 0;
    const std::size_t payload_bytes  = kSnapshotHeaderBytes + entities_bytes + trailer_bytes;
    const std::size_t total_bytes    = kFrameHeaderBytes + payload_bytes;

    std::vector<std::uint8_t> out(total_bytes);
    std::uint8_t* p = out.data();

    // -- Frame header (§7) -------------------------------------------------
    write_u8    (p + 0, kWireVersionV1);
    write_u8    (p + 1, static_cast<std::uint8_t>(MsgType::Snapshot));
    write_u16_le(p + 2, static_cast<std::uint16_t>(payload_bytes));
    p += kFrameHeaderBytes;

    // -- Payload header (§7.2) ---------------------------------------------
    write_u32_le(p + 0, static_cast<std::uint32_t>(snap.tick));
    write_u32_le(p + 4, snap.match_time_ms);
    // num_entities counts PLAYER entities only — the ball is transported in
    // the v1.1 trailer below, not in the entities region.
    write_u16_le(p + 8, static_cast<std::uint16_t>(player_count));
    p += kSnapshotHeaderBytes;

    // -- Entities (§7.2 record) — player entities only --------------------
    for (const SnapshotEntity& e : snap.entities) {
        if (e.flags.is_ball) { continue; }   // routed to trailer
        const EntityState& s = e.state;

        write_u16_le(p + 0,  static_cast<std::uint16_t>(s.slot_id));
        write_u16_le(p + 2,  e.flags.toU16());
        write_f32_le(p + 4,  s.position.x.toFloat());
        write_f32_le(p + 8,  s.position.y.toFloat());
        write_f32_le(p + 12, s.position.z.toFloat());
        write_f32_le(p + 16, s.velocity.x.toFloat());
        write_f32_le(p + 20, s.velocity.y.toFloat());
        write_f32_le(p + 24, s.heading.toFloat());
        write_u8    (p + 28, static_cast<std::uint8_t>(s.motion));
        write_u8    (p + 29, 0);   // reserved
        p += kEntityRecordBytes;
    }

    // -- v1.1 trailer (§7.2 addendum) — only emitted when ball is present -
    //
    // Backward-compat design: no-ball snapshots are BYTE-IDENTICAL to M0,
    // so v1.0 receivers keep working. Ball snapshots grow the payload; v1.1
    // receivers know to expect a trailer because HELLO_ACK advertised the
    // kWireCapSnapshotBallTrailer capability bit.
    if (ball_entity != nullptr) {
        write_u16_le(p + 0, static_cast<std::uint16_t>(kBallRegionBytes));
        p += kSnapshotTrailerLenBytes;
        const EntityState& s = ball_entity->state;
        write_f32_le(p + 0,  s.position.x.toFloat());
        write_f32_le(p + 4,  s.position.y.toFloat());
        write_f32_le(p + 8,  s.position.z.toFloat());
        write_f32_le(p + 12, s.velocity.x.toFloat());
        write_f32_le(p + 16, s.velocity.y.toFloat());
        write_f32_le(p + 20, s.velocity.z.toFloat());
        // Ball spin (offset 24..27): reserved in Slice 15, always 0.
        write_f32_le(p + 24, 0.0f);
        // Ball owner slot (offset 28..29): kBallOwnerLoose until possession
        // is implemented in a later slice.
        write_u16_le(p + 28, kBallOwnerLoose);
        p += kBallRegionBytes;
    }

    return out;
}

// ---------------------------------------------------------------------------
// deserialize — malformed input returns a default-constructed Snapshot.
// Callers that need to distinguish "empty" from "malformed" must sanity-check
// bytes.size() up front (a valid empty SNAPSHOT is exactly 14 bytes).
// ---------------------------------------------------------------------------
Snapshot BinaryV1Serializer::deserialize(std::span<const std::uint8_t> bytes)
{
    Snapshot empty{};

    if (bytes.size() < kFrameHeaderBytes) { return empty; }

    const std::uint8_t*  data       = bytes.data();
    const std::uint8_t   version    = data[0];
    const std::uint8_t   msg_type   = data[1];
    const std::uint16_t  payload_sz = read_u16_le(data + 2);

    if (version  != kWireVersionV1)                         { return empty; }
    if (msg_type != static_cast<std::uint8_t>(MsgType::Snapshot)) { return empty; }
    if (bytes.size() != kFrameHeaderBytes + payload_sz)     { return empty; }
    if (payload_sz < kSnapshotHeaderBytes)                  { return empty; }

    const std::uint8_t* p = data + kFrameHeaderBytes;

    Snapshot snap;
    snap.tick          = static_cast<TickNum>(read_u32_le(p + 0));
    snap.match_time_ms = read_u32_le(p + 4);
    const std::uint16_t n = read_u16_le(p + 8);
    p += kSnapshotHeaderBytes;

    // Slice 15.4: payload_sz may be LARGER than header+entities to carry a
    // v1.1 trailer (ball region). It may not be smaller — that's malformed.
    const std::size_t entities_bytes = static_cast<std::size_t>(n) * kEntityRecordBytes;
    const std::size_t entities_end   = kSnapshotHeaderBytes + entities_bytes;
    if (payload_sz < entities_end) { return empty; }

    snap.entities.reserve(n);
    for (std::uint16_t i = 0; i < n; ++i) {
        SnapshotEntity e;
        EntityState&   s = e.state;

        s.slot_id  = SlotId{read_u16_le(p + 0)};
        // EntityId isn't on the wire (server-local); leave as default 0.
        // Downstream code should key by slot_id, not id, on the wire.
        s.id       = EntityId{0};

        const std::uint16_t flags = read_u16_le(p + 2);
        e.flags.human_controlled = (flags & kFlagHumanControlled) != 0;
        e.flags.is_ball          = (flags & kFlagIsBall)          != 0;
        e.flags.active           = (flags & kFlagActive)          != 0;

        s.position.x = math::Fixed64::fromFloat(read_f32_le(p + 4));
        s.position.y = math::Fixed64::fromFloat(read_f32_le(p + 8));
        s.position.z = math::Fixed64::fromFloat(read_f32_le(p + 12));
        s.velocity.x = math::Fixed64::fromFloat(read_f32_le(p + 16));
        s.velocity.y = math::Fixed64::fromFloat(read_f32_le(p + 20));
        s.velocity.z = math::Fixed64::zero();   // not on the wire (§7.2)
        s.heading    = math::Fixed64::fromFloat(read_f32_le(p + 24));

        const std::uint8_t motion_raw = p[28];
        // Unknown motion values fall back to Idle rather than corrupting
        // downstream code that switch()es on the enum.
        switch (motion_raw) {
            case 0: s.motion = MotionState::Idle;   break;
            case 1: s.motion = MotionState::Walk;   break;
            case 2: s.motion = MotionState::Jog;    break;
            case 3: s.motion = MotionState::Sprint; break;
            default: s.motion = MotionState::Idle;  break;
        }
        // p[29] reserved; ignored.

        snap.entities.push_back(e);
        p += kEntityRecordBytes;
    }

    // -- v1.1 trailer (§7.2 addendum, Slice 15.4) -------------------------
    //
    // If any bytes remain after the entities region, they must form a
    // well-formed [u16 trailer_len][trailer_len bytes] block. Backward-compat:
    // senders that emit no trailer produce zero remaining bytes and never
    // enter this branch.
    const std::size_t remaining = static_cast<std::size_t>(payload_sz) - entities_end;
    if (remaining == 0) {
        return snap;
    }
    if (remaining < kSnapshotTrailerLenBytes) { return empty; }
    const std::uint16_t trailer_len = read_u16_le(p);
    p += kSnapshotTrailerLenBytes;
    if (remaining != kSnapshotTrailerLenBytes + trailer_len) { return empty; }

    if (trailer_len == 0) {
        // "Trailer present but empty" — legal but wasteful; senders should
        // just omit the trailer. No ball to decode.
        return snap;
    }
    if (trailer_len < kBallRegionBytes) {
        // Trailer too short to hold a ball region — malformed for v1.1.
        return empty;
    }

    SnapshotEntity ball{};
    EntityState&   bs = ball.state;
    bs.id                        = EntityId{0};
    bs.slot_id                   = SlotId{0};    // Slice 15.2 convention: ball at slot 0
    bs.position.x                = math::Fixed64::fromFloat(read_f32_le(p + 0));
    bs.position.y                = math::Fixed64::fromFloat(read_f32_le(p + 4));
    bs.position.z                = math::Fixed64::fromFloat(read_f32_le(p + 8));
    bs.velocity.x                = math::Fixed64::fromFloat(read_f32_le(p + 12));
    bs.velocity.y                = math::Fixed64::fromFloat(read_f32_le(p + 16));
    bs.velocity.z                = math::Fixed64::fromFloat(read_f32_le(p + 20));
    // Bytes p+24..27 = ball spin: reserved in Slice 15, not surfaced in-memory.
    // Bytes p+28..29 = ball owner slot: reserved in Slice 15 (always kBallOwnerLoose).
    bs.heading                   = math::Fixed64::zero();
    bs.motion                    = MotionState::Idle;
    ball.flags.is_ball           = true;
    ball.flags.active            = true;
    ball.flags.human_controlled  = false;

    // Insert at index 0 to match Slice 15.2 in-memory shape (ball first,
    // then player entities in ascending slot_id).
    snap.entities.insert(snap.entities.begin(), ball);

    // Bytes [kBallRegionBytes .. trailer_len) are reserved for future ball
    // fields (e.g. spin_axis, temperature); v1.1 readers ignore them so a
    // v1.2 sender remains understandable.

    return snap;
}

} // namespace fh::sim::net
