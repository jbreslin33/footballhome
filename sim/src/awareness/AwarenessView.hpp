// footballhome sim - WorldView + AwarenessView
//
// Both live in the awareness/ directory because they are the boundary
// between ground-truth match state and what a controller is allowed to see.
//
// Rule (§16.5, enforced by check_no_floats.sh):
//   • WorldView is produced ONLY by sim/src/match/ (the tick loop).
//   • WorldView is consumed ONLY by sim/src/awareness/ (RecognitionSystem).
//   • Every controller and behavior takes AwarenessView, never WorldView.
//
// See DESIGN.md §5.4, §11, §14, §19.

#pragma once

#include "common/EntityState.hpp"
#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <optional>
#include <vector>

namespace fh::sim::awareness {

// Ground-truth snapshot for one tick. Produced by the match tick loop
// after Physics has run. Contains everything a fully-omniscient observer
// would know about the world this tick.
struct WorldView {
    TickNum                   tick{0};
    math::Fixed64             time_seconds{math::Fixed64::zero()};
    std::vector<EntityState>  entities;
    std::optional<EntityId>   ball;   // nullopt in M0 (no ball yet)
};

// What one specific player is aware of this tick. Produced from a WorldView
// by RecognitionSystem::apply(worldView, profile, self).
//
// M0: identity copy — every field mirrors WorldView, recognized_patterns is
//     always empty.
// M4+: entities may be filtered/decayed by perception attrs;
//      recognized_patterns is populated by rolling against
//      PlayerProfile.recognition.
struct AwarenessView {
    TickNum                   tick{0};
    math::Fixed64             time_seconds{math::Fixed64::zero()};
    std::vector<EntityState>  entities;
    std::optional<EntityId>   ball;
    std::vector<PatternId>    recognized_patterns;
};

} // namespace fh::sim::awareness
