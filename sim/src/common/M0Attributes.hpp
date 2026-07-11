// footballhome sim - Milestone 0 attribute + concept catalogue
//
// The DB (§8) is source of truth for registries in production. In M0 we
// have no DB slice yet, so this header exposes the M0 IDs, keys, defaults,
// and a helper that seeds an in-memory registry so tests, tools, and the
// early server bootstrap can run without a database.
//
// When the DB migration lands, migration 200-sim-registries.sql must use
// the SAME (id, key) pairs defined here — otherwise loaded profiles will
// silently reference wrong attributes.
//
// See DESIGN.md §5.2, §8, §16.2, §16.3.

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"
#include "registry/AttributeRegistry.hpp"
#include "registry/ConceptRegistry.hpp"

namespace fh::sim::m0 {

// -----------------------------------------------------------------------
// Physical attributes consumed by M0 mechanics (see §16.2).
// -----------------------------------------------------------------------
inline constexpr AttrId kMaxWalkSpeed        = 1;   // m/s
inline constexpr AttrId kMaxJogSpeed         = 2;   // m/s
inline constexpr AttrId kMaxSprintSpeed      = 3;   // m/s
inline constexpr AttrId kAcceleration        = 4;   // m/s²
inline constexpr AttrId kDeceleration        = 5;   // m/s²
inline constexpr AttrId kAgility             = 6;   // rad/s
inline constexpr AttrId kStaminaMax          = 7;   // pool
inline constexpr AttrId kStaminaDrainRate    = 8;   // /s while sprinting
inline constexpr AttrId kStaminaRecoveryRate = 9;   // /s while walk/idle

// -----------------------------------------------------------------------
// Concepts registered in M0 (see §16.3). Exactly one: run_to_point,
// which unlocks WanderController.
// -----------------------------------------------------------------------
inline constexpr ConceptId kRunToPoint = 1;

// -----------------------------------------------------------------------
// Register the M0 attributes + concepts into the given registries.
// Idempotent — safe to call from tests and from server bootstrap.
// -----------------------------------------------------------------------
void seedRegistries(registry::AttributeRegistry& attrs,
                    registry::ConceptRegistry&   concepts);

// -----------------------------------------------------------------------
// Default M0 physical AttributeSet (§16.2 numbers). Every player in M0
// gets these values until per-player profiles land later.
// -----------------------------------------------------------------------
profile::AttributeSet defaultPhysical();

// Default ConceptSet: one concept, run_to_point, at full mastery.
// This is what WanderController checks to decide whether the slot's
// AI is "unlocked" for it in M0.
profile::ConceptSet defaultConcepts();

} // namespace fh::sim::m0
