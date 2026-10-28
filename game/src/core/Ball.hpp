// game/src/core/Ball.hpp
//
// The ball: 3D state + passive physics constants. Players are planar; the
// ball is the one entity with a real z (DESIGN.md §4).
//
// Ground-plane friction model [v1]: multiplicative per-tick velocity decay
// (direction-preserving, no sqrt, deterministic) + snap-to-rest below a
// threshold (Fixed64 truncation never reaches zero asymptotically) + a
// "kick-alive" runway after each kick so friction can't kill a short pass
// before it reaches the receiver. v1 proved all three at 20 Hz; constants
// here are re-derived for 30 Hz.
//
// Vertical model (new in v2): constant gravity while airborne, impact →
// bounce with restitution, tiny bounces squashed to rolling.

#pragma once

#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <optional>

namespace fh::game::core {

// ── constants ───────────────────────────────────────────────────────────

// [v1] 0.98 per 20 Hz tick ⇒ same half-life at 30 Hz ≈ 0.9867/tick.
// 987/1000 keeps fromFraction exact.
inline const math::Fixed64 kBallRollDecayPerTick =
    math::Fixed64::fromFraction(987, 1000);

// [v1] below this per-axis speed (m/s) a GROUNDED ball snaps to rest.
inline const math::Fixed64 kBallRestThreshold =
    math::Fixed64::fromFraction(1, 100);

// [v1] 2 s runway after a kick during which snap-to-rest is suppressed.
inline constexpr int kKickAliveTicks = 60;  // 2 s at 30 Hz

// Gravity, m/s². 981/100 exact.
inline const math::Fixed64 kGravity = math::Fixed64::fromFraction(981, 100);

// Bounce restitution: a grass bounce keeps ~55% of impact speed.
inline const math::Fixed64 kBallRestitution =
    math::Fixed64::fromFraction(11, 20);

// Grass skid (G4.48): a bounce keeps this much of the ball's FORWARD speed
// too. Without it every lofted ball skipped on at full pace — a 40 m pass
// landed at 20 m/s (past any first touch) and bounced 40 m more, out of
// play. Real turf takes ~a third off on a dropping ball.
inline const math::Fixed64 kBounceSkid = math::Fixed64::fromFraction(13, 20);

// Below this vertical impact speed (m/s) a bounce squashes to rolling.
inline const math::Fixed64 kBounceDeadSpeed = math::Fixed64::fromFraction(1, 2);

// [v1] capture radius (m): a slow free ball within this of a player's feet
// is picked up.
inline const math::Fixed64 kBallControlRadius = math::Fixed64::fromFraction(1, 2);

// A free ball faster than this (m/s) cannot be captured. 20 covers every
// current kick, which makes receiving AND intercepting the same mechanic:
// stand on the ball's path, the ball is yours (soccer, in one rule). The
// G1 value of 8 made passes unreceivable — the calibration harness caught
// it. Touch QUALITY (fast balls bobbling off weak first touches) arrives
// with attributes in G4.
inline const math::Fixed64 kCaptureMaxSpeed = math::Fixed64::fromInt(20);

// Keeper hands: a designated keeper claims the ball in a wider radius
// (dive/reach), higher (jump), and controls faster balls (+ hands bonus).
inline const math::Fixed64 kKeeperReach = math::Fixed64::fromFraction(6, 5);
inline const math::Fixed64 kKeeperReachZ = math::Fixed64::fromFraction(11, 5);
inline const math::Fixed64 kKeeperHandsBonus = math::Fixed64::fromInt(10);
// A failed first touch deflects the ball at this fraction of its speed.
inline const math::Fixed64 kBobbleKeep = math::Fixed64::fromFraction(2, 5);
inline constexpr int kBobbleLockoutTicks = 8;

// Tackling (G4.6): lunge reach, poke speed, and the recovery stun.
// 1.8 m: a real lunge with leg extension. 1.3 was unreachable BY
// CONSTRUCTION from behind a carrier (0.9 m body spacing + 0.4 m ball
// lead = 1.3 exactly) — AI defenders could never fire the dive.
inline const math::Fixed64 kTackleReach = math::Fixed64::fromFraction(9, 5);
inline const math::Fixed64 kTacklePokeSpeed = math::Fixed64::fromInt(6);
inline constexpr int kTackleMissRecovery = 15;  // 0.5 s flat on the turf
inline constexpr int kTackleWinRecovery  = 5;   // played the ball, quick up
inline constexpr int kDispossessedRecovery = 10;  // tackled carrier, off balance (G4.24)

// [v1] glue distance (m): carried ball sits this far ahead of the owner.
inline const math::Fixed64 kBallCarryLead = math::Fixed64::fromFraction(2, 5);

// Kick powers (m/s). Preset in G1; pass_power attributes arrive G2.
inline const math::Fixed64 kGroundKickSpeed = math::Fixed64::fromInt(14);
inline const math::Fixed64 kShortPassSpeed   = math::Fixed64::fromInt(8);
// A WEIGHTED ground pass (G4.81): struck so it reaches the man d metres
// away at kPassArriveSpeed — a firm ball to feet. Under the roll decay a
// rolling ball loses (1 − decay)·30 ≈ 0.39 m/s per metre it travels, so
// v0 = arrive + 0.39·d, capped at the outfield capture speed. The preset
// 14 / 8 m/s ignored distance: a 25 m pass took 3.5 s and arrived at
// 3.7 m/s, a 13 m one 2.6 s — defenders had 3-5 s to get there, and 16-26%
// of passes to a man 10 m+ free were lost (fh-game-match). A real 20-30 m
// ground pass is struck ~15-20 m/s and takes ~1.5-2 s.
// G4.84: 9, not 6 — a firm ball. At 6 a 15 m pass left at 12 m/s and a
// 25 m one at 16: defenders cut out 72-84 a team a match (pro 7.2). At 9
// (15 / 19 m/s — side-foot passes run ~12-20 m/s in kicking studies) 48-54,
// shots 29 -> 20 a team, spells 515 -> 365; at 12 bad touches rose (the
// semipro control speed is 13) and it all went back up. 10 matches each.
inline const math::Fixed64 kPassArriveSpeed = math::Fixed64::fromInt(9);
inline math::Fixed64 weightedPassSpeed(math::Fixed64 d) {
    const math::Fixed64 per_m =
        (math::Fixed64::one() - kBallRollDecayPerTick) * math::Fixed64::fromInt(30);
    math::Fixed64 v = kPassArriveSpeed + per_m * d;
    const math::Fixed64 cap = math::Fixed64::fromInt(20);
    return v > cap ? cap : v;
}
// A struck shot. 18 m/s: inside the outfield capture cap (20), so a body
// in the way blocks it (usually as a bobble, via control limits); keeper
// hands (cap 26) handle it cleanly. 24 was measured to produce uncatchable
// pinball (564 goals/game perfect, 99% loose mixed) — G4.4 owns the full
// shot/save statistical model.
inline const math::Fixed64 kShotSpeed        = math::Fixed64::fromInt(24);
inline const math::Fixed64 kLoftKickSpeed   = math::Fixed64::fromInt(12);
inline const math::Fixed64 kLoftKickRise    = math::Fixed64::fromInt(6);
// Aimed loft (G4.48): rise / forward speed. 1/2 = the preset chip's own
// ~27° launch; a 40 m ball leaves at ~22 m/s and peaks at ~5 m — a driven
// long pass, not a skied hoof.
inline const math::Fixed64 kLoftLaunchRatio = math::Fixed64::fromFraction(1, 2);

// ── state ───────────────────────────────────────────────────────────────

// Ticks after a kick during which the KICKER cannot recapture their own
// ball — without it a carrier running behind their shot re-captures it
// every other tick and "machine-guns" the ball upfield (the calibration
// harness's second catch: 160-goal games of shot-stutter).
inline constexpr int kKickerLockoutTicks = 15;  // 0.5 s at 30 Hz

// Touch-to-steal [v1 M2 contest lineage]: an OPPONENT within this radius
// of a carried ball builds contest pressure; at kStealTicks consecutive
// ticks the ball changes hands. Pressing becomes real: you cannot carry
// through a defender who stays touch-tight for a third of a second.
inline const math::Fixed64 kStealRadius = math::Fixed64::fromFraction(3, 5);
inline constexpr int kStealTicks = 10;

struct BallState {
    math::Vec3 pos{};
    math::Vec3 vel{};
    std::optional<std::uint8_t> owner;  // nullopt = free
    int kick_alive = 0;                 // ticks of snap-to-rest suppression
    std::uint8_t last_kicker = 0xFF;    // slot that last kicked it
    int kicker_lockout = 0;             // ticks last_kicker may not recapture
    int contest_ticks = 0;              // consecutive ticks an opponent is touch-tight
    std::uint8_t pass_to = 0xFF;        // the mate the last kick was played to (G4.81)
};

}  // namespace fh::game::core
