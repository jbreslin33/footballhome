// game/src/core/World.cpp

#include "core/World.hpp"

namespace fh::game::core {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

// Goal mouth: 7.32 m wide, 2.44 m high (laws of the game).
const Fixed64 kGoalHalfWidth = Fixed64::fromFraction(732, 200);  // 3.66
const Fixed64 kGoalHeight    = Fixed64::fromFraction(244, 100);  // 2.44

}  // namespace

World::World(SlotIndex player_count, Fixed64 max_speed,
             Fixed64 pitch_half_x, Fixed64 pitch_half_y,
             std::uint32_t half_length_ticks)
    : players_(player_count),
      intents_(player_count),
      actions_(player_count, Action::None),
      half_x_{pitch_half_x},
      half_y_{pitch_half_y},
      half_length_ticks_{half_length_ticks} {
    for (auto& p : players_) p.max_speed = max_speed;
    // The opening kickoff belongs to home; the ball starts dead on the
    // spot so an away player can't poach it before "the whistle".
    restart_team_ = 0;
}

void World::setIntent(SlotIndex slot, const MoveIntent& intent) {
    if (slot >= intents_.size()) return;  // unknown slot: drop, never throw
    intents_[slot] = intent;
}

void World::setAction(SlotIndex slot, Action action) {
    if (slot >= actions_.size()) return;
    if (action == Action::None) return;  // only non-None latches
    actions_[slot] = action;
}

void World::placePlayer(SlotIndex slot, const Vec3& pos, const Vec2& face) {
    if (slot >= players_.size()) return;
    players_[slot].pos = pos;
    players_[slot].face = face;
}

void World::setTeam(SlotIndex slot, std::uint8_t team) {
    if (slot >= players_.size()) return;
    players_[slot].team = team;
}

void World::setLevel(std::uint8_t team, const LevelParams& params) {
    level_[team & 1] = params;
}

void World::tickPlayers() {
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        Vec2 desire = intents_[i].move;
        if (math::lengthSquared(desire) > Fixed64::one()) {
            desire = desire.normalized();  // hostile overlong vector buys nothing
        }
        PlayerState& p = players_[i];
        p.vel = Vec3{desire.x * p.max_speed, desire.y * p.max_speed,
                     Fixed64::zero()};
        p.pos += p.vel * kTickDt;
        // Pitch bounds (+2 m apron): G1's live test watched a scorer chase
        // the ball clean off the grass. Hard clamp, no bounce — players
        // aren't balls.
        const Fixed64 margin = Fixed64::fromInt(2);
        if (p.pos.x > half_x_ + margin) p.pos.x = half_x_ + margin;
        if (p.pos.x < -half_x_ - margin) p.pos.x = -half_x_ - margin;
        if (p.pos.y > half_y_ + margin) p.pos.y = half_y_ + margin;
        if (p.pos.y < -half_y_ - margin) p.pos.y = -half_y_ - margin;
        // Track facing from actual movement; idle players keep facing.
        if (desire.x.raw != 0 || desire.y.raw != 0) {
            p.face = math::normalized(desire);
        }
    }
}

void World::tickPossessionAndKicks(std::vector<MatchEvent>& /*events*/) {
    // ── carry ───────────────────────────────────────────────────────────
    if (ball_.owner) {
        const PlayerState& o = players_[*ball_.owner];

        // Consume a latched kick before gluing, so the kick leaves from
        // the carry point of the PREVIOUS tick (feels like a real release).
        const SlotIndex kicker = *ball_.owner;
        const Action act = actions_[kicker];
        if (act == Action::GroundKick || act == Action::LoftedKick ||
            act == Action::ShortPass) {
            actions_[kicker] = Action::None;
            // Direction: live desire when pushing a direction, else facing.
            Vec2 desire = intents_[*ball_.owner].move;
            Vec2 dir = (desire.x.raw != 0 || desire.y.raw != 0)
                           ? math::normalized(desire)
                           : o.face;

            // Execution noise (G4.3): rotate the kick by a level-scaled
            // deterministic error and scale its power. A pro's error is a
            // couple of degrees; a U-10 sprays it. Zero params = exact,
            // which is the baseline every pre-G4.3 golden locks.
            const LevelParams& lv = level_[players_[kicker].team & 1];
            Fixed64 power_scale = Fixed64::one();
            if (lv.kick_angle_err_deg != 0 || lv.kick_power_err_pct != 0) {
                const Fixed64 n1 =
                    detNoise(match_seed_, clock_.tick(), kicker, 1);
                const Fixed64 n2 =
                    detNoise(match_seed_, clock_.tick(), kicker, 2);
                // degrees → radians: deg * 2π/360 ≈ deg * 71/4068.
                // Short feet-to-feet balls are easier than drives/chips:
                // half the angle error on a ShortPass, full on a drive,
                // 1.25x on a loft.
                Fixed64 kind_scale = Fixed64::one();
                if (act == Action::ShortPass)
                    kind_scale = Fixed64::fromFraction(1, 2);
                else if (act == Action::LoftedKick)
                    kind_scale = Fixed64::fromFraction(5, 4);
                const Fixed64 ang = n1 * kind_scale *
                    Fixed64::fromInt(lv.kick_angle_err_deg) *
                    Fixed64::fromFraction(71, 4068);
                const Fixed64 c = math::fx_cos(ang);
                const Fixed64 sn = math::fx_sin(ang);
                dir = Vec2{dir.x * c - dir.y * sn, dir.x * sn + dir.y * c};
                power_scale = Fixed64::one() +
                    n2 * Fixed64::fromFraction(lv.kick_power_err_pct, 100);
            }
            if (act == Action::GroundKick) {
                const Fixed64 v = kGroundKickSpeed * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, Fixed64::zero()};
            } else if (act == Action::ShortPass) {
                const Fixed64 v = kShortPassSpeed * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, Fixed64::zero()};
            } else {
                const Fixed64 v = kLoftKickSpeed * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v,
                                 kLoftKickRise * power_scale};
            }
            ball_.owner.reset();
            ball_.kick_alive = kKickAliveTicks;
            ball_.last_kicker = kicker;
            ball_.kicker_lockout = kKickerLockoutTicks;
            last_touch_team_ = players_[kicker].team;
            return;  // free-ball physics integrates it this same tick
        }

        // Glue [v1]: ball rides at the owner's feet, ahead of facing.
        ball_.pos = Vec3{o.pos.x + o.face.x * kBallCarryLead,
                         o.pos.y + o.face.y * kBallCarryLead, Fixed64::zero()};
        ball_.vel = o.vel;

        // Touch-to-steal contest [v1]: an opponent touch-tight on the
        // carried ball for kStealTicks takes it (nearest wins, lower slot
        // breaks ties). Teammates never contest.
        const Fixed64 steal_sq = kStealRadius * kStealRadius;
        bool contested = false;
        Fixed64 best_sq{};
        SlotIndex thief = 0;
        for (SlotIndex i = 0; i < players_.size(); ++i) {
            if (i == *ball_.owner) continue;
            if (players_[i].team == players_[*ball_.owner].team) continue;
            const Vec2 d{players_[i].pos.x - ball_.pos.x,
                         players_[i].pos.y - ball_.pos.y};
            const Fixed64 dsq = math::lengthSquared(d);
            if (dsq > steal_sq) continue;
            if (!contested || dsq < best_sq) {
                contested = true;
                best_sq = dsq;
                thief = i;
            }
        }
        if (contested) {
            if (++ball_.contest_ticks >= kStealTicks) {
                ball_.owner = thief;
                ball_.contest_ticks = 0;
            }
        } else {
            ball_.contest_ticks = 0;
        }
        return;
    }

    // ── first-touch capture [v1 rules] ──────────────────────────────────
    // Slow, low, free ball; nearest in-radius player wins; lower slot
    // breaks ties. A fast ball runs through everyone in G1 (controlled
    // first touch is a G2 mechanic).
    const Fixed64 planar_speed_sq = ball_.vel.x * ball_.vel.x +
                                    ball_.vel.y * ball_.vel.y;
    if (planar_speed_sq > kCaptureMaxSpeed * kCaptureMaxSpeed) return;
    if (ball_.pos.z > kBallControlRadius) return;

    const Fixed64 radius_sq = kBallControlRadius * kBallControlRadius;
    bool found = false;
    Fixed64 best_sq{};
    SlotIndex best = 0;
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        if (ball_.kicker_lockout > 0 && i == ball_.last_kicker)
            continue;  // you can't receive your own kick for half a second
        // Dead-ball restriction (G3.2): only the awarded team may take a
        // restart's first touch.
        if (restart_team_ != 0xFF && players_[i].team != restart_team_)
            continue;
        const Vec2 d{players_[i].pos.x - ball_.pos.x,
                     players_[i].pos.y - ball_.pos.y};
        const Fixed64 dsq = math::lengthSquared(d);
        if (dsq > radius_sq) continue;
        if (!found || dsq < best_sq) {
            found = true;
            best_sq = dsq;
            best = i;
        }
    }
    if (found) {
        ball_.owner = best;
        ball_.vel = Vec3{};
        ball_.kick_alive = 0;
        ball_.kicker_lockout = 0;
        ball_.contest_ticks = 0;
        last_touch_team_ = players_[best].team;
        restart_team_ = 0xFF;  // the dead ball is live again
    }
}

void World::tickFreeBall(std::vector<MatchEvent>& events) {
    if (ball_.owner) return;
    if (ball_.kicker_lockout > 0) --ball_.kicker_lockout;

    // Vertical: gravity while airborne, bounce on impact.
    const bool airborne = ball_.pos.z.raw > 0 || ball_.vel.z.raw != 0;
    if (airborne) {
        ball_.vel.z -= kGravity * kTickDt;
    }

    ball_.pos += ball_.vel * kTickDt;

    if (ball_.pos.z.raw < 0) {
        ball_.pos.z = Fixed64::zero();
        const Fixed64 impact = -ball_.vel.z;
        ball_.vel.z = (impact > kBounceDeadSpeed)
                          ? impact * kBallRestitution
                          : Fixed64::zero();
    }

    // Ground roll [v1]: multiplicative decay + snap-to-rest (suppressed
    // during the kick-alive runway so short passes reach their receiver).
    if (ball_.pos.z.raw == 0 && ball_.vel.z.raw == 0) {
        ball_.vel.x = ball_.vel.x * kBallRollDecayPerTick;
        ball_.vel.y = ball_.vel.y * kBallRollDecayPerTick;
        if (ball_.kick_alive > 0) {
            --ball_.kick_alive;
        } else if (math::fx_abs(ball_.vel.x) < kBallRestThreshold &&
                   math::fx_abs(ball_.vel.y) < kBallRestThreshold) {
            ball_.vel.x = Fixed64::zero();
            ball_.vel.y = Fixed64::zero();
        }
    }

    // ── end lines: goal, corner, or goal kick (G3.2) ────────────────────
    const bool in_mouth_y = math::fx_abs(ball_.pos.y) <= kGoalHalfWidth;
    const bool under_bar  = ball_.pos.z <= kGoalHeight;
    const Fixed64 corner_y =
        ball_.pos.y.raw >= 0 ? half_y_ - Fixed64::one() : -half_y_ + Fixed64::one();
    if (ball_.pos.x > half_x_) {
        if (in_mouth_y && under_bar) {
            ++score_[0];
            events.push_back({MatchEventType::Goal, 0});
            awardKickoff(1, events);  // conceders restart
            return;
        }
        // Over the +x end line: home attacks here. Last touch decides.
        if (last_touch_team_ == 1) {  // defender touched out → corner
            awardRestart(MatchEventType::Corner, 0,
                         Vec3{half_x_ - Fixed64::one(), corner_y,
                              Fixed64::zero()}, events);
        } else {                       // attacker out → goal kick
            awardRestart(MatchEventType::GoalKick, 1,
                         Vec3{half_x_ - Fixed64::fromInt(6), Fixed64::zero(),
                              Fixed64::zero()}, events);
        }
        return;
    }
    if (ball_.pos.x < -half_x_) {
        if (in_mouth_y && under_bar) {
            ++score_[1];
            events.push_back({MatchEventType::Goal, 1});
            awardKickoff(0, events);
            return;
        }
        if (last_touch_team_ == 0) {
            awardRestart(MatchEventType::Corner, 1,
                         Vec3{-half_x_ + Fixed64::one(), corner_y,
                              Fixed64::zero()}, events);
        } else {
            awardRestart(MatchEventType::GoalKick, 0,
                         Vec3{-half_x_ + Fixed64::fromInt(6), Fixed64::zero(),
                              Fixed64::zero()}, events);
        }
        return;
    }

    // ── side lines: throw-in to the team that didn't touch it out ──────
    // (A throw-in is a kick in v0 — no hands/thrower animation yet.)
    if (ball_.pos.y > half_y_ || ball_.pos.y < -half_y_) {
        const Fixed64 line_y =
            ball_.pos.y.raw > 0 ? half_y_ : -half_y_;
        awardRestart(MatchEventType::ThrowIn,
                     last_touch_team_ == 0 ? 1 : 0,
                     Vec3{ball_.pos.x, line_y, Fixed64::zero()}, events);
        return;
    }
}

void World::awardKickoff(std::uint8_t team, std::vector<MatchEvent>& events) {
    ball_ = BallState{};  // centre spot, at rest, free of carriers
    restart_team_ = team;
    events.push_back({MatchEventType::Kickoff, team});
}

void World::awardRestart(MatchEventType type, std::uint8_t team,
                         const Vec3& spot, std::vector<MatchEvent>& events) {
    ball_ = BallState{};
    ball_.pos = spot;
    restart_team_ = team;
    events.push_back({type, team});
}

void World::tickClock(std::vector<MatchEvent>& events) {
    if (half_length_ticks_ == 0) return;  // untimed sandbox
    ++match_clock_;
    if (period_ == 1 && match_clock_ == half_length_ticks_) {
        period_ = 2;
        events.push_back({MatchEventType::HalfTime, 0});
        // Second half kicks off to the team that didn't open the match.
        awardKickoff(kickoff_team_ == 0 ? 1 : 0, events);
    } else if (period_ == 2 && match_clock_ >= half_length_ticks_ * 2) {
        events.push_back({MatchEventType::FullTime, 0});
        // Perpetual sandbox: full reset, opening kickoff alternates.
        score_[0] = score_[1] = 0;
        match_clock_ = 0;
        period_ = 1;
        kickoff_team_ = kickoff_team_ == 0 ? 1 : 0;
        awardKickoff(kickoff_team_, events);
    }
}

std::vector<MatchEvent> World::tick() {
    std::vector<MatchEvent> events;
    tickPlayers();
    tickPossessionAndKicks(events);
    tickFreeBall(events);
    tickClock(events);
    // Actions are per-tick: consumed by the owner's kick above, discarded
    // for everyone else, so a stale tap can't fire ticks later.
    for (auto& a : actions_) a = Action::None;
    clock_.advance();
    return events;
}

}  // namespace fh::game::core
