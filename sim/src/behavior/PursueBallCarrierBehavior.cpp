// footballhome sim - PursueBallCarrierBehavior implementation
//
// See PursueBallCarrierBehavior.hpp for the interface contract and
// DESIGN.md §25.3 Slice 30.2 for the migration path from the
// hand-rolled DefenderController.

#include "behavior/PursueBallCarrierBehavior.hpp"

#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"

namespace fh::sim::behavior {

std::vector<ConceptId> PursueBallCarrierBehavior::requiredConcepts() const
{
    return {m0::kPressing};
}

math::Fixed64 PursueBallCarrierBehavior::minMastery() const
{
    // Presence-gated: any value ≥ 0 opens the gate provided the
    // concept is present in the ConceptSet. ConceptSet::has(id, min)
    // returns false when the concept is absent regardless of min, so
    // the actual gating happens at the "did the scenario plug this
    // concept for this slot?" layer (Scenario::applyConceptOverrides).
    return math::Fixed64::zero();
}

math::Fixed64 PursueBallCarrierBehavior::utility(
    const awareness::AwarenessView& /*view*/,
    SlotId                          /*self*/,
    const profile::ConceptSet&      /*concepts*/,
    const profile::AttributeSet&    /*technical*/,
    const profile::AttributeSet&    /*mental*/)
{
    // Constant 1.0 in Slice 30.2 — the M3 opening bag is single-behavior,
    // so magnitude is unobservable (see class comment).
    return math::Fixed64::one();
}

controller::Intent PursueBallCarrierBehavior::execute(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/)
{
    // Branch 1: THIS slot already owns the ball. Hold position with
    // wants_dribble asserted so BallControl's Rule 2 retention still
    // passes and we stay the owner. Mirrors the Slice 24.3b bug fix
    // in DefenderController — a diff-toward-ball step would push us
    // forward every tick and walk the ball straight off the pitch
    // because the ball is glued kBallOwnerLeadDistance (0.4 m) ahead
    // of the owner in the heading direction.
    if (view.ball_owner.has_value() && *view.ball_owner == self) {
        controller::Intent hold;
        hold.desired_direction = math::Vec3{};   // idle motion
        hold.wants_dribble     = true;           // retain ownership
        hold.wants_to_press    = true;           // no-op while owner
        return hold;
    }

    // Branch 2: scenario has no ball (empty pitch etc.) — nothing to
    // chase, so idle.
    if (!view.ball.has_value()) { return controller::idle(); }

    // Locate own entity by slot_id. Defensive: mid-match we might be
    // called before the entity spawns; stand still if so.
    const math::Vec3* my_pos = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self) {
            my_pos = &e.position;
            break;
        }
    }
    if (my_pos == nullptr) { return controller::idle(); }

    // Branch 3: ball_id is set but entity is missing from the view
    // (should not happen in normal play — Match keeps them in sync).
    // Defensive idle.
    const EntityId ball_id = *view.ball;
    const math::Vec3* ball_pos = nullptr;
    for (const auto& e : view.entities) {
        if (e.id == ball_id) {
            ball_pos = &e.position;
            break;
        }
    }
    if (ball_pos == nullptr) { return controller::idle(); }

    // Branch 4: standing exactly on the ball — no direction to
    // compute. Idle rather than emit a zero-length desired_direction
    // that mechanics might interpret as jitter.
    const math::Vec3 diff{
        ball_pos->x - my_pos->x,
        ball_pos->y - my_pos->y,
        math::Fixed64::zero()};
    const math::Fixed64 dist = diff.length();
    if (dist == math::Fixed64::zero()) {
        return controller::idle();
    }

    // Branch 5 (main path): jog toward the ball. Match Slice 24.3b's
    // DefenderController semantics — assert BOTH wants_dribble and
    // wants_to_press unconditionally. BallControl only cares about
    // wants_dribble within kBallControlRadius of the ball and
    // wants_to_press within kContestRadius, so a defender jogging in
    // from 5 m away is inert until they're actually in range; the
    // press is what shrinks the current owner's Rule-2 retention
    // radius, and the dribble bit makes this slot a Rule-1 candidate
    // for the same-tick first-touch scramble when the owner is
    // pressed off the ball.
    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    intent.wants_dribble     = true;
    intent.wants_to_press    = true;
    return intent;
}

} // namespace fh::sim::behavior
