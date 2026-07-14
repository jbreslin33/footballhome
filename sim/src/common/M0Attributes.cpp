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
    return a;
}

profile::ConceptSet defaultConcepts()
{
    profile::ConceptSet c;
    c.plug(kRunToPoint, math::Fixed64::fromDouble(1.0));
    return c;
}

} // namespace fh::sim::m0
