// game/src/ai/Brain.hpp
//
// G5.22 (DESIGN §8.120): the brain, rebuilt clean. James 11/5: "we need to
// again purge old stuff and start anew". Everything that decided — the G4
// priority chain, the concept classes, lapses, levels' noise, the call
// system, the look-age model — is gone. What is left here is the façade the
// server and tools drive:
//
//   think()     steps the state machines once a tick ([Buckland]): the team
//               phases (TeamPhase), the team's assignments, each man's state
//               (Players: DefendingBlock + Possession states);
//   ordersFor() his state's orders, then the laws and the body: a restart he
//               takes (G5.2, StatsBomb-sized), the law's distance from theirs,
//               out of their box on a goal kick, a pass named and weighted to
//               its man, brake to arrive (G4.80 + the DFL-fitted shape caps).
//
// Reads (the race, pass safety, chance quality, kick aiming) is what a
// player can predict — physics, kept whole.

#pragma once

#include "ai/DefendingBlock.hpp"
#include "ai/Formation.hpp"
#include "ai/Orders.hpp"
#include "ai/Players.hpp"
#include "ai/Possession.hpp"
#include "ai/Reads.hpp"
#include "ai/TeamPhase.hpp"
#include "core/ModelParams.hpp"
#include "core/World.hpp"

#include <cstdint>
#include <utility>
#include <vector>

namespace fh::game::ai {

struct TeamSetup {
    // team[slot] = 0 (home, attacks +x) or 1 (away, attacks -x).
    std::vector<std::uint8_t> team_of_slot;
    static TeamSetup splitHalves(std::uint8_t slot_count);
};

class Brain {
public:
    // Formation specs per team; an invalid/empty spec falls back to the
    // built-in for that team's size (tests and DB-down boots take this path).
    Brain(TeamSetup setup, math::Fixed64 pitch_half_x, math::Fixed64 pitch_half_y,
          FormationSpec home = {}, FormationSpec away = {});
    Brain(const Brain& o);
    Brain& operator=(const Brain& o);

    void setModelParams(const core::ModelParams& p);
    void setMatchSeed(std::uint64_t seed) { match_seed_ = seed; }
    // A restart shape (G4.58): while `team`'s dead ball waits, each listed slot
    // holds his mark facing the ball (the taker plays as usual).
    void setRestartShape(std::uint8_t team, std::vector<std::pair<std::uint8_t, math::Vec2>> marks) {
        hold_team_ = team; hold_ = std::move(marks);
    }
    void clearRestartShape() { hold_.clear(); hold_team_ = 0xFF; }

    // The state machines step once a tick — lazily, on the first ordersFor()
    // of a tick, so every driver gets it and later probes only read; a tick
    // that goes backwards (a new match) restarts them.
    void think(const core::World& world) const;
    Phase phaseOf(std::uint8_t team) const { return teams_[team & 1].phase(); }
    const PlayerState* stateOf(core::SlotIndex slot) const { return players_[slot & 31].machine.current(); }
    // Orders for ONE slot given the current world (deterministic).
    Orders ordersFor(core::SlotIndex slot, const core::World& world) const;
    // The trainer's label for an outfielder out of possession (Act::None otherwise), from his
    // state and the orders he was just given (docs/tactics-trainer.md step 1).
    Act actOf(core::SlotIndex slot, const core::World& world, const Orders& o) const;

    // A slot's position number (2 RB … 9 striker; 0 = unknown).
    int numberOf(core::SlotIndex slot) const {
        return spec_[setup_.team_of_slot[slot]].positions[index_in_team_[slot]].number;
    }
    // A slot's role as the brain plays it (formation role name first, then number).
    const Possession& possession() const { return poss_; }
    const std::vector<std::uint8_t>& teamOfSlot() const { return setup_.team_of_slot; }   // the harness reads the line jobs (§8.150)
    Role roleOf(core::SlotIndex slot) const { return slot < role_of_slot_.size() ? role_of_slot_[slot] : Role::DM; }
    using FlightRead = Reads::FlightRead;
    const FlightRead& flightRead(const core::World& world) const { return reads_.flightRead(world); }
    const Reads& reads() const { return reads_; }
    int restartTaker(const core::World& world, std::uint8_t team) const;
    // Harness probe: the target his state gave him this tick.
    math::Vec2 debugAnchor(core::SlotIndex slot) const { return dbg_anchor_[slot & 31]; }

private:
    PlayerView viewOf(core::SlotIndex slot, const core::World& world) const;
    bool actAs(const ActingState* st, core::SlotIndex slot, const core::World& world, Orders& o) const;
    bool takeRestart(core::SlotIndex slot, const core::World& world, Orders& out) const;
    bool playThrow(core::SlotIndex slot, const core::World& world, Orders& out) const;
    bool playCorner(core::SlotIndex slot, const core::World& world, Orders& out) const;
    bool playPenalty(core::SlotIndex slot, const core::World& world, Orders& out) const;
    void penaltyPlaces(core::SlotIndex slot, const core::World& world, Orders& o) const;
    void keepLawDistance(core::SlotIndex slot, const core::World& world, Orders& o) const;
    void outOfTheirBox(core::SlotIndex slot, const core::World& world, Orders& o) const;
    void namePass(core::SlotIndex slot, const core::World& world, Orders& o) const;
    math::Vec2 blockLead(core::SlotIndex slot, const core::World& world, const Orders& o) const;
    void capAcross(core::SlotIndex slot, const core::World& world, Orders& o) const;
    bool inDanger(core::SlotIndex slot, const core::World& world) const;
    bool lineRun(core::SlotIndex slot, const core::World& world, const Orders& o) const;   // G5.94 (§8.195)
    bool ourBall(core::SlotIndex slot, const core::World& world) const;   // G5.95 (§8.196)
    void brakeToArrive(core::SlotIndex slot, const core::World& world, Orders& o, math::Vec2 lead = {}) const;
    void wingBack(const FormationSpec::Pos& mine, PlayerView& v) const;
    math::Fixed64 acrossDef(const math::Vec2& base, const PlayerView& v) const;
    math::Fixed64 slideY(const math::Vec2& base, math::Fixed64 ball_y, math::Fixed64 shift, math::Fixed64 cap) const;

    TeamSetup setup_;
    math::Fixed64 half_x_, half_y_;
    FormationSpec spec_[2];
    std::vector<std::uint8_t> index_in_team_;
    std::uint64_t match_seed_ = 0;

    // The machines and what they read.
    Reads reads_;
    mutable DefendingBlock block_{};
    mutable Possession poss_{};
    std::vector<Role> role_of_slot_;
    PhaseParams phase_params_{};
    mutable TeamAgent teams_[2];
    mutable PlayerAgent players_[32];
    mutable std::uint64_t think_tick_ = ~0ull;
    mutable math::Vec2 dbg_anchor_[32]{};

    // Restarts (G5.2, mig 922: StatsBomb PL 2015/16 throws and corners).
    struct RestartPlay {
        std::int32_t throw_look_ticks = 30, throw_wait_ticks = 120, corner_look_ticks = 45, keeper_wait_ticks = 90;
        math::Fixed64 throw_min_m = math::Fixed64::fromInt(4), throw_room_m = math::Fixed64::fromInt(10),
                      throw_free_m = math::Fixed64::fromInt(3), throw_gain = math::Fixed64::fromFraction(3, 10),
                      keeper_long_m = math::Fixed64::fromInt(55), throw_law_m = math::Fixed64::fromInt(2),
                      kick_law_m = math::Fixed64::fromFraction(915, 100),
                      penalty_arc_m = math::Fixed64::fromFraction(915, 100);
    } restart_play_;
    std::uint8_t hold_team_ = 0xFF;
    std::vector<std::pair<std::uint8_t, math::Vec2>> hold_;

    // The body (G4.80 brake to arrive; G5.5 / G5.10 / G5.14 shape caps, DFL-fitted).
    math::Fixed64 arrive_decel_ = math::Fixed64::fromFraction(9, 2);
    math::Fixed64 arrive_through_ = math::Fixed64::fromInt(3);
    math::Fixed64 track_ball_m_ = math::Fixed64::fromInt(3);   // physics.receive.track_m (G5.58)
    math::Fixed64 shape_tau_{}, shape_tau_ours_{}, shape_max_{}, defend_max_{}, shape_danger_{}, tau_back_{}, wb_tuck_y_{};
    math::Fixed64 run_max_{}, run_zone_{}, run_tgap_{}, run_tau_{}, shift_fwd_max_{};   // G5.94 (§8.195): a run at their line, not a shape shift (run_max 0 = off)
    std::int64_t shape_danger_sprint_ = 0;
    // Across (G5.7): his base's y plus the ball's y × shift, capped.
    math::Fixed64 theirs_shift_y_{}, theirs_cap_y_{}, ours_shift_y_{}, ours_cap_y_{};
    math::Fixed64 trainer_recover_m_ = math::Fixed64::fromInt(5);
};

}  // namespace fh::game::ai
