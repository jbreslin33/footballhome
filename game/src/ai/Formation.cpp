// game/src/ai/Formation.cpp

#include "ai/Formation.hpp"

namespace fh::game::ai {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

Vec2 nv(int x_pct, int y_pct) {
    // Normalized vector from integer percentages (keeps fromFraction exact).
    return Vec2{Fixed64::fromFraction(x_pct, 100),
                Fixed64::fromFraction(y_pct, 100)};
}

// How far the shape slides with the ball, as a fraction of ball position.
const Fixed64 kShiftX = Fixed64::fromFraction(25, 100);
const Fixed64 kShiftY = Fixed64::fromFraction(30, 100);
// Cap the slide so the block never collapses onto the ball.
const Fixed64 kShiftCapX = Fixed64::fromInt(14);
const Fixed64 kShiftCapY = Fixed64::fromInt(10);
// Stay inside the grass.
const Fixed64 kMargin = Fixed64::fromInt(2);
// GK leash: how far off the goal line the keeper may drift.
const Fixed64 kKeeperLeash = Fixed64::fromInt(8);

Fixed64 clampFx(Fixed64 v, Fixed64 lo, Fixed64 hi) {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
}

}  // namespace

std::vector<Vec2> formationBases(std::uint8_t n) {
    switch (n) {
        case 11:  // 4-4-2 [GRF]-style role spread
            return {
                nv(-95, 0),                                        // GK
                nv(-65, -60), nv(-70, -20), nv(-70, 20), nv(-65, 60),  // back 4
                nv(-35, -65), nv(-40, -22), nv(-40, 22), nv(-35, 65),  // mid 4
                nv(-12, -25), nv(-12, 25),                             // front 2
            };
        case 3:  // 1-1-1 triangle (the standing CI config)
            return {nv(-70, 0), nv(-35, -40), nv(-20, 40)};
        default: {
            // Generic fallback: rows of up to 4, deeper rows first.
            std::vector<Vec2> out;
            out.reserve(n);
            const int rows = (n + 3) / 4;
            for (std::uint8_t i = 0; i < n; ++i) {
                const int row = i / 4, in_row = i % 4;
                const int row_n =
                    (row == rows - 1) ? (n - row * 4) : 4;
                const int x = -85 + (70 * row) / (rows > 1 ? rows - 1 : 1);
                const int y =
                    row_n > 1 ? -60 + (120 * in_row) / (row_n - 1) : 0;
                out.push_back(nv(x, y));
            }
            return out;
        }
    }
}

Vec2 anchorFor(const Vec2& base, int attack_sign, const Vec3& ball,
               Fixed64 half_x, Fixed64 half_y, bool is_keeper) {
    // Normalized → pitch metres, mirrored for the attack direction.
    const Fixed64 sign = attack_sign >= 0 ? Fixed64::one() : -Fixed64::one();
    Fixed64 x = base.x * half_x * sign;
    Fixed64 y = base.y * half_y;

    // Slide with the ball ([HELIOS]-lite), capped.
    x += clampFx(ball.x * kShiftX, -kShiftCapX, kShiftCapX);
    y += clampFx(ball.y * kShiftY, -kShiftCapY, kShiftCapY);

    if (is_keeper) {
        // The keeper holds the goal line area regardless of the slide.
        const Fixed64 line = half_x * sign * Fixed64::fromFraction(-95, 100);
        const Fixed64 lo = (sign.raw > 0) ? line : line - kKeeperLeash;
        const Fixed64 hi = (sign.raw > 0) ? line + kKeeperLeash : line;
        x = clampFx(x, lo, hi);
        y = clampFx(y, -Fixed64::fromInt(6), Fixed64::fromInt(6));
    }

    return Vec2{clampFx(x, -half_x + kMargin, half_x - kMargin),
                clampFx(y, -half_y + kMargin, half_y - kMargin)};
}

}  // namespace fh::game::ai
