// footballhome sim - PlayableAreaConstraint (Soft mode) unit tests
//
// Slice 17.2: exercises `apply_soft` — the inward-spring boundary.
//
// Uses the same 20x20 CCW rectangle centred on the origin as the Hard
// tests. `k` is chosen so `penetration_depth * k` produces exact
// Fixed64-representable velocity deltas.

#include "physics/PlayableAreaConstraint.hpp"

#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

#include <vector>

using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::apply_soft;

namespace {

// CCW 20x20 square centred on origin. Interior is x,y ∈ [-10, +10].
std::vector<Vec3> ccwSquare20()
{
    return {
        Vec3{Fixed64::fromInt(-10), Fixed64::fromInt(-10), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 10), Fixed64::fromInt(-10), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 10), Fixed64::fromInt( 10), Fixed64::zero()},
        Vec3{Fixed64::fromInt(-10), Fixed64::fromInt( 10), Fixed64::zero()},
    };
}

} // namespace

// ---------------------------------------------------------------------------
// No-op cases: empty polygon, interior point, exactly on edge.
// ---------------------------------------------------------------------------

FH_TEST(soft_empty_polygon_is_noop) {
    Vec3 pos{Fixed64::fromInt(999), Fixed64::fromInt(-999), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(5),   Fixed64::fromInt(3),    Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_soft(pos, vel, {}, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

FH_TEST(soft_interior_point_is_untouched) {
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(3), Fixed64::fromInt(-2), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(4), Fixed64::fromInt(-1), Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_soft(pos, vel, poly, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

FH_TEST(soft_on_edge_is_untouched) {
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(10), Fixed64::zero(), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(3),  Fixed64::zero(), Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_soft(pos, vel, poly, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

// ---------------------------------------------------------------------------
// Force magnitude = k × penetration_depth, applied INWARD.
// Position is unchanged (soft mode explicitly does not clamp).
// ---------------------------------------------------------------------------

FH_TEST(soft_outside_east_applies_inward_x_velocity_delta) {
    const auto poly = ccwSquare20();
    // 5 m east of the east edge. Outward normal is +x.
    Vec3 pos{Fixed64::fromInt(15), Fixed64::zero(), Fixed64::fromInt(7)};
    Vec3 vel{Fixed64::fromInt(2),  Fixed64::fromInt(3), Fixed64::fromInt(9)};
    apply_soft(pos, vel, poly, Fixed64::fromInt(4));
    // Position UNCHANGED (soft mode).
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(15));
    FH_EXPECT_EQ(pos.y, Fixed64::zero());
    FH_EXPECT_EQ(pos.z, Fixed64::fromInt(7));
    // penetration = 5, k = 4 → magnitude = 20 applied inward (-x).
    //   vel.x: 2 - 20 = -18
    //   vel.y: 3 (tangential — unaffected)
    //   vel.z: 9 (z preserved)
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(-18));
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(3));
    FH_EXPECT_EQ(vel.z, Fixed64::fromInt(9));
}

FH_TEST(soft_outside_north_applies_inward_y_velocity_delta) {
    const auto poly = ccwSquare20();
    // 3 m north of the north edge.
    Vec3 pos{Fixed64::zero(), Fixed64::fromInt(13), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(1), Fixed64::fromInt(5), Fixed64::zero()};
    apply_soft(pos, vel, poly, Fixed64::fromInt(2));
    // Position UNCHANGED.
    FH_EXPECT_EQ(pos.x, Fixed64::zero());
    FH_EXPECT_EQ(pos.y, Fixed64::fromInt(13));
    // penetration = 3, k = 2 → magnitude = 6 applied inward (-y).
    //   vel.x: 1 (tangential)
    //   vel.y: 5 - 6 = -1
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(-1));
}

FH_TEST(soft_outside_west_applies_inward_x_velocity_delta) {
    const auto poly = ccwSquare20();
    // 2 m west of the west edge.
    Vec3 pos{Fixed64::fromInt(-12), Fixed64::zero(), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(0),   Fixed64::fromInt(2), Fixed64::zero()};
    apply_soft(pos, vel, poly, Fixed64::fromInt(3));
    // penetration = 2, k = 3 → magnitude = 6 inward (+x).
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(-12));    // unchanged
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(6));      // 0 + 6
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(2));      // tangential
}

// ---------------------------------------------------------------------------
// Delta ADDS to existing velocity (does not overwrite it).
// ---------------------------------------------------------------------------

FH_TEST(soft_delta_adds_to_existing_outward_velocity) {
    const auto poly = ccwSquare20();
    // Outside east, moving OUTWARD (east). apply_soft only ADDS an
    // inward delta — it does not zero the existing outward component
    // (that's Hard-mode behavior).
    Vec3 pos{Fixed64::fromInt(14), Fixed64::zero(), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(5),  Fixed64::zero(), Fixed64::zero()};
    apply_soft(pos, vel, poly, Fixed64::fromInt(1));
    // penetration = 4, k = 1 → magnitude = 4 inward (-x).
    //   vel.x: 5 - 4 = 1 (still moving outward, but decelerated)
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(1));
}

FH_TEST(soft_delta_stacks_with_existing_inward_velocity) {
    const auto poly = ccwSquare20();
    // Outside east, already moving INWARD (west). Delta is also
    // inward, so vel.x becomes more negative.
    Vec3 pos{Fixed64::fromInt(14), Fixed64::zero(), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(-2), Fixed64::zero(), Fixed64::zero()};
    apply_soft(pos, vel, poly, Fixed64::fromInt(1));
    // penetration = 4, k = 1 → magnitude = 4 inward.
    //   vel.x: -2 - 4 = -6
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(-6));
}

// ---------------------------------------------------------------------------
// k = 0 → delta = 0 (module is effectively disabled).
// ---------------------------------------------------------------------------

FH_TEST(soft_k_zero_produces_no_velocity_delta) {
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(15), Fixed64::zero(), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(3),  Fixed64::fromInt(2), Fixed64::zero()};
    const Vec3 velBefore = vel;
    apply_soft(pos, vel, poly, Fixed64::zero());
    // Position still unchanged (soft mode never clamps).
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(15));
    // Velocity unchanged too because delta magnitude = 5 × 0 = 0.
    FH_EXPECT_EQ(vel, velBefore);
}

FH_TEST_MAIN()
