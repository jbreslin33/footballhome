// footballhome sim - Mechanics implementation
//
// See Mechanics.hpp for the intent → outputs contract. This file is where
// the M0 movement model lives — walk/jog/sprint tiers, acceleration/
// deceleration clamping, agility-limited heading rotation, and the
// stamina drain/recovery curve.

#include "match/Mechanics.hpp"

#include "common/M0Attributes.hpp"
#include "math/FixedMath.hpp"

namespace fh::sim::match {

namespace {

using math::Fixed64;
using math::Vec3;

// Distance below which we treat a Vec3 as zero. Avoids amplifying noise in
// normalize(). ~1 mm.
const Fixed64 kEpsilonDir = Fixed64::fromFraction(1, 1000);

// Wrap an angle to (-π, π]. Input is expected to be within (-3π, 3π] which
// covers all realistic per-tick heading deltas.
Fixed64 wrap_pi(Fixed64 a) noexcept
{
    while (a > math::FX_PI)  { a -= math::FX_TAU; }
    while (a <= -math::FX_PI) { a += math::FX_TAU; }
    return a;
}

} // namespace

MechanicsParams MechanicsParams::fromPhysical(const profile::AttributeSet& physical)
{
    // Baseline VALUES live only in M0Attributes.cpp (§22.11) — the single
    // sanctioned source of hard-coded attribute defaults. We fall back to
    // them if `physical` is missing any attribute (a per-player profile
    // may legitimately not override every slot). Sourcing here (instead
    // of an inline `Fixed64::fromDouble(...)`) satisfies
    // check_no_hardcoded_attrs.sh (§16.6).
    static const profile::AttributeSet kDefaults = m0::defaultPhysical();
    const auto get = [&](AttrId id) {
        return physical.get(id, kDefaults.get(id, Fixed64::zero()));
    };

    MechanicsParams p;
    p.max_walk_speed        = get(m0::kMaxWalkSpeed);
    p.max_jog_speed         = get(m0::kMaxJogSpeed);
    p.max_sprint_speed      = get(m0::kMaxSprintSpeed);
    p.acceleration          = get(m0::kAcceleration);
    p.deceleration          = get(m0::kDeceleration);
    p.agility               = get(m0::kAgility);
    p.stamina_max           = get(m0::kStaminaMax);
    p.stamina_drain_rate    = get(m0::kStaminaDrainRate);
    p.stamina_recovery_rate = get(m0::kStaminaRecoveryRate);
    // Slice 16.3: cached for BallControl. Read-only for applyIntent
    // (which never touches it), so both canonical goldens stay put.
    p.dribble_efficiency    = get(m0::kDribbleEfficiency);
    return p;
}

MechanicsResult applyIntent(const controller::Intent& intent,
                            const EntityState&         current,
                            Fixed64                    current_stamina,
                            const MechanicsParams&     params,
                            Fixed64                    dt)
{
    MechanicsResult out{};

    // -----------------------------------------------------------------
    // 1) Motion tier selection.
    //
    // Rules:
    //   - No direction requested → Idle.
    //   - wants_walk (and not wants_sprint)              → Walk.
    //   - wants_sprint AND stamina > 0                   → Sprint.
    //   - Otherwise → Jog.
    // -----------------------------------------------------------------
    const Vec3    dir     = intent.desired_direction;
    const Fixed64 dir_len = dir.length();
    const bool    moving  = dir_len >= kEpsilonDir;

    MotionState motion    = MotionState::Idle;
    Fixed64     target_speed = Fixed64::zero();

    if (moving) {
        if (intent.wants_sprint && current_stamina > Fixed64::zero()) {
            motion       = MotionState::Sprint;
            target_speed = params.max_sprint_speed;
        } else if (intent.wants_walk && !intent.wants_sprint) {
            motion       = MotionState::Walk;
            target_speed = params.max_walk_speed;
        } else {
            motion       = MotionState::Jog;
            target_speed = params.max_jog_speed;
        }
    }

    // -----------------------------------------------------------------
    // 2) Desired velocity from unit direction × target speed.
    // -----------------------------------------------------------------
    Vec3 desired_v{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};
    if (motion != MotionState::Idle) {
        // Normalize; safe against zero because we checked moving above.
        const Vec3 unit = dir.normalized();
        desired_v = Vec3{unit.x * target_speed,
                         unit.y * target_speed,
                         unit.z * target_speed};
    }

    // -----------------------------------------------------------------
    // 3) Velocity change clamped by acceleration or deceleration.
    //
    // Rule: if the desired velocity is a larger magnitude than current,
    // we're accelerating; otherwise decelerating. This includes coming
    // to a full stop from Idle (which uses deceleration).
    // -----------------------------------------------------------------
    const Vec3    delta_v   = desired_v - current.velocity;
    const Fixed64 delta_len = delta_v.length();

    const Fixed64 cur_speed = current.velocity.length();
    const Fixed64 des_speed = desired_v.length();
    const Fixed64 rate      = (des_speed >= cur_speed)
                                ? params.acceleration
                                : params.deceleration;
    const Fixed64 max_step  = rate * dt;

    Vec3 new_v;
    if (delta_len <= max_step) {
        new_v = desired_v;
    } else {
        const Vec3 unit_delta = delta_v.normalized();
        new_v = Vec3{current.velocity.x + unit_delta.x * max_step,
                     current.velocity.y + unit_delta.y * max_step,
                     current.velocity.z + unit_delta.z * max_step};
    }
    out.new_velocity = new_v;

    // -----------------------------------------------------------------
    // 4) Heading rotation clamped by agility (rad/s).
    //    Idle keeps the current heading (no wobble).
    // -----------------------------------------------------------------
    Fixed64 new_h = current.heading;
    if (motion != MotionState::Idle) {
        const Fixed64 target_h = math::fx_atan2(dir.y, dir.x);
        const Fixed64 delta_h  = wrap_pi(target_h - current.heading);
        const Fixed64 max_dh   = params.agility * dt;

        if (delta_h >  max_dh) { new_h = wrap_pi(current.heading + max_dh); }
        else if (delta_h < -max_dh) { new_h = wrap_pi(current.heading - max_dh); }
        else                        { new_h = wrap_pi(current.heading + delta_h); }
    }
    out.new_heading = new_h;
    out.new_motion  = motion;

    // -----------------------------------------------------------------
    // 5) Stamina.
    //    - Sprinting AND actually moving faster than walk → drain.
    //    - Idle or Walk → recover.
    //    - Jog → unchanged (design choice; keeps M0 model simple).
    // -----------------------------------------------------------------
    Fixed64 new_stamina = current_stamina;
    const bool actually_sprinting =
        (motion == MotionState::Sprint) && (des_speed > params.max_walk_speed);

    if (actually_sprinting) {
        new_stamina = new_stamina - params.stamina_drain_rate * dt;
    } else if (motion == MotionState::Idle || motion == MotionState::Walk) {
        new_stamina = new_stamina + params.stamina_recovery_rate * dt;
    }
    out.new_stamina = math::fx_clamp(new_stamina, Fixed64::zero(), params.stamina_max);

    return out;
}

} // namespace fh::sim::match
