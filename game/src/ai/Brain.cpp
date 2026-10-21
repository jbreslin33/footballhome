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
        const Vec2 goal{sign >= 0 ? half_x_ : -half_x_, Fixed64::zero()};
        const Vec2 to_goal{goal.x - me.pos.x, goal.y - me.pos.y};
        if (math::lengthSquared(to_goal) < kShootRange * kShootRange) {
            // Placement (G4.3b): aim inside the post AWAY from the
            // keeper's current side — a placed 24 m/s strike beats
            // angle-play positioning; a sprayed one doesn't (level
            // noise decides which you hit).
            Fixed64 aim_y = Fixed64::fromFraction(28, 10);
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
                open = pointSegmentDistSq(
                           Vec2{world.player(j).pos.x, world.player(j).pos.y},
                           a, b) > kLaneWidth * kLaneWidth;
            }
            if (!open) continue;
            if (!have_target || progress > best_progress) {
                have_target = true;
                best_progress = progress;
                target = b;
                target_dist_sq = dsq;
            }
        }

        if (have_target &&
            (pressed || best_progress - my_progress > kEagerGain * jitter)) {
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
            if (beyond_line && lv.swarm_pct < 40 &&
                target_dist_sq > kSoftPassRange * kSoftPassRange) {
                out.action = Action::LoftedKick;  // over the top
            } else {
                out.action = target_dist_sq < kSoftPassRange * kSoftPassRange
                                 ? Action::ShortPass
                                 : Action::GroundKick;
            }
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
        // level ladder until gated).
        if (!ball.owner && ball_in_my_third && lv.swarm_pct < 40) {
            out.move.move = seek(me.pos, Vec2{seen_ball.x, seen_ball.y},
                                 Fixed64::fromFraction(1, 10));
            return out;
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
        if (incoming && speed_sq > Fixed64::fromInt(144) &&
            math::fx_abs(ball.vel.x) > Fixed64::one()) {
            const Fixed64 flight_t =
                (anchor.x - seen_ball.x) / ball.vel.x;
            y = seen_ball.y + ball.vel.y * flight_t;
        }
        const Fixed64 lim = Fixed64::fromInt(6);
        if (y > lim) y = lim;
        if (y < -lim) y = -lim;
        anchor.y = y;
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
            const Fixed64 hold = seen_ball.x * sgn - Fixed64::fromInt(25);
            if (cover < hold) cover = hold;
            if (anchor.x * sgn > cover) anchor.x = cover * sgn;
            // Never retreat into the goal itself.
            const Fixed64 floor_x = -(half_x_ - Fixed64::fromInt(4));
            if (anchor.x * sgn < floor_x) anchor.x = floor_x * sgn;
        }
        // 3. Cover man: second-closest to the ball shadows the ball→goal
        //    line, 7 m goal-side.
        if (teamCloserCount(slot, world, seen_ball) == 1) {
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
        const bool undisciplined = lv.swarm_pct >= 40;

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
            const int eagerness = 4 + lv.swarm_pct / 2;  // %/tick
            if ((n + Fixed64::one()) < Fixed64::fromFraction(eagerness, 50)) {
                out.move.move = seek(me.pos, Vec2{ball.pos.x, ball.pos.y},
                                     Fixed64::fromFraction(1, 10));
                out.action = Action::Tackle;
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
                out.move.move = seek(me.pos, Vec2{seen_ball.x, seen_ball.y},
                                     Fixed64::fromFraction(1, 10));
                if (ball.owner &&
                    distSq(me.pos, ball.pos) <
                        core::kTackleReach * core::kTackleReach) {
                    const Fixed64 n = core::detNoise(
                        match_seed_, world.tickCount(), slot, 7);
                    const int eagerness = 4 + lv.swarm_pct / 2;  // %/tick
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
            const Vec2 jockey{
                seen_ball.x - dsgn * Fixed64::fromFraction(11, 5),
                seen_ball.y};
            out.move.move = seek(me.pos, jockey, Fixed64::fromFraction(3, 10));
            return out;
        }

        // ORGANIZE: non-engaged defenders take MARKS — greedy unique
        // assignment in slot order over goal-side opponents, standing
        // 1.5 m goal-side of the mark. Whoever finds no mark is the free
        // man and falls through to the shape rules.
        if (ball.owner && rank >= 2 && !undisciplined) {
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
                    if (world.player(o).pos.x * dsgn >=
                        seen_ball.x * dsgn + Fixed64::fromInt(5))
                        continue;  // not goal-side enough to threaten
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
                out.move.move = seek(
                    me.pos,
                    Vec2{mk.pos.x - dsgn * Fixed64::fromFraction(3, 2),
                         mk.pos.y},
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

        // ── run in behind (G4.8): the most ADVANCED disciplined attacker
        // attacks the space beyond their last outfield defender — the
        // run that makes the over-the-top ball a weapon and drags their
        // line deep. Ball-watchers (swarm ≥ 40) never make it.
        if (lv.swarm_pct < 40) {
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
        if (closer_to_carrier == 1 && lv.swarm_pct < 40) {
            out.move.move = seek(
                me.pos,
                Vec2{carrier.pos.x - sgn2 * Fixed64::fromInt(8),
                     carrier.pos.y * Fixed64::fromFraction(3, 4)},
                kArriveRadius);
            return out;
        }

        const bool im_support = closer_to_carrier == 0;
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

    // ── otherwise: hold the shifted anchor (shape IS support) ──────────
    out.move.move = seek(me.pos, anchor, kArriveRadius);
    return out;
}

}  // namespace fh::game::ai
