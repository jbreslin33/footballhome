// game/src/ai/Steering.hpp — the arrive-ramped seek every brain uses
// ([Reynolds via Buckland] steering; moved out of Brain.cpp for the G5.21
// player states).
#pragma once

#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"

namespace fh::game::ai {

// Arrive steering [Reynolds, via Buckland]: full speed outside the arrive
// radius, then desire ramps DOWN continuously to zero at the settle
// radius (World moves at |desire| x max_speed). The old bang-bang version
// (full speed / dead stop) had every off-ball player tracking a drifting
// anchor stop-start ~3-4x per second — James: "players jitter"; the
// harness measured ~4,000 go-stop flickers/min per match. The ramp's
// per-tick step is always shorter than the gap (never overshoots) and is
// continuous at both radii (no start-stop edge). Inside settle: stand —
// a near-zero vector would spin the body to face it.
inline math::Vec2 seek(const math::Vec3& from, const math::Vec2& to, math::Fixed64 arrive,
                        math::Fixed64 settle = math::Fixed64::fromFraction(1, 20)) {

    const math::Vec2 d{to.x - from.x, to.y - from.y};
    const math::Fixed64 dsq = math::lengthSquared(d);
    if (dsq >= arrive * arrive) return math::normalized(d);
    if (dsq <= settle * settle) return math::Vec2{};
    const math::Fixed64 len = math::length(d);
    const math::Fixed64 k = (len - settle) / ((arrive - settle) * len);
    return math::Vec2{d.x * k, d.y * k};
}

}  // namespace fh::game::ai
