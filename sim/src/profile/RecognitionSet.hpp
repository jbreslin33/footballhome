// footballhome sim - RecognitionSet
//
// Per-pattern probability [0.0, 1.0] that a player correctly identifies the
// pattern per Recognition scan. Populated from sim_player_recognition rows
// (ADR §22.18, migration 205); in M0 the table is empty for every person,
// so every player is born with an empty RecognitionSet.
//
// This field is deliberately first-class from day 1 even though patterns
// don't exist until M4 — so the storage layout, wire format, and behavior
// signatures do not change when M4 lands.
//
// See DESIGN.md §5.2, §8, §11, §22.18.

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstddef>
#include <unordered_map>

namespace fh::sim::profile {

class RecognitionSet {
public:
    RecognitionSet() = default;

    // Returns 0.0 for absent patterns — a player with no entry for pattern
    // P recognises it with probability 0 (never sees it), which is exactly
    // the M0 identity-pass-through default when no patterns are registered.
    math::Fixed64 skill(PatternId id) const;

    bool          has(PatternId id) const;

    void          set(PatternId id, math::Fixed64 skill);
    void          erase(PatternId id);
    void          clear() noexcept { skill_.clear(); }

    std::size_t   size() const noexcept { return skill_.size(); }
    bool          empty() const noexcept { return skill_.empty(); }

    const std::unordered_map<PatternId, math::Fixed64>& values() const noexcept
    {
        return skill_;
    }

private:
    std::unordered_map<PatternId, math::Fixed64> skill_;
};

} // namespace fh::sim::profile
