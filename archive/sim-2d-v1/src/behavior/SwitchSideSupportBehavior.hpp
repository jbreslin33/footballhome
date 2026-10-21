// footballhome sim - SwitchSideSupportBehavior
//
// A lightweight M4 switch-side support behavior: when a teammate is already
// sitting on one side of a ball-carrying player, this behavior pulls the
// supporting player to the opposite side to create a switch option.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class SwitchSideSupportBehavior final : public IBehavior {
public:
    SwitchSideSupportBehavior() noexcept = default;

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

    const char*            id() const override { return "switch_side_support"; }
};

} // namespace fh::sim::behavior
