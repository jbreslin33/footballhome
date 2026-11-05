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
}

Brain::Brain(const Brain& o)
    : setup_(o.setup_), half_x_(o.half_x_), half_y_(o.half_y_), index_in_team_(o.index_in_team_),
      match_seed_(o.match_seed_), reads_(o.reads_), block_(o.block_), poss_(o.poss_), phase_params_(o.phase_params_),
      think_tick_(o.think_tick_), restart_play_(o.restart_play_), hold_team_(o.hold_team_), hold_(o.hold_),
      arrive_decel_(o.arrive_decel_), arrive_through_(o.arrive_through_), shape_tau_(o.shape_tau_),
      shape_tau_ours_(o.shape_tau_ours_), shape_max_(o.shape_max_), defend_max_(o.defend_max_),
      shape_danger_(o.shape_danger_), shape_danger_sprint_(o.shape_danger_sprint_), theirs_shift_y_(o.theirs_shift_y_),
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
    arrive_decel_ = p.fixed("physics.body.arrive_decel_mps2", 4500);
    arrive_through_ = p.fixed("physics.body.arrive_through_mps", 3000);
    shape_tau_ = p.fixed("physics.body.shape_tau_s", 0);
    shape_tau_ours_ = p.fixed("physics.body.shape_tau_ours_s", 0);
    shape_max_ = p.fixed("physics.body.shape_max_mps", 0);
    defend_max_ = p.fixed("physics.body.defend_max_mps", 0);
    shape_danger_ = p.fixed("physics.body.shape_danger_m", 0);
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
        const_cast<DefendingBlock&>(block_).reset();
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
        const_cast<DefendingBlock&>(block_).assign(t, world, setup_.team_of_slot, fr, restartTaker(world, t));
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

PlayerView Brain::viewOf(SlotIndex slot, const World& world) const {
    const std::uint8_t team = setup_.team_of_slot[slot];
    const FormationSpec::Pos& mine = spec_[team].positions[index_in_team_[slot]];
    PlayerView v;
    v.slot = slot;
    v.team = team;
    v.sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    v.role = roleOfNumber(mine.number);
    v.keeper = world.isKeeper(slot);
    const Fixed64 by = world.ball().pos.y;
    v.across_def = slideY(mine.base, by, theirs_shift_y_, theirs_cap_y_);
    v.across_ours = slideY(mine.base, by, ours_shift_y_, ours_cap_y_);
    const FlightRead& fr = reads_.flightRead(world);
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
    namePass(slot, world, o);
    brakeToArrive(slot, world, o);
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
    else if (k == core::MatchEventType::Corner || k == core::MatchEventType::Offside) r = restart_play_.kick_law_m;
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
void Brain::brakeToArrive(SlotIndex slot, const World& world, Orders& o) const {
    switch (o.why) {
        case Why::Human: case Why::KeeperDive:
            return;
        default: break;
    }
    const auto& me = world.player(slot);
    if (world.ball().owner && *world.ball().owner == slot) return;
    if (o.target.x.raw == 0 && o.target.y.raw == 0) return;
    const Fixed64 m2 = math::lengthSquared(o.move.move);
    if (m2.raw == 0 || me.max_speed.raw <= 0) return;
    const Vec2 d{o.target.x - me.pos.x, o.target.y - me.pos.y};
    const Fixed64 dist = math::length(d);
    if (dist.raw == 0) return;
    const Fixed64 mlen = math::fx_sqrt(m2);
    // Only when he's actually running AT the target (a pass's target is the
    // receiver; a jockey's is the man).
    if (math::dot(o.move.move, d) < mlen * dist * Fixed64::fromFraction(9, 10)) return;
    Fixed64 v_end = Fixed64::zero();
    switch (o.why) {
        case Why::Chase: case Why::MeetPass: case Why::Press:
            v_end = arrive_through_;
            break;
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
    bool danger = false;
    if (shape_danger_.raw > 0 && o.why == Why::Hold) {
        const auto& b = world.ball();
        const std::uint8_t team = setup_.team_of_slot[slot];
        const bool theirs = b.owner ? setup_.team_of_slot[*b.owner] != team : world.lastTouchTeam() != team;
        const Fixed64 sg = setup_.team_of_slot[slot] == 0 ? Fixed64::one() : -Fixed64::one();
        danger = theirs && b.pos.x * sg + half_x_ < shape_danger_;
    }
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
        }
        const Fixed64 ease = dist / tau;
        if (ease < v_ok) v_ok = ease;
    }
    // A team shifts as a block at a jog and accepts the lag: most of what was
    // left over 5 m/s was a man 15 m+ off his target (§8.103).
    if (shape_max_.raw > 0 && o.why == Why::Hold && !danger && shape_max_ < v_ok) v_ok = shape_max_;
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
