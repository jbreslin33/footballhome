// footballhome sim - ConceptSet
//
// Sparse map { ConceptId → mastery in Fixed64 [0.0, 1.0] } describing which
// AI behaviors a player has "unlocked" and how proficient they are.
//
// M0 uses only one concept, `run_to_point`, wired to WanderController.
// Real ConceptSets get populated in M3+.
//
// Storage: one row per (person_id, concept_id, mastery) in
// sim_player_concept (see ADR §22.18, migration 205). The in-memory
// class holds a sparse unordered_map; the persistence layer sorts by id
// on save/load for deterministic pg_dump / replay diffs.
//
// See DESIGN.md §5.2, §8, §22.18.

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstddef>
#include <unordered_map>

namespace fh::sim::profile {

class ConceptSet {
public:
    ConceptSet() = default;

    // Returns 0.0 for absent concepts — an absent concept is "no mastery",
    // which is the correct default for the behavior gate in §5.5.
    math::Fixed64 level(ConceptId id) const;

    // Convenience: does the player have concept `id` at ≥ min_mastery?
    // With the default min_mastery = 0, this checks presence with mastery > 0.
    bool          has(ConceptId id,
                      math::Fixed64 min_mastery = math::Fixed64::zero()) const;

    // Insert or update. We do not clamp to [0, 1] here — validation is a
    // policy concern at the persistence boundary, and clamping in the
    // hot-path getters would mask bugs.
    void          plug(ConceptId id, math::Fixed64 mastery);
    void          unplug(ConceptId id);
    void          clear() noexcept { mastery_.clear(); }

    std::size_t size() const noexcept { return mastery_.size(); }
    bool        empty() const noexcept { return mastery_.empty(); }

    const std::unordered_map<ConceptId, math::Fixed64>& values() const noexcept
    {
        return mastery_;
    }

private:
    std::unordered_map<ConceptId, math::Fixed64> mastery_;
};

} // namespace fh::sim::profile
