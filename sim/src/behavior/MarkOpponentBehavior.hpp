// footballhome sim - MarkOpponentBehavior

#pragma once

#include "behavior/IBehavior.hpp"

namespace fh::sim::behavior {

class MarkOpponentBehavior final : public IBehavior {
public:
    MarkOpponentBehavior() noexcept = default;

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

    const char*            id() const override { return "mark_opponent"; }
};

} // namespace fh::sim::behavior