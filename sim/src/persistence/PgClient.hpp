// footballhome sim - PgClient
//
// Production libpqxx-backed implementation of IPgClient. One connection
// per instance; the sim daemon holds two instances (main thread + flush
// thread) per DESIGN.md §22.12 decision #4.
//
// This header must NOT expose any libpqxx types — sim_persistence users
// (sim_server, sim_gameplay, tests) never include <pqxx/pqxx.h>. The
// libpqxx connection lives inside a std::unique_ptr<Impl> pimpl so this
// header stays clean.
//
// Configuration is passed via ConnConfig. Missing/blank required fields
// throw PgError at construction time (fail-loud per Rule 4).

#pragma once

#include "persistence/IPgClient.hpp"

#include <memory>
#include <optional>
#include <string>

namespace fh::sim::persistence {

struct ConnConfig {
    std::string host;
    std::string port{"5432"};
    std::string dbname;
    std::string user;
    std::string password;
    // Optional application_name — shown in pg_stat_activity, helps ops
    // distinguish sim connections from backend ones.
    std::string application_name{"footballhome_sim"};
};

class PgClient : public IPgClient {
public:
    // Opens the connection and registers all prepared statements. Throws
    // PgError on any failure (unreachable DB, bad credentials, prepared
    // statement rejected, etc.).
    explicit PgClient(const ConnConfig& cfg);
    ~PgClient() override;

    // IPgClient overrides
    std::vector<RegistryRow> loadAttributeRegistry() override;
    std::vector<RegistryRow> loadConceptRegistry() override;
    std::vector<RegistryRow> loadPatternRegistry() override;

    std::optional<MatchRow> getMatch(MatchId id) override;
    void upsertMatch(const MatchRow& row) override;
    void updateMatchEnded(MatchId id,
                          std::span<const std::byte> result_hash) override;

    std::optional<ProfileRows> loadProfile(PersonId person_id) override;
    void upsertProfile(PersonId person_id, const ProfileRows& rows) override;

    void insertInput(const InputRow& row) override;
    void insertInputBatch(std::span<const InputRow> rows) override;
    std::vector<InputRow>
    loadInputsForMatch(MatchId id,
                       std::optional<TickNum> up_to_tick = std::nullopt) override;

    void insertEvent(const EventRow& row) override;
    void insertEventBatch(std::span<const EventRow> rows) override;
    std::optional<MatchEndRecord> loadMatchEnd(MatchId id) override;

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

} // namespace fh::sim::persistence
