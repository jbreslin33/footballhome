// game/src/ai/Brain.cpp

#include "ai/Brain.hpp"

#include "ai/Formation.hpp"
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
// his locomotion reach over (t - HIS reaction, G4.85; was a flat 0.2 s)
// + reach (G4.51; was max_speed x (t - reaction)) — BEFORE the receiver,
// stepping to meet it, gets there first (opponents checked first per stride: ties go
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
    auto react = [&](SlotIndex j, Fixed64 t) {
        const Fixed64 r = world.body(j).reaction();
        return t > r ? t - r : Fixed64::zero();
    };
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
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup.team_of_slot[j] == setup.team_of_slot[passer])
                continue;
            const auto& o = world.player(j);
            const Vec2 d{o.pos.x - pos.x, o.pos.y - pos.y};
            const Fixed64 run = runToward(world, j, pos, react(j, t)) + reach;
            if (math::lengthSquared(d) <= run * run) return false;
        }
        const auto& r = world.player(receiver);
        const Vec2 dr{r.pos.x - pos.x, r.pos.y - pos.y};
        const Fixed64 rrun = runToward(world, receiver, pos, react(receiver, t)) + reach;
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

    // Each man starts after HIS reaction (G4.85, the reaction attribute — was
    // one flat meet-the-pass number) + his perception delay, counted once
    // from when the flight BEGAN. Charged afresh on every read, a receiver
    // 3 m from a ball rolling at him, already running onto it, read as
    // "can't get there" (his whole reaction again before he may move) and
    // fell back to chasing where the ball was: it rolled past him 0.8 m off
    // and their man took it (GAME_TRACE_FLIP).
    const Fixed64 since = Fixed64::fromInt(static_cast<std::int64_t>(
                              world.tickCount() - world.flightTick())) * core::kTickDt;
    Fixed64 react[64];
    for (SlotIndex i = 0; i < n && i < 64; ++i) {
        const Fixed64 full = world.body(i).reaction() +
                             Fixed64::fromInt(levelOf(i).perception_delay_ticks) * core::kTickDt;
        react[i] = full > since ? full - since : Fixed64::zero();
    }
    const Fixed64 box_x = half_x_ - Fixed64::fromFraction(33, 2);   // 16.5 m
    const Fixed64 box_y = Fixed64::fromFraction(2016, 100);          // 20.16 m
    const std::uint32_t flagged = world.offsideMask();
    const std::uint8_t flag_team = world.offsideTeam();
    Vec3 pos = b.pos, vel = b.vel;
    int open = n;
    const int horizon = std::max(books_[0].meet_the_pass.horizonTicks(),
                                 books_[1].meet_the_pass.horizonTicks());
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
            // Our own ball (G4.85): he takes it where it has come down to a
            // pace his first touch can hold — a man knows his touch. Met
            // early and hot it came off him (traced: 53 bad touches a match
            // at 15 m/s+ on passes meant for him once the read stopped
            // re-charging the reaction).
            if (!gk && p.team == world.lastTouchTeam()) {
                const std::int32_t c = levelOf(i).control_speed_mps;
                if (c > 0 && sp2 > Fixed64::fromInt(c) * Fixed64::fromInt(c)) continue;
            }
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

Orders Brain::ordersFor(SlotIndex slot, const World& world) const {
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
                    if (passSafe(world, setup_, slot, o.pass_to, from, at,
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

Orders Brain::ordersSeen(SlotIndex slot, const World& world) const {
    Orders o = ordersFaced(slot, world);
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

math::Vec2 Brain::shapeAnchor(SlotIndex slot, const World& world) const {
    const FormationSpec::Pos& mine =
        spec_[setup_.team_of_slot[slot]].positions[index_in_team_[slot]];
    Vec2 a = anchorFor(mine.base, attackSign(slot), world.ball().pos, half_x_, half_y_, mine.keeper);
    const auto& b = world.ball();
    if (!mine.keeper && b.owner && setup_.team_of_slot[*b.owner] == setup_.team_of_slot[slot])
        a.x = possessionX(slot, b.pos.x);
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
    const Fixed64 lim = half_x_ - Fixed64::fromInt(3);
    if (x > lim) x = lim;
    if (x < -lim) x = -lim;
    return x * sg;
}

Orders Brain::ordersFaced(SlotIndex slot, const World& world) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    // A restart shape is held until the dead ball is played (G4.58).
    if (hold_team_ != 0xFF && world.restartTeam() == hold_team_ && !world.ball().owner) {
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
    unmark(slot, world, o);
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
        case Why::Human: case Why::DropStep: case Why::JumpPass:
            return o;   // these face where they're going
        default: break;
    }
    const int bit = book_.face_the_play.bit();
    if (ratings_[slot][bit] <= 0 || !applies(slot, bit, world.tickCount() / 30)) return o;
    if (!short_move) return o;
    o.move.face = to_ball;
    return o;
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
    Vec2 best = here;
    Fixed64 best_d = nearest(here);
    for (const Vec2& d : dirs) {
        const Vec2 c{here.x + d.x * L.step(), here.y + d.y * L.step()};
        if (math::fx_abs(c.x) > half_x_ - Fixed64::one() || math::fx_abs(c.y) > half_y_ - Fixed64::one()) continue;
        if (distSq(Vec3{c.x, c.y, Fixed64::zero()}, Vec3{o.target.x, o.target.y, Fixed64::zero()}) > L.leash() * L.leash()) continue;
        const Fixed64 nd = nearest(c);
        if (nd > best_d) { best_d = nd; best = c; }
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
bool Brain::keepIt(SlotIndex slot, const World& world, int sign, Orders& out) const {
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
    if (me.pos.x * sgn < -half_x_ + K.ownThird()) return false;
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

// Hurry the keeper / press the bad touch (178/179, G4.73). Only our
// nearest outfielder goes — to the loose ball after their bad touch (for
// window_s), or at their keeper when he can get within hurry_m before the
// keeper's ready to play (settle_s after he has it; a back pass: its flight
// first). Can't hurry him: false — drop (the normal shape).
bool Brain::hurryOrPounce(SlotIndex slot, const World& world, int sign, Orders& out) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& b = world.ball();
    const std::uint8_t my_team = setup_.team_of_slot[slot];
    const std::uint64_t sec = world.tickCount() / 30;
    auto nearestOurs = [&](const Vec3& at) {
        int best = -1;
        Fixed64 bd{};
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] != my_team || world.isKeeper(j)) continue;
            const Fixed64 d = distSq(world.player(j).pos, at);
            if (best < 0 || d < bd) { best = j; bd = d; }
        }
        return best;
    };
    const auto& me = world.player(slot);
    // The bad touch: his ball is loose off his own touch.
    const std::uint8_t bt = world.badTouchSlot();
    const int bb = book_.bad_touch.bit();
    if (!b.owner && bt != 0xFF && setup_.team_of_slot[bt] != my_team && b.last_kicker == bt &&
        world.tickCount() - world.badTouchTick() <= static_cast<std::uint64_t>(book_.bad_touch.windowTicks()) &&
        ratings_[slot][bb] > 0 && nearestOurs(b.pos) == static_cast<int>(slot) && applies(slot, bb, sec)) {
        const Vec2 t{b.pos.x, b.pos.y};
        out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 10));
        out.why = Why::PressBadTouch;
        out.target = t;
        out.other = static_cast<std::int16_t>(bt);
        return true;
    }
    // Their keeper: on the ball, or their back pass going to him.
    const int hk = book_.hurry_keeper.bit();
    if (ratings_[slot][hk] == 0) return false;
    int K = -1;
    Fixed64 ready{};
    if (b.owner && setup_.team_of_slot[*b.owner] != my_team && world.isKeeper(*b.owner)) {
        K = *b.owner;
        const Fixed64 held = Fixed64::fromInt(static_cast<std::int32_t>(world.tickCount() - world.ownedAtTick())) * core::kTickDt;
        ready = held < book_.hurry_keeper.settle() ? book_.hurry_keeper.settle() - held : Fixed64::zero();
    } else if (!b.owner && world.lastTouchTeam() != my_team) {
        const FlightRead& fr = flightRead(world);
        const int r = fr.live ? fr.first[1 - my_team] : -1;
        if (r >= 0 && world.isKeeper(static_cast<SlotIndex>(r)) && b.last_kicker != r) {
            K = r;
            ready = Fixed64::fromInt(fr.tick[r]) * core::kTickDt + book_.hurry_keeper.settle();
        }
    }
    if (K < 0) return false;
    const auto& kp = world.player(static_cast<SlotIndex>(K)).pos;
    if (nearestOurs(kp) != static_cast<int>(slot) || !applies(slot, hk, sec)) return false;
    const Vec2 at{kp.x, kp.y};
    const Fixed64 need = math::length(Vec2{kp.x - me.pos.x, kp.y - me.pos.y}) - book_.hurry_keeper.hurry();
    if (need > Fixed64::zero() && runToward(world, slot, at, ready) < need) return false;   // can't hurry him: drop
    // Straight at him, on the line to his nearest outfielder: the easy
    // pass goes through the man hurrying him.
    int O = -1;
    Fixed64 od{};
    for (SlotIndex j = 0; j < world.playerCount(); ++j) {
        if (setup_.team_of_slot[j] == my_team || world.isKeeper(j)) continue;
        const Fixed64 d = distSq(world.player(j).pos, kp);
        if (O < 0 || d < od) { O = j; od = d; }
    }
    Vec2 dir{Fixed64::zero(), Fixed64::zero()};
    if (O >= 0) {
        const auto& op = world.player(static_cast<SlotIndex>(O)).pos;
        dir = math::normalized(Vec2{op.x - kp.x, op.y - kp.y});
    }
    const Fixed64 g = Fixed64::fromFraction(3, 2);
    const Vec2 t{kp.x + dir.x * g, kp.y + dir.y * g};
    out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 10));
    out.why = Why::HurryKeeper;
    out.target = t;
    out.other = static_cast<std::int16_t>(K);
    (void)sign;
    return true;
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

// G4.64 Lighthouse's plan (165-167) [FH; James 10/26]: "we essentially
// pack the middle then wait for the inevitable pass to full then we press."
// While they build in their half the false 9 screens their midfield and the
// wingers tuck in (ai::PackTheMiddle); their pass to a full-back is the
// trigger — the winger whose man he is steps straight at him on the line to
// their midfield (ai::PressTheFullBack), the far winger tucks further, and
// the 9 locks the door on the return pass to the centre-back
// (ai::LockTheDoor). A failed roll is the ordinary brain.
bool Brain::packAndTrap(SlotIndex slot, const World& world, int sign, const Vec2& B,
                        const Vec2& anchor, Orders& out) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const auto& P = book_.pack_middle;
    const int num = numberOf(slot);
    const bool nine = num != 0 && num == P.falseNine();
    const bool wing = P.isWinger(num);
    const bool fullback = P.isFullBack(num);
    if (!nine && !wing && !fullback) return false;
    const std::uint8_t my_team = setup_.team_of_slot[slot];
    const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    if (B.x * dsgn < P.fromHalfway()) return false;   // their build-up only
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    if (fullback) {
        // Their restart (G4.72, James 10/27: "lh 2 & 3 still too close to 7
        // & 11 on restart"): the full-back stands off their winger — fb_off_m
        // goal-side, fb_inside_m toward the middle — for the long ball.
        const std::uint8_t rt = world.restartTeam();
        const bool their_restart = rt != 0xFF && rt != my_team;
        const bool their_keeper = ball.owner && setup_.team_of_slot[*ball.owner] != my_team && world.isKeeper(*ball.owner);
        if (!(their_restart || their_keeper)) return false;
        if (ratings_[slot][P.bit()] == 0 || !applies(slot, P.bit(), world.turnoverTick())) return false;
        const int M = directOpponents(world, world.tickCount() / 30)[slot];
        if (M == 255) return false;
        const auto& mp = world.player(static_cast<SlotIndex>(M)).pos;
        if (math::fx_abs(mp.y) <= P.centralWidth()) return false;   // not a winger
        const Fixed64 in = mp.y.raw > 0 ? -Fixed64::one() : Fixed64::one();
        const Vec2 t{mp.x - dsgn * P.fbOff(), mp.y + in * P.fbInside()};
        out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
        out.why = Why::PlayOff;
        out.target = t;
        out.other = static_cast<std::int16_t>(M);
        return true;
    }
    // We just lost it and he's near it: the counter-press comes first.
    if (world.lastLosingTeam() == my_team && ratings_[slot][16] > 0 && world.restartTeam() == 0xFF &&
        world.tickCount() - world.turnoverTick() < 10 + static_cast<std::uint64_t>(ratings_[slot][16]) &&
        distSq(me.pos, Vec3{B.x, B.y, Fixed64::zero()}) < Fixed64::fromInt(400))
        return false;
    const std::uint64_t sec = world.tickCount() / 30;
    const Trap tr = trapRead(world, my_team, B);
    const int R = tr.carrier, w = tr.winger;
    const std::vector<SlotIndex>& cbs = tr.cbs;
    const auto& direct = directOpponents(world, sec);
    auto isCb = [&](SlotIndex o) { return std::find(cbs.begin(), cbs.end(), o) != cbs.end(); };
    // Their midfield: the men our 6/8/10 mark (their direct opponents).
    std::vector<SlotIndex> mids;
    for (SlotIndex j = 0; j < world.playerCount(); ++j)
        if (setup_.team_of_slot[j] == my_team && P.isMidfield(numberOf(j)) && direct[j] != 255 &&
            std::find(mids.begin(), mids.end(), direct[j]) == mids.end())
            mids.push_back(direct[j]);
    // Screen a central man: screen_gap_m off him on the line from the ball.
    auto screen = [&](int M, Fixed64 width, Why why, Fixed64 gap) {
        const auto& mp = world.player(static_cast<SlotIndex>(M)).pos;
        const Vec2 to_ball = math::normalized(Vec2{B.x - mp.x, B.y - mp.y});
        const Fixed64 far = math::length(Vec2{B.x - mp.x, B.y - mp.y}) - Fixed64::fromInt(2);
        if (gap > far) gap = far;   // never past the ball
        Vec2 t{mp.x + to_ball.x * gap, mp.y + to_ball.y * gap};
        if (t.y > width) t.y = width;
        if (t.y < -width) t.y = -width;
        out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
        out.why = why;
        out.target = t;
        out.other = static_cast<std::int16_t>(M);
        return true;
    };
    // Who screens whom: each winger the man of their midfield on his side
    // (the winger on the left of our shape the leftmost; a lone man goes to
    // the winger on his side); the 9 floats onto the one nearest the ball
    // that's left — or, with none left, the nearest of them all.
    std::vector<SlotIndex> c;
    for (SlotIndex o : mids) {
        if (o == R) continue;
        const auto& op = world.player(o);
        if (math::fx_abs(op.pos.y) > P.centralWidth() || op.pos.x * dsgn >= B.x * dsgn) continue;
        c.push_back(o);
    }
    std::sort(c.begin(), c.end(), [&](SlotIndex a, SlotIndex b) { return world.player(a).pos.y < world.player(b).pos.y; });
    auto wingerMan = [&](SlotIndex wslot) {
        const Fixed64 wy = spec_[my_team].positions[index_in_team_[wslot]].base.y;
        bool high = true;   // the winger with the larger base y
        for (SlotIndex j = 0; j < world.playerCount(); ++j)
            if (j != wslot && setup_.team_of_slot[j] == my_team && P.isWinger(numberOf(j)) &&
                spec_[my_team].positions[index_in_team_[j]].base.y > wy)
                high = false;
        if (c.size() >= 2) return static_cast<int>(high ? c.back() : c.front());
        if (c.size() == 1 && (world.player(c[0]).pos.y.raw >= 0) == high) return static_cast<int>(c[0]);
        return -1;
    };
    auto nineMan = [&]() {
        std::vector<int> taken;
        for (SlotIndex j = 0; j < world.playerCount(); ++j)
            if (setup_.team_of_slot[j] == my_team && P.isWinger(numberOf(j))) taken.push_back(wingerMan(j));
        int M = -1;
        Fixed64 md{};
        for (int pass = 0; pass < 2 && M < 0; ++pass)
            for (SlotIndex o : c) {
                if (pass == 0 && std::find(taken.begin(), taken.end(), static_cast<int>(o)) != taken.end()) continue;
                const Fixed64 d = distSq(world.player(o).pos, Vec3{B.x, B.y, Fixed64::zero()});
                if (M < 0 || d < md) { M = o; md = d; }
            }
        return M;
    };
    auto tuck = [&](Fixed64 width) {
        const int M = wingerMan(slot);
        if (M >= 0) return screen(M, width, Why::PackMiddle, P.screenGap());
        Fixed64 y = anchor.y;
        if (y > width) y = width;
        if (y < -width) y = -width;
        const Vec2 t0{anchor.x, y};
        out.move.move = seek(me.pos, t0, Fixed64::fromFraction(1, 2));
        out.why = Why::PackMiddle;
        out.target = t0;
        return true;
    };
    // One roll per their possession (pack) and per trigger (press, lock):
    // a per-second roll flipped the wingers between the tuck and their
    // full-back (the man we leave open on purpose).
    const std::uint64_t poss = world.turnoverTick();
    const std::uint64_t trig = poss * 64 + static_cast<std::uint64_t>(R < 0 ? 63 : R);
    if (w >= 0) {
        const auto& fb = world.player(static_cast<SlotIndex>(R));
        const Vec2 F{fb.pos.x, fb.pos.y};
        if (slot == w) {
            // Tactic B (169): shadow the line from the full-back to their
            // winger — to its nearest point, then up it to the full-back.
            const auto& S = book_.shadow_line;
            if (ratings_[slot][S.bit()] > 0 && applies(slot, S.bit(), trig)) {
                const int W = theirWinger(world, my_team, sign, R, cbs);
                if (W >= 0 && !(ball.owner && distSq(me.pos, fb.pos) < S.handover() * S.handover())) {
                    const auto& wp = world.player(static_cast<SlotIndex>(W)).pos;
                    const Vec2 ab{wp.x - F.x, wp.y - F.y};
                    const Fixed64 len = math::length(ab);
                    if (len > S.fromFullBack() + Fixed64::one()) {
                        const Vec2 u{ab.x / len, ab.y / len};
                        Fixed64 t = dot(Vec2{me.pos.x - F.x, me.pos.y - F.y}, u);
                        if (t < S.fromFullBack()) t = S.fromFullBack();
                        if (t > len - Fixed64::one()) t = len - Fixed64::one();
                        const Vec2 near{F.x + u.x * t, F.y + u.y * t};
                        const bool on = distSq(me.pos, Vec3{near.x, near.y, Fixed64::zero()}) <= S.onLine() * S.onLine();
                        const Vec2 tgt = on ? Vec2{F.x + u.x * S.fromFullBack(), F.y + u.y * S.fromFullBack()} : near;
                        out.move.move = seek(me.pos, tgt, Fixed64::fromFraction(3, 10));
                        out.why = Why::ShadowLine;
                        out.target = tgt;
                        out.other = static_cast<std::int16_t>(W);
                        return true;
                    }
                }
            }
            const auto& T = book_.press_full_back;
            if (ratings_[slot][T.bit()] == 0 || !applies(slot, T.bit(), trig)) return false;
            if (ball.owner && distSq(me.pos, fb.pos) < T.handover() * T.handover()) return false;
            // Straight at him, on the line to their nearest central man.
            int M = -1;
            Fixed64 md{};
            for (SlotIndex o = 0; o < world.playerCount(); ++o) {
                if (setup_.team_of_slot[o] == my_team || world.isKeeper(o) || o == R || isCb(o)) continue;
                const auto& op = world.player(o);
                if (math::fx_abs(op.pos.y) > P.centralWidth()) continue;
                if (op.pos.x * dsgn > fb.pos.x * dsgn + T.shadowAhead()) continue;
                const Fixed64 d = distSq(op.pos, fb.pos);
                if (M < 0 || d < md) { M = o; md = d; }
            }
            Vec2 dir{-dsgn, Fixed64::zero()};   // no midfielder: goal-side of him
            if (M >= 0) {
                const auto& mp = world.player(static_cast<SlotIndex>(M)).pos;
                dir = math::normalized(Vec2{mp.x - F.x, mp.y - F.y});
            }
            const Vec2 t{F.x + dir.x * T.stepGap(), F.y + dir.y * T.stepGap()};
            out.move.move = seek(me.pos, t, Fixed64::fromFraction(3, 10));
            out.why = Why::PressFullBack;
            out.target = t;
            out.other = static_cast<std::int16_t>(R);
            return true;
        }
        if (wing) {   // the far winger: an extra midfielder
            if (!applies(slot, P.bit(), poss)) return false;
            return tuck(P.weakTuckWidth());
        }
        // The 9 locks the door.
        const auto& L = book_.lock_door;
        if (cbs.empty() || ratings_[slot][L.bit()] == 0 || !applies(slot, L.bit(), trig)) return false;
        SlotIndex near = cbs[0];
        for (SlotIndex c : cbs)
            if (distSq(world.player(c).pos, fb.pos) < distSq(world.player(near).pos, fb.pos)) near = c;
        const auto& cb = world.player(near).pos;
        const Vec2 to_fb = math::normalized(Vec2{F.x - cb.x, F.y - cb.y});
        Vec2 t{cb.x + to_fb.x * L.lockGap(), cb.y + to_fb.y * L.lockGap()};
        for (SlotIndex c : cbs) {
            if (c == near) continue;
            const auto& far = world.player(c).pos;
            const Vec2 to_far = math::normalized(Vec2{far.x - cb.x, far.y - cb.y});
            t = Vec2{t.x + to_far.x * L.shade(), t.y + to_far.y * L.shade()};
            break;
        }
        out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
        out.why = Why::LockDoor;
        out.target = t;
        out.other = static_cast<std::int16_t>(near);
        return true;
    }
    // No trigger yet: pack the middle.
    if (ratings_[slot][P.bit()] == 0 || !applies(slot, P.bit(), poss)) return false;
    if (ball.owner && distSq(me.pos, ball.pos) < P.handover() * P.handover()) return false;
    if (wing) {
        // Book-ends (G4.72, James 10/27: "lh 7 and 11 should be book ends to
        // lh 8,10"): level with our 8 or 10 on his side (the one nearer his
        // shape's side of the pitch), bookend_gap_m wider.
        int mid = -1, other = -1;
        for (SlotIndex j = 0; j < world.playerCount(); ++j) {
            if (setup_.team_of_slot[j] != my_team || !P.isBookendMid(numberOf(j))) continue;
            if (mid < 0) { mid = j; continue; }
            const Fixed64 dj = math::fx_abs(world.player(j).pos.y - anchor.y);
            const Fixed64 dm = math::fx_abs(world.player(static_cast<SlotIndex>(mid)).pos.y - anchor.y);
            if (dj < dm) { other = mid; mid = j; } else other = j;
        }
        if (mid < 0 || other < 0) return tuck(P.tuckWidth());
        const auto& m = world.player(static_cast<SlotIndex>(mid)).pos;
        const auto& o = world.player(static_cast<SlotIndex>(other)).pos;
        const Fixed64 outw = m.y >= o.y ? Fixed64::one() : -Fixed64::one();
        const Vec2 t{m.x, m.y + outw * P.bookendGap()};
        out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
        out.why = Why::PackMiddle;
        out.target = t;
        out.other = static_cast<std::int16_t>(mid);
        return true;
    }
    // The 9 in the box (G4.72, James 10/27: "he should be in middle of their
    // 6 and 8 and able to cover shadow them. like in a box between ukies
    // 4,5,6,8"): the middle of their two centre-backs and their two deepest
    // central midfielders.
    {
        std::vector<SlotIndex> deep = c;
        std::sort(deep.begin(), deep.end(), [&](SlotIndex a, SlotIndex b) {
            return world.player(a).pos.x * dsgn > world.player(b).pos.x * dsgn;   // nearest their goal first
        });
        if (cbs.size() >= 2 && deep.size() >= 2) {
            Vec2 t{Fixed64::zero(), Fixed64::zero()};
            for (SlotIndex o : {cbs[0], cbs[1], deep[0], deep[1]}) {
                t.x += world.player(o).pos.x;
                t.y += world.player(o).pos.y;
            }
            t = Vec2{t.x / Fixed64::fromInt(4), t.y / Fixed64::fromInt(4)};
            out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 2));
            out.why = Why::PackMiddle;
            out.target = t;
            out.other = static_cast<std::int16_t>(deep[0]);
            return true;
        }
    }
    // The false 9 floats: he screens the one the wingers leave, nearest the
    // ball — but never further than lock-the-door's reach from the ball-side
    // centre-back, so he can lock the door while the pass wide travels.
    const int M = nineMan();
    if (M < 0) return false;
    screen(M, P.centralWidth(), Why::PackMiddle, P.nineScreenGap());
    const auto& L = book_.lock_door;
    if (!cbs.empty() && ratings_[slot][L.bit()] > 0) {
        SlotIndex bs = cbs[0];
        for (SlotIndex c : cbs)
            if (distSq(world.player(c).pos, Vec3{B.x, B.y, Fixed64::zero()}) <
                distSq(world.player(bs).pos, Vec3{B.x, B.y, Fixed64::zero()}))
                bs = c;
        const auto& cb = world.player(bs).pos;
        const Vec2 d{out.target.x - cb.x, out.target.y - cb.y};
        const Fixed64 len = math::length(d);
        if (len > L.reach()) {
            const Fixed64 k = L.reach() / len;
            out.target = Vec2{cb.x + d.x * k, cb.y + d.y * k};
            out.move.move = seek(me.pos, out.target, Fixed64::fromFraction(1, 2));
        }
    }
    return true;
}

// The one spot (163/164, G4.63): from his marking spot, the candidate
// that keeps his own man in pressing distance (the must) and scores most —
// another man's lane from the carrier cut (163, a lane no teammate already
// stands on) and other men in pressing distance to help (164) — less a
// cost per metre moved off the marking spot. None better: the marking spot.
Vec2 Brain::oneSpot(SlotIndex slot, const World& world, SlotIndex man, const Vec2& spot,
                    const Vec2& B, SlotIndex carrier, bool shadow, bool help) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
    const std::uint8_t my_team = setup_.team_of_slot[slot];
    const auto& PD = book_.press_distance;
    const auto& SS = book_.shadow_second;
    struct Opp { Vec2 pos, meet; Fixed64 reach; Vec2 a, z; bool lane; bool keeper; };
    Opp opp[32];
    int n = 0;
    const Reach rm = pressReach(slot, world, B, man);
    const Vec2 M = rm.at;
    const Fixed64 reach_m = rm.run;
    for (SlotIndex o = 0; o < world.playerCount() && n < 32; ++o) {
        if (setup_.team_of_slot[o] == my_team || o == carrier || o == man) continue;
        Opp& x = opp[n++];
        x.pos = Vec2{world.player(o).pos.x, world.player(o).pos.y};
        x.keeper = world.isKeeper(o);
        const Reach r = pressReach(slot, world, B, o);
        x.meet = r.at;
        x.reach = r.run;
        // The lane: carrier → him, less the ends (that's pressing / marking).
        const Vec2 d{x.pos.x - B.x, x.pos.y - B.y};
        const Fixed64 len = math::length(d);
        // At least a metre of lane left once both ends are off (a hair of
        // one squared to 0 in fixed point and divided by it).
        x.lane = shadow && len > SS.fromPasser() + SS.fromMan() + Fixed64::one();
        if (!x.lane) continue;
        const Vec2 u{d.x / len, d.y / len};
        x.a = Vec2{B.x + u.x * SS.fromPasser(), B.y + u.y * SS.fromPasser()};
        x.z = Vec2{x.pos.x - u.x * SS.fromMan(), x.pos.y - u.y * SS.fromMan()};
        const Fixed64 w2 = SS.laneWidth() * SS.laneWidth();
        for (SlotIndex j = 0; j < world.playerCount() && x.lane; ++j) {
            if (j == slot || setup_.team_of_slot[j] != my_team) continue;
            const Vec2 jp{world.player(j).pos.x, world.player(j).pos.y};
            if (pointSegmentDistSq(jp, x.a, x.z) <= w2) x.lane = false;   // a teammate has it
        }
    }
    auto score = [&](const Vec2& p) {
        Fixed64 s = -PD.moveCost() * math::length(Vec2{p.x - spot.x, p.y - spot.y});
        const Fixed64 w2 = SS.laneWidth() * SS.laneWidth();
        for (int i = 0; i < n; ++i) {
            const Opp& x = opp[i];
            if (x.lane && pointSegmentDistSq(p, x.a, x.z) <= w2) s += SS.laneWeight();
            if (help && !x.keeper) {
                const Vec2 d{p.x - x.meet.x, p.y - x.meet.y};
                if (math::lengthSquared(d) <= x.reach * x.reach) s += PD.helpWeight();
            }
        }
        return s;
    };
    // And never more than max_off_man_m from where he'd mark him (James
    // 10/26: "that looks really bad leaving their winger wide open
    // unmarked" — reach on paper let a full-back stand 20 m off his winger).
    const Fixed64 leash = PD.maxOffMan();
    auto keeps_man = [&](const Vec2& p) {
        const Vec2 d{p.x - M.x, p.y - M.y};
        const Vec2 e{p.x - spot.x, p.y - spot.y};
        return math::lengthSquared(d) <= reach_m * reach_m && math::lengthSquared(e) <= leash * leash;
    };
    Vec2 best = spot;
    Fixed64 best_s = score(spot);
    auto consider = [&](const Vec2& p) {
        if (!keeps_man(p)) return;
        const Fixed64 s = score(p);
        if (s > best_s) { best = p; best_s = s; }
    };
    for (int i = 0; i < n; ++i) {
        const Opp& x = opp[i];
        if (x.lane) {   // the nearest point of his lane, and halfway to it
            const Vec2 ab{x.z.x - x.a.x, x.z.y - x.a.y};
            const Fixed64 ab2 = math::lengthSquared(ab);
            Fixed64 t = ab2.raw > 0 ? dot(Vec2{spot.x - x.a.x, spot.y - x.a.y}, ab) / ab2 : Fixed64::zero();
            if (t < Fixed64::zero()) t = Fixed64::zero();
            if (t > Fixed64::one()) t = Fixed64::one();
            const Vec2 l{x.a.x + ab.x * t, x.a.y + ab.y * t};
            consider(l);
            consider(Vec2{(l.x + spot.x) / 2, (l.y + spot.y) / 2});
        }
        if (help && !x.keeper) {   // a third and two thirds of the way to where he'd receive
            const Vec2 d{x.meet.x - spot.x, x.meet.y - spot.y};
            consider(Vec2{spot.x + d.x / 3, spot.y + d.y / 3});
            consider(Vec2{spot.x + d.x * 2 / 3, spot.y + d.y * 2 / 3});
        }
    }
    return best;
}

Orders Brain::decide(SlotIndex slot, const World& world) const {
    const ConceptBook& book_ = bookOf(slot);   // G4.76: his team's model
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
                if (passSafe(world, setup_, slot, j, from, to,
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
            const Fixed64 v = core::weightedPassSpeed(math::fx_sqrt(dsq));   // G4.81: as he'll strike it
            return passSafe(world, setup_, slot, recv, a, b, v, safe_reach);
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
                const ConceptContext pcx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                         half_x_, degree(slot, book_.short_simple.bit())};
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
        if (!im_keeper && !pressed) {
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
            if (blind(i)) continue;   // G4.66: can't see him
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
                if (blind(i)) continue;   // G4.66
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
        // keep-it-under-pressure (161, G4.60): touch-tight with nothing
        // on, play it back to the open man goal-side of him, else shield
        // and turn away; only in his own third may he still kick it away.
        // A lapse (or u-nothing) falls through to the hoof below.
        if (pressed && !im_keeper && keepIt(slot, world, sign, out))
            return out;
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
    if (shape_ours && !mine.keeper) anchor.x = possessionX(slot, seen_ball.x);

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
    if (!shape_ours && !mine.keeper) {
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
            // The line (G4.56, ai::LineHold): with the offside law in the
            // game a back line holds a height off the BALL — covered ball:
            // ball − hold (push-up squeezes it); uncovered: drop a few
            // metres more. An attacker beyond it is offside, not a man to
            // follow. Lapse (or not knowing line-hold): drop with the
            // deepest attacker, 2 m goal-side of him — the pre-offside rule
            // (G4.4) that sank every back line 16-22 m from its own goal.
            Fixed64 cover = deepest - Fixed64::fromInt(2);
            bool holding_line = false;
            const int lh = book_.line_hold.bit();
            if (ratings_[slot][lh] > 0 && (applies(slot, lh, world.tickCount() / 30) || told_line_)) {
                const auto& L = book_.line_hold;
                Fixed64 dist = L.hold() - L.squeeze() * degree(slot, 15);
                ConceptContext cx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                  half_x_, degree(slot, lh)};
                withFlight(cx);
                if (!book_.line_step.covered(cx)) dist += L.uncoveredDrop();
                cover = seen_ball.x * sgn - dist;
                holding_line = true;
            } else if (ratings_[slot][lh] > 0) {
                // The lapse keeps G4.8's floor: never more than hold_m behind
                // the ball (without it a line-riding runner and a tracking
                // back line retreat-spiral into the goalmouth).
                const Fixed64 floor_line = seen_ball.x * sgn -
                    (book_.line_hold.hold() - book_.line_hold.squeeze() * degree(slot, 15));
                if (cover < floor_line) cover = floor_line;
            }
            // line-step (bit 28, G4.33) [Sacchi palla coperta / scoperta;
            // James: "when ball is moving push up and stop as opp is
            // receiving and can play long. push up if opp is turned toward
            // their own goal with ball"] — ai::LineStep.
            if (ratings_[slot][28] > 0 && (applies(slot, 28, world.tickCount() / 30) || told_squeeze_)) {
                ConceptContext cx{world, slot, sign, Vec2{seen_ball.x, seen_ball.y},
                                        half_x_, degree(slot, 28)};
                withFlight(cx);
                if (auto line = book_.line_step.stepLine(cx)) {
                    if (cover < *line) cover = *line;          // leave the runner offside
                    if (anchor.x * sgn < *line) anchor.x = *line * sgn;  // and STEP UP
                }
            }
            // A held line SETS the back line's height (up as well as down);
            // the lapse only caps it (G4.4's rule never brought a deep
            // anchor up).
            if (holding_line || anchor.x * sgn > cover) anchor.x = cover * sgn;
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
    if (lv.shapePull() > 0 && !mine.keeper) {
        const Fixed64 f = Fixed64::fromFraction(lv.shapePull(), 100);
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
    // Their dead ball (G4.63): a man-marker picks up his direct opponent
    // while they set it up — goal-side, then the one spot (163/164) — not
    // stand in shape for it. Bielsa's men are on theirs when the keeper
    // looks up; in shape, the goal kick found every Ukie 10-27 m free.
    if (!ours && !opponents_restart && !mine.keeper && hurryOrPounce(slot, world, sign, out))
        return out;
    if (!ours && !mine.keeper &&
        packAndTrap(slot, world, sign, Vec2{seen_ball.x, seen_ball.y}, anchor, out))
        return out;
    if (!ours && opponents_restart && !mine.keeper && ratings_[slot][18] > 0 &&
        applies(slot, 18, world.tickCount() / 30)) {
        const std::uint64_t sec = world.tickCount() / 30;
        const std::uint8_t direct = directOpponents(world, sec)[slot];
        const Vec2 B{ball.pos.x, ball.pos.y};
        // The taker is the man on the ball.
        SlotIndex taker = 255;
        Fixed64 td{};
        for (SlotIndex o = 0; o < world.playerCount(); ++o) {
            if (setup_.team_of_slot[o] == my_team) continue;
            const Fixed64 d = distSq(world.player(o).pos, ball.pos);
            if (taker == 255 || d < td) { taker = o; td = d; }
        }
        if (direct != 255 && direct != taker) {
            const auto& mk = world.player(direct);
            const Fixed64 dsgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
            const Vec2 to_goal = math::normalized(Vec2{-dsgn * half_x_ - mk.pos.x, -mk.pos.y});
            const Fixed64 gap = Fixed64::fromFraction(3, 2) - Fixed64::fromFraction(9, 10) * degree(slot, 18);
            Vec2 spot{mk.pos.x + to_goal.x * gap, mk.pos.y + to_goal.y * gap};
            Why why = Why::Mark;
            const int ss = book_.shadow_second.bit(), pd = book_.press_distance.bit();
            const bool sh = ratings_[slot][ss] > 0 && applies(slot, ss, sec);
            const bool hp = ratings_[slot][pd] > 0 && applies(slot, pd, sec);
            if (sh || hp) {
                const Vec2 s2 = oneSpot(slot, world, direct, spot, B, taker, sh, hp);
                if (s2.x != spot.x || s2.y != spot.y) { spot = s2; why = Why::ShadowHelp; }
            }
            out.move.move = seek(me.pos, spot, Fixed64::fromFraction(1, 2));
            out.why = why;
            out.target = spot;
            out.other = static_cast<std::int16_t>(direct);
            return out;
        }
    }
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
        if (attackTheDrop(slot, world, sign, out)) return out;
        if (jumpThePass(slot, world, sign, out)) return out;
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

        // Defend your man (168), rule #2 on the ball: my man has it with his
        // back to our goal — tight and goal-side, don't dive, don't let him
        // turn (a dive the traffic roll above already took stays a dive).
        if (ball.owner) {
            const int dm = book_.defend_man.bit();
            const std::uint64_t dsec = world.tickCount() / 30;
            const auto& c = world.player(*ball.owner);
            const auto& D = book_.defend_man;
            if (ratings_[slot][dm] > 0 && directOpponents(world, dsec)[slot] == *ball.owner &&
                c.face.x * dsgn > Fixed64::zero() &&
                distSq(me.pos, c.pos) < D.noTurnWithin() * D.noTurnWithin() && applies(slot, dm, dsec) &&
                rung(slot, kNoTurn, c.pos.x, dsec)) {
                const Vec2 own_goal{-dsgn * half_x_, Fixed64::zero()};
                const Vec2 to_goal = math::normalized(Vec2{own_goal.x - c.pos.x, own_goal.y - c.pos.y});
                const Vec2 t{c.pos.x + to_goal.x * D.noTurnGap(), c.pos.y + to_goal.y * D.noTurnGap()};
                out.move.move = seek(me.pos, t, Fixed64::fromFraction(1, 10));
                out.why = Why::NoTurn;
                out.target = t;
                out.other = static_cast<std::int16_t>(*ball.owner);
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
                const Vec2 own_goal{-dsgn * half_x_, Fixed64::zero()};
                const Fixed64 dz = book_.engage_or_contain.danger();
                const bool in_range = distSq(c.pos, Vec3{own_goal.x, own_goal.y, Fixed64::zero()}) < dz * dz;
                engage = cover_here || back_to_goal || pinned || in_range;
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
                // Defend your man (168), rule #1: first to the pass to my man.
                if (race_first && !ball.owner) {
                    const int dm = book_.defend_man.bit();
                    const std::uint64_t dsec = world.tickCount() / 30;
                    const FlightRead& fr = flightRead(world);
                    const int their = fr.first[my_team ^ 1];
                    if (their >= 0 && directOpponents(world, dsec)[slot] == their &&
                        ratings_[slot][dm] > 0 && applies(slot, dm, dsec))
                        out.why = Why::Intercept;
                }
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
            // Defend your man (168), rule #3: he's turned on me — contain.
            {
                const int dm = book_.defend_man.bit();
                if (ball.owner && ratings_[slot][dm] > 0 && directOpponents(world, sec)[slot] == *ball.owner &&
                    applies(slot, dm, sec) && rung(slot, kContain, seen_ball.x, sec))
                    out.why = Why::Contain;
            }
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
            // man-mark (18), G4.56: his DIRECT opponent, followed anywhere
            // (not just goal-side threats near the ball — the zonal hand-out
            // below left a man-marking side marking 22% of the time).
            // Lapse: the zonal hand-out.
            const std::uint64_t sec = world.tickCount() / 30;
            const std::uint8_t direct = directOpponents(world, sec)[slot];
            if (ratings_[slot][18] > 0 && applies(slot, 18, sec)) {
                if (direct != 255 && !(ball.owner && *ball.owner == direct)) my_mark = direct;
            }
            // direct-opponent (160, G4.57): a zonal marker picks HIS man
            // up first when he's a goal-side threat in range; else the
            // nearest, as before. Lapse: nearest only.
            const int dob = book_.direct_opponent.bit();
            const bool knows_direct = ratings_[slot][dob] > 0 && applies(slot, dob, sec);
            if (my_mark == 255 && knows_direct && direct != 255 && !(ball.owner && *ball.owner == direct)) {
                const Fixed64 z = book_.direct_opponent.zone();
                if (distSq(world.player(direct).pos, Vec3{anchor.x, anchor.y, Fixed64::zero()}) < z * z)
                    my_mark = direct;   // he's in my zone: he's mine
            }
            for (SlotIndex d = 0; d < world.playerCount() && my_mark == 255; ++d) {
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
                    // Their keeper is nobody's mark (G4.73): he's hurried
                    // (178) or left (drop).
                    if (world.isKeeper(o)) continue;
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
                Vec2 spot{mk.pos.x - dsgn * gap, mk.pos.y};   // from behind
                // mark-position (158, G4.57): goal-side always; ball-side
                // (cover shadow in front) when his man is near the ball;
                // tucked toward the ball when he's far from it.
                const int mp = book_.mark_position.bit();
                if (ratings_[slot][mp] > 0 && applies(slot, mp, world.tickCount() / 30)) {
                    const auto& P = book_.mark_position;
                    const Vec2 own_goal{-dsgn * half_x_, Fixed64::zero()};
                    const Vec2 to_goal = math::normalized(Vec2{own_goal.x - mk.pos.x, own_goal.y - mk.pos.y});
                    const Vec2 bm{seen_ball.x - mk.pos.x, seen_ball.y - mk.pos.y};
                    const Fixed64 d = math::length(bm);
                    if (d < P.nearM() && d.raw > 0) {
                        const Vec2 to_ball{bm.x / d, bm.y / d};
                        const Vec2 dir = math::normalized(Vec2{to_goal.x + to_ball.x, to_goal.y + to_ball.y});
                        spot = Vec2{mk.pos.x + dir.x * gap, mk.pos.y + dir.y * gap};
                    } else {
                        spot = Vec2{mk.pos.x + to_goal.x * gap, mk.pos.y + to_goal.y * gap};
                        if (d > P.nearM()) {
                            Fixed64 f = (d - P.nearM()) / (P.farM() - P.nearM());
                            if (f > Fixed64::one()) f = Fixed64::one();
                            Fixed64 k = f * P.tuck();
                            // Never more than max_off_man_m off him (James 10/26:
                            // a full-back tucked 18 m in left their winger open).
                            const Fixed64 to_b = math::length(Vec2{seen_ball.x - spot.x, seen_ball.y - spot.y});
                            const Fixed64 cap = book_.press_distance.maxOffMan();
                            if (to_b * k > cap && to_b.raw > 0) k = cap / to_b;
                            spot = Vec2{spot.x + (seen_ball.x - spot.x) * k, spot.y + (seen_ball.y - spot.y) * k};
                        }
                    }
                }
                // near-tight-far-zone (122, G4.67): the nearer his man is to
                // the ball the tighter (goal-side, ball-side); the further,
                // the more off him toward the middle (goal-side, inside).
                Why mark_why = Why::Mark;
                const int nt = book_.near_tight.bit();
                if (ratings_[slot][nt] > 0 && applies(slot, nt, world.tickCount() / 30)) {
                    const auto& N = book_.near_tight;
                    const Vec2 own_goal{-dsgn * half_x_, Fixed64::zero()};
                    const Vec2 to_goal = math::normalized(Vec2{own_goal.x - mk.pos.x, own_goal.y - mk.pos.y});
                    const Vec2 bm{seen_ball.x - mk.pos.x, seen_ball.y - mk.pos.y};
                    const Fixed64 f = N.farShare(math::length(bm));
                    const Vec2 to_ball = math::normalized(bm);
                    const Fixed64 in = mk.pos.y.raw > 0 ? -Fixed64::one() : (mk.pos.y.raw < 0 ? Fixed64::one() : Fixed64::zero());
                    const Vec2 near_dir = math::normalized(Vec2{to_goal.x + to_ball.x, to_goal.y + to_ball.y});
                    const Vec2 mid_dir = math::normalized(Vec2{to_goal.x, to_goal.y + in});
                    const Fixed64 g = Fixed64::one() - f;
                    const Vec2 dir = math::normalized(Vec2{near_dir.x * g + mid_dir.x * f, near_dir.y * g + mid_dir.y * f});
                    Fixed64 off = N.gap(f);
                    if (f.raw == 0 && gap < off) off = gap;   // man-orientation's tighter gap
                    spot = Vec2{mk.pos.x + dir.x * off, mk.pos.y + dir.y * off};
                    mark_why = f * 2 < Fixed64::one() ? Why::MarkTight : Why::ProtectMiddle;
                }
                // Tactic B (170): our winger shadows the ground ball to my
                // man — play off him, goal-side, for the long ball.
                bool played_off = false;
                {
                    const int po = book_.play_off.bit();
                    if (ratings_[slot][po] > 0 && seen_ball.x * dsgn >= book_.pack_middle.fromHalfway()) {
                        const Trap tr = trapRead(world, my_team, Vec2{seen_ball.x, seen_ball.y});
                        if (tr.winger >= 0 && ratings_[tr.winger][book_.shadow_line.bit()] > 0 &&
                            theirWinger(world, my_team, sign, tr.carrier, tr.cbs) == my_mark &&
                            applies(slot, po, world.tickCount() / 30)) {
                            const Vec2 own_goal{-dsgn * half_x_, Fixed64::zero()};
                            const Vec2 to_goal = math::normalized(Vec2{own_goal.x - mk.pos.x, own_goal.y - mk.pos.y});
                            const Fixed64 off = book_.play_off.off();
                            spot = Vec2{mk.pos.x + to_goal.x * off, mk.pos.y + to_goal.y * off};
                            // He doesn't follow his winger up the field when
                            // the winger drops short (James 10/27: "our fb is
                            // already playing for long ball … to follow a
                            // winger up the field is too much to ask") —
                            // never further up than our highest centre-back
                            // plus ahead_of_line_m; our winger keeps the shadow.
                            bool line = false;
                            Fixed64 top{};
                            for (SlotIndex o = 0; o < world.playerCount(); ++o) {
                                if (setup_.team_of_slot[o] != my_team || o == slot) continue;
                                const int on = numberOf(o);
                                if (on != 4 && on != 5) continue;
                                const Fixed64 x = world.player(o).pos.x * dsgn;
                                if (!line || x > top) { top = x; line = true; }
                            }
                            if (line) {
                                const Fixed64 cap = top + book_.play_off.aheadOfLine();
                                if (spot.x * dsgn > cap) spot.x = cap * dsgn;
                            }
                            mark_why = Why::PlayOff;
                            played_off = true;
                        }
                    }
                }
                // the one spot (163/164, G4.63): his man in pressing distance,
                // another's lane cut, more men in reach to help.
                if (!played_off && ball.owner && *ball.owner != my_mark) {
                    const int ss = book_.shadow_second.bit(), pd = book_.press_distance.bit();
                    const bool sh = ratings_[slot][ss] > 0 && applies(slot, ss, sec);
                    const bool hp = ratings_[slot][pd] > 0 && applies(slot, pd, sec);
                    if (sh || hp) {
                        const Vec2 B{world.player(*ball.owner).pos.x, world.player(*ball.owner).pos.y};
                        const Vec2 s2 = oneSpot(slot, world, my_mark, spot, B, *ball.owner, sh, hp);
                        if (s2.x != spot.x || s2.y != spot.y) { spot = s2; mark_why = Why::ShadowHelp; }
                    }
                }
                out.move.move = seek(me.pos, spot, Fixed64::fromFraction(1, 2));
                out.why = mark_why;
                out.target = spot;
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
