// game/src/ai/DefendingBlock.hpp
//
// G5.21 (DESIGN §8.119): out of possession, rebuilt clean on the player state
// machines (Players.hpp). States: HoldBlockSpot, PressBall, ChaseBall.
//
// The block spot is real data, not a rule: by role and by the ball's
// distance from our line in 10 m bands, the mean metres off our own line a
// pro defender stands — DFL tracking (Bundesliga, Bassek et al. 2025, CC BY;
// benchmarks_tracking_possession.py DEFENDING SHAPE). No public PL 2015/16
// tracking exists: these are pro tracking, not a PL figure. Across: slideY.
//
// The team's assignments, once a tick: the loose ball's man (our pass: the
// man it's for, unless they get there first; else the race read's first; our
// own dead ball: its taker), and the ONE man who steps to their carrier (the
// nearest outfielder, held until another is switch_m nearer).

#pragma once

#include "ai/Players.hpp"
#include "core/ModelParams.hpp"

namespace fh::game::ai {

struct BlockParams {
    math::Fixed64 spot[kRoleCount][kBandCount]{};   // metres off our own line
    math::Fixed64 stand_off{};                      // presser: metres goal-side of their carrier
    math::Fixed64 switch_m{};                       // a new presser / chaser must be this much nearer
    math::Fixed64 tackle_per_s{};                   // in reach and goal-side: chance a second he dives
    void configure(const core::ModelParams& p);
};

class DefendingBlock {
public:
    void configure(const core::ModelParams& p) { params_.configure(p); }
    const BlockParams& params() const { return params_; }

    void assign(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                const Reads::FlightRead& fr, int restart_taker);
    int chaser(std::uint8_t team) const { return chaser_[team & 1]; }
    int presser(std::uint8_t team) const { return presser_[team & 1]; }
    void reset() { chaser_[0] = chaser_[1] = presser_[0] = presser_[1] = -1; }

    math::Vec2 spot(const PlayerView& v, const core::World& world) const;

    static const ActingState* holdBlockSpot();
    static const ActingState* pressBall();
    static const ActingState* chaseBall();

private:
    BlockParams params_{};
    int chaser_[2] = {-1, -1};
    int presser_[2] = {-1, -1};
};

}  // namespace fh::game::ai
