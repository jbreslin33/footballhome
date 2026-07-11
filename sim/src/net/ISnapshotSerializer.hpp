// footballhome sim - Snapshot serializer interface
//
// A serializer converts a server-side `match::Snapshot` (all Fixed64) into
// the wire bytes the client actually receives, and back. This is one of the
// two documented boundaries at which Fixed64 crosses into f32 (§7). Every
// non-boundary layer stays 100% deterministic; drift here just affects
// rendered pixels, not sim replay.
//
// M0 has exactly one implementation: BinaryV1Serializer (fh-sim.v1).
//
// See DESIGN.md §5.5, §7.

#pragma once

#include "match/Snapshot.hpp"

#include <cstdint>
#include <span>
#include <vector>

namespace fh::sim::net {

class ISnapshotSerializer {
public:
    virtual ~ISnapshotSerializer() = default;

    // Encode a Snapshot as a fully-framed message (includes the 4-byte
    // wire header). Return value is what goes directly on the transport.
    // Never throws; returns an empty vector if the snapshot exceeds the
    // wire-encodable size (u16 payload cap).
    virtual std::vector<std::uint8_t> serialize(const match::Snapshot& snap) = 0;

    // Decode a fully-framed SNAPSHOT message. Malformed / truncated / wrong
    // wire-version / wrong msg-type input returns a default-constructed
    // Snapshot (tick == 0, entities empty). Callers who need to distinguish
    // "empty snapshot" from "decode failure" should check `bytes.size()`
    // first — a valid empty SNAPSHOT is exactly 14 bytes.
    virtual match::Snapshot deserialize(std::span<const std::uint8_t> bytes) = 0;

    // Wire identifier for logging & multi-version negotiation.
    virtual const char* wireId() const noexcept = 0;
};

} // namespace fh::sim::net
