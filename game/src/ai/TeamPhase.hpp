// game/src/ai/TeamPhase.hpp
//
// G5.21 (DESIGN §8.119): the team layer — a state machine over the phases of
// play ([Buckland] team states; the coaching frame of in possession / out of
// possession / the two transitions / set pieces [FH coaching methodology]).
// Every player state reads its team's phase; nothing else decides "are we
// attacking or defending".
//
//   InPossession        our ball, settled
//   AttackingTransition we won it under transition_s ago
//   DefendingBlock      their ball, settled
//   DefensiveTransition we lost it under transition_s ago
//   OurSetPiece         a dead ball we take
//   TheirSetPiece       a dead ball they take
//
// Possession = the man on the ball's side; a loose ball in play stays with
// the side that touched it last (as DFL flags it); a dead ball with the side
// taking it. A change of side counts only once it has held min_dwell_s, so a
// ricochet between two men doesn't flip both teams' shapes for one tick.

#pragma once

#include "ai/StateMachine.hpp"
#include "core/World.hpp"
#include "math/Fixed64.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai {

enum class Phase : std::uint8_t {
    InPossession, AttackingTransition, DefendingBlock, DefensiveTransition, OurSetPiece, TheirSetPiece,
};
inline constexpr const char* kPhaseNames[] = {
    "in possession", "attacking transition", "defending block", "defensive transition",
    "our set piece", "their set piece",
};
inline constexpr int kPhaseCount = 6;

// DB rows physics.phase.* (game_model_params); defaults when a row is missing.
struct PhaseParams {
    // The transitions last this long after the ball changes side. Default 6 s:
    // the "six-second rule" of Guardiola's Barcelona counter-press [Perarnau,
    // Pep Confidential 2014] — a coaching convention, not a fit.
    std::uint32_t transition_ticks = 180;
    // A change of side has to hold this long (default 0.3 s) to count.
    std::uint32_t min_dwell_ticks = 9;
};

struct TeamAgent;
struct TeamCtx {
    const core::World& world;
    const std::vector<std::uint8_t>& team_of_slot;
    const PhaseParams& params;
    std::uint64_t tick;
};
using TeamState = State<TeamAgent, TeamCtx>;

struct TeamAgent {
    std::uint8_t team = 0;
    StateMachine<TeamAgent, TeamCtx> machine;
    // The side the ball is with as this team reads it (0xFF = nobody yet),
    // the side it is turning to, and since when.
    std::uint8_t side = 0xFF, pending = 0xFF;
    std::uint64_t pending_since = 0;
    bool dead = false;     // a dead ball (set piece) as last read

    Phase phase() const;
    bool ours() const { return side == team; }
};

// Which side has the ball and whether it is dead, read straight off the world.
struct BallSide { std::uint8_t side = 0xFF; bool dead = false; };
BallSide readBallSide(const core::World& world, const std::vector<std::uint8_t>& team_of_slot);

// The one state the team machine starts in; update() moves it.
const TeamState* teamStartState();
const TeamState* teamGlobalState();

}  // namespace fh::game::ai
