// footballhome sim - BallPhysics
//
// Passive ball dynamics: multiplicative velocity decay ("rolling friction"
// proxy) each tick, snap-to-rest below a threshold to avoid infinite
// asymptotic decay under Fixed64 truncation.
//
// Does NOT integrate position — caller's IPhysicsWorld::step() handles
// that. Same shape as Mechanics::applyIntent: pure function of inputs,
// writes new velocity back to the entity, leaves position alone. Match's
// tick loop calls BallPhysics::tick(ball) before physics_->step(dt) so the
// friction-damped velocity is what gets integrated this tick.
//
// The friction model is intentionally NOT µ×g×dt linear friction: linear
// friction on Fixed64 requires either a magnitude (sqrt, non-deterministic
// across compiler LUTs) or a per-axis approximation that breaks direction
// preservation off-axis. Multiplicative decay is direction-preserving,
// deterministic, and captures the "rolls, decelerates, stops" feel we
// need for M1 arcade football.
//
// Constants are per-call rather than global so scenarios can vary the
// surface (drill on turf vs. field) without a static-init reshuffle.
// M1 caller (`Match::tick`) passes the two defaults defined below.
//
// See DESIGN.md §23.2 Ball entity + physics, §5.3 physics layering.

#pragma once

#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"

namespace fh::sim::physics {

// Per-tick multiplicative velocity decay. 0.98 = 2% velocity loss per
// 20 Hz tick ⇒ ~half-decay every ~35 ticks (1.75 s) ⇒ 20 m/s ball
// snaps to rest at ~15 s under kDefaultBallRestThreshold. Deliberately
// not attribute-driven in M1 (uniform grass surface); may be promoted
// to a scenario field in M2 if drill surfaces need to vary.
//
// Value: 49/50 = 0.98 exactly, safe for Fixed64::fromFraction.
inline const math::Fixed64 kDefaultBallDecayPerTick =
    math::Fixed64::fromFraction(49, 50);

// Per-axis absolute-velocity threshold. When every component's magnitude
// falls below this, the whole velocity is snapped to zero. 1/100 = 0.01 m/s
// is well below "visible motion" at any reasonable camera zoom.
inline const math::Fixed64 kDefaultBallRestThreshold =
    math::Fixed64::fromFraction(1, 100);

// Apply passive ball dynamics for one tick. Writes new velocity in-place;
// leaves position untouched. Direction is preserved (each component
// multiplied by the same decay) unless the snap-to-rest branch fires,
// in which case velocity is set to exactly Vec3{0,0,0}.
//
// Precondition: `ball` is the ball entity's current state (as returned
// by IPhysicsWorld::get).
// Postcondition: `ball.velocity` reflects one tick of friction decay.
// Position, heading, motion, id, slot_id are untouched.
void tickBall(EntityState&        ball,
              const math::Fixed64 decay_per_tick,
              const math::Fixed64 rest_threshold) noexcept;

} // namespace fh::sim::physics
