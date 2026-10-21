// game/src/ai/Brain.hpp
//
// First-generation team brain (G2.4): a deterministic, pure function of
// the World that produces one MoveIntent + Action per AI slot each tick.
// No RNG, no stored state beyond the static team setup — same world in,
// same orders out, on every architecture (DESIGN.md §3, §5).
//
// Behavior set ([FH] utility-lite; support-spot/role ideas trace to
// [Buckland] and [GRF]):
//   loose ball → each team's nearest player chases it; rest hold anchors
//   our ball   → AI carrier dribbles at the goal, shoots inside range;
//                teammates hold (ball-shifted) anchors = natural support
//   their ball → nearest player presses the carrier; rest hold anchors
// The three-layer architecture (team tactic → role → player utilities,
// DESIGN.md §5) grows out of exactly these hooks in later slices.

#pragma once

#include "core/World.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai {

struct TeamSetup {
    // team[slot] = 0 (home, attacks +x) or 1 (away, attacks -x).
    std::vector<std::uint8_t> team_of_slot;

    static TeamSetup splitHalves(std::uint8_t slot_count);
};

struct Orders {
    core::MoveIntent move;
    core::Action action = core::Action::None;
};

class Brain {
public:
    Brain(TeamSetup setup, math::Fixed64 pitch_half_x,
          math::Fixed64 pitch_half_y);

    // Orders for ONE slot given the current world. Pure + deterministic.
    Orders ordersFor(core::SlotIndex slot, const core::World& world) const;

private:
    int attackSign(core::SlotIndex slot) const {
        return setup_.team_of_slot[slot] == 0 ? +1 : -1;
    }
    // Is `slot` its team's closest player to `target` (ties → lower slot)?
    bool isTeamClosest(core::SlotIndex slot, const core::World& world,
                       const math::Vec3& target) const;

    TeamSetup setup_;
    math::Fixed64 half_x_, half_y_;
    // Per-slot index within its own team (formation base lookup).
    std::vector<std::uint8_t> index_in_team_;
    std::vector<std::uint8_t> team_size_;
};

}  // namespace fh::game::ai
