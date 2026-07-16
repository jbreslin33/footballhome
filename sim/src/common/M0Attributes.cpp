// footballhome sim - Milestone 0 baseline profile values.
//
// See M0Attributes.hpp for scope. Catalog seed lives in the CMake-generated
// M0Registry.generated.hpp; this file only holds Fixed64 balance numbers.

#include "common/M0Attributes.hpp"

namespace fh::sim::m0 {

profile::AttributeSet defaultPhysical()
{
    profile::AttributeSet a;
    a.set(kMaxWalkSpeed,        math::Fixed64::fromDouble(2.0));
    a.set(kMaxJogSpeed,         math::Fixed64::fromDouble(4.5));
    a.set(kMaxSprintSpeed,      math::Fixed64::fromDouble(7.5));
    a.set(kAcceleration,        math::Fixed64::fromDouble(6.0));
    a.set(kDeceleration,        math::Fixed64::fromDouble(8.0));
    a.set(kAgility,             math::Fixed64::fromDouble(6.0));
    a.set(kStaminaMax,          math::Fixed64::fromDouble(1.0));
    a.set(kStaminaDrainRate,    math::Fixed64::fromDouble(0.10));
    a.set(kStaminaRecoveryRate, math::Fixed64::fromDouble(0.05));
    // Slice 16.1 (§23.3): dribble_efficiency scales walk-speed cap while
    // carrying the ball. Read by BallControl in Slice 16.3; not consumed
    // by MechanicsParams::fromPhysical, so the M0 canonical-hash gold
    // and the Slice 15.6 ball-trajectory gold stay byte-identical.
    a.set(kDribbleEfficiency,   math::Fixed64::fromDouble(0.85));

    // Slice 25.2 (§23.3): ball-carry speed pair. These replace the prior
    // "walk × efficiency" formula in BallControl. See
    // database/migrations/209-sim-attr-carry-speeds.sql for the DB rows
    // and the semantic contract.
    //   * max_dribble_speed       = 4.0 m/s (dribble under control, no sprint)
    //   * max_carry_sprint_speed  = 6.0 m/s (sprint with ball; still < 7.5
    //                                        m/s no-ball sprint by design —
    //                                        ball-touch cadence limits top)
    // dribble_efficiency (0.85 above) still applies as an attenuation, so
    // out-of-the-box effective caps are 3.4 m/s (dribble) and 5.1 m/s
    // (sprint w/ ball). Only the dribble determinism goldens
    // (kExpectedHashDribble200, kExpectedHashFirstTouch200) are affected;
    // no-ball paths are byte-identical.
    a.set(kMaxDribbleSpeed,     math::Fixed64::fromDouble(4.0));
    a.set(kMaxCarrySprintSpeed, math::Fixed64::fromDouble(6.0));

    // Slice 24.3b (§23.3): press_resistance rates a DEFENDER's ability
    // to strip an opposing dribbler while in contest range of the ball.
    // Read by BallControl in the post-Rule-2 contest step; not consumed
    // by MechanicsParams::fromPhysical's applyIntent path, so the M0
    // canonical goldens and every no-ball / no-defender determinism
    // golden stay byte-identical. Default 0.75 is deliberately BELOW
    // default dribble_efficiency (0.85): a default defender pressing a
    // default attacker does NOT win the contest, so the existing
    // Dribble200 / FirstTouch200 goldens (which never see a defender
    // asserting wants_to_press) are also unaffected.
    a.set(kPressResistance,     math::Fixed64::fromDouble(0.75));

    // Slice 26.1 (§24.3): pass_power is the initial ball speed (m/s)
    // when this player fires a short pass. Consumed by BallPhysics'
    // applyImpulse in Slice 26.3 — NO code path reads this default yet,
    // so migration 217 landing here is determinism-neutral: all 47
    // goldens (Wander200, HumanSprint400, BallRoll400, Dribble200,
    // FirstTouch200, HalfPitchHard400, SoftDrill400,
    // BallOnPitchWithDefender400, plus the M0 canonical hash) stay
    // byte-identical. Default 15.0 m/s is a moderate crisp pass —
    // faster than a top-end no-ball sprint (7.5 m/s) so a pass beats a
    // chaser, but slow enough that a receiver 10 m away has ~0.66 s to
    // read it. Per-player biasing arrives when the profile editor
    // lands (deferred per §24.5).
    a.set(kPassPower,           math::Fixed64::fromDouble(15.0));
    return a;
}

profile::ConceptSet defaultConcepts()
{
    profile::ConceptSet c;
    c.plug(kRunToPoint, math::Fixed64::fromDouble(1.0));
    return c;
}

} // namespace fh::sim::m0
