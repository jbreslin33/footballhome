// footballhome sim - InMemoryPgClient
//
// Test double / replay driver for IPgClient. Ships in production sources
// (not under sim/tests/) so `fh-sim-replay` can drive a replay from
// in-memory recorded inputs without touching Postgres.
//
// Not thread-safe. Callers that share an instance across threads must
// synchronize externally. The production PgClient's flush thread uses
// its own connection; the in-memory equivalent (test replay) is
// single-threaded by construction.
//
// Behavior contract mirrors the DB semantics where reasonable:
//   * Registry loads return rows in insertion order (equivalent to
//     ORDER BY id ASC when the seeder inserts in id order).
//   * upsertMatch replaces the row on id collision (matches DB upsert).
//   * updateMatchEnded requires exactly 8 bytes of result hash and is
//     idempotent (second call on an ended match is a no-op).
//   * Inputs and events are stored in strict insertion order across
//     insert() and insertBatch() calls, letting deterministic-replay
//     tests iterate reproducibly.
//
// See DESIGN.md §16.6, §22.12.

#pragma once

#include "persistence/IPgClient.hpp"

#include <cstddef>
#include <optional>
#include <unordered_map>
#include <vector>

namespace fh::sim::persistence {

class InMemoryPgClient : public IPgClient {
public:
    InMemoryPgClient() = default;
    ~InMemoryPgClient() override = default;

    // -----------------------------------------------------------------
    // Test seeding helpers (not on IPgClient — no equivalent on the
    // production driver; registries are seeded by a SQL migration).
    // -----------------------------------------------------------------
    void seedAttributeRegistry(std::vector<RegistryRow> rows);
    void seedConceptRegistry(std::vector<RegistryRow> rows);
    void seedPatternRegistry(std::vector<RegistryRow> rows);

    // -----------------------------------------------------------------
    // Test peek helpers (introspect stored state).
    // -----------------------------------------------------------------
    std::size_t inputCount() const noexcept { return inputs_.size(); }
    std::size_t eventCount() const noexcept { return events_.size(); }

    // Copies of stored rows for a specific match, in insertion order.
    std::vector<InputRow> inputsForMatch(MatchId id) const;
    std::vector<EventRow> eventsForMatch(MatchId id) const;

    // Match state introspection.
    bool matchEnded(MatchId id) const noexcept;
    std::optional<std::vector<std::byte>> matchResult(MatchId id) const;

    // §21.7 item 2 remedy: was first_tick_at written for this match?
    // True iff updateMatchFirstTick has been called at least once for
    // `id`. Mirrors the DB semantic "first_tick_at IS NOT NULL".
    bool matchFirstTickWritten(MatchId id) const noexcept;
    // Test-only counter: how many times updateMatchFirstTick was
    // invoked for `id`. The DB call is idempotent (WHERE ... IS NULL
    // guard) so only the first invocation has an effect, but the
    // sim daemon should invoke it exactly once per tick loop; a value
    // > 1 in the test harness indicates SimServer is firing the
    // first-tick callback more than once, which would be a bug.
    std::size_t matchFirstTickCallCount(MatchId id) const noexcept;

    // -----------------------------------------------------------------
    // IPgClient overrides
    // -----------------------------------------------------------------
    std::vector<RegistryRow> loadAttributeRegistry() override;
    std::vector<RegistryRow> loadConceptRegistry() override;
    std::vector<RegistryRow> loadPatternRegistry() override;

    std::optional<MatchRow> getMatch(MatchId id) override;
    void upsertMatch(const MatchRow& row) override;
    void updateMatchFirstTick(MatchId id) override;
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
    struct MatchRecord {
        MatchRow               row;
        bool                   ended{false};
        std::vector<std::byte> result;
        bool                   first_tick_written{false};
        std::size_t            first_tick_call_count{0};
    };

    std::vector<RegistryRow>                attrs_;
    std::vector<RegistryRow>                concepts_;
    std::vector<RegistryRow>                patterns_;
    std::unordered_map<MatchId, MatchRecord>   matches_;
    std::unordered_map<PersonId, ProfileRows>  profiles_;
    std::vector<InputRow>                   inputs_;
    std::vector<EventRow>                   events_;
};

} // namespace fh::sim::persistence
