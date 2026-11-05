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

// The pass policy's zones: metres from THEIR line in 0-18 / 18-35 / 35-52 /
// 52-70 / 70+ × centre (|y| < 20.16, the box's width) or wide.
int zoneOf(Fixed64 hx, const Vec2& p, Fixed64 sg) {
    const Fixed64 d = hx - p.x * sg;
    const int b = d < Fixed64::fromInt(18) ? 0 : d < Fixed64::fromInt(35) ? 1 : d < Fixed64::fromInt(52) ? 2 : d < Fixed64::fromInt(70) ? 3 : 4;
    return b * 2 + (math::fx_abs(p.y) < Fixed64::fromFraction(2016, 100) ? 0 : 1);
}

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
            // 1. A shot — the real policy (StatsBomb PL 2015/16): the share of
            // releases at his spot that are shots, by distance × the goal mouth's
            // angle; one roll for the spell, so the World's release (his real
            // time on the ball) lets go the shot or the pass it was going to be.
            const int db = dgoal < Fixed64::fromInt(12) ? 0 : dgoal < Fixed64::fromInt(18) ? 1
                         : dgoal < Fixed64::fromInt(25) ? 2 : dgoal < Fixed64::fromInt(35) ? 3 : -1;
            if (db >= 0) {
                const Fixed64 a1 = math::fx_atan2(-kGoalHalfW - sp.y, goal.x - sp.x);
                const Fixed64 a2 = math::fx_atan2(kGoalHalfW - sp.y, goal.x - sp.x);
                const Fixed64 ang = math::fx_abs(a2 - a1);
                const int ab = ang < Fixed64::fromFraction(1, 4) ? 0 : ang < Fixed64::fromFraction(1, 2) ? 1 : 2;
                const Fixed64 u = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 40) + Fixed64::one()) *
                                  Fixed64::fromFraction(1, 2);
                if (u < P.shot_p[db][ab]) {
                    const int k = theirKeeper(c, v.team);
                    const Fixed64 ky = k >= 0 ? w.player(static_cast<std::uint8_t>(k)).pos.y : Fixed64::zero();
                    const Fixed64 side = ky > sp.y ? -Fixed64::one() : Fixed64::one();   // the post away from him
                    o.target = Vec2{goal.x, side * (kGoalHalfW - Fixed64::fromFraction(1, 2))};
                    o.move.move = math::normalized(Vec2{o.target.x - sp.x, o.target.y - sp.y});
                    o.action = Action::Shot;
                    o.why = Why::Shoot;
                    return true;
                }
            }
        }
        // 2. A pass — the real policy (StatsBomb PL 2015/16 open play). Each
        // mate's weight is the share of real passes from this zone to his zone,
        // split among the mates standing there; only passes the race read says
        // we win (ground, else lofted) stay in; one roll for the spell picks.
        const int oz = zoneOf(hx, sp, v.sg);
        int in_zone[10] = {};
        for (std::uint8_t j = 0; j < w.playerCount(); ++j)
            if (j != v.slot && c.team_of_slot[j] == v.team) ++in_zone[zoneOf(hx, v2(w.player(j).pos), v.sg)];
        struct Cand { int j; Fixed64 wgt; bool loft; Loft lf; };
        Cand cand[32]; int nc = 0; Fixed64 sum{};
        const Fixed64 reach = rangeFor(w.skillOf(v.slot), Fixed64::fromInt(50));
        for (std::uint8_t j = 0; j < w.playerCount() && nc < 32; ++j) {
            if (j == v.slot || c.team_of_slot[j] != v.team) continue;
            const auto& m = w.player(j);
            const Vec2 to = v2(m.pos);
            const Fixed64 d = math::length(Vec2{to.x - sp.x, to.y - sp.y});
            if (d < P.pass_min_m) continue;
            const int ez = zoneOf(hx, to, v.sg);
            const Fixed64 wgt = P.pass_to[oz][ez] / Fixed64::fromInt(in_zone[ez]);
            if (wgt.raw <= 0) continue;
            if (c.reads.passSafe(w, v.slot, sp, to, core::weightedPassSpeed(d), Fixed64::one())) {
                cand[nc++] = Cand{j, wgt, false, Loft{}};
                sum += wgt;
            } else {
                const Loft lf = loftTo(w.ballFlight(), m, me.pos, reach);
                if (d <= reach && c.reads.loftSafe(w, v.slot, sp, lf.at, lf.carry_m, Fixed64::one())) {
                    cand[nc++] = Cand{j, wgt, true, lf};
                    sum += wgt;
                } else if (P.risk_weight.raw > 0) {
                    // Real passes fail 21% of the time: a pass the read says they
                    // win is still tried, at risk_weight of its share (fitted to
                    // the real 79.1% completion, StatsBomb PL 2015/16).
                    cand[nc++] = Cand{j, wgt * P.risk_weight, false, Loft{}};
                    sum += wgt * P.risk_weight;
                }
            }
        }
        if (nc > 0) {
            const Fixed64 u = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 41) + Fixed64::one()) *
                              Fixed64::fromFraction(1, 2) * sum;
            int k = 0; Fixed64 acc = cand[0].wgt;
            while (k + 1 < nc && acc < u) { ++k; acc += cand[k].wgt; }
            const Cand& ch = cand[k];
            const auto& m = w.player(static_cast<std::uint8_t>(ch.j));
            const int ez = zoneOf(hx, v2(m.pos), v.sg);
            // A ball into the box from wide goes in the air at the real cross share;
            // any other pass lofted at the zone's real loft share, if the loft is safe.
            const Fixed64 u2 = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 42) + Fixed64::one()) *
                               Fixed64::fromFraction(1, 2);
            const bool into_box = ez == 0 && oz != 0;
            bool air = ch.loft;
            bool crossed = false;
            Loft lf = ch.lf;
            // P(in the air | into the box) = the zone's crosses / its passes into the box.
            Fixed64 p_air = P.pass_loft[oz];
            if (into_box && P.pass_to[oz][0].raw > 0) {
                p_air = P.pass_cross[oz] / P.pass_to[oz][0];
                if (p_air > Fixed64::one()) p_air = Fixed64::one();
            }
            if (!air && u2 < p_air) {
                const Loft l2 = loftTo(w.ballFlight(), m, me.pos, reach);
                if (c.reads.loftSafe(w, v.slot, sp, l2.at, l2.carry_m, Fixed64::one())) { air = true; lf = l2; crossed = into_box; }
            }
            o.other = static_cast<std::int16_t>(ch.j);
            if (air) {
                o.target = lf.at; o.carry_m = lf.carry_m; o.action = Action::LoftedKick;
                o.pass_to = static_cast<std::uint8_t>(ch.j);
                o.why = (crossed || (into_box && math::fx_abs(sp.y) >= Fixed64::fromFraction(2016, 100))) ? Why::Cross : Why::Pass;
            } else {
                o.target = v2(m.pos);
                const Fixed64 d = math::length(Vec2{o.target.x - sp.x, o.target.y - sp.y});
                o.action = d < kSoftPass ? Action::ShortPass : Action::GroundKick;
                o.why = Why::Pass;
            }
            o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 10));
            return true;
        }
        // 4. Nothing safe: a keeper kicks it long; in our end, clear it.
        if (v.keeper || own_end < P.clear_from_m) {
            const Fixed64 len = v.keeper ? P.keeper_long_m : Fixed64::fromInt(45);
            o.target = Vec2{sp.x + v.sg * len, sp.y};
            o.carry_m = aimedCarry(me.pos, o.target, rangeFor(w.skillOf(v.slot), len));
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

// ── into the box ───────────────────────────────────────────────────────
// His team picked him to be in the box for this ball: a spot at the real
// depth (metres off their line) and width (|y|) for the ball's zone, the k-th
// runner on the next spot across (ball side first), kept onside.
class AttackBox final : public ActingState {
public:
    std::uint8_t id() const override { return 8; }
    const char* name() const override { return "attack the box"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const auto& P = c.poss.params();
        const int z = c.poss.ballZone(v.team);
        if (z < 0) return false;
        const Fixed64 hx = c.world.pitchHalfX();
        const Fixed64 by = c.world.ball().pos.y;
        const Fixed64 side = by.raw >= 0 ? Fixed64::one() : -Fixed64::one();
        const int k = c.poss.runnerIndex(v.slot);
        // Spots: ball side at |y|, then far side, then the middle, then again deeper.
        static const int kSide[4] = {1, -1, 0, 1};
        const Fixed64 y = side * P.box_ay[z] * Fixed64::fromInt(kSide[k & 3]);
        const Fixed64 depth = P.box_depth[z] - Fixed64::fromInt(3) * Fixed64::fromInt(k / 4);
        Vec2 t{(hx - depth) * v.sg, y};
        // Law 11: no further on than their second-last man (or the ball), less a margin.
        Fixed64 a{}, b{}; bool ha = false, hb = false;
        for (std::uint8_t j = 0; j < c.world.playerCount(); ++j) {
            if (c.team_of_slot[j] == v.team) continue;
            const Fixed64 x = c.world.player(j).pos.x * v.sg;
            if (!ha || x > a) { b = a; hb = ha; a = x; ha = true; }
            else if (!hb || x > b) { b = x; hb = true; }
        }
        Fixed64 line = hb ? b : hx;
        const Fixed64 bx = c.world.ball().pos.x * v.sg;
        if (bx > line) line = bx;
        const Fixed64 lim = line - P.onside_margin_m;
        if (t.x * v.sg > lim) t.x = lim * v.sg;
        o.target = t;
        o.move.move = seek(c.world.player(v.slot).pos, t, Fixed64::fromFraction(1, 2));
        o.why = Why::AttackBox;
        return true;
    }
};

const OnBall kOnBall;
const AttackBox kAttackBox;
const Support kSupport;
const Receive kReceive;
const Keeper kKeeper;

}  // namespace

const ActingState* Possession::onBall() { return &kOnBall; }
const ActingState* Possession::support() { return &kSupport; }
const ActingState* Possession::receive() { return &kReceive; }
const ActingState* Possession::keeper() { return &kKeeper; }
const ActingState* Possession::attackBox() { return &kAttackBox; }

int Possession::runnerIndex(std::uint8_t slot) const {
    int k = 0;
    for (std::uint8_t j = 0; j < slot && j < 32; ++j) if ((runners_ >> j) & 1u) ++k;
    return k;
}

void Possession::assignRunners(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                               const std::vector<Role>& role_of_slot, std::uint64_t match_seed) {
    const auto& b = world.ball();
    const std::uint32_t mine_mask = [&] { std::uint32_t m = 0; for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) if (team_of_slot[j] == team) m |= 1u << j; return m; }();
    auto clear = [&] { runners_ &= ~mine_mask; zone_[team & 1] = -1; };
    const bool ours = b.owner ? team_of_slot[*b.owner] == team : world.lastTouchTeam() == team;
    if (!ours || world.restartTeam() != 0xFF || world.outStage() != 0) { clear(); return; }
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 tl = world.pitchHalfX() - b.pos.x * sg;   // ball metres off their line
    if (tl >= Fixed64::fromInt(52)) { clear(); return; }
    const int z = (tl < Fixed64::fromInt(18) ? 0 : tl < Fixed64::fromInt(35) ? 1 : 2) * 2 +
                  (math::fx_abs(b.pos.y) < Fixed64::fromFraction(2016, 100) ? 0 : 1);
    const std::uint64_t now = world.tickCount();
    if (z == zone_[team & 1] && now - drawn_[team & 1] < 90) return;
    zone_[team & 1] = z; drawn_[team & 1] = now;
    runners_ &= ~mine_mask;
    // How many: the real 0 / 1 / 2 / 3+ shares (3+ = 3, 4 at the mean's excess).
    const Fixed64 u = (core::detNoise(match_seed, now, team, 50) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    int n = 0; Fixed64 acc = params_.box_k[z][0];
    while (n < 3 && u >= acc) { ++n; acc += params_.box_k[z][n]; }
    if (n == 0) return;
    // Who: weight = his role's real mean count ÷ the men of that role in this team; nearest first among equals.
    int per_role[kRoleCount] = {};
    for (std::uint8_t j = 0; j < world.playerCount(); ++j)
        if (team_of_slot[j] == team && !world.isKeeper(j)) ++per_role[static_cast<int>(role_of_slot[j])];
    const Vec2 box{sg * (world.pitchHalfX() - Fixed64::fromInt(12)), Fixed64::zero()};
    for (int pick = 0; pick < n; ++pick) {
        int best = -1; Fixed64 bw{};
        for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) {
            if (team_of_slot[j] != team || world.isKeeper(j) || ((runners_ >> j) & 1u)) continue;
            if (b.owner && *b.owner == j) continue;
            const int r = static_cast<int>(role_of_slot[j]);
            if (params_.box_role[z][r].raw <= 0) continue;
            const Fixed64 d = math::length(Vec2{world.player(j).pos.x - box.x, world.player(j).pos.y - box.y});
            // role weight, a little less per 10 m from the box (nearest first among equals)
            const Fixed64 wgt = params_.box_role[z][r] / Fixed64::fromInt(per_role[r]) / (Fixed64::one() + d / Fixed64::fromInt(40));
            if (best < 0 || wgt > bw) { best = j; bw = wgt; }
        }
        if (best < 0) break;
        runners_ |= 1u << best;
    }
}

void PossessionParams::configure(const core::ModelParams& p) {
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kBandCount; ++b) {
            const std::string key = std::string("physics.support.") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5);
            spot[r][b] = p.fixed(key, std::int64_t{kRealSpotDm[r][b]} * 100);
        }
    // The shot policy, StatsBomb PL 2015/16 open play (permille).
    static const int kShotP[4][3] = {{293, 778, 922}, {82, 610, 675}, {66, 358, 0}, {18, 183, 0}};
    for (int d = 0; d < 4; ++d)
        for (int a = 0; a < 3; ++a)
            shot_p[d][a] = p.fixed(("physics.shot.p_" + std::to_string(d) + "_" + std::to_string(a)).c_str(), kShotP[d][a]);
    // On-ball starting numbers [FH] — to be fitted to StatsBomb PL 2015/16
    // (crosses, pass length and direction a team-match).
    // The pass policy, StatsBomb PL 2015/16 open play (per mille of the origin zone's passes).
    static const int kTo[10][10] = {
        {770, 94, 121, 14, 0, 0, 0, 0, 0, 0},       {419, 339, 77, 159, 2, 4, 0, 0, 0, 0},
        {213, 105, 403, 147, 105, 25, 2, 0, 0, 0},  {141, 137, 183, 334, 70, 125, 4, 4, 0, 0},
        {35, 25, 155, 124, 353, 163, 115, 24, 4, 1}, {29, 30, 76, 174, 193, 305, 86, 97, 6, 3},
        {13, 11, 32, 31, 154, 120, 358, 158, 106, 16}, {17, 16, 36, 46, 77, 179, 211, 241, 108, 68},
        {7, 5, 42, 18, 91, 48, 167, 117, 383, 123},  {6, 6, 21, 22, 48, 71, 96, 191, 263, 277}};
    static const int kLoft[10] = {214, 265, 122, 134, 122, 118, 128, 172, 298, 289};
    static const int kCross[10] = {256, 296, 7, 78, 0, 0, 0, 0, 0, 0};
    for (int o = 0; o < 10; ++o) {
        for (int d = 0; d < 10; ++d)
            pass_to[o][d] = p.fixed(("physics.pass.to_" + std::to_string(o) + "_" + std::to_string(d)).c_str(), kTo[o][d]);
        pass_loft[o] = p.fixed(("physics.pass.loft_" + std::to_string(o)).c_str(), kLoft[o]);
        pass_cross[o] = p.fixed(("physics.pass.cross_" + std::to_string(o)).c_str(), kCross[o]);
    }
    clear_from_m = p.fixed("physics.onball.clear_from_m", 25000);
    pass_min_m = p.fixed("physics.onball.pass_min_m", 5000);
    onside_margin_m = p.fixed("physics.support.onside_margin_m", 500);
    risk_weight = p.fixed("physics.pass.risk_weight", 250);   // [FH] start; fit to completion 79.1%
    keeper_depth_m = p.fixed("physics.keeper.depth_m", 1000);
    keeper_depth_k = p.fixed("physics.keeper.depth_k", 80);
    keeper_depth_max_m = p.fixed("physics.keeper.depth_max_m", 12000);
    keeper_long_m = p.fixed("physics.restart.keeper_long_m", 55000);
    // Runs into the box: DFL (benchmarks_tracking_box.py), the ball's zone 0-18 / 18-35 / 35-52 × centre / wide.
    static const int kK[6][4] = {{60, 110, 140, 690}, {180, 160, 240, 420}, {600, 120, 100, 180},
                                 {620, 160, 100, 110}, {930, 30, 20, 20}, {950, 30, 10, 10}};   // per mille
    static const int kRole[6][kRoleCount] = {   // CB, FB, DM/CM, AM, WIDE, ST — mean count, ×1000
        {500, 210, 430, 340, 900, 1080}, {220, 80, 280, 210, 540, 950}, {160, 60, 110, 80, 230, 400},
        {90, 20, 60, 60, 170, 400}, {20, 0, 10, 10, 30, 60}, {10, 0, 0, 10, 20, 50}};
    static const int kDepth[6] = {11300, 12300, 14300, 14500, 15600, 15000};
    static const int kAy[6] = {7200, 6300, 7000, 6600, 6700, 7700};
    for (int z = 0; z < 6; ++z) {
        for (int k = 0; k < 4; ++k) box_k[z][k] = p.fixed(("physics.box.k_" + std::to_string(z) + "_" + std::to_string(k)).c_str(), kK[z][k]);
        for (int r = 0; r < kRoleCount; ++r) box_role[z][r] = p.fixed(("physics.box.role_" + std::to_string(z) + "_" + std::string(kRoleKey[r])).c_str(), kRole[z][r]);
        box_depth[z] = p.fixed(("physics.box.depth_" + std::to_string(z)).c_str(), kDepth[z]);
        box_ay[z] = p.fixed(("physics.box.abs_y_" + std::to_string(z)).c_str(), kAy[z]);
    }
}

Vec2 Possession::spot(const PlayerView& v, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_their = hx - world.ball().pos.x * v.sg;   // ball metres off their line
    const Fixed64 x = bandLookup(params_.spot[static_cast<int>(v.role)], off_their);
    return Vec2{(hx - x) * v.sg, v.across_ours};
}

}  // namespace fh::game::ai
