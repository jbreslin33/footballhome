// footballhome sim - IBehavior
//
// Behaviors are the utility-AI building blocks that AiController scores and
// executes. Each behavior declares which ConceptIds it requires and what
// minimum mastery gates it; a behavior whose gate is not satisfied by the
// slot's ConceptSet is skipped entirely.
//
// No concrete behaviors exist in M0 — the interface lives here so future
// milestones plug into an already-stable header.
//
// See DESIGN.md §5.5.

#pragma once

#include "awareness/AwarenessView.hpp"
#include "common/IdTypes.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"

#include <optional>
#include <vector>

namespace fh::sim::behavior {

class IBehavior {
public:
    virtual ~IBehavior() = default;

    // Concepts this behavior needs plugged into the slot's ConceptSet.
    virtual std::vector<ConceptId> requiredConcepts() const = 0;

    // Minimum mastery on each required concept for the gate to open.
    virtual math::Fixed64 minMastery() const = 0;

    // Higher score wins in utility-AI selection. Return zero to abstain.
    virtual math::Fixed64 utility(const awareness::AwarenessView& view,
                                  SlotId                          self,
                                  const profile::ConceptSet&      concepts,
                                  const profile::AttributeSet&    technical,
                                const profile::AttributeSet&    mental,
                                std::optional<SlotId>           mark_target) = 0;

    // Produce this tick's Intent when this behavior is selected.
    virtual controller::Intent execute(const awareness::AwarenessView& view,
                                       SlotId                          self,
                                    const profile::ConceptSet&      concepts,
                                    std::optional<SlotId>           mark_target) = 0;

    // Stable identifier for logs (e.g. "mark_opponent", "cover_shadow").
    virtual const char* id() const = 0;
};

} // namespace fh::sim::behavior
