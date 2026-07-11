// footballhome sim - Role enum
//
// Position/role hint attached to a Slot. Meaningless in M0 (empty pitch,
// no tactics). Real values come with M5 PressTrigger4v2 which assigns
// GK, LCB, RCB, CDM, ST9, ST10 to specific slots.
//
// See DESIGN.md §5.7, §16.

#pragma once

#include <cstdint>

namespace fh::sim {

enum class Role : std::uint8_t {
    // "Any" is the default for M0 slots on the empty pitch.
    Any  = 0,

    // Reserved. Populated in later milestones as scenarios need them.
    GK   = 1,
    LCB  = 2,
    RCB  = 3,
    CDM  = 4,
    ST9  = 5,
    ST10 = 6,
};

} // namespace fh::sim
