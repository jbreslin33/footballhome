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

// Below this vertical impact speed (m/s) a bounce squashes to rolling.
inline const math::Fixed64 kBounceDeadSpeed = math::Fixed64::fromFraction(1, 2);

// [v1] capture radius (m): a slow free ball within this of a player's feet
// is picked up.
inline const math::Fixed64 kBallControlRadius = math::Fixed64::fromFraction(1, 2);

// A free ball faster than this (m/s, squared compare) cannot be captured —
// it runs through you in G1 (controlled first touch is a G2 mechanic).
inline const math::Fixed64 kCaptureMaxSpeed = math::Fixed64::fromInt(8);

// [v1] glue distance (m): carried ball sits this far ahead of the owner.
inline const math::Fixed64 kBallCarryLead = math::Fixed64::fromFraction(2, 5);

// Kick powers (m/s). Preset in G1; pass_power attributes arrive G2.
inline const math::Fixed64 kGroundKickSpeed = math::Fixed64::fromInt(14);
inline const math::Fixed64 kLoftKickSpeed   = math::Fixed64::fromInt(12);
inline const math::Fixed64 kLoftKickRise    = math::Fixed64::fromInt(6);

// ── state ───────────────────────────────────────────────────────────────

struct BallState {
    math::Vec3 pos{};
    math::Vec3 vel{};
    std::optional<std::uint8_t> owner;  // nullopt = free
    int kick_alive = 0;                 // ticks of snap-to-rest suppression
};

}  // namespace fh::game::core
