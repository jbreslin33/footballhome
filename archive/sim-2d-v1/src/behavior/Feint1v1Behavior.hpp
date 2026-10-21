// footballhome sim - Feint1v1Behavior
//
// Concept-gated attacker behavior. When the ball carrier faces one nearby
// defender, this behavior prefers a lateral dribble away from the defender.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class Feint1v1Behavior final : public IBehavior {
public:
    Feint1v1Behavior() noexcept = default;

    std::vector<ConceptId> requiredConcepts() const override;
    math::Fixed64          minMastery() const override;
    TickNum                minTicks() const override { return TickNum{8}; }

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

    const char*            id() const override { return "feint_1v1"; }

private:
    std::optional<TickNum> next_feint_tick_{};
};

} // namespace fh::sim::behavior
