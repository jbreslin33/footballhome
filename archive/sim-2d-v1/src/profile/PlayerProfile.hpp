// footballhome sim - PlayerProfile
//
// Aggregates the five per-player deterministic inputs: three AttributeSets
// (physical, technical, mental), one ConceptSet, and one RecognitionSet.
//
// Loaded from `sim_player_profile` at match start; never mutated during a
// match. All fields kept public because this struct is a pure data
// container — no invariants exist above the individual Sets.
//
// See DESIGN.md §5.2, §8.

#pragma once

#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"
#include "profile/RecognitionSet.hpp"

namespace fh::sim::profile {

struct PlayerProfile {
    AttributeSet   physical;
    AttributeSet   technical;
    AttributeSet   mental;
    ConceptSet     concepts;
    RecognitionSet recognition;
};

} // namespace fh::sim::profile
