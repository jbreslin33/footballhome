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

// Slice 26.3 (ADR §22.23, DESIGN.md §24.3): number of ticks after a
// kick during which the snap-to-rest branch of tickBall() is
// suppressed. Guards short/weak passes and passes with a small
// perpendicular component against the friction floor killing the ball
// before it can reach a receiver. 40 ticks at 20 Hz = 2 s runway,
// safely longer than any realistic short-pass flight time on M2
// short-pass scenarios (30 m at 15 m/s = 2 s worst case).
inline constexpr int kKickAliveTicks = 40;

// Apply passive ball dynamics for one tick. Writes new velocity in-place;
// leaves position untouched. Direction is preserved (each component
// multiplied by the same decay) unless the snap-to-rest branch fires,
// in which case velocity is set to exactly Vec3{0,0,0}.
//
// Precondition: `ball` is the ball entity's current state (as returned
// by IPhysicsWorld::get).
// Postcondition: `ball.velocity` reflects one tick of friction decay.
// Position, heading, motion, id, slot_id are untouched.
//
// Slice 26.3: when `skip_rest_snap` is true the snap-to-rest branch is
// suppressed — velocity still multiplies by decay, but a ball whose
// components all fall below `rest_threshold` after multiplication is
// NOT zeroed. Match sets this true for `kKickAliveTicks` ticks after a
// kick so a slow pass isn't killed by the friction floor before it
// reaches its target. Default false preserves the M1 behaviour for
// every existing caller (test_ball_physics, ball-roll goldens).
void tickBall(EntityState&        ball,
              const math::Fixed64 decay_per_tick,
              const math::Fixed64 rest_threshold,
              bool                skip_rest_snap = false) noexcept;

// Slice 26.3 (ADR §22.23): apply an instantaneous kick impulse to the
// ball. Overwrites ball.velocity with `direction_normalized * speed`
// — a pass primitive fully imparts new momentum rather than adding to
// existing rolling. Position, heading, motion, id, slot_id are
// untouched. The Match tick loop calls this BEFORE `physics.step`, so
// the kicked velocity gets integrated into a position delta this same
// tick.
//
// `direction` is normalised inside; caller may pass any non-zero XY
// vector (the Slice 26.2 wire decoder guarantees magnitude ∈ [0.5, 1.5]
// when this fires from the wire path, but tests may pass different
// magnitudes and get identical output). A zero-length direction is a
// no-op — the ball's velocity is left untouched to avoid a
// divide-by-zero in normalize() and to make "kick pressed but no
// direction" a safe client bug.
//
// `speed` is the target speed in m/s. Negative speed reverses direction
// (mainly useful in tests); zero speed is a no-op.
void applyImpulse(EntityState&      ball,
                  const math::Vec3& direction,
                  math::Fixed64     speed) noexcept;

} // namespace fh::sim::physics
