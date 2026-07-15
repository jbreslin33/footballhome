// footballhome sim - Mechanics
//
// Free functions that translate a controller's Intent + the player's
// physical attributes + current entity state + current stamina + dt
// into the new velocity, heading, motion, and stamina for this tick.
//
// Pure and deterministic — no I/O, no allocation, no side effects.
// Lives in match/ (not physics/) because it's the gameplay-side glue
// between intent and physics; physics itself remains kinematics-only.
//
// See DESIGN.md §5.7 (mechanics functions), §14 (tick loop).

#pragma once

#include "common/EntityState.hpp"
#include "common/IdTypes.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "profile/AttributeSet.hpp"

namespace fh::sim::match {

// Cached per-player parameters. Built once at match start from
// profile.physical so the mechanics hot path avoids map lookups.
struct MechanicsParams {
    math::Fixed64 max_walk_speed;
    math::Fixed64 max_jog_speed;
    math::Fixed64 max_sprint_speed;
    math::Fixed64 acceleration;
    math::Fixed64 deceleration;
    math::Fixed64 agility;              // rad/s heading rate
    math::Fixed64 stamina_max;
    math::Fixed64 stamina_drain_rate;   // /s while actually sprinting
    math::Fixed64 stamina_recovery_rate;// /s while idle or walking

    // Slice 16.3: dribble_efficiency in [0,1]. Read by BallControl to
    // compute the walk-speed cap while a player owns the ball. NOT
    // consumed by applyIntent — the M0 canonical hash and the Slice
    // 15.6 ball-golden hash are only stable because this attribute
    // stays out of the movement math. If a future slice starts
    // reading this in applyIntent, both golden hashes need refresh.
    math::Fixed64 dribble_efficiency;

    // Slice 25.2: ball-carry speed pair. Read by BallControl in
    // fillOwnedFields as the *base* speed cap, chosen per-tick from
    // Intent::wants_sprint. NOT consumed by applyIntent — the no-ball
    // determinism goldens (Wander/HumanSprint/BallRoll) stay byte-
    // identical. The two ball-owning goldens (Dribble200 +
    // FirstTouch200) shifted with the new formula in this slice.
    //   * max_dribble_speed        = ceiling when owning ball, no sprint
    //   * max_carry_sprint_speed   = ceiling when owning ball + wants_sprint
    // Effective cap = base × dribble_efficiency (attenuation for weaker
    // dribblers). See sim/src/mechanics/BallControl.cpp::fillOwnedFields.
    math::Fixed64 max_dribble_speed;
    math::Fixed64 max_carry_sprint_speed;

    // Extract M0 params from a physical AttributeSet. Missing attrs fall
    // back to the M0 defaults from §16.2 so tests can pass minimal profiles.
    static MechanicsParams fromPhysical(const profile::AttributeSet& physical);
};

struct MechanicsResult {
    math::Vec3    new_velocity;
    math::Fixed64 new_heading;    // wrapped to [-π, π]
    MotionState   new_motion;
    math::Fixed64 new_stamina;    // clamped to [0, stamina_max]
};

// Compute the next-tick outputs. Callers pass the pre-step EntityState and
// stamina; the returned values should be written back before physics.step().
MechanicsResult applyIntent(const controller::Intent& intent,
                            const EntityState&         current,
                            math::Fixed64              current_stamina,
                            const MechanicsParams&     params,
                            math::Fixed64              dt);

} // namespace fh::sim::match
