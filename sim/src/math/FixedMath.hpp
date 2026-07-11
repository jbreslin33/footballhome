// sim/src/math/FixedMath.hpp
//
// Deterministic transcendentals over Fixed64.
//
//   fx_sqrt   : integer Newton–Raphson, monotone, bit-exact.
//   fx_sin    : LUT of 4096 entries + linear interpolation, exact modular reduce.
//   fx_cos    : fx_sin(x + π/2).
//   fx_atan2  : LUT of 2048 entries + quadrant fold-in, uses ratio in [0,1].
//
// All functions take and return Fixed64 only. NO float/double in the sim
// loop. Enforced by scripts/check_no_floats.sh.
//
// Design ref: sim/DESIGN.md §5.1, §10.

#pragma once

#include "math/Fixed64.hpp"

namespace fh::sim::math {

// -----------------------------------------------------------------------------
// Named constants (Fixed64). Computed once as constexpr from raw bits so no
// float is involved at compile time either.
//
//   π ≈ 3.14159265358979323846
//   π  * 2^32 = 13,493,037,704.928...
//   π/2       = 6,746,518,852.464...
//   2π        = 26,986,075,409.856...
// -----------------------------------------------------------------------------
inline constexpr Fixed64 FX_PI       = Fixed64::fromRaw(13493037705LL);
inline constexpr Fixed64 FX_TAU      = Fixed64::fromRaw(26986075410LL);
inline constexpr Fixed64 FX_HALF_PI  = Fixed64::fromRaw(6746518852LL);
inline constexpr Fixed64 FX_QUARTER_PI = Fixed64::fromRaw(3373259426LL);
inline constexpr Fixed64 FX_INV_TAU  = Fixed64::fromRaw(683565276LL);   // 1 / (2π)

// -----------------------------------------------------------------------------
// fx_sqrt(x)
//   Returns the non-negative square root of x. Requires x >= 0.
//   Method: integer Newton–Raphson on the raw scaled representation.
//     If y = sqrt(x) in real space, then y_raw = sqrt(x_raw * 2^32) as int.
//   For x_raw = 0, returns 0. For negative x, returns 0 (defensive; callers
//   should not pass negatives).
// -----------------------------------------------------------------------------
Fixed64 fx_sqrt(Fixed64 x) noexcept;

// -----------------------------------------------------------------------------
// fx_sin / fx_cos  — LUT + linear interpolation.
//
//   Table has 4096 entries covering [0, 2π). Radians input is mapped by
//     idx_scaled = (x * 4096 / 2π)     (in fixed-point)
//   with integer part = table index, fractional part = interpolation t.
//
//   Modular reduction: convert x to a scaled 64-bit integer index in
//   [0, 4096) using unsigned arithmetic to guarantee wrap-around behavior
//   is deterministic.
// -----------------------------------------------------------------------------
Fixed64 fx_sin(Fixed64 radians) noexcept;
Fixed64 fx_cos(Fixed64 radians) noexcept;

// -----------------------------------------------------------------------------
// fx_atan2(y, x)
//
//   Two-argument arctangent. Returns angle in radians in (-π, π].
//   Method:
//     1. Handle x=0, y=0 special cases explicitly.
//     2. Reduce to ratio r = min(|y|,|x|) / max(|y|,|x|) so r ∈ [0, 1].
//     3. Look up atan(r) from the atan LUT (2048 entries, linear interp).
//     4. Fold quadrant back in using the sign of x, y and swap.
// -----------------------------------------------------------------------------
Fixed64 fx_atan2(Fixed64 y, Fixed64 x) noexcept;

// -----------------------------------------------------------------------------
// fx_hypot(x, y) = sqrt(x*x + y*y)
//   Convenience for vector magnitude. Uses fx_sqrt after fixed-point multiply.
//   Note: intermediate x*x + y*y can exceed the Fixed64 range if x or y are
//   large; safe for pitch-scale coordinates (< 100 m).
// -----------------------------------------------------------------------------
Fixed64 fx_hypot(Fixed64 x, Fixed64 y) noexcept;

}  // namespace fh::sim::math
