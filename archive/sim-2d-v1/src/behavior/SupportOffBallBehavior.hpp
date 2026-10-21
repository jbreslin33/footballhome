// footballhome sim - SupportOffBallBehavior
//
// First M4 positioning behavior: an off-ball support posture that moves to a
// small offset behind the ball carrier so the player can offer a passing lane
// or second option without committing to a press or dribble.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class SupportOffBallBehavior final : public IBehavior {
public:
    SupportOffBallBehavior() noexcept = default;

    std::vector<ConceptId> requiredConcepts() const override;
    math::Fixed64          minMastery() const override;

    math::Fixed64          utility(const awareness::AwarenessView& view,
                                   SlotId                          self,
                                   const profile::ConceptSet&      concepts,
                                   const profile::AttributeSet&    technical,
                                   const profile::AttributeSet&    mental,
                                   std::optional<SlotId>           mark_target) override;

    controller::Intent     execute(const awareness::AwarenessView& view,
                                   SlotId                          self,
                                   const profile::ConceptSet&      concepts,
                                   std::optional<SlotId>           mark_target = std::nullopt) override;

    const char*            id() const override { return "support_off_ball"; }
};

} // namespace fh::sim::behavior
