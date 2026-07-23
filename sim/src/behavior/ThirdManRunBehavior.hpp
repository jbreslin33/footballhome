// footballhome sim - ThirdManRunBehavior
//
// A lightweight M4 third-man-run behavior: when a teammate is between the
// carrier and a deeper option, this behavior pulls the supporting player into
// the third-man channel for a deeper support run.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class ThirdManRunBehavior final : public IBehavior {
public:
    ThirdManRunBehavior() noexcept = default;

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

    const char*            id() const override { return "third_man_run"; }
};

} // namespace fh::sim::behavior
