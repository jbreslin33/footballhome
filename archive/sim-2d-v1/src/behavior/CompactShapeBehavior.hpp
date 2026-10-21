// footballhome sim - CompactShapeBehavior
//
// A lightweight M4 compact-shape behavior: when a ball-carrying teammate is
// isolated, this behavior pulls the supporting player toward a compact
// centroid so the attack stays connected and less vulnerable to a counter.

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class CompactShapeBehavior final : public IBehavior {
public:
    CompactShapeBehavior() noexcept = default;

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

    const char*            id() const override { return "compact_shape"; }
};

} // namespace fh::sim::behavior
