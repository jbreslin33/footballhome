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

#include "ai/Formation.hpp"
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
    // Formation specs per team; an invalid/empty spec falls back to the
    // built-in for that team's size (tests and DB-down boots take this
    // path, so goldens never depend on the database).
    Brain(TeamSetup setup, math::Fixed64 pitch_half_x,
          math::Fixed64 pitch_half_y,
          FormationSpec home = {}, FormationSpec away = {});

    // Skill noise (G4.3): perception delay + decision jitter per team.
    // Defaults (zero) = the perfect-play baseline the goldens lock.
    void setLevels(const core::LevelParams& home,
                   const core::LevelParams& away,
                   std::uint64_t match_seed) {
        level_[0] = home;
        level_[1] = away;
        match_seed_ = match_seed;
    }

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
    FormationSpec spec_[2];
    core::LevelParams level_[2];
    std::uint64_t match_seed_ = 0;
    // Per-slot index within its own team (formation base lookup).
    std::vector<std::uint8_t> index_in_team_;
    std::vector<std::uint8_t> team_size_;
};

}  // namespace fh::game::ai
