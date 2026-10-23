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

#include "ai/Concept.hpp"
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
    // G4.33: the class-based concepts read their numbers from the club DB
    // (game_model_params); without it they keep their seeded defaults.
    void setModelParams(const core::ModelParams& p) { book_.configure(p); }

    // Per-player level (G4.30): the band bent by the player's attributes.
    void setSlotLevel(core::SlotIndex slot, const core::LevelParams& lv) {
        if (slot_level_.size() <= slot) {
            slot_level_.resize(slot + 1u);
            slot_level_set_.resize(slot + 1u, 0);
        }
        slot_level_[slot] = lv;
        slot_level_set_[slot] = 1;
    }
    const core::LevelParams& levelOf(core::SlotIndex slot) const {
        return slot < slot_level_set_.size() && slot_level_set_[slot]
                   ? slot_level_[slot]
                   : level_[setup_.team_of_slot[slot]];
    }

    void setLevels(const core::LevelParams& home,
                   const core::LevelParams& away,
                   std::uint64_t match_seed) {
        level_[0] = home;
        level_[1] = away;
        match_seed_ = match_seed;
        // Reset every slot's knowledge to its band's default ratings.
        for (std::size_t i = 0; i < ratings_.size(); ++i) {
            ratings_[i] = core::defaultRatings(
                level_[setup_.team_of_slot[i]]);
        }
    }

    // Per-slot graded knowledge (game/CONCEPTS.md; 0-100 per concept).
    void setRatings(core::SlotIndex slot, const core::ConceptRatings& r) {
        if (slot < ratings_.size()) ratings_[slot] = r;
    }
    const core::ConceptRatings& ratings(core::SlotIndex slot) const {
        return ratings_[slot];
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
    // How many teammates are strictly closer to `target` (0 = I am
    // closest, 1 = I am the cover man, ...).
    int teamCloserCount(core::SlotIndex slot, const core::World& world,
                        const math::Vec3& target) const;

    TeamSetup setup_;
    math::Fixed64 half_x_, half_y_;
    FormationSpec spec_[2];
    core::LevelParams level_[2];
    ConceptBook book_;   // G4.33 class-based concepts
    // G4.30 per-player levels (perception, decisions, keeper reaction);
    // empty / unset = the team band.
    std::vector<core::LevelParams>  slot_level_;
    std::vector<std::uint8_t>       slot_level_set_;
    std::uint64_t match_seed_ = 0;
    std::vector<core::ConceptRatings> ratings_;
    // Graded application: does slot APPLY concept (bit index) this tick?
    // Consistency roll — deterministic noise vs the rating.
    bool applies(core::SlotIndex slot, int concept_idx,
                 std::uint64_t tick) const {
        const std::uint8_t r = ratings_[slot][concept_idx];
        if (r == 0) return false;
        if (r >= 100) return true;
        const auto n = core::detNoise(match_seed_, tick, slot,
                                      static_cast<std::uint8_t>(32 + concept_idx));
        return (n + math::Fixed64::one()) <
               math::Fixed64::fromFraction(r, 50);
    }
    // counter_attack (bit 23, G4.18): is slot's team inside its fast-break
    // window — ball won from the opponent IN OUR OWN HALF, within
    // 2 s + rating ticks? A rebound recovered in their box is a
    // scramble, not a transition (measured: those wins sit 0.6 s
    // before the goal and doubled world scoring when they counted).
    bool inCounterWindow(core::SlotIndex slot,
                         const core::World& world) const {
        const std::uint8_t r = ratings_[slot][23];
        const std::uint8_t team = setup_.team_of_slot[slot];
        if (r == 0 || world.lastLosingTeam() == 0xFF ||
            world.lastLosingTeam() == team)
            return false;
        if (world.tickCount() - world.turnoverTick() >=
            60 + static_cast<std::uint64_t>(r))
            return false;
        const math::Fixed64 x = world.turnoverBallX();
        return team == 0 ? x.raw < 0 : x.raw > 0;
    }
    // Magnitude helper: rating as a 0..1 Fixed64.
    math::Fixed64 degree(core::SlotIndex slot, int concept_idx) const {
        return math::Fixed64::fromFraction(ratings_[slot][concept_idx], 100);
    }
    // Per-slot index within its own team (formation base lookup).
    std::vector<std::uint8_t> index_in_team_;
    std::vector<std::uint8_t> team_size_;
};

}  // namespace fh::game::ai
