// game/src/ai/DefendingBlock.cpp — out of possession (G5.21, DESIGN §8.119).
#include "ai/DefendingBlock.hpp"

#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "core/PlayerSkill.hpp"
#include "math/FixedMath.hpp"

#include <string>

namespace fh::game::ai {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

// Real (DFL, 7 matches, the side without the ball, in play, 5 Hz, SETTLED: 6 s+
// since it lost it): mean metres off its own line by role, ball in bands 0-10 …
// 90-100 m off that line — benchmarks_tracking_possession.py DEFENDING SHAPE,
// SETTLED (G5.33, §8.131). Half of all real defending frames are the 6 s after
// a turnover, when men far from their goal still stand 3-9 m higher; the
// all-frames table (§8.111/§8.118) put the settled block on that blend.
constexpr int kRealSpotDm[kRoleCount][kBandCount] = {   // decimetres
    {100, 145, 201, 260, 305, 351, 386, 426, 454, 494},   // CB
    {131, 179, 227, 287, 327, 378, 413, 455, 480, 528},   // FB
    {176, 219, 277, 350, 393, 447, 487, 539, 575, 620},   // DM/CM
    {309, 335, 376, 437, 485, 542, 588, 645, 707, 777},   // AM
    {235, 279, 325, 397, 438, 492, 535, 591, 636, 710},   // WIDE
    {413, 427, 467, 522, 554, 602, 640, 696, 753, 832},   // ST
};
const char* const kRoleKey[kRoleCount] = {"cb", "fb", "dm", "am", "wide", "st"};

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
        if (!ball.owner) return false;
        const auto& me = c.world.player(v.slot);
        const auto& cr = c.world.player(*ball.owner);
        const Vec2 own_goal{-v.sg * c.world.pitchHalfX(), Fixed64::zero()};
        const Vec2 to_goal{own_goal.x - cr.pos.x, own_goal.y - cr.pos.y};
        const Fixed64 len = math::length(to_goal);
        const Fixed64 off_line = c.world.pitchHalfX() + ball.pos.x * v.sg;   // ball metres off our line
        const int band = off_line < Fixed64::fromInt(18) ? 0 : off_line < Fixed64::fromInt(35) ? 1
                       : off_line < Fixed64::fromInt(52) ? 2 : off_line < Fixed64::fromInt(70) ? 3 : 4;
        const auto& q = c.block.params().stand_off[band];
        const Fixed64 u = (core::detNoise(v.match_seed, c.world.ownedAtTick(), v.slot, 30) + Fixed64::one()) *
                          Fixed64::fromFraction(1, 2);   // [0, 1): p25 … p75
        const Fixed64 off = u < Fixed64::fromFraction(1, 2) ? q[0] + (q[1] - q[0]) * u * 2
                                                            : q[1] + (q[2] - q[1]) * (u * 2 - Fixed64::one());
        o.target = len.raw > 0 ? Vec2{cr.pos.x + to_goal.x * off / len, cr.pos.y + to_goal.y * off / len}
                               : Vec2{cr.pos.x, cr.pos.y};
        o.move.move = seek(me.pos, o.target, Fixed64::fromFraction(1, 10));
        o.move.face = Vec2{cr.pos.x - me.pos.x, cr.pos.y - me.pos.y};
        o.other = static_cast<std::int16_t>(*ball.owner);
        o.why = Why::Press;
        const bool goal_side = (me.pos.x - cr.pos.x) * v.sg < Fixed64::zero();
        if (goal_side && distSq(me.pos, ball.pos) < core::kTackleReach * core::kTackleReach) {
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

const HoldBlockSpot kHold;
const PressBall kPress;
const ChaseBall kChase;

}  // namespace

const ActingState* DefendingBlock::holdBlockSpot() { return &kHold; }
const ActingState* DefendingBlock::pressBall() { return &kPress; }
const ActingState* DefendingBlock::chaseBall() { return &kChase; }

void BlockParams::configure(const core::ModelParams& p) {
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kBandCount; ++b) {
            const std::string key = std::string("physics.block.") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5);
            spot[r][b] = p.fixed(key, std::int64_t{kRealSpotDm[r][b]} * 100);
        }
    // Real (DFL, the nearest defender to the man on the ball): p25 / median / p75 m.
    static const int kOff[5][3] = {{1200, 2100, 3600}, {1700, 3000, 4800}, {2000, 3900, 6600},
                                   {2800, 5500, 9200}, {3700, 8000, 13300}};
    static const char* kQ[3] = {"p25", "p50", "p75"};
    for (int b = 0; b < 5; ++b)
        for (int k = 0; k < 3; ++k)
            stand_off[b][k] = p.fixed((std::string("physics.press.stand_off_") + std::to_string(b) + "_" + kQ[k]).c_str(), kOff[b][k]);
    switch_m = p.fixed("physics.press.switch_m", 2000);
    tackle_per_s = p.fixed("physics.press.tackle_per_s", 500);
}

void DefendingBlock::assign(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                            const Reads::FlightRead& fr, int restart_taker) {
    const auto& ball = world.ball();
    const bool live = inPlay(world);
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
    if (live && !ball.owner && fr.live) {
        // Our pass (G4.81): the man it's for meets it; the rest let it run —
        // unless they get there first, when our first man goes too.
        const int to = ball.pass_to < world.playerCount() && team_of_slot[ball.pass_to] == team &&
                               world.lastTouchTeam() == team ? static_cast<int>(ball.pass_to) : -1;
        const int theirs = fr.first[team ^ 1];
        if (to >= 0 && fr.tick[to] >= 0 && (theirs < 0 || fr.tick[to] <= fr.tick[theirs])) ch = to;
        else if (fr.first[team] >= 0) ch = fr.first[team];
        // Nobody of ours can get there inside the race read's horizon (a ball come
        // to rest far from everyone): our nearest goes — else it sat there for good.
        else ch = nearest(ch);
    } else if (live && !ball.owner) {
        ch = nearest(ch);
    } else if (world.restartTeam() == team && world.outStage() == 0 && !ball.owner) {
        // Our dead ball: a held one (throw, goal kick, corner) is its taker's
        // (restartTaker, at its spot); a kick-off or free kick, the nearest man.
        ch = world.heldRestart() ? restart_taker : nearest(ch);
    } else ch = -1;
    int& pr = presser_[team & 1];
    if (!live || !ball.owner || team_of_slot[*ball.owner] == team) { pr = -1; return; }
    pr = nearest(pr);
}

Vec2 DefendingBlock::spot(const PlayerView& v, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_line = hx + v.ball_to.x * v.sg;   // the ball's metres off our own line, where it's going
    const Fixed64 x = bandLookup(params_.spot[static_cast<int>(v.role)], off_line);
    return Vec2{(x - hx) * v.sg, v.across_def};
}

}  // namespace fh::game::ai
