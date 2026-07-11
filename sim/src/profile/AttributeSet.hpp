// footballhome sim - AttributeSet
//
// Sparse map { AttrId → Fixed64 value } for one player, one category
// (physical, technical, or mental). AttributeSet is copied into the sim on
// match start and never mutated during a match.
//
// Byte format (persisted in `sim_player_profile.attributes`, §8):
//
//   [u16 count LE][ (u16 attr_id LE)(f32 value LE) ] × count
//
// The f32 on disk matches the DB's REAL source of truth and enables the
// SQL decode helper (§8.1). In-memory we work in Fixed64 for determinism.
// The f32 → Fixed64 conversion happens at load time; the reverse happens
// at save time. Neither is on the tick hot path.
//
// See DESIGN.md §5.2, §8.

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstddef>
#include <cstdint>
#include <span>
#include <unordered_map>
#include <vector>

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

    // Direct read-only access for iteration (deterministic order is NOT
    // guaranteed by unordered_map; use toBytes() when byte-identity matters).
    const std::unordered_map<AttrId, math::Fixed64>& values() const noexcept
    {
        return values_;
    }

    // Serialization -----------------------------------------------------
    // Emit records sorted by AttrId ascending so the byte layout is fully
    // deterministic regardless of insertion order.
    std::vector<std::uint8_t> toBytes() const;

    // Parse bytes in the format above. On malformed input (short buffer,
    // count/length mismatch), returns an empty set — the caller should
    // treat this as "no attributes present" and log at the persistence
    // boundary, not here.
    static AttributeSet fromBytes(std::span<const std::uint8_t> bytes);

private:
    std::unordered_map<AttrId, math::Fixed64> values_;
};

} // namespace fh::sim::profile
