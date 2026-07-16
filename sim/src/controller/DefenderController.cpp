// footballhome sim - DefenderController implementation

#include "controller/DefenderController.hpp"

#include "common/EntityState.hpp"

namespace fh::sim::controller {

Intent DefenderController::decide(const awareness::AwarenessView& view,
                                  SlotId self)
{
    // Find own position by slot_id. Defensive: if the match has not
    // yet spawned our entity (shouldn't happen mid-match), stand still.
    const math::Vec3* my_pos = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self) {
            my_pos = &e.position;
            break;
        }
    }
    if (my_pos == nullptr) { return idle(); }

    // Slice 24.3b (bug fix): if THIS slot already owns the ball, stop
    // chasing — the ball is glued kBallOwnerLeadDistance (0.4 m) ahead
    // of us in our heading direction, so any diff-toward-ball step
    // would just push us forward every tick and walk the ball straight
    // off the pitch. Hold position but KEEP wants_dribble asserted so
    // BallControl's Rule 2 retention still passes and we stay the
    // owner. wants_to_press is still asserted (harmless — the contest
    // step skips the current owner). A future slice can replace this
    // hold with a goalward-carry AI; the demo just needs "defender
    // steals, then stops" to be visible.
    if (view.ball_owner.has_value() && *view.ball_owner == self) {
        Intent hold;
        hold.desired_direction = math::Vec3{};   // idle motion
        hold.wants_dribble     = true;           // retain ownership
        hold.wants_to_press    = true;           // no-op while owner
        return hold;
    }

    // Find the ball entity. AwarenessView::ball holds the EntityId (not
    // the position) so we look it up in the entity list. When the
    // scenario has no ball (M0 empty pitch), just stand still — the
    // defender has nothing to chase.
    if (!view.ball.has_value()) { return idle(); }
    const EntityId ball_id = *view.ball;
    const math::Vec3* ball_pos = nullptr;
    for (const auto& e : view.entities) {
        if (e.id == ball_id) {
            ball_pos = &e.position;
            break;
        }
    }
    if (ball_pos == nullptr) { return idle(); }

    // Jog toward the ball. No sprint / walk / dribble flags: mechanics
    // defaults to jog when all three are zero, which is the right
    // baseline pace for a Slice 24.3a demo. Slice 24.3b will add a
    // sprint-when-far-behind branch; 24.3c will add a contest bit.
    const math::Vec3 diff{
        ball_pos->x - my_pos->x,
        ball_pos->y - my_pos->y,
        math::Fixed64::zero()};
    const math::Fixed64 dist = diff.length();
    if (dist == math::Fixed64::zero()) {
        // Standing exactly on the ball — no direction to compute.
        // Mechanics interprets zero desired_direction as "idle" so the
        // defender doesn't jitter over the ball.
        return idle();
    }

    Intent intent;
    intent.desired_direction = diff.normalized();
    // Slice 24.3b: assert BOTH wants_dribble and wants_to_press. The
    // press bit shrinks the current owner's Rule-2 retention radius;
    // the dribble bit makes this slot a Rule-1 candidate so that
    // *when* the owner is pressed off the ball, this closer slot wins
    // the first-touch scramble in the same tick — the "strip" is the
    // emergent composition of those two rules, not a bespoke opcode.
    // Setting them unconditionally is safe: BallControl only cares
    // about wants_dribble within kBallControlRadius of the ball and
    // wants_to_press within kContestRadius, so a defender jogging in
    // from 5 m away is inert until they're actually in range.
    intent.wants_dribble     = true;
    intent.wants_to_press    = true;
    return intent;
}

} // namespace fh::sim::controller
