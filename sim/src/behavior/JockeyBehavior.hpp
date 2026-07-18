// footballhome sim - JockeyBehavior
//
// Slice 31.2 opening skeleton: concept-gated defensive jockey posture.
// This behavior moves toward the current ball carrier without asserting
// dribble or press, so it positions but does not commit to a tackle.

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
                                   const profile::AttributeSet&    mental) override;

    controller::Intent     execute(const awareness::AwarenessView& view,
                                   SlotId                          self,
                                   const profile::ConceptSet&      concepts) override;

    const char*            id() const override { return "jockey"; }
};

} // namespace fh::sim::behavior