// footballhome sim - RegistryLoader
//
// Free-function bridge between the persistence layer (IPgClient) and the
// runtime registry types owned by sim_data. Kept as free functions rather
// than member methods to avoid an inverted layer dependency: sim_data
// (registries) sits BELOW sim_persistence, so registries cannot include
// IPgClient.hpp. The loader lives on the persistence side and pushes
// entries INTO the registries via their existing public API (addEntry).
//
// See DESIGN.md §16.6 (Slice 13 Sub-slice 2), §22.9 (drift check), §22.11
// (M0Registry.generated.hpp), §22.12 (persistence architecture).

#pragma once

#include "persistence/IPgClient.hpp"
#include "registry/AttributeRegistry.hpp"
#include "registry/ConceptRegistry.hpp"
#include "registry/PatternRegistry.hpp"

namespace fh::sim::persistence {

// Load DB rows into a runtime registry, clearing prior contents first.
// Throws PgError on any DB failure. Additionally throws PgError with
// context "loadAttributeRegistry" / "loadConceptRegistry" if the DB
// returned zero rows — an empty attribute or concept catalog is a
// deployment error (migration 200 was not applied), not a normal state.
//
// PatternRegistry may legitimately be empty in M0 (§12.5); no fail-loud.
void loadAttributeRegistryFromDb(registry::AttributeRegistry& out, IPgClient& db);
void loadConceptRegistryFromDb  (registry::ConceptRegistry&   out, IPgClient& db);
void loadPatternRegistryFromDb  (registry::PatternRegistry&   out, IPgClient& db);

// Boot-time drift check (§16.6 / §22.9). Seeds a scratch registry pair
// using m0::seedRegistries() (from the CMake-generated header, itself
// derived from migration 200) and compares it entry-for-entry against
// the DB-loaded registries.
//
// Throws PgError("verifyM0RegistryConsistency", <details>) if:
//   - Any compile-time (id, key) pair is missing from DB.
//   - Any compile-time id maps to a different key in DB.
//   - Sizes differ (DB has extra rows not covered by compile-time).
//
// The scratch approach means one edit — a new INSERT in migration 200
// that regenerates the header via `awk` at CMake configure time — is the
// only change needed to add attributes; the drift check picks up
// automatically.
void verifyM0RegistryConsistency(const registry::AttributeRegistry& attrs,
                                 const registry::ConceptRegistry&   concepts);

} // namespace fh::sim::persistence
