// footballhome sim - PursueBallCarrierBehavior
//
// Slice 30.2: first concrete IBehavior. Behavior-side reimplementation
// of the M2 DefenderController — pure pursuit with owner-hold, gated
// by the `pressing` M3 concept (id=3, migration 224).
//
// Zero RNG consumption (matches DefenderController's contract). All
// four branches of DefenderController::decide() are replicated inside
// execute() so the pursue demo is intent-identical at the spec level
// even though the dispatch path (AiController::decide() → this
// behavior's utility() then execute()) has one extra virtual call
// than the old direct IPlayerController::decide() path.
//
// utility() returns Fixed64::one() unconditionally in Slice 30.2 —
// the M3 opening bag is single-behavior, so magnitude is unobservable
// (AiController::decide() picks the sole non-abstaining champion via
// strict > argmax; a single entry with utility=1 always wins over the
// implicit zero-utility idle fallback). The `1 / distance_to_ball`
// utility shape from the original §25.2 draft is deferred to Slice
// 31.4, when JockeyBehavior first competes with pursue for the same
// tick and utility magnitude first becomes observable.
//
// See DESIGN.md §25.2 debug-replay bullet 4 + §25.3 Slice 30.2.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class PursueBallCarrierBehavior final : public IBehavior {
public:
    PursueBallCarrierBehavior() noexcept = default;

    std::vector<ConceptId> requiredConcepts() const override;
    math::Fixed64          minMastery() const override;

    math::Fixed64          utility(const awareness::AwarenessView& view,
                                   SlotId                          self,
                                   const profile::ConceptSet&      concepts) override;

    controller::Intent     execute(const awareness::AwarenessView& view,
                                   SlotId                          self,
                                   const profile::ConceptSet&      concepts) override;

    const char*            id() const override { return "pursue_ball_carrier"; }
};

} // namespace fh::sim::behavior
