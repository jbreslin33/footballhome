// footballhome sim - EntityState
//
// Shared struct describing the deterministic state of a single entity at one
// tick. Produced by IPhysicsWorld, consumed by WorldView/AwarenessView.
//
// See DESIGN.md §5.3, §5.4.

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>

namespace fh::sim {

// Motion state bucket (matches wire byte value in the snapshot record, §7).
enum class MotionState : std::uint8_t {
    Idle   = 0,
    Walk   = 1,
    Jog    = 2,
    Sprint = 3,
};

struct EntityState {
    EntityId    id{0};
    // Scenario slot occupied by this entity. 0 = ball or unassigned;
    // 1..N = player slot. Kept here (not just in Match) so any WorldView
    // consumer — including controllers via AwarenessView — can locate
    // itself and its teammates by slot without a side-table lookup.
    // Matches the u16 slot_id in the wire snapshot record (§7.2).
    SlotId      slot_id{0};
    math::Vec3  position{};
    math::Vec3  velocity{};
    math::Fixed64 heading{math::Fixed64::zero()};   // radians
    MotionState motion{MotionState::Idle};
};

} // namespace fh::sim
