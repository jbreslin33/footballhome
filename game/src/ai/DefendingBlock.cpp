// game/src/ai/DefendingBlock.cpp — out of possession, rebuilt (G5.21, DESIGN §8.119).
#include "ai/DefendingBlock.hpp"

#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "core/Levels.hpp"
#include "math/FixedMath.hpp"

#include <string>

namespace fh::game::ai {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

Role roleOfNumber(int n) {
    if (n == 4 || n == 5) return Role::CB;
    if (n == 2 || n == 3) return Role::FB;
    if (n == 10) return Role::AM;
    if (n == 7 || n == 11) return Role::Wide;
    if (n == 9) return Role::ST;
    return Role::DM;
}

namespace {

// Real (DFL, 7 matches, the side without the ball, in play, 5 Hz): mean metres
// off its own line by role, ball in bands 0-10 … 90-100 m off that line —
// benchmarks_tracking_possession.py DEFENDING SHAPE (§8.111/§8.118).
constexpr int kRealSpotDm[kRoleCount][kBandCount] = {   // decimetres
    { 93, 137, 196, 254, 309, 363, 410, 455, 498, 552},   // CB
    {120, 171, 229, 290, 341, 403, 450, 501, 544, 613},   // FB
    {154, 206, 274, 344, 402, 465, 518, 574, 624, 679},   // DM/CM
    {259, 311, 366, 428, 491, 554, 606, 666, 733, 810},   // AM
    {208, 263, 327, 397, 456, 520, 575, 636, 691, 770},   // WIDE
    {329, 381, 448, 504, 558, 616, 666, 724, 787, 865},   // ST
};
const char* const kRoleKey[kRoleCount] = {"cb", "fb", "dm", "am", "wide", "st"};

Fixed64 sqDist(const Vec3& a, const Vec3& b) {
    const Vec2 d{a.x - b.x, a.y - b.y};
    return math::lengthSquared(d);
}

bool inPlay(const core::World& w) { return w.restartTeam() == 0xFF && w.outStage() == 0; }

bool defendingPhase(Phase p) {
    return p == Phase::DefendingBlock || p == Phase::DefensiveTransition || p == Phase::TheirSetPiece;
}

// ── the states ─────────────────────────────────────────────────────────

class Attacking final : public PlayerState {
public:
    std::uint8_t id() const override { return 0; }
    const char* name() const override { return "attacking"; }
    void execute(PlayerAgent&, const PlayerCtx&) const override {}
};

// Where a pro defender of his role stands for this ball (the block spot).
class HoldBlockSpot final : public ActingState {
public:
    std::uint8_t id() const override { return 1; }
    const char* name() const override { return "hold the block spot"; }
    void execute(PlayerAgent&, const PlayerCtx&) const override {}
    bool act(const PlayerView& v, const PlayerCtx& c, core::MoveIntent& move, core::Action&, Vec2& target,
             std::int16_t&) const override {
        target = c.block.spot(v, c.world);
        move.move = seek(c.world.player(v.slot).pos, target, Fixed64::fromFraction(1, 2));
        return true;
    }
};

// The one man who steps to their carrier: stand_off metres goal-side of him,
// on his line to our goal; in reach and goal-side he may dive in.
class PressBall final : public ActingState {
public:
    std::uint8_t id() const override { return 2; }
    const char* name() const override { return "press the ball"; }
    void execute(PlayerAgent&, const PlayerCtx&) const override {}
    bool act(const PlayerView& v, const PlayerCtx& c, core::MoveIntent& move, core::Action& action, Vec2& target,
             std::int16_t& other) const override {
        const auto& ball = c.world.ball();
        if (!ball.owner) return false;
        const auto& me = c.world.player(v.slot);
        const auto& cr = c.world.player(*ball.owner);
        const Vec2 own_goal{-v.sg * c.world.pitchHalfX(), Fixed64::zero()};
        const Vec2 to_goal{own_goal.x - cr.pos.x, own_goal.y - cr.pos.y};
        const Fixed64 len = math::length(to_goal);
        const Fixed64 off = c.block.params().stand_off;
        target = len.raw > 0 ? Vec2{cr.pos.x + to_goal.x * off / len, cr.pos.y + to_goal.y * off / len}
                             : Vec2{cr.pos.x, cr.pos.y};
        move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
        move.face = Vec2{cr.pos.x - me.pos.x, cr.pos.y - me.pos.y};
        other = static_cast<std::int16_t>(*ball.owner);
        const bool goal_side = (me.pos.x - cr.pos.x) * v.sg < Fixed64::zero();
        if (goal_side && sqDist(me.pos, ball.pos) < core::kTackleReach * core::kTackleReach) {
            const Fixed64 per_tick = c.block.params().tackle_per_s * core::kTickDt;
            const Fixed64 n = core::detNoise(v.match_seed, c.tick, v.slot, 29);   // [-1, 1)
            if ((n + Fixed64::one()) * Fixed64::fromFraction(1, 2) < per_tick) action = core::Action::Tackle;
        }
        return true;
    }
};

// His team's first man to a loose ball goes to where he can take it.
class ChaseBall final : public ActingState {
public:
    std::uint8_t id() const override { return 3; }
    const char* name() const override { return "chase the ball"; }
    void execute(PlayerAgent&, const PlayerCtx&) const override {}
    bool act(const PlayerView& v, const PlayerCtx& c, core::MoveIntent& move, core::Action&, Vec2& target,
             std::int16_t&) const override {
        target = v.chase_to;
        move.move = seek(c.world.player(v.slot).pos, target, Fixed64::fromFraction(1, 10));
        return true;
    }
};

const Attacking kAttacking;
const HoldBlockSpot kHold;
const PressBall kPress;
const ChaseBall kChase;

// Each tick: his team's assignment and phase pick the state.
class Pick final : public PlayerState {
public:
    std::uint8_t id() const override { return 0xFE; }
    const char* name() const override { return "pick"; }
    void execute(PlayerAgent& a, const PlayerCtx& c) const override {
        const std::uint8_t team = c.team.team;
        const PlayerState* next = &kAttacking;
        if (c.world.isKeeper(a.slot)) next = &kAttacking;   // the keeper keeps his own craft
        else if (c.block.chaser(team) == a.slot) next = &kChase;
        else if (defendingPhase(c.team.phase())) next = c.block.presser(team) == a.slot ? static_cast<const PlayerState*>(&kPress) : &kHold;
        a.machine.change(a, c, next, c.tick);
    }
};
const Pick kPick;

}  // namespace

const PlayerState* DefendingBlock::attacking() { return &kAttacking; }
const PlayerState* DefendingBlock::holdBlockSpot() { return &kHold; }
const PlayerState* DefendingBlock::pressBall() { return &kPress; }
const PlayerState* DefendingBlock::chaseBall() { return &kChase; }
const PlayerState* DefendingBlock::global() { return &kPick; }

void BlockParams::configure(const core::ModelParams& p) {
    for (int r = 0; r < kRoleCount; ++r)
        for (int b = 0; b < kBandCount; ++b) {
            const std::string key = std::string("physics.block.") + kRoleKey[r] + "_" + std::to_string(b * 10 + 5);
            spot[r][b] = p.fixed(key, std::int64_t{kRealSpotDm[r][b]} * 100);
        }
    stand_off = p.fixed("physics.press.stand_off_m", 3000);
    switch_m = p.fixed("physics.press.switch_m", 2000);
    tackle_per_s = p.fixed("physics.press.tackle_per_s", 500);
}

void DefendingBlock::assign(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                            int first_to_ball, int restart_taker) {
    const auto& ball = world.ball();
    const bool live = inPlay(world);
    // The nearest outfielder to the ball, held until another is switch_m nearer.
    auto nearest = [&](int held) {
        int best = -1; Fixed64 bd{};
        for (std::uint8_t j = 0; j < world.playerCount(); ++j) {
            if (team_of_slot[j] != team || world.isKeeper(j)) continue;
            const Fixed64 d = sqDist(world.player(j).pos, ball.pos);
            if (best < 0 || d < bd) { best = j; bd = d; }
        }
        if (held >= 0 && held != best && team_of_slot[held] == team && !world.isKeeper(static_cast<std::uint8_t>(held))) {
            const Fixed64 dk = math::fx_sqrt(sqDist(world.player(static_cast<std::uint8_t>(held)).pos, ball.pos));
            if (dk < math::fx_sqrt(bd) + params_.switch_m) return held;
        }
        return best;
    };
    int& ch = chaser_[team & 1];
    if (live && !ball.owner) ch = first_to_ball;
    else if (world.restartTeam() == team && world.outStage() == 0 && !ball.owner)
        // Our dead ball: a held one (throw, goal kick, corner) is its taker's
        // (restartTaker, at its spot); a kick-off or free kick, the nearest man.
        ch = world.heldRestart() ? restart_taker : nearest(ch);
    else ch = -1;
    int& pr = presser_[team & 1];
    if (!live || !ball.owner || team_of_slot[*ball.owner] == team) { pr = -1; return; }
    pr = nearest(pr);
}

Vec2 DefendingBlock::spot(const PlayerView& v, const core::World& world) const {
    const Fixed64 hx = world.pitchHalfX();
    const Fixed64 off_line = hx + world.ball().pos.x * v.sg;   // ball metres off our own line
    const int r = static_cast<int>(v.role);
    // Band centres 5, 15, … 95: interpolate, flat beyond the ends.
    Fixed64 x;
    const Fixed64 u = (off_line - Fixed64::fromInt(5)) / Fixed64::fromInt(10);
    if (u <= Fixed64::zero()) x = params_.spot[r][0];
    else if (u >= Fixed64::fromInt(kBandCount - 1)) x = params_.spot[r][kBandCount - 1];
    else {
        const int i = static_cast<int>(u.raw >> Fixed64::FRAC_BITS);
        const Fixed64 f = u - Fixed64::fromInt(i);
        x = params_.spot[r][i] + (params_.spot[r][i + 1] - params_.spot[r][i]) * f;
    }
    return Vec2{(x - hx) * v.sg, v.across};
}

}  // namespace fh::game::ai
