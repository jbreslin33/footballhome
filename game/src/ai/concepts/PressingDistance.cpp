// game/src/ai/concepts/PressingDistance.cpp — see PressingDistance.hpp.

#include "ai/concepts/PressingDistance.hpp"

#include <algorithm>

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

void PressingDistance::clear(std::uint8_t team, const std::vector<std::uint8_t>& team_of_slot) {
    for (std::size_t s = 0; s < team_of_slot.size() && s < 32; ++s)
        if (team_of_slot[s] == team) reach_[s] = PressReach{};
}

// A ground pass of that length leaves at World::passSpeed and arrives at World::passArrive;
// the ball slows evenly over its distance, so its time is the length over the mean of the
// two. He covers nothing for his reaction, then runs; "on him" is arrive_m short of him.
Fixed64 PressingDistance::reachFor(const core::World& w, Fixed64 pass_m, Fixed64& ball_s) const {
    const Fixed64 mean = (w.passSpeed(pass_m) + w.passArrive(pass_m)) * Fixed64::fromFraction(1, 2);
    ball_s = mean.raw > 0 ? pass_m / mean : Fixed64::zero();
    const Fixed64 run_s = ball_s > p_.react_s ? ball_s - p_.react_s : Fixed64::zero();
    return p_.arrive_m + p_.run_mps * run_s;
}

void PressingDistance::read(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot,
                            const DirectOpponents& opp, const std::vector<Vec2>& place) {
    const int n = static_cast<int>(std::min<std::size_t>({team_of_slot.size(), static_cast<std::size_t>(w.playerCount()), 32}));
    const auto at = [&](int s) { const auto& p = w.player(static_cast<core::SlotIndex>(s)).pos; return Vec2{p.x, p.y}; };
    const Vec2 ball{w.ball().pos.x, w.ball().pos.y};
    const int on_ball = w.ball().owner ? static_cast<int>(*w.ball().owner) : -1;

    // Each of theirs once: how far a man can cover while a pass to him travels.
    std::array<Fixed64, 32> reach_to{}, ball_s{};
    for (int t = 0; t < n; ++t) {
        if (team_of_slot[t] == team || w.isKeeper(static_cast<core::SlotIndex>(t)) || t == on_ball) continue;
        reach_to[t] = reachFor(w, math::length(at(t) - ball), ball_s[t]);
    }

    for (int u = 0; u < n; ++u) {
        if (team_of_slot[u] != team) continue;
        PressReach r;
        r.man = opp.of(static_cast<core::SlotIndex>(u));
        if (r.man < 0 || r.man >= n) { r.man = -1; reach_[u] = r; continue; }
        const Vec2 me = at(u), him = at(r.man);
        r.gap_m = math::length(him - me);
        r.man_on_ball = r.man == on_ball;
        if (!r.man_on_ball) {
            // [behaviour: pd_reach_his_man]
            r.reach_m = reach_to[r.man];
            r.ball_s = ball_s[r.man];
            r.in = r.gap_m <= r.reach_m;
            // [behaviour: pd_step_into_distance]
            // From his PLACE (not from where he happens to be — the target must not chase his
            // own feet): the step toward his man that leaves the gap equal to his reach.
            const Vec2 to_man = him - place[u];
            const Fixed64 d = math::length(to_man);
            if (d > r.reach_m && d.raw > 0) {
                const Fixed64 need = std::min(d - r.reach_m, p_.max_step_m);
                r.step = Vec2{to_man.x * need / d, to_man.y * need / d};
            }
        }
        // [behaviour: pd_help_on_others]
        for (int t = 0; t < n; ++t) {
            if (t == r.man || team_of_slot[t] == team || w.isKeeper(static_cast<core::SlotIndex>(t)) || t == on_ball) continue;
            if (math::length(at(t) - me) <= reach_to[t] && r.help < 255) ++r.help;
        }
        reach_[u] = r;
    }
}

}  // namespace fh::game::ai::concepts
