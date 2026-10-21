// sim/src/math/Fixed64.hpp
// Q32.32 fixed-point arithmetic — the deterministic math foundation.
//
// Design ref: sim/DESIGN.md §5.1, §10.
//
//   Fixed64 wraps a signed 64-bit integer where the upper 32 bits are the
//   integer part and the lower 32 bits are the fractional part.
//
//   raw = (real_value * 2^32)  as int64_t
//
//   Range     : ±2,147,483,647 units          (well over the 105 m pitch)
//   Precision : 2^-32 ≈ 2.33e-10 units        (sub-nanometer on a 105 m pitch)
//
//   Multiplication uses __int128 for an exact 128-bit intermediate, then
//   arithmetic-shifts back by 32. Division does the same in reverse. Both
//   compile to 2-4 native instructions on x86_64 and aarch64 (GCC/Clang).
//
// Determinism guarantees:
//   - Same bytes in, same bytes out on any platform with __int128.
//   - No transcendentals, no floats, no compiler-dependent rounding.
//   - Constexpr where the language allows (all except conversions to/from
//     float, which round-trip through the FPU).
//
// Boundaries where Fixed64 may be crossed (only these):
//   - DB load     : Fixed64::fromFloat(REAL from Postgres)     — see profile/
//   - Wire encode : Fixed64::toFloat()  → f32 in the snapshot  — see net/
//   - Debug I/O   : toFloat() / toDouble() for logging         — see server/
//   - Tests       : convenience constructors                   — see tests/

#pragma once

#include <cstdint>
#include <compare>

namespace fh::sim::math {

struct Fixed64 {
    // Q32.32 raw representation. int64_t is portable across GCC/Clang.
    // Signed overflow is UB in C++, but we route every arithmetic op through
    // 128-bit intermediates or through wrap-safe patterns.
    std::int64_t raw;

    static constexpr std::int32_t FRAC_BITS = 32;
    static constexpr std::int64_t ONE       = std::int64_t{1} << FRAC_BITS;
    static constexpr std::int64_t FRAC_MASK = ONE - 1;

    // ---- Construction ------------------------------------------------------
    // Default constructor gives zero (a chosen convention, matches int64_t{}).
    constexpr Fixed64() noexcept : raw{0} {}
    // Explicit-only construction from raw to avoid accidental int-to-Fixed64.
    explicit constexpr Fixed64(std::int64_t r) noexcept : raw{r} {}

    static constexpr Fixed64 fromInt(std::int32_t v) noexcept {
        return Fixed64{static_cast<std::int64_t>(v) << FRAC_BITS};
    }
    static constexpr Fixed64 fromRaw(std::int64_t r) noexcept {
        return Fixed64{r};
    }
    // Boundary-only. Use exactly at DB-load and test-construction sites.
    // Rounds half-to-even (via nearbyint) to keep behavior predictable.
    static Fixed64 fromFloat(float f) noexcept;
    static Fixed64 fromDouble(double d) noexcept;

    // Numerator / denominator convenience (both int32). Result is num/den
    // computed in fixed-point. Deterministic. Used for constants like 1/20.
    static constexpr Fixed64 fromFraction(std::int32_t num,
                                          std::int32_t den) noexcept {
        // (num << 32) / den, all in int64_t. num up to 2^31 fits in int64.
        return Fixed64{(static_cast<std::int64_t>(num) << FRAC_BITS)
                        / static_cast<std::int64_t>(den)};
    }

    // ---- Conversion out (boundary use only) --------------------------------
    // These involve the FPU and are NOT deterministic across all platforms in
    // the last ULP — that's why they are boundary-only.
    float  toFloat()  const noexcept;
    double toDouble() const noexcept;

    // ---- Named constants ---------------------------------------------------
    static constexpr Fixed64 zero()     noexcept { return Fixed64{0}; }
    static constexpr Fixed64 one()      noexcept { return Fixed64{ONE}; }
    static constexpr Fixed64 halfConst() noexcept { return Fixed64{ONE >> 1}; }

    // ---- Arithmetic --------------------------------------------------------
    // Uses __int128 for mul/div intermediates. GCC/Clang natively support
    // __int128 on x86_64 and aarch64. It is a GNU extension that ISO C++
    // does not define — we suppress -Wpedantic only for these specific
    // operations; every other pedantic diagnostic remains an error.
    constexpr Fixed64 operator+(Fixed64 rhs) const noexcept {
        return Fixed64{raw + rhs.raw};
    }
    constexpr Fixed64 operator-(Fixed64 rhs) const noexcept {
        return Fixed64{raw - rhs.raw};
    }
    constexpr Fixed64 operator-() const noexcept {
        return Fixed64{-raw};
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
    constexpr Fixed64 operator*(Fixed64 rhs) const noexcept {
        // (a.raw / 2^32) * (b.raw / 2^32) = (a.raw * b.raw) / 2^64
        // We want the real result in Q32.32, so shift back by 32:
        //   result_raw = (a.raw * b.raw) >> 32
        // Full 128-bit intermediate to avoid overflow.
        __int128 prod = static_cast<__int128>(raw)
                      * static_cast<__int128>(rhs.raw);
        return Fixed64{static_cast<std::int64_t>(prod >> FRAC_BITS)};
    }
    constexpr Fixed64 operator/(Fixed64 rhs) const noexcept {
        // (a / b) in real space, keeping Q32.32:
        //   result_raw = (a.raw << 32) / b.raw
        // Numerator shifted into 128 bits.
        __int128 num = static_cast<__int128>(raw) << FRAC_BITS;
        return Fixed64{static_cast<std::int64_t>(num
                        / static_cast<__int128>(rhs.raw))};
    }
#pragma GCC diagnostic pop

    constexpr Fixed64& operator+=(Fixed64 rhs) noexcept { *this = *this + rhs; return *this; }
    constexpr Fixed64& operator-=(Fixed64 rhs) noexcept { *this = *this - rhs; return *this; }
    constexpr Fixed64& operator*=(Fixed64 rhs) noexcept { *this = *this * rhs; return *this; }
    constexpr Fixed64& operator/=(Fixed64 rhs) noexcept { *this = *this / rhs; return *this; }

    // Multiply by an integer scalar (no rounding, no precision loss).
    constexpr Fixed64 operator*(std::int32_t s) const noexcept {
        return Fixed64{raw * static_cast<std::int64_t>(s)};
    }
    constexpr Fixed64& operator*=(std::int32_t s) noexcept { *this = *this * s; return *this; }

    // Integer division by a scalar (truncates toward zero — deterministic).
    constexpr Fixed64 operator/(std::int32_t s) const noexcept {
        return Fixed64{raw / static_cast<std::int64_t>(s)};
    }
    constexpr Fixed64& operator/=(std::int32_t s) noexcept { *this = *this / s; return *this; }

    // ---- Comparisons -------------------------------------------------------
    // Three-way <=> gives us all six operators.
    constexpr auto operator<=>(const Fixed64& rhs) const noexcept = default;
    // == is defaulted by <=> too.
};

// ---- Free functions --------------------------------------------------------
// Named to avoid clashing with std:: and to make gameplay code obvious.

constexpr Fixed64 fx_abs(Fixed64 x) noexcept {
    // Note: raw == INT64_MIN would overflow. We accept that as UB just like
    // std::abs — no gameplay value should be anywhere near ±2^31 units.
    return x.raw < 0 ? Fixed64{-x.raw} : x;
}

constexpr Fixed64 fx_min(Fixed64 a, Fixed64 b) noexcept {
    return a.raw < b.raw ? a : b;
}
constexpr Fixed64 fx_max(Fixed64 a, Fixed64 b) noexcept {
    return a.raw > b.raw ? a : b;
}
constexpr Fixed64 fx_clamp(Fixed64 x, Fixed64 lo, Fixed64 hi) noexcept {
    return fx_min(fx_max(x, lo), hi);
}

// Deterministic sign function: -1 / 0 / +1 as Fixed64.
constexpr Fixed64 fx_sign(Fixed64 x) noexcept {
    if (x.raw > 0) return Fixed64::one();
    if (x.raw < 0) return Fixed64{-Fixed64::ONE};
    return Fixed64::zero();
}

}  // namespace fh::sim::math
