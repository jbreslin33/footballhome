// footballhome sim - OverloadSupportBehavior
//
// A lightweight M4 overload-support behavior: when a teammate and a defender
// create a 2v1 or 2v2 overload on one side of the play, this behavior pulls
// the supporting player toward the free side of the overload.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class OverloadSupportBehavior final : public IBehavior {
public:
    OverloadSupportBehavior() noexcept = default;

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

    const char*            id() const override { return "overload_support"; }
};

} // namespace fh::sim::behavior
