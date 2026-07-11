// footballhome sim - RecognitionSystem implementation
//
// M0: identity pass-through. See RecognitionSystem.hpp.

#include "awareness/RecognitionSystem.hpp"

namespace fh::sim::awareness {

AwarenessView RecognitionSystem::apply(const WorldView&              world,
                                       const profile::PlayerProfile& perceiver,
                                       SlotId                        self) const
{
    // In M0 the perceiver profile and slot are not consulted — every player
    // sees every entity with perfect fidelity. These params are unused now
    // and heavily used in M4+.
    (void)perceiver;
    (void)self;
    (void)patterns_;

    AwarenessView view;
    view.tick                = world.tick;
    view.time_seconds        = world.time_seconds;
    view.entities            = world.entities;
    view.ball                = world.ball;
    view.recognized_patterns.clear();
    return view;
}

} // namespace fh::sim::awareness
