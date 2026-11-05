// game/src/ai/Possession.cpp — in possession and the keeper (G5.22, DESIGN §8.120).
#include "ai/Possession.hpp"

#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "math/FixedMath.hpp"

#include <string>

namespace fh::game::ai {

using core::Action;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

// Real (DFL, 7 matches, the side IN possession, in play, 5 Hz): mean metres
// off THEIR line by role, ball in bands 0-10 … 90-100 m off it —
// benchmarks_tracking_possession.py POSSESSION SHAPE (§8.111).
constexpr int kRealSpotDm[kRoleCount][kBandCount] = {   // decimetres
    {377, 430, 488, 545, 602, 663, 721, 778, 832, 905},   // CB
    {292, 331, 386, 444, 500, 560, 608, 667, 728, 823},   // FB
    {255, 302, 359, 421, 477, 544, 601, 655, 708, 777},   // DM/CM
    {163, 217, 275, 340, 396, 460, 504, 557, 595, 656},   // AM
    {166, 209, 272, 334, 389, 449, 497, 546, 592, 667},   // WIDE
    {121, 162, 221, 284, 335, 388, 433, 474, 517, 574},   // ST
};
const char* const kRoleKey[kRoleCount] = {"cb", "fb", "dm", "am", "wide", "st"};
const Fixed64 kGoalHalfW = Fixed64::fromFraction(366, 100);   // Law 1: 7.32 m
const Fixed64 kSoftPass = Fixed64::fromInt(14);                // ShortPass inside it

Vec2 v2(const Vec3& p) { return Vec2{p.x, p.y}; }

int theirKeeper(const PlayerCtx& c, std::uint8_t team) {
    for (std::uint8_t j = 0; j < c.world.playerCount(); ++j)
        if (c.team_of_slot[j] != team && c.world.isKeeper(j)) return j;
    return -1;
}

// ── the carrier ────────────────────────────────────────────────────────
class OnBall final : public ActingState {
public:
    std::uint8_t id() const override { return 4; }
    const char* name() const override { return "on the ball"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const auto& P = c.poss.params();
        const auto& w = c.world;
        const auto& me = w.player(v.slot);
        const Vec2 sp = v2(me.pos);
        const Fixed64 hx = w.pitchHalfX();
        const Vec2 goal{v.sg * hx, Fixed64::zero()};
        const Fixed64 dgoal = math::length(Vec2{goal.x - sp.x, goal.y - sp.y});
        const Fixed64 depth = hx - sp.x * v.sg;            // metres off their line
        const Fixed64 own_end = hx + sp.x * v.sg;          // metres off our line

        if (!v.keeper) {
            // 1. A shot: in range with the goal open enough [FH; xG's angle + bodies].
            const Fixed64 q = chanceQuality(w, c.team_of_slot, v.slot, goal);
            if ((dgoal < P.shot_max_m && q >= P.shot_q_min) || (dgoal < P.shot_close_m && q.raw > 0)) {
                const int k = theirKeeper(c, v.team);
                const Fixed64 ky = k >= 0 ? w.player(static_cast<std::uint8_t>(k)).pos.y : Fixed64::zero();
                const Fixed64 side = ky > sp.y ? -Fixed64::one() : Fixed64::one();   // the post away from him
                o.target = Vec2{goal.x, side * (kGoalHalfW - Fixed64::fromFraction(1, 2))};
                o.move.move = math::normalized(Vec2{o.target.x - sp.x, o.target.y - sp.y});
                o.action = Action::Shot;
                o.why = Why::Shoot;
                return true;
            }
            // 2. A cross: wide, near their line — the freest man attacking the
            // box, else the penalty spot.
            if (depth <= P.cross_depth_m && math::fx_abs(sp.y) >= P.cross_wide_m) {
                int best = -1; Fixed64 bf{};
                for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                    if (j == v.slot || c.team_of_slot[j] != v.team || w.isKeeper(j)) continue;
                    const auto& m = w.player(j);
                    const Fixed64 md = hx - m.pos.x * v.sg;
                    if (md < Fixed64::fromInt(3) || md > Fixed64::fromInt(14) || math::fx_abs(m.pos.y) > Fixed64::fromInt(12)) continue;
                    Fixed64 free = Fixed64::fromInt(100);
                    for (std::uint8_t q2 = 0; q2 < w.playerCount(); ++q2) {
                        if (c.team_of_slot[q2] == v.team) continue;
                        const Fixed64 f = math::length(Vec2{w.player(q2).pos.x - m.pos.x, w.player(q2).pos.y - m.pos.y});
                        if (f < free) free = f;
                    }
                    if (best < 0 || free > bf) { best = j; bf = free; }
                }
                const Fixed64 reach = rangeFor(w.levelOf(v.slot), Fixed64::fromInt(45));
                if (best >= 0) {
                    const Loft lf = loftTo(w.ballFlight(), w.player(static_cast<std::uint8_t>(best)), me.pos, reach);
                    o.target = lf.at; o.carry_m = lf.carry_m;
                    o.other = static_cast<std::int16_t>(best);
                    o.pass_to = static_cast<std::uint8_t>(best);
                } else {
                    o.target = Vec2{v.sg * (hx - Fixed64::fromInt(11)), Fixed64::zero()};
                    o.carry_m = aimedCarry(me.pos, o.target, reach);
                }
                o.move.move = math::normalized(Vec2{o.target.x - sp.x, o.target.y - sp.y});
                o.action = Action::LoftedKick;
                o.why = Why::Cross;
                return true;
            }
        }
        // 3. The best safe pass: ground first, a loft to a man far off; the
        // race read decides "safe" (one of ours first) [Buckland].
        int best = -1; Fixed64 bs{}; bool loft = false; Loft blf{};
        const Fixed64 reach = rangeFor(w.levelOf(v.slot), Fixed64::fromInt(50));
        for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
            if (j == v.slot || c.team_of_slot[j] != v.team) continue;
            const auto& m = w.player(j);
            const Vec2 to = v2(m.pos);
            const Fixed64 d = math::length(Vec2{to.x - sp.x, to.y - sp.y});
            if (d < P.pass_min_m) continue;
            const Fixed64 gain = (to.x - sp.x) * v.sg;
            if (c.reads.passSafe(w, v.slot, sp, to, core::weightedPassSpeed(d), Fixed64::one())) {
                const Fixed64 s = gain - d * P.pass_len_cost;
                if (best < 0 || s > bs) { best = j; bs = s; loft = false; }
            } else if (d >= P.loft_min_m && d <= reach) {
                const Loft lf = loftTo(w.ballFlight(), m, me.pos, reach);
                if (c.reads.loftSafe(w, v.slot, sp, lf.at, lf.carry_m, Fixed64::one())) {
                    const Fixed64 s = gain - d * P.pass_len_cost - Fixed64::fromInt(5);
                    if (best < 0 || s > bs) { best = j; bs = s; loft = true; blf = lf; }
                }
            }
        }
        if (best >= 0) {
            const auto& m = w.player(static_cast<std::uint8_t>(best));
            o.other = static_cast<std::int16_t>(best);
            if (loft) {
                o.target = blf.at; o.carry_m = blf.carry_m; o.action = Action::LoftedKick;
                o.pass_to = static_cast<std::uint8_t>(best);
            } else {
                o.target = v2(m.pos);
                const Fixed64 d = math::length(Vec2{o.target.x - sp.x, o.target.y - sp.y});
                o.action = d < kSoftPass ? Action::ShortPass : Action::GroundKick;
            }
            o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 10));
            o.why = Why::Pass;
            return true;
        }
        // 4. Nothing safe: a keeper kicks it long; in our end, clear it.
        if (v.keeper || own_end < P.clear_from_m) {
            const Fixed64 len = v.keeper ? P.keeper_long_m : Fixed64::fromInt(45);
            o.target = Vec2{sp.x + v.sg * len, sp.y};
            o.carry_m = aimedCarry(me.pos, o.target, rangeFor(w.levelOf(v.slot), len));
            o.move.move = math::normalized(Vec2{o.target.x - sp.x, o.target.y - sp.y});
            o.action = Action::LoftedKick;
            o.why = v.keeper ? Why::KeeperPunt : Why::Clear;
            return true;
        }
        // 5. Carry: at goal, off the nearest man within 4 m.
        Vec2 dir = math::normalized(Vec2{goal.x - sp.x, goal.y - sp.y});
        int near = -1; Fixed64 nd = Fixed64::fromInt(16);
        for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
            if (c.team_of_slot[j] == v.team) continue;
            const Fixed64 d2 = distSq(w.player(j).pos, me.pos);
            if (d2 < nd) { nd = d2; near = j; }
        }
        if (near >= 0) {
            const auto& d = w.player(static_cast<std::uint8_t>(near));
            const Vec2 away = math::normalized(Vec2{sp.x - d.pos.x, sp.y - d.pos.y});
            dir = math::normalized(Vec2{dir.x + away.x * Fixed64::fromFraction(7, 10), dir.y + away.y * Fixed64::fromFraction(7, 10)});
        }
        o.target = Vec2{sp.x + dir.x * Fixed64::fromInt(5), sp.y + dir.y * Fixed64::fromInt(5)};
        o.move.move = dir;
        o.why = Why::Dribble;
        return true;
    }
};

// ── off the ball, ours ─────────────────────────────────────────────────
class Support final : public ActingState {
public:
    std::uint8_t id() const override { return 5; }
    const char* name() const override { return "support"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        Vec2 t = c.poss.spot(v, c.world);
        // Law 11: no further on than their second-last man (or the ball, or
        // halfway), less onside_margin_m.
        Fixed64 a{}, b{};   // their deepest two, in our attack direction
        bool ha = false, hb = false;
        for (std::uint8_t j = 0; j < c.world.playerCount(); ++j) {
            if (c.team_of_slot[j] == v.team) continue;
            const Fixed64 x = c.world.player(j).pos.x * v.sg;
            if (!ha || x > a) { b = a; hb = ha; a = x; ha = true; }
            else if (!hb || x > b) { b = x; hb = true; }
        }
        Fixed64 line = hb ? b : c.world.pitchHalfX();
        const Fixed64 bx = c.world.ball().pos.x * v.sg;
        if (bx > line) line = bx;
        if (line < Fixed64::zero()) line = Fixed64::zero();
        const Fixed64 lim = line - c.poss.params().onside_margin_m;
        if (t.x * v.sg > lim) t.x = lim * v.sg;
        o.target = t;
        o.move.move = seek(c.world.player(v.slot).pos, t, Fixed64::fromFraction(1, 2));
        o.why = Why::Hold;
        return true;
    }
};

// ── the pass is his ────────────────────────────────────────────────────
class Receive final : public ActingState {
public:
    std::uint8_t id() const override { return 6; }
    const char* name() const override { return "receive"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        Vec2 at{};
        if (!c.reads.getInLine(v.slot, c.world, at)) at = v.chase_to;
        const auto& me = c.world.player(v.slot);
        const auto& b = c.world.ball().pos;
        o.target = at;
        o.move.move = seek(me.pos, at, Fixed64::fromFraction(1, 10));
        o.move.face = Vec2{b.x - me.pos.x, b.y - me.pos.y};
        o.why = Why::MeetPass;
        return true;
    }
};

// ── the keeper, ball not his ───────────────────────────────────────────
class Keeper final : public ActingState {
public:
    std::uint8_t id() const override { return 7; }
    const char* name() const override { return "keeper"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const auto& P = c.poss.params();
        const auto& w = c.world;
        const auto& me = w.player(v.slot);
        const auto& ball = w.ball();
        const Vec2 g{-v.sg * w.pitchHalfX(), Fixed64::zero()};
        const Vec2 bg{ball.pos.x - g.x, ball.pos.y - g.y};
        const Fixed64 d = math::length(bg);
        Fixed64 depth = P.keeper_depth_m + P.keeper_depth_k * d;
        if (depth > P.keeper_depth_max_m) depth = P.keeper_depth_max_m;
        o.target = d.raw > 0 ? Vec2{g.x + bg.x * depth / d, g.y + bg.y * depth / d} : Vec2{g.x + v.sg * depth, g.y};
        o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 2));
        o.move.face = Vec2{ball.pos.x - me.pos.x, ball.pos.y - me.pos.y};
        o.why = Why::KeeperPosition;
        // A shot on goal he can't run to: dive at where it crosses his line.
        if (!ball.owner && w.restartTeam() == 0xFF && ball.vel.x * v.sg < Fixed64::fromInt(-8)) {
            const Fixed64 t = (me.pos.x - ball.pos.x) / ball.vel.x;
            if (t > Fixed64::zero() && t < Fixed64::fromFraction(6, 5)) {
                const Vec2 p{me.pos.x, ball.pos.y + ball.vel.y * t};
                if (math::fx_abs(p.y) < kGoalHalfW + Fixed64::fromInt(1)) {
                    const Fixed64 gap = math::length(Vec2{p.x - me.pos.x, p.y - me.pos.y});
                    if (gap > runToward(w, v.slot, p, t) + core::kKeeperReach) {
                        o.move.move = math::normalized(Vec2{p.x - me.pos.x, p.y - me.pos.y});
                        o.action = Action::Dive;
                        o.target = p;
                        o.why = Why::KeeperDive;
                    }
                }
            }
        }
        return true;
    }
};

const OnBall kOnBall;
const Support kSupport;
const Receive kReceive;
const Keeper kKeeper;

}  // namespace

const ActingState* Possession::onBall() { return &kOnBall; }
const ActingState* Possession::support() { return &kSupport; }
const ActingState* Possession::receive() { return &kReceive; }
const ActingState* Possession::keeper() { return &kKeeper; }

void PossessionParams::configure(const core::ModelParams& p) {
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kBandCount; ++b) {
            const std::string key = std::string("physics.support.") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5);
            spot[r][b] = p.fixed(key, std::int64_t{kRealSpotDm[r][b]} * 100);
        }
    // On-ball starting numbers [FH] — to be fitted to StatsBomb PL 2015/16
    // (shots, crosses, pass length and direction a team-match).
    shot_max_m = p.fixed("physics.onball.shot_max_m", 25000);
    shot_q_min = p.fixed("physics.onball.shot_q_min_rad", 200);
    shot_close_m = p.fixed("physics.onball.shot_close_m", 9000);
    cross_depth_m = p.fixed("physics.onball.cross_depth_m", 20000);
    cross_wide_m = p.fixed("physics.onball.cross_wide_m", 18000);
    clear_from_m = p.fixed("physics.onball.clear_from_m", 25000);
    pass_min_m = p.fixed("physics.onball.pass_min_m", 5000);
    pass_len_cost = p.fixed("physics.onball.pass_len_cost", 150);
    loft_min_m = p.fixed("physics.onball.loft_min_m", 25000);
    onside_margin_m = p.fixed("physics.support.onside_margin_m", 500);
    keeper_depth_m = p.fixed("physics.keeper.depth_m", 1000);
    keeper_depth_k = p.fixed("physics.keeper.depth_k", 80);
    keeper_depth_max_m = p.fixed("physics.keeper.depth_max_m", 12000);
    keeper_long_m = p.fixed("physics.restart.keeper_long_m", 55000);
}

Vec2 Possession::spot(const PlayerView& v, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_their = hx - world.ball().pos.x * v.sg;   // ball metres off their line
    const Fixed64 x = bandLookup(params_.spot[static_cast<int>(v.role)], off_their);
    return Vec2{(hx - x) * v.sg, v.across_ours};
}

}  // namespace fh::game::ai
