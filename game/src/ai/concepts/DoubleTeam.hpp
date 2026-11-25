// game/src/ai/concepts/DoubleTeam.hpp
//
// DOUBLE-TEAM — trap him on the touchline (game_concepts 12, double-team, "Trap on the touchline").
//
// The coaching: their man has the ball by the touchline and our presser is on him. The line is
// a defender too — he cannot go outside it. A second man comes across and closes the inside, the
// way back into the pitch, so the carrier is shut in between the two and the line, and either of
// them can take the ball. Real football (DFL, game/DESIGN.md §8.348 THE ENGAGE CUE): with a second
// defender inside 5 m a man on the ball is taken off his feet 0.66 times a second v 0.41 in ours —
// only our first presser ever tackled — and in their wide last third the ball is taken straight off
// the attacker's feet 11.4 a team-match v 5.5 (§8.347).
//
// Built as the taxonomy builds a concept (docs/taxonomy-one-system.md):
//
//   recognise   their carrier within trap_m of a touchline, our presser within presser_m of him;
//               the second man = our nearest other outfielder to the carrier, within join_m.
//               His spot: inside_m from the carrier toward the middle of the pitch, level with him.
//   choose      a dial, physics.press.double_team — the share of such spells we trap (one roll a
//               spell of theirs, per carrier). No row = 0: the read runs and nobody moves for it.
//   execute     DefendingBlock's DoubleTeamBall state: the second man runs to his spot, faces the
//               ball and, in reach, has his own tackle clock — the presser keeps his.
//
// Fixed point, deterministic (the roll is detNoise on the carrier's spell). The distances are
// [FH] coaching values, not fitted: the harness says how often (the dial) and whether it is real.

#pragma once

#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai::concepts {

struct DoubleTeamParams {
    using F = math::Fixed64;
    F share{};                              // physics.press.double_team: share of trap spells we take (0 = off)
    F trap_m = F::fromInt(12);              // the carrier this close to a touchline: the line can help
    F presser_m = F::fromInt(5);            // our presser this close to him: he is engaged
    F join_m = F::fromInt(15);              // the second man this close to the carrier: he can get there
    F inside_m = F::fromFraction(3, 2);     // his spot: this far inside the carrier, toward the middle
};

struct DoubleTeamRead {
    int carrier = -1;      // their man on the ball, trapped by the touchline
    int second = -1;       // our second man (-1 = no trap this tick)
    bool chosen = false;   // the dial's roll says we trap this spell
    math::Vec2 spot{};     // where the second man closes
};

class DoubleTeam {
public:
    void configure(const DoubleTeamParams& p) { p_ = p; }
    const DoubleTeamParams& params() const { return p_; }
    // One tick for `team`, the side without the ball, after its presser is known.
    void read(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot, int presser,
              std::uint64_t match_seed);
    const DoubleTeamRead& of(std::uint8_t team) const { return read_[team & 1]; }
    bool isSecond(std::uint8_t team, int slot) const { const auto& r = read_[team & 1]; return r.chosen && r.second == slot; }
    void reset() { read_[0] = read_[1] = DoubleTeamRead{}; }

private:
    DoubleTeamParams p_{};
    DoubleTeamRead read_[2]{};
};

}  // namespace fh::game::ai::concepts
