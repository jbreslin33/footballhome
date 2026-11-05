// game/src/ai/DefendingBlock.hpp
//
// G5.21 (DESIGN §8.119): out of possession, rebuilt clean. The G4-era
// defending chain in Brain::decide (compactness cap, pre-offside depth cover,
// swarm, delay/organize/step, counter-press, recover, man-orientation
// marking, ~760 lines) is gone; this replaces it, fitted to pro data and
// grown only where a measured gap asks.
//
// A player state machine per man ([Buckland] State / StateMachine): his team's
// phase (TeamPhase) and the team's assignments (who chases a loose ball, who
// steps to their carrier) pick his state in Brain::think; the state turns
// the world into his orders.
//
//   Attacking       his team has it — the possession code (not yet rebuilt)
//   HoldBlockSpot   where a pro defender of his role stands for that ball
//   PressBall       the one man who steps to their carrier
//   ChaseBall       his team's first man to a loose ball
//
// The block spot is real data, not a rule: by role (CB, FB, 6/8, 10, 7/11,
// 9) and by the ball's distance from our line in 10 m bands, the mean metres
// off our own line a pro defender stands — DFL tracking (Bundesliga, Bassek
// et al. 2025, CC BY; benchmarks_tracking_possession.py DEFENDING SHAPE). No
// public PL 2015/16 tracking exists: these are pro tracking, not a PL figure.
// Across: the existing defendingY slide.

#pragma once

#include "ai/StateMachine.hpp"
#include "ai/TeamPhase.hpp"
#include "core/ModelParams.hpp"
#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai {

enum class Role : std::uint8_t { CB, FB, DM, AM, Wide, ST };
inline constexpr int kRoleCount = 6;
inline constexpr int kBandCount = 10;   // ball 0-10 … 90-100 m off our line
// By shirt number (the formation's numbered positions): 4/5 CB, 2/3 FB,
// 6/8 DM/CM, 10 AM, 7/11 wide, 9 ST; no number = a 6/8.
Role roleOfNumber(int number);

struct BlockParams {
    math::Fixed64 spot[kRoleCount][kBandCount]{};   // metres off our own line
    math::Fixed64 stand_off{};                      // presser: metres goal-side of their carrier
    math::Fixed64 switch_m{};                       // a new presser must be this much nearer
    math::Fixed64 tackle_per_s{};                   // in reach and goal-side: chance a second he dives
    void configure(const core::ModelParams& p);
};

// What a player state needs to know about one man this tick (Brain builds it).
struct PlayerView {
    std::uint8_t slot = 0;
    std::uint8_t team = 0;
    math::Fixed64 sg{};          // +1 attacks +x, -1 attacks -x
    Role role = Role::DM;
    math::Fixed64 across{};      // his lateral spot (defendingY)
    math::Vec2 chase_to{};       // where he takes the loose ball (the race read)
    std::uint64_t match_seed = 0;
};

class DefendingBlock;
struct PlayerAgent;
struct PlayerCtx {
    const core::World& world;
    const DefendingBlock& block;
    const TeamAgent& team;
    std::uint64_t tick;
};
using PlayerState = State<PlayerAgent, PlayerCtx>;

// A state that gives orders. Attacking gives none (the possession code does).
class ActingState : public PlayerState {
public:
    virtual bool act(const PlayerView& v, const PlayerCtx& c, core::MoveIntent& move, core::Action& action,
                     math::Vec2& target, std::int16_t& other) const = 0;
};

struct PlayerAgent {
    std::uint8_t slot = 0;
    StateMachine<PlayerAgent, PlayerCtx> machine;
};

class DefendingBlock {
public:
    void configure(const core::ModelParams& p) { params_.configure(p); }
    const BlockParams& params() const { return params_; }

    // Once a tick per team (Brain::think): who goes to a loose ball (the race
    // read's first man; on our own dead ball, its taker) and who steps to
    // their carrier (the nearest outfielder, held until another is switch_m
    // nearer).
    void assign(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                int first_to_ball, int restart_taker);
    int chaser(std::uint8_t team) const { return chaser_[team & 1]; }
    int presser(std::uint8_t team) const { return presser_[team & 1]; }
    void reset() { chaser_[0] = chaser_[1] = presser_[0] = presser_[1] = -1; }

    // His block spot: metres off our line for his role at the ball's distance
    // from it (interpolated between band centres), across from the view.
    math::Vec2 spot(const PlayerView& v, const core::World& world) const;

    // The player states (singletons).
    static const PlayerState* attacking();
    static const PlayerState* holdBlockSpot();
    static const PlayerState* pressBall();
    static const PlayerState* chaseBall();
    static const PlayerState* global();   // picks the state each tick

private:
    BlockParams params_{};
    int chaser_[2] = {-1, -1};
    int presser_[2] = {-1, -1};
};

}  // namespace fh::game::ai
