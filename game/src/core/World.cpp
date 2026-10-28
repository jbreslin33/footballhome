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
      carry_m_(player_count, 0),
      pass_to_(player_count, 0xFF),
      bodies_(player_count),
      keeper_(player_count, false),
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

void World::setAction(SlotIndex slot, Action action, std::uint8_t carry_m,
                      std::uint8_t pass_to) {
    if (slot >= actions_.size()) return;
    if (action == Action::None) return;  // only non-None latches
    actions_[slot] = action;
    carry_m_[slot] = carry_m;
    pass_to_[slot] = pass_to;
}

void World::placePlayer(SlotIndex slot, const Vec3& pos, const Vec2& face) {
    if (slot >= players_.size()) return;
    players_[slot].pos = pos;
    players_[slot].vel = Vec3{};  // placed standing (G4.51: speed is state)
    players_[slot].dive_ticks = 0;
    players_[slot].recovery_ticks = 0;   // a coach's restart: everyone on his feet
    players_[slot].recovery_kind = 0;
    players_[slot].face = face;
}

void World::setTeam(SlotIndex slot, std::uint8_t team) {
    if (slot >= players_.size()) return;
    players_[slot].team = team;
}

void World::setLevel(std::uint8_t team, const LevelParams& params) {
    level_[team & 1] = params;
}

void World::setSlotLevel(SlotIndex slot, const LevelParams& params) {
    if (slot >= players_.size()) return;
    if (slot_level_.size() < players_.size()) {
        slot_level_.resize(players_.size());
        slot_level_set_.resize(players_.size(), 0);
    }
    slot_level_[slot] = params;
    slot_level_set_[slot] = 1;
}

void World::setKeeper(SlotIndex slot, bool keeper) {
    if (slot >= keeper_.size()) return;
    keeper_[slot] = keeper;
}

void World::tickPlayers() {
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        PlayerState& p = players_[i];
        // Tackle recovery: sprawled on the turf — no movement this tick.
        if (p.recovery_ticks > 0) {
            if (--p.recovery_ticks == 0) p.recovery_kind = 0;
            p.vel = Vec3{};
            continue;
        }
        Vec2 desire = intents_[i].move;
        if (math::lengthSquared(desire) > Fixed64::one()) {
            desire = desire.normalized();  // hostile overlong vector buys nothing
        }
        // Locomotion (G4.51): velocity relaxes toward the wanted one
        // (Locomotion.hpp) — no more 0 → top speed in a tick, no free
        // reversals. A carrier's top speed is the dribble share of his own.
        const Body& body = bodies_[i];
        const Fixed64 top = (ball_.owner && *ball_.owner == i) ? p.max_speed * body.dribble()
                                                               : p.max_speed;
        // In the air from a dive he goes where he launched (G4.51).
        const bool flying = p.dive_ticks > 0;
        // Facing (G4.53): his body turns toward where he wants to face —
        // the intent's face, else the way he's trying to go — at his own
        // yaw rate; moving off that line costs speed (Body::gait).
        if (!flying) {
            Vec2 want = intents_[i].face;
            if (want.x.raw == 0 && want.y.raw == 0) want = desire;
            if (want.x.raw != 0 || want.y.raw != 0)
                p.face = body.turnToward(p.face, math::normalized(want), kTickDt);
        }
        Fixed64 share = Fixed64::one();
        if (desire.x.raw != 0 || desire.y.raw != 0)
            share = body.gait(p.face, math::normalized(desire));
        const Vec2 v = flying ? Vec2{p.vel.x, p.vel.y}
                              : body.step(Vec2{p.vel.x, p.vel.y},
                                           Vec2{desire.x * top * share, desire.y * top * share}, kTickDt);
        p.vel = Vec3{v.x, v.y, Fixed64::zero()};
        p.pos += p.vel * kTickDt;
        // Pitch bounds (+2 m apron): G1's live test watched a scorer chase
        // the ball clean off the grass. Hard clamp, no bounce — players
        // aren't balls.
        const Fixed64 margin = Fixed64::fromInt(2);
        // The wall also stops him (G4.51): no speed kept into it.
        if (p.pos.x > half_x_ + margin) { p.pos.x = half_x_ + margin; p.vel.x = Fixed64::zero(); }
        if (p.pos.x < -half_x_ - margin) { p.pos.x = -half_x_ - margin; p.vel.x = Fixed64::zero(); }
        if (p.pos.y > half_y_ + margin) { p.pos.y = half_y_ + margin; p.vel.y = Fixed64::zero(); }
        if (p.pos.y < -half_y_ - margin) { p.pos.y = -half_y_ - margin; p.vel.y = Fixed64::zero(); }
        if (flying && --p.dive_ticks == 0) {  // lands: down on the turf
            p.vel = Vec3{};
            p.recovery_ticks = loco_.diveGroundTicks();
            p.recovery_kind = 3;
        }
        // In the air from a dive he faces where he flies.
        if (flying && math::lengthSquared(v) >= Fixed64::fromFraction(1, 4))
            p.face = math::normalized(v);
    }

    // Player-player collisions [v1 Slice 27]: circle-circle overlap is
    // resolved by pushing both bodies apart equally along the centre
    // axis (equal mass until body attributes land). One pass suffices:
    // max closing speed is ~0.4 m/tick against a 0.9 m combined radius.
    // Deterministic: fixed i<j order, exact-overlap fallback is slot-
    // indexed. James's "bunching stops goals" becomes physical — you
    // cannot dribble THROUGH a crowd any more.
    const Fixed64 min_dist = kPlayerRadius + kPlayerRadius;
    const Fixed64 min_dist_sq = min_dist * min_dist;
    for (SlotIndex i = 0; i + 1 < players_.size(); ++i) {
        for (SlotIndex j = i + 1; j < players_.size(); ++j) {
            Vec2 d{players_[j].pos.x - players_[i].pos.x,
                   players_[j].pos.y - players_[i].pos.y};
            const Fixed64 dsq = math::lengthSquared(d);
            if (dsq >= min_dist_sq) continue;
            if (dsq.raw == 0) {
                // Exact overlap: separate along x, lower slot goes -x.
                d = Vec2{Fixed64::fromFraction(1, 100), Fixed64::zero()};
            }
            const Fixed64 dist = math::length(d);
            const Vec2 n = (dist.raw == 0)
                               ? Vec2{Fixed64::one(), Fixed64::zero()}
                               : Vec2{d.x / dist, d.y / dist};
            const Fixed64 push = (min_dist - dist) * Fixed64::fromFraction(1, 2);
            players_[i].pos.x -= n.x * push;
            players_[i].pos.y -= n.y * push;
            players_[j].pos.x += n.x * push;
            players_[j].pos.y += n.y * push;
        }
    }

    // Re-clamp after collision pushes.
    const Fixed64 m2 = Fixed64::fromInt(2);
    for (auto& p : players_) {
        if (p.pos.x > half_x_ + m2) p.pos.x = half_x_ + m2;
        if (p.pos.x < -half_x_ - m2) p.pos.x = -half_x_ - m2;
        if (p.pos.y > half_y_ + m2) p.pos.y = half_y_ + m2;
        if (p.pos.y < -half_y_ - m2) p.pos.y = -half_y_ - m2;
    }
}

void World::tickDives() {
    // Keeper dives (G4.51): consumed here, before movement, so the launch
    // tick already flies. Only a keeper, on his feet, without the ball.
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        if (actions_[i] != Action::Dive) continue;
        actions_[i] = Action::None;
        PlayerState& p = players_[i];
        if (!keeper_[i] || p.recovery_ticks > 0 || p.dive_ticks > 0) continue;
        if (ball_.owner && *ball_.owner == i) continue;
        const Vec2 desire = intents_[i].move;
        if (desire.x.raw == 0 && desire.y.raw == 0) continue;
        const Vec2 dir = math::normalized(desire);
        const Fixed64 dive = bodies_[i].diveSpeed();
        p.vel = Vec3{dir.x * dive, dir.y * dive, Fixed64::zero()};
        p.dive_ticks = loco_.diveAirTicks();
        p.face = dir;
    }
}

void World::tickTackles(std::vector<MatchEvent>& events) {
    // Committed dives (G4.6). Resolved BEFORE kicks, so a well-timed
    // tackle blocks the shot that was about to fire. Only non-owners
    // tackle; only an OPPONENT'S carried ball can be won; a lunge at
    // nothing still costs the recovery (the whiff).
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        if (actions_[i] != Action::Tackle) continue;
        actions_[i] = Action::None;
        PlayerState& tackler = players_[i];
        if (tackler.recovery_ticks > 0) continue;
        if (ball_.owner && *ball_.owner == i) continue;  // you HAVE it

        const bool opponents_ball =
            ball_.owner &&
            players_[*ball_.owner].team != tackler.team;
        const Vec2 d{ball_.pos.x - tackler.pos.x,
                     ball_.pos.y - tackler.pos.y};
        const bool in_reach =
            math::lengthSquared(d) <= kTackleReach * kTackleReach &&
            ball_.pos.z < Fixed64::one();

        if (!opponents_ball || !in_reach) {
            tackler.recovery_ticks = kTackleMissRecovery;  // whiffed
            tackler.recovery_kind = 1;
            continue;
        }

        // Outcome by the tackler's level skill, deterministic noise.
        const LevelParams& lv = levelOf(i);
        const int skill =
            lv.tackle_success_pct > 0 ? lv.tackle_success_pct : 70;
        const Fixed64 roll = detNoise(match_seed_, clock_.tick(), i, 6);
        // roll in [-1,1) → success iff (roll+1)/2 < skill%.
        const bool won =
            (roll + Fixed64::one()) <
            Fixed64::fromFraction(skill, 50);  // skill% of the [0,2) span
        if (won) {
            // A won tackle (G4.24) is a CLEAN WIN most of the time — the
            // tackler comes away with it and the dispossessed carrier is
            // off balance — else the ball squirts SIDEWAYS, across the
            // carrier's line: a true 50/50. The old poke drove the ball
            // from the tackler THROUGH the ball line, i.e. from a front-on
            // tackle straight back to the carrier's feet: world matches
            // won 52 tackles and changed possession 5 times.
            const SlotIndex carrier = *ball_.owner;
            PlayerState& cp = players_[carrier];
            cp.recovery_ticks = kDispossessedRecovery;
            cp.recovery_kind = 2;
            ball_.contest_ticks = 0;
            last_touch_team_ = tackler.team;
            box_clear_team_ = 0xFF;
            losing_team_ = cp.team;
            turnover_tick_ = clock_.tick();
            turnover_ball_x_ = ball_.pos.x;
            const Fixed64 r2 = detNoise(match_seed_, clock_.tick(), i, 14);
            if ((r2 + Fixed64::one()) < Fixed64::fromFraction(7, 5)) {
                ball_.owner = i;  // clean: 70% of won tackles
                owned_at_tick_ = clock_.tick();
                ball_.vel = Vec3{};
            } else {
                // Squirt across the carrier→ball line; side by noise sign.
                const Vec2 cb{ball_.pos.x - cp.pos.x, ball_.pos.y - cp.pos.y};
                const Fixed64 cl = math::length(cb);
                Vec2 n = cl.raw == 0 ? Vec2{Fixed64::zero(), Fixed64::one()}
                                     : Vec2{-cb.y / cl, cb.x / cl};
                if (r2.raw & 1) n = Vec2{-n.x, -n.y};
                ball_.owner.reset();
                ball_.vel = Vec3{n.x * kTacklePokeSpeed,
                                 n.y * kTacklePokeSpeed, Fixed64::zero()};
                ball_.kick_alive = kKickAliveTicks;
            }
            tackler.recovery_ticks = kTackleWinRecovery;
            tackler.recovery_kind = 1;
            events.push_back({MatchEventType::TackleWon, tackler.team});
        } else {
            tackler.recovery_ticks = kTackleMissRecovery;  // beaten
            tackler.recovery_kind = 1;
            events.push_back({MatchEventType::TackleLost, tackler.team});
        }
    }
}

void World::tickPossessionAndKicks(std::vector<MatchEvent>& events) {
    pending_events_ = &events;
    // ── carry ───────────────────────────────────────────────────────────
    if (ball_.owner) {
        const PlayerState& o = players_[*ball_.owner];

        // Consume a latched kick before gluing, so the kick leaves from
        // the carry point of the PREVIOUS tick (feels like a real release).
        const SlotIndex kicker = *ball_.owner;
        const Action act = actions_[kicker];
        if (act != Action::None && players_[kicker].recovery_ticks == 0) {
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
            const LevelParams& lv = levelOf(kicker);
            Fixed64 power_scale = Fixed64::one();
            if (lv.kick_angle_err_deg != 0 || lv.kick_power_err_pct != 0 ||
                act == Action::Shot) {
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
                // Shooting is HARD at any level: a flat +5 degrees of
                // match-pressure error on shots, on top of level error.
                // (18 m/s strikes at 1-degree error converted like
                // penalties — nobody finishes like that from 20 m.)
                const bool shot = act == Action::Shot;
                const std::int32_t deg =
                    (shot && lv.shot_angle_err_deg >= 0 ? lv.shot_angle_err_deg
                                                        : lv.kick_angle_err_deg) +
                    (shot ? 5 : 0);
                const Fixed64 ang = n1 * kind_scale *
                    Fixed64::fromInt(deg) *
                    Fixed64::fromFraction(71, 4068);
                const Fixed64 c = math::fx_cos(ang);
                const Fixed64 sn = math::fx_sin(ang);
                dir = Vec2{dir.x * c - dir.y * sn, dir.x * sn + dir.y * c};
                power_scale = Fixed64::one() +
                    n2 * Fixed64::fromFraction(
                             shot && lv.shot_power_err_pct >= 0 ? lv.shot_power_err_pct
                                                                : lv.kick_power_err_pct,
                             100);
            }
            if (act == Action::GroundKick) {
                const Fixed64 v = (carry_m_[kicker] > 0 ? weightedPassSpeed(Fixed64::fromInt(carry_m_[kicker]))
                                                        : kGroundKickSpeed) * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, Fixed64::zero()};
            } else if (act == Action::Shot) {
                // Strike power is a SKILL (G4.14): a level's hardest shot
                // is its control speed + 6 — you can't strike what you
                // can't control. A U-10 "blast" is 12 m/s (his own
                // keeper's hands cap); only the top bands hit the full
                // 24 m/s that outfielders (cap 20) can't even touch.
                Fixed64 top = kShotSpeed;
                if (lv.control_speed_mps > 0) {
                    const Fixed64 ceil =
                        Fixed64::fromInt(lv.control_speed_mps + 12);
                    if (ceil < top) top = ceil;
                }
                const Fixed64 v = top * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, Fixed64::zero()};
            } else if (act == Action::ShortPass) {
                const Fixed64 v = (carry_m_[kicker] > 0 ? weightedPassSpeed(Fixed64::fromInt(carry_m_[kicker]))
                                                        : kShortPassSpeed) * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, Fixed64::zero()};
            } else if (carry_m_[kicker] > 0) {
                // Aimed loft (G4.48): no drag, so the first bounce lands at
                // v² · 2r / g with rise = r · v — solve for v. The power
                // error scales both, so a 10% miss is ~21% of the carry.
                const std::int32_t cap = lv.kick_range_m;
                const Fixed64 d = Fixed64::fromInt(
                    cap > 0 && carry_m_[kicker] > cap ? cap : carry_m_[kicker]);
                const Fixed64 v =
                    math::fx_sqrt(kGravity * d / (kLoftLaunchRatio * 2)) * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, v * kLoftLaunchRatio};
            } else {
                const Fixed64 v = kLoftKickSpeed * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v,
                                 kLoftKickRise * power_scale};
            }
            ball_.owner.reset();
            box_clear_team_ = 0xFF;  // kicked: the goal kick is in play
            ball_.kick_alive = kKickAliveTicks;
            ball_.last_kicker = kicker;
            ball_.kicker_lockout = kKickerLockoutTicks;
            ball_.pass_to = pass_to_[kicker];
            last_touch_team_ = players_[kicker].team;

            // Arm offside (G4.8). Second-last OPPONENT line (keeper
            // counts), the ball, and the halfway line all per the law.
            const std::uint8_t kt = players_[kicker].team;
            const Fixed64 os = kt == 0 ? Fixed64::one() : -Fixed64::one();
            Fixed64 d1 = Fixed64::fromInt(-1000), d2 = d1;
            for (SlotIndex j = 0; j < players_.size(); ++j) {
                if (players_[j].team == kt) continue;
                const Fixed64 depth = players_[j].pos.x * os;
                if (depth > d1) { d2 = d1; d1 = depth; }
                else if (depth > d2) { d2 = depth; }
            }
            offside_mask_ = 0;
            offside_team_ = kt;
            const Fixed64 ball_depth = ball_.pos.x * os;
            for (SlotIndex j = 0; j < players_.size(); ++j) {
                if (players_[j].team != kt || j == kicker) continue;
                const Fixed64 depth = players_[j].pos.x * os;
                if (depth > d2 && depth > ball_depth &&
                    depth > Fixed64::zero()) {
                    offside_mask_ |= (1u << (j & 31));
                }
            }
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
                losing_team_ = players_[*ball_.owner].team;
                turnover_tick_ = clock_.tick();
                turnover_ball_x_ = ball_.pos.x;
                ball_.owner = thief;
                owned_at_tick_ = clock_.tick();
                box_clear_team_ = 0xFF;
                ball_.contest_ticks = 0;
            }
        } else {
            ball_.contest_ticks = 0;
        }
        return;
    }

    // ── first-touch capture [v1 rules] + touch quality + keeper hands ──
    // Nearest in-radius player wins (lower slot breaks ties). Keepers
    // reach wider and higher and handle faster balls (G4.3b). A ball too
    // fast for the winner's CONTROL level bobbles off the touch instead
    // of sticking — a deflection, not a catch.
    const Fixed64 planar_speed_sq = ball_.vel.x * ball_.vel.x +
                                    ball_.vel.y * ball_.vel.y;

    // Body block (G4.25): a ball too fast to CONTROL still hits bodies.
    // Above the capture cap outfielders were ghosts — a 24 m/s shot
    // passed through them (world: 0% of shots blocked; real ~a quarter
    // to a third), and at 0.8 m/tick it could also tunnel past a 0.5 m
    // capture radius. Sweep this tick's path; the first OPPONENT
    // outfield body within body radius below head height rebounds it —
    // reversed, ±60° noise, 30% of its speed.
    if (planar_speed_sq > kCaptureMaxSpeed * kCaptureMaxSpeed &&
        ball_.pos.z < kBodyHeight) {
        const Vec2 a{ball_.pos.x, ball_.pos.y};
        const Vec2 step{ball_.vel.x * kTickDt, ball_.vel.y * kTickDt};
        const Fixed64 step_sq = math::lengthSquared(step);
        bool hit = false;
        Fixed64 best_t{};
        SlotIndex blocker = 0;
        for (SlotIndex i = 0; i < players_.size(); ++i) {
            if (keeper_[i]) continue;
            if (ball_.kicker_lockout > 0 && i == ball_.last_kicker) continue;
            // Opponents block; the kicker's teammates are assumed to get
            // out of the way (blocked shots are defenders' bodies).
            if (ball_.last_kicker < players_.size() &&
                players_[i].team == players_[ball_.last_kicker].team)
                continue;
            const Vec2 ap{players_[i].pos.x - a.x, players_[i].pos.y - a.y};
            Fixed64 t = step_sq.raw == 0
                            ? Fixed64::zero()
                            : (ap.x * step.x + ap.y * step.y) / step_sq;
            if (t < Fixed64::zero()) t = Fixed64::zero();
            if (t > Fixed64::one()) t = Fixed64::one();
            const Vec2 c{a.x + step.x * t - players_[i].pos.x,
                         a.y + step.y * t - players_[i].pos.y};
            if (math::lengthSquared(c) > kPlayerRadius * kPlayerRadius)
                continue;
            if (!hit || t < best_t) { hit = true; best_t = t; blocker = i; }
        }
        if (hit) {
            const Fixed64 n = detNoise(match_seed_, clock_.tick(), blocker, 15);
            const Fixed64 ang = n * Fixed64::fromFraction(71, 4068) *
                                Fixed64::fromInt(60);
            const Fixed64 c = math::fx_cos(ang);
            const Fixed64 sn = math::fx_sin(ang);
            const Vec2 v{-ball_.vel.x, -ball_.vel.y};
            const Fixed64 keep = Fixed64::fromFraction(3, 10);
            ball_.vel = Vec3{(v.x * c - v.y * sn) * keep,
                             (v.x * sn + v.y * c) * keep, Fixed64::zero()};
            ball_.last_kicker = blocker;
            ball_.pass_to = 0xFF;
            ball_.kicker_lockout = kBobbleLockoutTicks;
            ball_.kick_alive = kKickAliveTicks;
            last_touch_team_ = players_[blocker].team;
            if (offside_team_ != 0xFF &&
                players_[blocker].team != offside_team_) {
                offside_mask_ = 0;
                offside_team_ = 0xFF;
            }
            return;
        }
    }

    bool found = false;
    Fixed64 best_sq{};
    SlotIndex best = 0;
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        if (ball_.kicker_lockout > 0 && i == ball_.last_kicker)
            continue;  // you can't receive your own kick for half a second
        // A pass to a man (G4.81): for that same half second the passer's
        // other mates let it through — he steps over it or out of its way,
        // as the body block already assumes for shots. Traced: the man
        // beside the passer took 1 in 5 of the passes meant for someone
        // 10 m+ free, 0.1-0.3 s after the kick.
        if (ball_.kicker_lockout > 0 && ball_.pass_to != 0xFF && i != ball_.pass_to &&
            ball_.last_kicker < players_.size() && players_[i].team == players_[ball_.last_kicker].team)
            continue;
        // Dead-ball restriction (G3.2): only the awarded team may take a
        // restart's first touch.
        if (restart_team_ != 0xFF && players_[i].team != restart_team_)
            continue;
        const bool gk = keeper_[i];
        const Fixed64 reach = gk ? kKeeperReach : kBallControlRadius;
        const Fixed64 reach_z = gk ? kKeeperReachZ : kBallControlRadius;
        if (ball_.pos.z > reach_z) continue;
        // Hard cap: nobody touches a ball above the engine capture cap
        // (keepers get a hands bonus on top).
        const Fixed64 cap =
            gk ? kCaptureMaxSpeed + kKeeperHandsBonus : kCaptureMaxSpeed;
        if (planar_speed_sq > cap * cap) continue;
        const Vec2 d{players_[i].pos.x - ball_.pos.x,
                     players_[i].pos.y - ball_.pos.y};
        const Fixed64 dsq = math::lengthSquared(d);
        if (dsq > reach * reach) continue;
        if (!found || dsq < best_sq) {
            found = true;
            best_sq = dsq;
            best = i;
        }
    }
    if (!found) return;

    // Offside whistle (G4.8): a flagged teammate of the kicker taking the
    // first touch is caught — indirect free kick (dead ball) where he
    // touched it. Any opponent touch disarms the flags instead.
    if (offside_team_ != 0xFF) {
        if (players_[best].team != offside_team_) {
            offside_mask_ = 0;
            offside_team_ = 0xFF;
        } else if (offside_mask_ & (1u << (best & 31))) {
            const std::uint8_t awarded = offside_team_ == 0 ? 1 : 0;
            offside_mask_ = 0;
            offside_team_ = 0xFF;
            awardRestart(MatchEventType::Offside, awarded,
                         Vec3{ball_.pos.x, ball_.pos.y, Fixed64::zero()},
                         *pending_events_);
            return;
        }
    }

    // Touch quality: a ball faster than the toucher's control level
    // bobbles — deflects onward at reduced speed in a noise-rotated
    // direction — instead of sticking. Keepers add their hands bonus.
    const LevelParams& lv = levelOf(best);
    // Keeper handling (G4.23): a shot-speed ball (> 6 m/s) a keeper
    // reaches can still be FUMBLED, by level. Without it a level's
    // hardest shot (control + 6) equals its own keeper's catch cap, so a
    // U-10 keeper caught every U-10 shot he reached — and youth scoring
    // came almost entirely from an accidental lofted "clear" (G4.23).
    // Two thirds of fumbles parry (rebound in front of goal); a third
    // squirm THROUGH along the ball's own line, as youth spills do.
    bool fumbled = false, squirm = false;
    if (keeper_[best] && lv.keeper_fumble_pct > 0 &&
        planar_speed_sq > Fixed64::fromInt(36)) {
        const Fixed64 r = detNoise(match_seed_, clock_.tick(), best, 11);
        fumbled = (r + Fixed64::one()) <
                  Fixed64::fromFraction(lv.keeper_fumble_pct, 50);
        if (fumbled) {
            const Fixed64 r2 = detNoise(match_seed_, clock_.tick(), best, 12);
            squirm = (r2 + Fixed64::one()) < Fixed64::fromFraction(2, 3);
        }
    }
    if (lv.control_speed_mps > 0 || fumbled) {
        Fixed64 ctrl = Fixed64::fromInt(lv.control_speed_mps);
        if (keeper_[best]) ctrl += kKeeperHandsBonus;
        if (fumbled || planar_speed_sq > ctrl * ctrl) {
            const Fixed64 n =
                detNoise(match_seed_, clock_.tick(), best, 5);
            const Fixed64 ang = n * Fixed64::fromFraction(71, 4068) *
                                Fixed64::fromInt(60);  // up to ±60°
            const Fixed64 c = math::fx_cos(ang);
            const Fixed64 sn = math::fx_sin(ang);
            const Vec2 v{ball_.vel.x, ball_.vel.y};
            Vec2 defl{(v.x * c - v.y * sn) * kBobbleKeep,
                      (v.x * sn + v.y * c) * kBobbleKeep};
            // A keeper's bobble is a PARRY (G4.14): he pushes the ball
            // away from his goal, never through himself into it — the
            // direction-preserving deflection had u14 keepers parrying
            // 23% of shots into their own net (measured).
            if (squirm) {
                defl = Vec2{ball_.vel.x * kBobbleKeep,
                            ball_.vel.y * kBobbleKeep};
            } else if (keeper_[best]) {
                const bool home = players_[best].team == 0;
                // Team 0 defends -x: the parry must carry +x, and vice
                // versa.
                if (home ? defl.x.raw < 0 : defl.x.raw > 0)
                    defl.x = -defl.x;
            }
            ball_.vel = Vec3{defl.x, defl.y, Fixed64::zero()};
            ball_.pos.z = Fixed64::zero();
            ball_.last_kicker = best;
            ball_.pass_to = 0xFF;
            ball_.kicker_lockout = kBobbleLockoutTicks;
            bad_touch_slot_ = best;
            bad_touch_tick_ = clock_.tick();
            last_touch_team_ = players_[best].team;
            return;  // still nobody's ball
        }
    }

    // Possession swap = the transition moment (KNVB's 3rd/4th moment).
    if (last_touch_team_ != players_[best].team) {
        losing_team_ = last_touch_team_;
        turnover_tick_ = clock_.tick();
        turnover_ball_x_ = ball_.pos.x;
    }
    ball_.owner = best;
    owned_at_tick_ = clock_.tick();
    ball_.vel = Vec3{};
    ball_.pos.z = Fixed64::zero();  // keepers bring a high ball down
    ball_.kick_alive = 0;
    ball_.kicker_lockout = 0;
    ball_.contest_ticks = 0;
    last_touch_team_ = players_[best].team;
    restart_team_ = 0xFF;  // the dead ball is live again
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
        if (impact > kBounceDeadSpeed) {
            ball_.vel.x = ball_.vel.x * kBounceSkid;
            ball_.vel.y = ball_.vel.y * kBounceSkid;
        }
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

void World::giveBall(SlotIndex slot) {
    if (slot >= players_.size()) return;
    const PlayerState& p = players_[slot];
    ball_ = BallState{};
    ball_.owner = slot;
    owned_at_tick_ = clock_.tick();
    ball_.pos = Vec3{p.pos.x + p.face.x * kBallCarryLead, p.pos.y + p.face.y * kBallCarryLead, Fixed64::zero()};
    last_touch_team_ = p.team;
    restart_team_ = 0xFF;
    box_clear_team_ = 0xFF;
    offside_mask_ = 0;
    offside_team_ = 0xFF;
}

void World::awardKickoff(std::uint8_t team, std::vector<MatchEvent>& events) {
    ball_ = BallState{};  // centre spot, at rest, free of carriers
    restart_team_ = team;
    last_touch_team_ = team;   // kicking off isn't winning the ball
    box_clear_team_ = 0xFF;
    offside_mask_ = 0;
    offside_team_ = 0xFF;
    events.push_back({MatchEventType::Kickoff, team});
}

void World::awardRestart(MatchEventType type, std::uint8_t team,
                         const Vec3& spot, std::vector<MatchEvent>& events) {
    ball_ = BallState{};
    ball_.pos = spot;
    restart_team_ = team;
    // The dead ball is theirs: taking it isn't a turnover (no counter-press
    // on a goal kick — the old last toucher made it look like a lost ball).
    last_touch_team_ = team;
    box_clear_team_ = type == MatchEventType::GoalKick ? static_cast<std::uint8_t>(team ^ 1) : 0xFF;
    offside_mask_ = 0;
    offside_team_ = 0xFF;
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
    tickDives();
    tickPlayers();
    tickTackles(events);
    tickPossessionAndKicks(events);
    tickFreeBall(events);
    tickClock(events);
    // Actions are per-tick: consumed by the owner's kick above, discarded
    // for everyone else, so a stale tap can't fire ticks later.
    for (auto& a : actions_) a = Action::None;
    for (auto& c : carry_m_) c = 0;
    for (auto& p : pass_to_) p = 0xFF;
    clock_.advance();
    return events;
}

}  // namespace fh::game::core
