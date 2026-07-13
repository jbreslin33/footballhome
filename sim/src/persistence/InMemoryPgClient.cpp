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

std::optional<ProfileRows> InMemoryPgClient::loadProfile(PersonId person_id)
{
    const auto it = profiles_.find(person_id);
    if (it == profiles_.end()) {
        return std::nullopt;
    }
    // Mirror PgClient's ORDER BY <id> ASC semantics — callers depend on
    // this for deterministic reconstruction of AttributeSet / ConceptSet
    // / RecognitionSet. Copy first (map holds the canonical unsorted
    // ProfileRows exactly as upsert wrote it), then sort each vector by
    // its id (element .first) so the return value is byte-identical to
    // what PgClient would return for the same person.
    ProfileRows out = it->second;
    auto by_id = [](const auto& a, const auto& b) { return a.first < b.first; };
    std::sort(out.attributes.begin(),  out.attributes.end(),  by_id);
    std::sort(out.concepts.begin(),    out.concepts.end(),    by_id);
    std::sort(out.recognition.begin(), out.recognition.end(), by_id);
    return out;
}

void InMemoryPgClient::upsertProfile(PersonId person_id,
                                     const ProfileRows& rows)
{
    profiles_[person_id] = rows;
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

std::vector<InputRow>
InMemoryPgClient::loadInputsForMatch(MatchId id,
                                     std::optional<TickNum> up_to_tick)
{
    std::vector<InputRow> out;
    for (const auto& row : inputs_) {
        if (row.match_id != id) { continue; }
        if (up_to_tick.has_value() && row.tick_num > *up_to_tick) { continue; }
        out.push_back(row);
    }
    // Match the DB's ORDER BY tick_num ASC, slot_id ASC so replay sees
    // the identical sequence irrespective of insertion order.
    std::sort(out.begin(), out.end(),
              [](const InputRow& a, const InputRow& b) {
                  if (a.tick_num != b.tick_num) { return a.tick_num < b.tick_num; }
                  return a.slot_id < b.slot_id;
              });
    return out;
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

std::optional<IPgClient::MatchEndRecord>
InMemoryPgClient::loadMatchEnd(MatchId id)
{
    // Scan in reverse — the most recent MatchEnd wins under crash-restart
    // semantics (matches the DB's `ORDER BY id DESC LIMIT 1`).
    for (auto it = events_.rbegin(); it != events_.rend(); ++it) {
        if (it->match_id != id) { continue; }
        if (it->event_type != EventType::MatchEnd) { continue; }
        MatchEndRecord rec;
        rec.tick_num = it->tick_num;
        if (it->payload.has_value()) {
            rec.payload = *it->payload;
        }
        return rec;
    }
    return std::nullopt;
}

} // namespace fh::sim::persistence
