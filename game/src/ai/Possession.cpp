// game/src/ai/Possession.cpp — in possession and the keeper (G5.22, DESIGN §8.120).
#include "ai/Possession.hpp"

#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "math/FixedMath.hpp"

#include <algorithm>
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
// G5.102 (§8.204): the side ON the ball, its width — the real gap between a role's pair across by
// the ball's band off THEIR line (benchmarks_tracking_posswidth.py: CB 11.9 → 20.8 m as the ball goes
// back into their own half — the pair splits for the build-up; WIDE 21.9 → 32.3) over the game's
// own gap before (formation width + slide, CB ~13 m at every band), permille — real / game-before,
// two passes (the slide's clamp and men off their spot make it not quite linear), so ours measure the real gaps (fh-game-match POSSESSION WIDTH). AM and ST: no pair, kept whole.
constexpr int kRealWidthPm[kRoleCount][kBandCount] = {
    { 792,  923, 1025, 1078, 1263, 1552, 1772, 2034, 2066, 1646},   // CB
    { 633,  684,  773,  809,  908,  985, 1099, 1093, 1146,  924},   // FB
    { 730,  755,  850,  785,  879,  796,  814,  822,  850,  782},   // DM/CM
    {1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000},   // AM
    { 733,  801,  716,  670,  719,  773,  805,  795,  832,  832},   // WIDE
    {1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000},   // ST
};
// G5.120 (§8.221): the side ON the ball, by the ball's metres off the centre line in 4 m bins (0-4 … 24-28, 28+)
// — benchmarks_tracking_rolewidth.py (DFL, spell frames, the carrier out). SLIDE: the real centre of each role's
// pair toward the ball's side (CB +1.0 → +9.1 m, DM/CM 0 → +12.0), over ours before (every man 0.47 × the
// ball's y: CB +12.5 with the ball 28+) — decimetres, real × our input / our measured, two passes, so ours measure real (fh-game-match
// ROLE WIDTH). AM: no real pair, the old 0.47. LONE (the only DM / AM / ST in his side): the share of frames on
// the ball's side (permille; bin 0 held at a half so the side holds as the ball crosses the middle) and his
// metres toward it on the ball's side / the far side, medians (real AM +10.2 / −9.6 with the ball central:
// ours stood 5 m off the line either side).
constexpr int kRealSlideDm[kRoleCount][PossessionParams::kYBins] = {
    { 12,  16,  29,  46,  61,  67,  82, 102},   // CB
    {  7,  22,  23,  33,  46,  48,  70, 114},   // FB
    {  5,  18,  68,  61,  61,  86, 113, 152},   // DM/CM
    {  9,  28,  47,  66,  85, 103, 122, 146},   // AM (0.47 × the bin centre)
    { 11,  48,  52,  49,  51,  64,  96,  96},   // WIDE
    {  6,  17,  21,  38,  51,  73,  79,  84},   // ST
};
constexpr int kLoneP[3][PossessionParams::kYBins] = {   // DM/CM, AM, ST
    {500, 610, 630, 650, 670, 820, 890, 910}, {500, 580, 550, 640, 680, 720, 730, 770}, {500, 570, 620, 640, 620, 670, 760, 780}};
constexpr int kLoneNearDm[3][PossessionParams::kYBins] = {
    { 80, 121, 108, 109,  98, 140, 139, 152}, {102, 104, 105, 106, 117, 117, 132, 146}, { 63,  71,  82,  90,  85,  87,  98, 103}};
constexpr int kLoneFarDm[3][PossessionParams::kYBins] = {
    {-67, -50, -52, -71, -48, -37, -48, -47}, {-96, -86, -80, -53, -63, -54, -62, -51}, {-59, -57, -43, -44, -35, -31, -40, -31}};
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
        // G5.81 (§8.182): pressed (his man inside 3 m), the line he takes it on is drawn from the
        // real pressed first touches — away from the man 56%, across 27%, toward 14% (DFL controlled
        // first touches, PRESSED TOUCH: the touch's line v the line to the nearest opponent, away
        // > 120 deg, toward < 60) — one draw a spell, so his wish holds while he has it. A line
        // already in the drawn cone stays; else it turns, on its own side of the man, into it. The
        // first touch plays the ball his way (World::playFirstTouch): "at goal" with the marker
        // behind him had it stolen inside half a second.
        const auto& P = c.poss.params();
        if (P.press_on && nd < Fixed64::fromInt(9)) {
            const Vec2 q = Vec2{-away.x, -away.y};
            auto roll = [&](int ch) { return (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, ch) + Fixed64::one()) * Fixed64::fromFraction(1, 2); };
            const Fixed64 u1 = roll(57), u2 = roll(58), half = Fixed64::fromFraction(1, 2);
            Fixed64 lo = -Fixed64::one(), hi = -half;   // cos to his line: away [-1, -0.5]
            if (u1 < P.press_toward) { lo = half; hi = Fixed64::one(); }
            else if (u1 < P.press_toward + P.press_across) { lo = -half; hi = half; }
            const Fixed64 c0 = dir.x * q.x + dir.y * q.y;
            if (c0 < lo || c0 > hi) {
                const Fixed64 cs = lo + (hi - lo) * u2;
                const Fixed64 s2 = Fixed64::one() - cs * cs;
                Fixed64 sn = s2.raw > 0 ? math::fx_sqrt(s2) : Fixed64::zero();
                if ((q.x * dir.y - q.y * dir.x).raw < 0) sn = -sn;   // his line's side of the man
                dir = Vec2{q.x * cs - q.y * sn, q.y * cs + q.x * sn};
            }
        }
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
        // G5.74 (§8.175): a zone's share is split among the mates standing there by e^(-d/lambda),
        // d = his metres from the passer (DFL: the man a pass is for is the nearest in his zone 50-62%
        // of the time, 37-40% if even; wide to wide with a mate on each flank, the passer's own
        // flank 95-100%). Split evenly, the far flank's man took half of every wide-to-wide share.
        const int lb = own_end < Fixed64::fromInt(35) ? 0 : own_end < Fixed64::fromInt(70) ? 1 : 2;
        const Fixed64 lam = P.pick_lambda[lb];
        Fixed64 pick[32] = {}, zsum[10] = {};
        // G5.76 (§8.177): our keeper is not in a zone's split — he has his own real share (below).
        // Alone in the deep zone when our backs push up, he took all of it: 31 passes a team-match
        // (real 7.7), 12 from 40-60 m out (1.2).
        const bool gk_own = P.gk_on && !v.keeper;
        const int gkb = std::min(9, std::max(0, static_cast<int>(own_end.raw >> Fixed64::FRAC_BITS) / 10));
        for (std::uint8_t j = 0; j < w.playerCount() && j < 32; ++j)
            if (j != v.slot && c.team_of_slot[j] == v.team && !(gk_own && w.isKeeper(j))) {
                const Vec2 to = v2(w.player(j).pos);
                const int ez = zoneOf(hx, to, v.sg);
                ++in_zone[ez];
                pick[j] = lam.raw > 0 ? math::fx_exp_neg(math::length(Vec2{to.x - sp.x, to.y - sp.y}) / lam) : Fixed64::one();
                if (P.mark_on) {   // G5.83 (§8.184): a man with theirs close gets less of his zone's share
                    Fixed64 nd2 = Fixed64::fromInt(10000);
                    for (std::uint8_t q = 0; q < w.playerCount(); ++q)
                        if (c.team_of_slot[q] != v.team) { const Fixed64 e = distSq(w.player(q).pos, w.player(j).pos); if (e < nd2) nd2 = e; }
                    const int qb = nd2 < Fixed64::fromInt(4) ? 0 : nd2 < Fixed64::fromFraction(49, 4) ? 1 : nd2 < Fixed64::fromInt(25) ? 2 : nd2 < Fixed64::fromInt(64) ? 3 : 4;
                    const Fixed64 off = w.pitchHalfX() + to.x * v.sg;
                    const int rb = off < Fixed64::fromInt(35) ? 0 : off < Fixed64::fromInt(70) ? 1 : 2;
                    pick[j] = pick[j] * P.mark_lift[rb][qb];
                }
                zsum[ez] += pick[j];
            }
        struct Cand { int j; Fixed64 wgt; bool loft; Loft lf; bool behind; Vec2 at; std::uint8_t carry; bool cross = false; bool space = false; bool moded = false; };
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
        int gk_lo = -1, gk_hi = -1; Fixed64 gk_w{};   // G5.76: our keeper's candidates, at unit weight until the rest are in
        for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
            if (j == v.slot || c.team_of_slot[j] != v.team) continue;
            const bool is_gk = gk_own && w.isKeeper(j);
            const int nc0 = nc; const Fixed64 s0 = sum;
            const auto& m = w.player(j);
            const Vec2 to = v2(m.pos);
            const Fixed64 d = math::length(Vec2{to.x - sp.x, to.y - sp.y});
            if (d < P.pass_min_m) continue;
            const int ez = zoneOf(hx, to, v.sg);
            const Fixed64 w0 = is_gk ? (P.gk_share[gkb].raw > 0 ? Fixed64::one() : Fixed64{})
                             : zsum[ez].raw > 0 && j < 32 ? P.pass_to[oz][ez] * P.pass_kappa[oz][ez] * pick[j] / zsum[ez] : Fixed64{};
            if (w0.raw <= 0) continue;
            // Of the passes for a man this far short of their line, the real share
            // that are played in behind him (DFL, by 2 m of gap); the rest to feet.
            Fixed64 pb{};
            const Fixed64 gap = line - m.pos.x * v.sg;
            if (!w.isKeeper(j) && gap.raw >= 0 && gap < Fixed64::fromInt(18))
                pb = P.behind_gap[static_cast<int>(gap.raw >> Fixed64::FRAC_BITS) / 2];
            const Fixed64 wgt = w0 * (Fixed64::one() - pb);
            // G5.73 (§8.174): to feet, outside the cross into the box — high or on the ground at the
            // real share for his spot and this length; the race read sets each mode's risk, never the
            // mode. Before, a blocked ground lane with a safe loft became a chip: 12-30% of our passes
            // under 30 m went high (real 5-14%) and 94-99% arrived (real 35-50%), while 40-50 m passes
            // stayed on the ground (19-35% high, real 77-90%).
            const bool box_ball = ez == 0 && oz != 0;
            if (wgt.raw > 0 && P.high_on && !box_ball) {
                const bool gsafe = c.reads.passSafe(w, v.slot, sp, to, core::weightedPassSpeed(d), Fixed64::one());
                // Past his range the high share is not his to play, and is not handed to the ground:
                // nobody drives a 55 m pass along the floor (real 50+ m passes 87-98% high).
                // G5.75 (§8.176): and its direction — real 30-40 m passes from our third go high 73%
                // forward, 12% across, 4% back; by length alone our lateral balls went up at the forward rate.
                const Fixed64 fwd = (to.x - sp.x) * v.sg;
                const int dir = fwd * Fixed64::fromInt(2) > d ? 0 : fwd * Fixed64::fromInt(2) < -d ? 2 : 1;
                const Fixed64 ph = P.highShare(own_end, d, dir);
                Fixed64 gw = wgt * (Fixed64::one() - ph);
                if (!gsafe) gw = gw * P.risk_weight;
                add(Cand{j, gw, false, Loft{}, false, to, 0, false, false, true});
                if (ph.raw > 0 && d <= reach) {
                    const Loft lf = loftTo(w.ballFlight(), m, me.pos, reach);
                    const bool lsafe = c.reads.loftSafe(w, v.slot, sp, lf.at, lf.carry_m, Fixed64::one());
                    add(Cand{j, lsafe ? wgt * ph : wgt * ph * P.high_risk, true, lf, false, to, 0, false, false, true});
                }
            } else if (wgt.raw > 0) {
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
            if (is_gk) { gk_lo = nc0; gk_hi = nc; gk_w = sum - s0; sum = s0; }
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
            Fixed64 bw = w0 * pb;
            if (P.behind_lift_on) {   // G5.91 (§8.192): to the man already running at their goal
                const Fixed64 vf = m.vel.x * v.sg;
                const int vb = vf.raw < 0 ? 0 : vf < Fixed64::fromInt(2) ? 1 : vf < Fixed64::fromInt(4) ? 2 : vf < Fixed64::fromInt(6) ? 3 : 4;
                bw = bw * P.behind_lift[vb];
            }
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
        // G5.54 (§8.155): a zone ahead with no mate in it keeps its real share — the
        // ball into space there, for the mate who gets to it first (real passes into
        // their wide channel complete 70%, StatsBomb; a cross lands ~7.5 m out around
        // the middle). Without it the share vanished and went back and inside: from
        // wide 18-35 m out ours played 33% back (17), 7.6% down the line (14.5).
        if (P.space_on) {
            const int ob = oz / 2;
            const Fixed64 side = sp.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
            static const int kMid[5] = {9, 26, 43, 61, 80};
            for (int ez = 0; ez < 10; ++ez) {
                if (in_zone[ez] > 0 || ez / 2 > ob || ez == oz) continue;
                const Fixed64 wz = P.pass_to[oz][ez];
                if (wz.raw <= 0) continue;
                const bool wide = ez % 2 == 1;
                const bool cross = ez == 0 && oz % 2 == 1;
                const Fixed64 dep = ez == 0 ? P.cross_depth_m : Fixed64::fromInt(kMid[ez / 2]);
                const Vec2 at{(hx - dep) * v.sg, wide ? side * P.space_wide_y : Fixed64::zero()};
                // G5.57: ahead of the ball (a band's middle can be behind him in his own band).
                if ((at.x - sp.x) * v.sg < Fixed64::fromInt(3)) continue;
                const Fixed64 bd = math::length(Vec2{at.x - sp.x, at.y - sp.y});
                if (bd < P.pass_min_m || bd > reach) continue;
                // Who gets there first (his run's ticks, 0.3 s steps to 4.5 s).
                int best = -1, bn = 1000;
                for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                    if (j == v.slot || c.team_of_slot[j] != v.team || w.isKeeper(j)) continue;
                    // G5.58 (§8.159): a ground ball into space is played into a man's path —
                    // never to a mate already past the spot, sprinting back across its line
                    // (traced: 18 m upfield of it, at it 0.1-0.2 s late at 7 m/s, 2-3 m past).
                    if (!cross && (at.x - w.player(j).pos.x) * v.sg < -P.space_back_m) continue;
                    const Fixed64 run = math::length(Vec2{at.x - w.player(j).pos.x, at.y - w.player(j).pos.y});
                    int n = 9;
                    while (n < 135 && runToward(w, j, at, Fixed64::fromInt(n) * core::kTickDt) < run) n += 9;
                    if (n < bn) { bn = n; best = j; }
                }
                if (best < 0 || bn >= 135 || Fixed64::fromInt(bn) * core::kTickDt > P.space_max_s) continue;   // he must get there in time
                // G5.55 (§8.156): a ground ball, before any of theirs — real balls into space go to
                // the man who gets there first (ours went to a mate 17.8 m off it, theirs 11.5 m).
                // A cross is struck whoever is first (real: 28% completed, 40% cleared next).
                if (!cross) {
                    int tn = 1000;
                    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                        if (c.team_of_slot[j] == v.team) continue;
                        const Fixed64 run = math::length(Vec2{at.x - w.player(j).pos.x, at.y - w.player(j).pos.y});
                        int n = 9;
                        while (n < bn + 9 && runToward(w, j, at, Fixed64::fromInt(n) * core::kTickDt) < run) n += 9;
                        if (n < tn) tn = n;
                    }
                    if (tn < bn + P.space_margin_ticks) continue;
                }
                if (cross) {
                    const Loft lf{at, aimedCarry(me.pos, at, reach)};
                    const bool ok = c.reads.loftSafe(w, v.slot, sp, lf.at, lf.carry_m, Fixed64::one());
                    add(Cand{best, ok ? wz : wz * P.space_risk, true, lf, true, at, 0, true});
                    continue;
                }
                // G5.57 (§8.158): a die-at kick (core::dieAtSpeed): on the old weighted kick's
                // floor (9 m/s at the spot) it ran ~23 m on and out a quarter of the time.
                // Timed to reach the spot as he does (the G5.54 weight), never softer than one
                // that dies space_roll_m past it: the strike that rolls to rest d_tot away.
                Fixed64 rn = Fixed64::one();
                for (int i = 0; i < bn; ++i) rn = rn * core::kBallRollDecayPerTick;
                const Fixed64 one_r = Fixed64::one() - core::kBallRollDecayPerTick;
                const Fixed64 v_timed = bd * one_r / (core::kTickDt * (Fixed64::one() - rn));
                Fixed64 d_tot = v_timed * core::kTickDt * core::kBallRollDecayPerTick / one_r;
                if (d_tot < bd + P.space_roll_m) d_tot = bd + P.space_roll_m;
                std::int64_t cm = (d_tot.raw + Fixed64::fromFraction(1, 2).raw) >> Fixed64::FRAC_BITS;
                if (cm < 1) cm = 1;
                if (cm > 255) cm = 255;
                const Loft lf{at, aimedCarry(me.pos, at, reach)};
                const bool ok = c.reads.passSafe(w, v.slot, sp, at, core::dieAtSpeed(Fixed64::fromInt(cm)), Fixed64::one());
                add(Cand{best, ok ? wz : wz * P.space_risk, false, lf, true, at, static_cast<std::uint8_t>(cm), false, true});
            }
        }
        // G5.76 (§8.177): the keeper takes his real share s of the passes actually on offer —
        // s/(1-s) of everything else's weight. As a bare share beside mates cut by risk_weight
        // and the in-behind split he won far above it (10-30 m out 15.6 a team-match v 4.1).
        if (gk_lo >= 0 && gk_w.raw > 0 && sum.raw > 0) {
            const Fixed64 sh = P.gk_share[gkb];
            const Fixed64 tot = sum * sh / (Fixed64::one() - sh);
            for (int i = gk_lo; i < gk_hi; ++i) cand[i].wgt = cand[i].wgt * tot / gk_w;
            sum += tot;
        } else if (gk_lo >= 0) sum += gk_w;   // nothing else on: he is the pass
        if (nc > 0) {
            const Fixed64 u = (core::detNoise(v.match_seed, w.ownedAtTick(), v.slot, 41) + Fixed64::one()) *
                              Fixed64::fromFraction(1, 2) * sum;
            int k = 0; Fixed64 acc = cand[0].wgt;
            while (k + 1 < nc && acc < u) { ++k; acc += cand[k].wgt; }
            const Cand& ch = cand[k];
            const auto& m = w.player(static_cast<std::uint8_t>(ch.j));
            o.other = static_cast<std::int16_t>(ch.j);
            if (ch.behind && ch.cross) {   // G5.54: a cross into the box to space
                o.target = ch.lf.at; o.carry_m = ch.lf.carry_m; o.action = Action::LoftedKick; o.pass_to = static_cast<std::uint8_t>(ch.j);
                o.why = Why::Cross;
                o.move.move = carryDir(v, c, sp, goal);
                return true;
            }
            if (ch.behind) {
                if (ch.loft) { o.target = ch.lf.at; o.carry_m = ch.lf.carry_m; o.action = Action::LoftedKick; o.pass_to = static_cast<std::uint8_t>(ch.j); }
                else { o.action = Action::GroundKick; o.target = ch.at; o.carry_m = ch.carry; o.die = ch.space; }
                o.why = ch.space ? Why::IntoSpace : Why::InBehind;
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
            if (!air && !ch.moded && u2 < p_air) {
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
        Vec2 t = c.poss.spot(v, c.world, c.team_of_slot);
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
        {   // G5.118 (§8.219): off his mates — real men in possession stand 10-12 m from the nearest mate (DFL),
            // ours ran to their spots regardless (8-9.5 m, twice as many within 5 m). Each outfield mate within
            // spread_r_m of his spot pushes it away by spread_k x the overlap, the sum capped at spread_max_m.
            const auto& P = c.poss.params();
            if (P.spread_r_m.raw > 0 && !v.keeper) {
                Vec2 push{};
                for (std::uint8_t j = 0; j < c.world.playerCount(); ++j) {
                    if (j == v.slot || c.team_of_slot[j] != v.team || c.world.isKeeper(j)) continue;
                    const Vec2 d{t.x - c.world.player(j).pos.x, t.y - c.world.player(j).pos.y};
                    const Fixed64 L = math::length(d);
                    if (L >= P.spread_r_m) continue;
                    if (L.raw <= 0) continue;
                    const Fixed64 m = (P.spread_r_m - L) * P.spread_k / L;
                    push.x += d.x * m; push.y += d.y * m;
                }
                const Fixed64 pl = math::length(push);
                if (pl > P.spread_max_m) { push.x = push.x * P.spread_max_m / pl; push.y = push.y * P.spread_max_m / pl; }
                t.x += push.x; t.y += push.y;
                const Fixed64 ylim = c.world.pitchHalfY() - Fixed64::fromInt(2);
                if (t.y > ylim) t.y = ylim;
                if (t.y < -ylim) t.y = -ylim;
            }
        }
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
        // G5.58 (§8.159): only while the ball is still short of that spot. Played
        // across or down the wide channel, "behind him" on x stayed true after it
        // had passed the spot, and he turned back to the spot with the ball 0.9 m
        // from him running out of play.
        const bool short_of = math::dot(Vec2{led.at.x - b.x, led.at.y - b.y}, Vec2{bv.x, bv.y}).raw > 0;
        if (!c.world.ball().owner && led.to == v.slot && led.tick + 2 >= c.world.flightTick() && led.tick <= c.world.flightTick() &&
            reaches && short_of && b.x * v.sg + Fixed64::one() < me.pos.x * v.sg && distSq(me.pos, Vec3{led.at.x, led.at.y, Fixed64::zero()}) > Fixed64::one()) {
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
        Fixed64 y = side * P.box_ay[z] * Fixed64::fromInt(kSide[k & 3]);
        Fixed64 depth = P.box_depth[z] - Fixed64::fromInt(3) * Fixed64::fromInt(k / 4);
        if (c.poss.channel(v.slot)) { y = side * P.chan_ay[z]; depth = P.chan_depth[z]; }   // G5.56: the wide channel
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
    if (params_.box_spot_near && slot < 32) return spot_k_[slot];
    int k = 0;
    for (std::uint8_t j = 0; j < slot && j < 32; ++j) if (((runners_ & ~chan_) >> j) & 1u) ++k;
    return k;
}

void Possession::assignRunners(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                               const std::vector<Role>& role_of_slot, std::uint64_t match_seed) {
    const auto& b = world.ball();
    const std::uint32_t mine_mask = [&] { std::uint32_t m = 0; for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) if (team_of_slot[j] == team) m |= 1u << j; return m; }();
    auto clear = [&] { runners_ &= ~mine_mask; chan_ &= ~mine_mask; zone_[team & 1] = -1; };
    const bool ours = b.owner ? team_of_slot[*b.owner] == team : world.lastTouchTeam() == team;
    {   // G5.46: the live spell on the ball (as DFL's BallPossession with the ball in play)
        const bool live = ours && world.restartTeam() == 0xFF && world.outStage() == 0;
        if (live && !had_[team & 1]) won_[team & 1] = world.tickCount();
        had_[team & 1] = live;
    }
    // G5.61 (§8.162): the ball dead and the restart ours (or the call still to come after
    // our touch) — the runners hold as they are, no redraw. Real: with the ball 18-35 out
    // in the 3 s after a dead ball, 1.46-2.52 men in the box; ours 0.43-0.50, cleared.
    if (params_.box_restart_keep && world.restartTeam() == team) return;
    if (params_.box_restart_keep && world.outStage() != 0 && world.restartTeam() == 0xFF && world.lastTouchTeam() != team) return;
    if (!ours || world.restartTeam() != 0xFF || world.outStage() != 0) { clear(); return; }
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    // G5.60 (§8.161): with our pass on its way, the zone it is going to — the man it is
    // played to — so the runs start as it is played, not as it lands (the ball stays
    // in 18-35 wide 1.5 s; runners drawn on arrival were 11-13 m from their spots).
    Vec2 at{b.pos.x, b.pos.y};
    if (params_.box_from_pass && !b.owner && b.pass_to < world.playerCount() && team_of_slot[b.pass_to] == team)
        at = Vec2{world.player(b.pass_to).pos.x, world.player(b.pass_to).pos.y};
    const Fixed64 tl = world.pitchHalfX() - at.x * sg;   // ball (or its man) metres off their line
    if (tl >= Fixed64::fromInt(52)) { clear(); return; }
    const int z = (tl < Fixed64::fromInt(18) ? 0 : tl < Fixed64::fromInt(35) ? 1 : 2) * 2 +
                  (math::fx_abs(at.y) < Fixed64::fromFraction(2016, 100) ? 0 : 1);
    const std::uint64_t now = world.tickCount();
    // G5.53 (§8.154): whether their line has dropped inside line_deep_m — real box
    // presence goes by it (ball 18-35 centre: 2.71 men with it, 0.15 without).
    // G5.61 (§8.162): once deep, deep until the line is back past line_deep_out_m — a
    // line hovering at 16 m flipped deep and back, and each flip re-read the count.
    const Fixed64 lnd = world.pitchHalfX() - offsideLine(team, world, team_of_slot);
    const bool deep = lnd < (deep_[team & 1] && zone_[team & 1] >= 0 ? params_.box_line_deep_out_m : params_.box_line_deep_m);
    if (z == zone_[team & 1] && deep == deep_[team & 1] && now - drawn_[team & 1] < 90) return;
    zone_[team & 1] = z; drawn_[team & 1] = now; deep_[team & 1] = deep;
    // G5.60 (§8.161): the men already running stay first in line — a redraw (every
    // 3 s, a new zone, their line dropping) re-rolls how many, not who; before it,
    // a man 13 m into his run was dropped and another started (14% at their spot).
    const std::uint32_t keep = params_.box_sticky ? (runners_ & ~chan_ & mine_mask) : 0u;
    const std::uint32_t keepc = params_.box_sticky ? (chan_ & mine_mask) : 0u;
    runners_ &= ~mine_mask; chan_ &= ~mine_mask;
    // How many: the real 0 / 1 / 2 / 3+ shares (3+ = 3, 4 at the mean's excess).
    // G5.61 (§8.162): one roll a spell, read through each zone's real shares — a new
    // zone or their line dropping re-reads how many from the same roll, so the count
    // falls only where the real shares fall; a fresh roll per draw ended 39% of runs.
    const std::uint64_t at_t = params_.box_spell_roll ? won_[team & 1] + (now - won_[team & 1]) / 90 * 90 : now;
    const Fixed64 u = (core::detNoise(match_seed, at_t, team, 50) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    const Fixed64* kz = params_.box_kl[z][deep ? 1 : 0];
    int n = 0; Fixed64 acc = kz[0];
    while (n < 3 && u >= acc) { ++n; acc += kz[n]; }
    if (params_.box_stay) {
        // G5.61 (§8.162): a runner who has reached the box stays — a lower count does not
        // send him out. Real: of the men in the box, 70% (ball 18-35) to 91% (35-52) were
        // in it 2 s before; ours 43-51%, gone as the ball went back a zone.
        int there = 0;
        for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) {
            if (!((keep >> j) & 1u)) continue;
            const auto& q = world.player(j);
            if (world.pitchHalfX() - q.pos.x * sg < Fixed64::fromInt(18) && math::fx_abs(q.pos.y) < Fixed64::fromFraction(2016, 100)) ++there;
        }
        if (there > n) n = std::min(there, 4);
    }
    if (n == 0) { assignChannel(team, world, team_of_slot, role_of_slot, match_seed, z, deep, keepc); return; }
    // Who: weight = his role's real mean count ÷ the men of that role in this team; nearest first among equals.
    int per_role[kRoleCount] = {};
    for (std::uint8_t j = 0; j < world.playerCount(); ++j)
        if (team_of_slot[j] == team && !world.isKeeper(j)) ++per_role[static_cast<int>(role_of_slot[j])];
    const Vec2 box{sg * (world.pitchHalfX() - Fixed64::fromInt(12)), Fixed64::zero()};
    for (int pick = 0; pick < n; ++pick) {
        int best = -1; Fixed64 bw{}; bool bkept = false;
        for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) {
            if (team_of_slot[j] != team || world.isKeeper(j) || ((runners_ >> j) & 1u)) continue;
            if (b.owner && *b.owner == j) continue;
            const int r = static_cast<int>(role_of_slot[j]);
            if (params_.box_role[z][r].raw <= 0) continue;
            const Fixed64 d = math::length(Vec2{world.player(j).pos.x - box.x, world.player(j).pos.y - box.y});
            // role weight, a little less per 10 m from the box (nearest first among equals)
            const Fixed64 wgt = params_.box_role[z][r] / Fixed64::fromInt(per_role[r]) / (Fixed64::one() + d / Fixed64::fromInt(40));
            const bool kept = (keep >> j) & 1u;
            if (best < 0 || kept > bkept || (kept == bkept && wgt > bw)) { best = j; bw = wgt; bkept = kept; }
        }
        if (best < 0) break;
        runners_ |= 1u << best;
    }
    if (params_.box_spot_near) {
        // G5.60 (§8.161): the n spots to the n runners, least total distance (n ≤ 3, every order
        // tried). By slot number the far winger got the near post: 72% of a runner's gap was across.
        std::uint8_t who[4]; int m = 0;
        for (std::uint8_t j = 0; j < world.playerCount() && j < 32 && m < 4; ++j)
            if (team_of_slot[j] == team && ((runners_ >> j) & 1u)) who[m++] = j;
        const Fixed64 side = at.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
        static const int kSide[4] = {1, -1, 0, 1};
        Fixed64 dist[4][4];
        for (int k = 0; k < m; ++k) {
            const Vec2 t{(world.pitchHalfX() - (params_.box_depth[z] - Fixed64::fromInt(3) * Fixed64::fromInt(k / 4))) * sg,
                         side * params_.box_ay[z] * Fixed64::fromInt(kSide[k & 3])};
            for (int i = 0; i < m; ++i) dist[i][k] = math::length(Vec2{world.player(who[i]).pos.x - t.x, world.player(who[i]).pos.y - t.y});
        }
        int perm[4] = {0, 1, 2, 3}, bestp[4] = {0, 1, 2, 3}; Fixed64 bd{}; bool have = false;
        do {
            Fixed64 tot{};
            for (int i = 0; i < m; ++i) tot += dist[i][perm[i]];
            if (!have || tot < bd) { bd = tot; have = true; for (int i = 0; i < m; ++i) bestp[i] = perm[i]; }
        } while (std::next_permutation(perm, perm + m));
        for (int i = 0; i < m; ++i) spot_k_[who[i]] = static_cast<std::uint8_t>(bestp[i]);
    }
    assignChannel(team, world, team_of_slot, role_of_slot, match_seed, z, deep, keepc);
}

// G5.56 (§8.157): who stands in their wide channel on the ball's side — the real
// mean count for the zone and their line inside line_deep_m or not (whole part
// sure, the rest a roll), by the real role counts, nearest the channel spot
// first; never a box runner.
void Possession::assignChannel(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                               const std::vector<Role>& role_of_slot, std::uint64_t match_seed, int z, bool deep, std::uint32_t keep) {
    const auto& b = world.ball();
    const Fixed64 m = params_.chan_n[z][deep ? 1 : 0];
    int n = static_cast<int>(m.raw >> Fixed64::FRAC_BITS);
    const Fixed64 frac = m - Fixed64::fromInt(n);
    const Fixed64 u = (core::detNoise(match_seed, params_.box_spell_roll ? won_[team & 1] + (world.tickCount() - won_[team & 1]) / 90 * 90 : world.tickCount(), team, 69) + Fixed64::one()) * Fixed64::fromFraction(1, 2);   // G5.61
    if (u < frac) ++n;
    if (n <= 0) return;
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 side = b.pos.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
    const Vec2 spot{sg * (world.pitchHalfX() - params_.chan_depth[z]), side * params_.chan_ay[z]};
    int per_role[kRoleCount] = {};
    for (std::uint8_t j = 0; j < world.playerCount(); ++j)
        if (team_of_slot[j] == team && !world.isKeeper(j)) ++per_role[static_cast<int>(role_of_slot[j])];
    for (int pick = 0; pick < n; ++pick) {
        int best = -1; Fixed64 bw{}; bool bkept = false;
        for (std::uint8_t j = 0; j < world.playerCount() && j < 32; ++j) {
            if (team_of_slot[j] != team || world.isKeeper(j) || ((runners_ >> j) & 1u)) continue;
            if (b.owner && *b.owner == j) continue;
            const int r = static_cast<int>(role_of_slot[j]);
            if (params_.chan_role[z][r].raw <= 0) continue;
            const Fixed64 d = math::length(Vec2{world.player(j).pos.x - spot.x, world.player(j).pos.y - spot.y});
            const Fixed64 wgt = params_.chan_role[z][r] / Fixed64::fromInt(per_role[r]) / (Fixed64::one() + d / Fixed64::fromInt(15));
            const bool kept = (keep >> j) & 1u;
            if (best < 0 || kept > bkept || (kept == bkept && wgt > bw)) { best = j; bw = wgt; bkept = kept; }
        }
        if (best < 0) break;
        runners_ |= 1u << best;
        chan_ |= 1u << best;
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
        // G5.63: a holder who is only busy for a moment (the pass is his, or he is
        // running into the box or a channel) keeps the job, so it does not jump to
        // a man 7 m back and jump back when he is free (§8.164).
        if (params_.front_keep_busy && f[k] != 0xFF && f[k] != above && f[k] < world.playerCount() && team_of_slot[f[k]] == team &&
            !(b.owner && *b.owner == f[k]) && (b.pass_to == f[k] || runner(f[k]) || running(f[k]))) continue;
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


// G5.120: a 4 m-bin row by |y|, between the bin centres 2, 6 … 26, 30, held past the ends.
static Fixed64 yLookup(const Fixed64 (&row)[PossessionParams::kYBins], Fixed64 ay) {
    const Fixed64 u = (ay - Fixed64::fromInt(2)) / Fixed64::fromInt(4);
    if (u <= Fixed64::zero()) return row[0];
    if (u >= Fixed64::fromInt(PossessionParams::kYBins - 1)) return row[PossessionParams::kYBins - 1];
    const int i = static_cast<int>(u.raw >> Fixed64::FRAC_BITS);
    const Fixed64 f = u - Fixed64::fromInt(i);
    return row[i] + (row[i + 1] - row[i]) * f;
}

Fixed64 PossessionParams::slideAt(int role, Fixed64 by) const {
    const Fixed64 s = yLookup(slide[role], math::fx_abs(by));
    return by.raw < 0 ? -s : s;
}

// G5.73 (§8.174): the real high share for a pass this long from this far off our goal, linear
// between the length bands' middles (5, 15, … 55 m), held past the ends.
Fixed64 PossessionParams::highShare(Fixed64 own_m, Fixed64 len, int dir) const {
    const int o = own_m < Fixed64::fromInt(35) ? 0 : own_m < Fixed64::fromInt(70) ? 1 : 2;
    const Fixed64* h = high_dir_on && dir >= 0 && dir < 3 ? pass_high_dir[o][dir] : pass_high[o];
    if (len <= Fixed64::fromInt(5)) return h[0];
    if (len >= Fixed64::fromInt(55)) return h[5];
    const Fixed64 u = (len - Fixed64::fromInt(5)) / Fixed64::fromInt(10);
    const int i = static_cast<int>(u.raw >> Fixed64::FRAC_BITS);
    const Fixed64 f = u - Fixed64::fromInt(i);
    return h[i] + (h[i + 1] - h[i]) * f;
}

void PossessionParams::configure(const core::ModelParams& p) {
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kBandCount; ++b) {
            const std::string key = std::string("physics.support.") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5);
            spot[r][b] = p.fixed(key, std::int64_t{kRealSpotDm[r][b]} * 100);
            width[r][b] = p.fixed(std::string("physics.support.w_") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5), kRealWidthPm[r][b]);
        }
    slide_on = p.fixed("physics.support.slide_on", 1000).raw > 0;
    lone_on = p.fixed("physics.support.lone_on", 1000).raw > 0;
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kYBins; ++b) {
            const std::string yk = std::to_string(b * 4 + 2);
            slide[r][b] = p.fixed(std::string("physics.support.slide_") + kRoleKey[r] + "_" + yk, std::int64_t{kRealSlideDm[r][b]} * 100);
            const int li = r == static_cast<int>(Role::DM) ? 0 : r == static_cast<int>(Role::AM) ? 1 : r == static_cast<int>(Role::ST) ? 2 : -1;
            if (li < 0) continue;
            lone_p[r][b] = p.fixed(std::string("physics.support.lone_p_") + kRoleKey[r] + "_" + yk, kLoneP[li][b]);
            lone_near[r][b] = p.fixed(std::string("physics.support.lone_near_") + kRoleKey[r] + "_" + yk, std::int64_t{kLoneNearDm[li][b]} * 100);
            lone_far[r][b] = p.fixed(std::string("physics.support.lone_far_") + kRoleKey[r] + "_" + yk, std::int64_t{kLoneFarDm[li][b]} * 100);
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
    // G5.59 (§8.160): DFL 7 matches, benchmarks_tracking_passzone.py; cells under 10 passes 1000.
    static const int kKappa[10][10] = {
        {854, 2339, 740, 1000, 1000, 1000, 1000, 1000, 1000, 1000}, {609, 1390, 563, 876, 1000, 1000, 1000, 1000, 1000, 1000},
        {1465, 4000, 550, 1054, 510, 1111, 1000, 1000, 1000, 1000}, {1248, 3199, 525, 839, 514, 867, 1000, 1000, 1000, 1000},
        {4000, 1000, 860, 1360, 650, 1055, 744, 1657, 1000, 1000},  {1000, 1000, 829, 1106, 664, 945, 718, 1349, 4000, 1000},
        {1000, 1000, 1322, 2600, 687, 922, 682, 1100, 1328, 4000},  {1000, 1000, 1510, 3400, 657, 779, 606, 1042, 1071, 2591},
        {1000, 1000, 4000, 1000, 878, 1319, 721, 992, 811, 1417},   {1000, 1000, 1000, 1000, 1146, 1846, 829, 1045, 775, 1307}};
    const bool kappa_on = p.fixed("physics.pass.kappa_on", 1000).raw > 0;
    for (int o = 0; o < 10; ++o) {
        for (int d = 0; d < 10; ++d) {
            pass_to[o][d] = p.fixed(("physics.pass.to_" + std::to_string(o) + "_" + std::to_string(d)).c_str(), kTo[o][d]);
            pass_kappa[o][d] = kappa_on ? p.fixed(("physics.pass.kappa_" + std::to_string(o) + "_" + std::to_string(d)).c_str(), kKappa[o][d]) : Fixed64::one();
        }
        pass_loft[o] = p.fixed(("physics.pass.loft_" + std::to_string(o)).c_str(), kLoft[o]);
        pass_cross[o] = p.fixed(("physics.pass.cross_" + std::to_string(o)).c_str(), kCross[o]);
    }
    {   // G5.73 (§8.174): StatsBomb PL 15/16 open play, crosses out — high share by origin x length, permille
        static const int kHigh[3][6] = {{55, 52, 143, 539, 902, 979}, {53, 54, 123, 419, 775, 927}, {55, 74, 214, 462, 744, 874}};
        for (int o = 0; o < 3; ++o)
            for (int l = 0; l < 6; ++l)
                pass_high[o][l] = p.fixed(("physics.pass.high_" + std::to_string(o) + "_" + std::to_string(l)).c_str(), kHigh[o][l]);
        high_on = pass_high[0][0].raw > 0;
        // G5.75 (§8.176): by direction too (fwd within 60° / lateral / back), permille; a cell under
        // 30 real passes holds the next-shorter band's value (back 40 m+ from our third: 8 passes).
        static const int kHighDir[3][3][6] = {
            {{78, 78, 276, 729, 931, 982}, {36, 24, 36, 122, 473, 786}, {21, 19, 11, 44, 44, 44}},
            {{85, 92, 249, 643, 840, 937}, {36, 30, 40, 206, 692, 896}, {32, 24, 40, 78, 210, 210}},
            {{76, 107, 313, 625, 881, 881}, {62, 81, 163, 386, 737, 892}, {25, 24, 49, 143, 361, 361}}};
        for (int o = 0; o < 3; ++o)
            for (int d = 0; d < 3; ++d)
                for (int l = 0; l < 6; ++l)
                    pass_high_dir[o][d][l] = p.fixed(("physics.pass.high_" + std::to_string(o) + "_" + std::to_string(d) + "_" + std::to_string(l)).c_str(), kHighDir[o][d][l]);
        high_dir_on = p.fixed("physics.pass.high_dir_on", 1000).raw > 0;
    }
    {   // G5.76 (§8.177): StatsBomb PL 15/16 open play, crosses out — the share of passes to the
        // passer's own keeper, by the passer's 10 m off his own goal, permille (to 0.1 permille)
        static const int kGk[10] = {54200, 120700, 98300, 48100, 15400, 4200, 1200, 300, 200, 200};   // benchmarks_statsbomb_gkpass.py, keeper's own passes out
        for (int b = 0; b < 10; ++b) gk_share[b] = p.fixed(("physics.pass.gk_" + std::to_string(b)).c_str(), kGk[b]) / Fixed64::fromInt(1000);   // the row is permille
        gk_on = p.fixed("physics.pass.gk_on", 1000).raw > 0;
    }
    {   // G5.74 (§8.175): DFL 7 matches, benchmarks_tracking_passpick.py — lambda by maximum likelihood, m
        static const int kPick[3] = {15000, 10000, 8000};
        for (int o = 0; o < 3; ++o) pick_lambda[o] = p.fixed(("physics.pass.pick_lambda_" + std::to_string(o)).c_str(), kPick[o]);
    }
    {   // G5.83 (§8.184): DFL 7 matches, benchmarks_tracking_passpick.py MARKED PICK — within his zone the split
        // ~ e^(-d/lambda) x lift by his nearest opponent's metres, iterative scaling (8+ m = 1), x1000
        static const int kLift[3][5] = {{250, 200, 230, 330, 1000}, {270, 260, 270, 410, 1000}, {240, 220, 310, 420, 1000}};
        for (int b = 0; b < 3; ++b)
            for (int q = 0; q < 5; ++q)
                mark_lift[b][q] = p.fixed(("physics.pass.mark_lift_" + std::to_string(b) + "_" + std::to_string(q)).c_str(), kLift[b][q]);
        mark_on = p.fixed("physics.pass.mark_on", 1000).raw > 0;
    }
    clear_from_m = p.fixed("physics.onball.clear_from_m", 25000);
    press_on = p.fixed("physics.onball.press_on", 1000).raw > 0;        // G5.81 (§8.182), DFL PRESSED TOUCH
    press_toward = p.fixed("physics.onball.press_toward", 140);         // toward the man 14%
    press_across = p.fixed("physics.onball.press_across", 270);         // across 27%, away the rest
    pass_min_m = p.fixed("physics.onball.pass_min_m", 5000);
    onside_margin_m = p.fixed("physics.support.onside_margin_m", 500);
    spread_r_m = p.fixed("physics.support.spread_r_m", 12000);
    spread_k = p.fixed("physics.support.spread_k", 800);
    spread_max_m = p.fixed("physics.support.spread_max_m", 6000);
    risk_weight = p.fixed("physics.pass.risk_weight", 250);
    high_risk = p.fixed("physics.pass.high_risk_weight", 600);   // G5.73 fit: 0.25 / 0.6 / 1.0 → aerial duels 29.8 / 40.8 / 55.1 a match (44.1); a high ball is a contest by nature (real completes 36-57%), the read does not pick the ones that fail
    space_on = p.fixed("physics.space.on", 1000).raw > 0;               // G5.54
    space_risk = p.fixed("physics.space.risk_weight", 250);           // G5.54: one the race read says they win
    space_margin_ticks = static_cast<int>(p.fixed("physics.space.margin_s", 0).raw * 30 >> Fixed64::FRAC_BITS);   // G5.55: ours first by at least this
    space_roll_m = p.fixed("physics.space.roll_m", 2000);             // G5.57 [FH]: dies this far past the spot
    space_max_s = p.fixed("physics.space.max_s", 4500);               // G5.54: the first man's run to it, at most
    space_wide_y = p.fixed("physics.space.wide_y_m", 27000);
    space_back_m = p.fixed("physics.space.back_m", 2000);              // G5.58 [FH]: the runner no further past the spot           // [FH] the wide zones' middle (20.16-34)
    cross_depth_m = p.fixed("physics.cross.depth_m", 7500);            // real crosses land ~7.5 m out (StatsBomb, benchmarks_statsbomb_cross.py)
    {   // G5.91 (§8.192): DFL, 242 balls in behind
        static const int kLift[5] = {420, 650, 1040, 1730, 2950};
        for (int b = 0; b < 5; ++b) behind_lift[b] = p.fixed("physics.behind.lift_" + std::to_string(b), kLift[b]);
        behind_lift_on = p.fixed("physics.behind.lift_on", 1000).raw > 0;
    }
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
    box_sticky = p.fixed("physics.box.sticky", 1000).raw > 0;   // G5.60
    box_spot_near = p.fixed("physics.box.spot_near", 1000).raw > 0;   // G5.60
    box_from_pass = p.fixed("physics.box.from_pass", 1000).raw > 0;   // G5.60
    box_spell_roll = p.fixed("physics.box.spell_roll", 1000).raw > 0;   // G5.61
    box_stay = p.fixed("physics.box.stay", 1000).raw > 0;   // G5.61
    box_restart_keep = p.fixed("physics.box.restart_keep", 1000).raw > 0;   // G5.61
    box_line_deep_m = p.fixed("physics.box.line_deep_m", 16000);
    box_line_deep_out_m = p.fixed("physics.box.line_deep_out_m", 18000);
    // G5.62: their line's mean depth by the ball's metres off it (5 m bins, centres 2.5 … 67.5),
    // DFL benchmarks_tracking_linebyball.py; the support men follow a deeper line (follow_line_m 0 = off).
    static const int kLineUsual[14] = {2500, 6400, 9500, 12700, 15800, 18800, 21600, 24600, 27300, 29800, 32600, 35500, 37800, 39700};
    for (int i = 0; i < 14; ++i) line_usual[i] = p.fixed(("physics.support.line_usual_" + std::to_string(i * 5)).c_str(), kLineUsual[i]);
    follow_line_m = p.fixed("physics.support.follow_line_m", 10000);
    {   // G5.89 (§8.190): real DFL (benchmarks_tracking_zonemates.py, ball-side wide zones), ×1000.
        // The roll chance is the real share × 2.2 [FH fit]: a man rolled out wide spends part of
        // the spell getting there, so at ×1 the measured share came out at ~half real.
        static const int kP[3][2][2] = {{{90, 79}, {97, 101}}, {{213, 156}, {147, 196}}, {{37, 279}, {0, 196}}};
        static const int kTl[3][2][2] = {{{28500, 42000}, {26800, 42600}}, {{29300, 41100}, {29500, 42700}}, {{30800, 43900}, {30000, 44700}}};
        static const int kY[3][2][2] = {{{24700, 25500}, {25600, 26100}}, {{26000, 25600}, {26100, 26400}}, {{25100, 25700}, {26000, 24800}}};
        static const char* zk[3] = {"35c", "35w", "52w"}; static const char* rk[2] = {"st", "am"}; static const char* tk[2] = {"ahead", "level"};
        for (int z = 0; z < 3; ++z) for (int r = 0; r < 2; ++r) for (int t = 0; t < 2; ++t) {
            const std::string k = std::string("physics.drift.") + zk[z] + "_" + rk[r] + "_" + tk[t];
            drift_p[z][r][t] = p.fixed(k + "_p", kP[z][r][t]);
            drift_tl[z][r][t] = p.fixed(k + "_m", kTl[z][r][t]);
            drift_y[z][r][t] = p.fixed(k + "_y", kY[z][r][t]);
        }
        drift_on = p.fixed("physics.drift.on", 1000).raw > 0;
    }   // [FH]   // G5.61 [FH]: hysteresis; = line_deep_m turns it off
    // G5.56: their wide channel (0-18 m, |y| 20.16+), DFL benchmarks_tracking_box.py: mean men by the
    // zone and their line 16+ / inside 16, x1000; mean count by role (CB FB DM AM WIDE ST) x1000; depth, |y|.
    static const int kChN[6][2] = {{60, 520}, {310, 1390}, {20, 310}, {10, 500}, {0, 220}, {10, 470}};
    static const int kChRole[6][kRoleCount] = {{14, 122, 96, 46, 185, 46}, {33, 307, 181, 104, 541, 184}, {4, 25, 15, 8, 52, 15},
                                               {2, 45, 35, 20, 64, 31},   {0, 1, 0, 0, 5, 3},          {0, 2, 0, 1, 12, 6}};
    static const int kChD[6] = {10000, 11200, 14900, 14300, 15300, 13500}, kChY[6] = {26800, 28200, 26100, 27500, 25700, 27100};
    for (int z = 0; z < 6; ++z) {
        for (int d = 0; d < 2; ++d) chan_n[z][d] = p.fixed(("physics.chan.n_" + std::to_string(z) + "_" + std::to_string(d)).c_str(), kChN[z][d]);
        for (int r = 0; r < kRoleCount; ++r) chan_role[z][r] = p.fixed(("physics.chan.role_" + std::to_string(z) + "_" + std::string(kRoleKey[r])).c_str(), kChRole[z][r]);
        chan_depth[z] = p.fixed(("physics.chan.depth_" + std::to_string(z)).c_str(), kChD[z]);
        chan_ay[z] = p.fixed(("physics.chan.ay_" + std::to_string(z)).c_str(), kChY[z]);
    }
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
    front_keep_busy = p.fixed("physics.front.keep_busy", 1000).raw > 0;   // G5.63 [FH]
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

Vec2 Possession::spot(const PlayerView& v, const core::World& world, const std::vector<std::uint8_t>& team_of_slot) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_their = hx - world.ball().pos.x * v.sg;   // ball metres off their line
    Fixed64 x = bandLookup(params_.spot[static_cast<int>(v.role_ours)], off_their) + spellDepth(v);
    if (params_.follow_line_m.raw > 0) {
        // G5.62 (§8.163): a man near their line keeps his gap to it as it drops. The spot
        // is by the ball; the line's usual depth for this ball (DFL mean, 5 m bins) is
        // where the spot assumes it is. Deeper than that, he goes on by the difference —
        // all of it on the line, none follow_line_m behind it. Real (ball 18-35 wide):
        // men 0-5 m short of the line 1.61 → 2.35 as it drops inside 16 m; ours 1.40 → 1.17.
        // between the bins' centres (2.5, 7.5 … 67.5 m), held past the ends
        Fixed64 tl = off_their - Fixed64::fromFraction(5, 2);
        if (tl < Fixed64::zero()) tl = Fixed64::zero();
        const int bi = static_cast<int>(tl.raw >> Fixed64::FRAC_BITS) / 5;
        Fixed64 usual;
        if (bi >= 13) usual = params_.line_usual[13];
        else {
            const Fixed64 f = (tl - Fixed64::fromInt(bi * 5)) / Fixed64::fromInt(5);
            usual = params_.line_usual[bi] + (params_.line_usual[bi + 1] - params_.line_usual[bi]) * f;
        }
        const Fixed64 line = hx - offsideLine(v.team, world, team_of_slot);
        const Fixed64 drop = usual - line;
        if (drop.raw > 0) {
            const Fixed64 behind = x - usual;
            Fixed64 w = behind.raw <= 0 ? Fixed64::one() : Fixed64::one() - behind / params_.follow_line_m;
            if (w.raw > 0) x -= drop * w;
        }
    }
    if (x.raw < 0) x = Fixed64::zero();
    // G5.89 (§8.190): the striker / AM's drift into their wide channel on the ball's side — real
    // ones stand there 4-13% of the time with the ball 35-70 m out (ours: ST 0-3%, AM never). One
    // roll a man a spell a ball zone, against the real share; he takes the real spot. [FH, DFL]
    if (params_.drift_on && (v.role_ours == Role::ST || v.role_ours == Role::AM)) {
        const Fixed64 by = world.ball().pos.y;
        const bool wide = math::fx_abs(by) >= Fixed64::fromFraction(2016, 100);
        const int z = off_their >= Fixed64::fromInt(35) && off_their < Fixed64::fromInt(52) ? (wide ? 1 : 0)
                    : (off_their >= Fixed64::fromInt(52) && off_their < Fixed64::fromInt(70) && wide) ? 2 : -1;
        if (z >= 0) {
            const int r = v.role_ours == Role::ST ? 0 : 1;
            const Fixed64 u = (core::detNoise(v.match_seed, won_[v.team & 1], v.slot, 80 + z) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
            const Fixed64 pa = params_.drift_p[z][r][0], pl = params_.drift_p[z][r][1];
            const int t = u < pa ? 0 : u < pa + pl ? 1 : -1;
            if (t >= 0) {
                const Fixed64 side = by.raw >= 0 ? Fixed64::one() : -Fixed64::one();
                return Vec2{(hx - params_.drift_tl[z][r][t]) * v.sg, side * params_.drift_y[z][r][t]};
            }
        }
    }
    if (params_.lone_on && v.lone_ours && (v.role_ours == Role::DM || v.role_ours == Role::AM || v.role_ours == Role::ST)) {
        // G5.120 (§8.221): a lone DM / AM / ST stands off the centre line, a side a spell — real ones keep one
        // side through a spell with the ball central 95-97%, on the ball's side more as it goes wide. One roll a
        // man a spell; mirrored with the ball's side, so with the ball central (p a half) his side holds.
        const int r = static_cast<int>(v.role_ours);
        const Fixed64 by = world.ball().pos.y, ay = math::fx_abs(by);
        int b = static_cast<int>(ay.raw >> Fixed64::FRAC_BITS) / 4;
        if (b >= PossessionParams::kYBins) b = PossessionParams::kYBins - 1;
        const Fixed64 u = (core::detNoise(v.match_seed, won_[v.team & 1], v.slot, 90) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        const bool pos = by.raw >= 0;
        const bool near = (pos ? u : Fixed64::one() - u) < params_.lone_p[r][b];
        const Fixed64 s = yLookup(near ? params_.lone_near[r] : params_.lone_far[r], ay);
        return Vec2{(hx - x) * v.sg, pos ? s : -s};
    }
    return Vec2{(hx - x) * v.sg, v.across_ours};
}

}  // namespace fh::game::ai
