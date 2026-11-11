// game/src/ai/DefendingBlock.cpp — out of possession (G5.21, DESIGN §8.119).
#include "ai/DefendingBlock.hpp"

#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "core/PlayerSkill.hpp"
#include "math/FixedMath.hpp"

#include <algorithm>
#include <string>

namespace fh::game::ai {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

// Real (DFL, 7 matches, the side without the ball, in play, 5 Hz, SETTLED: 6 s+
// since it lost it, and the ball STILL: under 2 m/s toward or away from its line
// over the last second): mean metres off its own line by role, ball in bands
// 0-10 … 90-100 m off that line — benchmarks_tracking_lag.py (G5.42, §8.142).
// The spot is where he stands once he has caught up with the ball. Real men
// trail a moving ball as ours do (with it coming at them at 5+ m/s a real CB is
// 4-6 m higher than with it still; going away, 1.5-3.5 m deeper); G5.33's spots
// (§8.131) were the mean over every settled frame, that lag included, so ours
// caught up to a spot already ~1 s behind and then trailed it as well: 3.5-5 m
// high with the ball still at every band inside 50 m, the offside line 4 m high.
constexpr int kRealSpotDm[kRoleCount][kBandCount] = {   // decimetres
    { 77, 116, 170, 228, 275, 327, 368, 416, 449, 497},   // CB
    {104, 145, 189, 253, 290, 349, 391, 446, 475, 532},   // FB
    {138, 176, 230, 308, 358, 414, 461, 527, 565, 619},   // DM/CM
    {274, 285, 307, 391, 444, 510, 562, 627, 703, 772},   // AM
    {193, 238, 266, 352, 392, 456, 507, 574, 621, 713},   // WIDE
    {390, 374, 402, 471, 502, 566, 611, 676, 737, 829},   // ST
};
const char* const kRoleKey[kRoleCount] = {"cb", "fb", "dm", "am", "wide", "st"};

// G5.38 (§8.138): the settled block's width (DFL, 6 s+ since it lost it, by the
// ball's 10 m band off its line): the real gap between a role's pair — CB 9.5 →
// 12 m, FB 23.7 → 36, WIDE 24.5 → 32.7, DM/CM 9.6 → 12 — over the standard
// game's own settled gap with no factor (its men already stand ~20% inside their
// formation width: the slide and its caps), permille — real / game-before, fitted
// so the game's pairs measure the real gaps (benchmarks_tracking_possession.py and
// fh-game-match SETTLED WIDTH). AM and ST: no pair
// in the data, kept whole. A real block narrows toward its goal: its full-backs
// stand half their formation width apart with the ball 0-20 m out.
constexpr int kRealWidthPm[kRoleCount][kBandCount] = {
    {860, 900, 940, 820, 800, 800, 800, 850, 840, 830},   // CB
    {500, 510, 555, 600, 640, 700, 720, 745, 760, 740},   // FB
    {890, 770, 860, 860, 920, 950, 970, 920, 870, 730},   // DM/CM
    {1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000},   // AM
    {660, 660, 750, 840, 910, 970, 970, 940, 940, 860},   // WIDE
    {1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000},   // ST
};

bool inPlay(const core::World& w) { return w.restartTeam() == 0xFF && w.outStage() == 0; }

// Where a pro defender of his role stands for this ball.
class HoldBlockSpot final : public ActingState {
public:
    std::uint8_t id() const override { return 1; }
    const char* name() const override { return "hold the block spot"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const auto& me = c.world.player(v.slot);
        o.target = c.block.spot(v, c.world);
        o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 2));
        o.why = Why::Hold;
        return true;
    }
};

// The one man who steps to their carrier: stand_off metres goal-side of him,
// on his line to our goal; in reach and goal-side he may dive in.
class PressBall final : public ActingState {
public:
    std::uint8_t id() const override { return 2; }
    const char* name() const override { return "press the ball"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const auto& ball = c.world.ball();
        const bool flight = !ball.owner && c.block.pressFlight(v.team);   // G5.82: their pass still travelling
        if (!ball.owner && !flight) return false;
        const auto& me = c.world.player(v.slot);
        const Vec2 crp = flight ? c.block.pressAt(v.team) : Vec2{c.world.player(*ball.owner).pos.x, c.world.player(*ball.owner).pos.y};
        const Vec2 own_goal{-v.sg * c.world.pitchHalfX(), Fixed64::zero()};
        const Vec2 to_goal{own_goal.x - crp.x, own_goal.y - crp.y};
        const Fixed64 len = math::length(to_goal);
        const Fixed64 off_line = c.world.pitchHalfX() + (flight ? crp.x : ball.pos.x) * v.sg;   // ball metres off our line
        const int band = off_line < Fixed64::fromInt(18) ? 0 : off_line < Fixed64::fromInt(35) ? 1
                       : off_line < Fixed64::fromInt(52) ? 2 : off_line < Fixed64::fromInt(70) ? 3 : 4;
        const auto& q = c.block.params().stand_off[band];
        const Fixed64 u = (core::detNoise(v.match_seed, c.world.ownedAtTick(), v.slot, 30) + Fixed64::one()) *
                          Fixed64::fromFraction(1, 2);   // [0, 1): p25 … p75
        const Fixed64 off = u < Fixed64::fromFraction(1, 2) ? q[0] + (q[1] - q[0]) * u * 2
                                                            : q[1] + (q[2] - q[1]) * (u * 2 - Fixed64::one());
        o.target = len.raw > 0 ? Vec2{crp.x + to_goal.x * off / len, crp.y + to_goal.y * off / len}
                               : crp;
        o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 10));
        o.move.face = flight ? Vec2{ball.pos.x - me.pos.x, ball.pos.y - me.pos.y} : Vec2{crp.x - me.pos.x, crp.y - me.pos.y};
        o.other = ball.owner ? static_cast<std::int16_t>(*ball.owner) : static_cast<std::int16_t>(-1);
        o.why = Why::Press;
        const bool goal_side = (me.pos.x - crp.x) * v.sg < Fixed64::zero();
        if (!flight && goal_side && distSq(me.pos, ball.pos) < core::kTackleReach * core::kTackleReach) {
            const Fixed64 per_tick = c.block.params().tackle_per_s * core::kTickDt;
            const Fixed64 n = core::detNoise(v.match_seed, c.tick, v.slot, 29);   // [-1, 1)
            if ((n + Fixed64::one()) * Fixed64::fromFraction(1, 2) < per_tick) o.action = core::Action::Tackle;
        }
        return true;
    }
};

// His team's man for a loose ball goes to where he can take it.
class ChaseBall final : public ActingState {
public:
    std::uint8_t id() const override { return 3; }
    const char* name() const override { return "chase the ball"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        o.target = v.chase_to;
        o.move.move = seek(c.world.player(v.slot).pos, o.target, Fixed64::fromFraction(1, 10));
        o.why = Why::Chase;
        return true;
    }
};

// G5.72 (§8.173): goal-side of the man he marks, mark_d off him on the man's line to our goal's
// centre, running with him (Brain::blockLead) and facing the ball. Coaching: goal-side, see man
// and ball; tighter the nearer our goal [FH, fitted to DFL].
class MarkMan final : public ActingState {
public:
    std::uint8_t id() const override { return 4; }
    const char* name() const override { return "mark his man"; }
    bool act(const PlayerView& v, const PlayerCtx& c, Orders& o) const override {
        const int m = c.block.markOf(v.team, v.slot);
        if (m < 0) return false;
        const auto& me = c.world.player(v.slot);
        o.target = c.block.markPoint(v.team, m, c.world);
        o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 4));
        o.move.face = Vec2{c.world.ball().pos.x - me.pos.x, c.world.ball().pos.y - me.pos.y};
        o.other = static_cast<std::int16_t>(m);
        o.why = Why::Mark;
        return true;
    }
};

const MarkMan kMark;
const HoldBlockSpot kHold;
const PressBall kPress;
const ChaseBall kChase;

}  // namespace

const ActingState* DefendingBlock::holdBlockSpot() { return &kHold; }
const ActingState* DefendingBlock::pressBall() { return &kPress; }
const ActingState* DefendingBlock::chaseBall() { return &kChase; }
const ActingState* DefendingBlock::markMan() { return &kMark; }

void BlockParams::configure(const core::ModelParams& p) {
    static const int kLine[5] = {-5600, -3500, -800, 2400, 5400};   // G5.52, DFL spell offsets (m x1000)
    static const char* const kLq[5] = {"p10", "p25", "p50", "p75", "p90"};
    for (int k = 0; k < 5; ++k) line_q[k] = p.fixed(("physics.block.line_" + std::string(kLq[k])).c_str(), kLine[k]);
    // G5.70 (§8.171): each FORWARD's own offset off his role's spot, one roll a spell of theirs —
    // DFL (benchmarks_tracking_blockspread.py), net of the block's own offset (line_q), m x1000;
    // with the ball 20 m+ out (man_*) and inside 20 m of our goal (man_near_*), where one stays up
    // and another drops in. Defenders (CB / FB / DM) are 0: their real spread is who they mark,
    // which the block doesn't model — a random roll there is holes, not marking (the rows exist).
    static const int kMan[kRoleCount][5] = {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0},
                                            {-7300, -4000, -400, 3500, 7700}, {-7500, -3100, 800, 5200, 9600}, {-8500, -4100, 200, 3400, 6500}};
    static const int kManNear[kRoleCount][5] = {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0},
                                                {-9300, -5800, -1000, 5000, 12700}, {-8700, -5300, -300, 5400, 12300}, {-15900, -6800, 3600, 9600, 13200}};
    for (int r = 0; r < kRoleCount; ++r)
        for (int k = 0; k < 5; ++k) {
            man_q[r][k] = p.fixed((std::string("physics.block.man_") + kLq[k] + "_" + kRoleKey[r]).c_str(), kMan[r][k]);
            man_near_q[r][k] = p.fixed((std::string("physics.block.man_near_") + kLq[k] + "_" + kRoleKey[r]).c_str(), kManNear[r][k]);
        }
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kBandCount; ++b) {
            const std::string key = std::string("physics.block.") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5);
            spot[r][b] = p.fixed(key, std::int64_t{kRealSpotDm[r][b]} * 100);
            width[r][b] = p.fixed(std::string("physics.block.w_") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5), kRealWidthPm[r][b]);
        }
    // Real (DFL, the nearest defender to the man on the ball): p25 / median / p75 m.
    static const int kOff[5][3] = {{1200, 2100, 3600}, {1700, 3000, 4800}, {2000, 3900, 6600},
                                   {2800, 5500, 9200}, {3700, 8000, 13300}};
    static const char* kQ[3] = {"p25", "p50", "p75"};
    for (int b = 0; b < 5; ++b)
        for (int k = 0; k < 3; ++k)
            stand_off[b][k] = p.fixed((std::string("physics.press.stand_off_") + std::to_string(b) + "_" + kQ[k]).c_str(), kOff[b][k]);
    // Real (DFL, benchmarks_tracking_cover.py): the two CBs' depth gap by the ball's band, mm.
    static const int kStagger[kBandCount] = {3200, 2800, 2800, 2800, 3000, 2800, 2800, 2900, 2800, 3700};
    for (int b = 0; b < kBandCount; ++b)
        stagger[b] = p.fixed(std::string("physics.block.stagger_") + std::to_string(b * 10 + 5), kStagger[b]);
    {   // G5.72 (§8.173): marking radius / stand-off by the attacker's m off our goal, mm [FH, fitted]
        static const int kR[4] = {12000, 8000, 8000, 6000}, kD[4] = {1500, 3000, 3000, 4000};
        for (int b = 0; b < 4; ++b) {
            mark_r[b] = p.fixed(("physics.block.mark_r_" + std::to_string(b)).c_str(), kR[b]);
            mark_d[b] = p.fixed(("physics.block.mark_d_" + std::to_string(b)).c_str(), kD[b]);
        }
    }
    switch_m = p.fixed("physics.press.switch_m", 2000);
    gs_r = p.fixed("physics.block.gs_r", 0);   // G5.85 (§8.186) [FH]: built, left OFF — no row = off (mm)
    gs_w = p.fixed("physics.block.gs_w", 10000);
    gs_m = p.fixed("physics.block.gs_m", 1000);
    contest_min_z = p.fixed("physics.block.contest_min_z_m", 1500);
    {   // G5.82 (§8.183): s -> ticks; negative = off
        const Fixed64 m = p.fixed("physics.block.their_pass_margin_s", 0);
        their_pass_margin = m.raw < 0 ? -1 : static_cast<int>((m * Fixed64::fromInt(30)).raw >> Fixed64::FRAC_BITS);
    }
    press_on_pass = p.fixed("physics.press.on_pass", 1000).raw > 0;
    tackle_per_s = p.fixed("physics.press.tackle_per_s", 500);
}

void DefendingBlock::assign(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                            const std::vector<Role>& role_of_slot, const Reads::FlightRead& fr, int restart_taker) {
    const auto& ball = world.ball();
    const bool live = inPlay(world);
    {   // G5.52: their live spell on the ball (as Possession's, from the other side)
        const bool theirs = (ball.owner ? team_of_slot[*ball.owner] != team : world.lastTouchTeam() != team) &&
                            world.restartTeam() == 0xFF && world.outStage() == 0;
        if (theirs && !their_had_[team & 1]) their_won_[team & 1] = world.tickCount();
        their_had_[team & 1] = theirs;
    }
    // The nearest outfielder to the ball, held until another is switch_m nearer.
    auto nearest = [&](int held) {
        int best = -1; Fixed64 bd{};
        for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
            if (team_of_slot[j] != team || world.isKeeper(j)) continue;
            const Fixed64 d = distSq(world.player(j).pos, ball.pos);
            if (best < 0 || d < bd) { best = j; bd = d; }
        }
        if (held >= 0 && held != best && team_of_slot[held] == team && !world.isKeeper(static_cast<std::uint8_t>(held))) {
            const Fixed64 dk = math::fx_sqrt(distSq(world.player(static_cast<std::uint8_t>(held)).pos, ball.pos));
            if (dk < math::fx_sqrt(bd) + params_.switch_m) return held;
        }
        return best;
    };
    int& ch = chaser_[team & 1];
    int press_to = -1;   // G5.82: their receiver, when nobody of ours chases their pass
    if (live && !ball.owner && fr.live) {
        // Our pass (G4.81): the man it's for meets it; the rest let it run —
        // unless they get there first, when our first man goes too.
        const int to = ball.pass_to < world.playerCount() && team_of_slot[ball.pass_to] == team &&
                               world.lastTouchTeam() == team ? static_cast<int>(ball.pass_to) : -1;
        const int theirs = fr.first[team ^ 1];
        const bool their_pass = world.lastTouchTeam() != team && ball.pass_to < world.playerCount() && team_of_slot[ball.pass_to] != team;
        if (to >= 0 && fr.tick[to] >= 0 && (theirs < 0 || fr.tick[to] <= fr.tick[theirs])) ch = to;
        // G5.82 (§8.183): their pass, their man first to it by more than the margin — nobody of
        // ours chases it; each keeps his job (mark, block spot) and the presser steps to the man
        // once it is his. Real receivers of a 10-30 m pass have a man of ours inside 3 m at the
        // touch 5-10% (DFL, benchmarks_tracking_firsttouch.py RECEIVER SPACE); our first man ran
        // to where HE could first take it — down the line past their receiver, onto him — 22-28%.
        else if (params_.their_pass_margin >= 0 && their_pass && theirs >= 0 && fr.tick[theirs] >= 0 &&
                 (fr.first[team] < 0 || fr.tick[fr.first[team]] < 0 || fr.tick[fr.first[team]] > fr.tick[theirs] + params_.their_pass_margin)) {
            ch = -1; press_to = theirs;
        }
        else if (fr.first[team] >= 0) ch = fr.first[team];
        // Nobody of ours can get there inside the race read's horizon (a ball come
        // to rest far from everyone): our nearest goes — else it sat there for good.
        else ch = nearest(ch);
        // G5.71 (§8.172): their high ball, their man first to it — our nearest outfielder to
        // where he meets it goes there, to contest it in the air or be on him as it lands.
        // Without it our chaser ran to where HE could first take it, past their man: the
        // nearest of ours was 5.7 m off a high ball at head height in midfield (real 1.6),
        // aerial duels 18 a match (real 44), and their side kept the ball it had just won.
        int& ct = contest_[team & 1];
        const int mine = fr.first[team];
        if (params_.contest_min_z.raw > 0 && world.lastTouchTeam() != team && ball.pos.z >= params_.contest_min_z &&
            theirs >= 0 && fr.tick[theirs] >= 0 && (mine < 0 || fr.tick[mine] < 0 || fr.tick[theirs] < fr.tick[mine])) {
            const Vec2 at = fr.at[theirs];
            const Vec3 at3{at.x, at.y, Fixed64::zero()};
            int best = -1; Fixed64 bd{};
            for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
                if (team_of_slot[j] != team || world.isKeeper(j)) continue;
                const Fixed64 d = distSq(world.player(j).pos, at3);
                if (best < 0 || d < bd) { best = j; bd = d; }
            }
            if (ct >= 0 && ct != best && team_of_slot[ct] == team && !world.isKeeper(static_cast<std::uint8_t>(ct)) &&
                math::fx_sqrt(distSq(world.player(static_cast<std::uint8_t>(ct)).pos, at3)) < math::fx_sqrt(bd) + params_.switch_m) best = ct;
            ct = best; contest_at_[team & 1] = at;
            if (best >= 0) ch = best;
        } else ct = -1;
    } else if (live && !ball.owner) {
        ch = nearest(ch);
    } else if (world.restartTeam() == team && world.outStage() == 0 && !ball.owner) {
        // Our dead ball: a held one (throw, goal kick, corner) is its taker's
        // (restartTaker, at its spot); a kick-off or free kick, the nearest man.
        ch = world.heldRestart() ? restart_taker : nearest(ch);
    } else ch = -1;
    if (!(live && !ball.owner && fr.live)) contest_[team & 1] = -1;
    int& pr = presser_[team & 1];
    press_flight_[team & 1] = false;
    if (live && !ball.owner && press_to >= 0 && params_.press_on_pass && contest_[team & 1] < 0) {
        // G5.82 (§8.183): our nearest to where their man meets it, held until another is switch_m nearer
        const Vec2 at = fr.at[press_to];
        const Vec3 at3{at.x, at.y, Fixed64::zero()};
        int best = -1; Fixed64 bd{};
        for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
            if (team_of_slot[j] != team || world.isKeeper(j)) continue;
            const Fixed64 d = distSq(world.player(j).pos, at3);
            if (best < 0 || d < bd) { best = j; bd = d; }
        }
        if (pr >= 0 && pr != best && team_of_slot[pr] == team && !world.isKeeper(static_cast<std::uint8_t>(pr)) &&
            math::fx_sqrt(distSq(world.player(static_cast<std::uint8_t>(pr)).pos, at3)) < math::fx_sqrt(bd) + params_.switch_m) best = pr;
        pr = best; press_at_[team & 1] = at; press_flight_[team & 1] = best >= 0;
    } else if (!live || !ball.owner || team_of_slot[*ball.owner] == team) pr = -1;
    else pr = nearest(pr);
    assignCover(team, world, team_of_slot, role_of_slot);
}

namespace {
int markBand(Fixed64 off_goal) {
    return off_goal < Fixed64::fromInt(18) ? 0 : off_goal < Fixed64::fromInt(35) ? 1 : off_goal < Fixed64::fromInt(52) ? 2 : 3;
}
}  // namespace

// G5.72 (§8.173): who marks whom. In play, their ball (on it, or loose after their touch): every
// pair of our marking man (CB / FB / DM, not the chaser / presser / contester) and their outfielder
// (not the carrier — the presser has him) within mark_r of our man's block spot (his zone); nearest
// in fact first, one marker a man, one man a marker; a pair already on counts switch_m nearer than
// it is and holds to mark_r + 2·switch_m (held).
void DefendingBlock::assignMarks(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                                 const std::vector<Vec2>& spot_of, const std::vector<bool>& marks) {
    int* mk = mark_[team & 1];
    const auto& ball = world.ball();
    const bool theirs = inPlay(world) && (ball.owner ? team_of_slot[*ball.owner] != team : world.lastTouchTeam() != team && world.lastTouchTeam() <= 1);
    int prev[32];
    for (int j = 0; j < 32; ++j) { prev[j] = mk[j]; mk[j] = -1; }
    if (!theirs || params_.mark_r[0].raw <= 0) return;
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();   // our attack direction
    struct Pair { Fixed64 cost; int d, a; };
    std::vector<Pair> pairs;
    const int t = team & 1;
    for (std::uint8_t d = 0; d < world.playerCount() && d < 32; ++d) {
        if (team_of_slot[d] != team || world.isKeeper(d) || d >= marks.size() || !marks[d]) continue;
        if (d == chaser_[t] || d == presser_[t] || d == contest_[t]) continue;
        for (std::uint8_t a = 0; a < world.playerCount() && a < 32; ++a) {
            if (team_of_slot[a] == team || world.isKeeper(a) || (ball.owner && *ball.owner == a)) continue;
            const auto& ap = world.player(a).pos;
            const Fixed64 r = params_.mark_r[markBand(hx + ap.x * sg)];
            if (r.raw <= 0) continue;
            const Fixed64 dist = math::length(Vec2{ap.x - spot_of[d].x, ap.y - spot_of[d].y});
            if (dist >= (prev[d] == a ? r + params_.switch_m * 2 : r)) continue;   // a man already marked is kept a little further
            // In his zone by the spot; who takes him by where our men actually are (the spot slides with the
            // ball — by it, a man 15 m off got him and the mark jumped between men every few ticks).
            const auto& dp = world.player(d).pos;
            const Fixed64 real = math::length(Vec2{ap.x - dp.x, ap.y - dp.y});
            pairs.push_back({prev[d] == a ? real - params_.switch_m : real, d, a});
        }
    }
    std::sort(pairs.begin(), pairs.end(), [](const Pair& x, const Pair& y) { return x.cost.raw != y.cost.raw ? x.cost.raw < y.cost.raw : (x.d != y.d ? x.d < y.d : x.a < y.a); });
    bool taken[32] = {};
    for (const auto& pr : pairs)
        if (mk[pr.d] < 0 && !taken[pr.a]) { mk[pr.d] = pr.a; taken[pr.a] = true; }
}

Vec2 DefendingBlock::markPoint(std::uint8_t team, int man, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const auto& ap = world.player(static_cast<std::uint8_t>(man)).pos;
    const Vec2 to_goal{-sg * hx - ap.x, -ap.y};
    const Fixed64 len = math::length(to_goal);
    const Fixed64 d = params_.mark_d[markBand(hx + ap.x * sg)];
    if (len <= d) return Vec2{ap.x, ap.y};
    return Vec2{ap.x + to_goal.x * d / len, ap.y + to_goal.y * d / len};
}

// G5.41 (§8.141): with exactly two CBs on, the one nearer their most advanced
// outfielder is the deeper of the pair (he goes with the man who threatens the
// space behind; his partner stands higher), held until the other is switch_m
// nearer. Real (DFL): the pair stands ~2.8 m apart in depth at every band; the
// deeper man is the far one from the ball only half the time — not a side rule.
void DefendingBlock::assignCover(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                                 const std::vector<Role>& role_of_slot) {
    int& dc = deep_cb_[team & 1];
    int& oc = other_cb_[team & 1];
    int cb[2] = {-1, -1}, n = 0;
    for (std::uint8_t j = 0; j < world.playerCount() && j < role_of_slot.size(); ++j)
        if (team_of_slot[j] == team && !world.isKeeper(j) && role_of_slot[j] == Role::CB) { if (n < 2) cb[n] = j; ++n; }
    if (n != 2) { dc = oc = -1; return; }
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();   // our attack direction
    int front = -1; Fixed64 fx{};
    for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
        if (team_of_slot[j] == team || world.isKeeper(j)) continue;
        const Fixed64 x = world.player(j).pos.x * sg;   // smaller = nearer our goal
        if (front < 0 || x < fx) { front = j; fx = x; }
    }
    if (front < 0) { dc = oc = -1; return; }
    const Vec2 fp{world.player(static_cast<std::uint8_t>(front)).pos.x, world.player(static_cast<std::uint8_t>(front)).pos.y};
    const Fixed64 d0 = math::fx_sqrt(distSq(world.player(static_cast<std::uint8_t>(cb[0])).pos, Vec3{fp.x, fp.y, Fixed64::zero()}));
    const Fixed64 d1 = math::fx_sqrt(distSq(world.player(static_cast<std::uint8_t>(cb[1])).pos, Vec3{fp.x, fp.y, Fixed64::zero()}));
    int pick = d0 <= d1 ? cb[0] : cb[1];
    if (dc == cb[0] || dc == cb[1]) {   // held until the other is switch_m nearer
        const Fixed64 dk = dc == cb[0] ? d0 : d1, dn = dc == cb[0] ? d1 : d0;
        if (dn + params_.switch_m > dk) pick = dc;
    }
    dc = pick; oc = pick == cb[0] ? cb[1] : cb[0];
}

Vec2 DefendingBlock::spot(const PlayerView& v, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_line = hx + v.ball_to.x * v.sg;   // the ball's metres off our own line, where it's going
    Fixed64 x = bandLookup(params_.spot[static_cast<int>(v.role)], off_line);
    // G5.41: the pair's mean is the real CB spot; the deeper man half the gap below it.
    if (v.role == Role::CB) {
        const int t = v.team & 1;
        const Fixed64 half_gap = bandLookup(params_.stagger, off_line) * Fixed64::fromFraction(1, 2);
        if (deep_cb_[t] == v.slot) x -= half_gap;
        else if (other_cb_[t] == v.slot) x += half_gap;
    }
    {   // G5.52: the block's depth for their possession, one roll for the team
        const Fixed64 u = (core::detNoise(v.match_seed, their_won_[v.team & 1], v.team, 68) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        const Fixed64* q = params_.line_q;
        static const Fixed64 kAt[5] = {Fixed64::fromFraction(1, 10), Fixed64::fromFraction(1, 4), Fixed64::fromFraction(1, 2),
                                       Fixed64::fromFraction(3, 4), Fixed64::fromFraction(9, 10)};
        auto roll = [&](const Fixed64* qq, Fixed64 uu) {
            if (uu <= kAt[0]) return qq[0];
            for (int i = 0; i < 4; ++i)
                if (uu <= kAt[i + 1]) return qq[i] + (qq[i + 1] - qq[i]) * (uu - kAt[i]) / (kAt[i + 1] - kAt[i]);
            return qq[4];
        };
        Fixed64 off = roll(q, u);
        // Full from 18 m out, fading to nothing at 9 m [FH].
        if (off_line < Fixed64::fromInt(18))
            off = off_line <= Fixed64::fromInt(9) ? Fixed64::zero() : off * (off_line - Fixed64::fromInt(9)) / Fixed64::fromInt(9);
        x += off;
        // G5.70: and his own, one roll a man a spell (the tails held at p10 / p90), no fade:
        // the near-goal table inside 15 m, the far one from 25 m, blended between.
        const Fixed64 um = (core::detNoise(v.match_seed, their_won_[v.team & 1], v.slot, 71) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        const int ri = static_cast<int>(v.role);
        const Fixed64 far = roll(params_.man_q[ri], um), near = roll(params_.man_near_q[ri], um);
        const Fixed64 n15 = Fixed64::fromInt(15), n25 = Fixed64::fromInt(25);
        x += off_line <= n15 ? near : off_line >= n25 ? far : near + (far - near) * (off_line - n15) / (n25 - n15);
        if (x < Fixed64::one()) x = Fixed64::one();
    }
    Vec2 at{(x - hx) * v.sg, v.across_def};
    if (params_.gs_r.raw > 0) {   // G5.85 (§8.186): ball near our goal — between it and the goal
        const Vec2 g{-v.sg * hx, Fixed64::zero()};
        const Fixed64 db = math::length(Vec2{v.ball_to.x - g.x, v.ball_to.y - g.y});
        if (db < params_.gs_r && math::length(Vec2{at.x - v.ball_to.x, at.y - v.ball_to.y}) < params_.gs_w) {
            Fixed64 t = db - params_.gs_m;
            if (t < Fixed64::one()) t = Fixed64::one();
            const Fixed64 dp = math::length(Vec2{at.x - g.x, at.y - g.y});
            if (dp > t) at = Vec2{g.x + (at.x - g.x) * t / dp, g.y + (at.y - g.y) * t / dp};
        }
    }
    return at;
}

}  // namespace fh::game::ai
