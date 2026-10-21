// footballhome sim - ReceivingUnderPressureBehavior
//
// A lightweight M4 receiving-under-pressure behavior: when a defender is close
// to the carrier, this behavior pulls the supporting player off the crowded
// channel and toward a safer support lane.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class ReceivingUnderPressureBehavior final : public IBehavior {
public:
    ReceivingUnderPressureBehavior() noexcept = default;

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

    const char*            id() const override { return "receiving_under_pressure"; }
};

} // namespace fh::sim::behavior
