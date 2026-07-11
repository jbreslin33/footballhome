// sim/tests/test_vec3.cpp
//
// Vec2/Vec3 arithmetic + geometry helpers.

#include "test_harness.hpp"
#include "math/Vec3.hpp"

using fh::sim::math::Fixed64;
using fh::sim::math::Vec2;
using fh::sim::math::Vec3;

// Tolerance helper
static bool close_raw(Fixed64 a, Fixed64 b, std::int64_t max_ulps) {
    const std::int64_t d = a.raw > b.raw ? a.raw - b.raw : b.raw - a.raw;
    return d <= max_ulps;
}

FH_TEST(vec2_arithmetic) {
    const Vec2 a{Fixed64::fromInt(3), Fixed64::fromInt(4)};
    const Vec2 b{Fixed64::fromInt(1), Fixed64::fromInt(2)};
    FH_EXPECT_EQ((a + b).x.raw, Fixed64::fromInt(4).raw);
    FH_EXPECT_EQ((a + b).y.raw, Fixed64::fromInt(6).raw);
    FH_EXPECT_EQ((a - b).x.raw, Fixed64::fromInt(2).raw);
    FH_EXPECT_EQ((a - b).y.raw, Fixed64::fromInt(2).raw);
}

FH_TEST(vec3_arithmetic) {
    const Vec3 a{Fixed64::fromInt(1), Fixed64::fromInt(2), Fixed64::fromInt(3)};
    const Vec3 b{Fixed64::fromInt(4), Fixed64::fromInt(5), Fixed64::fromInt(6)};
    FH_EXPECT_EQ((a + b).x.raw, Fixed64::fromInt(5).raw);
    FH_EXPECT_EQ((a + b).y.raw, Fixed64::fromInt(7).raw);
    FH_EXPECT_EQ((a + b).z.raw, Fixed64::fromInt(9).raw);
}

FH_TEST(vec2_dot) {
    const Vec2 a{Fixed64::fromInt(3), Fixed64::fromInt(4)};
    const Vec2 b{Fixed64::fromInt(2), Fixed64::fromInt(1)};
    FH_EXPECT_EQ(dot(a, b).raw, Fixed64::fromInt(10).raw);   // 3*2 + 4*1 = 10
}

FH_TEST(vec3_dot) {
    const Vec3 a{Fixed64::fromInt(1), Fixed64::fromInt(2), Fixed64::fromInt(3)};
    const Vec3 b{Fixed64::fromInt(4), Fixed64::fromInt(5), Fixed64::fromInt(6)};
    // 1*4 + 2*5 + 3*6 = 32
    FH_EXPECT_EQ(dot(a, b).raw, Fixed64::fromInt(32).raw);
}

FH_TEST(vec2_length_3_4_5) {
    const Vec2 v{Fixed64::fromInt(3), Fixed64::fromInt(4)};
    FH_EXPECT(close_raw(length(v), Fixed64::fromInt(5), 100));
}

FH_TEST(vec2_length_squared) {
    const Vec2 v{Fixed64::fromInt(3), Fixed64::fromInt(4)};
    FH_EXPECT_EQ(lengthSquared(v).raw, Fixed64::fromInt(25).raw);
}

FH_TEST(vec2_normalize_unit_length) {
    const Vec2 v{Fixed64::fromInt(3), Fixed64::fromInt(4)};
    const Vec2 n = normalized(v);
    // |n| should be ~1
    FH_EXPECT(close_raw(length(n), Fixed64::one(), 10000));
    // Direction preserved: n.x / n.y == v.x / v.y == 3/4
    // Check with cross-product: n.x * v.y - n.y * v.x ≈ 0
    const Fixed64 cross = n.x * v.y - n.y * v.x;
    FH_EXPECT(close_raw(cross, Fixed64::zero(), 10000));
}

FH_TEST(vec2_normalize_zero_is_zero) {
    const Vec2 z{};
    const Vec2 n = normalized(z);
    FH_EXPECT_EQ(n.x.raw, 0);
    FH_EXPECT_EQ(n.y.raw, 0);
}

FH_TEST(vec3_normalize_zero_is_zero) {
    const Vec3 z{};
    const Vec3 n = normalized(z);
    FH_EXPECT_EQ(n.x.raw, 0);
    FH_EXPECT_EQ(n.y.raw, 0);
    FH_EXPECT_EQ(n.z.raw, 0);
}

FH_TEST(vec3_length_1_2_2_is_3) {
    // 1² + 2² + 2² = 9 → length 3
    const Vec3 v{Fixed64::fromInt(1), Fixed64::fromInt(2), Fixed64::fromInt(2)};
    FH_EXPECT(close_raw(length(v), Fixed64::fromInt(3), 100));
}

FH_TEST_MAIN()
