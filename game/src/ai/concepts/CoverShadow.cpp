// game/src/ai/concepts/CoverShadow.cpp — see CoverShadow.hpp.

#include "ai/concepts/CoverShadow.hpp"

#include <algorithm>

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

void CoverShadows::clear(std::uint8_t team, const std::vector<std::uint8_t>& team_of_slot) {
    for (std::size_t s = 0; s < team_of_slot.size() && s < 32; ++s)
        if (team_of_slot[s] == team) hidden_[s] = 0;
    screen_[team & 1] = -1;
}

// From the ball, the man at `at` stands along the way to `their` and within body_m of that
// line: the ground pass goes through him.
bool CoverShadows::hides(Vec2 ball, Vec2 at, Vec2 their) const {
    const Vec2 v = their - ball;
    const Fixed64 L = math::length(v);
    if (L.raw <= 0) return false;
    const Vec2 r = at - ball;
    const Fixed64 along = (r.x * v.x + r.y * v.y) / L;
    if (along < p_.near_m || along > L - p_.behind_m) return false;
    const Fixed64 off = math::fx_abs(r.y * v.x - r.x * v.y) / L;
    return off <= p_.body_m;
}

void CoverShadows::read(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot, Fixed64 sg) {
    const int n = static_cast<int>(std::min<std::size_t>({team_of_slot.size(), static_cast<std::size_t>(w.playerCount()), 32}));
    const auto at = [&](int s) { const auto& p = w.player(static_cast<core::SlotIndex>(s)).pos; return Vec2{p.x, p.y}; };
    const Vec2 ball{w.ball().pos.x, w.ball().pos.y};
    const int on_ball = w.ball().owner ? static_cast<int>(*w.ball().owner) : -1;

    // [behaviour: cs_hidden_behind_him]
    for (int u = 0; u < n; ++u) {
        if (team_of_slot[u] != team) continue;
        std::uint32_t mask = 0;
        if (!w.isKeeper(static_cast<core::SlotIndex>(u)))
            for (int t = 0; t < n; ++t) {
                if (team_of_slot[t] == team || t == on_ball || w.isKeeper(static_cast<core::SlotIndex>(t))) continue;
                if (hides(ball, at(u), at(t))) mask |= std::uint32_t{1} << t;
            }
        hidden_[u] = mask;
    }

    // [behaviour: cs_pick_nearest_receiver]
    // Which pass the man closing the ball down should block: the nearest of the carrier's
    // mates who is level with him or nearer our goal. Ties fall to the lower slot.
    int screen = -1;
    if (on_ball >= 0 && team_of_slot[on_ball] != team) {
        const Vec2 c = at(on_ball);
        Fixed64 best{};
        for (int t = 0; t < n; ++t) {
            if (t == on_ball || team_of_slot[t] == team || w.isKeeper(static_cast<core::SlotIndex>(t))) continue;
            const Vec2 p = at(t);
            if ((p.x - c.x) * sg > p_.back_m) continue;          // back toward their own goal
            const Fixed64 d = math::length(p - c);
            if (d > p_.receiver_m) continue;
            if (screen < 0 || d < best) { best = d; screen = t; }
        }
    }
    screen_[team & 1] = screen;
}

}  // namespace fh::game::ai::concepts
