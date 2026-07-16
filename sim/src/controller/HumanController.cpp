// footballhome sim - HumanController implementation

#include "controller/HumanController.hpp"

#include "awareness/AwarenessView.hpp"
#include "common/EntityState.hpp"

namespace fh::sim::controller {

namespace {

// Return a pointer to the entity whose EntityId matches `id` in the
// awareness view's `entities` list, or nullptr if none. The list is
// sorted ascending by EntityId (see Match::buildWorldView) but we do
// a linear scan — M1 slot counts (< 32) make binary search noise.
const EntityState* findEntityById(const awareness::AwarenessView& view,
                                  EntityId id) noexcept
{
    for (const auto& e : view.entities) {
        if (e.id == id) { return &e; }
    }
    return nullptr;
}

// Return a pointer to the entity whose SlotId matches `slot` — that's the
// controller's own body. Same rationale as above for the linear scan.
const EntityState* findEntityBySlot(const awareness::AwarenessView& view,
                                    SlotId slot) noexcept
{
    for (const auto& e : view.entities) {
        if (e.slot_id == slot) { return &e; }
    }
    return nullptr;
}

// Slice 16.2: XY horizontal distance-squared between two positions,
// returned as Fixed64. Used against kBallAutoDribbleRadius² to avoid
// a sqrt in the hot path.
math::Fixed64 distSqXY(const math::Vec3& a, const math::Vec3& b) noexcept
{
    const math::Fixed64 dx = a.x - b.x;
    const math::Fixed64 dy = a.y - b.y;
    return dx * dx + dy * dy;
}

} // namespace

Intent HumanController::decide(const awareness::AwarenessView& view,
                               SlotId self)
{
    // Start from the latest wire-driven Intent (joystick + explicit
    // wants_* flags). Then OR-augment wants_dribble on top based on
    // ball proximity — this is what makes joystick-only clients able
    // to dribble without a dedicated button (§23.3 Slice 16.2).
    Intent out = latest_;

    // Auto-dribble hint: if there IS a ball in the awareness view AND
    // both self and the ball resolve to entities AND self is within
    // kBallAutoDribbleRadius (horizontally), suggest wants_dribble.
    // BallControl (Slice 16.3) is still the sole authority on who
    // actually owns the ball each tick — this only sets the *hint*.
    //
    // Slice 16.4: the auto-hint is SUPPRESSED when the client
    // explicitly signals wants_release. Otherwise a human who's
    // standing on top of a loose (or their own) ball would never be
    // able to let go — the auto-hint would re-set wants_dribble every
    // tick. The explicit release bit is the escape hatch.
    if (view.ball.has_value() && !out.wants_release) {
        const EntityState* self_state = findEntityBySlot(view, self);
        const EntityState* ball_state = findEntityById(view, *view.ball);
        if (self_state != nullptr && ball_state != nullptr) {
            const math::Fixed64 d2 = distSqXY(self_state->position,
                                              ball_state->position);
            const math::Fixed64 r2 = kBallAutoDribbleRadius
                                   * kBallAutoDribbleRadius;
            if (d2 <= r2) { out.wants_dribble = true; }
        }
    }

    // Slice 16.4: release ALWAYS wins over wants_dribble, whether the
    // dribble bit was set by the wire or by the auto-hint above.
    // Collapsing to wants_dribble=false here means BallControl's Rule
    // 2 (owner retention) fails naturally with no BallControl-side
    // awareness of the release bit needed.
    if (out.wants_release) {
        out.wants_dribble = false;
    }

    // Slice 24.3b: symmetric wants_to_press auto-hint. Humans should
    // be able to steal from an AI dribbler without a dedicated button;
    // mirror DefenderController's unconditional press assertion so the
    // BallControl contest step will consider us when we get within
    // kContestRadius (0.7 m) of an opponent-owned ball. The contest
    // step skips the current owner, so setting this on a slot that
    // already owns the ball is a no-op. Suppressed on wants_release
    // for the same reason as wants_dribble — if the client is asking
    // to let go, don't fight to take it back the same tick.
    if (!out.wants_release) {
        out.wants_to_press = true;
    }

    return out;
}

} // namespace fh::sim::controller
