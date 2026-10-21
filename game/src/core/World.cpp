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
             Fixed64 pitch_half_x, Fixed64 pitch_half_y)
    : players_(player_count),
      intents_(player_count),
      actions_(player_count, Action::None),
      half_x_{pitch_half_x},
      half_y_{pitch_half_y} {
    for (auto& p : players_) p.max_speed = max_speed;
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
        // Track facing from actual movement; idle players keep facing.
        if (desire.x.raw != 0 || desire.y.raw != 0) {
            p.face = math::normalized(desire);
        }
    }
}

void World::tickPossessionAndKicks(std::vector<GoalEvent>& /*events*/) {
    // ── carry ───────────────────────────────────────────────────────────
    if (ball_.owner) {
        const PlayerState& o = players_[*ball_.owner];

        // Consume a latched kick before gluing, so the kick leaves from
        // the carry point of the PREVIOUS tick (feels like a real release).
        const Action act = actions_[*ball_.owner];
        if (act == Action::GroundKick || act == Action::LoftedKick) {
            actions_[*ball_.owner] = Action::None;
            // Direction: live desire when pushing a direction, else facing.
            Vec2 desire = intents_[*ball_.owner].move;
            Vec2 dir = (desire.x.raw != 0 || desire.y.raw != 0)
                           ? math::normalized(desire)
                           : o.face;
            if (act == Action::GroundKick) {
                ball_.vel = Vec3{dir.x * kGroundKickSpeed,
                                 dir.y * kGroundKickSpeed, Fixed64::zero()};
            } else {
                ball_.vel = Vec3{dir.x * kLoftKickSpeed,
                                 dir.y * kLoftKickSpeed, kLoftKickRise};
            }
            ball_.owner.reset();
            ball_.kick_alive = kKickAliveTicks;
            return;  // free-ball physics integrates it this same tick
        }

        // Glue [v1]: ball rides at the owner's feet, ahead of facing.
        ball_.pos = Vec3{o.pos.x + o.face.x * kBallCarryLead,
                         o.pos.y + o.face.y * kBallCarryLead, Fixed64::zero()};
        ball_.vel = o.vel;
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
    }
}

void World::tickFreeBall(std::vector<GoalEvent>& events) {
    if (ball_.owner) return;

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

    // Goal check BEFORE the walls: a ball crossing the end line inside the
    // mouth (and under the bar) scores. Home attacks +x.
    const bool in_mouth_y = math::fx_abs(ball_.pos.y) <= kGoalHalfWidth;
    const bool under_bar  = ball_.pos.z <= kGoalHeight;
    if (ball_.pos.x > half_x_ && in_mouth_y && under_bar) {
        events.push_back(GoalEvent{0});
        resetKickoff();
        return;
    }
    if (ball_.pos.x < -half_x_ && in_mouth_y && under_bar) {
        events.push_back(GoalEvent{1});
        resetKickoff();
        return;
    }

    // Arcade walls [FH placeholder until G3 restarts]: reflect off the
    // pitch bounds so a kickabout never loses the ball.
    if (ball_.pos.x > half_x_) {
        ball_.pos.x = half_x_ + half_x_ - ball_.pos.x;
        ball_.vel.x = -ball_.vel.x;
    } else if (ball_.pos.x < -half_x_) {
        ball_.pos.x = -half_x_ - half_x_ - ball_.pos.x;
        ball_.vel.x = -ball_.vel.x;
    }
    if (ball_.pos.y > half_y_) {
        ball_.pos.y = half_y_ + half_y_ - ball_.pos.y;
        ball_.vel.y = -ball_.vel.y;
    } else if (ball_.pos.y < -half_y_) {
        ball_.pos.y = -half_y_ - half_y_ - ball_.pos.y;
        ball_.vel.y = -ball_.vel.y;
    }
}

void World::resetKickoff() {
    ball_ = BallState{};  // centre spot, at rest, free
}

std::vector<GoalEvent> World::tick() {
    std::vector<GoalEvent> events;
    tickPlayers();
    tickPossessionAndKicks(events);
    tickFreeBall(events);
    // Actions are per-tick: consumed by the owner's kick above, discarded
    // for everyone else, so a stale tap can't fire ticks later.
    for (auto& a : actions_) a = Action::None;
    clock_.advance();
    return events;
}

}  // namespace fh::game::core
