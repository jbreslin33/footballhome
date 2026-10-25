// game/src/ai/Brain.cpp

#include "ai/Brain.hpp"

#include "ai/Formation.hpp"
#include "core/Ball.hpp"
#include "core/Levels.hpp"

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

// Arrive steering [Reynolds, via Buckland]: full speed outside the arrive
// radius, then desire ramps DOWN continuously to zero at the settle
// radius (World moves at |desire| x max_speed). The old bang-bang version
// (full speed / dead stop) had every off-ball player tracking a drifting
// anchor stop-start ~3-4x per second — James: "players jitter"; the
// harness measured ~4,000 go-stop flickers/min per match. The ramp's
// per-tick step is always shorter than the gap (never overshoots) and is
// continuous at both radii (no start-stop edge). Inside settle: stand —
// a near-zero vector would spin the body to face it.
Vec2 seek(const Vec3& from, const Vec2& to, Fixed64 arrive,
          Fixed64 settle = Fixed64::fromFraction(1, 20)) {
    const Vec2 d{to.x - from.x, to.y - from.y};
    const Fixed64 dsq = math::lengthSquared(d);
    if (dsq >= arrive * arrive) return math::normalized(d);
    if (dsq <= settle * settle) return Vec2{};
    const Fixed64 len = math::length(d);
    const Fixed64 k = (len - settle) / ((arrive - settle) * len);
    return Vec2{d.x * k, d.y * k};
}

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

// Earliest-reach interception of a rolling free ball (G4.14): walk the
// ball's deterministic friction path in 6-tick strides and aim at the
// FIRST point the chaser can reach by the time the ball does. Aiming at
// the ball's current spot is always a step behind; G4.3's naive fixed
// lead aimed PAST the catchable point and measured worse at every level
// (negative result recorded) — the bounded scan can do neither.
Vec2 interceptPoint(const World& world, SlotIndex me, const Vec3& ball_pos,
                    const Vec3& ball_vel) {
    const Vec3& my_pos = world.player(me).pos;
    Vec2 pos{ball_pos.x, ball_pos.y};
    Vec2 vel{ball_vel.x, ball_vel.y};
    Fixed64 t = Fixed64::zero();
    const Fixed64 stride = core::kTickDt * Fixed64::fromInt(6);
    for (int step = 0; step < 8; ++step) {  // 48 ticks = 1.6 s lookahead
        for (int k = 0; k < 6; ++k) {
            pos = Vec2{pos.x + vel.x * core::kTickDt,
                       pos.y + vel.y * core::kTickDt};
            vel = Vec2{vel.x * core::kBallRollDecayPerTick,
                       vel.y * core::kBallRollDecayPerTick};
        }
        t += stride;
        const Vec2 d{pos.x - my_pos.x, pos.y - my_pos.y};
        const Fixed64 run = runToward(world, me, pos, t) + Fixed64::one();
        if (math::lengthSquared(d) <= run * run) return pos;
    }
    // Not reachable inside the scan: chase where it is, as before.
    return Vec2{ball_pos.x, ball_pos.y};
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

// Pass safety [Buckland] (G4.19): the PASSER runs the interceptor's own
// closing-speed math. Walk the ground pass's friction path (3-tick
// strides) until it reaches the receiver; the pass is unsafe if any
// opponent can reach a point on it by the time the ball does —
// his locomotion reach over (t - reaction) + reach (G4.51; was
// max_speed x (t - reaction)) — BEFORE the receiver, stepping to
// meet it, gets there first (opponents checked first per stride: ties go
// to the defender, the cautious read). The static 2 m corridor alone let
// G4.14's earliest-reach defenders read every pass: world matches
// measured 2,230 balls collected by the other side (2.2 s possessions).
bool passSafe(const World& world, const TeamSetup& setup, SlotIndex passer,
              SlotIndex receiver, const Vec2& from, const Vec2& to,
              Fixed64 speed, Fixed64 reach) {
    const Vec2 ab{to.x - from.x, to.y - from.y};
    const Fixed64 len = math::length(ab);
    if (len.raw == 0) return true;
    const Vec2 dir{ab.x / len, ab.y / len};
    const Fixed64 reaction = Fixed64::fromFraction(1, 5);  // 0.2 s
    Vec2 pos = from;
    Fixed64 s = speed, travelled = Fixed64::zero(), t = Fixed64::zero();
    for (int stride = 0; stride < 30; ++stride) {  // 90 ticks = 3 s
        for (int k = 0; k < 3; ++k) {
            const Fixed64 step = s * core::kTickDt;
            pos = Vec2{pos.x + dir.x * step, pos.y + dir.y * step};
            travelled += step;
            s = s * core::kBallRollDecayPerTick;
        }
        t += core::kTickDt * Fixed64::fromInt(3);
        const Fixed64 react_t =
            t > reaction ? t - reaction : Fixed64::zero();
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup.team_of_slot[j] == setup.team_of_slot[passer])
                continue;
            const auto& o = world.player(j);
            const Vec2 d{o.pos.x - pos.x, o.pos.y - pos.y};
            const Fixed64 run = runToward(world, j, pos, react_t) + reach;
            if (math::lengthSquared(d) <= run * run) return false;
        }
        const auto& r = world.player(receiver);
        const Vec2 dr{r.pos.x - pos.x, r.pos.y - pos.y};
        const Fixed64 rrun = runToward(world, receiver, pos, react_t) + reach;
        if (math::lengthSquared(dr) <= rrun * rrun) return true;
        if (travelled >= len) return true;  // arrived at the receiver
    }
    return false;  // dies short of the receiver
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
Loft loftTo(const core::PlayerState& mate, const Vec3& from, Fixed64 max_m) {
    Vec2 at{mate.pos.x, mate.pos.y};
    Fixed64 d{};
    for (int k = 0; k < 3; ++k) {
        d = math::length(Vec2{at.x - from.x, at.y - from.y});
        if (d > max_m) d = max_m;
        if (d < Fixed64::one()) d = Fixed64::one();
        const Fixed64 two_r = core::kLoftLaunchRatio * 2;
        const Fixed64 v = math::fx_sqrt(core::kGravity * d / two_r);
        const Fixed64 t = two_r * v / core::kGravity;
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
    const SlotIndex n = world.playerCount();
    f.tick.assign(n, -1);
    f.at.assign(n, Vec2{});
    f.first[0] = f.first[1] = -1;
    f.live = !b.owner && world.restartTeam() == 0xFF;
    if (!f.live) return f;

    // Each man starts after his reaction (+ his perception delay).
    Fixed64 react[64];
    for (SlotIndex i = 0; i < n && i < 64; ++i)
        react[i] = book_.meet_the_pass.reaction() +
                   Fixed64::fromInt(levelOf(i).perception_delay_ticks) * core::kTickDt;
    const Fixed64 box_x = half_x_ - Fixed64::fromFraction(33, 2);   // 16.5 m
    const Fixed64 box_y = Fixed64::fromFraction(2016, 100);          // 20.16 m
    const std::uint32_t flagged = world.offsideMask();
    const std::uint8_t flag_team = world.offsideTeam();
    Vec3 pos = b.pos, vel = b.vel;
    int open = n;
    const int horizon = book_.meet_the_pass.horizonTicks();
    for (int k = 0; k <= horizon && open > 0; ++k) {
        if (k > 0) {  // World::tickFreeBall, one tick
            if (pos.z.raw > 0 || vel.z.raw != 0) vel.z -= core::kGravity * core::kTickDt;
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
            if (i == b.last_kicker && k < b.kicker_lockout) continue;
            const auto& p = world.player(i);
            // A man in an offside position leaves it (the flag decides).
            if (flag_team != 0xFF && p.team == flag_team && ((flagged >> (i & 31)) & 1u)) continue;
            const bool gk = world.isKeeper(i);
            if (pos.z > (gk ? core::kKeeperReachZ : core::kBallControlRadius)) continue;
            const Fixed64 cap = gk ? core::kCaptureMaxSpeed + core::kKeeperHandsBonus : core::kCaptureMaxSpeed;
            if (sp2 > cap * cap) continue;
            if (gk) {  // hands only in his own box
                const bool own_end = setup_.team_of_slot[i] == 0 ? pos.x < -box_x : pos.x > box_x;
                if (!own_end || math::fx_abs(pos.y) > box_y) continue;
            }
            const Fixed64 rt = t > react[i] ? t - react[i] : Fixed64::zero();
            const Fixed64 run = runToward(world, i, Vec2{pos.x, pos.y}, rt) +
                                (gk ? core::kKeeperReach : core::kBallControlRadius);
            if (distSq(p.pos, pos) <= run * run) {
                f.tick[i] = static_cast<std::int16_t>(k);
                f.at[i] = Vec2{pos.x, pos.y};
                --open;
            }
        }
    }
    for (SlotIndex i = 0; i < n; ++i) {
        if (f.tick[i] < 0) continue;
        int& first = f.first[setup_.team_of_slot[i]];
        if (first < 0 || f.tick[i] < f.tick[first]) first = i;
    }
    return f;
}

Orders Brain::ordersFor(SlotIndex slot, const World& world) const {
    Orders o = decide(slot, world);
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
        case Why::Human: case Why::DropStep:
            return o;   // these face where they're going
        default: break;
    }
    const int bit = book_.face_the_play.bit();
    if (ratings_[slot][bit] <= 0 || !applies(slot, bit, world.tickCount() / 30)) return o;
    if (!short_move) return o;
    o.move.face = to_ball;
    return o;
}

Orders Brain::decide(SlotIndex slot, const World& world) const {
    Orders out;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    const int sign = attackSign(slot);

    // The flight read for the line's concepts (G4.49).
    auto withFlight = [&](ConceptContext& cx) {
        if (ball.owner || world.restartTeam() != 0xFF) return;
        const FlightRead& fr = flightRead(world);
        const int a = fr.first[0], b = fr.first[1];
        const int win = a < 0 ? b : (b < 0 || fr.tick[a] <= fr.tick[b] ? a : b);
        if (win < 0) return;
        cx.flight_first = setup_.team_of_slot[win];
        cx.flight_at = fr.at[win];
    };

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
        if (shoot_now && applies(slot, 25, world.tickCount() / 30) &&
            math::lengthSquared(to_goal) >= Fixed64::fromInt(64)) {
            const Fixed64 bar = pressed ? Fixed64::fromFraction(18, 100)
                                        : Fixed64::fromFraction(30, 100);
            shoot_now = chanceQuality(world, setup_, slot, goal) >= bar;
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

        // Best forward receiver with an open lane. Progress = x toward MY
        // goal; deterministic tie-break by slot order (iteration order).
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        const Fixed64 my_progress = me.pos.x * sgn;
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
            if (!reads || lofted) return true;
            const Fixed64 v = dsq < kSoftPassRange * kSoftPassRange
                                  ? core::kShortPassSpeed
                                  : core::kGroundKickSpeed;
            return passSafe(world, setup_, slot, recv, a, b, v, safe_reach);
        };
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
        const auto lines = (ladder || release) ? book_.pass_ladder.lines(world, slot, sign)
                                               : PassLadder::Lines{};
        const bool holding = release &&
            book_.release_timing.hold(world, slot, sign, lines, book_.pass_ladder);
        int best_rung = 0;
        bool have_target = false;
        Fixed64 best_progress{};
        Vec2 target{};
        Fixed64 target_dist_sq{};
        SlotIndex target_slot = 0;
        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
            if (i == slot) continue;
            if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
            const auto& mate = world.player(i);
            Vec2 b{mate.pos.x, mate.pos.y};
            // G4.36: a laddered passer never picks a man in an offside
            // position, and plays an onside runner into the space he is
            // running into (rungs 1-2 are a ball into space) [Bielsa-Leeds].
            if (ladder) {
                if (PassLadder::offsidePosition(mate.pos.x * sgn, my_progress, lines))
                    continue;
                const Vec2 lead = book_.pass_ladder.leadPoint(mate, me.pos);
                if (lead.x * sgn > lines.back && lead.x * sgn > b.x * sgn) b = lead;
            }
            const Fixed64 progress = b.x * sgn;
            if (progress < my_progress + Fixed64::fromInt(3)) continue;
            const Fixed64 dsq = distSq(me.pos, Vec3{b.x, b.y, Fixed64::zero()});
            if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax)
                continue;
            // Lane check: any opponent near the carrier→mate segment?
            const Vec2 a{me.pos.x, me.pos.y};
            if (!lane_open(a, b)) continue;
            const bool lofted = progress > their_line &&
                                ratings_[slot][6] > 0 &&
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
            const ConceptContext pcx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                     half_x_, degree(slot, pass_choice)};
            const bool liked = ratings_[slot][29] == 0 || applies(slot, 29, world.tickCount() / 30);
            const bool longball = pass_choice == book_.direct_ball.bit();
            const auto r = longball ? book_.direct_ball.pick(pcx) : book_.short_simple.pick(pcx, lane_open);
            if (r) {
                Vec2 to{world.player(*r).pos.x, world.player(*r).pos.y};
                if (longball) {
                    // Dropped where he'll be (G4.48), not hit at where he is.
                    const Loft lf = loftTo(world.player(*r), me.pos, rangeFor(lv, book_.direct_ball.maxRange()));
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
            if (beyond_line && applies(slot, 6, world.tickCount()) &&
                target_dist_sq > kSoftPassRange * kSoftPassRange) {
                out.action = Action::LoftedKick;  // over the top
                // Dropped into his run (G4.48): the preset chip bounced on
                // ~45 m past a 20 m runner.
                const Loft lf = loftTo(world.player(target_slot), me.pos, rangeFor(lv, book_.direct_ball.maxRange()));
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
                if (setup_.team_of_slot[i] != setup_.team_of_slot[slot])
                    continue;
                const auto& mate = world.player(i);
                const Fixed64 dsq = distSq(me.pos, mate.pos);
                if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax)
                    continue;
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
        // Holding for a runner (release_timing): slow the ball down — a
        // walking carry keeps it, a sprint into the block loses it.
        if (holding) {
            const Fixed64 walk = Fixed64::fromFraction(35, 100);
            out.move.move = Vec2{out.move.move.x * walk, out.move.move.y * walk};
        }
        const bool keeps_it =
            reads && me.pos.x * sgn > -half_x_ + Fixed64::fromInt(35);
        if (pressed && !keeps_it) {
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
            if (touch_tight) {
                if (math::lengthSquared(to_goal) < kShootRange * kShootRange) {
                    out.action = Action::Shot;
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
                    const Vec2 to{ax * sgn, crowd[0] <= crowd[1] ? -ay : ay};
                    out.move.move = seek(me.pos, to, Fixed64::fromFraction(1, 10));
                    out.action = Action::LoftedKick;
                    out.carry_m = aimedCarry(me.pos, to, rangeFor(lv, Fixed64::fromInt(50)));
                }
            }
        }
        out.why = out.action == Action::Shot ? Why::Shoot : (out.action == Action::LoftedKick ? Why::Clear : (holding ? Why::WaitForRunner : Why::Dribble));
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
    if (!ball.owner && world.restartTeam() == 0xFF && world.lastTouchTeam() == my_team &&
        ratings_[slot][meet] > 0 && applies(slot, meet, world.tickCount() / 30)) {
        const FlightRead& fr = flightRead(world);
        const int mine_first = fr.first[my_team], theirs = fr.first[my_team ^ 1];
        if (mine_first >= 0) {
            flight_ours = theirs < 0 || fr.tick[mine_first] < fr.tick[theirs];
            if (mine_first == slot) {
                out.move.move = seek(me.pos, fr.at[slot], Fixed64::fromFraction(1, 10));
                out.why = Why::MeetPass;
                out.target = fr.at[slot];
                return out;
            }
        }
    }
    const bool ours =
        (ball.owner && setup_.team_of_slot[*ball.owner] == my_team) || flight_ours;

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

    // ── defensive shape (G4.4, James's law: "the thing that stops goals
    // really is the bunching") ──────────────────────────────────────────
    // Without the ball, the SHAPE defends, not the keeper:
    //   1. Compactness: nobody holds an anchor more than ~10 m upfield of
    //      the ball — the whole block drops goal-side as play advances.
    //   2. Depth cover: the back line (deep bases) tracks the deepest
    //      opponent, killing the run in behind (no offside law yet, so
    //      the last man MUST mind the space).
    //   3. Cover man: the second-closest defender sits on the ball→goal
    //      line ~7 m goal-side of the ball — a beaten press is met by
    //      cover, not a breakaway.
    if (!ours && !mine.keeper) {
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        // My goal is at -sgn * half_x. "Deep" = small x*sgn.
        // 1. Compactness cap: anchor_x*sgn <= ball_x*sgn + 10.
        const Fixed64 press_line = seen_ball.x * sgn + Fixed64::fromInt(10);
        if (anchor.x * sgn > press_line) {
            anchor.x = press_line * sgn;
        }
        // 2. Depth cover for the back line (bases at or behind -55%):
        //    stay goal-side of the deepest opponent by 2 m.
        if (mine.base.x <= Fixed64::fromFraction(-55, 100)) {
            Fixed64 deepest = Fixed64::fromInt(1000);  // in x*sgn terms
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                const Fixed64 depth = world.player(j).pos.x * sgn;
                if (depth < deepest) deepest = depth;
            }
            Fixed64 cover = deepest - Fixed64::fromInt(2);
            // HOLD THE LINE: never drop more than 25 m behind the ball.
            // Without this floor, a line-riding runner and a man-tracking
            // back line retreat-spiral each other into the goalmouth
            // (measured: 0 offsides, goals UP after the offside law
            // landed). Holding makes the runner's timing problem real —
            // beyond this line he's offside when the ball is struck.
            if (ratings_[slot][9] > 0) {
                // push_up (15) squeezes the hold distance: 25 m at 0 →
                // 12 m at 100 — "the white line steps up" [James].
                const Fixed64 dist =
                    Fixed64::fromInt(25) -
                    Fixed64::fromInt(13) * degree(slot, 15);
                const Fixed64 hold = seen_ball.x * sgn - dist;
                if (cover < hold) cover = hold;
            }
            // line-step (bit 28, G4.33) [Sacchi palla coperta / scoperta;
            // James: "when ball is moving push up and stop as opp is
            // receiving and can play long. push up if opp is turned toward
            // their own goal with ball"] — ai::LineStep.
            if (ratings_[slot][28] > 0 && applies(slot, 28, world.tickCount() / 30)) {
                ConceptContext cx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                        half_x_, degree(slot, 28)};
                withFlight(cx);
                if (auto line = book_.line_step.stepLine(cx)) {
                    if (cover < *line) cover = *line;          // leave the runner offside
                    if (anchor.x * sgn < *line) anchor.x = *line * sgn;  // and STEP UP
                }
            }
            if (anchor.x * sgn > cover) anchor.x = cover * sgn;
            // Never retreat into the goal itself.
            const Fixed64 floor_x = -(half_x_ - Fixed64::fromInt(4));
            if (anchor.x * sgn < floor_x) anchor.x = floor_x * sgn;
        }
        // 3. Cover man: second-closest to the ball shadows the ball→goal
        //    line, 7 m goal-side.
        if (teamCloserCount(slot, world, seen_ball) == 1 &&
            applies(slot, 12, world.tickCount() / 30) && ball.owner &&
            math::fx_abs(seen_ball.y) > Fixed64::fromInt(22)) {
            // double_team: the touchline is the extra defender — when the
            // carrier is pinned wide, the cover man CONVERGES instead of
            // sitting off, and the trap closes.
            anchor = Vec2{seen_ball.x, seen_ball.y};
        } else if (teamCloserCount(slot, world, seen_ball) == 1 &&
            ratings_[slot][2] > 0) {
            const Vec2 own_goal{-sgn * half_x_, Fixed64::zero()};
            const Vec2 to_goal{own_goal.x - seen_ball.x,
                               own_goal.y - seen_ball.y};
            const Fixed64 len = math::length(to_goal);
            if (len > Fixed64::fromInt(1)) {
                const Fixed64 k = Fixed64::fromInt(7) / len;
                anchor = Vec2{seen_ball.x + to_goal.x * k,
                              seen_ball.y + to_goal.y * k};
            }
        }
    }

    // ── swarm (G4.4, James's law #2): low-discipline levels collapse
    // toward the ball in BOTH phases — crowding their own attack and
    // accidentally barricading their goal. Keepers exempt.
    if (lv.swarm_pct > 0 && !mine.keeper) {
        const Fixed64 f = Fixed64::fromFraction(lv.swarm_pct, 100);
        anchor = Vec2{anchor.x + (seen_ball.x - anchor.x) * f,
                      anchor.y + (seen_ball.y - anchor.y) * f};
    }

    // ── loose ball: nearest teammate goes for it ────────────────────────
    // ── their ball: nearest teammate presses the carrier ────────────────
    // Opponent's dead ball (G3.2): we can't touch it — hold shape and
    // defend the restart instead of crowding an untakeable ball.
    const std::uint8_t restart = world.restartTeam();
    const bool opponents_restart =
        restart != 0xFF && restart != setup_.team_of_slot[slot];
    // Defending (James's model): DELAY buys time → ORGANIZE into marks +
    // a free man → with superiority behind the ball, someone STEPS (and
    // may dive in; outcome resolves in World::tickTackles). "At an
    // advanced level delay is to gain superiority while transitioning to
    // defense; once you have marking and a free man, someone steps to
    // ball." Low-discipline sides skip the theory and dive straight in.
    if (!ours && !opponents_restart) {
        const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        // cover_shadow (bit 27, G4.33) [Bielsa; James: "the lh 9 should
        // look to cover shadow press the ball carrying cb"] — ai::CoverShadow.
        if (ratings_[slot][27] > 0 && applies(slot, 27, world.tickCount() / 30)) {
            const ConceptContext cx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                    half_x_, degree(slot, 27)};
            if (auto t = book_.cover_shadow.target(cx)) {
                out.move.move = seek(me.pos, *t, Fixed64::fromFraction(3, 10));
                out.why = Why::CoverShadow;
                out.target = *t;
                out.other = ball.owner ? static_cast<std::int16_t>(*ball.owner) : static_cast<std::int16_t>(-1);
                return out;
            }
        }
        int mates_behind = 0, opps_behind = 0;
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            const bool behind =
                world.player(j).pos.x * dsgn < seen_ball.x * dsgn;
            if (setup_.team_of_slot[j] == setup_.team_of_slot[slot]) {
                if (behind) ++mates_behind;
            } else if (behind) {
                ++opps_behind;
            }
        }
        const bool organized = mates_behind >= opps_behind + 1;
    // Dive eagerness, in TENTHS of the old %-scale (the integer math at
    // the restraint-scaled magnitudes was rounding away most of the
    // suppression). Two graded concepts compose here:
    // - restraint (bit 21, G4.16): the anti-tackle. All dives scale down
    //   with the rating — full rash rate at 0, a fifth of it at 100. The
    //   floor keeps the STEP real: organized teams still step in.
    // - tackle_timing (bit 22, G4.17): dive on the exposed ball, not on
    //   faith. The carried ball rides AHEAD of the carrier's facing, so a
    //   defender in the carrier's front half-plane pokes through the
    //   ball; a lunge from behind goes through the man. Rated players
    //   suppress the from-behind dive hard (x0.1 at 100) and keep the
    //   ball-side dive at the restraint-scaled rate — volume falls and
    //   the dives that remain are the clean ones.
    auto dive_eagerness = [&](int base) {
        int e = base * 10;
        e -= e * ratings_[slot][21] * 4 / 500;  // restraint: 100 → x0.2
        const int t = ratings_[slot][22];
        if (t > 0 && ball.owner) {
            const auto& c = world.player(*ball.owner);
            const Fixed64 dot = c.face.x * (me.pos.x - c.pos.x) +
                                c.face.y * (me.pos.y - c.pos.y);
            if (dot.raw <= 0) e -= e * t * 9 / 1000;  // behind: 100 → x0.1
        }
        return e;
    };

        // Knowledge gates (CONCEPTS.md): what THIS player knows decides
        // which branches exist for him. undisciplined = lacks the delay
        // theory; a coached kid on a swarm team keeps his head.
        // Graded knowledge: the delay THEORY is known at all only above
        // 0; its per-moment application rolls against the rating.
        const bool undisciplined = ratings_[slot][0] == 0;

        // counter_press (G4.11, KNVB moment 3 / gegenpress): for ~3 s
        // after WE lose the ball, the nearby disciplined player hunts it
        // regardless of organization — win it back before they settle.
        // Window scales with the rating.
        if (world.lastLosingTeam() == setup_.team_of_slot[slot] &&
            ratings_[slot][16] > 0) {
            const std::uint64_t since =
                world.tickCount() - world.turnoverTick();
            const std::uint64_t window =
                10 + static_cast<std::uint64_t>(ratings_[slot][16]);
            if (since < window &&
                distSq(me.pos, seen_ball) < Fixed64::fromInt(400) &&
                teamCloserCount(slot, world, seen_ball) < 2) {
                out.move.move = seek(me.pos,
                                     Vec2{seen_ball.x, seen_ball.y},
                                     Fixed64::fromFraction(1, 10));
                // Impulse semantics: dives are a PER-TICK RATE (the
                // eagerness dial), never a per-tick probability equal to
                // the rating — rating 68 as %/tick produced 8k-tackle
                // matches. Ratings gate WHETHER you counter-press and for
                // HOW LONG; indiscipline still sets how rashly you dive.
                if (ball.owner &&
                    distSq(me.pos, ball.pos) <
                        core::kTackleReach * core::kTackleReach) {
                    const Fixed64 n2 = core::detNoise(
                        match_seed_, world.tickCount(), slot, 9);
                    const int eag = dive_eagerness(4 + lv.swarm_pct / 2);
                    if ((n2 + Fixed64::one()) <
                        Fixed64::fromFraction(eag, 500)) {
                        out.action = Action::Tackle;
                    }
                }
                out.why = Why::CounterPress;
                out.target = Vec2{seen_ball.x, seen_ball.y};
                out.other = ball.owner ? static_cast<std::int16_t>(*ball.owner) : static_cast<std::int16_t>(-1);
                return out;
            }
        }

        // Traffic tackles: ANY defender (not just the engaged presser)
        // dives when an opponent carries into their reach — provided the
        // team has earned the step (organized) or doesn't know better
        // (undisciplined). This is what makes dribbling INTO the dropped
        // block dangerous; without it the block was furniture.
        if (ball.owner && (organized || undisciplined) && !mine.keeper &&
            distSq(me.pos, ball.pos) <
                core::kTackleReach * core::kTackleReach) {
            const Fixed64 n =
                core::detNoise(match_seed_, world.tickCount(), slot, 7);
            const int eagerness = dive_eagerness(4 + lv.swarm_pct / 2);
            if ((n + Fixed64::one()) < Fixed64::fromFraction(eagerness, 500)) {
                out.move.move = seek(me.pos, Vec2{ball.pos.x, ball.pos.y},
                                     Fixed64::fromFraction(1, 10));
                out.action = Action::Tackle;
                out.why = Why::Tackle;
                out.target = Vec2{ball.pos.x, ball.pos.y};
                out.other = ball.owner ? static_cast<std::int16_t>(*ball.owner) : static_cast<std::int16_t>(-1);
                return out;
            }
        }

        // recover_goal_side: I'm upfield of the ball (beaten) — the
        // coached run is to the COVER LINE between ball and goal, never
        // straight at the ball. Kids chase; defenders recover.
        // Only a player whose SHAPE belongs goal-side of the ball is
        // "beaten": a forward's anchor is upfield, and recover vs. anchor
        // pulling opposite ways flip-flopped every few ticks across the
        // ball line (~5,500 reversals in 40 measured minutes).
        if (applies(slot, 11, world.tickCount() / 30) &&
            anchor.x * dsgn < seen_ball.x * dsgn &&
            me.pos.x * dsgn > seen_ball.x * dsgn + Fixed64::one() &&
            teamCloserCount(slot, world, seen_ball) >= 1) {
            const Vec2 own_goal{-dsgn * half_x_, Fixed64::zero()};
            const Vec2 tg{own_goal.x - seen_ball.x, own_goal.y - seen_ball.y};
            const Fixed64 len = math::length(tg);
            if (len > Fixed64::fromInt(1)) {
                const Fixed64 k = Fixed64::fromInt(6) / len;
                out.move.move =
                    seek(me.pos, Vec2{seen_ball.x + tg.x * k,
                                      seen_ball.y + tg.y * k},
                         Fixed64::fromFraction(1, 2));
                out.why = Why::Recover;
                out.target = Vec2{seen_ball.x + tg.x * k, seen_ball.y + tg.y * k};
                return out;
            }
        }

        const bool in_range =
            distSq(me.pos, seen_ball) < kChaseRadius * kChaseRadius;
        // Swarmy teams send a MOB at the ball, not one presser.
        const int max_chasers = 1 + lv.swarm_pct / 20;
        const int rank = teamCloserCount(slot, world, seen_ball);
        // intercept (bit 20) reads the FLIGHT (G4.49): a free ball is
        // chased by the man who reaches it first, to where he does — in the
        // air too. Rank-by-distance sent the nearest man under a 40 m ball
        // that was landing on someone else.
        bool race = false, race_first = false;
        Vec2 race_to{};
        if (!ball.owner && applies(slot, 20, world.tickCount() / 30)) {
            const FlightRead& fr = flightRead(world);
            if (fr.live && fr.first[my_team] >= 0) {
                race = true;
                race_first = fr.first[my_team] == slot;
                race_to = fr.at[slot];
            }
        }
        const bool chases = race ? (race_first || (max_chasers > 1 && in_range && rank < max_chasers))
                                 : (in_range && rank < max_chasers);
        // engage-or-contain (157, G4.54): cover behind him isn't enough —
        // step in on a trigger (cover ARRIVED close, his back to our goal,
        // pinned on the touchline); otherwise contain. Lapse: dives in.
        bool engage = organized;
        if (organized && ball.owner) {
            const int ec = book_.engage_or_contain.bit();
            if (ratings_[slot][ec] > 0 && applies(slot, ec, world.tickCount() / 30)) {
                const auto& c = world.player(*ball.owner);
                const Fixed64 cv = book_.engage_or_contain.cover();
                bool cover_here = false;
                for (SlotIndex j = 0; j < world.playerCount() && !cover_here; ++j) {
                    if (j == slot || setup_.team_of_slot[j] != my_team) continue;
                    const auto& m = world.player(j);
                    cover_here = m.pos.x * dsgn < c.pos.x * dsgn && distSq(m.pos, c.pos) < cv * cv;
                }
                const bool back_to_goal = c.face.x * dsgn > Fixed64::zero();   // facing away from our goal
                const bool pinned = math::fx_abs(c.pos.y) > half_y_ - book_.engage_or_contain.touchline();
                engage = cover_here || back_to_goal || pinned;
            }
        }
        if (chases) {
            if (!ball.owner || engage || undisciplined) {
                // STEP / loose-ball race: through the ball (arrive radius
                // far below capture radius — the harness's first catch);
                // dive in when the carried ball is inside tackle reach.
                // A rolling FREE ball is met at the earliest-reach point
                // on its friction path (closing-speed interception,
                // G4.14); a carried or flying ball is chased directly.
                Vec2 chase_to{seen_ball.x, seen_ball.y};
                // intercept (bit 20, skill class): the coached read.
                // Ungated it measured u10 22 goals (loose-ball mobs
                // arriving in sync) and world 1.9 (airtight) — the read
                // is TAUGHT, so it rolls per second like other duties.
                if (race_first)
                    chase_to = race_to;
                else if (!ball.owner &&
                    ball.pos.z < Fixed64::fromFraction(1, 2) &&
                    applies(slot, 20, world.tickCount() / 30))
                    chase_to = interceptPoint(world, slot, seen_ball, ball.vel);
                out.move.move = seek(me.pos, chase_to,
                                     Fixed64::fromFraction(1, 10));
                // Own noise channel (G4.24): this roll used channel 7 —
                // the SAME value the traffic-tackle check above had
                // already failed this tick, so the step branch's dive was
                // dead code (world: 28,748 engaged ticks, 0 tackles).
                if (ball.owner &&
                    distSq(me.pos, ball.pos) <
                        core::kTackleReach * core::kTackleReach) {
                    const Fixed64 n = core::detNoise(
                        match_seed_, world.tickCount(), slot, 13);
                    const int eagerness = dive_eagerness(4 + lv.swarm_pct / 2);
                    if ((n + Fixed64::one()) <
                        Fixed64::fromFraction(eagerness, 500)) {
                        out.action = Action::Tackle;
                    }
                }
                out.why = ball.owner ? Why::Press : Why::Chase;
                out.target = chase_to;
                out.other = ball.owner ? static_cast<std::int16_t>(*ball.owner) : static_cast<std::int16_t>(-1);
                return out;
            }
            // DELAY [v1 Jockey concept]: 2.2 m goal-side of the carrier,
            // matching laterally; no tackle from here — buy the time the
            // rest need to find their marks.
            // jockey_angle: shade a step infield of the ball so the
            // carrier's easy touch is toward the TOUCHLINE, not the
            // middle — "show them the line".
            Fixed64 shade = Fixed64::zero();
            if (ratings_[slot][10] > 0) {
                shade = (seen_ball.y.raw >= 0
                             ? -Fixed64::fromFraction(6, 5)
                             : Fixed64::fromFraction(6, 5)) *
                        degree(slot, 10);
            }
            const Vec2 jockey{
                seen_ball.x - dsgn * Fixed64::fromFraction(11, 5),
                seen_ball.y + shade};
            out.other = ball.owner ? static_cast<std::int16_t>(*ball.owner) : static_cast<std::int16_t>(-1);
            const std::uint64_t sec = world.tickCount() / 30;
            // drop-step (156, G4.54): he's coming at speed — turn and run
            // with him, goal-side on his line, instead of backpedalling.
            if (ball.owner) {
                const int ds = book_.drop_step.bit();
                const auto& c = world.player(*ball.owner);
                const Fixed64 goalward = -c.vel.x * dsgn;
                const Fixed64 w = book_.drop_step.within();
                if (ratings_[slot][ds] > 0 && goalward > book_.drop_step.carrierSpeed() &&
                    distSq(me.pos, c.pos) < w * w && applies(slot, ds, sec)) {
                    const Vec2 run = math::normalized(Vec2{c.vel.x, c.vel.y});
                    const Fixed64 lead = book_.drop_step.lead();
                    const Vec2 with{c.pos.x + run.x * lead - dsgn, c.pos.y + run.y * lead};
                    out.move.move = seek(me.pos, with, Fixed64::fromFraction(1, 10));
                    out.why = Why::DropStep;
                    out.target = with;
                    return out;
                }
            }
            out.move.move = seek(me.pos, jockey, Fixed64::fromFraction(3, 10));
            out.why = Why::Delay;
            out.target = jockey;
            // side-on-jockey (155, G4.54): body turned open toward the
            // side he shows (the touchline side the shade leaves open).
            const int so = book_.side_on_jockey.bit();
            if (ratings_[slot][so] > 0 && applies(slot, so, sec)) {
                const Vec2 to_c{seen_ball.x - me.pos.x, seen_ball.y - me.pos.y};
                if (to_c.x.raw != 0 || to_c.y.raw != 0) {
                    const Fixed64 a = book_.side_on_jockey.stance();
                    const Fixed64 ca = math::fx_cos(a), sa = math::fx_sin(a);
                    const Vec2 l{to_c.x * ca - to_c.y * sa, to_c.x * sa + to_c.y * ca};
                    const Vec2 r{to_c.x * ca + to_c.y * sa, -to_c.x * sa + to_c.y * ca};
                    const bool up = seen_ball.y.raw >= 0;   // the touchline he shows
                    out.move.face = (up ? l.y >= r.y : l.y <= r.y) ? l : r;
                    out.why = Why::SideOn;
                }
            }
            return out;
        }

        // libero (bit 26, G4.33) [Bielsa's +1; James: "free libero follow
        // ball but set themselves ready for long ball"] — ai::Libero.
        // G4.46: the roll is per lapse window; a failed roll is a LAPSE into
        // the neighbour concept he's best at (sweeping too deep / stepping
        // out too high), not the generic brain.
        if (ratings_[slot][26] > 0) {
            ConceptContext cx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                    half_x_, degree(slot, 26)};
                withFlight(cx);
            const std::uint64_t win = world.tickCount() / book_.libero.lapseWindowTicks();
            const int to = choose(slot, 26, win);
            const bool liked = to >= 0 && to != 26 && applies(slot, 26, win);
            std::optional<Vec2> lt;
            if (to == 26) {
                lt = book_.libero.target(cx, !book_.line_step.covered(cx));
                out.why = Why::Libero;
            } else if (to == book_.deep_sweeper.bit()) {
                lt = book_.deep_sweeper.target(cx);
                out.why = liked ? Why::HabitDeep : Why::LapseDeep;
            } else if (to == book_.step_out.bit()) {
                lt = book_.step_out.target(cx);
                out.why = liked ? Why::HabitStepOut : Why::LapseStepOut;
            }
            if (lt) {
                out.move.move = seek(me.pos, *lt, Fixed64::fromFraction(1, 2));
                out.target = *lt;
                return out;
            }
        }

        // balance (G4.11, FA principles): ball on the FAR side → the
        // weak-side player tucks toward the centre, by rating.
        if (ratings_[slot][17] > 0 &&
            math::fx_abs(seen_ball.y) > Fixed64::fromInt(15) &&
            ((seen_ball.y.raw > 0) != (anchor.y.raw > 0))) {
            anchor.y = anchor.y -
                       anchor.y * degree(slot, 17) *
                           Fixed64::fromFraction(6, 10);
        }

        // ORGANIZE: non-engaged defenders take MARKS — greedy unique
        // assignment in slot order over goal-side opponents, standing
        // 1.5 m goal-side of the mark. Whoever finds no mark is the free
        // man and falls through to the shape rules.
        // Their ball INCLUDES their pass in flight: releasing every mark
        // for each opponent pass then snapping back was the third-biggest
        // flip-flop source (G4.20 jitter attribution).
        const bool their_ball =
            ball.owner ||
            world.lastTouchTeam() != setup_.team_of_slot[slot];
        if (their_ball && rank >= 2 &&
            applies(slot, 1, world.tickCount() / 30)) {
            bool marked[32] = {false};
            SlotIndex my_mark = 255;
            for (SlotIndex d = 0; d < world.playerCount(); ++d) {
                if (setup_.team_of_slot[d] != setup_.team_of_slot[slot])
                    continue;
                // A teammate who doesn't mark (rating 0 — the free man,
                // the +1 behind the duels [Bielsa]) takes nobody's man
                // out of the hand-out (G4.31).
                if (ratings_[d][1] == 0) continue;
                if (teamCloserCount(d, world, seen_ball) < 2) continue;
                SlotIndex pick = 255;
                Fixed64 best{};
                for (SlotIndex o = 0; o < world.playerCount(); ++o) {
                    if (setup_.team_of_slot[o] == setup_.team_of_slot[slot])
                        continue;
                    if (o < 32 && marked[o]) continue;
                    if (o == *ball.owner) continue;
                    // Zonal marking only tracks goal-side threats; a
                    // man-oriented marker follows his man much higher.
                    const Fixed64 track_line =
                        Fixed64::fromInt(5) +
                        Fixed64::fromInt(25) * degree(d, 18);
                    if (world.player(o).pos.x * dsgn >=
                        seen_ball.x * dsgn + track_line)
                        continue;
                    const Fixed64 dd =
                        distSq(world.player(d).pos, world.player(o).pos);
                    if (pick == 255 || dd < best) {
                        pick = o;
                        best = dd;
                    }
                }
                if (pick != 255 && pick < 32) marked[pick] = true;
                if (d == slot) {
                    my_mark = pick;
                    break;
                }
            }
            if (my_mark != 255) {
                const auto& mk = world.player(my_mark);
                // man_orientation [Bielsa/Gasperini]: tight to the man
                // (1.5 m zonal → 0.6 m at 100), and FOLLOW him rather
                // than release to shape.
                const Fixed64 gap =
                    Fixed64::fromFraction(3, 2) -
                    Fixed64::fromFraction(9, 10) * degree(slot, 18);
                out.move.move = seek(
                    me.pos,
                    Vec2{mk.pos.x - dsgn * gap, mk.pos.y},
                    Fixed64::fromFraction(1, 2));
                out.why = Why::Mark;
                out.target = Vec2{mk.pos.x - dsgn * gap, mk.pos.y};
                out.other = static_cast<std::int16_t>(my_mark);
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
    if (ours && ratings_[slot][13] > 0 &&
        math::fx_abs(mine.base.y) > Fixed64::fromFraction(40, 100)) {
        const Fixed64 wide = Fixed64::fromInt(10) +
                             Fixed64::fromInt(16) * degree(slot, 13);
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
