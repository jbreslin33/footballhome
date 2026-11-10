// game/src/core/Footsteps.hpp — the body moves on its feet (G5.77, DESIGN §8.178).
//
// James 11/10: "is it possible for movement of players to be completely depending on their legs?
// or are we sliding them there and just making leg animations?" Until G5.77 a player was a point
// whose velocity relaxed toward the wanted one every tick (Locomotion.hpp), and the viewer drew
// legs after the fact. Now each player has two feet on a stride cycle and his velocity changes
// ONLY while a foot is on the ground: none in a running stride's flight. What a foot can do is
// limited by speed — the DFL envelope (benchmarks_tracking_envelope.py): speeding up p99 4.4 →
// 2.4 m/s^2 from a walk to 7-8 m/s, braking ~5 flat, lateral 4.2 → 6 rising. The stride-average
// cap is that envelope; inside the stride it is delivered in contact pulses of cap / (share of
// the stride with a foot down), so a sprinter (foot down 22% of the time) changes speed in hard
// pushes and drifts between them, and a man in the air cannot turn.
//
// Stride timing [Weyand 2000; Novacheck 1998]: walking stride 0.75 + 0.55 v m, duty 0.62;
// running contact length ~0.95 m, swing 0.50 s at 3 m/s → 0.34 s, blended 1.9-2.6 m/s.
// Where a foot lands [LIPM, Kajita 2001]: horizontal acceleration over a planted foot is
// w^2 (com − foot), so the foothold for the push he makes is com − a / w^2 — behind him to
// speed up, ahead to brake, outside his line to turn — plus the half-contact he will run over
// it and half his stance width to his side. The feet go on the wire (2.3 tail) and the viewer
// plants them exactly there. FH original (the stride numbers' sources as tagged).
#pragma once

#include "core/Clock.hpp"
#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"

#include <string>

namespace fh::game::core {

struct FootState {
    math::Vec2 plant[2]{};        // foot on the ground: where it stands; in the air: where it will land
    bool down[2] = {true, true};
    math::Fixed64 phase{};        // stride phase 0..1 (foot 0 lands at 0, foot 1 at 0.5)
    std::uint8_t prog[2] = {0, 0};   // 0..255 through this stance / swing
    bool placed = false;          // feet set at spawn / first tick
};

class Footsteps {
public:
    Footsteps() : Footsteps(ModelParams{}) {}
    explicit Footsteps(const ModelParams& p) {
        on_ = p.fixed("physics.body.steps_on", 1000).raw > 0;
        // DFL p99 by 1 m/s band 0-1 … 7-8 (benchmarks_tracking_envelope.py), m/s^2 x1000.
        static const int kAcc[8] = {4400, 4200, 4600, 4100, 3700, 3200, 2700, 2400};
        static const int kBrk[8] = {4800, 4700, 5300, 5100, 5200, 5100, 4800, 4700};
        static const int kLat[8] = {4300, 4200, 5200, 5400, 5800, 5900, 6100, 5800};
        for (int b = 0; b < 8; ++b) {
            acc_[b] = p.fixed("physics.body.acc_" + std::to_string(b), kAcc[b]);
            brk_[b] = p.fixed("physics.body.brk_" + std::to_string(b), kBrk[b]);
            lat_[b] = p.fixed("physics.body.lat_" + std::to_string(b), kLat[b]);
        }
    }
    bool on() const noexcept { return on_; }

    // The envelope at speed s: linear between band middles, held past the ends.
    math::Fixed64 accCap(math::Fixed64 s) const { return interp(acc_, s); }
    math::Fixed64 brkCap(math::Fixed64 s) const { return interp(brk_, s); }
    math::Fixed64 latCap(math::Fixed64 s) const { return interp(lat_, s); }

    struct Timing { math::Fixed64 T, duty, tc, cf, run; };
    // Stride period, duty factor (share of the stride each foot is down), contact time, and the
    // share of the stride with SOME foot down (cf = min(1, 2·duty)), at speed s.
    static Timing timing(math::Fixed64 s) {
        using math::Fixed64;
        const Fixed64 vs = s < Fixed64::fromFraction(3, 10) ? Fixed64::fromFraction(3, 10) : s;
        Fixed64 Tw = (Fixed64::fromFraction(3, 4) + Fixed64::fromFraction(55, 100) * vs) / vs;
        if (Tw > Fixed64::fromFraction(7, 5)) Tw = Fixed64::fromFraction(7, 5);
        const Fixed64 dw = Fixed64::fromFraction(62, 100);
        const Fixed64 vr = s < Fixed64::fromFraction(8, 5) ? Fixed64::fromFraction(8, 5) : s;
        const Fixed64 tc = Fixed64::fromFraction(95, 100) / vr;
        Fixed64 tsw = Fixed64::fromFraction(1, 2) - Fixed64::fromFraction(16, 1000) * (s - Fixed64::fromInt(3));
        if (tsw > Fixed64::fromFraction(1, 2)) tsw = Fixed64::fromFraction(1, 2);
        if (tsw < Fixed64::fromFraction(34, 100)) tsw = Fixed64::fromFraction(34, 100);
        const Fixed64 Tr = tc + tsw, dr = tc / Tr;
        Fixed64 u = (s - Fixed64::fromFraction(19, 10)) / Fixed64::fromFraction(7, 10);
        if (u.raw < 0) u = Fixed64::zero();
        if (u > Fixed64::one()) u = Fixed64::one();
        const Fixed64 r = u * u * (Fixed64::fromInt(3) - Fixed64::fromInt(2) * u);   // smoothstep
        Timing t;
        t.run = r;
        t.T = Tw + (Tr - Tw) * r;
        t.duty = dw + (dr - dw) * r;
        t.tc = t.duty * t.T;
        t.cf = t.duty * Fixed64::fromInt(2);
        if (t.cf > Fixed64::one()) t.cf = Fixed64::one();
        return t;
    }

    // Advance his feet one tick. pos, vel = his centre of mass after this tick's move; acc = the
    // contact acceleration he is pushing with; face = his facing (his feet sit either side of it);
    // still = standing (no stride: feet stay planted unless they must step). Returns whether a
    // foot was on the ground through this tick.
    bool advance(FootState& f, math::Vec2 pos, math::Vec2 vel, math::Vec2 acc, math::Vec2 face,
                 bool moving, math::Fixed64 dt) const {
        using math::Fixed64;
        const Fixed64 w = Fixed64::fromFraction(11, 100);
        const math::Vec2 side{-face.y, face.x};   // foot 0's side (the right foot, as the viewer's leg 0)
        // Set down somewhere new (a restart, a kick-off): his feet come with him.
        for (int i = 0; i < 2 && f.placed; ++i) {
            const math::Vec2 d{f.plant[i].x - pos.x, f.plant[i].y - pos.y};
            if (math::lengthSquared(d) > Fixed64::fromInt(16)) f.placed = false;   // 4 m off
        }
        if (!f.placed) {
            f.placed = true;
            for (int i = 0; i < 2; ++i) {
                const Fixed64 sd = i == 0 ? Fixed64::one() : -Fixed64::one();
                f.plant[i] = math::Vec2{pos.x + side.x * w * sd, pos.y + side.y * w * sd};
                f.down[i] = true;
            }
        }
        const Fixed64 s = math::length(vel);
        const Timing tm = timing(s);
        // Standing: feet stay where they are, unless the body has left them (he steps under it).
        if (!moving) {
            bool need = false;
            for (int i = 0; i < 2; ++i) {
                const math::Vec2 d{f.plant[i].x - pos.x, f.plant[i].y - pos.y};
                if (math::lengthSquared(d) > Fixed64::fromFraction(9, 100)) need = true;   // 0.3 m off
                if (!f.down[i]) need = true;                                                // finish the step
            }
            if (!need) {
                f.prog[0] = f.prog[1] = 0;
                return true;
            }
        }
        const Fixed64 ph0 = f.phase;
        Fixed64 ph = ph0 + dt / tm.T;
        while (ph >= Fixed64::one()) ph -= Fixed64::one();
        f.phase = ph;
        bool any = false;
        const Fixed64 g_over_h = Fixed64::fromFraction(109, 10);   // w^2 = g / 0.9 m
        for (int i = 0; i < 2; ++i) {
            Fixed64 ps = ph + (i == 0 ? Fixed64::zero() : Fixed64::fromFraction(1, 2));
            if (ps >= Fixed64::one()) ps -= Fixed64::one();
            const bool dn = ps < tm.duty;
            const Fixed64 sd = i == 0 ? Fixed64::one() : -Fixed64::one();
            if (dn && !f.down[i]) {
                // Touchdown: half the contact ahead of the body, to his side, offset by the push.
                const Fixed64 half = tm.tc * Fixed64::fromFraction(1, 2);
                Fixed64 ox = -acc.x / g_over_h, oy = -acc.y / g_over_h;
                const Fixed64 o2 = ox * ox + oy * oy, cap = Fixed64::fromFraction(6, 10);
                if (o2 > cap * cap) { const Fixed64 k = cap / math::fx_sqrt(o2); ox = ox * k; oy = oy * k; }
                f.plant[i] = math::Vec2{pos.x + vel.x * half + side.x * w * sd + ox,
                                        pos.y + vel.y * half + side.y * w * sd + oy};
            }
            if (!dn) {
                // In the air: where it will land (re-read every tick until it does).
                Fixed64 left = (Fixed64::one() - ps) * tm.T;
                const Fixed64 ahead = left + tm.tc * Fixed64::fromFraction(1, 2);
                f.plant[i] = math::Vec2{pos.x + vel.x * ahead + side.x * w * sd,
                                        pos.y + vel.y * ahead + side.y * w * sd};
                const Fixed64 u = (ps - tm.duty) / (Fixed64::one() - tm.duty);
                f.prog[i] = static_cast<std::uint8_t>((u * Fixed64::fromInt(255)).raw >> Fixed64::FRAC_BITS);
            } else {
                const Fixed64 u = ps / tm.duty;
                f.prog[i] = static_cast<std::uint8_t>((u * Fixed64::fromInt(255)).raw >> Fixed64::FRAC_BITS);
            }
            f.down[i] = dn;
            any = any || dn;
        }
        (void)ph0;
        return any;
    }

private:
    static math::Fixed64 interp(const math::Fixed64 (&t)[8], math::Fixed64 s) {
        using math::Fixed64;
        // band b's middle is b + 0.5 m/s
        const Fixed64 x = s - Fixed64::fromFraction(1, 2);
        if (x.raw <= 0) return t[0];
        const std::int64_t b = x.raw >> Fixed64::FRAC_BITS;
        if (b >= 7) return t[7];
        const Fixed64 f = Fixed64::fromRaw(x.raw - (b << Fixed64::FRAC_BITS));
        return t[b] + (t[b + 1] - t[b]) * f;
    }
    bool on_ = true;
    math::Fixed64 acc_[8]{}, brk_[8]{}, lat_[8]{};
};

}  // namespace fh::game::core
