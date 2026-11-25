// game/src/ai/concepts/DirectOpponent.cpp — see DirectOpponent.hpp.

#include "ai/concepts/DirectOpponent.hpp"

#include <algorithm>
#include <string>

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

namespace {
// The owner's pairs of 10/24 (mig 694), used when the table sends none.
constexpr int kPairs[][2] = {{9, 4}, {9, 5}, {4, 9}, {5, 9}, {10, 6}, {6, 10}, {7, 2}, {2, 7}, {3, 11}, {11, 3}, {8, 8}};
// A wide number's twin on the other touchline: sides come from where the men stand, not
// from which of the two numbers a formation gave the left.
int twin(int n) { return n == 2 ? 3 : n == 3 ? 2 : n == 7 ? 11 : n == 11 ? 7 : 0; }
}  // namespace

DirectOpponents::DirectOpponents() {
    for (const auto& q : kPairs) pair_[q[0]] |= static_cast<std::uint16_t>(1u << q[1]);
}

void DirectOpponents::configure(const core::ModelParams& p) {
    std::array<std::uint16_t, 12> got{};
    bool any = false;
    for (int n = 1; n <= 11; ++n)
        for (int m = 1; m <= 11; ++m)
            if (p.fixed("concept.direct.pair_" + std::to_string(n) + "_" + std::to_string(m), 0).raw > 0) {
                got[n] |= static_cast<std::uint16_t>(1u << m);
                any = true;
            }
    if (any) pair_ = got;
}

bool DirectOpponents::partners(int a, int b) const {
    if (a < 1 || a > 11 || b < 1 || b > 11) return false;
    if (pair_[a] & (1u << b)) return true;
    // [behaviour: do_wide_by_touchline]
    const int ta = twin(a), tb = twin(b);
    return (ta && (pair_[ta] & (1u << b))) || (tb && (pair_[a] & (1u << tb))) || (ta && tb && (pair_[ta] & (1u << tb)));
}

void DirectOpponents::reset() {
    opp_.fill(-1);
    watcher_.fill(-1);
    how_.fill(PairHow::None);
    spare_[0] = spare_[1] = free_[0] = free_[1] = -1;
}

void DirectOpponents::clear(std::uint8_t team, const std::vector<std::uint8_t>& team_of_slot) {
    for (std::size_t s = 0; s < team_of_slot.size() && s < 32; ++s) {
        if (team_of_slot[s] == team) { opp_[s] = -1; how_[s] = PairHow::None; }
        else watcher_[s] = -1;
    }
    spare_[team & 1] = free_[team & 1] = -1;
}

void DirectOpponents::assign(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot,
                             const std::vector<Vec2>& place, Fixed64 goal_x,
                             const std::vector<std::int16_t>& number, const std::vector<Fixed64>& base_y) {
    const int n = static_cast<int>(std::min<std::size_t>({team_of_slot.size(), static_cast<std::size_t>(w.playerCount()), 32}));
    std::vector<int> ours, theirs;
    for (int s = 0; s < n; ++s) {
        if (w.isKeeper(static_cast<core::SlotIndex>(s))) continue;
        (team_of_slot[s] == team ? ours : theirs).push_back(s);
    }
    const std::array<int, 32> prev = opp_;
    clear(team, team_of_slot);
    if (ours.empty() || theirs.empty()) return;
    const auto at = [&](int s) { const auto& p = w.player(static_cast<core::SlotIndex>(s)).pos; return Vec2{p.x, p.y}; };
    const Vec2 ball{w.ball().pos.x, w.ball().pos.y};
    const auto num = [&](int s) { return s < static_cast<int>(number.size()) ? number[s] : 0; };
    const auto by = [&](int s) { return s < static_cast<int>(base_y.size()) ? base_y[s] : Fixed64::zero(); };
    // Two wide men pair only along the same touchline.
    const auto same_side = [&](int u, int t) {
        const Fixed64 a = by(u), b = by(t);
        if (math::fx_abs(a) < p_.wide_y || math::fx_abs(b) < p_.wide_y) return true;
        return (a.raw > 0) == (b.raw > 0);
    };
    const auto matched = [&](int u, int t) { return partners(num(u), num(t)) && same_side(u, t); };

    struct Pair { Fixed64 cost; int us, them; };
    // Closest first, nobody twice; ties to the lower slots, so the same world gives the same pairs.
    const auto settle = [&](std::vector<Pair>& pairs, PairHow how) {
        std::sort(pairs.begin(), pairs.end(), [](const Pair& a, const Pair& b) {
            if (a.cost != b.cost) return a.cost < b.cost;
            if (a.us != b.us) return a.us < b.us;
            return a.them < b.them;
        });
        for (const Pair& p : pairs) {
            if (opp_[p.us] >= 0 || watcher_[p.them] >= 0) continue;
            opp_[p.us] = p.them;
            watcher_[p.them] = p.us;
            how_[p.us] = how;
        }
    };
    // [behaviour: do_keep_until_better]
    const auto cost = [&](int u, Vec2 from, int t) {
        Fixed64 c = math::length(from - at(t));
        if (prev[u] == t) c -= p_.keep_m;
        return c;
    };

    // 1. The battle: the men in the ball's scene pair with who is actually there.
    // [behaviour: do_battle_near_ball]
    {
        std::vector<Pair> pairs;
        for (const int u : ours) {
            if (math::length(at(u) - ball) > p_.battle_m) continue;
            for (const int t : theirs)
                if (math::length(at(t) - ball) <= p_.battle_m) pairs.push_back({cost(u, at(u), t), u, t});
        }
        settle(pairs, PairHow::Battle);
    }
    // 2. The matchup by number, for everyone else: of his matchup men not already taken, the
    // nearer to his place.
    // [behaviour: do_matchup_by_number]
    {
        std::vector<Pair> pairs;
        for (const int u : ours) {
            if (opp_[u] >= 0) continue;
            for (const int t : theirs)
                if (watcher_[t] < 0 && matched(u, t)) pairs.push_back({cost(u, place[u], t), u, t});
        }
        settle(pairs, PairHow::Matchup);
    }
    // 3. One whose numbers find nobody in their shape at all takes the nearest man left. One
    // whose matchup man is taken by a team-mate keeps nobody: he is the spare man.
    // [behaviour: do_nearest_when_no_matchup]
    {
        std::vector<Pair> pairs;
        for (const int u : ours) {
            if (opp_[u] >= 0) continue;
            bool has = false;
            for (const int t : theirs) has = has || matched(u, t);
            if (has) continue;
            for (const int t : theirs)
                if (watcher_[t] < 0 && math::length(place[u] - at(t)) <= p_.nearest_max_m) pairs.push_back({cost(u, place[u], t), u, t});
        }
        settle(pairs, PairHow::Nearest);
    }

    // The spare man (+1) and the free man (-1), named for the viewer.
    // [behaviour: do_spare_man]
    Fixed64 best{};
    for (const int u : ours)
        if (opp_[u] < 0) {
            const Fixed64 d = math::fx_abs(place[u].x - goal_x);
            if (spare_[team & 1] < 0 || d < best) { best = d; spare_[team & 1] = u; }
        }
    // [behaviour: do_free_man]
    Fixed64 far{};
    for (const int t : theirs)
        if (watcher_[t] < 0) {
            const Fixed64 d = math::fx_abs(at(t).x - goal_x);
            if (free_[team & 1] < 0 || d > far) { far = d; free_[team & 1] = t; }
        }
}

}  // namespace fh::game::ai::concepts
