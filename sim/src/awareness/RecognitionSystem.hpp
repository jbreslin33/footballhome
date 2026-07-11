// footballhome sim - RecognitionSystem
//
// The Recognition phase of the tick loop. Runs between Physics and
// Decision, producing one AwarenessView per player from the shared
// WorldView plus that player's PlayerProfile.
//
// M0 behavior: identity pass-through. WorldView fields are copied into
// AwarenessView; recognized_patterns is empty.
//
// M4+ behavior: this is where perception attrs (scan_rate, focus,
// anticipation) narrow the entity view, and where RNG-driven rolls against
// PlayerProfile.recognition populate recognized_patterns.
//
// Wiring this class in from day 1 keeps every controller signature stable
// across milestones.
//
// See DESIGN.md §5.4, §11, §14, §16.1, §16.5.

#pragma once

#include "awareness/AwarenessView.hpp"
#include "common/IdTypes.hpp"
#include "profile/PlayerProfile.hpp"
#include "registry/PatternRegistry.hpp"

namespace fh::sim::awareness {

class RecognitionSystem {
public:
    RecognitionSystem() = default;

    // The registry is a non-owning reference kept for M4+; M0 does not use
    // it. Passing an empty registry is the intended M0 configuration.
    explicit RecognitionSystem(const registry::PatternRegistry& patterns) noexcept
        : patterns_(&patterns)
    {}

    // Produce an AwarenessView for the player occupying `self` from the
    // shared WorldView, filtering by the perceiver's PlayerProfile.
    //
    // M0: identity copy.
    // M4+: subject to perception attrs + recognition rolls.
    AwarenessView apply(const WorldView&                world,
                        const profile::PlayerProfile&   perceiver,
                        SlotId                          self) const;

private:
    const registry::PatternRegistry* patterns_{nullptr};
};

} // namespace fh::sim::awareness
