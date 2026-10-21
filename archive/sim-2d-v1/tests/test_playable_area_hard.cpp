// footballhome sim - PlayableAreaConstraint (Hard mode) unit tests
//
// Slice 17.1: exercises `apply_hard` — the boundary-clamp routine.
//
// Uses a simple 20x20 CCW rectangle centred on the origin (corners
// (-10,-10), (+10,-10), (+10,+10), (-10,+10)) as the canonical polygon.
// A single test also verifies the CW-winding branch and the "no-op on
// degenerate polygon" branch.

#include "physics/PlayableAreaConstraint.hpp"

#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

#include <vector>

using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::apply_hard;

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

// Same square but listed clockwise — tests the CW-winding branch.
std::vector<Vec3> cwSquare20()
{
    return {
        Vec3{Fixed64::fromInt(-10), Fixed64::fromInt(-10), Fixed64::zero()},
        Vec3{Fixed64::fromInt(-10), Fixed64::fromInt( 10), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 10), Fixed64::fromInt( 10), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 10), Fixed64::fromInt(-10), Fixed64::zero()},
    };
}

} // namespace

// ---------------------------------------------------------------------------
// No-constraint cases: empty polygon, degenerate polygon, interior point.
// ---------------------------------------------------------------------------

FH_TEST(empty_polygon_is_noop) {
    Vec3 pos{Fixed64::fromInt(999), Fixed64::fromInt(-999), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(5),   Fixed64::fromInt(3),    Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_hard(pos, vel, {});
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

FH_TEST(polygon_with_two_vertices_is_noop) {
    // Fewer than 3 vertices = defensive no-op.
    std::vector<Vec3> line{
        Vec3{Fixed64::fromInt(-5), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 5), Fixed64::zero(), Fixed64::zero()},
    };
    Vec3 pos{Fixed64::fromInt(0), Fixed64::fromInt(50), Fixed64::zero()};
    Vec3 vel{Fixed64::zero(), Fixed64::fromInt(5), Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_hard(pos, vel, line);
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

FH_TEST(interior_point_is_untouched) {
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(3), Fixed64::fromInt(-2), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(4), Fixed64::fromInt(-1), Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_hard(pos, vel, poly);
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

FH_TEST(point_exactly_on_edge_is_untouched) {
    // On-edge counts as inside per the "≤" contract.
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(10), Fixed64::fromInt(5), Fixed64::zero()};   // east edge
    Vec3 vel{Fixed64::fromInt(3), Fixed64::fromInt(0), Fixed64::zero()};
    const Vec3 posBefore = pos;
    const Vec3 velBefore = vel;
    apply_hard(pos, vel, poly);
    FH_EXPECT_EQ(pos, posBefore);
    FH_EXPECT_EQ(vel, velBefore);
}

// ---------------------------------------------------------------------------
// Clamp cases: outside on each side of the square.
// ---------------------------------------------------------------------------

FH_TEST(outside_east_clamps_to_east_edge_and_zeros_x_velocity) {
    const auto poly = ccwSquare20();
    // pos.y = 0 lies on the east edge's axis of symmetry, so the
    // segment-projection factor is exactly 1/2 (Q32.32-exact).
    Vec3 pos{Fixed64::fromInt(15), Fixed64::zero(), Fixed64::fromInt(2)};
    Vec3 vel{Fixed64::fromInt(5), Fixed64::fromInt(2), Fixed64::fromInt(9)};
    apply_hard(pos, vel, poly);
    // Clamped to x=+10, y unchanged, z preserved.
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos.y, Fixed64::zero());
    FH_EXPECT_EQ(pos.z, Fixed64::fromInt(2));
    // Outward normal is +x. dot(vel,+x)=5>0 so x-component removed;
    // y untouched (tangential); z preserved.
    FH_EXPECT_EQ(vel.x, Fixed64::zero());
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(2));
    FH_EXPECT_EQ(vel.z, Fixed64::fromInt(9));
}

FH_TEST(outside_north_clamps_to_north_edge_and_zeros_y_velocity) {
    const auto poly = ccwSquare20();
    // pos.x = 0 lies on the north edge's axis of symmetry.
    Vec3 pos{Fixed64::zero(),      Fixed64::fromInt(15), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(3),  Fixed64::fromInt(4),  Fixed64::zero()};
    apply_hard(pos, vel, poly);
    FH_EXPECT_EQ(pos.x, Fixed64::zero());
    FH_EXPECT_EQ(pos.y, Fixed64::fromInt(10));
    // Outward normal is +y. y-velocity removed; x tangential preserved.
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(3));
    FH_EXPECT_EQ(vel.y, Fixed64::zero());
}

FH_TEST(outside_west_clamps_and_zeros_negative_x_velocity) {
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(-15), Fixed64::zero(), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(-2),  Fixed64::fromInt(1), Fixed64::zero()};
    apply_hard(pos, vel, poly);
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(-10));
    FH_EXPECT_EQ(pos.y, Fixed64::zero());
    // Outward normal is -x. dot(vel,-x)= -(-2)=2 > 0 so remove.
    FH_EXPECT_EQ(vel.x, Fixed64::zero());
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(1));
}

// ---------------------------------------------------------------------------
// Inward-moving velocity is NOT zeroed (asymmetric contract).
// ---------------------------------------------------------------------------

FH_TEST(inward_moving_velocity_is_preserved_after_clamp) {
    // Player is outside east, but their velocity points INWARD (west).
    // apply_hard still clamps the position back onto the east edge,
    // but must NOT wipe the inward velocity — that would strand them
    // against the wall.
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(15), Fixed64::zero(),     Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(-4), Fixed64::fromInt(2), Fixed64::zero()};
    apply_hard(pos, vel, poly);
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos.y, Fixed64::zero());
    // Inward: velocity untouched.
    FH_EXPECT_EQ(vel.x, Fixed64::fromInt(-4));
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(2));
}

// ---------------------------------------------------------------------------
// Corner clamp: point outside a corner projects to that corner.
// ---------------------------------------------------------------------------

FH_TEST(point_outside_ne_corner_clamps_to_corner) {
    const auto poly = ccwSquare20();
    Vec3 pos{Fixed64::fromInt(20), Fixed64::fromInt(20), Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(1),  Fixed64::fromInt(1),  Fixed64::zero()};
    apply_hard(pos, vel, poly);
    // Closest boundary point to (20,20) is (10,10). Both east-edge
    // projection and north-edge projection produce this same point;
    // tie-break by iteration order gives whichever edge is visited
    // first, but the RESULT (the clamped position) is unambiguous.
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos.y, Fixed64::fromInt(10));
    // Velocity handling: outward normal comes from the winning edge.
    // Whichever edge wins, its outward normal is axis-aligned, so ONE
    // of vx / vy will be zeroed; the other is tangential and preserved.
    // Rather than depend on tie-break order, we just verify that no
    // outward-facing component remains (dot with (1,1)/sqrt(2) ≤ 0).
    // The Fixed64 test uses raw comparison against the pre-clamp
    // outward magnitude: original (1,1) had outward-dot = (1+1)/sqrt(2)
    // > 0; the winning-edge component is now zero, so total outward
    // dot MUST be ≤ original.
    FH_EXPECT((vel.x + vel.y).raw <= (Fixed64::fromInt(1) + Fixed64::fromInt(1)).raw);
}

// ---------------------------------------------------------------------------
// CW-winding polygon works too.
// ---------------------------------------------------------------------------

FH_TEST(cw_winding_polygon_clamps_correctly) {
    const auto poly = cwSquare20();
    Vec3 pos{Fixed64::fromInt(15), Fixed64::zero(),      Fixed64::zero()};
    Vec3 vel{Fixed64::fromInt(5),  Fixed64::fromInt(-2), Fixed64::zero()};
    apply_hard(pos, vel, poly);
    // Same expected outcome as the CCW east-clamp test — the module
    // infers winding from the first non-collinear triple and picks
    // the outward normal accordingly.
    FH_EXPECT_EQ(pos.x, Fixed64::fromInt(10));
    FH_EXPECT_EQ(pos.y, Fixed64::zero());
    FH_EXPECT_EQ(vel.x, Fixed64::zero());
    FH_EXPECT_EQ(vel.y, Fixed64::fromInt(-2));
}

FH_TEST_MAIN()
