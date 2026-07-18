// footballhome sim - AiController implementation
//
// Utility-AI dispatch (Slice 30.1). Iterates the behavior bag, filters
// by concept-gate, argmax over utility, dispatches execute() on the
// winner. Empty bag ⇒ idle() (backward-compatible with the M0 skeleton
// and with every pre-Slice-30.1 test that constructed AiController via
// the two-arg ctor).
//
// See DESIGN.md §5.4, §5.5, §25.3 Slice 30.1.

#include "controller/AiController.hpp"

#include "behavior/IBehavior.hpp"
#include "behavior/JockeyBehavior.hpp"
#include "behavior/MarkOpponentBehavior.hpp"
#include "behavior/PursueBallCarrierBehavior.hpp"
#include "math/Fixed64.hpp"

namespace fh::sim::controller {

Intent AiController::decide(const awareness::AwarenessView& view, SlotId self)
{
    // Fast path: empty bag. Preserves M0 skeleton behavior byte-for-byte.
    if (behaviors_.empty()) {
        return idle();
    }

    // Argmax over gated behaviors. `best` is nullptr until we see the
    // first behavior whose gate passes AND whose utility strictly beats
    // the current champion — the strict `>` preserves insertion-order
    // tie-breaking (first behavior in the bag wins any tie), which is
    // the determinism contract documented in §25.2 and the AiController
    // header.
    behavior::IBehavior* best       = nullptr;
    math::Fixed64        best_score = math::Fixed64::zero();

    for (const auto& b : behaviors_) {
        // Concept gate: every required concept must be plugged in the
        // slot's ConceptSet at or above the behavior's minMastery
        // threshold. Absent concepts return level == 0 per ConceptSet
        // contract, so an absent required concept fails the gate at
        // any positive minMastery. minMastery == 0 gates on presence
        // + any positive mastery via ConceptSet::has (matches the
        // §25.2 PursueBallCarrierBehavior spec: minMastery = 0.0
        // means "any positive value opens the gate").
        const math::Fixed64 min_mastery = b->minMastery();
        bool gated_open = true;
        for (const ConceptId cid : b->requiredConcepts()) {
            if (!concepts_.has(cid, min_mastery)) {
                gated_open = false;
                break;
            }
        }
        if (!gated_open) {
            continue;
        }

        const math::Fixed64 score = b->utility(
            view, self, concepts_, technical_, mental_, mark_target_);

        // Zero-utility behaviors abstain (per IBehavior::utility contract).
        // First survivor becomes champion; subsequent survivors must
        // strictly exceed the current champion's score.
        if (best == nullptr) {
            if (score > math::Fixed64::zero()) {
                best       = b.get();
                best_score = score;
            }
        } else if (score > best_score) {
            best       = b.get();
            best_score = score;
        }
    }

    if (best == nullptr) {
        return idle();
    }
    return best->execute(view, self, concepts_, mark_target_);
}

std::vector<std::unique_ptr<behavior::IBehavior>>
AiController::defaultBehaviors(Role role)
{
    // Behavior bags grow slice-by-slice; the switch is exhaustive so a
    // reviewer can see at a glance which roles have real bags today
    // and which are still empty placeholders for later milestones.
    //   Slice 30.2 — temporary Role::Any bridge → {PursueBallCarrierBehavior}
    //                while all scenarios still spawned Role::Any slots.
    //   Slice 31.2 — JockeyBehavior and MarkOpponentBehavior skeletons added.
    //   Slice 31.4 — concrete defensive roles own the defender bag; Role::Any
    //                reverts to an empty placeholder.
    //   Slice 33.2 — Feint1v1Behavior added under an attacker role.
    std::vector<std::unique_ptr<behavior::IBehavior>> bag;
    switch (role) {
        case Role::Any:
        case Role::GK:
            return bag;   // empty — reserved for later milestones
        case Role::LCB:
        case Role::RCB:
        case Role::CDM:
            bag.push_back(std::make_unique<behavior::PursueBallCarrierBehavior>());
            bag.push_back(std::make_unique<behavior::JockeyBehavior>());
            bag.push_back(std::make_unique<behavior::MarkOpponentBehavior>());
            return bag;
        case Role::ST9:
        case Role::ST10:
            return bag;   // empty — reserved for later milestones
    }
    return bag;
}

} // namespace fh::sim::controller
