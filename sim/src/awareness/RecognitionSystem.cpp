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
    // Slice 24.3b: identity copy through in M0. Future perception
    // milestones may fuzz/hide this if the perceiver hasn't seen the
    // last touch, but for M1 every player knows the current owner.
    view.ball_owner          = world.ball_owner;
    view.recognized_patterns.clear();
    return view;
}

} // namespace fh::sim::awareness
