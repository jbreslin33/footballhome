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
const Fixed64 kPenaltyDepth     = Fixed64::fromFraction(33, 2);     // 16.5 (Law 1)
const Fixed64 kPenaltyHalfWidth = Fixed64::fromFraction(2016, 100); // 20.16

}  // namespace

World::World(SlotIndex player_count, Fixed64 max_speed,
             Fixed64 pitch_half_x, Fixed64 pitch_half_y,
             std::uint32_t half_length_ticks)
    : players_(player_count),
      intents_(player_count),
      actions_(player_count, Action::None),
      carry_m_(player_count, 0),
      aim_(player_count),
      has_aim_(player_count, 0),
      aim_z_(player_count),
      first_time_(player_count, 0),
      die_(player_count, 0),
      pass_to_(player_count, 0xFF),
      bodies_(player_count),
      keeper_(player_count, false),
      half_x_{pitch_half_x},
      half_y_{pitch_half_y},
      half_length_ticks_{half_length_ticks} {
    for (auto& p : players_) p.max_speed = max_speed;
    skill_.assign(player_count, PlayerSkill::perfect());   // the server sets the real numbers
    for (int i = 0; i < kOfficialCount; ++i)
        officials_.setOfficial(static_cast<OfficialRole>(i), OfficialRatings{}, Body{}, max_speed);
    officials_.place(pitch_half_x, pitch_half_y);
    // The opening kickoff belongs to home; the ball starts dead on the
    // spot so an away player can't poach it before "the whistle".
    restart_team_ = 0;
}

void World::setIntent(SlotIndex slot, const MoveIntent& intent) {
    if (slot >= intents_.size()) return;  // unknown slot: drop, never throw
    intents_[slot] = intent;
}

void World::setAction(SlotIndex slot, Action action, std::uint8_t carry_m,
                      std::uint8_t pass_to, bool first_time, const Vec2* aim, Fixed64 aim_z, bool die) {
    if (slot >= actions_.size()) return;
    if (action == Action::None) return;  // only non-None latches
    actions_[slot] = action;
    carry_m_[slot] = carry_m;
    first_time_[slot] = first_time ? 1 : 0;
    die_[slot] = die ? 1 : 0;
    pass_to_[slot] = pass_to;
    has_aim_[slot] = aim ? 1 : 0;
    if (aim) aim_[slot] = *aim;
    aim_z_[slot] = aim_z;
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
        // G5.4: holding it he takes it along, he doesn't run at goal. A real
        // carry is ~5 m and gains 2-3 m (PL 2015/16). Off without carry_share.
        if (carry_share_.raw > 0 && ball_.owner && *ball_.owner == i && clock_.tick() < hold_until_tick_)
            desire = Vec2{desire.x * carry_share_, desire.y * carry_share_};
        if (math::lengthSquared(desire) > Fixed64::one()) {
            desire = desire.normalized();  // hostile overlong vector buys nothing
        }
        // G5.2: the man taking a throw, goal kick or corner stands on his
        // spot until he's played it; the move is only his aim.
        if (heldRestart() && ball_.owner && *ball_.owner == i) {
            if (intents_[i].face.x.raw == 0 && intents_[i].face.y.raw == 0 &&
                (desire.x.raw != 0 || desire.y.raw != 0))
                p.face = math::normalized(desire);
            desire = Vec2{};
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
        Vec2 desire = intents_[i].move;
        if (carry_share_.raw > 0 && ball_.owner && *ball_.owner == i && clock_.tick() < hold_until_tick_)
            desire = Vec2{desire.x * carry_share_, desire.y * carry_share_};
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
            !heldRestart() && ball_.owner &&
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

        // Law 12 (G5.28): the challenge is a foul at the real share for its third
        // (from the tackler's own goal). G5.40 (Law 14): inside his own penalty
        // area at the area's own real share, and the restart is a penalty from the
        // mark. Advantage: play on (the carrier keeps it); else the restart, dead a
        // real roll.
        {
            const Fixed64 own = (ball_.pos.x * (tackler.team == 0 ? Fixed64::one() : -Fixed64::one())) + half_x_;
            const int third = own < Fixed64::fromInt(35) ? 0 : own < Fixed64::fromInt(70) ? 1 : 2;
            const bool own_box = own < Fixed64::fromFraction(165, 10) && math::fx_abs(ball_.pos.y) < Fixed64::fromFraction(2016, 100);
            const Fixed64 f = (detNoise(match_seed_, clock_.tick(), i, 15) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
            const Fixed64 fp = own_box ? foul_p_area_ : foul_p_[third];
            if (fp.raw > 0 && f < fp) {
                ++fouls_[tackler.team & 1];
                events.push_back({MatchEventType::Foul, tackler.team});
                tackler.recovery_ticks = kTackleMissRecovery;
                tackler.recovery_kind = 1;
                const Fixed64 a = (detNoise(match_seed_, clock_.tick(), i, 16) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
                if (a >= foul_adv_) {
                    const std::uint8_t fouled = players_[*ball_.owner].team;
                    if (own_box) {   // the mark: 11 m out from the fouler's goal line
                        const Fixed64 gx = tackler.team == 0 ? -half_x_ : half_x_;
                        const Fixed64 mark = tackler.team == 0 ? gx + Fixed64::fromInt(11) : gx - Fixed64::fromInt(11);
                        awardRestart(MatchEventType::Penalty, fouled, Vec3{mark, Fixed64::zero(), Fixed64::zero()}, events);
                    } else {
                        awardRestart(MatchEventType::FreeKick, fouled, Vec3{ball_.pos.x, ball_.pos.y, Fixed64::zero()}, events);
                    }
                    restart_ready_tick_ = clock_.tick() + deadRoll(fk_dead_lo_, fk_dead_hi_, i);
                    return;
                }
                continue;
            }
        }
        // Outcome by the tackler's level skill, deterministic noise.
        const PlayerSkill& lv = skillOf(i);
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
            touchedBy(tackler.team, true);
            box_clear_team_ = 0xFF;
            losing_team_ = cp.team;
            turnover_tick_ = clock_.tick();
            turnover_ball_x_ = ball_.pos.x;
            const Fixed64 r2 = detNoise(match_seed_, clock_.tick(), i, 14);
            if ((r2 + Fixed64::one()) < Fixed64::fromFraction(7, 5)) {
                ball_.owner = i;  // clean: 70% of won tackles
                owned_at_tick_ = clock_.tick();
                settleControl(i, Fixed64::zero());
                ball_.vel = Vec3{};
            } else {
                // Squirt across the carrier→ball line; side by noise sign.
                const Vec2 cb{ball_.pos.x - cp.pos.x, ball_.pos.y - cp.pos.y};
                const Fixed64 cl = math::length(cb);
                Vec2 n = cl.raw == 0 ? Vec2{Fixed64::zero(), Fixed64::one()}
                                     : Vec2{-cb.y / cl, cb.x / cl};
                if (r2.raw & 1) n = Vec2{-n.x, -n.y};
                flight_tick_ = clock_.tick();
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
        // G4.92: controlled first — unless he hits it first time (G4.95).
        const bool first_time = first_time_[kicker] != 0 && clock_.tick() < control_until_tick_;
        // G5.4: a man with time keeps it for the hold he drew on receipt. A
        // shot, a first-time hit, a keeper or a presser nearby ends that.
        bool hold_it = hold_on_ && clock_.tick() < hold_until_tick_ && act != Action::Shot &&
                       (first_time_[kicker] == 0 || hold_strict_) && !isKeeper(kicker);
        // G5.18 (§8.115): strict, the draw already holds the first-time and
        // pressed releases (real time on the ball is every receipt) — ending
        // it again on a presser or a first-time wish halved it (0.95 s v 1.47).
        for (SlotIndex i = 0; i < players_.size() && hold_it && !hold_strict_; ++i) {
            if (players_[i].team == players_[kicker].team) continue;
            const Vec2 d{players_[i].pos.x - o.pos.x, players_[i].pos.y - o.pos.y};
            // Near his own goal any presser ends it: holding there just gets him robbed.
            const Fixed64 own_d = players_[kicker].team == 0 ? half_x_ + o.pos.x : half_x_ - o.pos.x;
            const Fixed64 r = own_d < Fixed64::fromInt(35) ? Fixed64::fromFraction(5, 2) : hold_press_m_;
            if (math::lengthSquared(d) < r * r) hold_it = false;
        }
        if (act != Action::None && players_[kicker].recovery_ticks == 0 && !hold_it &&
            (clock_.tick() >= control_until_tick_ || first_time_[kicker] != 0)) {
            actions_[kicker] = Action::None;
            // Direction: live desire when pushing a direction, else facing.
            Vec2 desire = intents_[*ball_.owner].move;
            Vec2 dir = (desire.x.raw != 0 || desire.y.raw != 0)
                           ? math::normalized(desire)
                           : o.face;
            if (has_aim_[kicker]) {   // G5.29: at the point he aimed, from where he is now
                const Vec2 to{aim_[kicker].x - o.pos.x, aim_[kicker].y - o.pos.y};
                if (to.x.raw != 0 || to.y.raw != 0) dir = math::normalized(to);
            }

            // Execution noise (G4.3): rotate the kick by a level-scaled
            // deterministic error and scale its power. A pro's error is a
            // couple of degrees; a U-10 sprays it. Zero params = exact,
            // which is the baseline every pre-G4.3 golden locks.
            const PlayerSkill& lv = skillOf(kicker);
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
                if (first_time) kind_scale = kind_scale * Fixed64::fromFraction(3, 2);   // G4.95 [FH]
                // Shooting is HARD at any level: a flat +5 degrees of
                // match-pressure error on shots, on top of level error.
                // (18 m/s strikes at 1-degree error converted like
                // penalties — nobody finishes like that from 20 m.)
                const bool shot = act == Action::Shot;
                // G5.37 (§8.135): the brain's shot goes where the real ones went —
                // its aim IS the drawn crossing point, misses included — so no
                // angle error on top. A human's shot keeps it.
                const std::int32_t deg = shot && has_aim_[kicker] ? 0 :
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
            // G5.8 (§8.106): a clearance (first time, lofted) is hurried and
            // hit for safety, not placed: physics.kick.clear_err_deg either
            // side of the aim, like a headed clearance. No row = off. [FH fit
            // to StatsBomb PL 2015/16 clearance outcomes]
            if (clear_err_.raw > 0 && act == Action::LoftedKick && first_time_[kicker] != 0 && !isKeeper(kicker)) {
                const Fixed64 n3 = detNoise(match_seed_, clock_.tick(), kicker, 24);
                const Fixed64 ang = n3 * clear_err_ * Fixed64::fromFraction(71, 4068);
                const Fixed64 c = math::fx_cos(ang), sn = math::fx_sin(ang);
                dir = Vec2{dir.x * c - dir.y * sn, dir.x * sn + dir.y * c};
            }
            // Law 15 (G5.2): whatever he pressed, it's a throw — from behind
            // and over his head, on the touchline, onto the pitch, at the
            // range of an arm.
            const bool held = heldRestart();
            const MatchEventType kind = restart_kind_;
            if (held && kind == MatchEventType::ThrowIn) {
                Fixed64 d = carry_m_[kicker] > 0 ? Fixed64::fromInt(carry_m_[kicker]) : Fixed64::fromInt(12);
                if (d > officials_.throwMaxM()) d = officials_.throwMaxM();
                const Fixed64 v = ball_flight_.launchSpeed(d) * power_scale;
                if (dir.y * restart_spot_.y > Fixed64::zero()) dir.y = -dir.y;
                ball_.pos = Vec3{restart_spot_.x, restart_spot_.y, kThrowHeight};
                ball_.vel = Vec3{dir.x * v, dir.y * v, v * kLoftLaunchRatio};
            } else if (act == Action::GroundKick) {
                const Fixed64 v = (carry_m_[kicker] > 0 ? (die_[kicker] ? dieAtSpeed(Fixed64::fromInt(carry_m_[kicker]))
                                                                        : weightedPassSpeed(Fixed64::fromInt(carry_m_[kicker])))
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
                // G5.37: an aimed height — the lift that crosses the aim point at
                // aim_z, solved on the free ball's own law (drag + gravity).
                if (has_aim_[kicker] && aim_z_[kicker].raw > 0)
                    ball_.vel.z = shotLift(v, math::length(Vec2{aim_[kicker].x - o.pos.x, aim_[kicker].y - o.pos.y}), aim_z_[kicker]);
            } else if (act == Action::ShortPass) {
                const Fixed64 v = (carry_m_[kicker] > 0 ? weightedPassSpeed(Fixed64::fromInt(carry_m_[kicker]))
                                                        : kShortPassSpeed) * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, Fixed64::zero()};
            } else if (carry_m_[kicker] > 0) {
                // Aimed loft (G4.48): the launch speed (rise = r · v) whose
                // first bounce lands carry_m away — solved WITH air drag
                // since G4.87 (core::BallFlight). The power error scales
                // both, so a 10% miss is ~20% of the carry.
                const std::int32_t cap = lv.kick_range_m;
                const Fixed64 d = Fixed64::fromInt(
                    cap > 0 && carry_m_[kicker] > cap ? cap : carry_m_[kicker]);
                const Fixed64 v = ball_flight_.launchSpeed(d) * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v, v * kLoftLaunchRatio};
            } else {
                const Fixed64 v = kLoftKickSpeed * power_scale;
                ball_.vel = Vec3{dir.x * v, dir.y * v,
                                 kLoftKickRise * power_scale};
            }
            ball_.owner.reset();
            box_clear_team_ = 0xFF;  // kicked: the goal kick is in play
            flight_tick_ = clock_.tick();
            ball_.kick_alive = kKickAliveTicks;
            ball_.last_kicker = kicker;
            ball_.kicker_lockout = kKickerLockoutTicks;
            ball_.pass_to = pass_to_[kicker];
            touchedBy(players_[kicker].team, false);
            if (held) {
                restart_team_ = 0xFF;   // played: the dead ball is live
                // Law 11.3: no offside offence from a throw-in, goal kick
                // or corner. Until G5.2 all three armed the flag.
                offside_mask_ = 0;
                called_mask_ = 0;
                offside_team_ = 0xFF;
                return;
            }

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
            (void)d1; (void)d2;
            // G4.88: the assistant judges it from where he stands; the truth
            // is kept beside his call (core::Officials).
            last_call_ = officials_.judgeOffsidePosition(*this, kicker);
            offside_team_ = kt;
            offside_mask_ = last_call_.truth;
            called_mask_ = last_call_.called;
            return;  // free-ball physics integrates it this same tick
        }

        // G5.2: a held restart isn't carried. A corner or goal kick sits on
        // its spot; a throw is in his hands over his head, on the line.
        if (heldRestart()) {
            ball_.pos = restart_spot_;
            if (restart_kind_ == MatchEventType::ThrowIn) ball_.pos.z = kThrowHeight;
            ball_.vel = Vec3{};
            return;
        }

        // Glue [v1]: ball rides at the owner's feet, ahead of facing.
        ball_.pos = Vec3{o.pos.x + o.face.x * kBallCarryLead,
                         o.pos.y + o.face.y * kBallCarryLead, Fixed64::zero()};
        ball_.vel = o.vel;

        // Law 9 (G5.2): carried over a line it's out like any other ball —
        // a dribbler used to stay in play 2 m off the grass, on the apron.
        if (math::fx_abs(ball_.pos.x) > half_x_ + kBallRadius ||
            math::fx_abs(ball_.pos.y) > half_y_ + kBallRadius) {
            last_touch_team_ = o.team;
            ball_.owner.reset();
            ball_.contest_ticks = 0;
            return;   // tickFreeBall sees it over the line this same tick
        }

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
                settleControl(thief, Fixed64::zero());
                box_clear_team_ = 0xFF;
                ball_.contest_ticks = 0;
            }
        } else {
            ball_.contest_ticks = 0;
        }
        return;
    }

    // G5.2: nobody touches a ball that's out (bodies on the apron included),
    // or a dead ball before the referee has it ready.
    if (out_stage_ != 0 || (restart_team_ != 0xFF && clock_.tick() < restart_ready_tick_)) return;

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
            // G5.9 (§8.107): off a body the ball goes every way — real
            // blocked passes turned under 45° 26%, back over 135° 31%
            // (StatsBomb PL 2015/16) — so turn_deg either side of straight
            // back; the 60 / 0.3 defaults are G4.25's.
            const Fixed64 ang = n * Fixed64::fromFraction(71, 4068) * block_turn_;
            const Fixed64 c = math::fx_cos(ang);
            const Fixed64 sn = math::fx_sin(ang);
            const Vec2 v{-ball_.vel.x, -ball_.vel.y};
            const Fixed64 keep = block_keep_;
            ++body_blocks_[players_[blocker].team];
            ball_.vel = Vec3{(v.x * c - v.y * sn) * keep,
                             (v.x * sn + v.y * c) * keep, Fixed64::zero()};
            ball_.last_kicker = blocker;
            ball_.pass_to = 0xFF;
            flight_tick_ = clock_.tick();
            ball_.kicker_lockout = kBobbleLockoutTicks;
            ball_.kick_alive = kKickAliveTicks;
            touchedBy(players_[blocker].team, true);
            if (offside_team_ != 0xFF &&
                players_[blocker].team != offside_team_) {
                offside_mask_ = 0;
                called_mask_ = 0;
                offside_team_ = 0xFF;
            }
            return;
        }
    }

    bool found = false;
    Fixed64 best_sq{};
    SlotIndex best = 0;
    // G5.3: a ball at head height goes to whoever wins it in the air.
    bool duel = false;
    const int header = aerialWinner(duel);
    if (header >= 0) { found = true; best = static_cast<SlotIndex>(header); }
    for (SlotIndex i = 0; header < 0 && i < players_.size(); ++i) {
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
        // G5.5 (§8.103): the man a pass is for, set for it, reaches out a leg.
        // G5.11 (§8.108): their ball in our box, a defender sticks a leg out.
        const bool box_def = box_reach_m_.raw > 0 && !gk && ball_.last_kicker < players_.size() &&
                             players_[ball_.last_kicker].team != players_[i].team &&
                             (players_[i].team == 0 ? ball_.pos.x <= -half_x_ + kPenaltyDepth : ball_.pos.x >= half_x_ - kPenaltyDepth) &&
                             math::fx_abs(ball_.pos.y) <= kPenaltyHalfWidth;
        // G5.37: against their ball at shot speed a keeper takes it only this
        // close (his body behind it) — the fit to the real save share; any
        // other ball (a back pass, a loose one, a cross) at his full reach.
        const bool their_shot = gk && planar_speed_sq > Fixed64::fromInt(144) && ball_.last_kicker < players_.size() &&
                                players_[ball_.last_kicker].team != players_[i].team;
        const Fixed64 reach = gk ? (their_shot && keeper_shot_reach_.raw > 0 ? keeper_shot_reach_ : keeper_reach_)
                              : box_def ? box_reach_m_
                              : (i == ball_.pass_to && stretch_m_.raw > 0 && players_[i].team == last_touch_team_ ? stretch_m_ : kBallControlRadius);
        const Fixed64 reach_z = gk ? kKeeperReachZ : kOutfieldReachZ;   // G4.94: to the chest
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
        // G5.4 experiment (§8.102): the share of their moving passes an
        // outfielder in reach actually takes. Off without physics.tempo.cut_share.
        // G5.11 (§8.108): inside his own penalty area a defender plays every
        // ball he can reach — real low crosses are cut out ~70% (StatsBomb PL
        // 2015/16), where cut_share's midfield rate let the box's men stand
        // 0.5 m off a slow ball and watch it go by. cut_share_box (no row =
        // cut_share) is the share there; team 0 defends -x.
        Fixed64 share = cut_share_;
        if (cut_share_box_.raw > 0 &&
            (players_[i].team == 0 ? ball_.pos.x <= -half_x_ + kPenaltyDepth : ball_.pos.x >= half_x_ - kPenaltyDepth) &&
            math::fx_abs(ball_.pos.y) <= kPenaltyHalfWidth)
            share = cut_share_box_;
        if (share.raw > 0 && share < Fixed64::one() && !gk && ball_.last_kicker != 0xFF && ball_.last_kicker < players_.size() &&
            players_[ball_.last_kicker].team != players_[i].team &&
            planar_speed_sq > Fixed64::fromInt(9) &&
            (detNoise(match_seed_, clock_.tick() / 15, i, 24) + Fixed64::one()) * Fixed64::fromFraction(1, 2) >= share)
            continue;
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
        const bool in_position = offside_mask_ & (1u << (best & 31));
        if (players_[best].team != offside_team_) {
            offside_mask_ = 0;
            called_mask_ = 0;
            offside_team_ = 0xFF;
        } else if (called_mask_ & (1u << (best & 31))) {
            // The assistant's flag stands (G4.88), right or wrong.
            if (!in_position) ++wrong_whistles_;
            const std::uint8_t awarded = offside_team_ == 0 ? 1 : 0;
            offside_mask_ = 0;
            called_mask_ = 0;
            offside_team_ = 0xFF;
            awardRestart(MatchEventType::Offside, awarded,
                         Vec3{ball_.pos.x, ball_.pos.y, Fixed64::zero()},
                         *pending_events_);
            return;
        } else if (in_position) {
            ++missed_offsides_;   // he played on: nobody flagged him
            offside_mask_ = 0;
            called_mask_ = 0;
            offside_team_ = 0xFF;
        }
    }

    if (header >= 0) { headIt(best, duel); return; }

    // Touch quality: a ball faster than the toucher's control level
    // bobbles — deflects onward at reduced speed in a noise-rotated
    // direction — instead of sticking. Keepers add their hands bonus.
    const PlayerSkill& lv = skillOf(best);
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
    // Reaction touch (G4.82): an outfielder stepping across THEIR kick while
    // it still travels (3 m/s+) keeps it intercept_control_pct of the time;
    // otherwise it comes off him loose — it was 100% clean, and passes were
    // cut out 124-132 times a team a match against a pro 11.7 (of which
    // 62% kept).
    bool reaction = false;
    if (!keeper_[best] && lv.intercept_control_pct > 0 && lv.intercept_control_pct < 100 &&
        last_touch_team_ != players_[best].team && planar_speed_sq >= Fixed64::fromInt(9)) {
        const Fixed64 r = detNoise(match_seed_, clock_.tick(), best, 16);
        reaction = (r + Fixed64::one()) >= Fixed64::fromFraction(lv.intercept_control_pct, 50);
    }
    if (lv.control_speed_mps > 0 || fumbled || reaction) {
        Fixed64 ctrl = Fixed64::fromInt(lv.control_speed_mps);
        if (keeper_[best]) ctrl += kKeeperHandsBonus;
        else ctrl = controlSpeedAt(ctrl, ball_.pos.z);   // G4.94: a thigh / chest cushion
        if (fumbled || reaction || planar_speed_sq > ctrl * ctrl) {
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
            flight_tick_ = clock_.tick();
            touchedBy(players_[best].team, true);
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
    settleControl(best, math::fx_sqrt(planar_speed_sq));
    ball_.vel = Vec3{};
    ball_.pos.z = Fixed64::zero();  // keepers bring a high ball down
    ball_.kick_alive = 0;
    ball_.kicker_lockout = 0;
    ball_.contest_ticks = 0;
    touchedBy(players_[best].team, false);
    // A kick-off or free kick is live at the first touch; a throw, goal kick
    // or corner when he plays it (G5.2).
    if (!heldRestart()) restart_team_ = 0xFF;
}

void World::tickFreeBall(std::vector<MatchEvent>& events) {
    if (ball_.owner) return;
    if (ball_.kicker_lockout > 0) --ball_.kicker_lockout;

    // Vertical: drag (G4.87, core::BallFlight) and gravity while airborne,
    // bounce on impact.
    const bool airborne = ball_.pos.z.raw > 0 || ball_.vel.z.raw != 0;
    if (airborne) {
        ball_flight_.step(ball_.vel);
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

    // G5.2: over a line, play has stopped: the ball runs on, the call comes.
    if (out_stage_ != 0) {
        tickBallOut(events);
        return;
    }
    crossedLine(events);
}

// Law 9 + Law 10 (G3.2, the whole ball since G5.2): a goal now; anything else
// stops play and waits for the official.
bool World::crossedLine(std::vector<MatchEvent>& events) {
    const Fixed64 gx = half_x_ + kBallRadius, gy = half_y_ + kBallRadius;
    if (math::fx_abs(ball_.pos.x) > gx) {
        const std::uint8_t scorer = ball_.pos.x.raw > 0 ? 0 : 1;
        if (math::fx_abs(ball_.pos.y) <= kGoalHalfWidth && ball_.pos.z <= kGoalHeight) {
            ++score_[scorer];
            events.push_back({MatchEventType::Goal, scorer});
            awardKickoff(scorer ^ 1, events);  // conceders restart
            // G5.28: the celebration and the walk back — a real roll (DFL).
            if (ko_dead_hi_.raw > 0) restart_ready_tick_ = clock_.tick() + deadRoll(ko_dead_lo_, ko_dead_hi_, scorer);
            return true;
        }
        ballOut(true);
        return true;
    }
    if (math::fx_abs(ball_.pos.y) > gy) {
        ballOut(false);
        return true;
    }
    return false;
}

void World::ballOut(bool end_line) {
    out_stage_ = 1;
    out_end_line_ = end_line;
    out_crossed_ = Vec2{ball_.pos.x, ball_.pos.y};
    out_tick_ = clock_.tick();
    out_due_tick_ = out_tick_ + officials_.callTicks();
    ball_.pass_to = 0xFF;
    offside_mask_ = 0;
    called_mask_ = 0;
    offside_team_ = 0xFF;
}

// The official's call, then the ball back to its spot (G5.2).
void World::tickBallOut(std::vector<MatchEvent>& events) {
    if (clock_.tick() < out_due_tick_) return;
    if (out_stage_ == 2) {
        ball_ = BallState{};
        ball_.pos = restart_spot_;
        out_stage_ = 0;
        return;
    }
    const bool deflected = deflected_from_ != 0xFF &&
                           clock_.tick() - deflected_tick_ <= officials_.deflectionTicks();
    last_out_ = officials_.judgeOutOfPlay(*this, out_crossed_, out_end_line_, deflected, deflected_at_,
                                          last_touch_team_, deflected_from_);
    if (last_out_.called != last_out_.truth) ++wrong_out_;
    const std::uint8_t last = last_out_.called;
    const std::uint8_t other = last ^ 1;
    Vec3 spot{};
    MatchEventType type = MatchEventType::ThrowIn;
    std::uint8_t award = other;
    std::uint32_t ready = officials_.readyTicksThrow();
    if (out_end_line_) {
        const Fixed64 end = out_crossed_.x.raw > 0 ? Fixed64::one() : -Fixed64::one();
        const Fixed64 ys = out_crossed_.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
        const std::uint8_t defenders = out_crossed_.x.raw > 0 ? 1 : 0;   // team 1 defends +x
        if (last == defenders) {
            // Law 17: in the corner arc nearest where it went out.
            type = MatchEventType::Corner;
            award = defenders ^ 1;
            ready = officials_.readyTicksCorner();
            const Fixed64 in = Fixed64::fromFraction(1, 2);
            spot = Vec3{end * (half_x_ - in), ys * (half_y_ - in), Fixed64::zero()};
        } else {
            // Law 16: anywhere in the goal area; keepers set it on the side
            // it went out.
            type = MatchEventType::GoalKick;
            award = defenders;
            ready = officials_.readyTicksGoalKick();
            spot = Vec3{end * (half_x_ - Fixed64::fromInt(5)), ys * Fixed64::fromInt(6), Fixed64::zero()};
        }
    } else {
        // Law 15: where it crossed the touchline.
        const Fixed64 ys = out_crossed_.y.raw >= 0 ? Fixed64::one() : -Fixed64::one();
        spot = Vec3{out_crossed_.x, ys * half_y_, Fixed64::zero()};
    }
    setRestart(type, award, spot, events);
    restart_ready_tick_ = out_tick_ + ready;
    out_stage_ = 2;
    out_due_tick_ = clock_.tick() + officials_.retrieveTicks();
}

void World::configureAerial(const ModelParams& p) {
    aerial_radius_ = p.fixed("physics.aerial.radius_m", 0);
    aerial_min_z_ = p.fixed("physics.aerial.min_z_m", 1000);
    aerial_duel_slope_ = p.fixed("physics.aerial.duel_slope", 600);
    aerial_goal_range_ = p.fixed("physics.aerial.goal_range_m", 14000);
    aerial_own_range_ = p.fixed("physics.aerial.own_range_m", 35000);
    aerial_goal_speed_ = p.fixed("physics.aerial.goal_speed_mps", 14000);
    aerial_clear_speed_ = p.fixed("physics.aerial.clear_speed_mps", 16000);
    aerial_nod_keep_ = p.fixed("physics.aerial.nod_keep", 500);
    aerial_goal_err_ = p.fixed("physics.aerial.goal_err_deg", 45000);
    aerial_goal_err_duel_ = p.fixed("physics.aerial.goal_err_duel_deg", 80000);
    aerial_clear_err_ = p.fixed("physics.aerial.clear_err_deg", 40000);
    clear_err_ = p.fixed("physics.kick.clear_err_deg", 0);
    block_turn_ = p.fixed("physics.block.turn_deg", 60000);
    block_keep_ = p.fixed("physics.block.keep", 300);
}

void World::configureTempo(const ModelParams& p) {
    // G5.37 (§8.135): how far from his body a keeper takes the ball (m), fitted
    // to the real save curve (StatsBomb PL 2015/16 freeze frames); 1.2 = the old constant.
    keeper_reach_ = p.fixed("physics.keeper.reach_m", 1200);
    keeper_shot_reach_ = p.fixed("physics.keeper.shot_reach_m", 0);   // 0 = his full reach
    hold_under1_ = p.fixed("physics.tempo.hold_under1", 0);
    hold_under2_ = p.fixed("physics.tempo.hold_under2", 0);
    hold_under4_ = p.fixed("physics.tempo.hold_under4", 0);
    hold_press_m_ = p.fixed("physics.tempo.press_m", 2500);
    cut_share_ = p.fixed("physics.tempo.cut_share", 0);
    cut_share_box_ = p.fixed("physics.tempo.cut_share_box", 0);   // G5.11
    box_reach_m_ = p.fixed("physics.tempo.box_reach_m", 0);       // G5.11
    stretch_m_ = p.fixed("physics.tempo.stretch_m", 0);
    carry_share_ = p.fixed("physics.tempo.carry_share", 0);
    hold_on_ = hold_under1_.raw > 0 && hold_under2_ > hold_under1_ && hold_under4_ > hold_under2_;
    hold_one_ = p.fixed("physics.tempo.hold_one_touch", 0);        // G5.18 (§8.115)
    hold_p_one_ = p.fixed("physics.tempo.hold_pressed_one_touch", 0);
    hold_p_under1_ = p.fixed("physics.tempo.hold_pressed_under1", 0);
    hold_p_under2_ = p.fixed("physics.tempo.hold_pressed_under2", 0);
    hold_p_under4_ = p.fixed("physics.tempo.hold_pressed_under4", 0);
    hold_pressed_m_ = p.fixed("physics.tempo.hold_pressed_m", 0);
    hold_strict_ = p.integer("physics.tempo.hold_strict", 0);
}

void World::configureFouls(const ModelParams& p) {
    // StatsBomb PL 2015/16 (sb_fouls, §8.126): of a team's challenges on the man on
    // the ball in its own third / the middle / their third, the share that are fouls.
    foul_p_[0] = p.fixed("physics.foul.p_own_third", 213);
    foul_p_[1] = p.fixed("physics.foul.p_middle_third", 462);
    foul_p_[2] = p.fixed("physics.foul.p_their_third", 579);
    foul_adv_ = p.fixed("physics.foul.advantage", 138);    // 1.73 of 12.52 fouls played on
    // G5.40 (Law 14): in his own penalty area 7.6% of his challenges are fouls —
    // 0.13 a team-match of 1.61 tackle duels + fouls (benchmarks_statsbomb_penalties.py).
    foul_p_area_ = p.fixed("physics.foul.p_own_area", 76);
    // DFL (benchmarks_tracking_dead.py): seconds dead, p25 - p75.
    fk_dead_lo_ = p.fixed("physics.restart.free_kick_dead_p25_s", 20500);
    fk_dead_hi_ = p.fixed("physics.restart.free_kick_dead_p75_s", 43000);
    ko_dead_lo_ = p.fixed("physics.restart.goal_kickoff_dead_p25_s", 35700);
    ko_dead_hi_ = p.fixed("physics.restart.goal_kickoff_dead_p75_s", 76100);
}

std::uint32_t World::deadRoll(Fixed64 lo, Fixed64 hi, std::uint8_t salt) const {
    const Fixed64 u = (detNoise(match_seed_, clock_.tick(), salt, 61) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
    const Fixed64 s = lo + (hi - lo) * u;
    return static_cast<std::uint32_t>((s * Fixed64::fromInt(kTickRate)).raw >> Fixed64::FRAC_BITS);
}

// G5.3: the nearest man of each team under a ball at head height. Both there:
// a duel. One alone heads it only above his chest and only where a header is
// a decision: at their goal, or away from his own.
int World::aerialWinner(bool& duel) const {
    if (aerial_radius_.raw == 0 || ball_.owner || restart_team_ != 0xFF) return -1;
    if (ball_.pos.z < aerial_min_z_ || ball_.vel.z.raw >= 0) return -1;   // it's coming down
    int who[2] = {-1, -1};
    Fixed64 bd[2] = {};
    const Fixed64 rr = aerial_radius_ * aerial_radius_;
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        if (keeper_[i] || (ball_.kicker_lockout > 0 && i == ball_.last_kicker)) continue;
        if (ball_.pos.z > bodies_[i].headReach()) continue;   // over his head
        const Vec2 d{players_[i].pos.x - ball_.pos.x, players_[i].pos.y - ball_.pos.y};
        const Fixed64 q = math::lengthSquared(d);
        if (q > rr) continue;
        const int t = players_[i].team;
        if (who[t] < 0 || q < bd[t]) { who[t] = i; bd[t] = q; }
    }
    if (who[0] >= 0 && who[1] >= 0) {
        duel = true;
        const Fixed64 r = detNoise(match_seed_, clock_.tick(), static_cast<SlotIndex>(who[0]), 21);
        // 50-50 between equals; each point of his aerial share over the
        // other man's is duel_slope points of chance, capped short of sure.
        Fixed64 pct = Fixed64::fromInt(50) +
                      (bodies_[who[0]].aerial() - bodies_[who[1]].aerial()) * aerial_duel_slope_;
        if (pct < Fixed64::fromInt(5)) pct = Fixed64::fromInt(5);
        if (pct > Fixed64::fromInt(95)) pct = Fixed64::fromInt(95);
        return (r + Fixed64::one()) * Fixed64::fromInt(50) < pct ? who[0] : who[1];
    }
    const int lone = who[0] >= 0 ? who[0] : who[1];
    if (lone < 0 || ball_.pos.z <= kOutfieldReachZ) return -1;
    return (headRangeOfGoal(players_[lone].team) || headRangeOfOwn(players_[lone].team)) ? lone : -1;
}

// G5.3: straight-line distance to the goal he attacks; depth alone had a man
// on the touchline heading "at goal".
bool World::headRangeOfGoal(std::uint8_t team) const {
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    const Vec2 d{sg * half_x_ - ball_.pos.x, ball_.pos.y};
    return math::lengthSquared(d) <= aerial_goal_range_ * aerial_goal_range_;
}
bool World::headRangeOfOwn(std::uint8_t team) const {
    const Fixed64 sg = team == 0 ? Fixed64::one() : -Fixed64::one();
    return half_x_ + ball_.pos.x * sg <= aerial_own_range_;
}

// techniques 202 header-attacking, 240 def-header-clear (G5.3).
void World::headIt(SlotIndex slot, bool duel) {
    if (duel) ++aerial_duels_; else ++aerial_lone_;
    const auto& p = players_[slot];
    const Fixed64 sg = p.team == 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 n = detNoise(match_seed_, clock_.tick(), slot, 22);
    const Fixed64 rad = Fixed64::fromFraction(71, 4068);
    Vec2 dir{};
    Fixed64 speed{}, err{}, up{};
    if (headRangeOfGoal(p.team)) {
        dir = math::normalized(Vec2{sg * half_x_ - ball_.pos.x, -ball_.pos.y});
        speed = aerial_goal_speed_;
        err = duel ? aerial_goal_err_duel_ : aerial_goal_err_;
        up = Fixed64::zero();
        ++headers_at_goal_[p.team];
    } else if (headRangeOfOwn(p.team)) {
        dir = math::normalized(Vec2{ball_.pos.x + sg * half_x_, ball_.pos.y});
        speed = aerial_clear_speed_;
        err = aerial_clear_err_;
        up = speed * kLoftLaunchRatio;
        ++headers_clear_[p.team];
    } else {
        dir = math::normalized(Vec2{ball_.vel.x, ball_.vel.y});
        speed = math::length(Vec2{ball_.vel.x, ball_.vel.y}) * aerial_nod_keep_;
        err = aerial_clear_err_;
    }
    const Fixed64 ang = n * rad * err;
    const Fixed64 c = math::fx_cos(ang), sn = math::fx_sin(ang);
    ball_.vel = Vec3{(dir.x * c - dir.y * sn) * speed, (dir.x * sn + dir.y * c) * speed, up};
    ball_.last_kicker = slot;
    ball_.pass_to = 0xFF;
    ball_.kicker_lockout = kBobbleLockoutTicks;
    ball_.kick_alive = kKickAliveTicks;
    flight_tick_ = clock_.tick();
    touchedBy(p.team, duel);
}

void World::touchedBy(std::uint8_t team, bool deflection) {
    if (deflection && team != last_touch_team_) {
        deflected_from_ = last_touch_team_;
        deflected_at_ = Vec2{ball_.pos.x, ball_.pos.y};
        deflected_tick_ = clock_.tick();
    } else if (!deflection) {
        deflected_from_ = 0xFF;   // a clean touch: nothing to misread
    }
    last_touch_team_ = team;
}

// G4.92: his control touch — control_settle_ms + per m/s the ball came in
// at, his first_touch already in his level; 0 at the perfect level.
void World::settleControl(SlotIndex slot, Fixed64 speed) {
    if (hold_on_) {
        // G5.4: draw his time on the ball from the real spread: under 1 s,
        // 1-2, 2-4, then 4-8 s, flat inside each (StatsBomb PL 2015/16,
        // Ball Receipt to Pass; the flat slices are [FH]).
        const Fixed64 u = (detNoise(match_seed_, clock_.tick(), slot, 23) + Fixed64::one()) * Fixed64::fromFraction(1, 2);
        // G5.18 (§8.115): pressed at the receipt (a man within hold_pressed_m),
        // the pressed curve (StatsBomb PL 15/16 under_pressure receipts: 43.6%
        // one-touch, mean 1.11 s v 1.53 free); a one-touch slice is no hold.
        Fixed64 one = hold_one_, u1 = hold_under1_, u2 = hold_under2_, u4 = hold_under4_;
        if (hold_pressed_m_.raw > 0 && hold_p_under1_.raw > 0) {
            bool pressed = false;
            const auto& me = players_[slot];
            for (SlotIndex i = 0; i < players_.size() && !pressed; ++i)
                if (players_[i].team != me.team &&
                    math::lengthSquared(Vec2{players_[i].pos.x - me.pos.x, players_[i].pos.y - me.pos.y}) < hold_pressed_m_ * hold_pressed_m_)
                    pressed = true;
            if (pressed) { one = hold_p_one_; u1 = hold_p_under1_; u2 = hold_p_under2_; u4 = hold_p_under4_; }
        }
        Fixed64 s;
        if (one.raw > 0 && u < one) s = Fixed64::zero();
        else if (u < u1) s = one.raw > 0 ? Fixed64::fromFraction(3, 10) + Fixed64::fromFraction(7, 10) * (u - one) / (u1 - one) : u / u1;
        else if (u < u2) s = Fixed64::one() + (u - u1) / (u2 - u1);
        else if (u < u4) s = Fixed64::fromInt(2) + Fixed64::fromInt(2) * (u - u2) / (u4 - u2);
        else s = Fixed64::fromInt(4) + Fixed64::fromInt(4) * (u - u4) / (Fixed64::one() - u4);
        hold_until_tick_ = clock_.tick() + static_cast<std::uint64_t>((s * Fixed64::fromInt(kTickRate)).raw >> Fixed64::FRAC_BITS);
    }
    const PlayerSkill& cl = skillOf(slot);
    if (cl.control_settle_ms <= 0) { control_until_tick_ = 0; return; }
    const std::int64_t sp_mps = speed.raw >> Fixed64::FRAC_BITS;
    const std::int64_t ms = cl.control_settle_ms + cl.control_per_mps_ms * sp_mps;
    control_until_tick_ = clock_.tick() + static_cast<std::uint64_t>((ms * kTickRate + 999) / 1000);
}

void World::giveBall(SlotIndex slot) {
    if (slot >= players_.size()) return;
    const PlayerState& p = players_[slot];
    ball_ = BallState{};
    ball_.owner = slot;
    owned_at_tick_ = clock_.tick();
    control_until_tick_ = 0;   // a placed ball: nothing to control
    hold_until_tick_ = 0;
    ball_.pos = Vec3{p.pos.x + p.face.x * kBallCarryLead, p.pos.y + p.face.y * kBallCarryLead, Fixed64::zero()};
    last_touch_team_ = p.team;
    restart_team_ = 0xFF;
    out_stage_ = 0;
    box_clear_team_ = 0xFF;
    offside_mask_ = 0;
    called_mask_ = 0;
    offside_team_ = 0xFF;
}

void World::awardKickoff(std::uint8_t team, std::vector<MatchEvent>& events) {
    ball_ = BallState{};  // centre spot, at rest, free of carriers
    restart_team_ = team;
    restart_kind_ = MatchEventType::Kickoff;
    restart_ready_tick_ = 0;
    out_stage_ = 0;
    deflected_from_ = 0xFF;
    last_touch_team_ = team;   // kicking off isn't winning the ball
    box_clear_team_ = 0xFF;
    offside_mask_ = 0;
    called_mask_ = 0;
    offside_team_ = 0xFF;
    events.push_back({MatchEventType::Kickoff, team});
}

void World::awardRestart(MatchEventType type, std::uint8_t team,
                         const Vec3& spot, std::vector<MatchEvent>& events) {
    ball_ = BallState{};
    ball_.pos = spot;
    out_stage_ = 0;
    setRestart(type, team, spot, events);
    restart_ready_tick_ = 0;
}

void World::setRestart(MatchEventType type, std::uint8_t team, const Vec3& spot,
                       std::vector<MatchEvent>& events) {
    restart_team_ = team;
    restart_kind_ = type;
    restart_spot_ = spot;
    deflected_from_ = 0xFF;
    // The dead ball is theirs: taking it isn't a turnover (no counter-press
    // on a goal kick — the old last toucher made it look like a lost ball).
    last_touch_team_ = team;
    box_clear_team_ = type == MatchEventType::GoalKick ? static_cast<std::uint8_t>(team ^ 1) : 0xFF;
    offside_mask_ = 0;
    called_mask_ = 0;
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
    officials_.tick(*this);   // G4.88: the crew moves after the players
    tickTackles(events);
    tickPossessionAndKicks(events);
    tickFreeBall(events);
    tickClock(events);
    // Actions are per-tick: consumed by the owner's kick above, discarded
    // for everyone else, so a stale tap can't fire ticks later.
    for (auto& a : actions_) a = Action::None;
    for (auto& c : carry_m_) c = 0;
    for (auto& a : has_aim_) a = 0;
    for (auto& p : pass_to_) p = 0xFF;
    clock_.advance();
    return events;
}

// G5.37 (§8.135): the vertical launch speed for a strike of horizontal speed v
// to pass height h at d metres along the ground, on the airborne law
// (BallFlight::step + gravity), by bisection — the lowest lift that gets there.
Fixed64 World::shotLift(Fixed64 v, Fixed64 d, Fixed64 h) const {
    auto heightAt = [&](Fixed64 vz) {
        Vec3 vel{v, Fixed64::zero(), vz};
        Vec3 pos{Fixed64::zero(), Fixed64::zero(), kBallRadius};
        for (int t = 0; t < 300 && pos.x < d; ++t) {
            ball_flight_.step(vel);
            vel.z -= kGravity * kTickDt;
            pos += vel * kTickDt;
            if (pos.z.raw < 0) return pos.z;
        }
        return pos.z;
    };
    Fixed64 lo = Fixed64::zero(), hi = Fixed64::fromInt(16);
    for (int i = 0; i < 18; ++i) {
        const Fixed64 mid = (lo + hi) * Fixed64::fromFraction(1, 2);
        if (heightAt(mid) < h) lo = mid; else hi = mid;
    }
    return hi;
}

}  // namespace fh::game::core
