// footballhome sim - BallPhysics implementation

#include "physics/BallPhysics.hpp"

#include "math/Vec3.hpp"

namespace fh::sim::physics {

void tickBall(EntityState&        ball,
              const math::Fixed64 decay_per_tick,
              const math::Fixed64 rest_threshold) noexcept
{
    // 1) Multiplicative decay: v *= decay_per_tick, per axis. Direction
    //    is preserved because the same scalar multiplies every component.
    ball.velocity.x = ball.velocity.x * decay_per_tick;
    ball.velocity.y = ball.velocity.y * decay_per_tick;
    ball.velocity.z = ball.velocity.z * decay_per_tick;

    // 2) Snap to rest: if every component's magnitude is below the
    //    threshold, zero the whole velocity. Prevents infinite asymptotic
    //    decay bleeding sub-ULP jitter into replay hashes.
    if (math::fx_abs(ball.velocity.x) < rest_threshold &&
        math::fx_abs(ball.velocity.y) < rest_threshold &&
        math::fx_abs(ball.velocity.z) < rest_threshold) {
        ball.velocity = math::Vec3{};
    }
}

} // namespace fh::sim::physics
