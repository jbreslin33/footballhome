// sim/tests/test_fixed64.cpp
//
// Correctness + edge-case tests for Fixed64 Q32.32 arithmetic.

#include "test_harness.hpp"
#include "math/Fixed64.hpp"

#include <cstdint>
#include <initializer_list>
#include <limits>

using fh::sim::math::Fixed64;

// -----------------------------------------------------------------------------
// Construction
// -----------------------------------------------------------------------------
FH_TEST(fromInt_basic) {
    FH_EXPECT_EQ(Fixed64::fromInt(0).raw,   0);
    FH_EXPECT_EQ(Fixed64::fromInt(1).raw,   Fixed64::ONE);
    FH_EXPECT_EQ(Fixed64::fromInt(-1).raw, -Fixed64::ONE);
    FH_EXPECT_EQ(Fixed64::fromInt(105).raw, Fixed64::ONE * 105);
}

FH_TEST(fromRaw_roundtrip) {
    const std::int64_t r = 0x1234'5678'ABCD'EF01LL;
    FH_EXPECT_EQ(Fixed64::fromRaw(r).raw, r);
}

FH_TEST(fromFraction_examples) {
    // 1/20 for our 20 Hz tick
    const Fixed64 dt = Fixed64::fromFraction(1, 20);
    // In real terms 0.05, so raw = 0.05 * 2^32 = 214,748,364.8 → 214,748,364
    FH_EXPECT_EQ(dt.raw, Fixed64::ONE / 20);
    // 1/2 exact
    FH_EXPECT_EQ(Fixed64::fromFraction(1, 2).raw, Fixed64::ONE / 2);
    // 3/4 exact
    FH_EXPECT_EQ(Fixed64::fromFraction(3, 4).raw, (Fixed64::ONE * 3) / 4);
}

FH_TEST(constants_and_named) {
    FH_EXPECT_EQ(Fixed64::zero().raw, 0);
    FH_EXPECT_EQ(Fixed64::one().raw,  Fixed64::ONE);
    FH_EXPECT_EQ(Fixed64::halfConst().raw, Fixed64::ONE >> 1);
}

// -----------------------------------------------------------------------------
// Arithmetic
// -----------------------------------------------------------------------------
FH_TEST(add_sub_symmetry) {
    const Fixed64 a = Fixed64::fromInt(7);
    const Fixed64 b = Fixed64::fromInt(3);
    FH_EXPECT_EQ((a + b).raw, Fixed64::fromInt(10).raw);
    FH_EXPECT_EQ((a - b).raw, Fixed64::fromInt(4).raw);
    FH_EXPECT_EQ((-a).raw, Fixed64::fromInt(-7).raw);
    // Round-trip: (a + b) - b == a
    FH_EXPECT_EQ(((a + b) - b).raw, a.raw);
}

FH_TEST(mul_int_scalar) {
    // 3 * 4 == 12 as Fixed64
    FH_EXPECT_EQ((Fixed64::fromInt(3) * std::int32_t{4}).raw,
                 Fixed64::fromInt(12).raw);
    // -5 * 6 == -30
    FH_EXPECT_EQ((Fixed64::fromInt(-5) * std::int32_t{6}).raw,
                 Fixed64::fromInt(-30).raw);
}

FH_TEST(mul_fixed_fixed_integer_case) {
    // 3 * 4 via Fixed*Fixed
    FH_EXPECT_EQ((Fixed64::fromInt(3) * Fixed64::fromInt(4)).raw,
                 Fixed64::fromInt(12).raw);
    // -7 * 8
    FH_EXPECT_EQ((Fixed64::fromInt(-7) * Fixed64::fromInt(8)).raw,
                 Fixed64::fromInt(-56).raw);
}

FH_TEST(mul_by_zero) {
    FH_EXPECT_EQ((Fixed64::fromInt(999) * Fixed64::zero()).raw, 0);
    FH_EXPECT_EQ((Fixed64::zero() * Fixed64::fromInt(-42)).raw, 0);
}

FH_TEST(mul_by_one_identity) {
    const Fixed64 x = Fixed64::fromRaw(0x1234'5678'ABCD'EF00LL);
    FH_EXPECT_EQ((x * Fixed64::one()).raw, x.raw);
    FH_EXPECT_EQ((Fixed64::one() * x).raw, x.raw);
}

FH_TEST(mul_fractional) {
    // 0.5 * 0.5 = 0.25
    const Fixed64 half = Fixed64::halfConst();
    const Fixed64 quarter = Fixed64::fromFraction(1, 4);
    FH_EXPECT_EQ((half * half).raw, quarter.raw);

    // 0.1 * 10 ≈ 1 (may not be exact due to 0.1 not being representable)
    const Fixed64 tenth = Fixed64::fromFraction(1, 10);
    const Fixed64 ten   = Fixed64::fromInt(10);
    const Fixed64 res   = tenth * ten;
    // Should be within a few raw units of 1
    const std::int64_t diff = res.raw > Fixed64::ONE
        ? res.raw - Fixed64::ONE
        : Fixed64::ONE - res.raw;
    FH_EXPECT_LT(diff, 20);   // tight tolerance
}

FH_TEST(div_integer_case) {
    // 12 / 4 = 3
    FH_EXPECT_EQ((Fixed64::fromInt(12) / Fixed64::fromInt(4)).raw,
                 Fixed64::fromInt(3).raw);
    // 7 / 2 = 3.5
    FH_EXPECT_EQ((Fixed64::fromInt(7) / Fixed64::fromInt(2)).raw,
                 Fixed64::fromRaw(Fixed64::ONE * 3 + Fixed64::ONE / 2).raw);
    // Negative
    FH_EXPECT_EQ((Fixed64::fromInt(-15) / Fixed64::fromInt(3)).raw,
                 Fixed64::fromInt(-5).raw);
}

FH_TEST(div_reciprocal_identity) {
    // (a * b) / b ≈ a for reasonable magnitudes
    const Fixed64 a = Fixed64::fromInt(105);
    const Fixed64 b = Fixed64::fromFraction(3, 7);
    const Fixed64 r = (a * b) / b;
    const std::int64_t diff = r.raw > a.raw ? r.raw - a.raw : a.raw - r.raw;
    // 1 raw unit = 2.3e-10 units; tolerate a handful of raw ulps
    FH_EXPECT_LT(diff, 4);
}

FH_TEST(compound_ops) {
    Fixed64 x = Fixed64::fromInt(10);
    x += Fixed64::fromInt(5);
    FH_EXPECT_EQ(x.raw, Fixed64::fromInt(15).raw);
    x -= Fixed64::fromInt(3);
    FH_EXPECT_EQ(x.raw, Fixed64::fromInt(12).raw);
    x *= Fixed64::fromInt(2);
    FH_EXPECT_EQ(x.raw, Fixed64::fromInt(24).raw);
    x /= Fixed64::fromInt(4);
    FH_EXPECT_EQ(x.raw, Fixed64::fromInt(6).raw);
}

// -----------------------------------------------------------------------------
// Comparisons (spaceship-derived operators)
// -----------------------------------------------------------------------------
FH_TEST(comparisons_ordering) {
    const Fixed64 a = Fixed64::fromInt(3);
    const Fixed64 b = Fixed64::fromInt(5);
    const Fixed64 c = Fixed64::fromInt(5);
    FH_EXPECT(a <  b);
    FH_EXPECT(b >  a);
    FH_EXPECT(b <= c);
    FH_EXPECT(b >= c);
    FH_EXPECT(b == c);
    FH_EXPECT(a != b);
}

// -----------------------------------------------------------------------------
// Range & precision
// -----------------------------------------------------------------------------
FH_TEST(range_holds_pitch_dimensions) {
    // 105 m pitch length must round-trip exactly.
    const Fixed64 length = Fixed64::fromInt(105);
    const Fixed64 width  = Fixed64::fromInt(68);
    FH_EXPECT_EQ(length.raw, Fixed64::ONE * 105);
    FH_EXPECT_EQ(width.raw,  Fixed64::ONE * 68);
}

FH_TEST(precision_sub_nanometer_on_pitch) {
    // ULP is 2^-32 ≈ 2.33e-10 units. On a 105 m pitch, that's ~2.4e-8 mm.
    // Sanity: 105 m stored exactly, 1 raw off is imperceptible.
    const Fixed64 exact = Fixed64::fromInt(105);
    const Fixed64 nudged = Fixed64::fromRaw(exact.raw + 1);
    FH_EXPECT_NE(exact.raw, nudged.raw);
    // Their float representations should be identical (float can't resolve 1 ULP of Q32.32)
    FH_EXPECT(exact.toFloat() == nudged.toFloat());
}

// -----------------------------------------------------------------------------
// Free functions
// -----------------------------------------------------------------------------
FH_TEST(fx_abs) {
    using namespace fh::sim::math;
    FH_EXPECT_EQ(fx_abs(Fixed64::fromInt(5)).raw,  Fixed64::fromInt(5).raw);
    FH_EXPECT_EQ(fx_abs(Fixed64::fromInt(-5)).raw, Fixed64::fromInt(5).raw);
    FH_EXPECT_EQ(fx_abs(Fixed64::zero()).raw, 0);
}

FH_TEST(fx_min_max_clamp) {
    using namespace fh::sim::math;
    const Fixed64 a = Fixed64::fromInt(3);
    const Fixed64 b = Fixed64::fromInt(7);
    FH_EXPECT_EQ(fx_min(a, b).raw, a.raw);
    FH_EXPECT_EQ(fx_max(a, b).raw, b.raw);
    FH_EXPECT_EQ(fx_clamp(Fixed64::fromInt(5), a, b).raw, Fixed64::fromInt(5).raw);
    FH_EXPECT_EQ(fx_clamp(Fixed64::fromInt(-1), a, b).raw, a.raw);
    FH_EXPECT_EQ(fx_clamp(Fixed64::fromInt(99), a, b).raw, b.raw);
}

FH_TEST(fx_sign) {
    using namespace fh::sim::math;
    FH_EXPECT_EQ(fx_sign(Fixed64::fromInt(5)).raw,  Fixed64::one().raw);
    FH_EXPECT_EQ(fx_sign(Fixed64::fromInt(-5)).raw, (-Fixed64::one()).raw);
    FH_EXPECT_EQ(fx_sign(Fixed64::zero()).raw, 0);
}

// -----------------------------------------------------------------------------
// Boundary conversions
// -----------------------------------------------------------------------------
FH_TEST(fromFloat_toFloat_roundtrip_reasonable) {
    // Values that are exactly representable as float:
    for (float v : {0.0f, 1.0f, -1.0f, 0.5f, 1024.0f, -105.0f, 68.0f}) {
        const Fixed64 f = Fixed64::fromFloat(v);
        FH_EXPECT_EQ(f.toFloat(), v);
    }
}

FH_TEST(fromFloat_nan_yields_zero) {
    const float nan = std::numeric_limits<float>::quiet_NaN();
    FH_EXPECT_EQ(Fixed64::fromFloat(nan).raw, 0);
}

FH_TEST(fromFloat_saturates_on_overflow) {
    const Fixed64 big = Fixed64::fromFloat(1e20f);
    FH_EXPECT_EQ(big.raw, std::numeric_limits<std::int64_t>::max());
    const Fixed64 neg = Fixed64::fromFloat(-1e20f);
    FH_EXPECT_EQ(neg.raw, std::numeric_limits<std::int64_t>::min());
}

// -----------------------------------------------------------------------------
// Bit-exact determinism (spot check across identical inputs)
// -----------------------------------------------------------------------------
FH_TEST(bit_exact_multiplication_repeatable) {
    // Same operation, ten thousand times, must give same raw output.
    const Fixed64 a = Fixed64::fromFraction(31415926, 10000000);
    const Fixed64 b = Fixed64::fromFraction(27182818, 10000000);
    const Fixed64 expected = a * b;
    for (int i = 0; i < 10000; ++i) {
        FH_EXPECT_EQ((a * b).raw, expected.raw);
    }
}

FH_TEST_MAIN()
