// sim/tests/test_fixed_math.cpp
//
// Accuracy + determinism tests for fx_sqrt, fx_sin, fx_cos, fx_atan2, fx_hypot.

#include "test_harness.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"

#include <cmath>
#include <cstdint>

using fh::sim::math::Fixed64;
using namespace fh::sim::math;

// Tolerance helper: compare two Fixed64 within `max_raw_ulps` raw units.
static bool close_raw(Fixed64 a, Fixed64 b, std::int64_t max_raw_ulps) {
    const std::int64_t d = a.raw > b.raw ? a.raw - b.raw : b.raw - a.raw;
    return d <= max_raw_ulps;
}

// Same-value tolerance in terms of real-space delta.
// 1 raw unit = 2.33e-10; so 1e-4 units = ~430,000 raw ulps.
static constexpr std::int64_t kSinCosTolRaw = 1'000'000;   // ~2.3e-4 in real units
static constexpr std::int64_t kSqrtTolRaw   = 100;         // ~2.3e-8 in real units
static constexpr std::int64_t kAtanTolRaw   = 5'000'000;   // ~1.2e-3 rad

// =============================================================================
// fx_sqrt
// =============================================================================
FH_TEST(fx_sqrt_perfect_squares) {
    // sqrt(0), sqrt(1), sqrt(4), sqrt(100)
    FH_EXPECT_EQ(fx_sqrt(Fixed64::zero()).raw, 0);
    FH_EXPECT(close_raw(fx_sqrt(Fixed64::fromInt(1)),   Fixed64::fromInt(1),  kSqrtTolRaw));
    FH_EXPECT(close_raw(fx_sqrt(Fixed64::fromInt(4)),   Fixed64::fromInt(2),  kSqrtTolRaw));
    FH_EXPECT(close_raw(fx_sqrt(Fixed64::fromInt(9)),   Fixed64::fromInt(3),  kSqrtTolRaw));
    FH_EXPECT(close_raw(fx_sqrt(Fixed64::fromInt(100)), Fixed64::fromInt(10), kSqrtTolRaw));
}

FH_TEST(fx_sqrt_pitch_range) {
    // sqrt(105) ~ 10.246950...
    const Fixed64 x = Fixed64::fromInt(105);
    const Fixed64 r = fx_sqrt(x);
    // Reference from double, converted to Fixed64 for compare.
    const Fixed64 expected = Fixed64::fromDouble(std::sqrt(105.0));
    FH_EXPECT(close_raw(r, expected, kSqrtTolRaw));
}

FH_TEST(fx_sqrt_negative_yields_zero) {
    FH_EXPECT_EQ(fx_sqrt(Fixed64::fromInt(-5)).raw, 0);
}

FH_TEST(fx_sqrt_monotone) {
    // sqrt is monotonically non-decreasing
    Fixed64 last = Fixed64::zero();
    for (std::int32_t n = 0; n <= 200; ++n) {
        const Fixed64 r = fx_sqrt(Fixed64::fromInt(n));
        FH_EXPECT(r.raw >= last.raw);
        last = r;
    }
}

FH_TEST(fx_sqrt_deterministic_repeated) {
    const Fixed64 x = Fixed64::fromInt(105);
    const Fixed64 first = fx_sqrt(x);
    for (int i = 0; i < 1000; ++i) {
        FH_EXPECT_EQ(fx_sqrt(x).raw, first.raw);
    }
}

// =============================================================================
// fx_sin / fx_cos
// =============================================================================
FH_TEST(fx_sin_zero) {
    FH_EXPECT_EQ(fx_sin(Fixed64::zero()).raw, 0);
}

FH_TEST(fx_cos_zero_is_one) {
    FH_EXPECT(close_raw(fx_cos(Fixed64::zero()), Fixed64::one(), kSinCosTolRaw));
}

FH_TEST(fx_sin_half_pi_is_one) {
    FH_EXPECT(close_raw(fx_sin(FX_HALF_PI), Fixed64::one(), kSinCosTolRaw));
}

FH_TEST(fx_sin_pi_is_zero) {
    FH_EXPECT(close_raw(fx_sin(FX_PI), Fixed64::zero(), kSinCosTolRaw));
}

FH_TEST(fx_sin_matches_std_sin_within_tolerance) {
    for (int deg = 0; deg <= 360; deg += 15) {
        const double rad = deg * 3.14159265358979323846 / 180.0;
        const Fixed64 x = Fixed64::fromDouble(rad);
        const Fixed64 got = fx_sin(x);
        const Fixed64 exp = Fixed64::fromDouble(std::sin(rad));
        FH_EXPECT(close_raw(got, exp, kSinCosTolRaw));
    }
}

FH_TEST(fx_cos_matches_std_cos_within_tolerance) {
    for (int deg = 0; deg <= 360; deg += 15) {
        const double rad = deg * 3.14159265358979323846 / 180.0;
        const Fixed64 got = fx_cos(Fixed64::fromDouble(rad));
        const Fixed64 exp = Fixed64::fromDouble(std::cos(rad));
        FH_EXPECT(close_raw(got, exp, kSinCosTolRaw));
    }
}

FH_TEST(fx_sin_pythagorean_identity) {
    // sin²(x) + cos²(x) ≈ 1 for a range of x
    for (int deg = 0; deg <= 720; deg += 27) {
        const double rad = deg * 3.14159265358979323846 / 180.0;
        const Fixed64 x = Fixed64::fromDouble(rad);
        const Fixed64 s = fx_sin(x);
        const Fixed64 c = fx_cos(x);
        const Fixed64 sum = s * s + c * c;
        FH_EXPECT(close_raw(sum, Fixed64::one(), kSinCosTolRaw * 3));
    }
}

FH_TEST(fx_sin_deterministic_repeated) {
    const Fixed64 x = Fixed64::fromDouble(1.2345678);
    const Fixed64 first = fx_sin(x);
    for (int i = 0; i < 1000; ++i) {
        FH_EXPECT_EQ(fx_sin(x).raw, first.raw);
    }
}

FH_TEST(fx_sin_periodicity) {
    // sin(x) == sin(x + 2π) within tolerance
    for (int deg = 0; deg < 360; deg += 37) {
        const double rad = deg * 3.14159265358979323846 / 180.0;
        const Fixed64 x        = Fixed64::fromDouble(rad);
        const Fixed64 x_plus_2pi = x + FX_TAU;
        FH_EXPECT(close_raw(fx_sin(x), fx_sin(x_plus_2pi), kSinCosTolRaw));
    }
}

// =============================================================================
// fx_atan2
// =============================================================================
FH_TEST(fx_atan2_axis_cases) {
    // atan2(0, 0) = 0 (by our convention)
    FH_EXPECT_EQ(fx_atan2(Fixed64::zero(), Fixed64::zero()).raw, 0);
    // atan2(0, 1) = 0
    FH_EXPECT(close_raw(fx_atan2(Fixed64::zero(), Fixed64::one()),
                        Fixed64::zero(), kAtanTolRaw));
    // atan2(1, 0) = π/2
    FH_EXPECT(close_raw(fx_atan2(Fixed64::one(), Fixed64::zero()),
                        FX_HALF_PI, kAtanTolRaw));
    // atan2(0, -1) = π
    FH_EXPECT(close_raw(fx_atan2(Fixed64::zero(), -Fixed64::one()),
                        FX_PI, kAtanTolRaw));
    // atan2(-1, 0) = -π/2
    FH_EXPECT(close_raw(fx_atan2(-Fixed64::one(), Fixed64::zero()),
                        -FX_HALF_PI, kAtanTolRaw));
}

FH_TEST(fx_atan2_quadrants) {
    // Compare against std::atan2 across many angles at unit radius.
    for (int deg = 5; deg < 360; deg += 11) {
        const double rad = deg * 3.14159265358979323846 / 180.0;
        const double xd  = std::cos(rad);
        const double yd  = std::sin(rad);
        const Fixed64 x  = Fixed64::fromDouble(xd);
        const Fixed64 y  = Fixed64::fromDouble(yd);
        const Fixed64 got = fx_atan2(y, x);
        const Fixed64 exp = Fixed64::fromDouble(std::atan2(yd, xd));
        // atan2 tolerance a bit looser due to two divisions.
        FH_EXPECT(close_raw(got, exp, kAtanTolRaw));
    }
}

FH_TEST(fx_atan2_deterministic) {
    const Fixed64 y = Fixed64::fromInt(3);
    const Fixed64 x = Fixed64::fromInt(4);
    const Fixed64 first = fx_atan2(y, x);
    for (int i = 0; i < 1000; ++i) {
        FH_EXPECT_EQ(fx_atan2(y, x).raw, first.raw);
    }
}

// =============================================================================
// fx_hypot
// =============================================================================
FH_TEST(fx_hypot_3_4_5) {
    // classic 3-4-5 triangle
    const Fixed64 h = fx_hypot(Fixed64::fromInt(3), Fixed64::fromInt(4));
    FH_EXPECT(close_raw(h, Fixed64::fromInt(5), kSqrtTolRaw));
}

FH_TEST(fx_hypot_zero) {
    FH_EXPECT_EQ(fx_hypot(Fixed64::zero(), Fixed64::zero()).raw, 0);
}

FH_TEST(fx_hypot_matches_std) {
    for (int i = 1; i < 30; ++i) {
        for (int j = 0; j < 30; ++j) {
            const Fixed64 h = fx_hypot(Fixed64::fromInt(i), Fixed64::fromInt(j));
            const Fixed64 e = Fixed64::fromDouble(std::hypot(double(i), double(j)));
            FH_EXPECT(close_raw(h, e, kSqrtTolRaw));
        }
    }
}

FH_TEST_MAIN()
