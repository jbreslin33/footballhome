// footballhome sim - WanderController implementation

#include "controller/WanderController.hpp"

#include "math/FixedMath.hpp"

namespace fh::sim::controller {

WanderController::WanderController(math::Fixed64 pitch_length_m,
                                   math::Fixed64 pitch_width_m,
                                   math::RngDet* rng,
                                   math::Fixed64 close_thresh_m,
                                   math::Fixed64 min_dwell_s,
                                   math::Fixed64 max_dwell_s) noexcept
    : pitch_length_(pitch_length_m)
    , pitch_width_(pitch_width_m)
    , rng_(rng)
    , close_thresh_(close_thresh_m)
    , min_dwell_(min_dwell_s)
    , dwell_range_(max_dwell_s - min_dwell_s)
{
}

void WanderController::pickNewTarget(math::Fixed64 now_seconds)
{
    // Pitch origin is at centre (§9). Uniform in x ∈ [-L/2, L/2], y ∈ [-W/2, W/2].
    const math::Fixed64 half_length = pitch_length_ * math::Fixed64::halfConst();
    const math::Fixed64 half_width  = pitch_width_  * math::Fixed64::halfConst();

    target_.x = rng_->nextRange(math::Fixed64::zero() - half_length, half_length);
    target_.y = rng_->nextRange(math::Fixed64::zero() - half_width,  half_width);
    target_.z = math::Fixed64::zero();

    const math::Fixed64 dwell = min_dwell_ + rng_->nextUnit() * dwell_range_;
    choose_new_target_at_     = now_seconds + dwell;
    initialised_              = true;
}

Intent WanderController::decide(const awareness::AwarenessView& view,
                                SlotId self)
{
    // Locate this controller's own entity by slot_id.
    const math::Vec3* my_pos = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self) {
            my_pos = &e.position;
            break;
        }
    }
    if (my_pos == nullptr) {
        // No entity for this slot yet (shouldn't happen mid-match, but be
        // defensive). Stand still.
        return idle();
    }

    // Time-based OR distance-based re-target. First tick always re-targets
    // because initialised_ starts false.
    const math::Vec3 diff{
        target_.x - my_pos->x,
        target_.y - my_pos->y,
        math::Fixed64::zero()};
    const math::Fixed64 dist         = diff.length();
    const bool         reached       = initialised_ && dist <= close_thresh_;
    const bool         timer_expired = view.time_seconds >= choose_new_target_at_;

    if (!initialised_ || reached || timer_expired) {
        pickNewTarget(view.time_seconds);
        // Recompute diff to the fresh target.
        const math::Vec3 diff2{
            target_.x - my_pos->x,
            target_.y - my_pos->y,
            math::Fixed64::zero()};
        Intent intent;
        intent.desired_direction = diff2.normalized();
        // Wander is a jog (no walk/sprint flags → mechanics defaults to jog).
        return intent;
    }

    Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::controller
