// game/src/ai/Reads.cpp — what a player can predict (G5.22, DESIGN §8.120).
// Moved from the old Brain.cpp unchanged but for where its numbers live.
#include "ai/Reads.hpp"

#include "core/Ball.hpp"
#include "core/PlayerSkill.hpp"
#include "math/FixedMath.hpp"

#include <algorithm>

namespace fh::game::ai {

using core::SlotIndex;
using core::World;
using math::Fixed64;
using math::Vec2;
using math::Vec3;
using math::dot;

Fixed64 distSq(const Vec3& a, const Vec3& b) {
    const Vec2 d{a.x - b.x, a.y - b.y};
    return math::lengthSquared(d);
}

Fixed64 runToward(const World& world, SlotIndex slot, const Vec2& at, Fixed64 t) {
    const core::PlayerState& p = world.player(slot);
    const Vec2 d{at.x - p.pos.x, at.y - p.pos.y};
    // Out of reach even at full speed the whole way: skip the sqrt.
    const Fixed64 best = p.max_speed * t;
    if (math::lengthSquared(d) > (best + Fixed64::fromInt(2)) * (best + Fixed64::fromInt(2)))
        return best;
    const Fixed64 len = math::length(d);
    const Fixed64 v0 = len.raw > 0 ? (p.vel.x * d.x + p.vel.y * d.y) / len : Fixed64::zero();
    return world.body(slot).reach(v0, p.max_speed, t);
}

Fixed64 chanceQuality(const World& world, const std::vector<std::uint8_t>& team_of_slot,
                      SlotIndex shooter, const Vec2& goal) {
    const Fixed64 half_w = Fixed64::fromFraction(732, 200);
    const auto& me = world.player(shooter);
    const Vec2 s{me.pos.x, me.pos.y};
    const Vec2 p1{goal.x, -half_w}, p2{goal.x, half_w};
    const Vec2 a{p1.x - s.x, p1.y - s.y}, b{p2.x - s.x, p2.y - s.y};
    const Fixed64 cr = a.x * b.y - a.y * b.x;
    Fixed64 q = math::fx_abs(math::fx_atan2(cr, dot(a, b)));
    auto side = [](const Vec2& o, const Vec2& u, const Vec2& v) {
        return (u.x - o.x) * (v.y - o.y) - (u.y - o.y) * (v.x - o.x);
    };
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (team_of_slot[j] == team_of_slot[shooter]) continue;
        if (world.isKeeper(j)) continue;
        const Vec2 o{world.player(j).pos.x, world.player(j).pos.y};
        const Fixed64 d1 = side(s, p1, o), d2 = side(p1, p2, o),
                      d3 = side(p2, s, o);
        const bool neg = d1.raw < 0 || d2.raw < 0 || d3.raw < 0;
        const bool pos = d1.raw > 0 || d2.raw > 0 || d3.raw > 0;
        if (!(neg && pos)) q = q * Fixed64::fromFraction(1, 2);
    }
    return q;
}

Loft loftTo(const core::BallFlight& flight, const core::PlayerState& mate, const Vec3& from, Fixed64 max_m) {
    Vec2 at{mate.pos.x, mate.pos.y};
    Fixed64 d{};
    for (int k = 0; k < 3; ++k) {
        d = math::length(Vec2{at.x - from.x, at.y - from.y});
        if (d > max_m) d = max_m;
        if (d < Fixed64::one()) d = Fixed64::one();
        // Its time in the air, with drag (G4.87; was 2·r·v / g).
        const Fixed64 t = flight.flightTime(d);
        at = Vec2{mate.pos.x + mate.vel.x * t, mate.pos.y + mate.vel.y * t};
    }
    const std::int64_t m = (d + Fixed64::fromFraction(1, 2)).raw >> Fixed64::FRAC_BITS;
    return Loft{at, static_cast<std::uint8_t>(m < 1 ? 1 : (m > 255 ? 255 : m))};
}

std::uint8_t aimedCarry(const Vec3& from, const Vec2& to, Fixed64 max_m) {
    Fixed64 d = math::length(Vec2{to.x - from.x, to.y - from.y});
    if (d > max_m) d = max_m;
    const std::int64_t m = (d + Fixed64::fromFraction(1, 2)).raw >> Fixed64::FRAC_BITS;
    return static_cast<std::uint8_t>(m < 1 ? 1 : (m > 255 ? 255 : m));
}

Fixed64 rangeFor(const core::PlayerSkill& lv, Fixed64 max_m) {
    const Fixed64 r = Fixed64::fromInt(lv.kick_range_m);
    return lv.kick_range_m > 0 && r < max_m ? r : max_m;
}

void Reads::configure(const core::ModelParams& p) {
    // physics.receive.* (G5.22) — the numbers concept.meet-the-pass carried.
    horizon_ticks_ = p.integer("physics.receive.horizon_ticks", p.integer("concept.meet-the-pass.horizon_ticks", 90));
    early_s_ = p.fixed("physics.receive.early_s", p.milli("concept.meet-the-pass.early_s", 250));
    on_line_m_ = p.fixed("physics.receive.on_line_m", p.milli("concept.meet-the-pass.on_line_m", 250));
    read_header_ = p.integer("physics.receive.read_header", p.integer("concept.meet-the-pass.read_header", 0));
    aerial_radius_ = p.fixed("physics.aerial.radius_m", 0);
    aerial_min_z_ = p.fixed("physics.aerial.min_z_m", 1000);
    if (aerial_radius_.raw <= 0) read_header_ = 0;
}

const Reads::FlightRead& Reads::flightRead(const World& world) const {
    const auto& b = world.ball();
    if (flight_tick_ == world.tickCount() && flight_key_[0] == b.pos.x.raw &&
        flight_key_[1] == b.pos.y.raw && flight_key_[2] == b.vel.x.raw)
        return flight_;
    flight_tick_ = world.tickCount();
    flight_key_[0] = b.pos.x.raw;
    flight_key_[1] = b.pos.y.raw;
    flight_key_[2] = b.vel.x.raw;
    FlightRead& f = flight_;
    f.live = !b.owner && world.restartTeam() == 0xFF;
    if (!f.live) {
        f.tick.assign(world.playerCount(), -1);
        f.at.assign(world.playerCount(), Vec2{});
        f.first[0] = f.first[1] = -1;
        return f;
    }
    RaceBall rb;
    rb.pos = b.pos;
    rb.vel = b.vel;
    rb.since = static_cast<std::int64_t>(world.tickCount() - world.flightTick());
    rb.kicker = b.last_kicker;
    rb.lockout = b.kicker_lockout;
    rb.ours = world.lastTouchTeam();
    race(world, rb, f);
    f.live = true;
    return f;
}

void Reads::race(const World& world, const RaceBall& rb, FlightRead& f) const {
    const SlotIndex n = world.playerCount();
    f.tick.assign(n, -1);
    f.at.assign(n, Vec2{});
    f.first[0] = f.first[1] = -1;

    // Each man starts after HIS reaction (G4.85, the reaction attribute — was
    // one flat meet-the-pass number) + his perception delay, counted once
    // from when the flight BEGAN. Charged afresh on every read, a receiver
    // 3 m from a ball rolling at him, already running onto it, read as
    // "can't get there" (his whole reaction again before he may move) and
    // fell back to chasing where the ball was: it rolled past him 0.8 m off
    // and their man took it (GAME_TRACE_FLIP).
    const Fixed64 since = Fixed64::fromInt(rb.since) * core::kTickDt;
    Fixed64 react[64];
    for (SlotIndex i = 0; i < n && i < 64; ++i) {
        const Fixed64 full = world.body(i).reaction() +
                             Fixed64::fromInt(world.skillOf(i).perception_delay_ticks) * core::kTickDt;
        react[i] = full > since ? full - since : Fixed64::zero();
    }
    const Fixed64 box_x = half_x_ - Fixed64::fromFraction(33, 2);   // 16.5 m
    const Fixed64 box_y = Fixed64::fromFraction(2016, 100);          // 20.16 m
    const std::uint32_t flagged = rb.offside ? world.offsideMask() : 0u;
    const std::uint8_t flag_team = rb.offside ? world.offsideTeam() : std::uint8_t{0xFF};
    Vec3 pos = rb.pos, vel = rb.vel;
    int open = n;
    const int horizon = horizon_ticks_;
    for (int k = 0; k <= horizon && open > 0; ++k) {
        if (k > 0) {  // World::tickFreeBall, one tick
            if (pos.z.raw > 0 || vel.z.raw != 0) {
                world.ballFlight().step(vel);   // G4.87: the World's own law
                vel.z -= core::kGravity * core::kTickDt;
            }
            pos += vel * core::kTickDt;
            if (pos.z.raw < 0) {
                pos.z = Fixed64::zero();
                const Fixed64 impact = -vel.z;
                if (impact > core::kBounceDeadSpeed) {
                    vel.z = impact * core::kBallRestitution;
                    vel.x = vel.x * core::kBounceSkid;
                    vel.y = vel.y * core::kBounceSkid;
                } else {
                    vel.z = Fixed64::zero();
                }
            }
            if (pos.z.raw == 0 && vel.z.raw == 0) {
                vel.x = vel.x * core::kBallRollDecayPerTick;
                vel.y = vel.y * core::kBallRollDecayPerTick;
            }
        }
        if (math::fx_abs(pos.x) > half_x_ || math::fx_abs(pos.y) > half_y_) break;  // out of play
        const bool rolling = pos.z.raw == 0 && vel.z.raw == 0;
        if (rolling && k % 3 != 0) continue;  // a rolling ball: every 3rd tick is plenty
        const Fixed64 sp2 = vel.x * vel.x + vel.y * vel.y;
        const Fixed64 t = core::kTickDt * Fixed64::fromInt(k);
        for (SlotIndex i = 0; i < n && i < 64; ++i) {
            if (f.tick[i] >= 0) continue;
            if (i == rb.kicker && k < rb.lockout) continue;
            const auto& p = world.player(i);
            // A man in an offside position leaves it (the flag decides).
            if (flag_team != 0xFF && p.team == flag_team && ((flagged >> (i & 31)) & 1u)) continue;
            const bool gk = world.isKeeper(i);
            // G5.11 (§8.108): an outfielder reads the HEAD-height point of a
            // ball coming down too (World::aerialWinner's window: min_z up to
            // his head, within the aerial radius, any speed) — reading only to
            // his chest sent every man to where a cross had already dropped
            // past heading, and none was ever headed (real: 25% of high
            // crosses end in a defender's headed clearance). No row = off.
            const bool header = read_header_ && !gk && vel.z.raw < 0 && pos.z > core::kOutfieldReachZ &&
                                pos.z >= aerial_min_z_ && pos.z <= world.body(i).headReach();
            if (!header && pos.z > (gk ? core::kKeeperReachZ : core::kOutfieldReachZ)) continue;   // G4.94
            const Fixed64 cap = gk ? core::kCaptureMaxSpeed + core::kKeeperHandsBonus : core::kCaptureMaxSpeed;
            if (!header && sp2 > cap * cap) continue;
            // Our own ball (G4.85): he takes it where it has come down to a
            // pace his first touch can hold — a man knows his touch. Met
            // early and hot it came off him (traced: 53 bad touches a match
            // at 15 m/s+ on passes meant for him once the read stopped
            // re-charging the reaction).
            if (!header && !gk && p.team == rb.ours) {
                const std::int32_t c = world.skillOf(i).control_speed_mps;
                const Fixed64 cs = core::controlSpeedAt(Fixed64::fromInt(c), pos.z);   // G4.94
                if (c > 0 && sp2 > cs * cs) continue;
            }
            if (gk) {  // hands only in his own box
                const bool own_end = (*team_of_slot_)[i] == 0 ? pos.x < -box_x : pos.x > box_x;
                if (!own_end || math::fx_abs(pos.y) > box_y) continue;
            }
            const Fixed64 rt = t > react[i] ? t - react[i] : Fixed64::zero();
            const Fixed64 run = runToward(world, i, Vec2{pos.x, pos.y}, rt) +
                                (gk ? world.keeperReach() : header ? aerial_radius_ : core::kBallControlRadius) +
                                (p.team != rb.ours ? rb.opp_margin : Fixed64::zero());
            const Fixed64 gap_sq = header ? math::lengthSquared(Vec2{p.pos.x - pos.x, p.pos.y - pos.y}) : distSq(p.pos, pos);
            if (gap_sq <= run * run) {
                f.tick[i] = static_cast<std::int16_t>(k);
                f.at[i] = Vec2{pos.x, pos.y};
                --open;
            }
        }
        if (rb.first_only && open < static_cast<int>(n)) break;
    }
    for (SlotIndex i = 0; i < n; ++i) {
        if (f.tick[i] < 0) continue;
        int& first = f.first[(*team_of_slot_)[i]];
        if (first < 0 || f.tick[i] < f.tick[first]) first = i;
    }
}

namespace { constexpr int kInLineSoonTicks = 15; }   // G5.98: 0.5 s — a ball this near he meets on time, not early

bool Reads::getInLine(SlotIndex slot, const World& world, Vec2& at) const {
    const Fixed64 early = early_s_;
    if (early.raw <= 0) return false;
    const auto& b = world.ball();
    if (b.pos.z.raw != 0 || b.vel.z.raw != 0) return false;
    const auto& p = world.player(slot);
    const Fixed64 since = Fixed64::fromInt(static_cast<std::int64_t>(world.tickCount() - world.flightTick())) * core::kTickDt;
    const Fixed64 full = world.body(slot).reaction() +
                         Fixed64::fromInt(world.skillOf(slot).perception_delay_ticks) * core::kTickDt;
    const Fixed64 react = full > since ? full - since : Fixed64::zero();
    const std::int32_t c = world.skillOf(slot).control_speed_mps;
    const Fixed64 cs = Fixed64::fromInt(c);
    Vec2 pos{b.pos.x, b.pos.y}, vel{b.vel.x, b.vel.y};
    // On the line first, then along it: until his body is on its line he takes
    // no spot short of the foot of his perpendicular, or the spot keeps sliding
    // toward the ball and he runs beside it (traced: half the misses 0.5-1 m off).
    const Fixed64 sp = math::length(vel);
    if (sp.raw == 0) return false;
    const Vec2 dir{vel.x / sp, vel.y / sp};
    const Vec2 rel{p.pos.x - pos.x, p.pos.y - pos.y};
    const Fixed64 foot = math::dot(rel, dir);
    const Fixed64 off = math::fx_abs(rel.x * dir.y - rel.y * dir.x);
    const bool on_line = off < on_line_m_;
    const int horizon = horizon_ticks_;
    for (int k = 1; k <= horizon; ++k) {
        pos.x += vel.x * core::kTickDt;
        pos.y += vel.y * core::kTickDt;
        vel.x = vel.x * core::kBallRollDecayPerTick;
        vel.y = vel.y * core::kBallRollDecayPerTick;
        if (math::fx_abs(pos.x) > half_x_ || math::fx_abs(pos.y) > half_y_) return false;
        if (k % 3 != 0) continue;
        if (c > 0 && vel.x * vel.x + vel.y * vel.y > cs * cs) continue;   // not yet at a pace he can hold
        if (!on_line && math::dot(Vec2{pos.x - b.pos.x, pos.y - b.pos.y}, dir) < foot) continue;
        // G5.98 (§8.199): early only where there is time for it. A ball under 0.5 s from the
        // spot he takes on time — with the 0.25 s early every near spot failed, and the first
        // that passed was 14 m on, where the ball had slowed to his running pace.
        const bool soon = k <= kInLineSoonTicks;
        const Fixed64 t = core::kTickDt * Fixed64::fromInt(k) - react - (soon ? Fixed64::zero() : early);
        if (t < Fixed64::zero()) continue;
        // G5.98 (§8.199): his run plus his reach, as race() counts it. On the run alone a man
        // 0.3 m off the line of a ball 3 m from him "couldn't get there" at any near point
        // (0.25 s early leaves him 0.05 s), and the spot he took was 13 m down the line: he
        // jogged off to it as the ball reached him late or rolled by to their man.
        const Fixed64 r = runToward(world, slot, pos, t) + core::kBallControlRadius;
        if (distSq(p.pos, Vec3{pos.x, pos.y, Fixed64::zero()}) <= r * r) {
            at = pos;
            return true;
        }
    }
    return false;
}

bool Reads::passSafe(const World& world, SlotIndex passer, const Vec2& from, const Vec2& to,
                     Fixed64 speed, Fixed64 reach) const {
    const Vec2 ab{to.x - from.x, to.y - from.y};
    const Fixed64 len = math::length(ab);
    if (len.raw == 0) return true;
    return raceSafe(world, passer, Vec3{from.x, from.y, Fixed64::zero()},
                    Vec3{ab.x / len * speed, ab.y / len * speed, Fixed64::zero()}, reach);
}

bool Reads::loftSafe(const World& world, SlotIndex passer, const Vec2& from, const Vec2& at,
                     std::uint8_t carry_m, Fixed64 reach) const {
    const Vec2 ab{at.x - from.x, at.y - from.y};
    const Fixed64 len = math::length(ab);
    if (len.raw == 0) return true;
    const Fixed64 v = world.ballFlight().launchSpeed(Fixed64::fromInt(carry_m));
    return raceSafe(world, passer, Vec3{from.x, from.y, Fixed64::zero()},
                    Vec3{ab.x / len * v, ab.y / len * v, v * world.ballFlight().ratio(Fixed64::fromInt(carry_m))}, reach);
}

bool Reads::raceSafe(const World& world, SlotIndex passer, const Vec3& pos, const Vec3& vel,
                     Fixed64 reach) const {
    RaceBall rb;
    rb.pos = pos;
    rb.vel = vel;
    rb.kicker = passer;
    rb.lockout = core::kKickerLockoutTicks;
    rb.ours = (*team_of_slot_)[passer];
    rb.offside = false;
    rb.opp_margin = reach > core::kBallControlRadius ? reach - core::kBallControlRadius : Fixed64::zero();
    rb.first_only = true;
    FlightRead& f = pass_race_;
    race(world, rb, f);
    const int mine = f.first[rb.ours], theirs = f.first[rb.ours ^ 1];
    return mine >= 0 && (theirs < 0 || f.tick[mine] < f.tick[theirs]);
}

}  // namespace fh::game::ai
