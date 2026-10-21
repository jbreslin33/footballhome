// footballhome sim - ProfileStore implementation
// See ProfileStore.hpp and DESIGN.md §16.6, §22.12, §22.18.

#include "persistence/ProfileStore.hpp"

#include "common/M0Attributes.hpp"
#include "math/Fixed64.hpp"

#include <algorithm>
#include <cstdint>
#include <utility>

namespace fh::sim::persistence {

namespace {

// Encode one Set (AttributeSet / ConceptSet / RecognitionSet) into the
// (id, f32) row pairs the persistence layer stores. Iterates the sparse
// unordered_map exposed via .values() and sorts ascending by id so:
//   (a) the DB write order is deterministic (pg_dump / logical-replica
//       diffs stable across replays);
//   (b) the round-trip through Postgres — which returns rows ORDER BY
//       <id> ASC — reconstructs an identical unordered_map without
//       requiring extra sorts at load time.
//
// Templated over the map type from the Set's .values() accessor. All
// three id types (AttrId / ConceptId / PatternId) alias std::uint16_t
// in common/IdTypes.hpp, so the static_cast on emplace_back is a
// documentation-only no-op that survives a future id-type widening
// (would then become a real narrowing conversion under -Wconversion).
template <typename Map>
std::vector<std::pair<std::uint16_t, float>>
encodeSet(const Map& src)
{
    std::vector<std::pair<std::uint16_t, float>> out;
    out.reserve(src.size());
    for (const auto& [id, fx] : src) {
        // f32 is the on-disk width (DB REAL column). Precision loss
        // matches the previous bytea codec exactly (§22.18 consequence
        // note: this refactor is byte-transparent for read/write, not
        // a widening).
        out.emplace_back(static_cast<std::uint16_t>(id), fx.toFloat());
    }
    std::sort(out.begin(), out.end(),
              [](const auto& a, const auto& b) { return a.first < b.first; });
    return out;
}

} // namespace

profile::PlayerProfile ProfileStore::loadOrCreate(PersonId person)
{
    auto rows_opt = db_.loadProfile(person);
    if (rows_opt.has_value()) {
        const auto& rows = *rows_opt;
        profile::PlayerProfile p;

        // M0: sim_player_attribute holds physical only. technical +
        // mental stay empty (M1+ multi-category encoding, §21.5 loose
        // end). Rows arrive ORDER BY attr_id ASC; the AttributeSet is a
        // sparse unordered_map so insertion order is irrelevant to
        // downstream determinism (the map itself is never iterated
        // outside encodeSet's sort).
        for (const auto& [attr_id, value] : rows.attributes) {
            p.physical.set(static_cast<AttrId>(attr_id),
                           math::Fixed64::fromFloat(value));
        }
        for (const auto& [concept_id, mastery] : rows.concepts) {
            p.concepts.plug(static_cast<ConceptId>(concept_id),
                            math::Fixed64::fromFloat(mastery));
        }
        for (const auto& [pattern_id, skill] : rows.recognition) {
            p.recognition.set(static_cast<PatternId>(pattern_id),
                              math::Fixed64::fromFloat(skill));
        }
        return p;
    }

    // First-touch: build M0 baseline, persist, return.
    profile::PlayerProfile p;
    p.physical = m0::defaultPhysical();
    p.concepts = m0::defaultConcepts();
    // technical, mental, recognition stay empty (M0).
    save(person, p);
    return p;
}

void ProfileStore::save(PersonId person, const profile::PlayerProfile& p)
{
    ProfileRows rows;
    rows.attributes  = encodeSet(p.physical.values());
    rows.concepts    = encodeSet(p.concepts.values());
    rows.recognition = encodeSet(p.recognition.values());
    db_.upsertProfile(person, rows);
}

} // namespace fh::sim::persistence
