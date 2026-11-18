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
// one. G5.154 (§8.259): refit to every real flight past 1.8 m (benchmarks_tracking_chip.py,
// landing med 1.68 / 1.92 / 2.36 / 2.84 / 3.56 s) — "past 4 m" kept only the steepest third
// of short ones, and every 10-20 m chip of ours hung 2.9 s at a 6.6 m peak (real 3.2 m).
// G5.155 (§8.260): and its spread — each loft flies at one of kLevels landing times for
// its carry, the real p10 / p30 / p50 / p70 / p90 (benchmarks_tracking_chip.py), the level
// drawn per kick (World::loftLevel); physics.ball.loft_time_<bin>_p<q>, the p50 the old
// loft_time_<bin>. physics.ball.loft_spread_on 0 = the p50 for every kick.
// physics.ball.loft_time_on 0 = the flat 27° law. Throw-ins keep the flat
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
#include <string>

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
        // G5.156 (§8.261): an aimed loft's backspin lift, C_L [fitted to DFL peak-for-time; Goff & Carré 2010]
        const Fixed64 cl = p.fixed("physics.ball.lift_coeff", 250);
        kl_ = m.raw > 0 && cl.raw > 0 ? rho * area * cl / (m * 2) : Fixed64::zero();
        static const int kAt[5] = {15, 25, 35, 45, 60};
        // G5.154 (§8.259) p50; G5.155 (§8.260) the spread: real landing s ×1000, p10 / p30 / p50 / p70 / p90 by bin
        static const int kT[kLevels][5] = {{1160, 1200, 1800, 2280, 3080}, {1400, 1520, 2120, 2600, 3360},
                                           {1680, 1920, 2360, 2840, 3560}, {2040, 2280, 2640, 3120, 3880},
                                           {3280, 3240, 3560, 3840, 4360}};
        static const char* const kName[5] = {"physics.ball.loft_time_15", "physics.ball.loft_time_25", "physics.ball.loft_time_35",
                                             "physics.ball.loft_time_45", "physics.ball.loft_time_60"};
        static const char* const kQ[kLevels] = {"_p10", "_p30", "", "_p70", "_p90"};
        const bool on = p.integer("physics.ball.loft_time_on", 1) != 0;
        spread_ = on && p.integer("physics.ball.loft_spread_on", 1) != 0;
        std::array<std::int64_t, 6> key{k_.raw, on ? 1 : 0, spread_ ? 1 : 0, 0, kl_.raw, 0};
        Fixed64 tt[kLevels][5];
        for (int l = 0; l < kLevels; ++l)
            for (int i = 0; i < 5; ++i) {
                tt[l][i] = p.fixed(std::string(kName[i]) + kQ[l], kT[l][i]);
                key[3] = key[3] * 1000003 + tt[l][i].raw;
            }
        // The tables depend only on these numbers: solved once per process for each set
        // (every World and test builds a BallFlight; the solve is ~2M flight ticks a level).
        static std::array<std::int64_t, 6> last_key{};
        static std::shared_ptr<const Tables> last;
        if (last && last_key == key) { tables_ = last; return; }
        auto t = std::make_shared<Tables>();
        for (int l = 0; l < kLevels; ++l)
            if (l == kMid || spread_) solve(t->lv[l], on, kAt, tt[l]);
        if (!spread_) for (int l = 0; l < kLevels; ++l) if (l != kMid) t->lv[l] = t->lv[kMid];
        tables_ = std::move(t);
        last = tables_; last_key = key;
    }

    static constexpr int kLevels = 5, kMid = 2;
    bool spread() const noexcept { return spread_; }

    // Drag coefficient per metre (k above).
    math::Fixed64 k() const noexcept { return k_; }

    // One tick of drag on an airborne ball's velocity: v −= k·|v|·v·dt.
    // G5.156 (§8.261): with backspin, lift too — kl·|v|·(ω̂ × v)·dt, ω̂ the horizontal
    // axis across his line (ω̂ × v = (−vx·vz/h, −vy·vz/h, h), h the ground speed): up
    // while it travels, back while it climbs, on while it drops [Goff & Carré 2010].
    void step(math::Vec3& v, bool spin = false) const {
        if (k_.raw == 0 && (!spin || kl_.raw == 0)) return;
        const math::Fixed64 sp = math::fx_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
        const math::Fixed64 f = math::Fixed64::one() - k_ * sp * kTickDt;
        math::Vec3 n{v.x * f, v.y * f, v.z * f};
        if (spin && kl_.raw > 0) {
            const math::Fixed64 h = math::fx_sqrt(v.x * v.x + v.y * v.y);
            if (h.raw > 0) {
                const math::Fixed64 q = kl_ * sp * kTickDt;
                n.x -= q * v.x * v.z / h;
                n.y -= q * v.y * v.z / h;
                n.z += q * h;
            }
        }
        v = n;
    }
    // G5.156: does an aimed loft carry backspin lift? ...and one of carry_m at level lv (a lob no
    // backspin flight makes is struck without it).
    bool lifts() const noexcept { return kl_.raw > 0; }
    bool spins(math::Fixed64 carry_m, int lv = kMid) const {
        if (kl_.raw <= 0) return false;
        const std::int64_t i = carry_m.raw <= 0 ? 1 : carry_m.raw >> math::Fixed64::FRAC_BITS;
        return lvl(lv).spin[i >= kMaxCarry ? kMaxCarry : i];
    }

    // Aimed loft: the speed to strike it (along the ground direction; it
    // rises at ratio() of that) so the first bounce is carry_m away; at flight
    // level lv (G5.155: 0 flattest .. kLevels-1 highest, kMid the median).
    math::Fixed64 launchSpeed(math::Fixed64 carry_m, int lv = kMid) const { return lookup(lvl(lv).speed, carry_m); }
    // G5.84: its rise / ground speed for that carry (kLoftLaunchRatio when off)...
    math::Fixed64 ratio(math::Fixed64 carry_m, int lv = kMid) const { return lookup(lvl(lv).ratio, carry_m); }
    // ...and the rise itself (m/s).
    math::Fixed64 launchRise(math::Fixed64 carry_m, int lv = kMid) const { return launchSpeed(carry_m, lv) * ratio(carry_m, lv); }
    // A throw-in: the flat kLoftLaunchRatio law (G5.84 left throws alone).
    math::Fixed64 throwSpeed(math::Fixed64 carry_m) const { return lookup(lvl(kMid).flat, carry_m); }
    // ...and how long it is in the air until that bounce (s).
    math::Fixed64 flightTime(math::Fixed64 carry_m, int lv = kMid) const { return lookup(lvl(lv).time, carry_m); }

    // G5.11 (§8.108): a loft of carry_m, coming down, passes height h this far
    // along the ground (its bounce point if it never rises over h).
    math::Fixed64 descendDist(math::Fixed64 carry_m, math::Fixed64 h) const {
        math::Vec3 vel{launchSpeed(carry_m), math::Fixed64::zero(), launchRise(carry_m)};
        math::Vec3 pos{};
        for (int ticks = 0; ticks < 600; ++ticks) {
            step(vel, spins(carry_m));
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
    struct Level {
        std::array<math::Fixed64, kMaxCarry + 1> speed{}, time{}, ratio{}, flat{};
        std::array<bool, kMaxCarry + 1> spin{};   // G5.156: struck with backspin at this carry
    };
    struct Tables { Level lv[kLevels]; };
    const Level& lvl(int lv) const { return tables_->lv[lv < 0 ? 0 : lv >= kLevels ? kLevels - 1 : lv]; }

    // The free-ball law (World::tickFreeBall) for one launch, to the first
    // bounce: metres along the ground and ticks.
    // ...and the tick it came back down through 0.5 m (benchmarks_tracking_loft.py's landing).
    void fly(math::Fixed64 v, math::Fixed64 r, math::Fixed64& dist, int& ticks, int* down = nullptr, bool spin = false) const {
        math::Vec3 vel{v, math::Fixed64::zero(), v * r};
        math::Vec3 pos{};
        const math::Fixed64 half = math::Fixed64::fromFraction(1, 2);
        ticks = 0;
        if (down) *down = -1;
        while (ticks < 600) {
            step(vel, spin);
            vel.z -= kGravity * kTickDt;
            pos += vel * kTickDt;
            ++ticks;
            if (down && *down < 0 && vel.z.raw < 0 && pos.z < half) *down = ticks;
            if (pos.z.raw < 0) break;
        }
        dist = pos.x;
    }
    // The launch speed at ratio r whose first bounce is want away.
    math::Fixed64 speedFor(math::Fixed64 want, math::Fixed64 r, int iters, bool spin = false) const {
        using math::Fixed64;
        Fixed64 lo = Fixed64::zero(), hi = Fixed64::fromInt(80);
        for (int it = 0; it < iters; ++it) {
            const Fixed64 mid = (lo + hi) / 2;
            Fixed64 dist{};
            int ticks = 0;
            fly(mid, r, dist, ticks, nullptr, spin);
            if (dist < want) lo = mid; else hi = mid;
        }
        return hi;
    }

    void solve(Level& t, bool on, const int* at, const math::Fixed64* tt) const {
        using math::Fixed64;
        const bool sp = kl_.raw > 0;   // G5.156: an aimed loft flies with its backspin (a throw-in, t.flat, without)
        auto target = [&](int c) {   // the real landing time at carry c: linear between bin middles, held past the ends
            if (c <= at[0]) return tt[0];
            for (int i = 1; i < 5; ++i)
                if (c <= at[i]) return tt[i - 1] + (tt[i] - tt[i - 1]) * Fixed64::fromFraction(c - at[i - 1], at[i] - at[i - 1]);
            return tt[4];
        };
        // The angle whose flight is back down through 0.5 m at goal ticks, the speed solved for the carry at each try.
        auto search = [&](const Fixed64& w, int goal, bool spin) {
            Fixed64 lo = Fixed64::fromFraction(1, 20), hi = Fixed64::fromInt(3);   // ~3° .. ~72° (G5.155: the p90 lob; G5.156: a backspun p10 flat ball; was 11-56°)
            for (int it = 0; it < 18; ++it) {
                const Fixed64 mid = (lo + hi) / 2;
                Fixed64 dist{};
                int ticks = 0, down = 0;
                fly(speedFor(w, mid, 22, spin), mid, dist, ticks, &down, spin);
                if (down < goal) lo = mid; else hi = mid;
            }
            return hi;
        };
        // G5.156: does that flight make it — down at its time (±3 ticks), first bounce at its carry (±0.6 m)?
        auto makes = [&](const Fixed64& w, int goal, const Fixed64& r, bool spin) {
            Fixed64 dist{};
            int ticks = 0, down = 0;
            fly(speedFor(w, r, 28, spin), r, dist, ticks, &down, spin);
            const Fixed64 miss = math::fx_abs(dist - w);
            return down >= goal - 3 && down <= goal + 3 && miss < Fixed64::fromFraction(3, 5);
        };
        Fixed64 r_lo_end{}, r_hi_end{};
        bool s_lo_end = sp, s_hi_end = sp;
        for (int c = 0; c <= kMaxCarry; ++c) {
            const Fixed64 want = Fixed64::fromInt(c < 1 ? 1 : c);
            t.flat[c] = speedFor(want, kLoftLaunchRatio, 28);
            Fixed64 r = kLoftLaunchRatio;
            bool spin = sp;
            if (on) {
                if (c < at[0] && c > 0 && r_lo_end.raw) { r = r_lo_end; spin = s_lo_end; }
                else if (c > 70 && r_hi_end.raw) { r = r_hi_end; spin = s_hi_end; }
                else {
                    const int cc = c < at[0] ? at[0] : c;   // c 0: the 15 m angle
                    const Fixed64 w = Fixed64::fromInt(cc);
                    const int goal = static_cast<int>((target(cc) / kTickDt).raw >> Fixed64::FRAC_BITS);
                    r = search(w, goal, spin);
                    // G5.156 (§8.261): a lob no backspin flight can make (lift pulls a steep slow ball back on
                    // itself: the 15 m p90, 3.3 s) is struck without it — a scoop, a skied ball.
                    if (spin && !makes(w, goal, r, true)) { spin = false; r = search(w, goal, false); }
                    if (c == at[0] || c == 0) { r_lo_end = r; s_lo_end = spin; }
                    if (c == 70) { r_hi_end = r; s_hi_end = spin; }
                }
            }
            t.ratio[c] = r;
            t.spin[c] = spin;
            t.speed[c] = r == kLoftLaunchRatio && !spin ? t.flat[c] : speedFor(want, r, 28, spin);
            Fixed64 dist{};
            int ticks = 0;
            fly(t.speed[c], r, dist, ticks, nullptr, spin);
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

    math::Fixed64 k_{}, kl_{};
    bool spread_ = false;
    std::shared_ptr<const Tables> tables_;   // shared: World is copied per brain per tick
};

}  // namespace fh::game::core
