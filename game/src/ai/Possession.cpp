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

// Real (DFL, 7 matches, the side IN possession, in play, 5 Hz, the ball STILL:
// under 2 m/s forward or back over the last second): mean metres off THEIR line
// by role, ball in bands 0-10 … 90-100 m off it — benchmarks_tracking_lag.py
// (G5.43, §8.143). As the block's (G5.42): real men trail a moving ball (with it
// going forward at 5+ m/s a real ST is 5-7 m further from goal than with it
// still), so §8.111's all-frames table held that lag and ours trailed on top of
// it — 5-8 m deep with the ball still, the front man 6 m short of their line.
constexpr int kRealSpotDm[kRoleCount][kBandCount] = {   // decimetres
    {369, 397, 448, 506, 565, 631, 694, 758, 813, 897},   // CB
    {257, 287, 336, 400, 453, 514, 558, 623, 686, 805},   // FB
    {232, 267, 316, 378, 439, 513, 568, 623, 676, 757},   // DM/CM
    {144, 184, 236, 309, 357, 425, 467, 524, 561, 630},   // AM
    {144, 180, 238, 303, 353, 416, 457, 507, 550, 641},   // WIDE
    { 96, 131, 195, 256, 304, 359, 400, 446, 488, 552},   // ST
};
const char* const kRoleKey[kRoleCount] = {"cb", "fb", "dm", "am", "wide", "st"};
const Fixed64 kGoalHalfW = Fixed64::fromFraction(366, 100);   // Law 1: 7.32 m

// G5.37 (§8.135): where real unblocked shots crossed the goal line, by distance
// band (0-12 / 12-18 / 18-25 / 25+ m): permille per cell, lateral metres from the
// goal's centre {0-1, 1-2, 2-3, 3-3.66, 3.66-5, 5-7, 7-10, 10+} x height {0-0.5,
// 0.5-1.5, 1.5-2.44, 2.44-4, 4+} — StatsBomb PL 2015/16 open play
// (benchmarks_statsbomb_placement.py: the on-target share from the outcomes x
// the spread of goals and saves, the rest the spread of misses at the line).
constexpr int kShotXing[4][8][5] = {
  {{ 39,  46,  28,  26,  21}, { 38,  60,  35,  20,  23}, { 51,  63,  37,  30,  30}, { 30,  38,  18,  10,  10}, { 26,  38,  18,  18,  15}, { 13,  46,  16,  14,  19}, { 21,  28,   5,   9,  13}, { 18,  19,   2,   4,   4}},
  {{ 43,  37,   9,  12,  17}, { 61,  31,  14,  18,  22}, {101,  50,  30,  18,  20}, { 90,  46,  20,   5,  10}, { 46,  20,  15,  18,  26}, { 42,  24,  12,  12,  23}, { 29,  16,   4,   3,  13}, { 24,   7,   5,   1,   5}},
  {{ 53,  38,  22,   8,  17}, { 56,  39,  21,  11,  24}, { 63,  39,  28,  15,  28}, { 35,  25,  13,  14,  18}, { 37,  20,   9,  23,  30}, { 48,  26,  10,  17,  49}, { 40,  18,   8,   8,  34}, { 18,  10,   1,   9,  17}},
  {{ 36,  40,  21,  22,  27}, { 24,  27,  25,   3,  30}, { 32,  32,  17,  16,  42}, { 28,  15,   8,  11,  20}, { 31,  22,   7,  13,  31}, { 42,  31,  15,  23,  51}, { 44,  16,  11,  16,  47}, { 38,  24,   7,   9,  47}},
};
constexpr int kXingLatCm[9] = {0, 100, 200, 300, 366, 500, 700, 1000, 1400};
constexpr int kXingHtCm[6] = {0, 50, 150, 244, 400, 600};
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

// The carry (G5.29): at goal, off the nearest of theirs within 4 m — what he
// does with the ball at his feet until the World lets his release go.
Vec2 carryDir(const PlayerView& v, const PlayerCtx& c, const Vec2& sp, const Vec2& goal) {
    const auto& w = c.world;
    Vec2 dir = math::normalized(Vec2{goal.x - sp.x, goal.y - sp.y});
    int near = -1; Fixed64 nd = Fixed64::fromInt(16);
    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
        if (c.team_of_slot[j] == v.team) continue;
        const Fixed64 d2 = distSq(w.player(j).pos, w.player(v.slot).pos);
        if (d2 < nd) { nd = d2; near = j; }
    }
    if (near >= 0) {
        const auto& d = w.player(static_cast<std::uint8_t>(near));
        const Vec2 away = math::normalized(Vec2{sp.x - d.pos.x, sp.y - d.pos.y});
        dir = math::normalized(Vec2{dir.x + away.x * Fixed64::fromFraction(7, 10), dir.y + away.y * Fixed64::fromFraction(7, 10)});
    }
    return dir;
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
                    // G5.37 (§8.135): where it goes is drawn from where real shots
                    // from this distance went (on target, wide, over), one draw for
                    // the spell — the kick then has to get there past the keeper
                    // and the bodies. Side of the goal 50/50 [FH: no side data].
                    const int band = db < 3 ? db : 3;
                    auto roll = [&](int ch) {
                        return (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, ch) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
                    };
                    const int pick = static_cast<int>((roll(41) * Fixed64::fromInt(1000)).raw >> Fixed64::FRAC_BITS);
                    int li = 7, hi = 4, acc = 0;
                    for (int a = 0, done = 0; a < 8 && !done; ++a)
                        for (int b = 0; b < 5; ++b) {
                            acc += kShotXing[band][a][b];
                            if (pick < acc) { li = a; hi = b; done = 1; break; }
                        }
                    const Fixed64 lat = Fixed64::fromFraction(kXingLatCm[li], 100) +
                                        Fixed64::fromFraction(kXingLatCm[li + 1] - kXingLatCm[li], 100) * roll(42);
                    const Fixed64 ht = Fixed64::fromFraction(kXingHtCm[hi], 100) +
                                       Fixed64::fromFraction(kXingHtCm[hi + 1] - kXingHtCm[hi], 100) * roll(43);
                    const Fixed64 side = roll(44) < Fixed64::fromFraction(1, 2) ? -Fixed64::one() : Fixed64::one();
                    o.target = Vec2{goal.x, side * lat};
                    o.aim_z = ht < Fixed64::fromFraction(15, 100) ? Fixed64::zero() : ht;   // under 15 cm: along the ground
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
        struct Cand { int j; Fixed64 wgt; bool loft; Loft lf; bool behind; Vec2 at; std::uint8_t carry; };
        Cand cand[64]; int nc = 0; Fixed64 sum{};
        const Fixed64 reach = rangeFor(w.skillOf(v.slot), Fixed64::fromInt(50));
        // Their offside line (Law 11): the second-last of theirs, or halfway, or the ball.
        Fixed64 line{};
        {
            Fixed64 a{}, b{}; bool ha = false, hb = false;
            for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                if (c.team_of_slot[j] == v.team) continue;
                const Fixed64 x = w.player(j).pos.x * v.sg;
                if (!ha || x > a) { b = a; hb = ha; a = x; ha = true; }
                else if (!hb || x > b) { b = x; hb = true; }
            }
            line = hb ? b : hx;
            if (line < Fixed64::zero()) line = Fixed64::zero();
            if (sp.x * v.sg > line) line = sp.x * v.sg;
        }
        // In behind (G5.27, DFL): where a ball in behind is met past the line (a
        // roll for the spell), and whether it goes in the air (the real share).
        const Fixed64 u3 = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 43) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        const Fixed64 past = P.behind_past_lo + (P.behind_past_hi - P.behind_past_lo) * u3;
        const Fixed64 u4 = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 44) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        auto add = [&](const Cand& cd) { if (nc < 64 && cd.wgt.raw > 0) { cand[nc++] = cd; sum += cd.wgt; } };
        for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
            if (j == v.slot || c.team_of_slot[j] != v.team) continue;
            const auto& m = w.player(j);
            const Vec2 to = v2(m.pos);
            const Fixed64 d = math::length(Vec2{to.x - sp.x, to.y - sp.y});
            if (d < P.pass_min_m) continue;
            const int ez = zoneOf(hx, to, v.sg);
            const Fixed64 w0 = P.pass_to[oz][ez] / Fixed64::fromInt(in_zone[ez]);
            if (w0.raw <= 0) continue;
            // Of the passes for a man this far short of their line, the real share
            // that are played in behind him (DFL, by 2 m of gap); the rest to feet.
            Fixed64 pb{};
            const Fixed64 gap = line - m.pos.x * v.sg;
            if (!w.isKeeper(j) && gap.raw >= 0 && gap < Fixed64::fromInt(18))
                pb = P.behind_gap[static_cast<int>(gap.raw >> Fixed64::FRAC_BITS) / 2];
            const Fixed64 wgt = w0 * (Fixed64::one() - pb);
            if (wgt.raw > 0) {
                if (c.reads.passSafe(w, v.slot, sp, to, core::weightedPassSpeed(d), Fixed64::one())) {
                    add(Cand{j, wgt, false, Loft{}, false, to, 0});
                } else {
                    const Loft lf = loftTo(w.ballFlight(), m, me.pos, reach);
                    if (d <= reach && c.reads.loftSafe(w, v.slot, sp, lf.at, lf.carry_m, Fixed64::one()))
                        add(Cand{j, wgt, true, lf, false, to, 0});
                    else
                        // Real passes fail 21% of the time: a pass the read says they
                        // win is still tried, at risk_weight of its share (fitted to
                        // the real 79.1% completion, StatsBomb PL 2015/16).
                        add(Cand{j, wgt * P.risk_weight, false, Loft{}, false, to, 0});
                }
            }
            if (pb.raw <= 0) continue;
            // The ball in behind: into the space a real roll past the line on his
            // line of run; on the ground weighted to arrive as he does (his run's
            // time to the spot), else in the air — the real share first, or
            // whichever way the race read says we win.
            Fixed64 tx = line + past;
            if (tx > hx - Fixed64::fromInt(3)) tx = hx - Fixed64::fromInt(3);
            Fixed64 ty = m.pos.y + m.vel.y * P.behind_lead_s;
            const Fixed64 ycap = w.pitchHalfY() - Fixed64::fromInt(2);
            if (ty > ycap) ty = ycap;
            if (ty < -ycap) ty = -ycap;
            const Vec2 at{tx * v.sg, ty};
            if ((at.x - sp.x) * v.sg <= Fixed64::zero()) continue;
            const Fixed64 bd = math::length(Vec2{at.x - sp.x, at.y - sp.y});
            if (bd < P.pass_min_m) continue;
            const Fixed64 run = math::length(Vec2{at.x - m.pos.x, at.y - m.pos.y});
            int n = 9;   // his run's ticks to the spot, in 0.3 s steps to 4.5 s
            while (n < 135 && runToward(w, j, at, Fixed64::fromInt(n) * core::kTickDt) < run) n += 9;
            // A rolling ball covers d = v0·dt·(1 − rⁿ)/(1 − r) in n ticks.
            Fixed64 rn = Fixed64::one();
            for (int i = 0; i < n; ++i) rn = rn * core::kBallRollDecayPerTick;
            const Fixed64 one_r = Fixed64::one() - core::kBallRollDecayPerTick;
            Fixed64 v0 = bd * one_r / (core::kTickDt * (Fixed64::one() - rn));
            if (v0 > Fixed64::fromInt(20)) v0 = Fixed64::fromInt(20);
            const Fixed64 per_m = one_r * Fixed64::fromInt(30);
            std::int64_t cm = ((v0 - core::kPassArriveSpeed) / per_m).raw >> Fixed64::FRAC_BITS;
            if (cm < 1) cm = 1;
            if (cm > 255) cm = 255;
            const std::uint8_t carry = static_cast<std::uint8_t>(cm);
            const Fixed64 vg = core::weightedPassSpeed(Fixed64::fromInt(cm));
            const Loft lf{at, aimedCarry(me.pos, at, reach)};
            const Fixed64 bw = w0 * pb;
            const bool air_first = u4 < P.behind_air && bd <= reach;
            const bool gsafe = c.reads.passSafe(w, v.slot, sp, at, vg, Fixed64::one());
            const bool lsafe = bd <= reach && c.reads.loftSafe(w, v.slot, sp, lf.at, lf.carry_m, Fixed64::one());
            if (air_first ? lsafe : gsafe) add(Cand{j, bw, air_first, lf, true, at, carry});
            else if (air_first ? gsafe : lsafe) add(Cand{j, bw, !air_first, lf, true, at, carry});
            // G5.51 (§8.152): a ball in behind the race read says they win is still
            // played, at behind_risk of its share. Real balls over the top are 50/50s
            // (in behind completes 47.5%, DFL); judged on risk_weight they were cut from
            // deep: 52+ m out ours 3.7 a team-match v 14.9 real.
            else add(Cand{j, bw * P.behind_risk, air_first, lf, true, at, carry});
        }
        if (nc > 0) {
            const Fixed64 u = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 41) + Fixed64::one()) *
                              Fixed64::fromFraction(1, 2) * sum;
            int k = 0; Fixed64 acc = cand[0].wgt;
            while (k + 1 < nc && acc < u) { ++k; acc += cand[k].wgt; }
            const Cand& ch = cand[k];
            const auto& m = w.player(static_cast<std::uint8_t>(ch.j));
            o.other = static_cast<std::int16_t>(ch.j);
            if (ch.behind) {
                if (ch.loft) { o.target = ch.lf.at; o.carry_m = ch.lf.carry_m; o.action = Action::LoftedKick; o.pass_to = static_cast<std::uint8_t>(ch.j); }
                else { o.action = Action::GroundKick; o.target = ch.at; o.carry_m = ch.carry; }
                o.why = Why::InBehind;
                o.move.move = carryDir(v, c, sp, goal);   // he carries it until the release
                return true;
            }
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
            o.move.move = carryDir(v, c, sp, goal);   // he carries it until the release
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
        // 5. Nothing on: carry.
        const Vec2 dir = carryDir(v, c, sp, goal);
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
        // G5.47: the front man stands on their line, his tenure's gap short of it.
        if (c.poss.onLine(v.team, v.slot)) t.x = (line - c.poss.frontGap(v)) * v.sg;
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
        // A ball in behind for him (G5.27): while it is still behind him he runs on
        // to the spot it was played to, not back to the earliest point of its line.
        const auto& led = c.poss.led(c.world.ball().last_kicker);
        const auto& bv = c.world.ball().vel;
        // where a rolling ball comes to rest: v·dt/(1 − r) on (in the air: it gets there)
        const bool rolling = b.z.raw == 0 && bv.z.raw == 0;
        const Fixed64 roll = core::kTickDt / (Fixed64::one() - core::kBallRollDecayPerTick);
        const bool reaches = !rolling || (b.x + bv.x * roll) * v.sg > me.pos.x * v.sg;
        if (!c.world.ball().owner && led.to == v.slot && led.tick + 2 >= c.world.flightTick() && led.tick <= c.world.flightTick() &&
            reaches && b.x * v.sg + Fixed64::one() < me.pos.x * v.sg && distSq(me.pos, Vec3{led.at.x, led.at.y, Fixed64::zero()}) > Fixed64::one()) {
            o.target = led.at;
            o.move.move = seek(me.pos, led.at, Fixed64::fromFraction(1, 10));
            o.move.face = Vec2{b.x - me.pos.x, b.y - me.pos.y};
            o.why = Why::MeetPass;
            return true;
        }
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
        // G5.37 (§8.135): their strike — for his own reaction time (Body::reaction,
        // the read every other man already pays) he carries on as he was: no
        // new line, no dive. Reacting on the strike's own tick he ran to where
        // every shot was going and saved 100% of them 3 m+ from him (real 5-30%,
        // StatsBomb PL 2015/16 freeze frames, benchmarks_statsbomb_placement.py).
        if (!ball.owner && w.restartTeam() == 0xFF && ball.vel.x * v.sg < Fixed64::fromInt(-8) &&
            ball.last_kicker < c.team_of_slot.size() && c.team_of_slot[ball.last_kicker] != v.team) {
            const Fixed64 since = Fixed64::fromInt(static_cast<std::int32_t>(w.tickCount() - w.flightTick())) * core::kTickDt;
            if (since < w.body(v.slot).reaction()) {
                o.target = Vec2{};
                o.move.move = me.max_speed.raw > 0 ? Vec2{me.vel.x / me.max_speed, me.vel.y / me.max_speed} : Vec2{};
                return true;
            }
        }
        // A shot on goal he can't run to: dive at where it crosses his line.
        if (!ball.owner && w.restartTeam() == 0xFF && ball.vel.x * v.sg < Fixed64::fromInt(-8)) {
            const Fixed64 t = (me.pos.x - ball.pos.x) / ball.vel.x;
            if (t > Fixed64::zero() && t < Fixed64::fromFraction(6, 5)) {
                const Vec2 p{me.pos.x, ball.pos.y + ball.vel.y * t};
                if (math::fx_abs(p.y) < kGoalHalfW + Fixed64::fromInt(1)) {
                    const Fixed64 gap = math::length(Vec2{p.x - me.pos.x, p.y - me.pos.y});
                    if (gap > runToward(w, v.slot, p, t) + w.keeperShotReach()) {
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

// ── onto their line ────────────────────────────────────────────────────
// G5.45 (§8.145): his run (Possession::assignRuns) — straight at their goal on
// his line, to the gap short of their LIVE line his run was rolled to; never
// past it less onside_margin_m. Done (there, or out of time), assignRuns ends it
// and he is back in Support.
class RunLine final : public ActingState {
public:
    std::uint8_t id() const override { return 9; }
    const char* name() const override { return "run onto the line"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const auto& P = c.poss.params();
        const Fixed64 line = Possession::offsideLine(v.team, c.world, c.team_of_slot);
        Fixed64 g = c.poss.runEndGap(v.slot);
        if (g < P.onside_margin_m) g = P.onside_margin_m;
        const Vec2 t{(line - g) * v.sg, c.poss.runY(v.slot)};
        o.target = t;
        o.move.move = seek(c.world.player(v.slot).pos, t, Fixed64::fromFraction(1, 2));
        o.why = Why::RunLine;
        return true;
    }
};

const OnBall kOnBall;
const AttackBox kAttackBox;
const RunLine kRunLine;
const Support kSupport;
const Receive kReceive;
const Keeper kKeeper;

}  // namespace

const ActingState* Possession::onBall() { return &kOnBall; }
const ActingState* Possession::support() { return &kSupport; }
const ActingState* Possession::receive() { return &kReceive; }
const ActingState* Possession::keeper() { return &kKeeper; }
const ActingState* Possession::attackBox() { return &kAttackBox; }
const ActingState* Possession::runLine() { return &kRunLine; }

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
    {   // G5.46: the live spell on the ball (as DFL's BallPossession with the ball in play)
        const bool live = ours && world.restartTeam() == 0xFF && world.outStage() == 0;
        if (live && !had_[team & 1]) won_[team & 1] = world.tickCount();
        had_[team & 1] = live;
    }
    if (!ours || world.restartTeam() != 0xFF || world.outStage() != 0) { clear(); return; }
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 tl = world.pitchHalfX() - b.pos.x * sg;   // ball metres off their line
    if (tl >= Fixed64::fromInt(52)) { clear(); return; }
    const int z = (tl < Fixed64::fromInt(18) ? 0 : tl < Fixed64::fromInt(35) ? 1 : 2) * 2 +
                  (math::fx_abs(b.pos.y) < Fixed64::fromFraction(2016, 100) ? 0 : 1);
    const std::uint64_t now = world.tickCount();
    // G5.53 (§8.154): whether their line has dropped inside line_deep_m — real box
    // presence goes by it (ball 18-35 centre: 2.71 men with it, 0.15 without).
    const bool deep = world.pitchHalfX() - offsideLine(team, world, team_of_slot) < params_.box_line_deep_m;
    if (z == zone_[team & 1] && deep == deep_[team & 1] && now - drawn_[team & 1] < 90) return;
    zone_[team & 1] = z; drawn_[team & 1] = now; deep_[team & 1] = deep;
    runners_ &= ~mine_mask;
    // How many: the real 0 / 1 / 2 / 3+ shares (3+ = 3, 4 at the mean's excess).
    const Fixed64 u = (core::detNoise(match_seed, now, team, 50) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    const Fixed64* kz = params_.box_kl[z][deep ? 1 : 0];
    int n = 0; Fixed64 acc = kz[0];
    while (n < 3 && u >= acc) { ++n; acc += kz[n]; }
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

Fixed64 Possession::offsideLine(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot) {
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    Fixed64 a{}, b{}; bool ha = false, hb = false;
    for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
        if (team_of_slot[j] == team) continue;
        const Fixed64 x = world.player(j).pos.x * sg;
        if (!ha || x > a) { b = a; hb = ha; a = x; ha = true; }
        else if (!hb || x > b) { b = x; hb = true; }
    }
    Fixed64 line = hb ? b : world.pitchHalfX();
    const Fixed64 bx = world.ball().pos.x * sg;
    if (bx > line) line = bx;
    if (line < Fixed64::zero()) line = Fixed64::zero();
    return line;
}

Fixed64 Possession::offsideLineVelX(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot) {
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    Fixed64 a{}, b{}; bool ha = false, hb = false; std::uint8_t ja = 0xFF, jb = 0xFF;
    for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
        if (team_of_slot[j] == team) continue;
        const Fixed64 x = world.player(j).pos.x * sg;
        if (!ha || x > a) { b = a; hb = ha; jb = ja; a = x; ha = true; ja = j; }
        else if (!hb || x > b) { b = x; hb = true; jb = j; }
    }
    if (!hb) return Fixed64::zero();
    const auto& ball = world.ball();
    if (ball.pos.x * sg > b) return ball.vel.x;
    if (b < Fixed64::zero()) return Fixed64::zero();
    return world.player(jb).vel.x;
}

void Possession::assignRuns(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                            const std::vector<Role>& role_of_slot, std::uint64_t match_seed) {
    const auto& b = world.ball();
    const auto& P = params_;
    const std::uint64_t now = world.tickCount();
    const bool ours = b.owner ? team_of_slot[*b.owner] == team : world.lastTouchTeam() == team;
    const bool live = ours && world.restartTeam() == 0xFF && world.outStage() == 0;
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 line = live ? offsideLine(team, world, team_of_slot) : Fixed64::zero();
    // Real runs counted here are the ones with the ball NOT going forward (under
    // 2 m/s at their goal): the ones with it are the shape moving with the ball,
    // which Support already does (ours 181 a team-match v real 209, §8.145).
    const bool still = b.vel.x * sg < P.run_ball_fwd;
    for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) {
        if (team_of_slot[j] != team) continue;
        Run& r = run_[j];
        const Fixed64 gap = line - world.player(j).pos.x * sg;
        if (r.on) {
            Fixed64 g = r.end_gap;
            if (g < P.onside_margin_m) g = P.onside_margin_m;
            if (!live || now >= r.until || gap <= g + Fixed64::fromFraction(1, 2) || (b.owner && *b.owner == j)) r = Run{};
            continue;
        }
        // Eligible as the real rate was counted: the ball ours, carried or on its way (DFL BallPossession).
        if (!live || (b.owner && *b.owner == j) || b.pass_to == j || world.isKeeper(j) || runner(j) || !still) continue;
        if (gap.raw < 0 || gap >= Fixed64::fromInt(12)) continue;
        const int ro = static_cast<int>(role_of_slot[j]);
        // His role's real starts a second, a tick's share of it.
        const Fixed64 u = (core::detNoise(match_seed, now, j, 63) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        if (u >= P.run_rate[ro] * core::kTickDt) continue;
        // Where it gets to: piecewise through his role's real p25 / median / p75
        // (the tails as far again past each quartile, never under 0).
        const Fixed64 u2 = (core::detNoise(match_seed, now, j, 64) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        const Fixed64* q = P.run_end[ro];
        Fixed64 lo = q[0] - (q[1] - q[0]); if (lo.raw < 0) lo = Fixed64::zero();
        const Fixed64 hi = q[2] + (q[2] - q[1]);
        const Fixed64 pts[5] = {lo, q[0], q[1], q[2], hi};
        const Fixed64 f = u2 * Fixed64::fromInt(4);
        int i = static_cast<int>(f.raw >> Fixed64::FRAC_BITS); if (i > 3) i = 3;
        const Fixed64 end = pts[i] + (pts[i + 1] - pts[i]) * (f - Fixed64::fromInt(i));
        // A run, not a step: at least run_min_m on toward it.
        if (gap - end < P.run_min_m) continue;
        r.on = true;
        r.end_gap = end;
        r.y = world.player(j).pos.y;
        r.until = now + static_cast<std::uint64_t>((P.run_max_s / core::kTickDt).raw >> Fixed64::FRAC_BITS);
    }
}

void Possession::assignFront(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot) {
    const auto& b = world.ball();
    const bool ours = b.owner ? team_of_slot[*b.owner] == team : world.lastTouchTeam() == team;
    std::uint8_t* f = front_[team & 1];
    std::uint64_t* at = front_at_[team & 1];
    if (!ours || world.restartTeam() != 0xFF || world.outStage() != 0) { f[0] = f[1] = 0xFF; return; }
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    // Our most advanced outfielders in Support: not on the ball, not the pass's
    // man, not running into the box or onto the line.
    auto ok = [&](std::uint8_t j) {
        return j < world.playerCount() && team_of_slot[j] == team && !world.isKeeper(j) && !(b.owner && *b.owner == j) &&
               b.pass_to != j && !runner(j) && !running(j);
    };
    // k = 0 the front man, 1 the second; each keeps the job until a mate (not the
    // one above him) is front_swap_m further on.
    for (int k = 0; k < 2; ++k) {
        const std::uint8_t above = k ? f[0] : 0xFF;
        std::uint8_t best = 0xFF; Fixed64 bx{};
        for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) {
            if (!ok(j) || j == above) continue;
            const Fixed64 x = world.player(j).pos.x * sg;
            if (best == 0xFF || x > bx) { best = j; bx = x; }
        }
        if (best == 0xFF) { f[k] = 0xFF; continue; }
        if (f[k] != 0xFF && f[k] != above && ok(f[k]) && world.player(f[k]).pos.x * sg + params_.front_swap_m >= bx) continue;
        f[k] = best;
        at[k] = world.tickCount();
    }
}

Fixed64 Possession::rollGap(const Fixed64* q, std::uint64_t at, const PlayerView& v, int salt) const {
    // One roll a tenure, piecewise through the real p10 … p90 (tails held).
    const Fixed64 u = (core::detNoise(v.match_seed, at, v.slot, salt) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    static const Fixed64 kAt[5] = {Fixed64::fromFraction(1, 10), Fixed64::fromFraction(1, 4), Fixed64::fromFraction(1, 2),
                                   Fixed64::fromFraction(3, 4), Fixed64::fromFraction(9, 10)};
    if (u <= kAt[0]) return q[0];
    for (int i = 0; i < 4; ++i)
        if (u <= kAt[i + 1]) return q[i] + (q[i + 1] - q[i]) * (u - kAt[i]) / (kAt[i + 1] - kAt[i]);
    return q[4];
}

Fixed64 Possession::frontGap(const PlayerView& v) const {
    // Never nearer than onside_margin_m; the second man never nearer than the front man.
    const std::uint8_t* f = front_[v.team & 1];
    const std::uint64_t* at = front_at_[v.team & 1];
    Fixed64 g0 = rollGap(params_.front_q, at[0], PlayerView{v}, 66);
    if (f[0] != 0xFF && f[0] != v.slot) { PlayerView w = v; w.slot = f[0]; g0 = rollGap(params_.front_q, at[0], w, 66); }
    if (g0 < params_.onside_margin_m) g0 = params_.onside_margin_m;
    if (f[1] != v.slot) return g0;
    Fixed64 g = rollGap(params_.second_q, at[1], v, 67);
    if (g < g0) g = g0;
    return g;
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
    risk_weight = p.fixed("physics.pass.risk_weight", 250);
    behind_risk = p.fixed("physics.behind.risk_weight", 1000);   // G5.51 fit: 0.5 / 0.75 / 1.0 → in behind 21.0 / 26.3 / 29.3 (37.7), completed 46 / 52 / 50% (47.5) — the read does not pick the ones that fail   // [FH] start; fit to completion 79.1%
    keeper_depth_m = p.fixed("physics.keeper.depth_m", 1000);
    keeper_depth_k = p.fixed("physics.keeper.depth_k", 80);
    keeper_depth_max_m = p.fixed("physics.keeper.depth_max_m", 12000);
    keeper_long_m = p.fixed("physics.restart.keeper_long_m", 55000);
    // Runs into the box: DFL (benchmarks_tracking_box.py), the ball's zone 0-18 / 18-35 / 35-52 × centre / wide.
    static const int kK[6][4] = {{60, 110, 140, 690}, {180, 160, 240, 420}, {600, 120, 100, 180},
                                 {620, 160, 100, 110}, {930, 30, 20, 20}, {950, 30, 10, 10}};   // per mille
    // G5.53: the same by their line (second-last, keeper in, or the ball) 16+ m off its goal / inside 16 (DFL).
    static const int kKL[6][2][4] = {{{667, 283, 36, 14}, {41, 103, 145, 711}}, {{870, 110, 21, 0}, {156, 158, 249, 437}},
                                     {{899, 69, 23, 9}, {53, 203, 254, 490}},  {{925, 67, 7, 1}, {117, 316, 266, 301}},
                                     {{962, 29, 6, 3}, {89, 184, 291, 436}},   {{974, 22, 4, 0}, {192, 293, 324, 191}}};
    box_line_deep_m = p.fixed("physics.box.line_deep_m", 16000);
    static const int kRole[6][kRoleCount] = {   // CB, FB, DM/CM, AM, WIDE, ST — mean count, ×1000
        {500, 210, 430, 340, 900, 1080}, {220, 80, 280, 210, 540, 950}, {160, 60, 110, 80, 230, 400},
        {90, 20, 60, 60, 170, 400}, {20, 0, 10, 10, 30, 60}, {10, 0, 0, 10, 20, 50}};
    static const int kDepth[6] = {11300, 12300, 14300, 14500, 15600, 15000};
    static const int kAy[6] = {7200, 6300, 7000, 6600, 6700, 7700};
    // Balls in behind: DFL (benchmarks_tracking_behind.py), per mille.
    static const int kGap[9] = {500, 320, 220, 180, 120, 70, 50, 30, 20};   // his gap 0-2 … 16-18 m
    for (int g = 0; g < 9; ++g) behind_gap[g] = p.fixed(("physics.behind.gap_" + std::to_string(2 * g)).c_str(), kGap[g]);
    behind_past_lo = p.fixed("physics.behind.past_p25_m", 2630);
    behind_past_hi = p.fixed("physics.behind.past_p75_m", 9730);
    behind_air = p.fixed("physics.behind.air", 580);
    behind_lead_s = p.fixed("physics.behind.lead_s", 1000);   // [FH] his across drift on the ball's way
    // Runs onto their line: DFL (benchmarks_tracking_runs.py, the ball not going forward).
    static const int kRunRate[kRoleCount] = {42, 24, 22, 11, 15, 9};            // starts per eligible man-second, x1000
    static const int kRunEnd[kRoleCount][3] = {{1600, 4300, 7200}, {1600, 4300, 7200}, {1600, 4300, 7200},
                                               {2100, 4400, 6700}, {1900, 4500, 7400}, {1100, 2900, 5600}};   // gets to, m short: p25 / median / p75
    for (int r = 0; r < kRoleCount; ++r) {
        run_rate[r] = p.fixed(("physics.run.rate_" + std::string(kRoleKey[r])).c_str(), kRunRate[r]);
        static const char* const kQ[3] = {"p25", "p50", "p75"};
        for (int k = 0; k < 3; ++k) run_end[r][k] = p.fixed(("physics.run.end_" + std::string(kQ[k]) + "_" + kRoleKey[r]).c_str(), kRunEnd[r][k]);
    }
    run_min_m = p.fixed("physics.run.min_m", 3000);      // real forward p25 4.1 m; a shorter one is a step
    run_max_s = p.fixed("physics.run.max_s", 4000);      // real lasts p75 2.6 s at 4+ m/s, + the run-up and the brake
    run_ball_fwd = p.fixed("physics.run.ball_fwd", 2000);
    // His depth for the possession: DFL (benchmarks_tracking_gapspread.py SPELL OFFSET, spells 5 s+), metres x1000.
    static const int kSpell[kRoleCount][5] = {{-10400, -3500, 200, 3000, 5700}, {-12400, -6900, -1100, 5000, 10500}, {-11200, -5600, -300, 4600, 9200},
                                              {-7300, -4900, 200, 4100, 7600}, {-5800, -3700, -300, 4100, 9400}, {-2500, -1500, 200, 3100, 6600}};
    static const char* const kDq[5] = {"p10", "p25", "p50", "p75", "p90"};
    for (int r = 0; r < kRoleCount; ++r)
        for (int k = 0; k < 5; ++k)
            depth_q[r][k] = p.fixed(("physics.support.depth_" + std::string(kDq[k]) + "_" + kRoleKey[r]).c_str(), kSpell[r][k]);
    // The front man's gap (G5.47): DFL (benchmarks_tracking_shoulder.py, ball 10-60 m out), metres x1000.
    static const int kFront[5] = {-700, 500, 1600, 3000, 4800};
    for (int k = 0; k < 5; ++k) front_q[k] = p.fixed(("physics.front.gap_" + std::string(kDq[k])).c_str(), kFront[k]);
    front_swap_m = p.fixed("physics.front.swap_m", 1000);
    front_close = p.fixed("physics.front.close_mps", 1000);   // fitted: 1.0 / 1.5 / 2.0 → ball-still runs 43.8 / 47.5 / 49.8 (41.7)
    static const int kSecond[5] = {1200, 2500, 4200, 6700, 9900};   // G5.49, the same source
    for (int k = 0; k < 5; ++k) second_q[k] = p.fixed(("physics.front.second_" + std::string(kDq[k])).c_str(), kSecond[k]);
    for (int z = 0; z < 6; ++z) {
        for (int d = 0; d < 2; ++d)
            for (int k = 0; k < 4; ++k)
                box_kl[z][d][k] = p.fixed(("physics.box.kl_" + std::to_string(z) + "_" + std::to_string(d) + "_" + std::to_string(k)).c_str(), kKL[z][d][k]);
        for (int k = 0; k < 4; ++k) box_k[z][k] = p.fixed(("physics.box.k_" + std::to_string(z) + "_" + std::to_string(k)).c_str(), kK[z][k]);
        for (int r = 0; r < kRoleCount; ++r) box_role[z][r] = p.fixed(("physics.box.role_" + std::to_string(z) + "_" + std::string(kRoleKey[r])).c_str(), kRole[z][r]);
        box_depth[z] = p.fixed(("physics.box.depth_" + std::to_string(z)).c_str(), kDepth[z]);
        box_ay[z] = p.fixed(("physics.box.abs_y_" + std::to_string(z)).c_str(), kAy[z]);
    }
}

Fixed64 Possession::spellDepth(const PlayerView& v) const {
    // One roll a man a spell, piecewise through the real p10 … p90 (held at the
    // ends: the 10% tails each side stand at p10 / p90).
    const Fixed64 u = (core::detNoise(v.match_seed, won_[v.team & 1], v.slot, 65) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    const Fixed64* q = params_.depth_q[static_cast<int>(v.role_ours)];
    static const Fixed64 kAt[5] = {Fixed64::fromFraction(1, 10), Fixed64::fromFraction(1, 4), Fixed64::fromFraction(1, 2),
                                   Fixed64::fromFraction(3, 4), Fixed64::fromFraction(9, 10)};
    if (u <= kAt[0]) return q[0];
    for (int i = 0; i < 4; ++i)
        if (u <= kAt[i + 1]) return q[i] + (q[i + 1] - q[i]) * (u - kAt[i]) / (kAt[i + 1] - kAt[i]);
    return q[4];
}

Vec2 Possession::spot(const PlayerView& v, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_their = hx - world.ball().pos.x * v.sg;   // ball metres off their line
    Fixed64 x = bandLookup(params_.spot[static_cast<int>(v.role_ours)], off_their) + spellDepth(v);
    if (x.raw < 0) x = Fixed64::zero();
    return Vec2{(hx - x) * v.sg, v.across_ours};
}

}  // namespace fh::game::ai
