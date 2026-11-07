// game/src/ai/Brain.cpp — the brain's façade (G5.22, DESIGN §8.120): the state
// machines' step, and orders = his state's, then the laws and the body.
#include "ai/Brain.hpp"

#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "core/PlayerSkill.hpp"
#include "math/FixedMath.hpp"

#include <algorithm>

namespace fh::game::ai {

using core::Action;
using core::SlotIndex;
using core::World;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {
const Fixed64 kPressureRadius = Fixed64::fromFraction(5, 2);  // 2.5 m: a man on him
}  // namespace

TeamSetup TeamSetup::splitHalves(std::uint8_t slot_count) {
    TeamSetup s;
    s.team_of_slot.resize(slot_count);
    const std::uint8_t half = slot_count / 2;
    for (std::uint8_t i = 0; i < slot_count; ++i)
        s.team_of_slot[i] = i < half ? 0 : 1;
    return s;
}

Brain::Brain(TeamSetup setup, Fixed64 pitch_half_x, Fixed64 pitch_half_y, FormationSpec home, FormationSpec away)
    : setup_{std::move(setup)}, half_x_{pitch_half_x}, half_y_{pitch_half_y},
      reads_{nullptr, pitch_half_x, pitch_half_y} {
    reads_.bind(&setup_.team_of_slot);
    const auto n = setup_.team_of_slot.size();
    index_in_team_.resize(n);
    std::uint8_t count[2] = {0, 0};
    for (std::size_t i = 0; i < n; ++i) index_in_team_[i] = count[setup_.team_of_slot[i]]++;
    spec_[0] = home.valid(count[0]) ? std::move(home) : builtinFormation(count[0]);
    spec_[1] = away.valid(count[1]) ? std::move(away) : builtinFormation(count[1]);
    role_of_slot_.resize(n);
    for (std::size_t i = 0; i < n; ++i) {
        const auto& pos = spec_[setup_.team_of_slot[i]].positions[index_in_team_[i]];
        role_of_slot_[i] = roleOfSlot(pos.role, pos.number);
    }
}

Brain::Brain(const Brain& o)
    : setup_(o.setup_), half_x_(o.half_x_), half_y_(o.half_y_), index_in_team_(o.index_in_team_),
      match_seed_(o.match_seed_), reads_(o.reads_), block_(o.block_), poss_(o.poss_), role_of_slot_(o.role_of_slot_), phase_params_(o.phase_params_),
      think_tick_(o.think_tick_), restart_play_(o.restart_play_), hold_team_(o.hold_team_), hold_(o.hold_),
      arrive_decel_(o.arrive_decel_), arrive_through_(o.arrive_through_), shape_tau_(o.shape_tau_),
      shape_tau_ours_(o.shape_tau_ours_), shape_max_(o.shape_max_), defend_max_(o.defend_max_),
      shape_danger_(o.shape_danger_), wb_tuck_y_(o.wb_tuck_y_), tau_back_(o.tau_back_), shape_danger_sprint_(o.shape_danger_sprint_), theirs_shift_y_(o.theirs_shift_y_),
      theirs_cap_y_(o.theirs_cap_y_), ours_shift_y_(o.ours_shift_y_), ours_cap_y_(o.ours_cap_y_) {
    spec_[0] = o.spec_[0]; spec_[1] = o.spec_[1];
    for (int i = 0; i < 2; ++i) teams_[i] = o.teams_[i];
    for (int i = 0; i < 32; ++i) { players_[i] = o.players_[i]; dbg_anchor_[i] = o.dbg_anchor_[i]; }
    reads_.bind(&setup_.team_of_slot);
}

Brain& Brain::operator=(const Brain& o) {
    if (this != &o) { this->~Brain(); new (this) Brain(o); }
    return *this;
}

void Brain::setModelParams(const core::ModelParams& p) {
    reads_.configure(p);
    block_.configure(p);
    poss_.configure(p);
    auto ticks = [&](const char* key, std::int64_t milli) {
        return static_cast<std::int32_t>((p.fixed(key, milli) * Fixed64::fromInt(core::kTickRate)).raw >> Fixed64::FRAC_BITS);
    };
    phase_params_.transition_ticks = static_cast<std::uint32_t>(ticks("physics.phase.transition_s", 6000));
    phase_params_.min_dwell_ticks = static_cast<std::uint32_t>(ticks("physics.phase.min_dwell_s", 300));
    restart_play_.throw_look_ticks = ticks("physics.restart.throw_look_s", 1000);
    restart_play_.throw_wait_ticks = ticks("physics.restart.throw_wait_s", 4000);
    restart_play_.corner_look_ticks = ticks("physics.restart.corner_look_s", 1500);
    restart_play_.keeper_wait_ticks = ticks("physics.restart.keeper_wait_s", 3000);
    restart_play_.throw_min_m = p.fixed("physics.restart.throw_min_m", 4000);
    restart_play_.throw_room_m = p.fixed("physics.restart.throw_room_m", 10000);
    restart_play_.throw_free_m = p.fixed("physics.restart.throw_free_m", 3000);
    restart_play_.throw_gain = p.fixed("physics.restart.throw_gain", 300);
    restart_play_.keeper_long_m = p.fixed("physics.restart.keeper_long_m", 55000);
    restart_play_.throw_law_m = p.fixed("physics.restart.throw_law_m", 2000);
    restart_play_.kick_law_m = p.fixed("physics.restart.kick_law_m", 9150);
    restart_play_.penalty_arc_m = p.fixed("physics.restart.penalty_arc_m", 9150);
    arrive_decel_ = p.fixed("physics.body.arrive_decel_mps2", 4500);
    arrive_through_ = p.fixed("physics.body.arrive_through_mps", 3000);
    shape_tau_ = p.fixed("physics.body.shape_tau_s", 0);
    shape_tau_ours_ = p.fixed("physics.body.shape_tau_ours_s", 0);
    shape_max_ = p.fixed("physics.body.shape_max_mps", 0);
    defend_max_ = p.fixed("physics.body.defend_max_mps", 0);
    shape_danger_ = p.fixed("physics.body.shape_danger_m", 0);
    wb_tuck_y_ = p.fixed("physics.shape.wb_tuck_y", 700);
    tau_back_ = p.fixed("physics.body.shape_tau_back_s", 0);
    shape_danger_sprint_ = p.integer("physics.body.shape_danger_sprint", 0);
    theirs_shift_y_ = p.fixed("physics.shape.theirs_shift_y", 0);
    theirs_cap_y_ = p.fixed("physics.shape.theirs_cap_y_m", 0);
    ours_shift_y_ = p.fixed("physics.shape.ours_shift_y", 0);
    ours_cap_y_ = p.fixed("physics.shape.ours_cap_y_m", 0);
}

void Brain::think(const World& world) const {
    const std::uint64_t now = world.tickCount();
    if (think_tick_ != ~0ull && now == think_tick_) return;
    if (think_tick_ == ~0ull || now < think_tick_) {
        for (std::uint8_t t = 0; t < 2; ++t) {
            teams_[t] = TeamAgent{};
            teams_[t].team = t;
            teams_[t].machine.init(teamStartState(), teamGlobalState(), now);
        }
        block_.reset();
        poss_.reset();
        for (std::uint8_t s = 0; s < 32; ++s) {
            players_[s] = PlayerAgent{};
            players_[s].slot = s;
            players_[s].machine.init(playerStartState(), playerGlobalState(), now);
        }
    }
    think_tick_ = now;
    for (auto& a : teams_) {
        const TeamCtx c{world, setup_.team_of_slot, phase_params_, now};
        a.machine.update(a, c);
    }
    const FlightRead& fr = reads_.flightRead(world);
    for (std::uint8_t t = 0; t < 2; ++t)
    {
        block_.assign(t, world, setup_.team_of_slot, role_of_slot_, fr, restartTaker(world, t));
        poss_.assignRunners(t, world, setup_.team_of_slot, role_of_slot_, match_seed_);
        poss_.assignRuns(t, world, setup_.team_of_slot, role_of_slot_, match_seed_);
        poss_.assignFront(t, world, setup_.team_of_slot);
    }
    for (std::uint8_t s = 0; s < world.playerCount() && s < 32; ++s) {
        const PlayerCtx c{world, setup_.team_of_slot, block_, poss_, reads_, teams_[setup_.team_of_slot[s] & 1], now};
        players_[s].machine.update(players_[s], c);
    }
}

Fixed64 Brain::slideY(const Vec2& base, Fixed64 ball_y, Fixed64 shift, Fixed64 cap) const {
    Fixed64 s = ball_y * shift;
    if (cap.raw > 0) {
        if (s > cap) s = cap;
        if (s < -cap) s = -cap;
    }
    Fixed64 v = base.y * half_y_ + s;
    const Fixed64 lim = half_y_ - Fixed64::fromInt(2);
    if (v > lim) v = lim;
    if (v < -lim) v = -lim;
    return v;
}

// G5.36 (§8.134): a wing-back — James: "the ball-side wing-back goes, the
// far-side one tucks in to make a back four". Without the ball the one on the
// ball's side (where it is going) stands at a wide man's depth; the other at a
// full-back's, tucked to a back four's full-back width (physics.shape.wb_tuck_y,
// the club 4-4-2's 15/85 = 0.7 of the half-width), sliding as the block does.
// With the ball both are the wide men.
// G5.38 (§8.138): his lateral spot without the ball — his formation width scaled
// to the real settled block's for his role and the ball's band (the block narrows
// toward its goal), then the slide toward the ball.
Fixed64 Brain::acrossDef(const Vec2& base, const PlayerView& v) const {
    const Fixed64 off_line = half_x_ + v.ball_to.x * v.sg;
    const Fixed64 f = block_.widthFactor(v.role, off_line);
    return slideY(Vec2{base.x, base.y * f}, v.ball_to.y, theirs_shift_y_, theirs_cap_y_);
}

void Brain::wingBack(const FormationSpec::Pos& mine, PlayerView& v) const {
    if (mine.role != "wing-back") return;
    v.role_ours = Role::Wide;
    if (v.ball_to.y * mine.base.y > Fixed64::zero()) { v.role = Role::Wide; return; }
    v.role = Role::FB;
    const Fixed64 side = mine.base.y.raw < 0 ? -Fixed64::one() : Fixed64::one();
    v.across_def = acrossDef(Vec2{mine.base.x, side * wb_tuck_y_}, v);
}

PlayerView Brain::viewOf(SlotIndex slot, const World& world) const {
    const std::uint8_t team = setup_.team_of_slot[slot];
    const FormationSpec::Pos& mine = spec_[team].positions[index_in_team_[slot]];
    PlayerView v;
    v.slot = slot;
    v.team = team;
    v.sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    v.role = roleOfSlot(mine.role, mine.number);
    v.role_ours = v.role;
    v.keeper = world.isKeeper(slot);
    const FlightRead& fr = reads_.flightRead(world);
    // G5.30 (§8.128): where the ball is going — a free ball in play, the point
    // the race read's first man (either side) takes it; else where it is. The
    // block shifts while the ball travels, not after it lands.
    v.ball_to = Vec2{world.ball().pos.x, world.ball().pos.y};
    if (fr.live) {
        int f = -1;
        for (int t = 0; t < 2; ++t) {
            const int j = fr.first[t];
            if (j >= 0 && j < static_cast<int>(fr.tick.size()) && fr.tick[j] >= 0 && (f < 0 || fr.tick[j] < fr.tick[f])) f = j;
        }
        if (f >= 0) v.ball_to = fr.at[f];
    }
    v.across_def = acrossDef(mine.base, v);
    wingBack(mine, v);
    v.across_ours = slideY(mine.base, world.ball().pos.y, ours_shift_y_, ours_cap_y_);
    v.chase_to = (fr.live && slot < fr.at.size() && fr.tick[slot] >= 0) ? fr.at[slot]
                                                                         : Vec2{world.ball().pos.x, world.ball().pos.y};
    v.match_seed = match_seed_;
    return v;
}

bool Brain::actAs(const ActingState* st, SlotIndex slot, const World& world, Orders& o) const {
    const PlayerCtx c{world, setup_.team_of_slot, block_, poss_, reads_, teams_[setup_.team_of_slot[slot] & 1], world.tickCount()};
    return st->act(viewOf(slot, world), c, o);
}

Orders Brain::ordersFor(SlotIndex slot, const World& world) const {
    think(world);
    Orders o;
    if (!takeRestart(slot, world, o)) {
        bool held = false;
        // A restart shape is held until the dead ball is played (G4.58 / G5.2).
        if (hold_team_ != 0xFF && world.restartTeam() == hold_team_)
            for (const auto& [s, mark] : hold_) {
                if (s != slot) continue;
                const auto& b = world.ball().pos;
                if (distSq(Vec3{mark.x, mark.y, Fixed64::zero()}, b) < Fixed64::fromInt(4)) break;   // the taker
                o.move.move = seek(world.player(slot).pos, mark, Fixed64::fromFraction(1, 2));
                o.move.face = Vec2{b.x - world.player(slot).pos.x, b.y - world.player(slot).pos.y};
                o.why = Why::Hold;
                o.target = mark;
                held = true;
                break;
            }
        if (!held) {
            const PlayerState* st = players_[slot & 31].machine.current();
            const auto* acting = dynamic_cast<const ActingState*>(st);
            if (!acting || !actAs(acting, slot, world, o)) actAs(DefendingBlock::holdBlockSpot(), slot, world, o);
        }
    }
    keepLawDistance(slot, world, o);
    outOfTheirBox(slot, world, o);
    penaltyPlaces(slot, world, o);
    if (o.why == Why::InBehind && o.other >= 0) poss_.noteLed(slot, static_cast<std::uint8_t>(o.other), o.target, world.tickCount());
    namePass(slot, world, o);
    brakeToArrive(slot, world, o, blockLead(slot, world, o));
    capAcross(slot, world, o);
    // Settled at his spot he faces the ball.
    if (o.move.face.x.raw == 0 && o.move.face.y.raw == 0 && (o.why == Why::Hold || o.why == Why::KeeperPosition)) {
        const auto& me = world.player(slot);
        const auto& b = world.ball().pos;
        if (distSq(me.pos, Vec3{o.target.x, o.target.y, Fixed64::zero()}) <= Fixed64::fromInt(4))
            o.move.face = Vec2{b.x - me.pos.x, b.y - me.pos.y};
    }
    dbg_anchor_[slot & 31] = o.target;
    return o;
}

// The taker of a held restart (G5.2): the keeper for his goal kick, the man a
// restart shape puts on the spot, else the nearest outfielder to the spot.
int Brain::restartTaker(const World& world, std::uint8_t team) const {
    const Vec3& sp = world.restartSpot();
    if (world.restartKind() == core::MatchEventType::GoalKick) {
        for (SlotIndex i = 0; i < world.playerCount(); ++i)
            if (setup_.team_of_slot[i] == team && world.isKeeper(i)) return i;
    }
    if (hold_team_ == team)
        for (const auto& [s, mark] : hold_)
            if (setup_.team_of_slot[s] == team && distSq(Vec3{mark.x, mark.y, Fixed64::zero()}, sp) < Fixed64::fromInt(9))
                return s;
    int best = -1;
    Fixed64 bd{};
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (setup_.team_of_slot[i] != team || world.isKeeper(i)) continue;
        const Fixed64 d = distSq(world.player(i).pos, sp);
        if (best < 0 || d < bd) { best = i; bd = d; }
    }
    return best;
}

bool Brain::takeRestart(SlotIndex slot, const World& world, Orders& out) const {
    if (!world.heldRestart() || world.restartTeam() != setup_.team_of_slot[slot]) return false;
    if (restartTaker(world, world.restartTeam()) != slot) return false;
    const auto& me = world.player(slot);
    const auto& ball = world.ball();
    if (ball.owner && *ball.owner == slot) {
        switch (world.restartKind()) {
            case core::MatchEventType::ThrowIn: return playThrow(slot, world, out);
            case core::MatchEventType::Corner:  return playCorner(slot, world, out);
            case core::MatchEventType::Penalty: return playPenalty(slot, world, out);
            default: break;
        }
        // Goal kick: the keeper's own ball — his on-ball state chooses it;
        // he doesn't stand on it for ever if it finds nothing.
        actAs(Possession::onBall(), slot, world, out);
        const std::uint64_t waited = world.tickCount() - world.ownedAtTick();
        if (out.action == Action::None && waited >= static_cast<std::uint64_t>(restart_play_.keeper_wait_ticks)) {
            const Fixed64 sg = setup_.team_of_slot[slot] == 0 ? Fixed64::one() : -Fixed64::one();
            const Vec2 target{me.pos.x + sg * restart_play_.keeper_long_m, me.pos.y};
            out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            out.action = Action::LoftedKick;
            out.carry_m = aimedCarry(me.pos, target, rangeFor(world.skillOf(slot), restart_play_.keeper_long_m));
            out.why = Why::KeeperPunt;
            out.target = target;
        }
        return true;
    }
    // Walk to it: behind the line for a throw, behind the ball for a kick,
    // onto it once the referee has it ready.
    const Vec3& sp = world.restartSpot();
    Vec2 aim{Fixed64::zero(), Fixed64::zero()};
    if (world.restartKind() == core::MatchEventType::ThrowIn) aim = Vec2{sp.x, Fixed64::zero()};
    if (world.restartKind() == core::MatchEventType::Corner)
        aim = Vec2{sp.x, Fixed64::zero()};
    const Vec2 back = math::normalized(Vec2{sp.x - aim.x, sp.y - aim.y});
    const bool ready = world.outStage() == 0 && world.tickCount() >= world.restartReadyTick();
    const Fixed64 off = ready ? Fixed64::fromFraction(1, 4) : Fixed64::fromFraction(3, 4);
    const Vec2 stand{sp.x + back.x * off, sp.y + back.y * off};
    out.move.move = seek(me.pos, stand, Fixed64::fromInt(1), Fixed64::fromFraction(1, 20));
    out.move.face = Vec2{-back.x, -back.y};
    out.why = Why::TakeRestart;
    out.target = stand;
    return true;
}

bool Brain::playThrow(SlotIndex slot, const World& world, Orders& out) const {
    const std::uint8_t team = setup_.team_of_slot[slot];
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const Vec2 from{world.restartSpot().x, world.restartSpot().y};
    const Vec2 infield{Fixed64::zero(), world.restartSpot().y.raw > 0 ? -Fixed64::one() : Fixed64::one()};
    out.move.face = infield;
    out.why = Why::ThrowIn;
    const std::uint64_t waited = world.tickCount() - world.ownedAtTick();
    if (waited < static_cast<std::uint64_t>(restart_play_.throw_look_ticks)) return true;
    const Fixed64 reach = world.officials().throwMaxM();
    int best = -1;
    Fixed64 bs{}, bfree{};
    Vec2 bat{};
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot || setup_.team_of_slot[i] != team || world.isKeeper(i)) continue;
        const auto& m = world.player(i);
        const Vec2 at{m.pos.x, m.pos.y};
        const Fixed64 d = math::length(Vec2{at.x - from.x, at.y - from.y});
        if (d < restart_play_.throw_min_m || d > reach) continue;
        Fixed64 free = restart_play_.throw_room_m;
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] == team) continue;
            const Fixed64 q = math::length(Vec2{world.player(j).pos.x - at.x, world.player(j).pos.y - at.y});
            if (q < free) free = q;
        }
        Fixed64 gained = (at.x - from.x) * sg;
        if (gained > restart_play_.throw_room_m) gained = restart_play_.throw_room_m;
        if (gained < -restart_play_.throw_room_m) gained = -restart_play_.throw_room_m;
        Fixed64 score = free + gained * restart_play_.throw_gain;
        const std::uint8_t carry = aimedCarry(Vec3{from.x, from.y, Fixed64::zero()}, at, reach);
        if (!reads_.loftSafe(world, slot, from, at, carry, Fixed64::fromFraction(1, 2))) score -= restart_play_.throw_room_m;
        if (best < 0 || score > bs) { best = i; bs = score; bfree = free; bat = at; }
    }
    const bool late = waited >= static_cast<std::uint64_t>(restart_play_.throw_wait_ticks);
    if (best < 0 || (bfree < restart_play_.throw_free_m && !late)) {
        if (!late) return true;
        // Nobody in range: down the line.
        bat = Vec2{from.x + sg * restart_play_.throw_room_m, from.y + infield.y * Fixed64::fromInt(3)};
    }
    out.move.move = math::normalized(Vec2{bat.x - from.x, bat.y - from.y});
    out.action = Action::LoftedKick;
    out.carry_m = aimedCarry(Vec3{from.x, from.y, Fixed64::zero()}, bat, reach);
    if (best >= 0) out.pass_to = static_cast<std::uint8_t>(best);
    out.other = static_cast<std::int16_t>(best);
    out.target = bat;
    return true;
}

// G5.40 (Law 14): the penalty. Where it goes is drawn from where real ones went
// (StatsBomb PL 2015/16, benchmarks_statsbomb_penalties.py): on target 93.4% (81.3%
// scored, 12.1% saved), off 6.6%; on target a median 2.38 m from the goal's centre
// (p25 1.83, p75 2.93), 0.64 m up (p25 0.18, p75 1.28) — the quartiles joined by
// straight lines, the ends to the post / the bar. The keeper still has to save it.
bool Brain::playPenalty(SlotIndex slot, const World& world, Orders& out) const {
    const auto& me = world.player(slot);
    const std::uint8_t team = setup_.team_of_slot[slot];
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    out.move.face = Vec2{sg, Fixed64::zero()};
    out.why = Why::Shoot;
    if (world.tickCount() - world.ownedAtTick() < static_cast<std::uint64_t>(restart_play_.corner_look_ticks))
        return true;
    auto roll = [&](int ch) {
        return (core::detNoise(match_seed_, world.ownedAtTick(), slot, ch) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    };
    // A piecewise-linear draw through 0 / p25 / median / p75 / top (cm).
    auto quart = [](Fixed64 u, const int (&q)[5]) {
        const Fixed64 k = u * Fixed64::fromInt(4);
        const int i = static_cast<int>(k.raw >> Fixed64::FRAC_BITS) > 3 ? 3 : static_cast<int>(k.raw >> Fixed64::FRAC_BITS);
        const Fixed64 f = k - Fixed64::fromInt(i);
        return Fixed64::fromFraction(q[i], 100) + Fixed64::fromFraction(q[i + 1] - q[i], 100) * f;
    };
    static const int kLat[5] = {0, 183, 238, 293, 350}, kHt[5] = {0, 18, 64, 128, 230};
    Fixed64 lat = quart(roll(51), kLat), ht = quart(roll(52), kHt);
    if (roll(53) < Fixed64::fromFraction(66, 1000)) {   // the miss: wide of the post or over
        if (roll(54) < Fixed64::fromFraction(1, 2)) lat = Fixed64::fromFraction(390, 100) + roll(55) * Fixed64::fromInt(2);
        else ht = Fixed64::fromFraction(260, 100) + roll(55);
    }
    const Fixed64 side = roll(56) < Fixed64::fromFraction(1, 2) ? -Fixed64::one() : Fixed64::one();
    out.target = Vec2{sg * half_x_, side * lat};
    out.aim_z = ht < Fixed64::fromFraction(15, 100) ? Fixed64::zero() : ht;
    out.move.move = math::normalized(Vec2{out.target.x - me.pos.x, out.target.y - me.pos.y});
    out.action = Action::Shot;
    return true;
}

// Law 14 (G5.40): until the penalty is kicked everyone but the taker and the
// defending keeper stands outside the penalty area and the arc (9.15 m from the
// mark), behind the ball — on a line 21 m out, across the area's width. The
// defending keeper stands on his line between the posts.
void Brain::penaltyPlaces(SlotIndex slot, const World& world, Orders& o) const {
    if (!world.penaltySetup()) return;
    const Vec3& sp = world.restartSpot();
    const Fixed64 end = sp.x.raw > 0 ? Fixed64::one() : -Fixed64::one();   // the goal it is taken at
    const std::uint8_t team = setup_.team_of_slot[slot];
    if (world.isKeeper(slot)) {
        if (team == world.restartTeam()) return;   // the taker's keeper: his own game
        const Vec2 t{end * half_x_ - end * Fixed64::fromFraction(1, 5), Fixed64::zero()};
        o.target = t;
        o.move.move = seek(world.player(slot).pos, t, Fixed64::fromFraction(1, 2));
        o.move.face = Vec2{-end, Fixed64::zero()};
        o.action = Action::None;
        o.why = Why::KeeperPosition;
        return;
    }
    if (team == world.restartTeam() && restartTaker(world, team) == slot) return;
    const auto& me = world.player(slot);
    // Outside the area and the arc: the mark (11 m) + the arc's radius + a stride.
    const Fixed64 line = half_x_ - (Fixed64::fromInt(11) + restart_play_.penalty_arc_m + Fixed64::fromFraction(17, 20));
    const bool aimed = o.target.x.raw != 0 || o.target.y.raw != 0;
    Vec2 t = aimed ? o.target : Vec2{me.pos.x, me.pos.y};
    if (t.x * end > line) t.x = line * end;
    o.target = t;
    o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
    o.action = Action::None;
    o.why = Why::LawDistance;
}

bool Brain::playCorner(SlotIndex slot, const World& world, Orders& out) const {
    const auto& me = world.player(slot);
    const std::uint8_t team = setup_.team_of_slot[slot];
    const Vec3& sp = world.restartSpot();
    const Fixed64 end = sp.x.raw > 0 ? Fixed64::one() : -Fixed64::one();
    out.move.face = Vec2{-end, sp.y.raw > 0 ? -Fixed64::one() : Fixed64::one()};
    out.why = Why::CornerKick;
    if (world.tickCount() - world.ownedAtTick() < static_cast<std::uint64_t>(restart_play_.corner_look_ticks))
        return true;
    Vec2 at{end * (half_x_ - Fixed64::fromInt(11)), Fixed64::zero()};
    int best = -1;
    Fixed64 bf{};
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot || setup_.team_of_slot[i] != team || world.isKeeper(i)) continue;
        const auto& m = world.player(i);
        const Fixed64 depth = half_x_ - m.pos.x * end;
        if (depth < Fixed64::fromInt(3) || depth > Fixed64::fromInt(14) ||
            math::fx_abs(m.pos.y) > Fixed64::fromInt(12))
            continue;
        Fixed64 free = Fixed64::fromInt(100);
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] == team) continue;
            const Fixed64 q = math::length(Vec2{world.player(j).pos.x - m.pos.x, world.player(j).pos.y - m.pos.y});
            if (q < free) free = q;
        }
        if (best < 0 || free > bf) { best = i; bf = free; at = Vec2{m.pos.x, m.pos.y}; }
    }
    out.move.move = math::normalized(Vec2{at.x - sp.x, at.y - sp.y});
    out.action = Action::LoftedKick;
    out.carry_m = aimedCarry(me.pos, at, rangeFor(world.skillOf(slot), Fixed64::fromInt(60)));
    if (best >= 0) out.pass_to = static_cast<std::uint8_t>(best);
    out.other = static_cast<std::int16_t>(best);
    out.target = at;
    return true;
}

// Their dead ball (G5.2): Law 15 two metres from the throw, Law 17 / Law 13
// the 9.15 m of a corner or free kick. His walk stops at the distance; if
// he's inside it, he backs off.
void Brain::keepLawDistance(SlotIndex slot, const World& world, Orders& o) const {
    const std::uint8_t rt = world.restartTeam();
    if (rt == 0xFF || rt == setup_.team_of_slot[slot]) return;
    Fixed64 r{};
    const core::MatchEventType k = world.restartKind();
    if (k == core::MatchEventType::ThrowIn) r = restart_play_.throw_law_m;
    else if (k == core::MatchEventType::Corner || k == core::MatchEventType::Offside ||
             k == core::MatchEventType::FreeKick) r = restart_play_.kick_law_m;
    else return;
    const auto& me = world.player(slot);
    const Vec3& sp = world.restartSpot();
    const bool aimed = o.target.x.raw != 0 || o.target.y.raw != 0;
    Vec2 t = aimed ? o.target : Vec2{me.pos.x, me.pos.y};
    const Vec2 ds{t.x - sp.x, t.y - sp.y};
    const Vec2 dm{me.pos.x - sp.x, me.pos.y - sp.y};
    const Fixed64 rr = r * r;
    if (math::lengthSquared(ds) >= rr && math::lengthSquared(dm) >= rr) return;
    Vec2 u = math::lengthSquared(ds) >= rr ? ds : dm;
    if (u.x.raw == 0 && u.y.raw == 0) u = Vec2{-sp.x, -sp.y};
    u = math::normalized(u);
    t = Vec2{sp.x + u.x * r, sp.y + u.y * r};
    o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
    o.action = Action::None;
    o.target = t;
    o.why = Why::LawDistance;
}

void Brain::outOfTheirBox(SlotIndex slot, const World& world, Orders& o) const {
    // Their goal kick (Law 16): every one of us stays outside their penalty
    // area until the ball is kicked — the man-marker picks his CB up on the
    // 18, not goal-side of him in the box. Whoever's in it walks out.
    if (world.boxClearTeam() != setup_.team_of_slot[slot] || world.isKeeper(slot)) return;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    const Fixed64 end = ball.pos.x.raw < 0 ? -Fixed64::one() : Fixed64::one();   // the kicker's goal
    const Fixed64 line = half_x_ - Fixed64::fromFraction(35, 2);                 // 16.5 m + a metre
    const Fixed64 box_y = Fixed64::fromFraction(2116, 100);                      // 20.16 m + a metre
    auto inside = [&](const Vec2& p) { return p.x * end > line && math::fx_abs(p.y) < box_y; };
    const bool aimed = o.target.x.raw != 0 || o.target.y.raw != 0;
    Vec2 t = aimed ? o.target : Vec2{me.pos.x, me.pos.y};
    if (!inside(t) && !inside(Vec2{me.pos.x, me.pos.y})) return;
    if (inside(t)) t.x = line * end;
    o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
    o.target = t;
}

// A kick to a mate (G4.81): name him, weight a ground pass to where it's aimed
// and lead it into a moving man's path; pressed in his control touch, a ground
// pass goes first time (G4.95b).
void Brain::namePass(SlotIndex slot, const World& world, Orders& o) const {
    // One touch when pressed (G4.95b; pass-one-touch, recv-first-time):
    // still in his control touch (G4.92) with a man on him, a ground pass
    // to a mate goes first time — the lay-off, the wall pass back.
    // Without it a pressed receiver could only wait out his touch: 75% of
    // own-third dispossessions came inside it.
    if ((o.action == core::Action::ShortPass || o.action == core::Action::GroundKick) &&
        o.other >= 0 && world.ball().owner && *world.ball().owner == slot &&
        world.tickCount() < world.controlUntilTick()) {
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] == setup_.team_of_slot[slot]) continue;
            if (distSq(world.player(j).pos, world.player(slot).pos) < kPressureRadius * kPressureRadius) {
                o.first_time = true;
                break;
            }
        }
    }
    // A kick to a mate (G4.81): name him on the ball, and weight a
    // ground pass to the spot it's aimed at.
    if (o.action == core::Action::ShortPass || o.action == core::Action::GroundKick ||
        o.action == core::Action::LoftedKick) {
        if (o.other >= 0 && o.other < static_cast<int>(world.playerCount()) && o.other != static_cast<int>(slot) &&
            setup_.team_of_slot[o.other] == setup_.team_of_slot[slot])
            o.pass_to = static_cast<std::uint8_t>(o.other);
        if (o.pass_to != 0xFF && o.carry_m == 0 && o.action != core::Action::LoftedKick) {
            const auto& p = world.player(slot).pos;
            // Into his path: a ball at his feet goes to where he'll be
            // when it gets there (flight time of the weighted pass,
            // Simpson on 1/v — speed falls linearly with distance), at
            // most lead_max 10 m on. A moving man was passed where he
            // stood: 4-8 m/s off, 2.5 s later he was 10-15 m away.
            const auto& mate = world.player(o.pass_to);
            if (distSq(mate.pos, Vec3{o.target.x, o.target.y, Fixed64::zero()}) < Fixed64::one()) {
                Vec2 at{mate.pos.x, mate.pos.y};
                for (int k = 0; k < 2; ++k) {
                    const Fixed64 d = math::length(Vec2{at.x - p.x, at.y - p.y});
                    const Fixed64 v0 = core::weightedPassSpeed(d), va = core::kPassArriveSpeed;
                    const Fixed64 vm = (v0 + va) / 2;
                    const Fixed64 t = d / 6 * (Fixed64::one() / v0 + Fixed64::fromInt(4) / vm + Fixed64::one() / va);
                    Vec2 lead{mate.vel.x * t, mate.vel.y * t};
                    const Fixed64 ll = math::length(lead), cap = Fixed64::fromInt(10);
                    if (ll > cap) lead = Vec2{lead.x * cap / ll, lead.y * cap / ll};
                    at = Vec2{mate.pos.x + lead.x, mate.pos.y + lead.y};
                    if (at.x > half_x_) at.x = half_x_;
                    if (at.x < -half_x_) at.x = -half_x_;
                    if (at.y > half_y_) at.y = half_y_;
                    if (at.y < -half_y_) at.y = -half_y_;
                }
                // The led ball is the one he strikes, so it's the one he
                // reads (G4.82): unsafe led, he plays the ball he checked.
                const Vec2 from{p.x, p.y};
                if (reads_.passSafe(world, slot, from, at,
                             core::weightedPassSpeed(math::length(Vec2{at.x - p.x, at.y - p.y})), Fixed64::one())) {
                    o.target = at;
                    o.move.move = seek(p, at, Fixed64::fromFraction(1, 10));
                }
            }
            const Fixed64 d = math::length(Vec2{o.target.x - p.x, o.target.y - p.y});
            const std::int64_t m = (d + Fixed64::fromFraction(1, 2)).raw >> Fixed64::FRAC_BITS;
            o.carry_m = static_cast<std::uint8_t>(m < 1 ? 1 : (m > 255 ? 255 : m));
        }
    }
}

// Brake to arrive (G4.80) [Reynolds 1999 "arrive"; Harper, Carling & Kiely
// 2019 on decelerations]: he runs no faster than he can still stop from,
// v ≤ √(v_end² + 2·b·d); the shape caps (G5.5 / G5.10 / G5.14, DFL-fitted).
// G5.30 (§8.128): how fast his block spot itself moves (m/s) — the spot for the
// ball a fifth of a second on along the carrier's run, less the spot now. Only
// holding the block with their man carrying it in play; a free ball's spot is
// where it will be taken, which stands still while it travels.
Vec2 Brain::blockLead(SlotIndex slot, const World& world, const Orders& o) const {
    // G5.47 (§8.147): the front man's spot is their line less his gap — it moves
    // as the line does, so he runs with the line's own velocity (tracking).
    if (o.why == Why::Hold && poss_.onLine(setup_.team_of_slot[slot], slot) &&
        players_[slot & 31].machine.current() == Possession::support())
        return Vec2{Possession::offsideLineVelX(setup_.team_of_slot[slot], world, setup_.team_of_slot), Fixed64::zero()};
    if (o.why != Why::Hold || players_[slot & 31].machine.current() != DefendingBlock::holdBlockSpot()) return Vec2{};
    const auto& b = world.ball();
    if (!b.owner || world.restartTeam() != 0xFF || world.outStage() != 0) return Vec2{};
    if (setup_.team_of_slot[*b.owner] == setup_.team_of_slot[slot]) return Vec2{};
    const auto& cv = world.player(*b.owner).vel;
    if (cv.x.raw == 0 && cv.y.raw == 0) return Vec2{};
    const Fixed64 h = Fixed64::fromFraction(1, 5);
    PlayerView v = viewOf(slot, world);
    const Vec2 now = block_.spot(v, world);
    v.ball_to = Vec2{v.ball_to.x + cv.x * h, v.ball_to.y + cv.y * h};
    const FormationSpec::Pos& mine = spec_[v.team].positions[index_in_team_[slot]];
    v.across_def = acrossDef(mine.base, v);
    wingBack(mine, v);
    const Vec2 then = block_.spot(v, world);
    return Vec2{(then.x - now.x) / h, (then.y - now.y) / h};
}

// G5.31 (§8.129): holding shape, his pace by direction, not one cap — across
// and up the pitch at the shift's pace (shape_max), back toward our goal at
// the defending pace (defend_max; in danger, as §8.108 has it). The real side
// without the ball runs 5+ m/s across 2.0% of the time with their ball inside
// 40 m of its goal, 2.3% further out; back 9.2 / 2.8% (DFL,
// benchmarks_tracking_recover.py). One cap had ours across 17.1% in danger
// (uncapped) and back 0.6% outside it (the jog).
void Brain::capAcross(SlotIndex slot, const World& world, Orders& o) const {
    if (o.why != Why::Hold || shape_max_.raw <= 0) return;
    const Fixed64 top = world.player(slot).max_speed;
    if (top.raw <= 0) return;
    const Fixed64 lim = shape_max_ / top;
    if (o.move.move.y > lim) o.move.move.y = lim;
    else if (o.move.move.y < -lim) o.move.move.y = -lim;
    const Fixed64 sg = setup_.team_of_slot[slot] == 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 fwd = o.move.move.x * sg;
    if (fwd > lim) o.move.move.x = lim * sg;
    if (defend_max_.raw > 0 && !inDanger(slot, world) && -fwd > defend_max_ / top) o.move.move.x = -(defend_max_ / top) * sg;
}

// Their ball inside shape_danger_m of our goal (G5.10, §8.108).
bool Brain::inDanger(SlotIndex slot, const World& world) const {
    if (shape_danger_.raw <= 0) return false;
    const auto& b = world.ball();
    const std::uint8_t team = setup_.team_of_slot[slot];
    const bool theirs = b.owner ? setup_.team_of_slot[*b.owner] != team : world.lastTouchTeam() != team;
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    return theirs && b.pos.x * sg + half_x_ < shape_danger_;
}

void Brain::brakeToArrive(SlotIndex slot, const World& world, Orders& o, Vec2 lead) const {
    switch (o.why) {
        case Why::Human: case Why::KeeperDive:
            return;
        default: break;
    }
    const auto& me = world.player(slot);
    if (world.ball().owner && *world.ball().owner == slot) return;
    if (o.target.x.raw == 0 && o.target.y.raw == 0) return;
    const bool leading = lead.x.raw != 0 || lead.y.raw != 0;
    // Settled on a moving spot he still moves with it.
    if (leading && math::lengthSquared(o.move.move).raw == 0) o.move.move = math::normalized(lead);
    const Fixed64 m2 = math::lengthSquared(o.move.move);
    if (m2.raw == 0 || me.max_speed.raw <= 0) return;
    const Vec2 d{o.target.x - me.pos.x, o.target.y - me.pos.y};
    const Fixed64 dist = math::length(d);
    if (dist.raw == 0 && !leading) return;
    const Fixed64 mlen = math::fx_sqrt(m2);
    // Only when he's actually running AT the target (a pass's target is the
    // receiver; a jockey's is the man).
    if (!leading && math::dot(o.move.move, d) < mlen * dist * Fixed64::fromFraction(9, 10)) return;
    Fixed64 v_end = Fixed64::zero();
    switch (o.why) {
        case Why::Chase: case Why::MeetPass:
            v_end = arrive_through_;
            break;
        case Why::Press: {
            // G5.39 (§8.139): his spot moves with their carrier — he arrives at
            // it no slower than the carrier runs (tracking, not pursuit, as the
            // block's G5.30). Braked to arrive at 3 m/s on a spot running at goal
            // at 4-5, the presser trailed behind the carrier he was meant to be
            // goal-side of (the nearest man goal-side 32% with the ball 0-18 m
            // out; real 60%, DFL).
            v_end = arrive_through_;
            if (world.ball().owner) {
                const auto& cv = world.player(*world.ball().owner).vel;
                const Fixed64 cs = math::fx_sqrt(cv.x * cv.x + cv.y * cv.y);
                if (cs > v_end) v_end = cs;
            }
            break;
        }
        default: break;
    }
    Fixed64 v_ok = math::fx_sqrt(v_end * v_end + Fixed64::fromInt(2) * arrive_decel_ * dist);
    // G5.5 (§8.103): adjusting his shape he goes only as fast as the gap asks,
    // closing it in shape_tau_s. Off the ball real men spend 3.3% of the time
    // over 5 m/s (DFL tracking); ours 47.5%, 58% of that holding shape, and a
    // man running at the kick can't take the ball.
    // G5.10 (§8.108): not with their ball inside shape_danger_m of our goal —
    // there a man getting back into his shape goes at the defending pace
    // (the block that walked back was 9 m behind its spots with the ball wide
    // 18-30 m out, the offside line 4-5 m too high, the box empty).
    const bool danger = o.why == Why::Hold && inDanger(slot, world);
    if (o.why == Why::Hold && shape_tau_.raw > 0 && !danger) {
        // G5.14 (§8.111): with our ball the shape moves with it — he closes
        // the gap in shape_tau_ours_s. Eased over shape_tau_s (fitted to the
        // block without the ball, §8.103) every man trailed his spot by the
        // spot's own speed × tau, ~11 m: the side in possession stood 5-9 m
        // deeper than real at every ball band (DFL), front men and full-backs
        // 10 m, and ours_slope had been raised 0.45 → 0.9 to make up for it
        // (§8.102) — targets nobody reached. Real team centroids move in phase
        // with the ball [Frencken, Lemmink, Delleman & Visscher 2011].
        // Coaching: "move together with the ball" [FH].
        Fixed64 tau = shape_tau_;
        if (shape_tau_ours_.raw > 0) {
            const auto& b = world.ball();
            const std::uint8_t team = setup_.team_of_slot[slot];
            const bool ours = b.owner ? setup_.team_of_slot[*b.owner] == team
                                      : (world.restartTeam() == 0xFF && world.lastTouchTeam() == team);
            if (ours) tau = shape_tau_ours_;
            // G5.32 (§8.130): without the ball, a spot goal-side of him (a metre+)
            // he closes in shape_tau_back_s — get goal-side first [FH coaching];
            // across and up he keeps the shift's patience. On one tau the block
            // reached the 40 m danger line behind its spots and sprinted from
            // there (back 5+ m/s 17.5% inside it, real 9.2; further out 1.1, real
            // 2.8 — DFL, benchmarks_tracking_recover.py). No row = off.
            const Fixed64 sgn = setup_.team_of_slot[slot] == 0 ? Fixed64::one() : -Fixed64::one();
            if (!ours && tau_back_.raw > 0 && d.x * sgn < -Fixed64::one()) tau = tau_back_;
        }
        const Fixed64 ease = dist / tau;
        if (ease < v_ok) v_ok = ease;
    }

    // A team shifts as a block at a jog and accepts the lag: most of what was
    // left over 5 m/s was a man 15 m+ off his target (§8.103).
    // G5.30 (§8.128): tracking, not pursuit — he runs with his spot's own
    // velocity and closes the gap on top of it. On gap/tau alone a man
    // trailed a moving spot by its speed × tau (/ the backpedal share facing
    // the ball): the block stood 1.5-3 m off its spots at every band, upfield
    // of them where the ball comes at us. Real team centroids move in phase
    // with the ball [Frencken, Lemmink, Delleman & Visscher 2011].
    // G5.50 (§8.150): a line job (front / second man) closes on his spot at most
    // front.close_mps on top of the line's own velocity — he walks or jogs into
    // a jumped spot; sprinting into it read as a run (ball-still runs 84.7 v 41.7).
    // With the ball going forward 2+ m/s the shape moves with it, and real men run
    // then (ours 167 v 167.4), so only with the ball not going forward.
    if (leading && o.why == Why::Hold && poss_.onLine(setup_.team_of_slot[slot], slot) &&
        poss_.params().front_close.raw > 0 && v_ok > poss_.params().front_close) {
        const Fixed64 sgf = setup_.team_of_slot[slot] == 0 ? Fixed64::one() : -Fixed64::one();
        if (world.ball().vel.x * sgf < poss_.params().run_ball_fwd) v_ok = poss_.params().front_close;
    }
    if (leading && o.why == Why::Hold) {
        const Vec2 want = dist.raw > 0 ? Vec2{lead.x + d.x * v_ok / dist, lead.y + d.y * v_ok / dist} : lead;
        Fixed64 cap = Fixed64::zero();
        if (!danger) cap = defend_max_;   // and by direction: capAcross
        else if (shape_danger_sprint_ == 0) cap = defend_max_;
        Fixed64 sp = math::length(want);
        Vec2 w = want;
        if (cap.raw > 0 && sp > cap) { w = Vec2{want.x * cap / sp, want.y * cap / sp}; sp = cap; }
        if (sp > me.max_speed) w = Vec2{w.x * me.max_speed / sp, w.y * me.max_speed / sp};
        o.move.move = Vec2{w.x / me.max_speed, w.y / me.max_speed};
        return;
    }
    // Holding shape outside danger his pace is by direction (capAcross, G5.31).
    if (shape_max_.raw > 0 && o.why == Why::Hold && !danger && defend_max_ < v_ok) v_ok = defend_max_;
    if (danger && shape_danger_sprint_ == 0 && defend_max_.raw > 0 && defend_max_ < v_ok) v_ok = defend_max_;
    // A race to a MOVING ball (G4.84): arrive ON TIME, not just under
    // control. His target is where the flight read says he and the ball
    // meet, fr.tick ticks from now — so he runs at least dist / that time
    // (+10%). Braked on distance alone he was late, the next read picked a
    // nearer, later point, he braked again: receivers stood and waited (5.2
    // → 1.4 m/s traced) while the defender the read had beaten stepped in
    // front — 53% of the passes cut out were OURS by the read at the kick.
    // Not braking at all ran him past the spot before the ball came.
    switch (o.why) {
        case Why::MeetPass: case Why::Chase: {
            if (world.ball().owner || world.restartTeam() != 0xFF) break;
            const FlightRead& fr = reads_.flightRead(world);
            if (!fr.live || slot >= fr.tick.size() || fr.tick[slot] <= 0) break;
            const Fixed64 t = Fixed64::fromInt(fr.tick[slot]) * core::kTickDt;
            const Fixed64 need = dist / t * Fixed64::fromFraction(11, 10);
            if (need > v_ok) v_ok = need;
            break;
        }
        default: break;
    }
    const Fixed64 k = v_ok / me.max_speed;
    if (k >= mlen) return;
    o.move.move = Vec2{o.move.move.x * k / mlen, o.move.move.y * k / mlen};
}

}  // namespace fh::game::ai
