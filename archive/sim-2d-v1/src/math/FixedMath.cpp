// sim/src/math/FixedMath.cpp
//
// Implementation of the deterministic transcendental library.

#include "math/FixedMath.hpp"
#include "math/TrigLUT.hpp"

#include <cstdint>

namespace fh::sim::math {

// =============================================================================
// fx_sqrt — integer Newton-Raphson on the raw representation.
//
// We want y such that y^2 == x in real space, i.e.
//   (y_raw / 2^32)^2 = (x_raw / 2^32)
//   y_raw^2          = x_raw * 2^32
//   y_raw            = isqrt(x_raw * 2^32)
//
// x_raw * 2^32 is up to 2^63 * 2^32 = 2^95, so we need a 128-bit intermediate.
// Then integer isqrt via Newton's method: y_{n+1} = (y_n + N / y_n) / 2.
// =============================================================================
namespace {

// isqrt over unsigned __int128 for N ≤ 2^96, returning a uint64_t.
// Deterministic (integer-only), converges in O(log log N) iterations.
// __int128 is a GCC/Clang extension; suppress -Wpedantic in this block only.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
std::uint64_t isqrt_u128(__uint128_t N) noexcept {
    if (N == 0) return 0;

    // Seed: y0 is the smallest power of 2 >= sqrt(N).
    // Compute floor(log2(N)) via a bit scan on the high/low halves.
    std::uint64_t hi = static_cast<std::uint64_t>(N >> 64);
    std::uint64_t lo = static_cast<std::uint64_t>(N);
    int highest_bit;
    if (hi != 0) {
        highest_bit = 127 - __builtin_clzll(hi);
    } else {
        highest_bit = 63 - __builtin_clzll(lo);
    }
    // sqrt(N) has ~highest_bit/2 bits.
    std::uint64_t y = std::uint64_t{1} << ((highest_bit / 2) + 1);

    // Newton iterations. int on int, no float, no reciprocal.
    // Terminates when y stops decreasing.
    while (true) {
        __uint128_t Ndivy = N / y;
        std::uint64_t next = static_cast<std::uint64_t>((Ndivy + y) >> 1);
        if (next >= y) {
            // Converged. Verify last step didn't oscillate above by testing
            // y^2 vs (y+1)^2 against N. Since we came from above, y is either
            // floor(sqrt(N)) or floor(sqrt(N))+1.
            __uint128_t y2 = static_cast<__uint128_t>(y) * y;
            if (y2 > N) --y;
            return y;
        }
        y = next;
    }
}
#pragma GCC diagnostic pop

}  // namespace

Fixed64 fx_sqrt(Fixed64 x) noexcept {
    if (x.raw <= 0) return Fixed64::zero();
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
    // N = x.raw * 2^32
    const __uint128_t N =
        static_cast<__uint128_t>(static_cast<std::uint64_t>(x.raw))
        << Fixed64::FRAC_BITS;
#pragma GCC diagnostic pop
    const std::uint64_t root = isqrt_u128(N);
    return Fixed64::fromRaw(static_cast<std::int64_t>(root));
}

// =============================================================================
// fx_sin / fx_cos — LUT + linear interpolation.
//
// Strategy:
//   idx_q32 = x * (SIN_LUT_SIZE / 2π)      // fixed-point index
//     -> integer part i (mod SIN_LUT_SIZE) picks table entry
//     -> fractional part t (Fixed64) blends toward the next entry
//
//   The scaling constant SIN_INDEX_SCALE is computed at compile time from
//   FX_TAU using __int128, so it is guaranteed correct and doesn't drift
//   through a hand-copied literal.
// =============================================================================
namespace {

// SIN_INDEX_SCALE real value = SIN_LUT_SIZE / (2π)
// Fixed64.raw = real * 2^32, so:
//   .raw = SIN_LUT_SIZE * 2^32 / (2π)
//        = (SIN_LUT_SIZE << 64) / FX_TAU.raw
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
constexpr std::int64_t compute_sin_index_scale_raw() noexcept {
    return static_cast<std::int64_t>(
        (static_cast<__int128>(SIN_LUT_SIZE) << 64)
        / static_cast<__int128>(FX_TAU.raw));
}
#pragma GCC diagnostic pop

constexpr Fixed64 SIN_INDEX_SCALE =
    Fixed64::fromRaw(compute_sin_index_scale_raw());

// LUT-based sin using a Fixed64-scaled index. All modular reduction happens
// via uint64 masking; the input is first mapped to [0, 2π) equivalent-index.
Fixed64 sin_from_index_scaled(Fixed64 idx_scaled) noexcept {
    // Take the raw as a two's-complement integer, then reduce mod SIN_LUT_SIZE
    // in the integer domain. The Q32.32 index has 32 fractional bits.
    //   integer_part = raw >> 32   (mod SIN_LUT_SIZE)
    //   frac_part    = raw & 0xFFFFFFFF   (Fixed64 fractional, 0..1)
    //
    // Because raw can be negative, we work in unsigned wrap-space. Every
    // 2^32 raw units = 1 table step; every 2^32 * 4096 raw units = one full
    // period. Modular reduction is a mask.
    std::uint64_t r = static_cast<std::uint64_t>(idx_scaled.raw);
    // Bits: [32+SIN_LUT_BITS-1 : 32] = integer index; below 32 = frac.
    const std::uint64_t index_mask = (std::uint64_t{1} << SIN_LUT_BITS) - 1;
    const int          i = static_cast<int>((r >> Fixed64::FRAC_BITS) & index_mask);
    const int          j = (i + 1) & static_cast<int>(index_mask);
    // Fractional interpolation weight in Fixed64.
    const Fixed64      t = Fixed64::fromRaw(
        static_cast<std::int64_t>(r & static_cast<std::uint64_t>(Fixed64::FRAC_MASK)));
    const std::int64_t* tbl = detail::sin_table();
    const Fixed64      a = Fixed64::fromRaw(tbl[i]);
    const Fixed64      b = Fixed64::fromRaw(tbl[j]);
    return a + (b - a) * t;
}

}  // namespace

Fixed64 fx_sin(Fixed64 radians) noexcept {
    return sin_from_index_scaled(radians * SIN_INDEX_SCALE);
}

Fixed64 fx_cos(Fixed64 radians) noexcept {
    return sin_from_index_scaled((radians + FX_HALF_PI) * SIN_INDEX_SCALE);
}

// =============================================================================
// fx_atan2 — LUT of atan(r) for r ∈ [0,1] + quadrant fold-in.
//
// Standard identity:
//   atan(1/r) = π/2 − atan(r)   for r > 0
//   so we only need atan on [0, 1] and fold in quadrant + swap.
// =============================================================================
namespace {

// atan(r) for r ∈ [0,1] using the atan_table.
// index scale: (ATAN_LUT_SIZE - 1) as Fixed64.
Fixed64 atan_unit(Fixed64 r) noexcept {
    // r assumed in [0, 1]. Compute idx_scaled = r * (ATAN_LUT_SIZE - 1).
    const Fixed64 scale = Fixed64::fromInt(ATAN_LUT_SIZE - 1);
    const Fixed64 idx_scaled = r * scale;
    // Split into integer index + fractional weight.
    std::int64_t raw = idx_scaled.raw;
    if (raw < 0) raw = 0;
    int i = static_cast<int>(raw >> Fixed64::FRAC_BITS);
    if (i >= ATAN_LUT_SIZE - 1) i = ATAN_LUT_SIZE - 2;
    const int j = i + 1;
    const Fixed64 t = Fixed64::fromRaw(raw
        & static_cast<std::int64_t>(Fixed64::FRAC_MASK));
    const std::int64_t* tbl = detail::atan_table();
    const Fixed64 a = Fixed64::fromRaw(tbl[i]);
    const Fixed64 b = Fixed64::fromRaw(tbl[j]);
    return a + (b - a) * t;
}

}  // namespace

Fixed64 fx_atan2(Fixed64 y, Fixed64 x) noexcept {
    // Special cases first.
    if (x.raw == 0 && y.raw == 0) return Fixed64::zero();
    if (x.raw == 0)               return y.raw > 0 ? FX_HALF_PI : -FX_HALF_PI;

    const Fixed64 ax = fx_abs(x);
    const Fixed64 ay = fx_abs(y);

    // r = min / max in [0, 1]
    Fixed64 base;
    if (ay <= ax) {
        base = atan_unit(ay / ax);
    } else {
        // atan(x/y) then reflect: atan2(y,x) magnitude in [π/4, π/2]
        base = FX_HALF_PI - atan_unit(ax / ay);
    }

    // Quadrant fold-in using signs of x and y.
    //
    //   x > 0, y >= 0 :  base
    //   x > 0, y  < 0 : -base
    //   x < 0, y >= 0 :  π - base
    //   x < 0, y  < 0 : -(π - base) = base - π
    if (x.raw > 0) {
        return y.raw >= 0 ? base : -base;
    } else {
        return y.raw >= 0 ? (FX_PI - base) : (base - FX_PI);
    }
}

// =============================================================================
// fx_hypot
// =============================================================================
Fixed64 fx_hypot(Fixed64 x, Fixed64 y) noexcept {
    return fx_sqrt(x * x + y * y);
}

}  // namespace fh::sim::math
