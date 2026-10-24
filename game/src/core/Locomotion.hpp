// game/src/core/Locomotion.hpp — how a body gets up to speed (G4.51).
//
// Until G4.51 the World set vel = desire × max_speed: 0 → top speed in one
// tick and 180° turns for free, so a defender backpedalled at full pace and
// mirrored every cut (the ESCORT, §8.21/§8.46). Now a player's velocity
// relaxes toward the one he wants, the mono-exponential sprint law
// [Furusawa, Hill & Parkinson 1927; Samozino/Morin sprint profiling]:
//
//     dv/dt = (v_wanted − v) / τ        |dv/dt| ≤ max_accel
//
// From rest that is v(t) = top·(1 − e^(−t/τ)), first acceleration top/τ.
// The cap binds when he has to brake or turn hard: a reversal at speed
// spends ~1 s braking before he gets going the other way. With the ball at
// his feet his top speed is dribble_pct of his own.
//
// The Brain reads the same law in closed form (reach()), so a defender's
// "can I get there?" matches what his legs will do.
//
// Numbers: game_model_params owner 'physics', code 'locomotion' (mig 674);
// the defaults below are the same rows, for tests and DB-less boots.
#pragma once

#include "core/Clock.hpp"
#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"

namespace fh::game::core {

class Locomotion {
public:
    Locomotion() : Locomotion(ModelParams{}) {}
    explicit Locomotion(const ModelParams& p)
        : tau_(p.fixed("physics.locomotion.tau_s", 1200)),
          max_accel_(p.fixed("physics.locomotion.max_accel_mps2", 7000)),
          dribble_(p.fixed("physics.locomotion.dribble_pct", 88000) / math::Fixed64::fromInt(100)),
          dive_speed_(p.fixed("physics.keeper_dive.speed_mps", 4000)),
          dive_air_ticks_(p.integer("physics.keeper_dive.air_ms", 600) * kTickRate / 1000),
          dive_ground_ticks_(p.integer("physics.keeper_dive.ground_ms", 800) * kTickRate / 1000) {
        // lag() at every tick out to kLagTicks, once (fx_exp_neg per read
        // made the Brain's reach scans ~5x slower).
        for (int k = 0; k <= kLagTicks; ++k) {
            const math::Fixed64 t = math::Fixed64::fromFraction(k, kTickRate);
            lag_[k] = tau_ * (math::Fixed64::one() - math::fx_exp_neg(t / tau_));
        }
    }

    math::Fixed64 tau() const noexcept { return tau_; }
    math::Fixed64 maxAccel() const noexcept { return max_accel_; }
    // Share of his top speed a carrier can run at.
    math::Fixed64 dribble() const noexcept { return dribble_; }

    // Keeper dive (G4.51): a two-footed launch, not a run. He leaves the
    // ground at dive_speed along his line, is ballistic for air ticks
    // (no steering, no second thoughts), then is on the ground for
    // ground ticks before he can get up.
    math::Fixed64 diveSpeed() const noexcept { return dive_speed_; }
    std::int32_t diveAirTicks() const noexcept { return dive_air_ticks_; }
    std::int32_t diveGroundTicks() const noexcept { return dive_ground_ticks_; }

    // One tick of the law: the new planar velocity.
    math::Vec2 step(math::Vec2 v, math::Vec2 wanted, math::Fixed64 dt) const {
        math::Vec2 a{(wanted.x - v.x) / tau_, (wanted.y - v.y) / tau_};
        const math::Fixed64 a2 = math::lengthSquared(a);
        if (a2 > max_accel_ * max_accel_) {
            const math::Fixed64 k = max_accel_ / math::fx_sqrt(a2);
            a = math::Vec2{a.x * k, a.y * k};
        }
        return math::Vec2{v.x + a.x * dt, v.y + a.y * dt};
    }

    // How far he gets along a straight line in t seconds, starting at v0
    // (his speed along that line, may be negative) with top speed `top`:
    // top·t − (top − v0)·τ·(1 − e^(−t/τ)). Exact for the uncapped law; the
    // cap (hard reversals) is ignored — a slight optimism the Brain shares
    // with every real player.
    math::Fixed64 reach(math::Fixed64 v0, math::Fixed64 top, math::Fixed64 t) const {
        return reachLag(v0, top, t, lag(t));
    }
    // τ·(1 − e^(−t/τ)) — the distance lost getting up to speed; depends on
    // t only, so a scan over many players computes it once per step.
    // Table read, linear between ticks; past kLagTicks (10 s) it is τ to
    // within 0.03%.
    math::Fixed64 lag(math::Fixed64 t) const {
        if (t.raw <= 0) return math::Fixed64::zero();
        const math::Fixed64 ticks = t * math::Fixed64::fromInt(kTickRate);
        const std::int64_t k = ticks.raw >> math::Fixed64::FRAC_BITS;
        if (k >= kLagTicks) return lag_[kLagTicks];
        const math::Fixed64 f = math::Fixed64::fromRaw(ticks.raw - (k << math::Fixed64::FRAC_BITS));
        return lag_[k] + (lag_[k + 1] - lag_[k]) * f;
    }
    math::Fixed64 reachLag(math::Fixed64 v0, math::Fixed64 top, math::Fixed64 t,
                           math::Fixed64 lag_t) const {
        if (t.raw <= 0) return math::Fixed64::zero();
        if (v0 > top) v0 = top;
        const math::Fixed64 d = top * t - (top - v0) * lag_t;
        return d.raw > 0 ? d : math::Fixed64::zero();
    }

private:
    static constexpr int kLagTicks = 10 * kTickRate;
    math::Fixed64 tau_, max_accel_, dribble_, dive_speed_;
    std::int32_t dive_air_ticks_, dive_ground_ticks_;
    math::Fixed64 lag_[kLagTicks + 1];
};

}  // namespace fh::game::core
