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
    return intent;
}

} // namespace fh::sim::controller
