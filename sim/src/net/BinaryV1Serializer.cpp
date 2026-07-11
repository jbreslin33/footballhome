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
    // Refuse to encode more entities than fit in the u16 payload cap. This
    // is a hard error, not a silent truncation — losing entities would be a
    // safety bug.
    if (snap.entities.size() > kMaxSnapshotEntities) {
        return {};
    }

    const std::size_t n = snap.entities.size();
    const std::size_t payload_bytes =
        kSnapshotHeaderBytes + n * kEntityRecordBytes;
    const std::size_t total_bytes = kFrameHeaderBytes + payload_bytes;

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
    write_u16_le(p + 8, static_cast<std::uint16_t>(n));
    p += kSnapshotHeaderBytes;

    // -- Entities (§7.2 record) -------------------------------------------
    for (std::size_t i = 0; i < n; ++i) {
        const SnapshotEntity& e = snap.entities[i];
        const EntityState&    s = e.state;

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

    // Reject partial / trailing junk. The frame's payload length must
    // exactly account for header + N entities.
    const std::size_t entities_bytes = static_cast<std::size_t>(n) * kEntityRecordBytes;
    if (payload_sz != kSnapshotHeaderBytes + entities_bytes) { return empty; }

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

    return snap;
}

} // namespace fh::sim::net
