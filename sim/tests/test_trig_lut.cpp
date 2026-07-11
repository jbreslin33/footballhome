// sim/tests/test_trig_lut.cpp
//
// Verify that the LUT tables have the expected structural properties.
// (Deep correctness lives in test_fixed_math.cpp.)

#include "test_harness.hpp"
#include "math/TrigLUT.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"

using fh::sim::math::Fixed64;

FH_TEST(sin_table_endpoints) {
    const std::int64_t* tbl = fh::sim::math::detail::sin_table();
    // sin(0) == 0 exactly
    FH_EXPECT_EQ(tbl[0], 0);
    // Peak at index N/4 should be near ONE
    const std::int64_t peak = tbl[fh::sim::math::SIN_LUT_SIZE / 4];
    // Within a handful of ULPs of Fixed64::ONE (round-to-nearest of exact 1.0)
    FH_EXPECT(peak >= Fixed64::ONE - 4);
    FH_EXPECT(peak <= Fixed64::ONE + 4);
    // Trough at index 3N/4 should be near -ONE
    const std::int64_t trough = tbl[3 * fh::sim::math::SIN_LUT_SIZE / 4];
    FH_EXPECT(trough <= -(Fixed64::ONE - 4));
    FH_EXPECT(trough >= -(Fixed64::ONE + 4));
}

FH_TEST(atan_table_endpoints) {
    const std::int64_t* tbl = fh::sim::math::detail::atan_table();
    // atan(0) == 0
    FH_EXPECT_EQ(tbl[0], 0);
    // atan(1) == π/4 ≈ 3373259426 raw
    const std::int64_t last = tbl[fh::sim::math::ATAN_LUT_SIZE - 1];
    // Compare against our FX_QUARTER_PI constant.
    const std::int64_t pi4 = fh::sim::math::FX_QUARTER_PI.raw;
    FH_EXPECT(last >= pi4 - 4);
    FH_EXPECT(last <= pi4 + 4);
}

FH_TEST(sin_table_monotone_first_quarter) {
    const std::int64_t* tbl = fh::sim::math::detail::sin_table();
    const int N4 = fh::sim::math::SIN_LUT_SIZE / 4;
    for (int i = 1; i <= N4; ++i) {
        FH_EXPECT(tbl[i] >= tbl[i - 1]);
    }
}

FH_TEST(atan_table_monotone) {
    const std::int64_t* tbl = fh::sim::math::detail::atan_table();
    for (int i = 1; i < fh::sim::math::ATAN_LUT_SIZE; ++i) {
        FH_EXPECT(tbl[i] >= tbl[i - 1]);
    }
}

FH_TEST_MAIN()
