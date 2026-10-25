// game/src/core/Locomotion.hpp — how a body moves (G4.51, per player G4.52).
//
// Until G4.51 the World set vel = desire × max_speed: 0 → top speed in one
// tick and 180° turns for free, so a defender backpedalled at full pace and
// mirrored every cut (the ESCORT, §8.21/§8.46). Now each player's velocity
// relaxes toward the one he wants, the mono-exponential sprint law
// [Furusawa, Hill & Parkinson 1927; Samozino/Morin sprint profiling]:
//
//     dv/dt = (v_wanted − v) / τ
//
// with the change split along his line of travel — braking limited by his
// DECELERATION, the sideways part (turning, cutting) by his AGILITY. From
// rest v(t) = top·(1 − e^(−t/τ)): first acceleration top/τ. With the ball
// his top speed is his DRIBBLING share of his own, so he also gets up to it
// that much more slowly.
//
// Every number is the player's own (core::Body, from his attributes via
// SkillSet::body — G4.52, James: "all players should have different rates
// of acceleration and speed … with or without ball"). A default Body is a
// 50-rated player. The Brain reads the same law in closed form (reach()).
// The dive's timings are the only shared numbers here (physics of a jump).
#pragma once

#include "core/Clock.hpp"
#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"

namespace fh::game::core {

class Body {
public:
    // A 50-rated body: the skill rows' at50 values (mig 679).
    Body()
        : Body(math::Fixed64::fromFraction(6, 5), math::Fixed64::fromInt(7),
               math::Fixed64::fromInt(6), math::Fixed64::fromFraction(88, 100),
               math::Fixed64::fromInt(4)) {}
    Body(math::Fixed64 tau, math::Fixed64 brake, math::Fixed64 turn,
         math::Fixed64 dribble, math::Fixed64 dive_speed)
        : Body(tau, brake, turn, dribble, dive_speed, math::Fixed64::fromFraction(8, 10),
               math::Fixed64::fromFraction(65, 100), math::Fixed64::fromInt(9)) {}
    // G4.53/G4.54: run = his top speed side-on (hips open, crossover run —
    // facing 90° off his travel), back = backpedalling, both as shares of
    // his forward top speed; yaw = how fast his body turns (rad/s);
    // head_cos = cos of how far he can look off his line at no cost (head
    // and eyes turn, hips stay on the run).
    Body(math::Fixed64 tau, math::Fixed64 brake, math::Fixed64 turn,
         math::Fixed64 dribble, math::Fixed64 dive_speed, math::Fixed64 run,
         math::Fixed64 back, math::Fixed64 yaw,
         math::Fixed64 head_cos = math::Fixed64::fromFraction(1, 2))
        : tau_(tau), brake_(brake), turn_(turn), dribble_(dribble), dive_speed_(dive_speed),
          side_(run), back_(back), yaw_(yaw), head_cos_(head_cos) {
        // lag() at every tick out to kLagTicks, once per body (fx_exp_neg
        // per read made the Brain's reach scans ~5x slower).
        for (int k = 0; k <= kLagTicks; ++k) {
            const math::Fixed64 t = math::Fixed64::fromFraction(k, kTickRate);
            lag_[k] = tau_ * (math::Fixed64::one() - math::fx_exp_neg(t / tau_));
        }
    }

    math::Fixed64 tau() const noexcept { return tau_; }
    math::Fixed64 brake() const noexcept { return brake_; }
    math::Fixed64 turn() const noexcept { return turn_; }
    math::Fixed64 dribble() const noexcept { return dribble_; }
    math::Fixed64 diveSpeed() const noexcept { return dive_speed_; }
    math::Fixed64 side() const noexcept { return side_; }
    math::Fixed64 back() const noexcept { return back_; }
    math::Fixed64 yaw() const noexcept { return yaw_; }

    // Gait (G4.54): his top-speed share for moving along `dir` while facing
    // `face` (both unit), by the cosine c between them: full speed while
    // he can just turn his head (c ≥ head_cos, ~60°); then his hips open —
    // side() running side-on at 90°; back() backpedalling at 180°. Linear
    // in c between those points. (G4.53 had 90° as the SLOWEST gait, a
    // square shuffle; a defender running side-on crosses over instead.)
    math::Fixed64 gait(math::Vec2 face, math::Vec2 dir) const {
        const math::Fixed64 c = face.x * dir.x + face.y * dir.y;
        if (c >= head_cos_) return math::Fixed64::one();
        if (c.raw >= 0) return side_ + (math::Fixed64::one() - side_) * (c / head_cos_);
        return side_ + (back_ - side_) * (-c);
    }

    // Body turn (G4.53): `face` rotated toward `want` by at most yaw()·dt.
    math::Vec2 turnToward(math::Vec2 face, math::Vec2 want, math::Fixed64 dt) const {
        const math::Fixed64 cross = face.x * want.y - face.y * want.x;
        const math::Fixed64 dot = face.x * want.x + face.y * want.y;
        const math::Fixed64 ang = math::fx_atan2(cross, dot);
        const math::Fixed64 step = yaw_ * dt;
        if (math::fx_abs(ang) <= step) return want;
        const math::Fixed64 a = ang.raw > 0 ? step : -step;
        const math::Fixed64 c = math::fx_cos(a), s = math::fx_sin(a);
        return math::Vec2{face.x * c - face.y * s, face.x * s + face.y * c};
    }

    // One tick of the law: the new planar velocity.
    math::Vec2 step(math::Vec2 v, math::Vec2 wanted, math::Fixed64 dt) const {
        math::Vec2 a{(wanted.x - v.x) / tau_, (wanted.y - v.y) / tau_};
        const math::Fixed64 speed2 = math::lengthSquared(v);
        if (speed2 < math::Fixed64::fromFraction(1, 4)) {
            // Nearly still: no line of travel to brake or turn against.
            a = capped(a, brake_);
        } else {
            const math::Fixed64 speed = math::fx_sqrt(speed2);
            const math::Vec2 u{v.x / speed, v.y / speed};
            math::Fixed64 along = a.x * u.x + a.y * u.y;
            math::Vec2 side{a.x - u.x * along, a.y - u.y * along};
            if (along < -brake_) along = -brake_;
            side = capped(side, turn_);
            a = math::Vec2{u.x * along + side.x, u.y * along + side.y};
        }
        return math::Vec2{v.x + a.x * dt, v.y + a.y * dt};
    }

    // How far he gets along a straight line in t seconds, starting at v0
    // (his speed along that line, may be negative) with top speed `top`:
    // top·t − (top − v0)·τ·(1 − e^(−t/τ)). Exact for the uncapped law; the
    // braking/turning caps are ignored — a slight optimism the Brain shares
    // with every real player.
    math::Fixed64 reach(math::Fixed64 v0, math::Fixed64 top, math::Fixed64 t) const {
        if (t.raw <= 0) return math::Fixed64::zero();
        if (v0 > top) v0 = top;
        const math::Fixed64 d = top * t - (top - v0) * lag(t);
        return d.raw > 0 ? d : math::Fixed64::zero();
    }
    // τ·(1 − e^(−t/τ)), the distance lost getting up to speed: table read,
    // linear between ticks; past 10 s it is τ to within 0.03%.
    math::Fixed64 lag(math::Fixed64 t) const {
        if (t.raw <= 0) return math::Fixed64::zero();
        const math::Fixed64 ticks = t * math::Fixed64::fromInt(kTickRate);
        const std::int64_t k = ticks.raw >> math::Fixed64::FRAC_BITS;
        if (k >= kLagTicks) return lag_[kLagTicks];
        const math::Fixed64 f = math::Fixed64::fromRaw(ticks.raw - (k << math::Fixed64::FRAC_BITS));
        return lag_[k] + (lag_[k + 1] - lag_[k]) * f;
    }

private:
    static math::Vec2 capped(math::Vec2 a, math::Fixed64 cap) {
        const math::Fixed64 a2 = math::lengthSquared(a);
        if (a2 <= cap * cap) return a;
        const math::Fixed64 k = cap / math::fx_sqrt(a2);
        return math::Vec2{a.x * k, a.y * k};
    }

    static constexpr int kLagTicks = 10 * kTickRate;
    math::Fixed64 tau_, brake_, turn_, dribble_, dive_speed_, side_, back_, yaw_, head_cos_;
    math::Fixed64 lag_[kLagTicks + 1];
};

// The shared part: a keeper's dive is a two-footed launch, not a run — he
// leaves the ground at his own dive speed (Body) along his line, is
// ballistic for air ticks (no steering, no second thoughts), then is on
// the ground for ground ticks before he can get up.
class Locomotion {
public:
    Locomotion() : Locomotion(ModelParams{}) {}
    explicit Locomotion(const ModelParams& p)
        : dive_air_ticks_(p.integer("physics.keeper_dive.air_ms", 600) * kTickRate / 1000),
          dive_ground_ticks_(p.integer("physics.keeper_dive.ground_ms", 800) * kTickRate / 1000) {}

    std::int32_t diveAirTicks() const noexcept { return dive_air_ticks_; }
    std::int32_t diveGroundTicks() const noexcept { return dive_ground_ticks_; }

private:
    std::int32_t dive_air_ticks_, dive_ground_ticks_;
};

}  // namespace fh::game::core
