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

#include <optional>
#include <unordered_map>
#include <vector>

namespace fh::sim::awareness {

class RecognitionSystem {
public:
    RecognitionSystem() = default;

    // The registry is a non-owning reference. Passing an empty registry keeps
    // the identity-pass behavior for matches with no registered patterns.
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
    struct VelocitySample {
        TickNum    tick{0};
        math::Vec3 velocity{};
    };

    void updateCarrierHistory(const WorldView& world) const;
    bool carrierChangedDirectionRecently(const WorldView& world,
                                         const EntityState& carrier) const;
    bool shouldRecognizeBeingBeaten1v1(const WorldView& world,
                                       SlotId           self) const;

    const registry::PatternRegistry* patterns_{nullptr};
    mutable std::optional<TickNum> last_history_tick_{};
    mutable std::unordered_map<SlotId, std::vector<VelocitySample>> carrier_velocity_history_{};
    mutable std::optional<SlotId> changed_direction_carrier_{};
};

} // namespace fh::sim::awareness
