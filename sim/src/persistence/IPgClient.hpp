// footballhome sim - IPgClient
//
// Pure-virtual persistence boundary between sim gameplay code and Postgres.
// The concrete `PgClient` (libpqxx) and the in-memory test double
// `InMemoryPgClient` both implement this interface.
//
// Callers NEVER include <pqxx/pqxx.h>. All row payloads that Postgres
// stores as `BYTEA` are exchanged here as `std::span<const std::byte>`
// (writes) or `std::vector<std::byte>` (reads), so no libpqxx type leaks
// out of `PgClient.cpp`.
//
// Error surface: methods throw `PgError` on failure (unreachable DB,
// prepared-statement failure, malformed row, etc.). Callers do not check
// return codes — startup errors propagate to main() and terminate the
// daemon (Rule 4 fail-loud, §3); tick-loop errors from the flush thread
// crash the process by design.
//
// See DESIGN.md §16.6 (Slice 13 spec), §22.12 (this interface's ADR),
// §8 (DB schema for the columns referenced below).

#pragma once

#include "common/IdTypes.hpp"
#include "persistence/EventTypes.hpp"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace fh::sim::persistence {

// -----------------------------------------------------------------------------
// Error type
// -----------------------------------------------------------------------------

// All `IPgClient` methods throw this on failure. The `context()` is a short
// human-readable string naming the operation ("upsertMatch", "loadProfile"
// etc.); `what()` contains the underlying driver / SQL error message.
// Callers typically log both and shut down (Rule 4).
class PgError : public std::runtime_error {
public:
    PgError(std::string ctx, std::string msg)
        : std::runtime_error(std::move(msg)), context_(std::move(ctx)) {}

    const std::string& context() const noexcept { return context_; }

private:
    std::string context_;
};

// -----------------------------------------------------------------------------
// Row types (domain-owned; no libpqxx leakage)
// -----------------------------------------------------------------------------

// One row of a registry table (`sim_attribute_registry`,
// `sim_concept_registry`, `sim_pattern_registry`). `id` is the stable
// registry ID (see §22.9); `key` is the canonical string key; `category`
// is the discriminator (e.g. "physical" / "technical" / "mental" for
// attributes). Weight and description columns are not exposed on this
// interface — they belong to a separate future "registry metadata" API
// if we ever need them, since gameplay only cares about (id, key,
// category).
struct RegistryRow {
    std::uint16_t id{0};
    std::string   key;
    std::string   category;
};

// One row of `sim_matches`. Sim reads this once at startup (via getMatch)
// and writes it once at boot (upsertMatch) + once at shutdown
// (updateMatchEnded). Times are managed by the DB (DEFAULT NOW()) — the
// sim does not send `started_at` / `ended_at` on the write path.
struct MatchRow {
    MatchId                 id{0};
    std::int16_t            scenario_id{0};
    std::uint64_t           seed{0};
    std::int16_t            tick_hz{20};
    std::string             server_version;
    std::optional<PersonId> created_by;         // nullable in DB
    std::int16_t            visibility{0};      // 0=public 1=club 2=private
};

// A `sim_player_profile` row's three bytea payloads. Kept as three
// separate vectors because the DB has three separate columns; the
// AttributeSet / ConceptSet / RecognitionSet codecs each own their own
// wire format (§8) and concatenating them here would just make callers
// slice the buffer back apart.
struct ProfileBlob {
    std::vector<std::byte> attributes;
    std::vector<std::byte> concepts;
    std::vector<std::byte> recognition;
};

// One row of `sim_match_inputs`. Primary key = (match_id, tick_num,
// slot_id). No `client_id` column: slot ownership at that tick is
// recovered from the corresponding SlotClaim/Release events in
// `sim_match_events`. This matches §14 semantics (input is addressed
// by slot, not by connection).
struct InputRow {
    MatchId                match_id{0};
    TickNum                tick_num{0};
    SlotId                 slot_id{0};
    std::vector<std::byte> payload;    // wire InputFrame bytes
};

// One row of `sim_match_events`. `payload` optional because the DB column
// is nullable; simple events like ClientConnect need no payload, while
// MatchEnd carries the 8-byte canonical snapshot hash (§22.14, forthcoming).
struct EventRow {
    MatchId                                match_id{0};
    TickNum                                tick_num{0};
    EventType                              event_type{EventType::MatchStart};
    std::optional<std::vector<std::byte>>  payload;
};

// -----------------------------------------------------------------------------
// Interface
// -----------------------------------------------------------------------------

class IPgClient {
public:
    virtual ~IPgClient() = default;

    IPgClient() = default;
    IPgClient(const IPgClient&) = delete;
    IPgClient& operator=(const IPgClient&) = delete;
    IPgClient(IPgClient&&) = delete;
    IPgClient& operator=(IPgClient&&) = delete;

    // ------------------------------------------------------------------
    // Registry reads (startup-only, ordered by id ascending)
    // ------------------------------------------------------------------
    // Each returns every row of the corresponding table. The caller is
    // responsible for the empty-registry check (§16.6 says sim refuses
    // to start if any registry is empty). Order is deterministic
    // (ORDER BY id ASC) so drift checks against the compile-time
    // constants (§22.11) can iterate in lock-step.
    virtual std::vector<RegistryRow> loadAttributeRegistry() = 0;
    virtual std::vector<RegistryRow> loadConceptRegistry()   = 0;
    virtual std::vector<RegistryRow> loadPatternRegistry()   = 0;

    // ------------------------------------------------------------------
    // Match lifecycle
    // ------------------------------------------------------------------
    // Returns nullopt if the match row does not exist. Any other error
    // (connection loss, malformed row) throws.
    virtual std::optional<MatchRow> getMatch(MatchId id) = 0;

    // Idempotent INSERT ... ON CONFLICT (id) DO UPDATE. Refreshes
    // `server_version` on restart. Does NOT touch `ended_at` / `result`.
    virtual void upsertMatch(const MatchRow& row) = 0;

    // Called on shutdown. Sets ended_at = NOW() and result = result_hash
    // (must be exactly 8 bytes — the canonical FNV-1a-64 snapshot hash).
    // No-op if the row is already ended (idempotent under crash-restart).
    virtual void updateMatchEnded(MatchId id,
                                  std::span<const std::byte> result_hash) = 0;

    // ------------------------------------------------------------------
    // Player profile (bytea round-trip)
    // ------------------------------------------------------------------
    // Returns nullopt if no `sim_player_profile` row exists for
    // `person_id`. Callers (ProfileStore::loadOrCreate) then materialize
    // a default profile and call upsertProfile.
    virtual std::optional<ProfileBlob> loadProfile(PersonId person_id) = 0;

    // Idempotent INSERT ... ON CONFLICT (person_id) DO UPDATE. Writes
    // all three bytea columns + refreshes `updated_at`. First-touch
    // for a new person_id is a plain insert.
    virtual void upsertProfile(PersonId person_id,
                               const ProfileBlob& blob) = 0;

    // ------------------------------------------------------------------
    // Input log
    // ------------------------------------------------------------------
    // Autocommitted single-row insert. Used only for tests / debug
    // scenarios; the live flush thread uses insertInputBatch.
    virtual void insertInput(const InputRow& row) = 0;

    // Atomic multi-row insert inside a single transaction. Used by the
    // flush thread to drain the input queue at each tick boundary
    // (§16.6). All rows commit or none do — no partial-batch state
    // is observable to a concurrent replay reader.
    virtual void insertInputBatch(std::span<const InputRow> rows) = 0;

    // ------------------------------------------------------------------
    // Event log
    // ------------------------------------------------------------------
    virtual void insertEvent(const EventRow& row) = 0;
    virtual void insertEventBatch(std::span<const EventRow> rows) = 0;
};

} // namespace fh::sim::persistence
