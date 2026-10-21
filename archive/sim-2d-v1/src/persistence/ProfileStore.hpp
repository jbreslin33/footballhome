// footballhome sim - ProfileStore
//
// Bridge between the persistence layer (IPgClient) and the runtime
// PlayerProfile type owned by sim_data. Provides the one operation SimServer
// needs at client-connect time: "give me the profile for this PersonId,
// creating a default M0 baseline row on first-touch."
//
// First-touch materialization is the SOLE authorized use of hard-coded M0
// baseline VALUES (§16.6, §22.11). The values themselves live in
// M0Attributes.cpp; ProfileStore just calls defaultPhysical() /
// defaultConcepts() and writes the result back so subsequent loads read
// from the DB, not from code.
//
// See DESIGN.md §5.2, §8, §16.6, §22.12.

#pragma once

#include "common/IdTypes.hpp"
#include "persistence/IPgClient.hpp"
#include "profile/PlayerProfile.hpp"

namespace fh::sim::persistence {

class ProfileStore {
public:
    // Non-owning reference. Caller keeps db alive for ProfileStore's lifetime.
    explicit ProfileStore(IPgClient& db) noexcept : db_{db} {}

    // Load `person`'s profile, or materialize + persist a default M0 baseline
    // if no row exists yet. Throws PgError on any DB failure.
    //
    // Behavior contract:
    //   1) Existing row  → decode all three bytea columns → PlayerProfile.
    //   2) No row        → build M0 baseline (defaultPhysical + defaultConcepts),
    //                      upsertProfile(), return the baseline.
    //
    // Idempotent under concurrent first-touch: the upsert is
    // INSERT ... ON CONFLICT (person_id) DO UPDATE, so a race between two
    // sim workers just overwrites with identical bytes.
    profile::PlayerProfile loadOrCreate(PersonId person);

    // Force-write. Used by tests / future admin tooling. Throws PgError.
    void save(PersonId person, const profile::PlayerProfile& profile);

private:
    IPgClient& db_;
};

} // namespace fh::sim::persistence
