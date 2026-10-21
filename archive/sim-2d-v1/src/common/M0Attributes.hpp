// footballhome sim - Milestone 0 baseline profile values.
//
// The registry CATALOG (attribute IDs, keys, categories; concept IDs, keys,
// categories) is generated at CMake configure time from
// database/migrations/200-sim-registries.sql into M0Registry.generated.hpp
// (see DESIGN.md section 22.11). That header exports:
//
//   * inline constexpr AttrId    m0::kMaxWalkSpeed, kMaxJogSpeed, ...
//   * inline constexpr ConceptId m0::kRunToPoint, ...
//   * inline void m0::seedRegistries(AttributeRegistry&, ConceptRegistry&)
//
// This file adds ONLY the non-catalog piece: default M0 attribute + concept
// VALUES (Fixed64 numbers - max walk speed = 2.0 m/s, etc.). These are
// gameplay balance baselines, not registry schema, and belong to the C++
// code rather than the migration.
//
// See DESIGN.md sections 5.2, 8, 16.2, 16.3, 21.1, 22.11.

#pragma once

#include "common/M0Registry.generated.hpp"     // constants + seedRegistries()
#include "math/Fixed64.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"

namespace fh::sim::m0 {

// -----------------------------------------------------------------------
// Default M0 physical AttributeSet (see DESIGN.md section 16.2 numbers).
// Every player in M0 gets these values until per-player profiles land.
// -----------------------------------------------------------------------
profile::AttributeSet defaultPhysical();

// Default ConceptSet: one concept, run_to_point, at full mastery.
// This is what WanderController checks to decide whether the slot's
// AI is "unlocked" for it in M0.
profile::ConceptSet defaultConcepts();

} // namespace fh::sim::m0
