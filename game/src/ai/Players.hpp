// game/src/ai/Players.hpp
//
// G5.22 (DESIGN §8.120): the player layer — one state machine per man
// ([Buckland] State / StateMachine). His team's phase (TeamPhase) and the
// team's assignments (who takes the loose ball, who steps to their carrier)
// pick his state once a tick in Brain::think (the global state, Pick); the
// state turns the world into his orders.
//
//   in possession              out of possession
//   ─────────────              ─────────────────
//   OnBall    he has it        HoldBlockSpot  his role's real spot
//   Support   his role's spot  PressBall      the one man on their carrier
//   Receive   the pass is his  ChaseBall      his team's first to a loose ball
//   Keeper    set position (keeper, ball not his)
//
// States live in Possession.cpp and DefendingBlock.cpp; the data each reads
// (the real spots, the on-ball numbers) in Possession / DefendingBlock.

#pragma once

#include "ai/Orders.hpp"
#include "ai/Reads.hpp"
#include "ai/StateMachine.hpp"
#include "ai/TeamPhase.hpp"
#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <string>
#include <vector>

namespace fh::game::ai {

enum class Role : std::uint8_t { CB, FB, DM, AM, Wide, ST };
inline constexpr int kRoleCount = 6;
inline constexpr int kBandCount = 10;   // ball 0-10 … 90-100 m off a goal line
// By shirt number: 4/5 CB, 2/3 FB, 6/8 DM/CM, 10 AM, 7/11 wide, 9 ST; else a 6/8.
Role roleOfNumber(int number);
// G5.36: his slot's role (formation_slot_roles.role) where it is known — the
// 6 in a back three is a centre-back, the 9 in a 3-5-2's midfield three a
// midfielder; else by his number. A wing-back is a full-back here (his
// spots by the ball's side: Brain::viewOf).
Role roleOfSlot(const std::string& role, int number);
// A 10-band real table (metres off a line, by role and the ball's metres off
// it), interpolated between band centres 5, 15, … 95; flat beyond the ends.
math::Fixed64 bandLookup(const math::Fixed64 (&row)[kBandCount], math::Fixed64 ball_off_line);

// What a state needs to know about one man this tick (Brain builds it).
struct PlayerView {
    std::uint8_t slot = 0;
    std::uint8_t team = 0;
    math::Fixed64 sg{};          // +1 attacks +x, -1 attacks -x
    Role role = Role::DM;        // without the ball (a wing-back: by the ball's side)
    Role role_ours = Role::DM;   // with it (a wing-back: wide)
    bool keeper = false;
    math::Fixed64 across_def{};  // his lateral spot without the ball (slideY)
    math::Fixed64 across_ours{}; // ...with it
    bool lone_ours = false;      // G5.120: the only man of his role_ours in his side (a lone DM / AM / ST picks a side a spell)
    math::Vec2 chase_to{};       // where he takes the loose ball (the race read)
    math::Vec2 ball_to{};        // where the ball is going: a free ball's first taker's point, else the ball
    std::uint64_t match_seed = 0;
};

class DefendingBlock;
class Possession;
struct PlayerAgent;
struct PlayerCtx {
    const core::World& world;
    const std::vector<std::uint8_t>& team_of_slot;
    const DefendingBlock& block;
    const Possession& poss;
    const Reads& reads;
    const TeamAgent& team;
    std::uint64_t tick;
};
using PlayerState = State<PlayerAgent, PlayerCtx>;

// A state that gives orders.
class ActingState : public PlayerState {
public:
    void execute(PlayerAgent&, const PlayerCtx&) const override {}
    virtual bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const = 0;
};

struct PlayerAgent {
    std::uint8_t slot = 0;
    StateMachine<PlayerAgent, PlayerCtx> machine;
};

// Picks every man's state each tick (the machine's global state).
const PlayerState* playerGlobalState();
const PlayerState* playerStartState();

}  // namespace fh::game::ai
