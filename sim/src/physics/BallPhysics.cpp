// footballhome sim - BallPhysics implementation

#include "physics/BallPhysics.hpp"

#include "math/Vec3.hpp"

namespace fh::sim::physics {

void tickBall(EntityState&        ball,
              const math::Fixed64 decay_per_tick,
              const math::Fixed64 rest_threshold,
              bool                skip_rest_snap) noexcept
{
    // 1) Multiplicative decay: v *= decay_per_tick, per axis. Direction
    //    is preserved because the same scalar multiplies every component.
    ball.velocity.x = ball.velocity.x * decay_per_tick;
    ball.velocity.y = ball.velocity.y * decay_per_tick;
    ball.velocity.z = ball.velocity.z * decay_per_tick;

    // 2) Snap to rest: if every component's magnitude is below the
    //    threshold, zero the whole velocity. Prevents infinite asymptotic
    //    decay bleeding sub-ULP jitter into replay hashes.
    //
    //    Slice 26.3: suppressed for `kKickAliveTicks` ticks after a
    //    kick so a slow pass doesn't get killed by the friction floor
    //    mid-flight. See kKickAliveTicks in the header for rationale.
    if (!skip_rest_snap &&
        math::fx_abs(ball.velocity.x) < rest_threshold &&
        math::fx_abs(ball.velocity.y) < rest_threshold &&
        math::fx_abs(ball.velocity.z) < rest_threshold) {
        ball.velocity = math::Vec3{};
    }
}

void applyImpulse(EntityState&      ball,
                  const math::Vec3& direction,
                  math::Fixed64     speed) noexcept
{
    // No-op guards — see header for the rationale. Neither branch
    // mutates ball.velocity, so callers can pass through zero-effect
    // impulses without special-casing them.
    if (speed == math::Fixed64::zero()) { return; }
    const math::Fixed64 len = direction.length();
    if (len == math::Fixed64::zero())   { return; }

    // Normalise + scale in one pass. Vec3::normalized() divides by
    // length; multiplying by speed then gives the requested magnitude
    // vector with the requested direction. We inline the division to
    // avoid an intermediate unit Vec3 (which would round twice under
    // Fixed64).
    const math::Fixed64 scale = speed / len;
    ball.velocity.x = direction.x * scale;
    ball.velocity.y = direction.y * scale;
    ball.velocity.z = direction.z * scale;
}

} // namespace fh::sim::physics
