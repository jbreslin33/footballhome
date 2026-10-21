// game/src/ai/Formation.hpp
//
// Formation shapes + ball-relative anchoring.
//
// A formation is a list of base positions in NORMALIZED coordinates for a
// team DEFENDING x = -1 and attacking x = +1: base.x in [-1, 0] (own half
// at kickoff shape), base.y in [-1, +1] across the width. anchorFor() maps
// a base to pitch metres for either attack direction and shifts the whole
// shape toward the ball — [HELIOS]-lite: HELIOS/agent2d interpolates home
// positions over a Delaunay triangulation of trained ball positions; v0
// uses a clamped linear translation, which already reads as "the block
// slides with play". The full interpolation + the DB-backed formation
// registry ([v1] migration→codegen pattern) replace these in-code specs in
// a dedicated slice — this file is the documented stopgap (DESIGN.md §8.3).

#pragma once

#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai {

// A formation shape: normalized bases + keeper flags. Sourced either from
// the club's `formations` table (persistence/FormationStore) or from the
// built-ins below.
struct FormationSpec {
    struct Pos {
        math::Vec2 base;
        bool keeper = false;
    };
    std::vector<Pos> positions;

    bool valid(std::uint8_t team_size) const {
        return positions.size() == team_size;
    }
};

// Base positions for a team of `n`, normalized as described above.
// Index 0 is the goalkeeper when n >= 5.
std::vector<math::Vec2> formationBases(std::uint8_t n);

// The in-code fallback spec (same numbers as formationBases; keeper is
// index 0 for teams of 5+). Used when the DB is unavailable and by tests.
FormationSpec builtinFormation(std::uint8_t n);

// Pitch-space anchor for one team member.
//   base        normalized base from formationBases
//   attack_sign +1 attacks +x, -1 attacks -x
//   ball        current ball position (pitch metres)
//   half_x/y    pitch half extents
// The shape translates toward the ball by kShift* (capped), then clamps
// inside the pitch with a margin. The GK (is_keeper) ignores the x shift
// beyond a short leash from its goal line.
math::Vec2 anchorFor(const math::Vec2& base, int attack_sign,
                     const math::Vec3& ball, math::Fixed64 half_x,
                     math::Fixed64 half_y, bool is_keeper);

}  // namespace fh::game::ai
