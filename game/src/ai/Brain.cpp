// game/src/ai/Brain.cpp

#include "ai/Brain.hpp"

#include "ai/Formation.hpp"
#include "ai/Steering.hpp"
#include "core/Ball.hpp"
#include "core/Levels.hpp"

#include <algorithm>

namespace fh::game::ai {

using core::Action;
using core::MoveIntent;
using core::SlotIndex;
using core::World;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

// Shoot when the carrier is inside this range of the goal centre.
const Fixed64 kShootRange = Fixed64::fromInt(22);
// An opponent this close means "under pressure" — look for the pass before
// the touch-tight steal lands.
const Fixed64 kPressureRadius = Fixed64::fromFraction(5, 2);  // 2.5 m
// A passing lane is "closed" if any opponent stands within this of the
// carrier→receiver segment.
const Fixed64 kLaneWidth = Fixed64::fromInt(2);
// Pass only to receivers in this distance window: closer is a handover
// that achieves nothing, farther outruns a ground ball's roll-out.
const Fixed64 kPassMin = Fixed64::fromInt(5);
const Fixed64 kPassMax = Fixed64::fromInt(30);
// Feet-to-feet inside this → ShortPass (8 m/s); beyond → driven (14 m/s).
const Fixed64 kSoftPassRange = Fixed64::fromInt(14);
// Forward progress a receiver must offer to be worth it when NOT pressed.
const Fixed64 kEagerGain = Fixed64::fromInt(8);
// Chase a loose ball only within this radius of the anchor's duties —
// beyond it, trust a better-placed teammate (prevents 11-man ball-chasing,
// the classic youth-soccer failure the teaching tool exists to fix).
const Fixed64 kChaseRadius = Fixed64::fromInt(28);
// "Arrived" radius around the anchor — inside it, stand still instead of
// oscillating over the point.
const Fixed64 kArriveRadius = Fixed64::fromFraction(3, 2);


Fixed64 distSq(const Vec3& a, const Vec3& b) {
    const Vec2 d{a.x - b.x, a.y - b.y};
    return math::lengthSquared(d);
}

// Squared distance from point p to segment a→b (planar). Deterministic:
// one fixed-point division, clamped parameter.
Fixed64 pointSegmentDistSq(const Vec2& p, const Vec2& a, const Vec2& b) {
    const Vec2 ab{b.x - a.x, b.y - a.y};
    const Fixed64 len_sq = math::lengthSquared(ab);
    if (len_sq.raw == 0) {
        const Vec2 d{p.x - a.x, p.y - a.y};
        return math::lengthSquared(d);
    }
    Fixed64 t = (dot(Vec2{p.x - a.x, p.y - a.y}, ab)) / len_sq;
    if (t < Fixed64::zero()) t = Fixed64::zero();
    if (t > Fixed64::one()) t = Fixed64::one();
    const Vec2 c{a.x + ab.x * t, a.y + ab.y * t};
    const Vec2 d{p.x - c.x, p.y - c.y};
    return math::lengthSquared(d);
}

// G4.51: how far he runs toward `at` in t seconds — his own body's law
// (core::Body::reach, G4.52) from his current speed along that line, not
// top speed from a standing start.
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

// Chance quality (G4.21, shot_selection) [FH, after the xG literature's
// two dominant features — visible goal angle and bodies in the way]: the
// angle the goal mouth subtends at the shooter (radians), halved for
// every OUTFIELD opponent standing inside the shooter→post→post
// triangle. The keeper is excluded — placement already plays him.
// Laws of the Game: goal 7.32 m wide (World.cpp owns the physics copy).
Fixed64 chanceQuality(const World& world, const TeamSetup& setup,
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
        if (setup.team_of_slot[j] == setup.team_of_slot[shooter]) continue;
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


// Aimed loft (G4.48): where to drop a lofted pass for a moving mate — his
// spot after the ball's flight (2·r·v / g at the carry that reaches it,
// solved twice: the lead moves the carry) — and that carry, capped at the
// passer's range. Lands at his feet on the first bounce, the one moment a
// dropping ball is low enough to take.
struct Loft {
    Vec2 at;
    std::uint8_t carry_m;
};
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

// The carry that drops a loft on a fixed spot (clearances, punts).
std::uint8_t aimedCarry(const Vec3& from, const Vec2& to, Fixed64 max_m) {
    Fixed64 d = math::length(Vec2{to.x - from.x, to.y - from.y});
    if (d > max_m) d = max_m;
    const std::int64_t m = (d + Fixed64::fromFraction(1, 2)).raw >> Fixed64::FRAC_BITS;
    return static_cast<std::uint8_t>(m < 1 ? 1 : (m > 255 ? 255 : m));
}

// A loft's max carry for this player: the concept's number, capped by his
// level's kick range (G4.48) — he never asks for a ball he can't hit.
Fixed64 rangeFor(const core::LevelParams& lv, Fixed64 max_m) {
    const Fixed64 r = Fixed64::fromInt(lv.kick_range_m);
    return lv.kick_range_m > 0 && r < max_m ? r : max_m;
}

}  // namespace

TeamSetup TeamSetup::splitHalves(std::uint8_t slot_count) {
    TeamSetup s;
    s.team_of_slot.resize(slot_count);
    const std::uint8_t half = slot_count / 2;
    for (std::uint8_t i = 0; i < slot_count; ++i)
        s.team_of_slot[i] = i < half ? 0 : 1;
    return s;
}

Brain::Brain(TeamSetup setup, Fixed64 pitch_half_x, Fixed64 pitch_half_y,
             FormationSpec home, FormationSpec away)
    : setup_{std::move(setup)}, half_x_{pitch_half_x}, half_y_{pitch_half_y} {
    const auto n = setup_.team_of_slot.size();
    index_in_team_.resize(n);
    team_size_.resize(n);
    std::uint8_t count[2] = {0, 0};
    for (std::size_t i = 0; i < n; ++i)
        index_in_team_[i] = count[setup_.team_of_slot[i]]++;
    for (std::size_t i = 0; i < n; ++i)
        team_size_[i] = count[setup_.team_of_slot[i]];
    spec_[0] = home.valid(count[0]) ? std::move(home)
                                    : builtinFormation(count[0]);
    spec_[1] = away.valid(count[1]) ? std::move(away)
                                    : builtinFormation(count[1]);
    ratings_.assign(n, core::defaultRatings(core::LevelParams{}));
}

int Brain::teamCloserCount(SlotIndex slot, const World& world,
                           const Vec3& target) const {
    const Fixed64 mine = distSq(world.player(slot).pos, target);
    int closer = 0;
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot) continue;
        if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
        const Fixed64 d = distSq(world.player(i).pos, target);
        if (d < mine || (d == mine && i < slot)) ++closer;
    }
    return closer;
}

bool Brain::isTeamClosest(SlotIndex slot, const World& world,
                          const Vec3& target) const {
    const Fixed64 mine = distSq(world.player(slot).pos, target);
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot) continue;
        if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
        const Fixed64 d = distSq(world.player(i).pos, target);
        if (d < mine || (d == mine && i < slot)) return false;
    }
    return true;
}

const Brain::FlightRead& Brain::flightRead(const World& world) const {
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

void Brain::race(const World& world, const RaceBall& rb, FlightRead& f) const {
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
                             Fixed64::fromInt(levelOf(i).perception_delay_ticks) * core::kTickDt;
        react[i] = full > since ? full - since : Fixed64::zero();
    }
    const Fixed64 box_x = half_x_ - Fixed64::fromFraction(33, 2);   // 16.5 m
    const Fixed64 box_y = Fixed64::fromFraction(2016, 100);          // 20.16 m
    const std::uint32_t flagged = rb.offside ? world.offsideMask() : 0u;
    const std::uint8_t flag_team = rb.offside ? world.offsideTeam() : std::uint8_t{0xFF};
    Vec3 pos = rb.pos, vel = rb.vel;
    int open = n;
    const int horizon = std::max(books_[0].meet_the_pass.horizonTicks(),
                                 books_[1].meet_the_pass.horizonTicks());
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
                const std::int32_t c = levelOf(i).control_speed_mps;
                const Fixed64 cs = core::controlSpeedAt(Fixed64::fromInt(c), pos.z);   // G4.94
                if (c > 0 && sp2 > cs * cs) continue;
            }
            if (gk) {  // hands only in his own box
                const bool own_end = setup_.team_of_slot[i] == 0 ? pos.x < -box_x : pos.x > box_x;
                if (!own_end || math::fx_abs(pos.y) > box_y) continue;
            }
            const Fixed64 rt = t > react[i] ? t - react[i] : Fixed64::zero();
            const Fixed64 run = runToward(world, i, Vec2{pos.x, pos.y}, rt) +
                                (gk ? core::kKeeperReach : header ? aerial_radius_ : core::kBallControlRadius) +
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
        int& first = f.first[setup_.team_of_slot[i]];
        if (first < 0 || f.tick[i] < f.tick[first]) first = i;
    }
}

// Get in line with the ball (G5.5, §8.103) [FH; coaching: "get your body behind
// it"]: the man a rolling pass is for picks the first spot on its real path he
// reaches early_s ahead of the ball, his body on it, not the first he can only
// just touch. The race's spot has no margin: traced, 75% of ground passes that
// ran into touch went within 2 m of him at 10 m/s, he on the line at the kick,
// walking up it to a spot he then missed, or braking short, or still turning out
// of a run. False = no such spot, or the ball isn't rolling yet.
bool Brain::getInLine(SlotIndex slot, const World& world, Vec2& at) const {
    const ConceptBook& book_ = bookOf(slot);
    const Fixed64 early = book_.meet_the_pass.earlyS();
    if (early.raw <= 0) return false;
    const auto& b = world.ball();
    if (b.pos.z.raw != 0 || b.vel.z.raw != 0) return false;
    const auto& p = world.player(slot);
    const Fixed64 since = Fixed64::fromInt(static_cast<std::int64_t>(world.tickCount() - world.flightTick())) * core::kTickDt;
    const Fixed64 full = world.body(slot).reaction() +
                         Fixed64::fromInt(levelOf(slot).perception_delay_ticks) * core::kTickDt;
    const Fixed64 react = full > since ? full - since : Fixed64::zero();
    const std::int32_t c = levelOf(slot).control_speed_mps;
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
    const bool on_line = off < book_.meet_the_pass.onLineM();
    const int horizon = book_.meet_the_pass.horizonTicks();
    for (int k = 1; k <= horizon; ++k) {
        pos.x += vel.x * core::kTickDt;
        pos.y += vel.y * core::kTickDt;
        vel.x = vel.x * core::kBallRollDecayPerTick;
        vel.y = vel.y * core::kBallRollDecayPerTick;
        if (math::fx_abs(pos.x) > half_x_ || math::fx_abs(pos.y) > half_y_) return false;
        if (k % 3 != 0) continue;
        if (c > 0 && vel.x * vel.x + vel.y * vel.y > cs * cs) continue;   // not yet at a pace he can hold
        if (!on_line && math::dot(Vec2{pos.x - b.pos.x, pos.y - b.pos.y}, dir) < foot) continue;
        const Fixed64 t = core::kTickDt * Fixed64::fromInt(k) - react - early;
        if (t < Fixed64::zero()) continue;
        const Fixed64 r = runToward(world, slot, pos, t);
        if (distSq(p.pos, Vec3{pos.x, pos.y, Fixed64::zero()}) <= r * r) {
            at = pos;
            return true;
        }
    }
    return false;
}

// Pass safety [Buckland] (G4.19): the PASSER runs the interceptors' own
// race — since G4.86 the very race the flight read runs on the ball in the
// air (Brain::race), on the ground pass he's about to strike: each man's
// own reaction and perception from the kick, his body's reach, our men only
// where the ball has slowed to their touch, the passer's own caution as
// `reach` m (G4.51: 1 m, 0.6 at verticality 100) on every opponent. Safe
// when one of ours is first; ties go to the defender. Two models of the
// same race disagreed: balls in behind the passer had read were 23% theirs
// by the flight read one tick after the kick (the old walk stopped at the
// spot and knew nothing of the receiver's touch).
bool Brain::passSafe(const World& world, SlotIndex passer, SlotIndex receiver,
                     const Vec2& from, const Vec2& to, Fixed64 speed, Fixed64 reach) const {
    (void)receiver;
    const Vec2 ab{to.x - from.x, to.y - from.y};
    const Fixed64 len = math::length(ab);
    if (len.raw == 0) return true;
    return raceSafe(world, passer, Vec3{from.x, from.y, Fixed64::zero()},
                    Vec3{ab.x / len * speed, ab.y / len * speed, Fixed64::zero()}, reach);
}

// A loft he's about to hit (G4.86b): the same race on the ball as the World
// launches it (core::BallFlight — up at the launch ratio, with drag, G4.87),
// out of reach until it comes down. "It flies over the block" was never
// read: read balls in behind on the ground were 5% theirs at the kick,
// lofted ones 30%.
bool Brain::loftSafe(const World& world, SlotIndex passer, const Vec2& from, const Vec2& at,
                     std::uint8_t carry_m, Fixed64 reach) const {
    const Vec2 ab{at.x - from.x, at.y - from.y};
    const Fixed64 len = math::length(ab);
    if (len.raw == 0) return true;
    const Fixed64 v = world.ballFlight().launchSpeed(Fixed64::fromInt(carry_m));
    return raceSafe(world, passer, Vec3{from.x, from.y, Fixed64::zero()},
                    Vec3{ab.x / len * v, ab.y / len * v, v * core::kLoftLaunchRatio}, reach);
}

bool Brain::raceSafe(const World& world, SlotIndex passer, const Vec3& pos, const Vec3& vel,
                     Fixed64 reach) const {
    RaceBall rb;
    rb.pos = pos;
    rb.vel = vel;
    rb.kicker = passer;
    rb.lockout = core::kKickerLockoutTicks;
    rb.ours = setup_.team_of_slot[passer];
    rb.offside = false;
    rb.opp_margin = reach > core::kBallControlRadius ? reach - core::kBallControlRadius : Fixed64::zero();
    rb.first_only = true;
    FlightRead& f = pass_race_;
    race(world, rb, f);
    const int mine = f.first[rb.ours], theirs = f.first[rb.ours ^ 1];
    return mine >= 0 && (theirs < 0 || f.tick[mine] < f.tick[theirs]);
}

const std::vector<std::uint8_t>& Brain::directOpponents(const World& world, std::uint64_t sec) const {
    if (direct_sec_ == sec && !direct_.empty()) return direct_;
    direct_sec_ = sec;
    const std::size_t n = setup_.team_of_slot.size();
    direct_.assign(n, 255);
    for (std::uint8_t team = 0; team < 2; ++team) {
        // Our markers and their outfielders, in our normalized frame.
        std::vector<std::uint8_t> ours, theirs;
        for (std::size_t s = 0; s < n; ++s) {
            const auto& p = spec_[setup_.team_of_slot[s]].positions[index_in_team_[s]];
            if (p.keeper) continue;
            if (setup_.team_of_slot[s] == team) {
                if (ratings_[s][1] > 0) ours.push_back(static_cast<std::uint8_t>(s));
            } else {
                theirs.push_back(static_cast<std::uint8_t>(s));
            }
        }
        // By position number first (James: "the 9's direct opponents are
        // the 4 and 5 and vice versa … 10:6, 7:2, 3:11, 8:8"): each marker
        // takes the nearest of the opponents his number is paired with —
        // two of ours may share one of theirs (the 4 and 5 on their 9; the
        // free man, marking 0, isn't a marker). Unnumbered slots fall back
        // to the shape matchup below.
        std::vector<bool> numbered(ours.size(), false);
        if (!direct_pairs_.empty()) {
            auto num = [&](std::uint8_t s) { return spec_[setup_.team_of_slot[s]].positions[index_in_team_[s]].number; };
            for (std::size_t i = 0; i < ours.size(); ++i) {
                const int n = num(ours[i]);
                if (n == 0) continue;
                int pick = -1;
                Fixed64 best{};
                for (const std::uint8_t o : theirs) {
                    const int m = num(o);
                    bool paired = false;
                    for (const auto& pr : direct_pairs_) paired = paired || (pr.first == n && pr.second == m);
                    if (!paired) continue;
                    const Fixed64 d = distSq(world.player(ours[i]).pos, world.player(o).pos);
                    if (pick < 0 || d < best) { pick = o; best = d; }
                }
                if (pick >= 0) { direct_[ours[i]] = static_cast<std::uint8_t>(pick); numbered[i] = true; }
            }
        }
        auto mirrored = [&](std::uint8_t o) {   // their base → our frame
            const Vec2& b = spec_[setup_.team_of_slot[o]].positions[index_in_team_[o]].base;
            return Vec2{-Fixed64::one() - b.x, -b.y};
        };
        std::vector<bool> used_o(theirs.size(), false), used_m(numbered);
        for (std::size_t j = 0; j < theirs.size(); ++j)
            for (std::size_t i = 0; i < ours.size(); ++i)
                if (numbered[i] && direct_[ours[i]] == theirs[j]) used_o[j] = true;
        for (std::size_t round = 0; round < ours.size(); ++round) {
            int bm = -1, bo = -1;
            Fixed64 best{};
            for (std::size_t i = 0; i < ours.size(); ++i) {
                if (used_m[i]) continue;
                const Vec2& mb = spec_[team].positions[index_in_team_[ours[i]]].base;
                for (std::size_t j = 0; j < theirs.size(); ++j) {
                    if (used_o[j]) continue;
                    const Vec2 t = mirrored(theirs[j]);
                    const Fixed64 d = (mb.x - t.x) * (mb.x - t.x) + (mb.y - t.y) * (mb.y - t.y);
                    if (bm < 0 || d < best) { bm = static_cast<int>(i); bo = static_cast<int>(j); best = d; }
                }
            }
            if (bm < 0) break;
            used_m[bm] = used_o[bo] = true;
            direct_[ours[bm]] = theirs[bo];
        }
    }
    return direct_;
}

// What a player can see (G4.66). The men in front of him are where they
// are; the men behind him are where they WERE at his last look over the
// shoulder — approximated linearly as pos - vel * age, like the ball's
// perception delay (no history state: brains stay pure). A man who ran in
// behind him since is still back where he started. The flight read and the
// direct-opponent pairs are shared by all 22 brains, so they are read from
// the true world first (their caches then serve every picture this tick).
const Call& Brain::callConcept(Why w, std::uint8_t team) const {
    const ConceptBook& book_ = books_[team > 1 ? 0 : team];
    switch (w) {
        case Why::CallManOn: return book_.call_man_on;
        case Why::CallTurn: return book_.call_turn;
        case Why::CallTime: return book_.call_time;
        case Why::CallSqueeze: return book_.call_squeeze;
        case Why::CallLine: return book_.call_line;
        default: return book_.call_shadow;
    }
}

// SAYING: he knows the call and his communication lets it out this second.
bool Brain::says(SlotIndex slot, const Call& c, std::uint64_t sec) const {
    const int bit = c.bit();
    if (ratings_[slot][bit] == 0 || !applies(slot, bit, sec)) return false;
    const auto n = core::detNoise(match_seed_, sec, slot, static_cast<std::uint8_t>(216 + (bit % 8)));
    return (n + Fixed64::one()) < Fixed64::fromFraction(levelOf(slot).speak_pct, 50);
}

// HEARING: in voice range of the talker, and his concentration takes it in.
bool Brain::hears(SlotIndex slot, const CallOut& c, const World& world) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    if (!c.made || c.talker < 0) return false;
    if (c.to == Orders::kBackLine ? !backLine(slot) : c.to != static_cast<int>(slot)) return false;
    const Fixed64 v = book_.vision.voice;
    if (distSq(world.player(slot).pos, world.player(static_cast<SlotIndex>(c.talker)).pos) > v * v) return false;
    const std::uint64_t sec = world.tickCount() / 30;
    const auto n = core::detNoise(match_seed_, sec, slot,
                                  static_cast<std::uint8_t>(224 + (callConcept(c.why, setup_.team_of_slot[slot]).bit() % 8)));
    return (n + Fixed64::one()) < Fixed64::fromFraction(levelOf(slot).listen_pct, 50);
}

const std::vector<Brain::CallOut>& Brain::calls(std::uint8_t team, const World& world) const {
    const ConceptBook& book_ = books_[team > 1 ? 0 : team];   // G4.76: his team's model
    const auto& b = world.ball();
    const std::int64_t key = b.pos.x.raw ^ (b.pos.y.raw << 1);
    std::vector<CallOut>& out = calls_[team & 1];
    if (calls_tick_[team & 1] == world.tickCount() && calls_key_[team & 1] == key) return out;
    calls_tick_[team & 1] = world.tickCount();
    calls_key_[team & 1] = key;
    out.clear();
    if (world.restartTeam() != 0xFF) return out;
    const std::uint64_t sec = world.tickCount() / 30;
    const Fixed64 voice = book_.vision.voice;
    const bool ours = b.owner ? world.player(*b.owner).team == team : world.lastTouchTeam() == team;
    auto add = [&](Why w, int talker, int to, int man) {
        CallOut c;
        c.why = w;
        c.talker = talker;
        c.to = to;
        c.man = man;
        c.made = says(static_cast<SlotIndex>(talker), callConcept(w, team), sec);
        out.push_back(c);
    };
    if (ours) {
        // Man on / turn / time: about our man on the ball, or the one the
        // pass is going to.
        int T = b.owner ? static_cast<int>(*b.owner) : -1;
        if (T < 0) {
            const FlightRead& fr = flightRead(world);
            if (fr.live) T = fr.first[team];
        }
        if (T < 0 || world.isKeeper(static_cast<SlotIndex>(T)) || levelOf(static_cast<SlotIndex>(T)).isZero()) return out;
        const SlotIndex t = static_cast<SlotIndex>(T);
        const auto& tp = world.player(t);
        int O = -1;
        Fixed64 od{};
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] == team) continue;
            const Fixed64 d = distSq(world.player(j).pos, tp.pos);
            if (O < 0 || d < od) { O = j; od = d; }
        }
        if (O < 0) return out;
        const SlotIndex o = static_cast<SlotIndex>(O);
        Why w = Why::Hold;
        const Fixed64 near = book_.call_man_on.reach();
        if (od <= near * near && !inView(t, world, o)) {
            w = Why::CallManOn;
        } else {
            const Fixed64 free = book_.call_turn.reach();
            if (od > free * free && lookAge(t, world) > book_.vision.blind_pass_ticks) {
                const Fixed64 dsgn = attackSign(t) >= 0 ? Fixed64::one() : -Fixed64::one();
                w = tp.face.x * dsgn < Fixed64::zero() ? Why::CallTurn : Why::CallTime;
            }
        }
        if (w == Why::Hold) return out;
        // The talker: the nearest mate in voice range who can see him (and,
        // for man on, the man).
        int F = -1;
        Fixed64 fd{};
        for (SlotIndex f = 0; f < world.playerCount(); ++f) {
            if (setup_.team_of_slot[f] != team || f == t) continue;
            const Fixed64 d = distSq(world.player(f).pos, tp.pos);
            if (d > voice * voice || !inView(f, world, t)) continue;
            if (w == Why::CallManOn && !inView(f, world, o)) continue;
            if (F < 0 || d < fd) { F = f; fd = d; }
        }
        if (F >= 0) add(w, F, T, w == Why::CallManOn ? O : -1);
        return out;
    }

    // Their ball. Adjust your shadow (172, G4.70): the full-back playing off
    // sees their winger; our winger shadowing the line has him behind him.
    {
        const Trap tr = trapRead(world, team, Vec2{b.pos.x, b.pos.y});
        if (tr.winger >= 0 && ratings_[tr.winger][book_.shadow_line.bit()] > 0) {
            const SlotIndex w = static_cast<SlotIndex>(tr.winger);
            const int sign = attackSign(w);
            const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
            const int M = b.pos.x * dsgn < book_.pack_middle.fromHalfway()
                              ? -1 : theirWinger(world, team, sign, tr.carrier, tr.cbs);
            if (M >= 0) {
                const SlotIndex m = static_cast<SlotIndex>(M);
                const auto& direct = directOpponents(world, sec);
                const int po = book_.play_off.bit();
                for (SlotIndex f = 0; f < world.playerCount(); ++f) {
                    if (setup_.team_of_slot[f] != team || f == w || direct[f] != m || ratings_[f][po] == 0) continue;
                    if (!levelOf(w).isZero() && !inView(w, world, m) && inView(f, world, m))
                        add(Why::CallShadow, f, w, M);
                    break;
                }
            }
        }
    }
    // Squeeze / line (176/177): the keeper organises the back line.
    int K = -1;
    for (SlotIndex k = 0; k < world.playerCount(); ++k)
        if (setup_.team_of_slot[k] == team && world.isKeeper(k)) { K = k; break; }
    if (K < 0) return out;
    const SlotIndex k = static_cast<SlotIndex>(K);
    const int sign = attackSign(k);
    const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    ConceptContext cx{world, k, sign, Vec2{b.pos.x, b.pos.y}, half_x_, degree(k, 28)};
    if (!b.owner) {
        const FlightRead& fr = flightRead(world);
        const int a0 = fr.first[0], a1 = fr.first[1];
        const int win = a0 < 0 ? a1 : (a1 < 0 || fr.tick[a0] <= fr.tick[a1] ? a0 : a1);
        if (win >= 0) { cx.flight_first = setup_.team_of_slot[win]; cx.flight_at = fr.at[win]; }
    }
    // The back line's height (its highest man) and anyone a metre or more
    // under a step he should take / gap_m off the line with their man
    // onside off him.
    Fixed64 top{};
    bool any = false;
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] != team || !backLine(j)) continue;
        const Fixed64 x = world.player(j).pos.x * sgn;
        if (!any || x > top) { top = x; any = true; }
    }
    if (!any) return out;
    // Who organises (G4.78) [James 10/27: "all players should communicate"]:
    // the keeper while his voice reaches the whole back line; when it's up
    // and out of his range, the back-liner who talks the most (his
    // communication), the more central on a tie.
    int O = K;
    for (SlotIndex j = 0; j < world.playerCount(); ++j)
        if (setup_.team_of_slot[j] == team && backLine(j) &&
            distSq(world.player(j).pos, world.player(k).pos) > voice * voice) { O = -1; break; }
    if (O < 0) {
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] != team || !backLine(j)) continue;
            if (O < 0) { O = j; continue; }
            const int a = levelOf(j).speak_pct, c = levelOf(static_cast<SlotIndex>(O)).speak_pct;
            if (a > c || (a == c && math::fx_abs(world.player(j).pos.y) <
                                        math::fx_abs(world.player(static_cast<SlotIndex>(O)).pos.y))) O = j;
        }
    }
    if (auto line = book_.line_step.stepLine(cx)) {
        bool under = false;
        for (SlotIndex j = 0; j < world.playerCount(); ++j)
            if (setup_.team_of_slot[j] == team && backLine(j) &&
                world.player(j).pos.x * sgn < *line - Fixed64::one()) under = true;
        if (under) add(Why::CallSqueeze, O, Orders::kBackLine, -1);
        return out;
    }
    const Fixed64 gap = book_.call_line.reach();
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] != team || !backLine(j)) continue;
        const Fixed64 x = world.player(j).pos.x * sgn;
        if (x > top - gap) continue;
        bool onside = false;   // one of theirs between him and the line
        for (SlotIndex a = 0; a < world.playerCount(); ++a) {
            if (setup_.team_of_slot[a] == team || world.isKeeper(a)) continue;
            const Fixed64 ax = world.player(a).pos.x * sgn;
            onside = onside || (ax < top && ax > x);
        }
        if (onside) { add(Why::CallLine, O, Orders::kBackLine, -1); break; }
    }
    return out;
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
        for (std::uint8_t s = 0; s < 32; ++s) {
            players_[s] = PlayerAgent{};
            players_[s].slot = s;
            players_[s].machine.init(DefendingBlock::attacking(), DefendingBlock::global(), now);
        }
    }
    think_tick_ = now;
    for (auto& a : teams_) {
        const TeamCtx c{world, setup_.team_of_slot, phase_params_, now};
        a.machine.update(a, c);
    }
    // The players (G5.21): the team's assignments, then each man's state.
    const FlightRead& fr = flightRead(world);
    for (std::uint8_t t = 0; t < 2; ++t) block_.assign(t, world, setup_.team_of_slot, fr.live ? fr.first[t] : -1, restartTaker(world, t));
    for (std::uint8_t s = 0; s < world.playerCount() && s < 32; ++s) {
        const PlayerCtx c{world, block_, teams_[setup_.team_of_slot[s] & 1], now};
        players_[s].machine.update(players_[s], c);
    }
}

Orders Brain::ordersFor(SlotIndex slot, const World& world) const {
    think(world);
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    flightRead(world);
    directOpponents(world, world.tickCount() / 30);
    const bool perfect = levelOf(slot).isZero();
    const std::int32_t age0 = perfect ? 0 : lookAge(slot, world);
    // Communication (G4.70-71): the talker carries his call on his orders;
    // a listener who hears one gets its effect — a fresher picture (one man,
    // or everyone behind him) or the back line's order.
    const std::vector<CallOut>& cs = calls(setup_.team_of_slot[slot], world);
    Why heard = Why::Hold;
    int heard_man = -1;
    std::int32_t hear_ticks = 0;
    told_squeeze_ = told_line_ = false;
    for (const CallOut& c : cs) {
        if (!hears(slot, c, world)) continue;
        heard = c.why;
        hear_ticks = static_cast<std::int32_t>((callConcept(c.why, setup_.team_of_slot[slot]).hear() * Fixed64::fromInt(core::kTickRate)).raw >>
                                               Fixed64::FRAC_BITS) + levelOf(slot).perception_delay_ticks;
        if (c.why == Why::CallSqueeze) told_squeeze_ = true;
        if (c.why == Why::CallLine) told_line_ = true;
        heard_man = c.man;
        break;
    }
    auto tag = [&](Orders& o) {
        told_squeeze_ = told_line_ = false;
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
                    if (passSafe(world, slot, o.pass_to, from, at,
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
        o.heard = heard;
        for (const CallOut& c : cs) {
            if (c.talker != static_cast<int>(slot)) continue;
            o.due = c.why;
            if (c.made) { o.call = c.why; o.call_to = static_cast<std::int16_t>(c.to); }
            break;
        }
    };
    // Turn / time: everyone behind him is as fresh as the call.
    std::int32_t age = age0;
    if ((heard == Why::CallTurn || heard == Why::CallTime) && hear_ticks < age) age = hear_ticks;
    if (age <= 0) {
        Orders o = ordersSeen(slot, world);
        brakeToArrive(slot, world, o);
        o.look_ds = perfect ? 255 : 0;
        tag(o);
        return o;
    }
    // Shadow / man on: that one man.
    const bool one_man = (heard == Why::CallShadow || heard == Why::CallManOn) && heard_man >= 0;
    // Placed back along his run by at most max_age_s: the linear picture
    // means nothing over long ages (the look itself can be older).
    const std::int32_t reach = age < book_.vision.max_age_ticks ? age : book_.vision.max_age_ticks;
    const Fixed64 back = Fixed64::fromInt(reach) * core::kTickDt;
    World seen = world;
    std::uint8_t unseen = 0;
    // On the ball, a mate he can't see is no pass — unless he looked just
    // now (he doesn't play a ball blind to where a man used to be).
    const bool carrier = world.ball().owner && *world.ball().owner == slot;
    const bool stale = age > book_.vision.blind_pass_ticks;
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot || inView(slot, world, i)) continue;
        const auto& p = world.player(i);
        Fixed64 bk = back;
        if (one_man && static_cast<int>(i) == heard_man && hear_ticks < reach)
            bk = Fixed64::fromInt(hear_ticks) * core::kTickDt;
        seen.seePlayerAt(i, Vec3{p.pos.x - p.vel.x * bk, p.pos.y - p.vel.y * bk, p.pos.z});
        ++unseen;
        if (carrier && stale && i < 64 && setup_.team_of_slot[i] == setup_.team_of_slot[slot])
            blind_ |= std::uint64_t{1} << i;
    }
    Orders o = ordersSeen(slot, seen);
    brakeToArrive(slot, world, o);
    blind_ = 0;
    o.look_ds = static_cast<std::uint8_t>(age / 3 > 254 ? 254 : age / 3);
    o.unseen = unseen;
    tag(o);
    return o;
}

std::int32_t Brain::lookAge(SlotIndex slot, const World& world) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& ball = world.ball();
    const std::uint8_t team = setup_.team_of_slot[slot];
    const bool ours = ball.owner ? world.player(*ball.owner).team == team
                                 : world.lastTouchTeam() == team;
    const Scanning& scan = ours ? static_cast<const Scanning&>(book_.scan_receive)
                                : static_cast<const Scanning&>(book_.scan_defend);
    const int bit = scan.bit();
    const std::uint8_t r = ratings_[slot][bit];
    // 0 = he never looks: as old as a picture gets (a minute).
    constexpr std::int32_t kNever = 60 * core::kTickRate;
    if (r == 0) return kNever;
    const std::uint64_t tick = world.tickCount();
    // The pass is coming to me: a look while it travels (scan before you
    // receive) — rolled per half second.
    if (ours && !ball.owner && world.restartTeam() == 0xFF) {
        const FlightRead& fr = flightRead(world);
        if (fr.first[team] == slot && applies(slot, bit, tick / 15)) return 0;
    }
    // Otherwise a look every so often, each one rolled; his own rhythm
    // (phase) so 22 heads don't turn on the same tick.
    const std::int32_t every = scan.everyTicks(r);
    const auto n = core::detNoise(match_seed_, 0, slot, 250);
    const std::uint64_t phase =
        static_cast<std::uint64_t>((((n + Fixed64::one()) * every) / 2).raw >> Fixed64::FRAC_BITS);
    const std::uint64_t t = tick + phase;
    std::int32_t age = static_cast<std::int32_t>(t % static_cast<std::uint64_t>(every));
    if (!applies(slot, bit, t / static_cast<std::uint64_t>(every))) age += every;   // skipped that one
    return age;
}

bool Brain::inView(SlotIndex slot, const World& world, SlotIndex other) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& me = world.player(slot);
    const auto& him = world.player(other);
    const Vec2 d{him.pos.x - me.pos.x, him.pos.y - me.pos.y};
    const Fixed64 dd = math::lengthSquared(d);
    const Fixed64 feel = book_.vision.feel;
    if (dd <= feel * feel) return true;
    const Fixed64 dp = math::dot(me.face, d);
    const Fixed64 c = book_.vision.cos_half;
    // dp >= c·|face|·|d|, squared to stay off the square root.
    const Fixed64 rhs = c * c * math::lengthSquared(me.face) * dd;
    if (c.raw >= 0) return dp.raw >= 0 && dp * dp >= rhs;
    return dp.raw >= 0 || dp * dp <= rhs;
}

// The taker (G5.2): the keeper for his goal kick; the man whose restart mark
// is on the ball (a corner's shape names him); else the nearest outfielder.
int Brain::restartTaker(const World& world, std::uint8_t team) const {
    const Vec3& sp = world.restartSpot();
    if (world.restartKind() == core::MatchEventType::GoalKick) {
        for (SlotIndex i = 0; i < world.playerCount(); ++i)
            if (setup_.team_of_slot[i] == team && world.isKeeper(i)) return i;
    }
    if (hold_team_ == team)
        for (const auto& [s, mark] : hold_)
            if (setup_.team_of_slot[s] == team &&
                distSq(Vec3{mark.x, mark.y, Fixed64::zero()}, sp) < Fixed64::fromInt(9))
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
        // Goal kick: the keeper's own ball (his concepts choose it, G4.58);
        // he doesn't stand on it for ever if they find nothing.
        out = decide(slot, world);
        const std::uint64_t waited = world.tickCount() - world.ownedAtTick();
        if (out.action == Action::None && waited >= static_cast<std::uint64_t>(restart_play_.keeper_wait_ticks)) {
            const Fixed64 sg = setup_.team_of_slot[slot] == 0 ? Fixed64::one() : -Fixed64::one();
            const Vec2 target{me.pos.x + sg * restart_play_.keeper_long_m, me.pos.y};
            out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            out.action = Action::LoftedKick;
            out.carry_m = aimedCarry(me.pos, target, rangeFor(world.levelOf(slot), restart_play_.keeper_long_m));
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

// Law 15 (G5.2): a throw goes to a mate within an arm's range, on the mate
// with the most room and a bit of ground gained; he waits for one to come
// free, as long as a thrower can. Pro: 82% complete, median 15 m (StatsBomb
// PL 2015/16 sample, mig 922).
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
        if (!loftSafe(world, slot, from, at, carry, Fixed64::fromFraction(1, 2))) score -= restart_play_.throw_room_m;
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

// Law 17 (G5.2): delivered into the box, on the freest man attacking it,
// else the penalty spot. Pro: median 34 m, 42% complete, 31% a shot within
// 10 s (StatsBomb PL 2015/16 sample, mig 922).
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
    out.carry_m = aimedCarry(me.pos, at, rangeFor(world.levelOf(slot), Fixed64::fromInt(60)));
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

Orders Brain::ordersSeen(SlotIndex slot, const World& world) const {
    Orders o = ordersFaced(slot, world);
    keepLawDistance(slot, world, o);
    // Their goal kick (Law 16): every one of us stays outside their penalty
    // area until the ball is kicked — the man-marker picks his CB up on the
    // 18, not goal-side of him in the box. Whoever's in it walks out.
    if (world.boxClearTeam() != setup_.team_of_slot[slot] || world.isKeeper(slot)) return o;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    const Fixed64 end = ball.pos.x.raw < 0 ? -Fixed64::one() : Fixed64::one();   // the kicker's goal
    const Fixed64 line = half_x_ - Fixed64::fromFraction(35, 2);                 // 16.5 m + a metre
    const Fixed64 box_y = Fixed64::fromFraction(2116, 100);                      // 20.16 m + a metre
    auto inside = [&](const Vec2& p) { return p.x * end > line && math::fx_abs(p.y) < box_y; };
    const bool aimed = o.target.x.raw != 0 || o.target.y.raw != 0;
    Vec2 t = aimed ? o.target : Vec2{me.pos.x, me.pos.y};
    if (!inside(t) && !inside(Vec2{me.pos.x, me.pos.y})) return o;
    if (inside(t)) t.x = line * end;
    o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
    o.target = t;
    return o;
}

// Brake to arrive (G4.80). seek() ramps the wish down only inside its
// arrive radius (1.5 m, sized when the World moved at |desire| × top in
// one tick); with momentum (G4.51) and real top speeds (G4.79) a man at
// 8.4 m/s needs ~8 m to stop, so every run ran PAST its spot and came back
// — James 10/27: "guys are just over running the ball and look like they
// are on skates". The arrival law [Reynolds 1999, "arrive"; FH: on the
// player's own stopping distance]: he runs no faster than he can still
// slow from, v ≤ √(v_end² + 2·b·d), b = arrive_decel (a hard but
// comfortable deceleration — soccer high-intensity decelerations run past
// −3 m/s², maxima −5 to −8 [Harper, Carling & Kiely 2019]). v_end = 0 to a
// spot; arrive_through to a ball he's running onto (he meets it moving,
// under control). Runs beyond the line keep going — that's their point.
void Brain::brakeToArrive(SlotIndex slot, const World& world, Orders& o) const {
    switch (o.why) {
        case Why::RunInBehind: case Why::BlindSideRun: case Why::KeepRunning:
        case Why::GiveAndGo: case Why::Human: case Why::Tackle: case Why::KeeperDive:
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
        case Why::Chase: case Why::MeetPass: case Why::CounterPress: case Why::Press:
        case Why::Intercept: case Why::JumpPass: case Why::PressBadTouch: case Why::HurryKeeper:
        case Why::AttackDrop: case Why::RunBackDrop: case Why::KeeperSweep:
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
        const Fixed64 sg = attackSign(slot) >= 0 ? Fixed64::one() : -Fixed64::one();
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
    if (defend_max_.raw > 0 && defend_max_ < v_ok) {
        switch (o.why) {
            case Why::Recover: case Why::Mark: case Why::MarkTight: case Why::ProtectMiddle:
                v_ok = defend_max_;
                break;
            default: break;
        }
    }
    // A race to a MOVING ball (G4.84): arrive ON TIME, not just under
    // control. His target is where the flight read says he and the ball
    // meet, fr.tick ticks from now — so he runs at least dist / that time
    // (+10%). Braked on distance alone he was late, the next read picked a
    // nearer, later point, he braked again: receivers stood and waited (5.2
    // → 1.4 m/s traced) while the defender the read had beaten stepped in
    // front — 53% of the passes cut out were OURS by the read at the kick.
    // Not braking at all ran him past the spot before the ball came.
    switch (o.why) {
        case Why::MeetPass: case Why::Intercept: case Why::JumpPass: case Why::Chase: {
            if (world.ball().owner || world.restartTeam() != 0xFF) break;
            const FlightRead& fr = flightRead(world);
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

// Defend the cross (125, G5.9, §8.107) [coaching: "win the box on crosses" —
// the back line drops in, near post owned, everyone goal-side]: their ball
// wide (|y| 14 m+) within within_m of our goal line, a back-line man (base at
// or behind -55%) whose job isn't the ball (press, tackle, jockey, delay)
// stands no further than depth_m off our line and width_m off the middle.
// Real (DFL tracking, ball wide inside 18 m): 4.0 defenders in the box, the
// deepest 9.1 m and the next 11.0 m off the line; the game had 2.4. No row = off.
void Brain::defendTheCross(SlotIndex slot, const World& world, Orders& o) const {
    if (dtc_within_.raw <= 0) return;
    const auto& b = world.ball();
    const std::uint8_t team = setup_.team_of_slot[slot];
    if (!b.owner || setup_.team_of_slot[*b.owner] == team || world.restartTeam() != 0xFF) return;
    const FormationSpec::Pos& mine = spec_[team].positions[index_in_team_[slot]];
    if (mine.keeper || mine.base.x > Fixed64::fromFraction(-55, 100)) return;
    switch (o.why) {
        case Why::Press: case Why::Tackle: case Why::SideOn: case Why::Delay: case Why::Contain:
        case Why::CounterPress: case Why::Chase: case Why::DropStep: case Why::Intercept: case Why::JumpPass:
            return;
        default: break;
    }
    const Fixed64 sg = attackSign(slot) >= 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 from_line = b.pos.x * sg + half_x_;
    if (from_line >= dtc_within_ || math::fx_abs(b.pos.y) < Fixed64::fromInt(14)) return;
    Vec2 t = (o.target.x.raw != 0 || o.target.y.raw != 0) ? o.target : Vec2{world.player(slot).pos.x, world.player(slot).pos.y};
    const Fixed64 cap_x = -half_x_ + dtc_depth_;   // in our frame
    bool moved = false;
    if (t.x * sg > cap_x) { t.x = cap_x * sg; moved = true; }
    if (t.y > dtc_width_) { t.y = dtc_width_; moved = true; }
    if (t.y < -dtc_width_) { t.y = -dtc_width_; moved = true; }
    if (!moved) return;
    o.move.move = seek(world.player(slot).pos, t, Fixed64::fromFraction(1, 2));
    o.target = t;
}

void Brain::stayOnside(SlotIndex slot, const World& world, Orders& o) const {
    const ConceptBook& book_ = bookOf(slot);
    const auto& ball = world.ball();
    if (world.restartTeam() != 0xFF || world.isKeeper(slot)) return;
    const std::uint8_t team = setup_.team_of_slot[slot];
    if (ball.owner) {
        if (*ball.owner == slot || setup_.team_of_slot[*ball.owner] != team) return;
    } else {
        // Our ball in flight too (G4.91): the next pass is the one he'll be
        // judged on. Traced: offside men at a kick were running ON at 8 m/s
        // while our pass travelled ("keep running"), 11-24 m past the line.
        // The man it's for, and the man going for it, chase it.
        if (world.lastTouchTeam() != team || ball.pass_to == slot) return;
        switch (o.why) {
            case Why::MeetPass: case Why::Chase: case Why::JumpPass: case Why::WaitPass:
            case Why::AttackDrop: case Why::RunBackDrop:
                return;
            default: break;
        }
    }
    const int bit = book_.stay_onside.bit();
    if (ratings_[slot][bit] == 0 || !applies(slot, bit, world.tickCount() / 30)) return;
    const Fixed64 sg = attackSign(slot) >= 0 ? Fixed64::one() : -Fixed64::one();
    // The law's line as he sees it: their second-last man (keeper counts),
    // the ball, halfway — and margin_m short of it.
    Fixed64 d1 = Fixed64::fromInt(-1000), d2 = d1;
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] == team) continue;
        const Fixed64 x = world.player(j).pos.x * sg;
        if (x > d1) { d2 = d1; d1 = x; } else if (x > d2) d2 = x;
    }
    Fixed64 line = d2;
    if (ball.pos.x * sg > line) line = ball.pos.x * sg;
    if (line < Fixed64::zero()) line = Fixed64::zero();
    const Fixed64 hold = line - book_.stay_onside.margin();
    const auto& me = world.player(slot);
    const bool has_target = o.target.x.raw != 0 || o.target.y.raw != 0;
    const bool target_past = has_target && o.target.x * sg > hold;
    const bool me_past = me.pos.x * sg > hold;
    // A target already onside is him on his way back: leave it.
    if (!target_past && !(me_past && !has_target)) return;
    Vec2 t = (o.target.x.raw != 0 || o.target.y.raw != 0) ? o.target : Vec2{me.pos.x, me.pos.y};
    if (t.x * sg > hold) t.x = hold * sg;
    o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
    o.target = t;
    if (me_past) o.why = Why::StayOnside;   // coming back: the job is the line now
}

// G5.14 (§8.111): the ball a side in possession shifts its shape on — an
// exponential smoothing of the ball over ours_ball_tau (x, y), stepped once
// a tick, restarted on the ball after any gap (a new match, a tick skipped).
// Coaching: the team moves with the play, not with every pass [FH]; the
// smoothing is fitted on DFL tracking (§8.111). Off (tau 0) = the ball.
math::Vec2 Brain::shapeBall(std::uint8_t team, const World& world) const {
    const auto& b = world.ball().pos;
    const std::uint64_t now = world.tickCount();
    Vec2& e = shape_ball_[team & 1];
    std::uint64_t& last = shape_ball_tick_[team & 1];
    if (last == now) return e;
    if (last == ~0ull || now < last || now - last > 3) {
        e = Vec2{b.x, b.y};
    } else {
        const Fixed64 dt = Fixed64::fromInt(static_cast<std::int64_t>(now - last)) * core::kTickDt;
        auto step = [&](Fixed64 v, Fixed64 to, Fixed64 tau) {
            if (tau.raw <= 0) return to;
            Fixed64 al = dt / tau;
            if (al > Fixed64::one()) al = Fixed64::one();
            return v + (to - v) * al;
        };
        e.x = step(e.x, b.x, ours_ball_tau_x_);
        e.y = step(e.y, b.y, ours_ball_tau_y_);
    }
    last = now;
    return e;
}

math::Vec2 Brain::shapeAnchor(SlotIndex slot, const World& world) const {
    const FormationSpec::Pos& mine =
        spec_[setup_.team_of_slot[slot]].positions[index_in_team_[slot]];
    Vec2 a = anchorFor(mine.base, attackSign(slot), world.ball().pos, half_x_, half_y_, mine.keeper);
    const auto& b = world.ball();
    if (!mine.keeper && b.owner && setup_.team_of_slot[*b.owner] == setup_.team_of_slot[slot]) {
        const Vec2 sb = (ours_ball_tau_x_.raw > 0 || ours_ball_tau_y_.raw > 0)
                            ? shapeBall(setup_.team_of_slot[slot], world) : Vec2{b.pos.x, b.pos.y};
        a.x = possessionX(slot, sb.x);
        a.y = possessionY(mine.base, sb.y, a.y);
    } else if (!mine.keeper && b.owner) {
        a.y = defendingY(mine.base, b.pos.y, a.y);
    }
    return a;
}

// The block moves up with its own ball (G4.80). A formation's bases are
// its KICK-OFF shape, drawn in our own half (4-3-3: centre-backs 43 m from
// halfway, the 9 at 16 m), and anchorFor slides them only 25% of the
// ball's x, capped at 14 m — a defending block's slide (the line and
// compactness rules below set where a defending team stands). With the ball
// nothing else moved the shape: an attack on their 18 had our 9 on
// halfway and our wingers 15-30 m behind it, and the kids' swarm pull was
// all that brought a semi-pro side up (shape pull 0 since G4.80). In
// possession now the shape keeps its lines' spacing, stretched depth_k
// round the team's middle, and the middle stands at slope × the ball's x
// + offset_m (attack direction) [FH; team centroids move in phase with
// the ball — Frencken, Lemmink, Delleman & Visscher 2011]: ball on their
// 18 → centre-backs about halfway, the front three on their line; ball on
// our 18 → centre-backs at our box, the 9 near halfway; ~38 m from back
// line to front.
Fixed64 Brain::possessionX(SlotIndex slot, Fixed64 ball_x) const {
    const std::uint8_t team = setup_.team_of_slot[slot];
    const auto& ps = spec_[team].positions;
    Fixed64 sum = Fixed64::zero();
    int n = 0;
    for (const auto& q : ps)
        if (!q.keeper) { sum += q.base.x; ++n; }
    const Fixed64 middle = n ? sum / Fixed64::fromInt(n) : Fixed64::zero();
    const Fixed64 sg = attackSign(slot) >= 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 base = ps[index_in_team_[slot]].base.x;
    Fixed64 x = ball_x * sg * shape_slope_ + shape_offset_ + (base - middle) * half_x_ * shape_depth_;
    {   // G5.14: the line's own push in possession
        const int num = numberOf(slot);
        const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : -1;
        if (r >= 0) x += ours_push_[r];
    }
    const Fixed64 lim = half_x_ - Fixed64::fromInt(3);
    if (x > lim) x = lim;
    if (x < -lim) x = -lim;
    return x * sg;
}

Orders Brain::ordersFaced(SlotIndex slot, const World& world) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    // G5.14: the shape's smoothed ball runs every tick, in possession or not.
    if (ours_ball_tau_x_.raw > 0 || ours_ball_tau_y_.raw > 0) (void)shapeBall(setup_.team_of_slot[slot], world);
    // G5.2: the man taking a throw, goal kick or corner.
    {
        Orders t;
        if (takeRestart(slot, world, t)) return t;
    }
    // A restart shape is held until the dead ball is played (G4.58) — by
    // the taker's kick, not his reaching it (G5.2).
    if (hold_team_ != 0xFF && world.restartTeam() == hold_team_) {
        for (const auto& [s, mark] : hold_) {
            if (s != slot) continue;
            const auto& b = world.ball().pos;
            if (distSq(Vec3{mark.x, mark.y, Fixed64::zero()}, b) < Fixed64::fromInt(4)) break;   // the taker
            Orders h;
            h.move.move = seek(world.player(slot).pos, mark, Fixed64::fromFraction(1, 2));
            h.move.face = Vec2{b.x - world.player(slot).pos.x, b.y - world.player(slot).pos.y};
            h.why = Why::Hold;
            h.target = mark;
            return h;
        }
    }
    Orders o = decide(slot, world);
    restDefense(slot, world, o);
    unmark(slot, world, o);
    stayOnside(slot, world, o);
    defendTheCross(slot, world, o);
    if (o.move.face.x.raw != 0 || o.move.face.y.raw != 0) return o;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    if (ball.owner && *ball.owner == slot) return o;   // carriers face their carry
    const Vec2 to_ball{ball.pos.x - me.pos.x, ball.pos.y - me.pos.y};
    if (to_ball.x.raw == 0 && to_ball.y.raw == 0) return o;
    // Keepers face the ball for the set position (keeper craft, no roll) —
    // a short adjustment shuffles; a long one he turns and runs.
    const Fixed64 within = book_.face_the_play.within();
    const bool short_move =
        distSq(me.pos, Vec3{o.target.x, o.target.y, Fixed64::zero()}) <= within * within;
    if (world.isKeeper(slot)) { if (short_move) o.move.face = to_ball; return o; }
    switch (o.why) {
        case Why::RunInBehind: case Why::BlindSideRun: case Why::KeepRunning:
        case Why::MeetPass: case Why::Chase: case Why::Press: case Why::Recover:
        case Why::Human: case Why::DropStep: case Why::JumpPass: case Why::TrackRunner:
            return o;   // these face where they're going
        default: break;
    }
    const int bit = book_.face_the_play.bit();
    if (ratings_[slot][bit] <= 0 || !applies(slot, bit, world.tickCount() / 30)) return o;
    if (!short_move) return o;
    o.move.face = to_ball;
    return o;
}

// rest-defense (70, G5.0): preventive marking. Our ball, a man this model
// keeps behind it holding his job: once the ball is past his direct
// opponent he stands goal-side of him on his line to our goal; before that
// he keeps his job. A full-back is never wider than his man (55), lapse or
// not. The men
// the model sends on get no demand: of those, an 8 or 10 fills the wide
// channel on the ball's side when nobody holds it. Which way they unmark is
// the read in unmark() (open-closed-ball, 185).
void Brain::restDefense(SlotIndex slot, const World& world, Orders& o) const {
    const ConceptBook& book_ = bookOf(slot);
    const auto& R = book_.rest_defense;
    if (R.gap().raw <= 0) return;
    const auto& ball = world.ball();
    if ((ball.owner && *ball.owner == slot) || world.isKeeper(slot) || world.restartTeam() != 0xFF) return;
    // Our ball includes our pass in flight: a rule that stops while it
    // travels walks the full-back back out on every pass.
    const std::uint8_t team = setup_.team_of_slot[slot];
    const bool ours = ball.owner ? setup_.team_of_slot[*ball.owner] == team : world.lastTouchTeam() == team;
    if (!ours) return;
    if (o.why != Why::Hold && o.why != Why::Support && o.why != Why::Outlet) return;
    const std::uint64_t sec = world.tickCount() / 30;
    const auto& me = world.player(slot);
    const int num = numberOf(slot);
    if (ratings_[slot][R.bit()] <= 0) {
        if ((num != 8 && num != 10) || ratings_[slot][13] <= 0) return;
        const Fixed64 side = ball.pos.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
        if (me.pos.y * side <= Fixed64::zero() || !applies(slot, 13, sec)) return;
        const Fixed64 channel = half_y_ - R.wingBand();
        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
            if (i == slot || setup_.team_of_slot[i] != team) continue;
            const auto& p = world.player(i).pos;
            if (p.y * side >= channel && math::fx_abs(p.x - me.pos.x) <= R.reach()) return;
        }
        const Vec2 t{o.target.x, side * (half_y_ - R.wide())};
        o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
        o.target = t;
        o.why = Why::PopOut;
        return;
    }
    const std::uint8_t direct = directOpponents(world, sec)[slot];
    if (direct == 255) return;
    const auto& man = world.player(direct).pos;
    const Fixed64 sgn = attackSign(slot) >= 0 ? Fixed64::one() : -Fixed64::one();
    Vec2 t = o.target;
    // Read once a possession, or a lapse walks him out and back every second.
    const bool past = (ball.pos.x - man.x) * sgn >= Fixed64::zero() &&
                      applies(slot, R.bit(), world.turnoverTick());
    if (past) {
        const Vec2 to_goal{-sgn * half_x_ - man.x, -man.y};
        const Fixed64 len = math::length(to_goal);
        if (len.raw > 0) t = Vec2{man.x + to_goal.x * R.gap() / len, man.y + to_goal.y * R.gap() / len};
    }
    const auto& I = book_.inverted_fullback;
    if ((num == 2 || num == 3) && ratings_[slot][I.bit()] > 0) {
        const Fixed64 side = man.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
        Fixed64 lim = man.y * side - I.inside();
        if (lim.raw < 0) lim = Fixed64::zero();
        if (t.y * side > lim) t.y = side * lim;
    }
    if (t.x == o.target.x && t.y == o.target.y) return;
    o.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
    o.target = t;
    if (past) { o.why = Why::PreventiveMark; o.other = static_cast<std::int16_t>(direct); }
}

// lose-your-marker (159, G4.57): our ball, he's off it holding his job
// (shape / support / outlet) with an opponent tight on him → step to the
// spot, of 8 around him, furthest from every opponent, within the leash of
// where his job wants him.
void Brain::unmark(SlotIndex slot, const World& world, Orders& o) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& ball = world.ball();
    if (!ball.owner || *ball.owner == slot || world.isKeeper(slot) || world.restartTeam() != 0xFF) return;
    const std::uint8_t team = setup_.team_of_slot[slot];
    if (setup_.team_of_slot[*ball.owner] != team) return;
    if (o.why != Why::Hold && o.why != Why::Support && o.why != Why::Outlet) return;
    const int bit = book_.lose_your_marker.bit();
    if (ratings_[slot][bit] <= 0) return;
    const auto& L = book_.lose_your_marker;
    const auto& me = world.player(slot);
    auto nearest = [&](const Vec2& at) {
        Fixed64 best = Fixed64::fromInt(1000);
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] == team) continue;
            const Fixed64 d2 = distSq(world.player(j).pos, Vec3{at.x, at.y, Fixed64::zero()});
            if (d2 < best) best = d2;
        }
        return best;
    };
    const Vec2 here{me.pos.x, me.pos.y};
    if (nearest(here) > L.tight() * L.tight()) return;
    if (!applies(slot, bit, world.tickCount() / 30)) return;
    static const Fixed64 k = Fixed64::fromFraction(7071, 10000);
    const Vec2 dirs[8] = {{Fixed64::one(), {}}, {-Fixed64::one(), {}}, {{}, Fixed64::one()}, {{}, -Fixed64::one()},
                          {k, k}, {k, -k}, {-k, k}, {-k, -k}};
    // G5.0 preventive marking: the front five go forward, sideways, then
    // back; the 7 and 11 keep the width; a full-back never goes wider than
    // his man (rest-defense, inverted-fullback).
    const auto& R = book_.rest_defense;
    const bool preventive = R.gap().raw > 0;
    const bool forward_first = preventive && ratings_[slot][R.bit()] <= 0;
    const int num = numberOf(slot);
    const bool winger = preventive && (num == 7 || num == 11);
    const Fixed64 sgn = attackSign(slot) >= 0 ? Fixed64::one() : -Fixed64::one();
    Fixed64 fb_lim = half_y_;
    Fixed64 fb_side = Fixed64::zero();
    if (preventive && (num == 2 || num == 3) && ratings_[slot][book_.inverted_fullback.bit()] > 0) {
        const std::uint8_t direct = directOpponents(world, world.tickCount() / 30)[slot];
        if (direct != 255) {
            const Fixed64 man_y = world.player(direct).pos.y;
            fb_side = man_y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
            fb_lim = man_y * fb_side - book_.inverted_fullback.inside();
            if (fb_lim.raw < 0) fb_lim = Fixed64::zero();
        }
    }
    // open-closed-ball (185): a closed ball turns his order round — toward
    // the man on it first. Lapse or never taught: he goes forward anyway.
    bool closed = false;
    Vec2 to_ball{};
    if (forward_first) {
        const auto& C = book_.open_closed;
        const auto& carrier = world.player(*ball.owner);
        const Vec2 at{carrier.pos.x, carrier.pos.y};
        if (ratings_[slot][C.bit()] > 0 && applies(slot, C.bit(), world.tickCount() / 30))
            closed = nearest(at) <= C.pressure() * C.pressure() || carrier.face.x * sgn < Fixed64::zero();
        to_ball = Vec2{carrier.pos.x - here.x, carrier.pos.y - here.y};
    }
    // wide_first (a model's choice, the Ukies): the 2 and 3 look for the
    // touchline first, the other way round from preventive marking.
    const bool wide_first = L.wideFirst() && (num == 2 || num == 3) && !preventive;
    const Fixed64 touchline = me.pos.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
    Vec2 best = here;
    Fixed64 best_d = nearest(here);
    for (int tier = 0; tier < (forward_first ? 3 : wide_first ? 2 : 1); ++tier) {
        for (const Vec2& d : dirs) {
            if (wide_first && (d.y * touchline > Fixed64::zero() ? 0 : 1) != tier) continue;
            if (forward_first) {
                const Fixed64 ahead = closed ? dot(d, to_ball) : d.x * sgn;
                if ((ahead.raw > 0 ? 0 : ahead.raw == 0 ? 1 : 2) != tier) continue;
            }
            const Vec2 c{here.x + d.x * L.step(), here.y + d.y * L.step()};
            if (math::fx_abs(c.x) > half_x_ - Fixed64::one() || math::fx_abs(c.y) > half_y_ - Fixed64::one()) continue;
            if (distSq(Vec3{c.x, c.y, Fixed64::zero()}, Vec3{o.target.x, o.target.y, Fixed64::zero()}) > L.leash() * L.leash()) continue;
            if (winger && math::fx_abs(c.y) < half_y_ - R.wingBand() && math::fx_abs(c.y) < math::fx_abs(here.y)) continue;
            if (fb_side.raw != 0 && c.y * fb_side > fb_lim) continue;
            const Fixed64 nd = nearest(c);
            if (nd > best_d) { best_d = nd; best = c; }
        }
        if ((forward_first || wide_first) && best_d >= L.free() * L.free()) break;
    }
    if (best.x == here.x && best.y == here.y) return;
    o.move.move = seek(me.pos, best, Fixed64::fromFraction(1, 2));
    o.target = best;
    o.why = Why::Unmark;
}

// keep-it-under-pressure (161, G4.60) [James 10/26; coaching: shield, if
// you can't go forward go back]: the carrier is touch-tight with no pass
// on. Outside his own third he never hoofs it: he plays it back — the
// teammate goal-side of him within reach with an open lane, the one with
// most room — or else shields, carrying it away from the presser and back
// toward his own goal at a protecting pace. Inside his own third he may
// still play it back; failing that the old clear stands. False = the
// concept didn't apply (not touch-tight, not his, a lapse) — carry on.
bool Brain::keepIt(SlotIndex slot, const World& world, int sign, Orders& out, bool shield_own_third) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const int bit = book_.keep_it.bit();
    if (ratings_[slot][bit] <= 0) return false;
    const auto& K = book_.keep_it;
    const auto& me = world.player(slot);
    const std::uint8_t team = setup_.team_of_slot[slot];
    const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 tight = Fixed64::fromFraction(6, 5);
    int presser = -1;
    Fixed64 room_me = Fixed64::fromInt(1000);
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] == team) continue;
        const Fixed64 d2 = distSq(me.pos, world.player(j).pos);
        if (d2 < room_me) { room_me = d2; presser = j; }
    }
    if (presser < 0 || room_me >= tight * tight) return false;
    // In shooting range the boot is a shot — that's not this lesson.
    const Vec2 goal{half_x_ * sgn, Fixed64::zero()};
    const Vec2 to_goal{goal.x - me.pos.x, goal.y - me.pos.y};
    if (math::lengthSquared(to_goal) < kShootRange * kShootRange) return false;
    if (!applies(slot, bit, world.tickCount() / 30)) return false;
    // G5.13 (§8.110) [FH]: near their line, a touch-tight man mostly takes
    // his man on (real wide 18-35 m pressed: back 13%, lost 40%) — one
    // roll per spell on the ball.
    if (K.finalThirdM().raw > 0 && half_x_ - me.pos.x * sgn < K.finalThirdM()) {
        const Fixed64 u = (core::detNoise(match_seed_, world.ownedAtTick(), slot, 209) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        if (u >= K.finalThirdBackShare()) return false;
    }
    // Play it back: goal-side of him, in reach, lane open — most room.
    int best = -1;
    Fixed64 best_room{}, best_dsq{};
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot || setup_.team_of_slot[i] != team || blind(i)) continue;
        const auto& mate = world.player(i);
        if (mate.pos.x * sgn >= me.pos.x * sgn) continue;
        const Fixed64 dsq = distSq(me.pos, mate.pos);
        if (dsq < kPassMin * kPassMin || dsq > K.backPassMax() * K.backPassMax()) continue;
        // The lane starts a lane-width out: the presser at his feet is
        // what he's escaping, not what blocks the pass — only a man in the
        // way does.
        const Vec2 b{mate.pos.x, mate.pos.y};
        const Vec2 dir = math::normalized(Vec2{b.x - me.pos.x, b.y - me.pos.y});
        const Vec2 a{me.pos.x + dir.x * kLaneWidth, me.pos.y + dir.y * kLaneWidth};
        bool open = true;
        Fixed64 room = Fixed64::fromInt(1000);
        for (SlotIndex j = 0; j < world.playerCount() && open; ++j) {
            if (setup_.team_of_slot[j] == team) continue;
            const Vec2 o{world.player(j).pos.x, world.player(j).pos.y};
            if (pointSegmentDistSq(o, a, b) <= kLaneWidth * kLaneWidth) open = false;
            const Fixed64 r = distSq(world.player(j).pos, mate.pos);
            if (r < room) room = r;
        }
        if (!open) continue;
        if (best < 0 || room > best_room) { best = i; best_room = room; best_dsq = dsq; }
    }
    if (best >= 0) {
        const Vec2 to{world.player(best).pos.x, world.player(best).pos.y};
        out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
        out.action = best_dsq < kSoftPassRange * kSoftPassRange ? Action::ShortPass : Action::GroundKick;
        out.why = Why::PlayBack;
        out.target = to;
        out.other = static_cast<std::int16_t>(best);
        return true;
    }
    // In his own third the clear is still allowed (the caller's hoof).
    if (!shield_own_third && me.pos.x * sgn < -half_x_ + K.ownThird()) return false;
    // Shield and turn: away from the presser, leaning back toward our goal.
    const auto& p = world.player(static_cast<SlotIndex>(presser));
    Vec2 away{me.pos.x - p.pos.x, me.pos.y - p.pos.y};
    if (away.x.raw == 0 && away.y.raw == 0) away = Vec2{-sgn, Fixed64::zero()};
    away = math::normalized(away);
    Vec2 dir{away.x - sgn, away.y};
    if (dir.x.raw == 0 && dir.y.raw == 0) dir = away;
    dir = math::normalized(dir);
    Vec2 to{me.pos.x + dir.x * K.shieldStep(), me.pos.y + dir.y * K.shieldStep()};
    const Fixed64 lx = half_x_ - Fixed64::one(), ly = half_y_ - Fixed64::one();
    if (to.x > lx) to.x = lx;
    if (to.x < -lx) to.x = -lx;
    if (to.y > ly) to.y = ly;
    if (to.y < -ly) to.y = -ly;
    const Vec2 mv = seek(me.pos, to, Fixed64::fromFraction(1, 10));
    out.move.move = Vec2{mv.x * K.shieldSpeed(), mv.y * K.shieldSpeed()};
    out.why = Why::Shield;
    out.target = to;
    out.other = static_cast<std::int16_t>(presser);
    return true;
}

// G4.63 pressing distance (164): where `man` receives a pass from `passer`
// — he comes meet_share of his own run toward it, the ball the rest at
// pass_speed — and how far slot runs in that time less his reaction (his
// body's own law, from a standing start), plus the contact distance.
Brain::Reach Brain::pressReach(SlotIndex slot, const World& world, const Vec2& passer, SlotIndex man) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& P = book_.press_distance;
    const auto& m = world.player(man);
    const Vec2 d{passer.x - m.pos.x, passer.y - m.pos.y};
    const Fixed64 len = math::length(d);
    if (len.raw == 0) return {Vec2{m.pos.x, m.pos.y}, P.contact()};
    const Fixed64 t0 = len / P.passSpeed();
    Fixed64 come = world.body(man).reach(Fixed64::zero(), m.max_speed, t0) * P.meetShare();
    if (come > len / 2) come = len / 2;
    const Vec2 at{m.pos.x + d.x / len * come, m.pos.y + d.y / len * come};
    Fixed64 t = (len - come) / P.passSpeed() - P.reaction();
    if (t < Fixed64::zero()) t = Fixed64::zero();
    return {at, world.body(slot).reach(Fixed64::zero(), world.player(slot).max_speed, t) + P.contact()};
}

// Jump the pass (162, G4.63): their pass travelling to a man we won't beat
// to it — his defender (direct opponent, within jump_max_m; else the
// nearest teammate in pressing distance of the arrival, the chain) goes as
// the ball goes, to arrive goal-side of where it lands.
bool Brain::rung(SlotIndex slot, Rung r, Fixed64 x, std::uint64_t sec) const {
    const std::uint8_t team = setup_.team_of_slot[slot];
    const Fixed64 u = team == 0 ? x : -x;   // + = toward their goal
    const Fixed64 third = half_x_ * Fixed64::fromFraction(1, 3);
    const int zone = u < -third ? 0 : (u > third ? 2 : 1);
    const std::uint8_t w = ladder_[team & 1][zone][r];
    if (w >= 100) return true;
    if (w == 0) return false;
    const auto n = core::detNoise(match_seed_, sec, slot, static_cast<std::uint8_t>(236 + r));
    return (n + Fixed64::one()) < Fixed64::fromFraction(w, 50);
}

// Attack the drop (170, G4.69) [James 10/27: "our full back needs to be
// agressive in reading the type of pass when he is in the off coverage
// tactic. he does not 'wait' for ball to reach. he reads pass. in the air he
// chases it and trys to recive facing their goal to play forward. its bad to
// be running backwards toward own goal but that is 2nd option. but if on
// ground he does normal intercept, no turn, contain"]: playing off, their
// ball in the air whose first man to it is my man — go now, to face_up_m
// past where I can first take it along its path, so it comes onto me facing
// their goal; if that's back toward our goal, run back for it (second
// option). He goes whether or not he wins the race. On the ground: the 3
// rules (jumpThePass).
bool Brain::attackTheDrop(SlotIndex slot, const World& world, int sign, Orders& out) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& b = world.ball();
    const std::uint8_t my_team = setup_.team_of_slot[slot];
    if (b.owner || world.restartTeam() != 0xFF || world.lastTouchTeam() == my_team) return false;
    const int po = book_.play_off.bit();
    if (ratings_[slot][po] == 0 || world.isKeeper(slot)) return false;
    if (!(b.pos.z > core::kBallControlRadius || b.vel.z.raw > 0)) return false;   // on the ground
    const FlightRead& fr = flightRead(world);
    if (!fr.live) return false;
    const int rcv = fr.first[1 - my_team];
    if (rcv < 0) return false;
    const std::uint64_t sec = world.tickCount() / 30;
    if (directOpponents(world, sec)[slot] != rcv || !applies(slot, po, sec)) return false;
    // Where I take it: my own first point on its flight, else his.
    const bool reach = fr.tick[slot] >= 0;
    const Vec2 at = reach ? fr.at[slot] : fr.at[rcv];
    const Vec2 path = math::normalized(Vec2{b.vel.x, b.vel.y});
    const Fixed64 f = book_.play_off.faceUp();
    const Vec2 target{at.x + path.x * f, at.y + path.y * f};
    const auto& me = world.player(slot);
    const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
    out.why = target.x * dsgn < me.pos.x * dsgn - Fixed64::one() ? Why::RunBackDrop : Why::AttackDrop;
    out.target = target;
    out.other = static_cast<std::int16_t>(rcv);
    return true;
}

bool Brain::jumpThePass(SlotIndex slot, const World& world, int sign, Orders& out) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& b = world.ball();
    const std::uint8_t my_team = setup_.team_of_slot[slot];
    if (b.owner || world.restartTeam() != 0xFF || world.lastTouchTeam() == my_team) return false;
    const int jb = book_.jump_pass.bit();
    if (ratings_[slot][jb] == 0 || world.isKeeper(slot)) return false;
    const FlightRead& fr = flightRead(world);
    if (!fr.live) return false;
    const int rcv = fr.first[1 - my_team];
    if (rcv < 0) return false;
    const int ours = fr.first[my_team];
    const Vec2 at = fr.at[rcv];
    const Fixed64 t_arrive = core::kTickDt * Fixed64::fromInt(fr.tick[rcv]);
    const std::uint64_t sec = world.tickCount() / 30;
    const auto& direct = directOpponents(world, sec);
    const int dm = book_.defend_man.bit();
    // We win it: the race — unless it's his own man's defender and his coach
    // doesn't go for the interception in this third (rule #1's weight): then
    // he arrives so the man can't turn instead.
    if (ours >= 0 && fr.tick[ours] <= fr.tick[rcv]) {
        const SlotIndex o = static_cast<SlotIndex>(ours);
        if (!(direct[o] == rcv && ratings_[o][dm] > 0 && applies(o, dm, sec) &&
              !rung(o, kIntercept, at.x, sec)))
            return false;
    }
    const Fixed64 jmax = book_.jump_pass.jumpMax();
    // Who goes: his own defender if he gets there in time; else the
    // nearest teammate who does, in pressing distance (the chain); else his
    // own defender from further out (within jump_max_m), late.
    const int pd = book_.press_distance.bit();
    const Vec3 at3{at.x, at.y, Fixed64::zero()};
    auto in_time = [&](SlotIndex j) {
        const Fixed64 run = runToward(world, j, at, t_arrive) + book_.press_distance.contact();
        return distSq(world.player(j).pos, at3) <= run * run;
    };
    int jumper = -1, chain = -1, late = -1;
    Fixed64 best_chain{}, best_late{};
    const Fixed64 dsgn_j = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] != my_team || world.isKeeper(j) || ratings_[j][jb] == 0) continue;
        const Fixed64 d = distSq(world.player(j).pos, at3);
        const bool mine = direct[j] == rcv;
        const bool fast = in_time(j);
        if (mine && fast) { jumper = j; break; }
        // The chain never leaves his own man free goal-side of the ball (James
        // 10/26: "that looks really bad leaving their winger wide open" — our
        // full-back jumped their full-back and their winger was free).
        const bool own_man_behind = direct[j] != 255 &&
            world.player(direct[j]).pos.x * dsgn_j < at.x * dsgn_j;
        if (fast && !own_man_behind && ratings_[j][pd] > 0 && (chain < 0 || d < best_chain)) { chain = j; best_chain = d; }
        if (mine && d <= jmax * jmax && (late < 0 || d < best_late)) { late = j; best_late = d; }
    }
    const bool is_late = jumper < 0 && chain < 0;
    if (jumper < 0) jumper = chain >= 0 ? chain : late;
    if (jumper != static_cast<int>(slot) || !applies(slot, jb, sec)) return false;
    const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    const Vec2 to_goal = math::normalized(Vec2{-dsgn * half_x_ - at.x, -at.y});
    const bool ladder = direct[slot] == rcv && ratings_[slot][dm] > 0 && applies(slot, dm, sec);
    // Defend your man (168): his own man, and he can't get there tight in
    // time — or his coach doesn't ask for it in this third — rule #3,
    // contain: arrive contain_gap_m goal-side of where it lands, don't dive
    // in late (James 10/27: "he reads the pass and player … most likely he
    // is looking at contain but depends").
    const bool contain = ladder && (is_late || !rung(slot, kNoTurn, at.x, sec));
    const Fixed64 g = contain ? book_.defend_man.containGap() : book_.jump_pass.arriveGap();
    const Vec2 target{at.x + to_goal.x * g, at.y + to_goal.y * g};
    out.move.move = seek(world.player(slot).pos, target, Fixed64::fromFraction(1, 10));
    out.why = Why::JumpPass;
    // Rule #2: in time — arrive so he can't turn.
    if (ladder) out.why = contain ? Why::Contain : Why::NoTurn;
    out.target = target;
    out.other = static_cast<std::int16_t>(rcv);
    return true;
}

// The trap's read (G4.64), shared by the pack, the press and the full-back
// who plays off: who has their ball (or who their pass reaches first), their
// centre-backs (the men our false 9's number is paired with), and — when
// that man is a full-back (wide and not a centre-back, or a winger's direct
// opponent) — our nearer winger, the one who goes.
Brain::Trap Brain::trapRead(const World& world, std::uint8_t my_team, const Vec2& B) const {
    const ConceptBook& book_ = books_[my_team > 1 ? 0 : my_team];   // G4.76: his team's model
    (void)B;
    Trap t;
    const auto& P = book_.pack_middle;
    const auto& ball = world.ball();
    if (ball.owner) {
        if (setup_.team_of_slot[*ball.owner] != my_team) t.carrier = *ball.owner;
    } else if (world.restartTeam() == 0xFF && world.lastTouchTeam() != my_team) {
        const FlightRead& fr = flightRead(world);
        const int a = fr.first[my_team ^ 1], u = fr.first[my_team];
        if (fr.live && a >= 0 && (u < 0 || fr.tick[a] <= fr.tick[u])) t.carrier = a;
    }
    for (SlotIndex o = 0; o < world.playerCount(); ++o) {
        if (setup_.team_of_slot[o] == my_team || world.isKeeper(o)) continue;
        const int on = numberOf(o);
        for (const auto& pr : direct_pairs_)
            if (pr.first == P.falseNine() && pr.second == on) { t.cbs.push_back(o); break; }
    }
    const int R = t.carrier;
    if (R < 0 || world.isKeeper(static_cast<SlotIndex>(R)) ||
        std::find(t.cbs.begin(), t.cbs.end(), static_cast<SlotIndex>(R)) != t.cbs.end())
        return t;
    const auto& direct = directOpponents(world, world.tickCount() / 30);
    bool full_back = math::fx_abs(world.player(static_cast<SlotIndex>(R)).pos.y) > P.centralWidth();
    Fixed64 bd{};
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] != my_team || !P.isWinger(numberOf(j))) continue;
        full_back = full_back || direct[j] == R;
        const Fixed64 d = distSq(world.player(j).pos, world.player(static_cast<SlotIndex>(R)).pos);
        if (t.winger < 0 || d < bd) { t.winger = j; bd = d; }
    }
    if (!full_back) t.winger = -1;
    return t;
}

// Their winger on the full-back's side (G4.64 tactic B, 169-170): their man
// nearest the full-back R, ahead of him (toward our goal), who isn't a
// centre-back or one of the men our midfield marks; -1 = none.
int Brain::theirWinger(const World& world, std::uint8_t my_team, int sign, int R,
                       const std::vector<SlotIndex>& cbs) const {
    const ConceptBook& book_ = books_[my_team > 1 ? 0 : my_team];   // G4.76: his team's model
    if (R < 0) return -1;
    const auto& P = book_.pack_middle;
    const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    const auto& direct = directOpponents(world, world.tickCount() / 30);
    const auto& F = world.player(static_cast<SlotIndex>(R)).pos;
    int W = -1;
    Fixed64 wd{};
    for (SlotIndex o = 0; o < world.playerCount(); ++o) {
        if (setup_.team_of_slot[o] == my_team || world.isKeeper(o) || o == R) continue;
        if (std::find(cbs.begin(), cbs.end(), o) != cbs.end()) continue;
        bool mid = false;
        for (SlotIndex j = 0; j < world.playerCount(); ++j)
            mid = mid || (setup_.team_of_slot[j] == my_team && P.isMidfield(numberOf(j)) && direct[j] == o);
        if (mid) continue;
        const auto& op = world.player(o).pos;
        if (op.x * dsgn >= F.x * dsgn) continue;   // not ahead of the full-back
        const Fixed64 d = distSq(op, F);
        if (W < 0 || d < wd) { W = o; wd = d; }
    }
    return W;
}

Orders Brain::decide(SlotIndex slot, const World& world) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    Orders out;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    const int sign = attackSign(slot);

    // Perception delay (G4.3): this brain reacts to where the ball WAS
    // delay ticks ago, approximated linearly (no history state — brains
    // stay pure). Carrier logic is exempt: the ball is at your feet.
    const core::LevelParams& lv = levelOf(slot);
    Vec3 seen_ball = ball.pos;
    if (lv.perception_delay_ticks > 0 && (!ball.owner || *ball.owner != slot)) {
        const Fixed64 back =
            Fixed64::fromInt(lv.perception_delay_ticks) * core::kTickDt;
        seen_ball = Vec3{ball.pos.x - ball.vel.x * back,
                         ball.pos.y - ball.vel.y * back,
                         ball.pos.z};
    }
    // Decision jitter (G4.3): thresholds wobble per (tick, slot).
    Fixed64 jitter = Fixed64::one();
    if (lv.decision_jitter_pct > 0) {
        jitter = Fixed64::one() +
                 core::detNoise(match_seed_, world.tickCount(), slot, 3) *
                     Fixed64::fromFraction(lv.decision_jitter_pct, 100);
    }

    // ── I have the ball: shoot in range; else look for a forward pass
    // ([Buckland]-lite: lane-checked, progress-scored); else dribble ─────
    if (ball.owner && *ball.owner == slot) {
        const bool im_keeper = world.isKeeper(slot);
        const Vec2 goal{sign >= 0 ? half_x_ : -half_x_, Fixed64::zero()};
        const Vec2 to_goal{goal.x - me.pos.x, goal.y - me.pos.y};
        // Am I pressed? (Pass eagerness rises under pressure.)
        bool pressed = false;
        for (SlotIndex i = 0; i < world.playerCount() && !pressed; ++i) {
            if (setup_.team_of_slot[i] == setup_.team_of_slot[slot]) continue;
            pressed = distSq(me.pos, world.player(i).pos) <
                      kPressureRadius * kPressureRadius;
        }
        // shot_selection (bit 25, G4.21): a selecting shooter fires on
        // CHANCE QUALITY, not range — ~17° of clear goal (~10° when
        // pressed: shoot or lose it), always inside 8 m. Range-only
        // shooting fired the first tick a carrier entered 22 m: world
        // matches measured ~259 shots against a real ~25. Kids (and
        // anyone not applying it this second) still shoot on range.
        bool shoot_now =
            !im_keeper &&
            math::lengthSquared(to_goal) < kShootRange * kShootRange;
        // G5.4 (§8.102): where the real rates are loaded, the choice is the
        // rate a pro shoots from this spot, pressed or not. One roll per
        // spot per 3 s, so holding it there isn't a fresh chance every tick
        // (real time on the ball is ~1.5-3 s). No range fallback: a man who
        // loses the roll passes or carries like anybody else [FH roll;
        // rates StatsBomb PL 2015/16].
        const bool measured_shot = book_.shot_selection.measured();
        if (measured_shot) {
            shoot_now = false;
            if (!im_keeper) {
                const auto& sel = book_.shot_selection;
                const Fixed64 d = math::length(to_goal);
                const Fixed64 wide_limit = Fixed64::fromFraction(1416, 100);
                const bool central = to_goal.y <= wide_limit && Fixed64::zero() - to_goal.y <= wide_limit;
                const Fixed64 r = sel.rate(d, central, pressed);
                const std::uint64_t spot = static_cast<std::uint64_t>(d.raw >> (Fixed64::FRAC_BITS + 2)) * 4 +
                                           (central ? 2u : 0u) + (pressed ? 1u : 0u);
                const Fixed64 n = core::detNoise(match_seed_, (world.tickCount() / 90) * 64 + spot, slot, 200);
                shoot_now = (n + Fixed64::one()) * Fixed64::fromFraction(1, 2) < r;
            }
        }
        if (shoot_now && !measured_shot && applies(slot, 25, world.tickCount() / 30) &&
            math::lengthSquared(to_goal) >= Fixed64::fromInt(64)) {
            // G4.55: what the chance is worth (his read wobbles with his
            // decisions) against working it closer or a mate's better one.
            const auto& sel = book_.shot_selection;
            const Fixed64 mine = sel.xg(chanceQuality(world, setup_, slot, goal),
                                        math::length(to_goal), pressed) * jitter;
            shoot_now = mine >= (pressed ? sel.minPressed() : sel.minFree());
            for (SlotIndex j = 0; j < world.playerCount() && shoot_now; ++j) {
                if (j == slot || setup_.team_of_slot[j] != setup_.team_of_slot[slot] ||
                    world.isKeeper(j))
                    continue;
                const auto& m = world.player(j);
                const Vec2 mg{goal.x - m.pos.x, goal.y - m.pos.y};
                if (math::lengthSquared(mg) > kShootRange * kShootRange) continue;
                const Fixed64 theirs = sel.xg(chanceQuality(world, setup_, j, goal), math::length(mg), false);
                if (theirs < mine * sel.passBetter()) continue;
                const Vec2 from{me.pos.x, me.pos.y}, to{m.pos.x, m.pos.y};
                if (passSafe(world, slot, j, from, to,
                             core::weightedPassSpeed(math::length(Vec2{to.x - from.x, to.y - from.y})), Fixed64::one()))
                    shoot_now = false;   // pass it — the pass branch below picks the man
            }
        }
        if (shoot_now) {
            // Placement (G4.3b): aim inside the post AWAY from the
            // keeper's current side — a placed 24 m/s strike beats
            // angle-play positioning; a sprayed one doesn't (level
            // noise decides which you hit).
            Fixed64 aim_y =
                Fixed64::fromFraction(33, 10) * degree(slot, 8);
            for (SlotIndex i = 0; i < world.playerCount(); ++i) {
                if (setup_.team_of_slot[i] == setup_.team_of_slot[slot])
                    continue;
                if (!world.isKeeper(i)) continue;
                if (world.player(i).pos.y.raw > 0) aim_y = -aim_y;
                break;
            }
            out.move.move =
                seek(me.pos, Vec2{goal.x, aim_y}, kArriveRadius);
            out.action = Action::Shot;
            out.why = Why::Shoot;
            out.target = Vec2{goal.x, aim_y};
            return out;
        }

        // G5.4 (§8.102): pressed near his own goal a real defender clears it
        // (93% in the box centrally, 45% wide, 30-40% out to 35 m), rolled
        // once on the ball, hit first time up the emptier side.
        // G5.8 (§8.106): those rates were read off StatsBomb's under-pressure
        // flag, which every clearance carries; with clear-the-danger's rows
        // the roll is the 360 rate for his zone and the nearest man's
        // distance instead, for every release, still once on the ball.
        const auto& ctd = book_.clear_the_danger;
        if (!im_keeper && (pressed || ctd.measured())) {
            const Fixed64 clr_sgn = Fixed64::fromInt(sign >= 0 ? 1 : -1);
            const Fixed64 own_d = me.pos.x * clr_sgn + half_x_;
            if (own_d < Fixed64::fromInt(35) || ctd.measured()) {
                const Fixed64 wide_limit = Fixed64::fromFraction(1416, 100);
                const bool central = me.pos.y <= wide_limit && Fixed64::zero() - me.pos.y <= wide_limit;
                Fixed64 share{};
                if (ctd.measured()) {
                    Fixed64 nearest_sq = Fixed64::fromInt(10000);
                    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                        if (setup_.team_of_slot[j] == setup_.team_of_slot[slot] || world.isKeeper(j)) continue;
                        const Fixed64 d2 = distSq(me.pos, world.player(j).pos);
                        if (d2 < nearest_sq) nearest_sq = d2;
                    }
                    share = ctd.rate(ClearTheDanger::zone(own_d, math::fx_abs(me.pos.y)),
                                     ClearTheDanger::near(math::fx_sqrt(nearest_sq)));
                } else {
                    share = book_.pass_ladder.clearShare(own_d < Fixed64::fromInt(18) ? 0 : 1, central);
                }
                const Fixed64 u = (core::detNoise(match_seed_, world.ownedAtTick(), slot, 202) + Fixed64::one()) *
                                  Fixed64::fromFraction(1, 2);
                if (u < share) {
                    const Fixed64 cx = me.pos.x + clr_sgn * Fixed64::fromInt(20);
                    const Fixed64 cy = half_y_ * Fixed64::fromFraction(3, 5);
                    int crowd[2] = {0, 0};
                    const Vec2 ch[2] = {Vec2{cx, Fixed64::zero() - cy}, Vec2{cx, cy}};
                    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                        if (setup_.team_of_slot[j] == setup_.team_of_slot[slot]) continue;
                        for (int c = 0; c < 2; ++c) {
                            const Vec2 d{world.player(j).pos.x - ch[c].x, world.player(j).pos.y - ch[c].y};
                            if (math::lengthSquared(d) < Fixed64::fromInt(225)) ++crowd[c];
                        }
                    }
                    Fixed64 ax = me.pos.x * clr_sgn + Fixed64::fromInt(35);
                    if (ax > half_x_ - Fixed64::fromInt(30)) ax = half_x_ - Fixed64::fromInt(30);
                    const Fixed64 ay = half_y_ * Fixed64::fromFraction(7, 20);
                    Vec2 to{ax * clr_sgn, crowd[0] <= crowd[1] ? Fixed64::zero() - ay : ay};
                    to = clearUpTheLine(me.pos, to);
                    out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                    out.action = Action::LoftedKick;
                    out.carry_m = aimedCarry(me.pos, to, rangeFor(levelOf(slot), Fixed64::fromInt(50)));
                    out.why = Why::Clear;
                    out.first_time = true;
                    out.target = to;
                    return out;
                }
            }
        }

        // G5.9 (§8.107): near their line, wide or in the half-space, a pro
        // crosses at the real rate for the spot, rolled once on the ball:
        // in the air (or driven low, low_share) to the mate with the most
        // room in the box, else to the spot crosses land on. [FH roll and
        // aim; rates StatsBomb PL 2015/16]
        {
            const auto& X = book_.cross;
            if (X.measured() && !im_keeper) {
                const Fixed64 csg = Fixed64::fromInt(sign >= 0 ? 1 : -1);
                const Fixed64 to_line = half_x_ - me.pos.x * csg;
                const int cd = CrossIt::depth(to_line);
                const int cw = CrossIt::width(math::fx_abs(me.pos.y));
                if (cd >= 0) {
                    const Fixed64 u = (core::detNoise(match_seed_, world.ownedAtTick(), slot, 204) + Fixed64::one()) *
                                      Fixed64::fromFraction(1, 2);
                    if (u < X.rate(cd, cw)) {
                        const std::uint8_t team = setup_.team_of_slot[slot];
                        int best = -1;
                        Fixed64 best_room{};
                        // G5.11 (§8.108): read every man lead_s on along his run —
                        // the ball goes where the runner arrives (0 = where he is).
                        const Fixed64 lead = X.leadS();
                        auto ahead = [&](SlotIndex k) {
                            const auto& q = world.player(k);
                            return Vec2{q.pos.x + q.vel.x * lead, q.pos.y + q.vel.y * lead};
                        };
                        Vec2 best_at{};
                        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
                            if (i == slot || setup_.team_of_slot[i] != team || world.isKeeper(i)) continue;
                            const Vec2 at = ahead(i);
                            const Fixed64 mx = half_x_ - at.x * csg;
                            if (mx < X.boxNearM() || mx > X.boxFarM() || math::fx_abs(at.y) > X.boxYM()) continue;
                            Fixed64 room = Fixed64::fromInt(10000);
                            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                                if (setup_.team_of_slot[j] == team) continue;
                                const Vec2 o = ahead(j);
                                const Fixed64 r = math::lengthSquared(Vec2{o.x - at.x, o.y - at.y});
                                if (r < room) room = r;
                            }
                            if (best < 0 || room > best_room) { best = i; best_room = room; best_at = at; }
                        }
                        // ...and only with a man to find, when need_mate is set.
                        if (best >= 0 || !X.needMate()) {
                        Vec2 to = best >= 0 ? best_at
                                            : Vec2{(half_x_ - X.spotM()) * csg, Fixed64::zero()};
                        // A cross is played into an area, not onto a man's head:
                        // aim_spread_m either way in x and y around it. [FH]
                        if (X.spreadM().raw > 0) {
                            to.x += core::detNoise(match_seed_, world.ownedAtTick(), slot, 207) * X.spreadM();
                            to.y += core::detNoise(match_seed_, world.ownedAtTick(), slot, 208) * X.spreadM();
                        }
                        const Fixed64 u2 = (core::detNoise(match_seed_, world.ownedAtTick(), slot, 205) + Fixed64::one()) *
                                           Fixed64::fromFraction(1, 2);
                        const Fixed64 dist = math::length(Vec2{to.x - me.pos.x, to.y - me.pos.y});
                        out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                        if (u2 < X.lowShare()) {
                            out.action = Action::GroundKick;
                            const std::int64_t cm = (dist + Fixed64::fromFraction(1, 2)).raw >> Fixed64::FRAC_BITS;
                            out.carry_m = static_cast<std::uint8_t>(cm < 1 ? 1 : (cm > 255 ? 255 : cm));
                        } else {
                            out.action = Action::LoftedKick;
                            out.carry_m = aimedCarry(me.pos, to, rangeFor(lv, Fixed64::fromInt(50)));
                            if (X.meetZM().raw > 0) {
                                const int c = world.ballFlight().carryToMeet(dist, X.meetZM());
                                const Fixed64 cap = rangeFor(lv, Fixed64::fromInt(50));
                                const int cmax = static_cast<int>(cap.raw >> Fixed64::FRAC_BITS);
                                out.carry_m = static_cast<std::uint8_t>(std::max(1, std::min({c, cmax, 255})));
                            }
                        }
                        out.why = Why::Cross;
                        out.target = to;
                        if (best >= 0) out.other = static_cast<std::int16_t>(best);
                        return out;
                        }
                    }
                }
            }
        }

        // G5.4 (§8.102): a man with time, his hold over, passes square or
        // back at the real share for this third, to the open mate nearest a
        // real pass's length. Forward stays with the ladder below.
        if (!im_keeper && book_.pass_ladder.measuredDirection() &&
            world.tickCount() >= world.holdUntilTick()) {
            const Fixed64 dir_sgn = Fixed64::fromInt(sign >= 0 ? 1 : -1);
            const Fixed64 from_own = me.pos.x * dir_sgn + half_x_;
            const Fixed64 third_len = half_x_ * Fixed64::fromFraction(2, 3);
            const int third = from_own < third_len ? 0 : from_own < third_len * Fixed64::fromInt(2) ? 1 : 2;
            const Fixed64 u = (core::detNoise(match_seed_, world.ownedAtTick(), slot, 201) + Fixed64::one()) *
                              Fixed64::fromFraction(1, 2);
            const Fixed64 sq = book_.pass_ladder.squareShare(third, pressed), bk = book_.pass_ladder.backShare(third, pressed);
            const int want = u < bk ? 2 : u < bk + sq ? 1 : 0;   // 2 back, 1 square, 0 forward
            // Forward stays with the ladder where it works: a free man outside
            // the final third. Elsewhere it rarely fires, so pick the ball here.
            if (want != 0 || pressed || third == 2) {
                const Fixed64 onside = book_.pass_ladder.lines(world, slot, sign).offside;
                const Fixed64 three = Fixed64::fromInt(3), ideal = Fixed64::fromInt(16);
                const Vec2 from{me.pos.x, me.pos.y};
                bool have = false;
                Fixed64 best = Fixed64::zero();
                SlotIndex who = 0;
                Vec2 to{};
                Fixed64 to_dsq = Fixed64::zero();
                for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                    if (j == slot || setup_.team_of_slot[j] != setup_.team_of_slot[slot]) continue;
                    const auto& mate = world.player(j);
                    const Fixed64 gain = (mate.pos.x - me.pos.x) * dir_sgn;
                    if (want == 0 ? (gain < three || mate.pos.x * dir_sgn > onside)
                                  : want == 1 ? (gain >= three || gain <= Fixed64::zero() - three)
                                              : gain > Fixed64::zero() - three)
                        continue;
                    const Vec2 t{mate.pos.x, mate.pos.y};
                    const Fixed64 dsq = distSq(me.pos, Vec3{t.x, t.y, Fixed64::zero()});
                    if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax) continue;
                    const Fixed64 len = math::length(Vec2{t.x - from.x, t.y - from.y});
                    if (!passSafe(world, slot, j, from, t, core::weightedPassSpeed(len),
                                  want == 0 ? book_.pass_ladder.forwardReach() : Fixed64::one()))
                        continue;
                    const Fixed64 off = len > ideal ? len - ideal : ideal - len;
                    if (!have || off < best) { have = true; best = off; who = j; to = t; to_dsq = dsq; }
                }
                if (have) {
                    out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                    out.action = to_dsq < kSoftPassRange * kSoftPassRange ? Action::ShortPass : Action::GroundKick;
                    out.why = want == 0 ? Why::Pass : Why::Recycle;
                    out.target = to;
                    out.other = static_cast<std::int16_t>(who);
                    return out;
                }
            }
        }

        // Best forward receiver with an open lane. Progress = x toward MY
        // goal; deterministic tie-break by slot order (iteration order).
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        const Fixed64 my_progress = me.pos.x * sgn;
        // Law 11 on every pass he picks (G4.89): never to a man he reads in
        // an offside position — beyond their second-last man (keeper
        // counts), the ball and halfway, on HIS picture of the line (the
        // world as he sees it). Only the pass ladder asked (G4.36): the
        // offside whistle caught the man it was played to 90% of the time,
        // 56% of them 3 m+ past the line at the kick — off recycles, the
        // long-ball lapse, the plain pass, the keeper's short ball.
        const PassLadder::Lines law_lines = book_.pass_ladder.lines(world, slot, sign);
        auto onside = [&](SlotIndex j) {
            return !PassLadder::offsidePosition(world.player(j).pos.x * sgn, my_progress, law_lines);
        };
        Fixed64 their_line = Fixed64::fromInt(-1000);  // in x*sgn
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                continue;
            if (world.isKeeper(j)) continue;
            const Fixed64 depth = world.player(j).pos.x * sgn;
            if (depth > their_line) their_line = depth;
        }
        // safe_pass (bit 24, G4.19 [Buckland]): this tick, does the passer
        // READ the interceptors? Rolls per SECOND like the other duties —
        // a per-tick roll at 92 leaves a blind tick inside 92% of
        // one-second carries, and the pass fires on exactly that tick.
        // u10/u14 never read.
        // Verticality accepts risk: the cautious 1 m reach shrinks to
        // 0.6 m at 100. A ball lofted over the line flies over the block,
        // so only ground passes are read.
        const bool reads = applies(slot, 24, world.tickCount() / 30);
        const Fixed64 safe_reach =
            Fixed64::one() - degree(slot, 19) * Fixed64::fromFraction(2, 5);
        auto lane_open = [&](const Vec2& a, const Vec2& b) {
            const Fixed64 lane =
                kLaneWidth -
                kLaneWidth * degree(slot, 19) * Fixed64::fromFraction(2, 5);
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                if (pointSegmentDistSq(Vec2{world.player(j).pos.x,
                                            world.player(j).pos.y},
                                       a, b) <= lane * lane)
                    return false;
            }
            return true;
        };
        auto safe = [&](SlotIndex recv, const Vec2& a, const Vec2& b,
                        Fixed64 dsq, bool lofted) {
            if (!reads) return true;
            if (lofted) {   // G4.86b: the loft he'll hit, dropped where loftTo drops it
                const Loft lf = loftTo(world.ballFlight(), world.player(recv), me.pos, rangeFor(lv, book_.direct_ball.maxRange()));
                return loftSafe(world, slot, a, lf.at, lf.carry_m, safe_reach);
            }
            const Fixed64 v = core::weightedPassSpeed(math::fx_sqrt(dsq));   // G4.81: as he'll strike it
            return passSafe(world, slot, recv, a, b, v, safe_reach);
        };
        // Over their line (180; G4.75 keeper, G4.78 everyone): the runner
        // onside within runner_from_line_m of their last man, already going
        // forward at runner_speed_mps, and race_m nearer the drop (behind_m
        // past their line, his channel) than any of theirs, keeper too —
        // PERCEIVING the race is half the concept (G4.75 shipped without it:
        // 16-19 keeper balls a match, 91% theirs). The ball travels
        // pass_min_m+ and is in his range. Fills `out` and says yes, or no.
        auto overTheLine = [&](Fixed64 room) -> bool {
            const auto& H = book_.high_line;
            if (half_x_ - their_line < room) return false;
            Fixed64 drop = their_line + H.behind();
            if (drop > half_x_ - Fixed64::fromInt(6)) drop = half_x_ - Fixed64::fromInt(6);
            const Fixed64 reach = rangeFor(lv, Fixed64::fromInt(60));
            int run = -1;
            Fixed64 rx{};
            Vec2 to{};
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (j == slot || setup_.team_of_slot[j] != setup_.team_of_slot[slot] || world.isKeeper(j)) continue;
                const auto& rp = world.player(j);
                const Fixed64 x = rp.pos.x * sgn;
                if (x > their_line || x < their_line - H.runnerFromLine()) continue;   // offside / too deep
                if (rp.vel.x * sgn < H.runnerSpeed()) continue;                       // his run isn't on
                const Vec2 t{drop * sgn, rp.pos.y};
                const Fixed64 dsq = distSq(me.pos, Vec3{t.x, t.y, Fixed64::zero()});
                if (dsq < H.passMin() * H.passMin() || dsq > reach * reach) continue;
                const Fixed64 rd = math::length(Vec2{rp.pos.x - t.x, rp.pos.y - t.y});
                bool wins = true;
                for (SlotIndex o = 0; o < world.playerCount() && wins; ++o) {
                    if (setup_.team_of_slot[o] == setup_.team_of_slot[slot]) continue;
                    const auto& op = world.player(o).pos;
                    wins = math::length(Vec2{op.x - t.x, op.y - t.y}) > rd + H.race();
                }
                if (wins && (run < 0 || x > rx)) { run = j; rx = x; to = t; }
            }
            if (run < 0) return false;
            out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
            out.action = Action::LoftedKick;
            out.carry_m = aimedCarry(me.pos, to, reach);
            out.why = Why::OverHighLine;
            out.target = to;
            out.other = static_cast<std::int16_t>(run);
            return true;
        };
        // The keeper's distribution (G4.75): does he READ their high line
        // (180)? Read, seen high and a runner winning the race: over it.
        // Otherwise (not read — amateurs and kids never; a semipro at his
        // quality — or not on): the short, simple ball to an open man, any
        // direction — long only when nobody's open (below).
        if (im_keeper) {
            const auto& H = book_.high_line;
            const std::uint64_t ksec = world.tickCount() / 30;
            const bool reads_line = ratings_[slot][H.bit()] > 0 && applies(slot, H.bit(), ksec);
            if (reads_line && overTheLine(H.high())) return out;
            {   // not on (or not read): the short, simple ball
                ConceptContext pcx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                   half_x_, degree(slot, book_.short_simple.bit())};
                pcx.eligible = onside;
                if (const auto r = book_.short_simple.pick(pcx, lane_open, H.keeperShort())) {
                    const Vec2 to{world.player(*r).pos.x, world.player(*r).pos.y};
                    out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                    out.action = distSq(me.pos, Vec3{to.x, to.y, Fixed64::zero()}) < kSoftPassRange * kSoftPassRange
                                     ? Action::ShortPass : Action::GroundKick;
                    out.why = Why::KeeperShort;
                    out.target = to;
                    out.other = static_cast<std::int16_t>(*r);
                    return out;
                }
            }
        }
        // Everyone reads it (G4.78) [James 10/27: "everyone including false
        // 9 dropping in and taking care of it to send long ball like harry
        // kane"]: an outfield passer with time (not pressed) puts it over the
        // same way. The false 9 (181) doesn't need the line high: space_m of
        // grass behind it will do.
        // settle-in-possession (89, G5.1): the team is stretched, so no ball
        // in behind: what's in front of their line, or walk it while they
        // come up. A real counter still goes (counter-or-keep, 140).
        const bool settling = !im_keeper && !pressed && ratings_[slot][book_.settle.bit()] > 0 &&
            book_.settle.stretched(world, slot, sign) &&
            applies(slot, book_.settle.bit(), world.turnoverTick()) &&
            !(ratings_[slot][140] > 0 && inCounterWindow(slot, world));
        if (!im_keeper && !pressed && !settling) {
            const auto& F9 = book_.false_nine;
            const std::uint64_t osec = world.tickCount() / 30;
            const bool nine = ratings_[slot][F9.bit()] > 0 && applies(slot, F9.bit(), osec);
            const bool reads_line = nine || (ratings_[slot][book_.high_line.bit()] > 0 &&
                                             applies(slot, book_.high_line.bit(), osec));
            if (reads_line && overTheLine(nine ? F9.space() : book_.high_line.high())) return out;
        }
        // pass_ladder (bit 29, G4.35) [Bielsa-Leeds ch4] — ai::PassLadder:
        // a laddered passer ranks receivers by rung (behind their line
        // first, central before wide) instead of raw progress, and plays
        // a high enough rung at once. Rolls per second like safe_pass.
        // G4.47: what he plays — the ladder, a liked pass on his own
        // initiative, or a lapse (short and simple / hit it long).
        const int pass_choice = im_keeper ? (ratings_[slot][29] > 0 && applies(slot, 29, world.tickCount() / 30) ? 29 : -1)
                                          : choose(slot, 29, world.tickCount() / 30);
        const bool ladder = pass_choice == 29;
        // release_timing (id 60, G4.44) [Bielsa-Leeds f54/67/71]: an
        // unpressed carrier holds for a teammate about to break the line.
        const bool release = ratings_[slot][60] > 0 && !pressed && !im_keeper &&
                             applies(slot, 60, world.tickCount() / 30);
        const auto lines = (ladder || release || settling) ? book_.pass_ladder.lines(world, slot, sign)
                                                           : PassLadder::Lines{};
        const bool holding = release &&
            book_.release_timing.hold(world, slot, sign, lines, book_.pass_ladder);
        // over_the_top (bit 6): this tick's roll, the one the kick below uses.
        const bool over_top = ratings_[slot][6] > 0 && applies(slot, 6, world.tickCount());
        int best_rung = 0;
        bool have_target = false;
        Fixed64 best_progress{};
        Vec2 target{};
        Fixed64 target_dist_sq{};
        SlotIndex target_slot = 0;
        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
            if (i == slot) continue;
            if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
            if (blind(i)) continue;   // G4.66: can't see him
            const auto& mate = world.player(i);
            Vec2 b{mate.pos.x, mate.pos.y};
            // G4.36: a laddered passer never picks a man in an offside
            // position, and plays an onside runner into the space he is
            // running into (rungs 1-2 are a ball into space) [Bielsa-Leeds].
            if (!onside(i)) continue;   // G4.89: every pass, not just the ladder's
            // G4.98: only a man RUNNING at their goal is led — the lead of a
            // man drifting forward put ~80 balls a team a match "in behind".
            if (ladder && book_.pass_ladder.running(mate, sgn)) {
                const Vec2 lead = book_.pass_ladder.leadPoint(mate, me.pos);
                if (lead.x * sgn > lines.back && lead.x * sgn > b.x * sgn) b = lead;
            }
            const Fixed64 progress = b.x * sgn;
            if (progress < my_progress + Fixed64::fromInt(3)) continue;
            if (settling && progress > lines.back) continue;
            const Fixed64 dsq = distSq(me.pos, Vec3{b.x, b.y, Fixed64::zero()});
            if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax)
                continue;
            // Lane check: any opponent near the carrier→mate segment?
            const Vec2 a{me.pos.x, me.pos.y};
            if (!lane_open(a, b)) continue;
            // Only a ball he WILL loft skips the ground read (G4.86): the
            // over-the-top roll below decides the kick, and when it failed
            // he drove an unread ground ball through the block — 29% of
            // the balls in behind (34 a team a match) were theirs at the
            // kick by the flight read.
            const bool lofted = progress > their_line && over_top &&
                                dsq > kSoftPassRange * kSoftPassRange;
            if (!safe(i, a, b, dsq, lofted)) continue;
            const int r = ladder ? book_.pass_ladder.rung(progress, b.y, lines) : 0;
            const bool wins =
                ladder ? PassLadder::better(r, progress, best_rung, best_progress)
                       : progress > best_progress;
            if (!have_target || wins) {
                have_target = true;
                best_progress = progress;
                best_rung = r;
                target = b;
                target_dist_sq = dsq;
                target_slot = i;
            }
        }

        // G4.47 pass habits / lapses: he plays HIS ball, now.
        if (pass_choice == book_.short_simple.bit() || pass_choice == book_.direct_ball.bit()) {
            ConceptContext pcx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                               half_x_, degree(slot, pass_choice)};
            pcx.eligible = onside;
            const bool liked = ratings_[slot][29] == 0 || applies(slot, 29, world.tickCount() / 30);
            const bool longball = pass_choice == book_.direct_ball.bit();
            const auto r = longball ? book_.direct_ball.pick(pcx) : book_.short_simple.pick(pcx, lane_open);
            if (r) {
                Vec2 to{world.player(*r).pos.x, world.player(*r).pos.y};
                if (longball) {
                    // Dropped where he'll be (G4.48), not hit at where he is.
                    const Loft lf = loftTo(world.ballFlight(), world.player(*r), me.pos, rangeFor(lv, book_.direct_ball.maxRange()));
                    to = lf.at;
                    out.carry_m = lf.carry_m;
                }
                out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                out.action = longball ? Action::LoftedKick
                                      : (distSq(me.pos, Vec3{to.x, to.y, Fixed64::zero()}) < kSoftPassRange * kSoftPassRange
                                             ? Action::ShortPass : Action::GroundKick);
                out.why = longball ? (liked ? Why::HabitLong : Why::LapseLong)
                                   : (liked ? Why::HabitShort : Why::LapseShort);
                out.target = to;
                out.other = static_cast<std::int16_t>(*r);
                return out;
            }
        }

        // verticality [Bielsa/Zeman]: forward FIRST — the gain threshold
        // collapses with the rating (0.4x at 100): play the ball on.
        Fixed64 vdeg = degree(slot, 19);
        // counter_attack (bit 23, G4.18, KNVB moment 4): the first
        // seconds after WINNING the ball are the fast break — their
        // shape is broken, so even a control-minded side plays forward
        // NOW. Inside the window (own-half win, length scales with the
        // rating) the gain threshold collapses at least as far as verticality 100
        // would take it; outside it, style resumes.
        if (inCounterWindow(slot, world)) {
            const Fixed64 cdeg = degree(slot, 23);
            if (cdeg > vdeg) vdeg = cdeg;
        }
        const Fixed64 gain_scale =
            Fixed64::one() - vdeg * Fixed64::fromFraction(6, 10);
        const bool ladder_fires =
            ladder && best_rung > 0 &&
            best_rung <= book_.pass_ladder.fireRung(degree(slot, 29));
        // Holding for a runner: only the ball in behind (rungs 1-2) may go.
        const bool in_behind = ladder && best_rung >= 1 && best_rung <= 2;
        if (have_target && !(holding && !in_behind) &&
            (pressed || im_keeper || ladder_fires ||
             best_progress - my_progress > kEagerGain * jitter * gain_scale)) {
            out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            // Over the top (§5.2's worked example, playable at last): a
            // receiver BEYOND their last outfield defender gets a lofted
            // through ball — it flies over the block that a ground pass
            // would have to thread. Disciplined sides only (a U-10
            // doesn't know this ball exists).
            const bool beyond_line = best_progress > their_line;
            if (beyond_line && over_top &&
                target_dist_sq > kSoftPassRange * kSoftPassRange) {
                out.action = Action::LoftedKick;  // over the top
                // Dropped into his run (G4.48): the preset chip bounced on
                // ~45 m past a 20 m runner.
                const Loft lf = loftTo(world.ballFlight(), world.player(target_slot), me.pos, rangeFor(lv, book_.direct_ball.maxRange()));
                target = lf.at;
                out.carry_m = lf.carry_m;
                out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            } else {
                out.action = target_dist_sq < kSoftPassRange * kSoftPassRange
                                 ? Action::ShortPass
                                 : Action::GroundKick;
            }
            out.why = out.action == Action::LoftedKick ? Why::OverTop : (ladder_fires ? Why::PassLadder : Why::Pass);
            out.rung = static_cast<std::uint8_t>(best_rung);
            out.read = reads;
            out.target = target;
            out.other = static_cast<std::int16_t>(target_slot);
            return out;
        }

        // Recycle (safe_pass, G4.19): pressed with nothing on going
        // forward, a reading passer keeps the ball — the safest-read pass
        // in ANY direction (the G4.8 back outlet finally receives). Most
        // progress among the safe ones; blind passers dribble or hoof.
        if (reads && pressed) {
            bool have = false;
            Fixed64 best{};
            Vec2 to{};
            Fixed64 to_dsq{};
            SlotIndex recycle_slot = 0;
            for (SlotIndex i = 0; i < world.playerCount(); ++i) {
                if (i == slot) continue;
                if (blind(i)) continue;   // G4.66
                if (setup_.team_of_slot[i] != setup_.team_of_slot[slot])
                    continue;
                const auto& mate = world.player(i);
                const Fixed64 dsq = distSq(me.pos, mate.pos);
                if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax)
                    continue;
                if (!onside(i)) continue;   // G4.89
                const Vec2 a{me.pos.x, me.pos.y};
                const Vec2 b{mate.pos.x, mate.pos.y};
                if (!lane_open(a, b) || !safe(i, a, b, dsq, false)) continue;
                const Fixed64 progress = mate.pos.x * sgn;
                if (!have || progress > best) {
                    have = true;
                    best = progress;
                    to = b;
                    to_dsq = dsq;
                    recycle_slot = i;
                }
            }
            if (have) {
                out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                out.action = to_dsq < kSoftPassRange * kSoftPassRange
                                 ? Action::ShortPass
                                 : Action::GroundKick;
                out.why = Why::Recycle;
                out.target = to;
                out.other = static_cast<std::int16_t>(recycle_slot);
                return out;
            }
        }

        // Keeper distribution (G4.14): a keeper NEVER dribbles out — with
        // no open pass he PUNTS to the emptier wide midfield channel.
        // The keeper-catch → short-pass-into-the-counter-press →
        // poke → re-shot loop was the pinball engine behind 1,600
        // shots/match at top levels; the punt turns a save into a
        // midfield contest, as in life.
        if (im_keeper) {
            const Fixed64 sgn_k = sign >= 0 ? Fixed64::one() : -Fixed64::one();
            const Fixed64 ch_y = half_y_ * Fixed64::fromFraction(3, 5);
            int crowd[2] = {0, 0};  // opponents near the left/right channel
            const Vec2 ch[2] = {Vec2{sgn_k * Fixed64::fromInt(10), -ch_y},
                                Vec2{sgn_k * Fixed64::fromInt(10), ch_y}};
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                for (int c = 0; c < 2; ++c) {
                    const Vec2 d{world.player(j).pos.x - ch[c].x,
                                 world.player(j).pos.y - ch[c].y};
                    if (math::lengthSquared(d) < Fixed64::fromInt(225))
                        ++crowd[c];
                }
            }
            const Vec2 target = crowd[0] <= crowd[1] ? ch[0] : ch[1];
            out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            out.action = Action::LoftedKick;
            out.carry_m = aimedCarry(me.pos, target, rangeFor(lv, Fixed64::fromInt(60)));
            out.why = Why::KeeperPunt;
            out.target = target;
            return out;
        }

        // No pass: dribble at goal; if touch-tight with no outlet, clear
        // over the press rather than donating a steal. A READING passer
        // (safe_pass) clears only in his own defensive third — elsewhere
        // he keeps it and risks the duel. The clear-anywhere hoof was
        // 858 of world's 989 lost kicks per match (G4.19 A/B: without
        // it, possessions 5.1 s → 12.2 s).
        out.move.move = seek(me.pos, goal, kArriveRadius);
        // G5.9 (§8.107): a wide man drives at the real angles — down the
        // line most, inside or cutting in the rest — not always at the goal.
        {
            const auto& D = book_.drive_the_line;
            const Fixed64 ay = math::fx_abs(me.pos.y);
            const Fixed64 to_line = half_x_ - me.pos.x * sgn;
            if (D.measured() && !im_keeper && ay >= Fixed64::fromInt(14) && to_line < D.withinM()) {
                const int row = ay >= Fixed64::fromInt(24) ? 0 : 1;
                const Fixed64 u = (core::detNoise(match_seed_, world.ownedAtTick(), slot, 206) + Fixed64::one()) *
                                  Fixed64::fromFraction(1, 2);
                Fixed64 deg = D.angleFor(row, u);
                if (to_line < Fixed64::fromInt(4) && deg < Fixed64::fromInt(50)) deg = Fixed64::fromInt(90);   // at the byline: in along it
                const Fixed64 a = deg * Fixed64::fromFraction(71, 4068);
                const Fixed64 inward = me.pos.y.raw > 0 ? -Fixed64::one() : Fixed64::one();
                const Vec2 dir{sgn * math::fx_cos(a), inward * math::fx_sin(a)};
                Vec2 to{me.pos.x + dir.x * Fixed64::fromInt(10), me.pos.y + dir.y * Fixed64::fromInt(10)};
                const Fixed64 lx = half_x_ - Fixed64::fromInt(1), ly = half_y_ - Fixed64::fromInt(1);
                if (to.x > lx) to.x = lx;
                if (to.x < -lx) to.x = -lx;
                if (to.y > ly) to.y = ly;
                if (to.y < -ly) to.y = -ly;
                out.move.move = seek(me.pos, to, kArriveRadius);
            }
        }
        // Holding for a runner (release_timing): slow the ball down — a
        // walking carry keeps it, a sprint into the block loses it.
        if (holding || settling) {
            const Fixed64 walk = Fixed64::fromFraction(35, 100);
            out.move.move = Vec2{out.move.move.x * walk, out.move.move.y * walk};
        }
        const bool keeps_it =
            reads && me.pos.x * sgn > -half_x_ + Fixed64::fromInt(35);
        // keep-it-under-pressure (161, G4.60): touch-tight with nothing
        // on, play it back to the open man goal-side of him, else shield
        // and turn away; only in his own third may he still kick it away.
        // A lapse (or u-nothing) falls through to the hoof below.
        // G5.8 (§8.106): with clear-the-danger's rows the clearance was
        // rolled once on the ball above; here a touch-tight man keeps it
        // (plays back or shields), in his own third too, never a late hoof.
        const bool clear_now = false;
        if (ctd.measured() && !im_keeper) {
            if (keepIt(slot, world, sign, out, true)) return out;
        } else if (!ctd.measured() && pressed && !im_keeper && keepIt(slot, world, sign, out))
            return out;
        if (clear_now || (!ctd.measured() && pressed && !keeps_it)) {
            bool touch_tight = false;
            for (SlotIndex i = 0; i < world.playerCount() && !touch_tight;
                 ++i) {
                if (setup_.team_of_slot[i] == setup_.team_of_slot[slot])
                    continue;
                touch_tight = distSq(me.pos, world.player(i).pos) <
                              Fixed64::fromFraction(6, 5) *
                                  Fixed64::fromFraction(6, 5);
            }
            // In shooting range the boot IS a shot (shot physics, counted
            // as one); elsewhere it's a CLEARANCE to the emptier wide
            // channel upfield — never along the carrier's run. The old
            // loft-along-desire chipped the keeper from every pressed
            // attack: 33 of 36 HEAD amateur goals were these uncounted
            // "clears" (G4.23 goal anatomy, read pre-tick).
            if (touch_tight || clear_now) {
                if (!clear_now && math::lengthSquared(to_goal) < kShootRange * kShootRange) {
                    // G5.4 (§8.102): with real rates loaded the shot was
                    // already rolled above. A tight man here plays on or
                    // loses it, as a pro does (29-35% lost in this zone).
                    if (!book_.shot_selection.measured()) out.action = Action::Shot;
                } else {
                    const Fixed64 cx = me.pos.x + sgn * Fixed64::fromInt(20);
                    const Fixed64 cy = half_y_ * Fixed64::fromFraction(3, 5);
                    int crowd[2] = {0, 0};
                    const Vec2 ch[2] = {Vec2{cx, -cy}, Vec2{cx, cy}};
                    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                        if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                            continue;
                        for (int c = 0; c < 2; ++c) {
                            const Vec2 d{world.player(j).pos.x - ch[c].x,
                                         world.player(j).pos.y - ch[c].y};
                            if (math::lengthSquared(d) < Fixed64::fromInt(225))
                                ++crowd[c];
                        }
                    }
                    // Aimed (G4.48): long and up the emptier side, landing
                    // inside the pitch — it runs on ~20 m after the bounce,
                    // so dropping it ON the wide channel put ~300 balls a
                    // match into touch.
                    Fixed64 ax = me.pos.x * sgn + Fixed64::fromInt(35);
                    if (ax > half_x_ - Fixed64::fromInt(30)) ax = half_x_ - Fixed64::fromInt(30);
                    const Fixed64 ay = half_y_ * Fixed64::fromFraction(7, 20);
                    Vec2 to{ax * sgn, crowd[0] <= crowd[1] ? -ay : ay};
                    to = clearUpTheLine(me.pos, to);
                    out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                    out.action = Action::LoftedKick;
                    out.carry_m = aimedCarry(me.pos, to, rangeFor(lv, Fixed64::fromInt(50)));
                }
            }
        }
        out.why = out.action == Action::Shot ? Why::Shoot : (out.action == Action::LoftedKick ? Why::Clear : (holding ? Why::WaitForRunner : (settling ? Why::Settle : Why::Dribble)));
        // A clearance is hit first time (G4.95; def-clear-foot): no touch to
        // set it — dispossessed in his own third, 74% were still in their
        // control touch, 29% of them trying to clear.
        out.first_time = out.why == Why::Clear;
        out.target = goal;
        return out;
    }

    // My formation anchor (ball-shifted), the default duty.
    const FormationSpec::Pos& mine =
        spec_[setup_.team_of_slot[slot]].positions[index_in_team_[slot]];
    Vec2 anchor = anchorFor(mine.base, sign, seen_ball, half_x_,
                            half_y_, mine.keeper);
    if (mine.keeper) {
        // Angle play (G4.3b): stand where the ball→goal-centre line
        // crosses the keeper's x, so central shots meet hands. Division
        // is guarded (ball at the goal line exactly → hold centre).
        const Fixed64 goal_x =
            sign >= 0 ? -half_x_ : half_x_;  // MY goal is behind me
        const Fixed64 denom = seen_ball.x - goal_x;
        Fixed64 y = Fixed64::zero();
        if (math::fx_abs(denom) > Fixed64::one()) {
            const Fixed64 t = (anchor.x - goal_x) / denom;
            y = seen_ball.y * t;
        }
        // Sweep (G4.8): a FREE ball in my defensive third is MINE — come
        // claim it with hands before the runner arrives. This is the
        // real counter to the ball over the top.
        const Fixed64 my_depth_limit =
            -half_x_ * (sign >= 0 ? Fixed64::one() : -Fixed64::one()) *
            Fixed64::one();  // my goal line x
        const Fixed64 dsgn_k = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        const bool ball_in_my_third =
            seen_ball.x * dsgn_k < -half_x_ + Fixed64::fromInt(20);
        // Sweeping is an ADVANCED keeper concept — U-10 keepers are
        // famously rooted to their line (and two sweeping U-10 keepers
        // measured a 97%-loose swamp: the mechanic itself inverted the
        // level ladder until gated). G4.14: sweep only when it's
        // WINNABLE — the harness measured beaten keepers 13-14 m off
        // their line (every unwinnable sweep vacates the net for the
        // next 20 m shot). "Is it mine?" is the first judgment a real
        // keeper makes; margin = 2 m in the keeper's favor required.
        if (!ball.owner && ball_in_my_third &&
            applies(slot, 7, world.tickCount() / 30)) {
            Fixed64 opp_best_sq = Fixed64::fromInt(10000);
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                const Fixed64 d = distSq(world.player(j).pos, seen_ball);
                if (d < opp_best_sq) opp_best_sq = d;
            }
            const Fixed64 my_d =
                math::length(Vec2{seen_ball.x - me.pos.x,
                                  seen_ball.y - me.pos.y}) +
                Fixed64::fromInt(2);
            if (my_d * my_d < opp_best_sq) {
                out.move.move = seek(me.pos, Vec2{seen_ball.x, seen_ball.y},
                                     Fixed64::fromFraction(1, 10));
                out.why = Why::KeeperSweep;
                out.target = Vec2{seen_ball.x, seen_ball.y};
                return out;
            }
        }
        (void)my_depth_limit;

        // Dive-lite (G4.3b): a FAST free ball coming at my goal is a
        // shot — track where its actual trajectory crosses my x, not
        // the centre line. Perception delay makes slow keepers read it
        // late, which is exactly how levels should feel.
        const bool incoming =
            !ball.owner &&
            ((sign >= 0 && ball.vel.x.raw < 0) ||
             (sign < 0 && ball.vel.x.raw > 0));
        const Fixed64 speed_sq = ball.vel.x * ball.vel.x +
                                 ball.vel.y * ball.vel.y;
        // Reaction knob (G4.14, THE G4.4 item): the keeper holds his
        // angle-play spot for the first reaction ticks of a shot's
        // flight — a placed strike beats the slow-to-move, as in life.
        const bool reacted =
            lv.keeper_reaction_ticks <= 0 ||
            core::kKickAliveTicks - ball.kick_alive >=
                lv.keeper_reaction_ticks;
        // The speed gate is about "is it moving", NOT "is it fast": a
        // 14 m/s youth shot decays to ~7 m/s over 17 m of grass and
        // arrived UNDER the old 12 m/s gate — u14 keepers watched
        // tricklers roll past from 3 m away (measured, G4.14). Any
        // incoming ball on a goalward track gets tracked.
        bool on_target = false;
        Fixed64 arrive_t = Fixed64::zero();
        if (reacted && incoming && speed_sq > Fixed64::fromInt(16) &&
            math::fx_abs(ball.vel.x) > Fixed64::one()) {
            // Leave it if it's going WIDE (G4.23): project to the GOAL
            // line; outside the post + 0.3 m the keeper holds his angle
            // spot. Tracking every shot to ±6 m had keepers collecting
            // 90% of all shots and ~0% missing the target — a slow
            // amateur strike gives a 6 m/s keeper time to reach anything.
            const Fixed64 goal_x = sign >= 0 ? -half_x_ : half_x_;
            const Fixed64 gt = (goal_x - seen_ball.x) / ball.vel.x;
            const Fixed64 y_goal = seen_ball.y + ball.vel.y * gt;
            if (math::fx_abs(y_goal) <= Fixed64::fromFraction(396, 100)) {
                const Fixed64 flight_t =
                    (anchor.x - seen_ball.x) / ball.vel.x;
                y = seen_ball.y + ball.vel.y * flight_t;
                on_target = true;
                arrive_t = flight_t;
            }
        }
        const Fixed64 lim = Fixed64::fromInt(6);
        if (y > lim) y = lim;
        if (y < -lim) y = -lim;
        anchor.y = y;
        // Dive (G4.51): if his feet can't get him there before the ball,
        // he launches — timed so he is still in the air when it arrives
        // (air ticks), not early onto the turf. [FH]
        if (on_target && arrive_t.raw > 0) {
            const auto& loco = world.locomotion();
            const Vec2 gap{anchor.x - me.pos.x, anchor.y - me.pos.y};
            const Fixed64 dist = math::length(gap);
            const Fixed64 feet = runToward(world, slot, anchor, arrive_t) + core::kKeeperReach;
            const Fixed64 air_t = Fixed64::fromInt(loco.diveAirTicks()) * core::kTickDt;
            if (dist > feet && arrive_t <= air_t && dist.raw > 0) {
                out.move.move = Vec2{gap.x / dist, gap.y / dist};
                out.action = Action::Dive;
                out.why = Why::KeeperDive;
                out.target = anchor;
                return out;
            }
        }
        // A keeper does ONLY keeper things (G4.14): without this return
        // he fell through into the outfield counter-press and loose-ball
        // chase branches and hunted balls up to 28 m from goal — the
        // harness measured beaten keepers 12-14 m off their line. His
        // ball-winning is the gated sweep and dive-lite above, full stop.
        // Arrive radius 0.5 m, NOT the shared 1.5 m: hands reach 1.2 m,
        // so the generic radius left a dead band where he stood still
        // and watched the ball pass 1.3 m away (measured: beaten keepers
        // 2.4 m off the crossing point with the shot aimed 1 m out).
        out.move.move = seek(me.pos, anchor, Fixed64::fromFraction(1, 2));
        out.why = Why::KeeperPosition;
        out.target = anchor;
        return out;
    }

    // ── meet the pass (G4.49) — ai::MeetThePass: our ball is travelling.
    // The man who can take it first goes to where he can; if we get there
    // before them it's still OUR ball, and the rest keep attacking.
    const std::uint8_t my_team = setup_.team_of_slot[slot];
    const int meet = book_.meet_the_pass.bit();
    bool flight_ours = false;
    // One read per PASS (G4.60), not per second: a per-second roll had a
    // semipro receiver meet it, forget it the next second and walk back
    // to his shape 2 m from the ball (traced in the phase harness). The
    // flight is keyed by its kicker and heading — friction slows a rolling
    // ball but never turns it — so a lapse is misjudging the pass when it
    // is played, not abandoning the run.
    auto flightKey = [&]() -> std::uint64_t {
        const Fixed64 ax = math::fx_abs(ball.vel.x), ay = math::fx_abs(ball.vel.y);
        const Fixed64 hi = ax > ay ? ax : ay, lo = ax > ay ? ay : ax;
        const std::uint64_t ratio = hi.raw > 0 ? static_cast<std::uint64_t>(((lo * Fixed64::fromInt(16)) / hi).raw >> Fixed64::FRAC_BITS) : 0;
        const std::uint64_t octant = (ball.vel.x.raw < 0 ? 1u : 0u) | (ball.vel.y.raw < 0 ? 2u : 0u) | (ax > ay ? 4u : 0u);
        return (std::uint64_t{1} << 40) | (std::uint64_t{ball.last_kicker} << 16) | (octant << 8) | ratio;
    };
    // The pass is FOR somebody (G4.81): the man the passer played it to
    // (ball().pass_to — read off the passer the way a player reads "that's
    // mine") meets it; the rest LET IT RUN unless he can't get there before
    // them, when our first man rescues it. Before, only the mate the flight
    // read put first went: 41-47% of passes lost in our own third had
    // another mate "first", the man it was played to held his shape and ran
    // off it with his moving possession spot, and teammates stepped across
    // passes meant for someone else (fh-game-match, LH APSL v Ukies).
    if (!ball.owner && world.restartTeam() == 0xFF && world.lastTouchTeam() == my_team &&
        ratings_[slot][meet] > 0) {
        const int to = ball.pass_to < world.playerCount() && setup_.team_of_slot[ball.pass_to] == my_team
                           ? static_cast<int>(ball.pass_to) : -1;
        const bool for_me = to == static_cast<int>(slot);
        Vec2 in_line{};
        if (for_me && getInLine(slot, world, in_line)) {
            out.move.move = seek(me.pos, in_line, Fixed64::fromFraction(1, 10));
            out.move.face = Vec2{ball.pos.x - me.pos.x, ball.pos.y - me.pos.y};
            out.why = Why::MeetPass;
            out.target = in_line;
            return out;
        }
        if (applies(slot, meet, flightKey())) {
            const FlightRead& fr = flightRead(world);
            const int mine_first = fr.first[my_team], theirs = fr.first[my_team ^ 1];
            if (mine_first >= 0) {
                flight_ours = theirs < 0 || fr.tick[mine_first] < fr.tick[theirs];
                const bool his = to >= 0 && !for_me && fr.tick[to] >= 0 &&
                                 (theirs < 0 || fr.tick[to] <= fr.tick[theirs]);   // let it run
                if ((mine_first == slot && !his) || (for_me && fr.tick[slot] >= 0)) {
                    out.move.move = seek(me.pos, fr.at[slot], Fixed64::fromFraction(1, 10));
                    out.why = Why::MeetPass;
                    out.target = fr.at[slot];
                    return out;
                }
            }
            if (for_me) {   // can't reach it inside the read: come to it
                const Vec2 to{ball.pos.x, ball.pos.y};
                out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                out.why = Why::MeetPass;
                out.target = to;
                return out;
            }
        } else if (for_me) {
            // The lapse: he lets it come to him — steps onto its line and
            // waits there instead of coming to meet it ("come to the
            // ball!"), so they get the extra second to nip in. Waiting where
            // he stood let the ball roll past 2-3 m off him (traced).
            const Vec2 v{ball.vel.x, ball.vel.y};
            const Fixed64 sp = math::length(v);
            Vec2 to{me.pos.x, me.pos.y};
            if (sp > Fixed64::fromFraction(1, 2)) {
                const Vec2 dir{v.x / sp, v.y / sp};
                const Fixed64 along = math::dot(Vec2{me.pos.x - ball.pos.x, me.pos.y - ball.pos.y}, dir);
                if (along > Fixed64::zero()) to = Vec2{ball.pos.x + dir.x * along, ball.pos.y + dir.y * along};
                else to = Vec2{ball.pos.x, ball.pos.y};   // it's past him: go to it
            }
            out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
            out.move.face = Vec2{ball.pos.x - me.pos.x, ball.pos.y - me.pos.y};
            out.why = Why::WaitPass;
            out.target = to;
            return out;
        }
    }
    const bool ours =
        (ball.owner && setup_.team_of_slot[*ball.owner] == my_team) || flight_ours;
    // The SHAPE's phase is the team's possession, not this tick's owner
    // (G4.80b): our own pass in the air is still our ball until they take
    // it. Keyed on the owner alone, every pass whose meet-the-pass read
    // didn't fire flipped the whole team to its defending block and line
    // for the flight and back on the touch — hold-shape targets jumped
    // ~24 m in one tick, mid-possession, and men 12 m off their spot
    // chased them at full speed (the "skates").
    // Open play only: a dead ball keeps its own shapes (kick-off halves,
    // G4.58 restart holds).
    const bool shape_ours = ours ||
        (!ball.owner && world.restartTeam() == 0xFF && world.lastTouchTeam() == my_team);
    if (shape_ours && !mine.keeper) {
        Vec2 sb{seen_ball.x, seen_ball.y};
        if (ours_ball_tau_x_.raw > 0 || ours_ball_tau_y_.raw > 0) sb = shapeBall(my_team, world);   // G5.14
        anchor.x = possessionX(slot, sb.x);
        anchor.y = possessionY(mine.base, sb.y, anchor.y);
    } else if (!mine.keeper) {
        anchor.y = defendingY(mine.base, seen_ball.y, anchor.y);
    }

    // Our ball in flight: a runner ahead of it keeps running — stopping to
    // watch it was the run that never got the ball in behind. Not a man
    // the flag has caught, and never into the end zone.
    if (flight_ours && !mine.keeper) {
        const Fixed64 sg = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        const bool flagged = world.offsideTeam() == my_team &&
                             ((world.offsideMask() >> (slot & 31)) & 1u);
        if (!flagged && me.pos.x * sg > ball.pos.x * sg &&
            me.vel.x * sg > book_.meet_the_pass.keepRunningSpeed() &&
            me.pos.x * sg < half_x_ - Fixed64::fromInt(8)) {
            const Vec2 dir = math::normalized(Vec2{me.vel.x, me.vel.y});
            out.move.move = dir;
            out.why = Why::KeepRunning;
            out.target = Vec2{me.pos.x + dir.x * Fixed64::fromInt(5), me.pos.y + dir.y * Fixed64::fromInt(5)};
            return out;
        }
    }

    // ── out of possession (G5.21, §8.119): the player state machine ──────
    // The G4 chain that stood here (compactness cap, pre-offside depth
    // cover, swarm, delay/organize/step, counter-press, recover, man-
    // orientation marking) is deleted (James 11/5: "delete old code so it
    // don't corrupt"); DefendingBlock's states give the orders.
    if (!mine.keeper) {
        const PlayerState* st = players_[slot].machine.current();
        if (st && st != DefendingBlock::attacking()) {
            PlayerView v;
            v.slot = slot;
            v.team = my_team;
            v.sg = sign >= 0 ? Fixed64::one() : -Fixed64::one();
            v.role = roleOfNumber(numberOf(slot));
            v.across = defendingY(mine.base, seen_ball.y,
                                  anchorFor(mine.base, sign, seen_ball, half_x_, half_y_, mine.keeper).y);
            const FlightRead& fr = flightRead(world);
            v.chase_to = (fr.live && slot < fr.at.size() && fr.tick[slot] >= 0) ? fr.at[slot] : Vec2{ball.pos.x, ball.pos.y};
            v.match_seed = match_seed_;
            const PlayerCtx c{world, block_, teams_[my_team], world.tickCount()};
            if (static_cast<const ActingState*>(st)->act(v, c, out.move, out.action, out.target, out.other)) {
                out.why = st == DefendingBlock::holdBlockSpot() ? Why::Hold
                        : st == DefendingBlock::pressBall()     ? Why::Press
                                                                : Why::Chase;
                dbg_anchor_[slot] = out.target;   // harness probe (match_main DEFENDING SHAPE)
                return out;
            }
        }
    }

    // ── our ball, off the ball: the carrier's nearest teammate offers a
    // support spot ahead of play ([Buckland]-lite single support player;
    // the sampled support-spot calculator replaces this) ────────────────
    if (ours && ball.owner && *ball.owner != slot && !mine.keeper) {
        const auto& carrier = world.player(*ball.owner);
        const Fixed64 sgn2 = sign >= 0 ? Fixed64::one() : -Fixed64::one();

        // give_and_go: I JUST passed this ball — keep moving. Burst past
        // the receiver into the space ahead; his normal pass evaluation
        // finds me and the 1-2 emerges with no special wall-pass code.
        if (ratings_[slot][14] > 0 && ball.last_kicker == slot &&
            applies(slot, 14, world.tickCount() / 30)) {
            out.move.move = seek(
                me.pos,
                Vec2{carrier.pos.x + sgn2 * Fixed64::fromInt(10),
                     (carrier.pos.y + me.pos.y) *
                         Fixed64::fromFraction(1, 2)},
                Fixed64::fromFraction(1, 2));
            out.why = Why::GiveAndGo;
            out.target = Vec2{carrier.pos.x + sgn2 * Fixed64::fromInt(10), (carrier.pos.y + me.pos.y) * Fixed64::fromFraction(1, 2)};
            out.other = static_cast<std::int16_t>(*ball.owner);
            return out;
        }

        // blind_side_run (bit 30, G4.36) [Bielsa-Leeds] — ai::BlindSideRun:
        // up at their line, wait onside on the defender's far shoulder; go
        // in behind when the carrier turns forward and he can't see you.
        if (ratings_[slot][30] > 0 && applies(slot, 30, world.tickCount() / 30)) {
            const ConceptContext cx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                    half_x_, degree(slot, 30)};
            if (auto t = book_.blind_side_run.target(cx)) {
                out.move.move = seek(me.pos, *t, Fixed64::fromFraction(1, 2));
                out.why = Why::BlindSideRun;
                out.target = *t;
                out.other = static_cast<std::int16_t>(*ball.owner);
                return out;
            }
        }

        // The false 9 drops in (181, G4.78) [Kane]: our ball still
        // from_line_m or more short of their back line — the 9 comes off it
        // to drop_m in front of it, central, ahead of the ball, to take it
        // and turn. With him gone the most advanced man is a winger, so the
        // run in behind below is now HIS.
        {
            const auto& F9 = book_.false_nine;
            const int num = spec_[setup_.team_of_slot[slot]].positions[index_in_team_[slot]].number;
            if (num == 9 && ratings_[slot][F9.bit()] > 0 && applies(slot, F9.bit(), world.tickCount() / 30)) {
                Fixed64 line9 = Fixed64::fromInt(-1000);
                for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                    if (setup_.team_of_slot[j] == setup_.team_of_slot[slot] || world.isKeeper(j)) continue;
                    const Fixed64 d = world.player(j).pos.x * sgn2;
                    if (d > line9) line9 = d;
                }
                const Fixed64 cp = carrier.pos.x * sgn2;
                if (line9 - cp >= F9.fromLine()) {
                    Fixed64 dx = line9 - F9.drop();
                    if (dx < cp + Fixed64::fromInt(6)) dx = cp + Fixed64::fromInt(6);
                    const Vec2 t{dx * sgn2, carrier.pos.y * Fixed64::fromFraction(1, 4)};
                    out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
                    out.why = Why::FalseNineDrop;
                    out.target = t;
                    out.other = static_cast<std::int16_t>(*ball.owner);
                    return out;
                }
            }
        }

        // The named ways off a position (G4.80, Concept.hpp): otherwise a
        // semi-pro holds his spot. By the traditional numbers (formation
        // roles): full-backs 2 / 3, wingers 7 / 11, midfielders 6 / 8 / 10;
        // his side is his base's.
        {
            const std::uint64_t sec = world.tickCount() / 30;
            const int num = mine.number;
            const bool fullback = num == 2 || num == 3, winger = num == 7 || num == 11;
            const bool mid = num == 6 || num == 8 || num == 10;
            const Fixed64 side = mine.base.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
            const auto& cpos = spec_[setup_.team_of_slot[*ball.owner]].positions[index_in_team_[*ball.owner]];
            const auto& cb = cpos.base;
            const Fixed64 cx = carrier.pos.x * sgn2, mx = me.pos.x * sgn2;
            // Overlap (41): our wide man on my side has it infield, at or past
            // halfway; I'm the full-back behind him.
            const auto& OV = book_.overlap;
            if (fullback && ratings_[slot][OV.bit()] > 0 &&
                (cpos.number == 7 || cpos.number == 11) && (cb.y.raw >= 0) == (side.raw > 0) &&
                cx >= -OV.fromHalfway() && cx > mx &&
                carrier.pos.y * side < half_y_ - OV.infield() && applies(slot, OV.bit(), sec)) {
                Fixed64 tx = cx + OV.ahead();
                const Fixed64 cap = half_x_ - Fixed64::fromInt(6);
                if (tx > cap) tx = cap;
                const Vec2 t{tx * sgn2, side * (half_y_ - OV.wide())};
                out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
                out.why = Why::Overlap;
                out.target = t;
                out.other = static_cast<std::int16_t>(*ball.owner);
                return out;
            }
            // The winger comes short (182): our ball deep (own half) on my
            // side, me gap_m or more beyond it.
            const auto& CS = book_.come_short;
            if (winger && ratings_[slot][CS.bit()] > 0 &&
                cx < Fixed64::zero() && carrier.pos.y * side > Fixed64::zero() &&
                mx - cx >= CS.gap() && applies(slot, CS.bit(), sec)) {
                const Vec2 t{(cx + CS.ahead()) * sgn2, anchor.y};
                out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
                out.why = Why::ComeShort;
                out.target = t;
                out.other = static_cast<std::int16_t>(*ball.owner);
                return out;
            }
            // The midfielder checks in (183): marked, the ball far_m+ behind
            // him — show for it show_m from the ball, on the line between.
            const auto& CI = book_.check_in;
            if (mid && ratings_[slot][CI.bit()] > 0 &&
                cx < mx && distSq(me.pos, carrier.pos) >= CI.far() * CI.far()) {
                bool marked = false, shown = false;
                const Fixed64 t2 = CI.tight() * CI.tight();
                const Fixed64 s2 = (CI.show() + Fixed64::fromInt(3)) * (CI.show() + Fixed64::fromInt(3));
                for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                    if (j == slot || j == *ball.owner) continue;
                    const bool mate = setup_.team_of_slot[j] == setup_.team_of_slot[slot];
                    if (!mate && distSq(world.player(j).pos, me.pos) < t2) marked = true;
                    if (mate && !world.isKeeper(j) && distSq(world.player(j).pos, carrier.pos) < s2) shown = true;
                }
                if (marked && !shown && applies(slot, CI.bit(), sec)) {
                    const Vec2 d{me.pos.x - carrier.pos.x, me.pos.y - carrier.pos.y};
                    const Fixed64 len = math::length(d);
                    const Vec2 t{carrier.pos.x + d.x * CI.show() / len, carrier.pos.y + d.y * CI.show() / len};
                    out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
                    out.why = Why::CheckIn;
                    out.target = t;
                    out.other = static_cast<std::int16_t>(*ball.owner);
                    return out;
                }
            }
        }

        // ── attack the box (cross-zone-runs, 100, G5.9 §8.107) [coaching:
        // "three runners, three zones" — near post, far post, penalty spot]:
        // our ball wide (|y| 14 m+) within 18 m of their line, the three
        // most advanced men go; 18-30 m out, the most advanced one. Real
        // (DFL tracking, ball wide inside 18 m): 2.2 attackers in the box,
        // 1.1 in the 3-13 m central zone; the game had 1.3 and 0.25.
        if (box_runners_near_ > 0 || box_runners_far_ > 0) {
            const Fixed64 tl = half_x_ - carrier.pos.x * sgn2;
            const Fixed64 by = carrier.pos.y;
            const Fixed64 aby = math::fx_abs(by);
            const std::int64_t want = aby < Fixed64::fromInt(14) ? 0
                                      : tl < Fixed64::fromInt(18) ? box_runners_near_
                                      : tl < Fixed64::fromInt(30) ? box_runners_far_ : 0;
            if (want > 0) {
                int rank = 0;
                const Fixed64 my_prog = me.pos.x * sgn2;
                for (SlotIndex i = 0; i < world.playerCount(); ++i) {
                    if (i == slot || i == *ball.owner || world.isKeeper(i)) continue;
                    if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
                    const Fixed64 pr = world.player(i).pos.x * sgn2;
                    if (pr > my_prog || (pr == my_prog && i < slot)) ++rank;
                }
                if (rank < want) {
                    const Fixed64 side = by.raw >= 0 ? Fixed64::one() : -Fixed64::one();
                    // rank 0 near post, 1 far post, 2 the penalty spot
                    const Fixed64 zx = rank == 0 ? Fixed64::fromInt(5) : rank == 1 ? Fixed64::fromInt(6) : Fixed64::fromInt(11);
                    const Fixed64 zy = rank == 0 ? side * Fixed64::fromInt(3) : rank == 1 ? -side * Fixed64::fromInt(4) : Fixed64::zero();
                    const Vec2 to{(half_x_ - zx) * sgn2, zy};
                    out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 2));
                    out.why = Why::AttackBox;
                    out.target = to;
                    out.other = static_cast<std::int16_t>(*ball.owner);
                    return out;
                }
            }
        }

        // ── run in behind (G4.8): the most ADVANCED disciplined attacker
        // attacks the space beyond their last outfield defender — the
        // run that makes the over-the-top ball a weapon and drags their
        // line deep. Ball-watchers (swarm ≥ 40) never make it.
        // counter_attack (bit 23, G4.18): during the fast-break window a
        // SECOND runner joins — moment 4 is arriving in NUMBERS before
        // their shape reforms; one runner the recovering line can track.
        {
            int more_adv = 0;
            const Fixed64 my_prog = me.pos.x * sgn2;
            for (SlotIndex i = 0; i < world.playerCount(); ++i) {
                if (i == slot || i == *ball.owner) continue;
                if (setup_.team_of_slot[i] != setup_.team_of_slot[slot])
                    continue;
                if (world.isKeeper(i)) continue;
                const Fixed64 pr = world.player(i).pos.x * sgn2;
                if (pr > my_prog || (pr == my_prog && i < slot))
                    ++more_adv;
            }
            const bool runs_now =
                (more_adv == 0 && applies(slot, 5, world.tickCount() / 30)) ||
                (more_adv == 1 && inCounterWindow(slot, world) &&
                 applies(slot, 23, world.tickCount() / 30));
            if (runs_now) {
                Fixed64 their_line = Fixed64::fromInt(-1000);
                for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                    if (setup_.team_of_slot[j] ==
                        setup_.team_of_slot[slot])
                        continue;
                    if (world.isKeeper(j)) continue;
                    const Fixed64 depth = world.player(j).pos.x * sgn2;
                    if (depth > their_line) their_line = depth;
                }
                // Ride the LINE, not the space behind it — offside now
                // exists, so the run is timed by the pass (ball in
                // flight = loose-ball chase takes over). Half a metre
                // onside for safety; perception delay makes weaker
                // players misjudge exactly this margin.
                Fixed64 run_x = (their_line - Fixed64::fromFraction(1, 2)) * sgn2;
                const Fixed64 cap = half_x_ - Fixed64::fromInt(8);
                if (run_x * sgn2 > cap) run_x = cap * sgn2;
                // Attack the channel between ball and goal centre.
                const Fixed64 run_y = seen_ball.y * Fixed64::fromFraction(1, 2);
                out.move.move = seek(me.pos, Vec2{run_x, run_y},
                                     Fixed64::fromFraction(1, 2));
                out.why = Why::RunInBehind;
                out.target = Vec2{run_x, run_y};
                out.other = static_cast<std::int16_t>(*ball.owner);
                return out;
            }
        }

        // Support ranking among remaining attackers (carrier excluded).
        int closer_to_carrier = 0;
        const Fixed64 mine_d = distSq(me.pos, carrier.pos);
        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
            if (i == slot || i == *ball.owner) continue;
            if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
            const Fixed64 d = distSq(world.player(i).pos, carrier.pos);
            if (d < mine_d || (d == mine_d && i < slot)) ++closer_to_carrier;
        }

        // ── back outlet (G4.8): second-nearest sits 8 m goal-side of the
        // carrier — the safety valve that completes the passing triangle.
        if (closer_to_carrier == 1 && applies(slot, 4, world.tickCount() / 30)) {
            out.move.move = seek(
                me.pos,
                Vec2{carrier.pos.x - sgn2 * Fixed64::fromInt(8),
                     carrier.pos.y * Fixed64::fromFraction(3, 4)},
                kArriveRadius);
            out.why = Why::Outlet;
            out.target = Vec2{carrier.pos.x - sgn2 * Fixed64::fromInt(8), carrier.pos.y * Fixed64::fromFraction(3, 4)};
            out.other = static_cast<std::int16_t>(*ball.owner);
            return out;
        }

        const bool im_support =
            closer_to_carrier == 0 && ratings_[slot][3] > 0;
        if (im_support) {
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        // Candidate spots: 12 m goalward of the carrier, offset ±8 m wide;
        // pick the side with the more open spot (fewer close opponents).
        auto openness = [&](const Vec2& spot) {
            Fixed64 nearest = Fixed64::fromInt(1000);
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                const Vec2 d{world.player(j).pos.x - spot.x,
                             world.player(j).pos.y - spot.y};
                const Fixed64 dd = math::lengthSquared(d);
                if (dd < nearest) nearest = dd;
            }
            return nearest;  // bigger = more open
        };
        const Fixed64 ahead = carrier.pos.x + sgn * Fixed64::fromInt(12);
        const Vec2 left{ahead, carrier.pos.y - Fixed64::fromInt(8)};
        const Vec2 right{ahead, carrier.pos.y + Fixed64::fromInt(8)};
        const Vec2 spot = openness(left) >= openness(right) ? left : right;
        out.move.move = seek(me.pos, spot, kArriveRadius);
        out.why = Why::Support;
        out.target = spot;
        out.other = static_cast<std::int16_t>(*ball.owner);
        return out;
        }
    }

    // spread_wide (James's law, attacking half): "the bunching of the
    // offense is what stops goals" — so the coached attack UN-bunches.
    // In possession, wide-based players hold real width, stretching the
    // defense laterally regardless of the ball-shift pull.
    // G5.7 (§8.105, concept.width.far_one): with the ball on the far side
    // only the highest wide man holds width there, at far_wide_m at most;
    // the rest take their shifted spot. [FH; DFL tracking: ball wide, real
    // sides keep one man wide on the far side (-16.6 m), the next at -7.5 m;
    // every wide man holding width put two on the far touchline.]
    bool far_free = false;
    Fixed64 far_wide = Fixed64::zero();
    if (ours && width_far_one_ && math::fx_abs(seen_ball.y) > Fixed64::fromInt(15) &&
        (seen_ball.y.raw > 0) != (mine.base.y.raw > 0) &&
        math::fx_abs(mine.base.y) > Fixed64::fromFraction(40, 100)) {
        const auto& ps = spec_[my_team].positions;
        const Fixed64 my_x = mine.base.x;
        for (const auto& q : ps)
            if (!q.keeper && (q.base.y.raw > 0) == (mine.base.y.raw > 0) &&
                math::fx_abs(q.base.y) > Fixed64::fromFraction(40, 100) && q.base.x > my_x)
                far_free = true;   // a higher man holds the width
        far_wide = width_far_m_;
    }
    if (ours && ratings_[slot][13] > 0 && !far_free &&
        math::fx_abs(mine.base.y) > Fixed64::fromFraction(40, 100)) {
        Fixed64 wide = Fixed64::fromInt(10) +
                       Fixed64::fromInt(16) * degree(slot, 13);
        if (far_wide.raw > 0 && wide > far_wide) wide = far_wide;
        if (mine.base.y.raw >= 0) {
            if (anchor.y < wide) anchor.y = wide;
        } else {
            if (anchor.y > -wide) anchor.y = -wide;
        }
    }

    // ── otherwise: hold the shifted anchor (shape IS support) ──────────
    // Settled within 0.5 m: anchors are ball-relative approximations that
    // wobble with every touch; chasing the wobble read as shuffling and
    // body-spinning (5,312 same-branch reversals in 40 measured minutes).
    out.move.move = seek(me.pos, anchor, kArriveRadius,
                         Fixed64::fromFraction(1, 2));
    out.why = Why::Hold;
    out.target = anchor;
    return out;
}

}  // namespace fh::game::ai
