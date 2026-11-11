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
//
// G5.84 (§8.185): the launch angle by carry. One 27° launch (kLoftLaunchRatio)
// flew a 30-40 m loft to the ground in 1.9 s; real ones take 2.5 (DFL,
// benchmarks_tracking_loft.py LOFT FLIGHT: lofts past 4 m, launch → back
// under 0.5 m, median by carry 10-20 / 20-30 / 30-40 / 40-50 / 50-70 m:
// 2.88 / 2.48 / 2.48 / 2.92 / 3.60 s). physics.ball.loft_time_<15|25|35|45|60>
// (s x1000, at each bin's middle, linear between, held past the ends) is that
// time; for each carry the ratio (rise / ground speed) is bisected so the ball
// is back down to 0.5 m then, the speed solved for the carry at each try.
// Under 15 m the 15 m angle holds (no hanging 5 m chips); past 70 m the 70 m
// one. physics.ball.loft_time_on 0 = the flat 27° law. Throw-ins keep the flat
// law (throwSpeed). [FH, fitted to DFL; the law is Goff & Carré's drag]
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
        static const int kAt[5] = {15, 25, 35, 45, 60};
        static const int kT[5] = {2880, 2480, 2480, 2920, 3600};
        static const char* const kName[5] = {"physics.ball.loft_time_15", "physics.ball.loft_time_25", "physics.ball.loft_time_35",
                                             "physics.ball.loft_time_45", "physics.ball.loft_time_60"};
        const bool on = p.integer("physics.ball.loft_time_on", 1) != 0;
        std::array<std::int64_t, 6> key{k_.raw, on ? 1 : 0, 0, 0, 0, 0};
        Fixed64 tt[5];
        for (int i = 0; i < 5; ++i) { tt[i] = p.fixed(kName[i], kT[i]); key[1] = key[1] * 1000003 + tt[i].raw; }
        // The tables depend only on these numbers: solved once per process for each set
        // (every World and test builds a BallFlight; the solve is ~2M flight ticks).
        static std::array<std::int64_t, 6> last_key{};
        static std::shared_ptr<const Tables> last;
        if (last && last_key == key) { tables_ = last; return; }
        auto t = std::make_shared<Tables>();
        solve(*t, on, kAt, tt);
        tables_ = std::move(t);
        last = tables_; last_key = key;
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
    // rises at ratio() of that) so the first bounce is carry_m away.
    math::Fixed64 launchSpeed(math::Fixed64 carry_m) const { return lookup(tables_->speed, carry_m); }
    // G5.84: its rise / ground speed for that carry (kLoftLaunchRatio when off)...
    math::Fixed64 ratio(math::Fixed64 carry_m) const { return lookup(tables_->ratio, carry_m); }
    // ...and the rise itself (m/s).
    math::Fixed64 launchRise(math::Fixed64 carry_m) const { return launchSpeed(carry_m) * ratio(carry_m); }
    // A throw-in: the flat kLoftLaunchRatio law (G5.84 left throws alone).
    math::Fixed64 throwSpeed(math::Fixed64 carry_m) const { return lookup(tables_->flat, carry_m); }
    // ...and how long it is in the air until that bounce (s).
    math::Fixed64 flightTime(math::Fixed64 carry_m) const { return lookup(tables_->time, carry_m); }

    // G5.11 (§8.108): a loft of carry_m, coming down, passes height h this far
    // along the ground (its bounce point if it never rises over h).
    math::Fixed64 descendDist(math::Fixed64 carry_m, math::Fixed64 h) const {
        math::Vec3 vel{launchSpeed(carry_m), math::Fixed64::zero(), launchRise(carry_m)};
        math::Vec3 pos{};
        for (int ticks = 0; ticks < 600; ++ticks) {
            step(vel);
            vel.z -= kGravity * kTickDt;
            pos += vel * kTickDt;
            if (pos.z.raw < 0 || (vel.z.raw < 0 && pos.z <= h)) break;
        }
        return pos.x;
    }
    // ...and the shortest whole carry (1-255) whose descent passes h at d or
    // beyond: the cross that meets a head there instead of bouncing at his feet.
    int carryToMeet(math::Fixed64 d, math::Fixed64 h) const {
        int lo = 1, hi = kMaxCarry;
        while (lo < hi) {
            const int mid = (lo + hi) / 2;
            if (descendDist(math::Fixed64::fromInt(mid), h) < d) lo = mid + 1; else hi = mid;
        }
        return lo;
    }

private:
    struct Tables {
        std::array<math::Fixed64, kMaxCarry + 1> speed{}, time{}, ratio{}, flat{};
    };

    // The free-ball law (World::tickFreeBall) for one launch, to the first
    // bounce: metres along the ground and ticks.
    // ...and the tick it came back down through 0.5 m (benchmarks_tracking_loft.py's landing).
    void fly(math::Fixed64 v, math::Fixed64 r, math::Fixed64& dist, int& ticks, int* down = nullptr) const {
        math::Vec3 vel{v, math::Fixed64::zero(), v * r};
        math::Vec3 pos{};
        const math::Fixed64 half = math::Fixed64::fromFraction(1, 2);
        ticks = 0;
        if (down) *down = -1;
        while (ticks < 600) {
            step(vel);
            vel.z -= kGravity * kTickDt;
            pos += vel * kTickDt;
            ++ticks;
            if (down && *down < 0 && vel.z.raw < 0 && pos.z < half) *down = ticks;
            if (pos.z.raw < 0) break;
        }
        dist = pos.x;
    }
    // The launch speed at ratio r whose first bounce is want away.
    math::Fixed64 speedFor(math::Fixed64 want, math::Fixed64 r, int iters) const {
        using math::Fixed64;
        Fixed64 lo = Fixed64::zero(), hi = Fixed64::fromInt(80);
        for (int it = 0; it < iters; ++it) {
            const Fixed64 mid = (lo + hi) / 2;
            Fixed64 dist{};
            int ticks = 0;
            fly(mid, r, dist, ticks);
            if (dist < want) lo = mid; else hi = mid;
        }
        return hi;
    }

    void solve(Tables& t, bool on, const int* at, const math::Fixed64* tt) const {
        using math::Fixed64;
        auto target = [&](int c) {   // the real landing time at carry c: linear between bin middles, held past the ends
            if (c <= at[0]) return tt[0];
            for (int i = 1; i < 5; ++i)
                if (c <= at[i]) return tt[i - 1] + (tt[i] - tt[i - 1]) * Fixed64::fromFraction(c - at[i - 1], at[i] - at[i - 1]);
            return tt[4];
        };
        Fixed64 r_lo_end{}, r_hi_end{};
        for (int c = 0; c <= kMaxCarry; ++c) {
            const Fixed64 want = Fixed64::fromInt(c < 1 ? 1 : c);
            t.flat[c] = speedFor(want, kLoftLaunchRatio, 28);
            Fixed64 r = kLoftLaunchRatio;
            if (on) {
                if (c < at[0] && c > 0 && r_lo_end.raw) r = r_lo_end;
                else if (c > 70 && r_hi_end.raw) r = r_hi_end;
                else {
                    const int cc = c < at[0] ? at[0] : c;   // c 0: the 15 m angle
                    const Fixed64 w = Fixed64::fromInt(cc);
                    const int goal = static_cast<int>((target(cc) / kTickDt).raw >> Fixed64::FRAC_BITS);
                    Fixed64 lo = Fixed64::fromFraction(1, 5), hi = Fixed64::fromFraction(3, 2);   // ~11° .. ~56°
                    for (int it = 0; it < 16; ++it) {
                        const Fixed64 mid = (lo + hi) / 2;
                        Fixed64 dist{};
                        int ticks = 0, down = 0;
                        fly(speedFor(w, mid, 22), mid, dist, ticks, &down);
                        if (down < goal) lo = mid; else hi = mid;
                    }
                    r = hi;
                    if (c == at[0] || c == 0) r_lo_end = r;
                    if (c == 70) r_hi_end = r;
                }
            }
            t.ratio[c] = r;
            t.speed[c] = r == kLoftLaunchRatio ? t.flat[c] : speedFor(want, r, 28);
            Fixed64 dist{};
            int ticks = 0;
            fly(t.speed[c], r, dist, ticks);
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
