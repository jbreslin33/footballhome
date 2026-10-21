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

Vec2 seek(const Vec3& from, const Vec2& to, Fixed64 arrive) {
    const Vec2 d{to.x - from.x, to.y - from.y};
    if (math::lengthSquared(d) < arrive * arrive) {
        return Vec2{};  // close enough — stop
    }
    return math::normalized(d);
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

// Earliest-reach interception of a rolling free ball (G4.14): walk the
// ball's deterministic friction path in 6-tick strides and aim at the
// FIRST point the chaser can reach by the time the ball does. Aiming at
// the ball's current spot is always a step behind; G4.3's naive fixed
// lead aimed PAST the catchable point and measured worse at every level
// (negative result recorded) — the bounded scan can do neither.
Vec2 interceptPoint(const Vec3& my_pos, const Vec3& ball_pos,
                    const Vec3& ball_vel, Fixed64 my_speed) {
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
        const Fixed64 run = my_speed * t + Fixed64::one();
        if (math::lengthSquared(d) <= run * run) return pos;
    }
    // Not reachable inside the scan: chase where it is, as before.
    return Vec2{ball_pos.x, ball_pos.y};
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

Orders Brain::ordersFor(SlotIndex slot, const World& world) const {
    Orders out;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    const int sign = attackSign(slot);

    // Perception delay (G4.3): this brain reacts to where the ball WAS
    // delay ticks ago, approximated linearly (no history state — brains
    // stay pure). Carrier logic is exempt: the ball is at your feet.
    const core::LevelParams& lv = level_[setup_.team_of_slot[slot]];
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
        if (!im_keeper &&
            math::lengthSquared(to_goal) < kShootRange * kShootRange) {
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
            return out;
        }

        // Am I pressed? (Pass eagerness rises under pressure.)
        bool pressed = false;
        for (SlotIndex i = 0; i < world.playerCount() && !pressed; ++i) {
            if (setup_.team_of_slot[i] == setup_.team_of_slot[slot]) continue;
            pressed = distSq(me.pos, world.player(i).pos) <
                      kPressureRadius * kPressureRadius;
        }

        // Best forward receiver with an open lane. Progress = x toward MY
        // goal; deterministic tie-break by slot order (iteration order).
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        const Fixed64 my_progress = me.pos.x * sgn;
        bool have_target = false;
        Fixed64 best_progress{};
        Vec2 target{};
        Fixed64 target_dist_sq{};
        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
            if (i == slot) continue;
            if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
            const auto& mate = world.player(i);
            const Fixed64 progress = mate.pos.x * sgn;
            if (progress < my_progress + Fixed64::fromInt(3)) continue;
            const Fixed64 dsq = distSq(me.pos, mate.pos);
            if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax)
                continue;
            // Lane check: any opponent near the carrier→mate segment?
            bool open = true;
            const Vec2 a{me.pos.x, me.pos.y};
            const Vec2 b{mate.pos.x, mate.pos.y};
            for (SlotIndex j = 0; j < world.playerCount() && open; ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                const Fixed64 lane =
                    kLaneWidth -
                    kLaneWidth * degree(slot, 19) *
                        Fixed64::fromFraction(2, 5);
                open = pointSegmentDistSq(
                           Vec2{world.player(j).pos.x, world.player(j).pos.y},
                           a, b) > lane * lane;
            }
            if (!open) continue;
            if (!have_target || progress > best_progress) {
                have_target = true;
                best_progress = progress;
                target = b;
                target_dist_sq = dsq;
            }
        }

        // verticality [Bielsa/Zeman]: forward FIRST — the gain threshold
        // collapses with the rating (0.4x at 100): play the ball on.
        const Fixed64 vdeg = degree(slot, 19);
        const Fixed64 gain_scale =
            Fixed64::one() - vdeg * Fixed64::fromFraction(6, 10);
        if (have_target &&
            (pressed || im_keeper ||
             best_progress - my_progress > kEagerGain * jitter * gain_scale)) {
            out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            // Over the top (§5.2's worked example, playable at last): a
            // receiver BEYOND their last outfield defender gets a lofted
            // through ball — it flies over the block that a ground pass
            // would have to thread. Disciplined sides only (a U-10
            // doesn't know this ball exists).
            Fixed64 their_line = Fixed64::fromInt(-1000);  // in x*sgn
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                if (world.isKeeper(j)) continue;
                const Fixed64 depth = world.player(j).pos.x * sgn;
                if (depth > their_line) their_line = depth;
            }
            const bool beyond_line = best_progress > their_line;
            if (beyond_line && applies(slot, 6, world.tickCount()) &&
                target_dist_sq > kSoftPassRange * kSoftPassRange) {
                out.action = Action::LoftedKick;  // over the top
            } else {
                out.action = target_dist_sq < kSoftPassRange * kSoftPassRange
                                 ? Action::ShortPass
                                 : Action::GroundKick;
            }
            return out;
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
            return out;
        }

        // No pass: dribble at goal; if touch-tight with no outlet, clear
        // over the press rather than donating a steal.
        out.move.move = seek(me.pos, goal, kArriveRadius);
        if (pressed) {
            bool touch_tight = false;
            for (SlotIndex i = 0; i < world.playerCount() && !touch_tight;
                 ++i) {
                if (setup_.team_of_slot[i] == setup_.team_of_slot[slot])
                    continue;
                touch_tight = distSq(me.pos, world.player(i).pos) <
                              Fixed64::fromFraction(6, 5) *
                                  Fixed64::fromFraction(6, 5);
            }
            if (touch_tight) out.action = Action::LoftedKick;
        }
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
            applies(slot, 7, world.tickCount())) {
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
        if (reacted && incoming && speed_sq > Fixed64::fromInt(16) &&
            math::fx_abs(ball.vel.x) > Fixed64::one()) {
            const Fixed64 flight_t =
                (anchor.x - seen_ball.x) / ball.vel.x;
            y = seen_ball.y + ball.vel.y * flight_t;
        }
        const Fixed64 lim = Fixed64::fromInt(6);
        if (y > lim) y = lim;
        if (y < -lim) y = -lim;
        anchor.y = y;
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
        return out;
    }

    const bool ours =
        ball.owner && setup_.team_of_slot[*ball.owner] ==
                          setup_.team_of_slot[slot];

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
            if (anchor.x * sgn > cover) anchor.x = cover * sgn;
            // Never retreat into the goal itself.
            const Fixed64 floor_x = -(half_x_ - Fixed64::fromInt(4));
            if (anchor.x * sgn < floor_x) anchor.x = floor_x * sgn;
        }
        // 3. Cover man: second-closest to the ball shadows the ball→goal
        //    line, 7 m goal-side.
        if (teamCloserCount(slot, world, seen_ball) == 1 &&
            applies(slot, 12, world.tickCount()) && ball.owner &&
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
    // restraint (bit 21, CONCEPTS.md queue → wired G4.16): the
    // anti-tackle. Dive eagerness (%/tick) scales down with the rating:
    // full rash rate at 0, about a fifth of it at 100 — world matches
    // measured ~245 dive attempts against the ~35 of a real one. The
    // floor keeps the STEP real: organized teams still step in.
    auto restrained = [&](int eag) {
        const int r = ratings_[slot][21];
        return eag - eag * r * 4 / 500;  // 100 → x0.2
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
                    const int eag = restrained(4 + lv.swarm_pct / 2);
                    if ((n2 + Fixed64::one()) <
                        Fixed64::fromFraction(eag, 50)) {
                        out.action = Action::Tackle;
                    }
                }
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
            const int eagerness = restrained(4 + lv.swarm_pct / 2);
            if ((n + Fixed64::one()) < Fixed64::fromFraction(eagerness, 50)) {
                out.move.move = seek(me.pos, Vec2{ball.pos.x, ball.pos.y},
                                     Fixed64::fromFraction(1, 10));
                out.action = Action::Tackle;
                return out;
            }
        }

        // recover_goal_side: I'm upfield of the ball (beaten) — the
        // coached run is to the COVER LINE between ball and goal, never
        // straight at the ball. Kids chase; defenders recover.
        if (applies(slot, 11, world.tickCount()) &&
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
                return out;
            }
        }

        const bool in_range =
            distSq(me.pos, seen_ball) < kChaseRadius * kChaseRadius;
        // Swarmy teams send a MOB at the ball, not one presser.
        const int max_chasers = 1 + lv.swarm_pct / 20;
        const int rank = teamCloserCount(slot, world, seen_ball);
        if (in_range && rank < max_chasers) {
            if (!ball.owner || organized || undisciplined) {
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
                if (!ball.owner &&
                    ball.pos.z < Fixed64::fromFraction(1, 2) &&
                    applies(slot, 20, world.tickCount() / 30))
                    chase_to = interceptPoint(me.pos, seen_ball, ball.vel,
                                              Fixed64::fromInt(6));
                out.move.move = seek(me.pos, chase_to,
                                     Fixed64::fromFraction(1, 10));
                if (ball.owner &&
                    distSq(me.pos, ball.pos) <
                        core::kTackleReach * core::kTackleReach) {
                    const Fixed64 n = core::detNoise(
                        match_seed_, world.tickCount(), slot, 7);
                    const int eagerness = restrained(4 + lv.swarm_pct / 2);
                    if ((n + Fixed64::one()) <
                        Fixed64::fromFraction(eagerness, 50)) {
                        out.action = Action::Tackle;
                    }
                }
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
            out.move.move = seek(me.pos, jockey, Fixed64::fromFraction(3, 10));
            return out;
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
        if (ball.owner && rank >= 2 && applies(slot, 1, world.tickCount())) {
            bool marked[32] = {false};
            SlotIndex my_mark = 255;
            for (SlotIndex d = 0; d < world.playerCount(); ++d) {
                if (setup_.team_of_slot[d] != setup_.team_of_slot[slot])
                    continue;
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
            return out;
        }

        // ── run in behind (G4.8): the most ADVANCED disciplined attacker
        // attacks the space beyond their last outfield defender — the
        // run that makes the over-the-top ball a weapon and drags their
        // line deep. Ball-watchers (swarm ≥ 40) never make it.
        if (applies(slot, 5, world.tickCount() / 30)) {
            bool im_most_advanced = true;
            const Fixed64 my_prog = me.pos.x * sgn2;
            for (SlotIndex i = 0; i < world.playerCount(); ++i) {
                if (i == slot || i == *ball.owner) continue;
                if (setup_.team_of_slot[i] != setup_.team_of_slot[slot])
                    continue;
                if (world.isKeeper(i)) continue;
                const Fixed64 pr = world.player(i).pos.x * sgn2;
                if (pr > my_prog || (pr == my_prog && i < slot))
                    im_most_advanced = false;
            }
            if (im_most_advanced) {
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
    out.move.move = seek(me.pos, anchor, kArriveRadius);
    return out;
}

}  // namespace fh::game::ai
