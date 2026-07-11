// footballhome sim - Milestone 0 attribute + concept seed values

#include "common/M0Attributes.hpp"

namespace fh::sim::m0 {

void seedRegistries(registry::AttributeRegistry& attrs,
                    registry::ConceptRegistry&   concepts)
{
    attrs.addEntry(kMaxWalkSpeed,        "physical.max_walk_speed",        "physical");
    attrs.addEntry(kMaxJogSpeed,         "physical.max_jog_speed",         "physical");
    attrs.addEntry(kMaxSprintSpeed,      "physical.max_sprint_speed",      "physical");
    attrs.addEntry(kAcceleration,        "physical.acceleration",          "physical");
    attrs.addEntry(kDeceleration,        "physical.deceleration",          "physical");
    attrs.addEntry(kAgility,             "physical.agility",               "physical");
    attrs.addEntry(kStaminaMax,          "physical.stamina_max",           "physical");
    attrs.addEntry(kStaminaDrainRate,    "physical.stamina_drain_rate",    "physical");
    attrs.addEntry(kStaminaRecoveryRate, "physical.stamina_recovery_rate", "physical");

    concepts.addEntry(kRunToPoint, "run_to_point", "movement");
}

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
    return a;
}

profile::ConceptSet defaultConcepts()
{
    profile::ConceptSet c;
    c.plug(kRunToPoint, math::Fixed64::fromDouble(1.0));
    return c;
}

} // namespace fh::sim::m0
