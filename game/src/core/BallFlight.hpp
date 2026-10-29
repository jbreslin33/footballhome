// game/src/core/BallFlight.hpp — how a ball flies through the air (G4.87).
//
// Until G4.87 a ball in the air felt only gravity: a 30 m loft came down at
// the 17 m/s it was struck, over every player's control speed. Now it also
// feels aerodynamic drag [Goff & Carré 2009, "Trajectory analysis of a soccer
// ball", Am J Phys 77:1020 — F_D = ½ ρ A v² C_D, opposite the velocity; ρ 1.2
// kg/m³, A ≈ 0.0375 m² (diameter 0.218 m), m 0.424 kg, C_D 0.2 measured for
// no-spin launches at ~18 m/s, 0.17 at 19.4]. As an acceleration on the ball:
//
//     a = −k · |v| · v,   k = ρ · (π d² / 4) · C_D / (2 m)   (≈ 0.0105 / m)
//
// applied while the ball is AIRBORNE only — on the ground the roll decay
// [v1] already is the measured loss of a rolling ball. No spin, no Magnus,
// and one C_D: below the drag crisis (Re ≈ 2.2-3.0 × 10⁵, ~15-21 m/s — Asai
// et al.) the real C_D roughly doubles; not modelled yet.
//
// ONE object for the World that strikes and flies the ball and the Brain
// that reads it (Brain::race, loftTo, loftSafe): step() is the per-tick law,
// launchSpeed()/flightTime() the aimed loft solved WITH drag — for each carry
// 1-255 m, the launch speed (at kLoftLaunchRatio) whose first bounce lands
// there, found by bisection on the same tick law, once, at construction.
#pragma once

#include "core/Ball.hpp"
#include "core/Clock.hpp"
#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>
#include <memory>

namespace fh::game::core {

class BallFlight {
public:
    static constexpr int kMaxCarry = 255;

    BallFlight() : BallFlight(ModelParams{}) {}
    explicit BallFlight(const ModelParams& p) {
        using math::Fixed64;
        const Fixed64 rho = p.fixed("physics.ball.air_density_kgm3", 1200);
        const Fixed64 d = p.fixed("physics.ball.diameter_m", 218);
        const Fixed64 m = p.fixed("physics.ball.mass_kg", 424);
        const Fixed64 cd = p.fixed("physics.ball.drag_coeff", 200);
        const Fixed64 area = math::FX_PI * d * d / 4;
        k_ = m.raw > 0 ? rho * area * cd / (m * 2) : Fixed64::zero();
        auto t = std::make_shared<Tables>();
        solve(*t);
        tables_ = std::move(t);
    }

    // Drag coefficient per metre (k above).
    math::Fixed64 k() const noexcept { return k_; }

    // One tick of drag on an airborne ball's velocity: v −= k·|v|·v·dt.
    void step(math::Vec3& v) const {
        if (k_.raw == 0) return;
        const math::Fixed64 sp = math::fx_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
        const math::Fixed64 f = math::Fixed64::one() - k_ * sp * kTickDt;
        v = math::Vec3{v.x * f, v.y * f, v.z * f};
    }

    // Aimed loft: the speed to strike it (along the ground direction; it
    // rises at kLoftLaunchRatio of that) so the first bounce is carry_m away.
    math::Fixed64 launchSpeed(math::Fixed64 carry_m) const { return lookup(tables_->speed, carry_m); }
    // ...and how long it is in the air until that bounce (s).
    math::Fixed64 flightTime(math::Fixed64 carry_m) const { return lookup(tables_->time, carry_m); }

private:
    struct Tables {
        std::array<math::Fixed64, kMaxCarry + 1> speed{}, time{};
    };

    // The free-ball law (World::tickFreeBall) for one launch, to the first
    // bounce: metres along the ground and ticks.
    void fly(math::Fixed64 v, math::Fixed64& dist, int& ticks) const {
        math::Vec3 vel{v, math::Fixed64::zero(), v * kLoftLaunchRatio};
        math::Vec3 pos{};
        ticks = 0;
        while (ticks < 600) {
            step(vel);
            vel.z -= kGravity * kTickDt;
            pos += vel * kTickDt;
            ++ticks;
            if (pos.z.raw < 0) break;
        }
        dist = pos.x;
    }

    void solve(Tables& t) const {
        using math::Fixed64;
        for (int c = 0; c <= kMaxCarry; ++c) {
            const Fixed64 want = Fixed64::fromInt(c < 1 ? 1 : c);
            Fixed64 lo = Fixed64::zero(), hi = Fixed64::fromInt(80);
            for (int it = 0; it < 28; ++it) {
                const Fixed64 mid = (lo + hi) / 2;
                Fixed64 dist{};
                int ticks = 0;
                fly(mid, dist, ticks);
                if (dist < want) lo = mid; else hi = mid;
            }
            Fixed64 dist{};
            int ticks = 0;
            fly(hi, dist, ticks);
            t.speed[c] = hi;
            t.time[c] = Fixed64::fromInt(ticks) * kTickDt;
        }
    }

    math::Fixed64 lookup(const std::array<math::Fixed64, kMaxCarry + 1>& a, math::Fixed64 carry) const {
        if (carry.raw <= 0) return a[1];
        const std::int64_t i = carry.raw >> math::Fixed64::FRAC_BITS;
        if (i >= kMaxCarry) return a[kMaxCarry];
        const math::Fixed64 f = carry - math::Fixed64::fromInt(static_cast<std::int32_t>(i));
        return a[i] + (a[i + 1] - a[i]) * f;
    }

    math::Fixed64 k_{};
    std::shared_ptr<const Tables> tables_;   // shared: World is copied per brain per tick
};

}  // namespace fh::game::core
