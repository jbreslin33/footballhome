// footballhome sim - Snapshot
//
// One tick of match state, in a form suitable for wire serialisation.
// This is the server-side data structure; BinaryV1Serializer (added in the
// networking slice) converts Fixed64 → f32 per §7.2 as it emits bytes.
//
// See DESIGN.md §5.7, §7.2.

#pragma once

#include "common/EntityState.hpp"
#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstdint>
#include <vector>

namespace fh::sim::match {

// Per-entity flags matching §7.2 wire record.
struct EntityFlags {
    bool human_controlled{false};
    bool is_ball{false};
    bool active{true};

    // Pack to the u16 the wire expects.
    std::uint16_t toU16() const noexcept {
        std::uint16_t v = 0;
        if (human_controlled) { v |= (std::uint16_t{1} << 0); }
        if (is_ball)          { v |= (std::uint16_t{1} << 1); }
        if (active)           { v |= (std::uint16_t{1} << 2); }
        return v;
    }
};

struct SnapshotEntity {
    EntityState  state;      // includes id, slot_id, pos, vel, heading, motion
    EntityFlags  flags;
};

struct Snapshot {
    TickNum                       tick{0};
    // Match time in milliseconds since tick 0. Fits u32 easily (90 min = 5.4M).
    std::uint32_t                 match_time_ms{0};
    std::vector<SnapshotEntity>   entities;   // sorted by slot_id ascending
};

} // namespace fh::sim::match
