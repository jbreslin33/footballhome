// game/src/ai/concepts/PressingDistance.hpp
//
// STAY IN PRESSING DISTANCE — can I get to my man while a pass to him travels?
// (game_concepts pressing-distance.)
//
// Owner 2026-11-24: "lets focus on stay in pressing distance and fully finish it". The
// catalogue's cue: "Close enough to your man to reach him while a pass to him travels, and
// close enough to one or more other men to help on them too." It stands on the direct
// opponent (ai/concepts/DirectOpponent): his man must be known first.
//
// Built the way the taxonomy says a concept is built (docs/taxonomy-one-system.md):
//
//   recognise   for every defender with a man, two times are compared —
//                 the ball's:  how long a pass from where the ball is now takes to reach
//                              his man (the engine's own pass speed for that length);
//                 his:         his reaction, then the run over the gap to his man.
//               Put as a distance: his REACH — how far he can cover while that pass
//               travels. His man inside his reach = in pressing distance: the man gets no
//               free first touch. The reach shrinks as the ball comes nearer his man, so a
//               defender far from the ball may stand off and one near it must be tight.
//               Also counted: how many OTHER opponents are inside his reach (the help).
//   choose      a dial, physics.pressdist.hold — how much of the missing distance he takes
//               back. No row = 0: nobody moves for it and the sim is unchanged. The harness
//               decides whether a side is nearer real with it on.
//   execute     from his place in the shape, a step toward his man just long enough to put
//               him in reach again; if that spot is not goal side of his man, the spot on
//               his man's line to our goal, a reach off him, instead — never more than
//               max_step_m off his place.
//
// The man on the ball is not this concept: closing him down is the presser's job
// (game_concepts close-down, DefendingBlock's PressBall).
//
// Fixed point, no noise, no memory: the same world gives the same read. The reaction, the
// run pace and the arrive distance are [FH] coaching values, not fitted.

#pragma once

#include "ai/concepts/DirectOpponent.hpp"
#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>
#include <vector>

namespace fh::game::ai::concepts {

struct PressingDistanceParams {
    using F = math::Fixed64;
    F react_s = F::fromFraction(3, 10);    // the pass is struck → he is moving
    F run_mps = F::fromInt(6);             // his pace over a short run to a man, from a standing start
    F arrive_m = F::fromFraction(3, 2);    // "on him": this close as the ball arrives — no free first touch
    F max_step_m = F::fromInt(6);          // execute: never further than this off his place in the shape
};

// One defender's read this tick.
struct PressReach {
    int man = -1;                 // his direct opponent, or -1 (the spare man, a keeper, his side has the ball)
    bool man_on_ball = false;     // his man has it: the presser's business, not pressing distance
    bool in = false;              // his man is inside his reach
    // Owner 11/25: "being able to press but the player can dribble to our goal lol is bad as we are 'chasing'".
    // Goal side: he is nearer his own goal (its centre) than his man is — the man cannot run at goal past him.
    // Pressing distance done fully = in reach AND goal side; read on the wire, in the viewer and the clip judge,
    // and the step aims for it (with the dial on).
    bool goal_side = false;
    std::uint8_t help = 0;        // other opponents inside his reach for a pass to THEM
    math::Fixed64 gap_m{};        // him to his man
    math::Fixed64 reach_m{};      // how far he can cover while a pass to his man travels
    math::Fixed64 ball_s{};       // how long that pass takes
    math::Vec2 step{};            // execute: from his place, the step that puts his man in reach, goal side (zero when it is)
};

class PressingDistance {
public:
    // One tick for `team`, the side without the ball, after DirectOpponents::assign.
    // `place[slot]` is each of ours' place in the defensive shape.
    void read(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot,
              const DirectOpponents& opp, const std::vector<math::Vec2>& place);
    void clear(std::uint8_t team, const std::vector<std::uint8_t>& team_of_slot);
    void reset() { for (auto& r : reach_) r = PressReach{}; }

    const PressReach& of(core::SlotIndex slot) const { return reach_[slot & 31]; }
    const PressingDistanceParams& params() const { return p_; }

    // How far a man can cover while a pass of `pass_m` metres travels.
    math::Fixed64 reachFor(const core::World& w, math::Fixed64 pass_m, math::Fixed64& ball_s) const;

private:
    PressingDistanceParams p_{};
    std::array<PressReach, 32> reach_{};
};

}  // namespace fh::game::ai::concepts
