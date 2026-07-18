// footballhome sim - JockeyBehavior
//
// Concept-gated defensive jockey posture. The behavior positions near the
// current ball carrier without asserting dribble or press, so it contains
// the carrier but does not commit to a tackle.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class JockeyBehavior final : public IBehavior {
public:
    JockeyBehavior() noexcept = default;

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

    const char*            id() const override { return "jockey"; }
};

} // namespace fh::sim::behavior