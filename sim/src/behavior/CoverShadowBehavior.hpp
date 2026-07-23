// footballhome sim - CoverShadowBehavior
//
// A simple M4 cover-shadow behavior: when a teammate is carrying the ball and
// an opponent is threatening their passing lane, this behavior moves to a
// midpoint between the carrier and the nearest danger player so the support
// receiver can still offer a safe option.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class CoverShadowBehavior final : public IBehavior {
public:
    CoverShadowBehavior() noexcept = default;

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

    const char*            id() const override { return "cover_shadow"; }
};

} // namespace fh::sim::behavior
