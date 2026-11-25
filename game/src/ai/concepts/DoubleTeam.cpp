// game/src/ai/concepts/DoubleTeam.cpp — see DoubleTeam.hpp.

#include "ai/concepts/DoubleTeam.hpp"

#include "core/PlayerSkill.hpp"

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

void DoubleTeam::read(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot, int presser,
                      std::uint64_t match_seed) {
    DoubleTeamRead r;
    const auto& ball = w.ball();
    // A dead ball needs no check here: DefendingBlock::assign gives no presser unless the ball is live.
    if (!ball.owner || presser < 0 || *ball.owner >= team_of_slot.size() || team_of_slot[*ball.owner] == team ||
        w.isKeeper(*ball.owner)) { read_[team & 1] = r; return; }
    const int car = *ball.owner;
    const auto& cp = w.player(static_cast<core::SlotIndex>(car)).pos;
    // [behaviour: dt_trap_on_touchline]
    // recognise: the line is a defender — he is within trap_m of it, and our presser is on him.
    const Fixed64 to_line = w.pitchHalfY() - math::fx_abs(cp.y);
    if (to_line > p_.trap_m) { read_[team & 1] = r; return; }
    const auto& pp = w.player(static_cast<core::SlotIndex>(presser)).pos;
    const Vec2 pc{pp.x - cp.x, pp.y - cp.y};
    if (math::lengthSquared(pc) > p_.presser_m * p_.presser_m) { read_[team & 1] = r; return; }
    r.carrier = car;
    // The second man: our nearest other outfielder to him, inside join_m.
    Fixed64 bd{};
    for (std::uint8_t j = 0; j < w.playerCount() && j < team_of_slot.size(); ++j) {
        if (team_of_slot[j] != team || w.isKeeper(j) || j == presser) continue;
        const auto& jp = w.player(j).pos;
        const Fixed64 d = math::lengthSquared(Vec2{jp.x - cp.x, jp.y - cp.y});
        if (d > p_.join_m * p_.join_m) continue;
        if (r.second < 0 || d < bd) { r.second = j; bd = d; }
    }
    if (r.second < 0) { read_[team & 1] = r; return; }
    // His spot: inside the carrier, toward the middle of the pitch, level with him.
    r.spot = Vec2{cp.x, cp.y.raw >= 0 ? cp.y - p_.inside_m : cp.y + p_.inside_m};
    // [behaviour: dt_roll_per_spell]
    // choose: one roll a spell of the carrier's (the tick he got it), per side — the dial is the share trapped.
    if (p_.share.raw > 0) {
        const Fixed64 u = (core::detNoise(match_seed, w.ownedAtTick(), static_cast<std::uint8_t>(car), static_cast<std::uint8_t>(124 + (team & 1))) + Fixed64::one()) *
                          Fixed64::fromFraction(1, 2);   // [0, 1)
        r.chosen = u < p_.share;
    }
    read_[team & 1] = r;
}

}  // namespace fh::game::ai::concepts
