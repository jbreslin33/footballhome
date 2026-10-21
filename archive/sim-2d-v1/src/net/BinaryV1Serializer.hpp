// footballhome sim - fh-sim.v1 SNAPSHOT serializer
//
// Wire format is fully specified in DESIGN.md §7.2. This file's only job
// is to move bytes between that spec and match::Snapshot.

#pragma once

#include "net/ISnapshotSerializer.hpp"

namespace fh::sim::net {

class BinaryV1Serializer final : public ISnapshotSerializer {
public:
    BinaryV1Serializer() = default;

    std::vector<std::uint8_t> serialize(const match::Snapshot& snap) override;
    match::Snapshot           deserialize(std::span<const std::uint8_t> bytes) override;

    const char* wireId() const noexcept override { return "fh-sim.v1"; }
};

} // namespace fh::sim::net
