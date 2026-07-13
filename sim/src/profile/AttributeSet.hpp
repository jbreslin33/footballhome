// footballhome sim - AttributeSet
//
// Sparse map { AttrId → Fixed64 value } for one player, one category
// (physical, technical, or mental). AttributeSet is copied into the sim on
// match start and never mutated during a match.
//
// Storage: one row per (person_id, attr_id, value) in sim_player_attribute
// (see ADR §22.18 and migration 205). The on-disk value is REAL (f32) to
// match the DB source of truth; the persistence layer converts to Fixed64
// on load and back to f32 on save. Neither conversion is on the tick hot
// path. Load order is `ORDER BY attr_id ASC` for deterministic
// reconstruction; save order is sorted ascending for stable pg_dump diffs.
//
// See DESIGN.md §5.2, §8, §22.18.

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstddef>
#include <unordered_map>

namespace fh::sim::profile {

class AttributeSet {
public:
    AttributeSet() = default;

    // Accessors ---------------------------------------------------------
    math::Fixed64 get(AttrId id, math::Fixed64 default_value = math::Fixed64::zero()) const;
    bool          has(AttrId id) const;
    std::size_t   size() const noexcept { return values_.size(); }
    bool          empty() const noexcept { return values_.empty(); }

    // Mutators — used at profile-build time only, never in the tick loop.
    void          set(AttrId id, math::Fixed64 value);
    void          erase(AttrId id);
    void          clear() noexcept { values_.clear(); }

    // Direct read-only access for iteration. Deterministic order is NOT
    // guaranteed by unordered_map — the persistence layer sorts by id at
    // the save boundary (see ProfileStore::save).
    const std::unordered_map<AttrId, math::Fixed64>& values() const noexcept
    {
        return values_;
    }

private:
    std::unordered_map<AttrId, math::Fixed64> values_;
};

} // namespace fh::sim::profile
