// footballhome sim - InMemoryPgClient
//
// See header for policy. Implementation is deliberately dumb: linear scans
// for matches (there is only ever one in M0), std::unordered_map for
// profiles keyed by person_id, std::vector for inputs/events in strict
// insertion order.
//
// This file must NOT gain any performance-critical logic. The production
// driver is PgClient.cpp; this one exists to make gameplay code testable
// without a running Postgres.

#include "persistence/InMemoryPgClient.hpp"

#include <algorithm>
#include <utility>

namespace fh::sim::persistence {

// ---------------------------------------------------------------------------
// Seeders
// ---------------------------------------------------------------------------

void InMemoryPgClient::seedAttributeRegistry(std::vector<RegistryRow> rows)
{
    attrs_ = std::move(rows);
}

void InMemoryPgClient::seedConceptRegistry(std::vector<RegistryRow> rows)
{
    concepts_ = std::move(rows);
}

void InMemoryPgClient::seedPatternRegistry(std::vector<RegistryRow> rows)
{
    patterns_ = std::move(rows);
}

// ---------------------------------------------------------------------------
// Peek helpers
// ---------------------------------------------------------------------------

std::vector<InputRow> InMemoryPgClient::inputsForMatch(MatchId id) const
{
    std::vector<InputRow> out;
    for (const auto& row : inputs_) {
        if (row.match_id == id) {
            out.push_back(row);
        }
    }
    return out;
}

std::vector<EventRow> InMemoryPgClient::eventsForMatch(MatchId id) const
{
    std::vector<EventRow> out;
    for (const auto& row : events_) {
        if (row.match_id == id) {
            out.push_back(row);
        }
    }
    return out;
}

bool InMemoryPgClient::matchEnded(MatchId id) const noexcept
{
    const auto it = matches_.find(id);
    return it != matches_.end() && it->second.ended;
}

std::optional<std::vector<std::byte>>
InMemoryPgClient::matchResult(MatchId id) const
{
    const auto it = matches_.find(id);
    if (it == matches_.end() || !it->second.ended) {
        return std::nullopt;
    }
    return it->second.result;
}

// ---------------------------------------------------------------------------
// Registry reads
// ---------------------------------------------------------------------------

std::vector<RegistryRow> InMemoryPgClient::loadAttributeRegistry()
{
    return attrs_;
}

std::vector<RegistryRow> InMemoryPgClient::loadConceptRegistry()
{
    return concepts_;
}

std::vector<RegistryRow> InMemoryPgClient::loadPatternRegistry()
{
    return patterns_;
}

// ---------------------------------------------------------------------------
// Match lifecycle
// ---------------------------------------------------------------------------

std::optional<MatchRow> InMemoryPgClient::getMatch(MatchId id)
{
    const auto it = matches_.find(id);
    if (it == matches_.end()) {
        return std::nullopt;
    }
    return it->second.row;
}

void InMemoryPgClient::upsertMatch(const MatchRow& row)
{
    auto& rec = matches_[row.id];
    rec.row = row;
    // upsertMatch does NOT touch ended / result — matches DB behaviour
    // where ON CONFLICT DO UPDATE excludes ended_at + result columns.
}

void InMemoryPgClient::updateMatchEnded(MatchId id,
                                        std::span<const std::byte> result_hash)
{
    if (result_hash.size() != 8) {
        throw PgError("updateMatchEnded",
                      "result_hash must be exactly 8 bytes (got " +
                          std::to_string(result_hash.size()) + ")");
    }

    const auto it = matches_.find(id);
    if (it == matches_.end()) {
        throw PgError("updateMatchEnded",
                      "match id " + std::to_string(id) + " not found");
    }

    if (it->second.ended) {
        // Idempotent under crash-restart: already-ended is a no-op.
        return;
    }

    it->second.ended = true;
    it->second.result.assign(result_hash.begin(), result_hash.end());
}

// ---------------------------------------------------------------------------
// Player profile
// ---------------------------------------------------------------------------

std::optional<ProfileBlob> InMemoryPgClient::loadProfile(PersonId person_id)
{
    const auto it = profiles_.find(person_id);
    if (it == profiles_.end()) {
        return std::nullopt;
    }
    return it->second;
}

void InMemoryPgClient::upsertProfile(PersonId person_id,
                                     const ProfileBlob& blob)
{
    profiles_[person_id] = blob;
}

// ---------------------------------------------------------------------------
// Input log
// ---------------------------------------------------------------------------

void InMemoryPgClient::insertInput(const InputRow& row)
{
    inputs_.push_back(row);
}

void InMemoryPgClient::insertInputBatch(std::span<const InputRow> rows)
{
    inputs_.reserve(inputs_.size() + rows.size());
    for (const auto& row : rows) {
        inputs_.push_back(row);
    }
}

// ---------------------------------------------------------------------------
// Event log
// ---------------------------------------------------------------------------

void InMemoryPgClient::insertEvent(const EventRow& row)
{
    events_.push_back(row);
}

void InMemoryPgClient::insertEventBatch(std::span<const EventRow> rows)
{
    events_.reserve(events_.size() + rows.size());
    for (const auto& row : rows) {
        events_.push_back(row);
    }
}

} // namespace fh::sim::persistence
