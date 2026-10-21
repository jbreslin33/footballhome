// game/tests/test_formation_store.cpp
//
// The pure club→game coordinate mapping (DB access itself is exercised by
// the live boot, which logs loudly and falls back — see main.cpp).

#include "test_harness.hpp"
#include "persistence/FormationStore.hpp"

using fh::game::math::Fixed64;
using fh::game::persistence::mapClubPosition;

FH_TEST(gk_maps_to_goal_line_centre) {
    // Club GK: x=50 (centre), y=5 (own goal line area).
    const auto p = mapClubPosition(50, 5, true);
    FH_EXPECT_EQ(p.base.x.raw, Fixed64::fromFraction(-95, 100).raw);
    FH_EXPECT_EQ(p.base.y.raw, 0);
    FH_EXPECT(p.keeper);
}

FH_TEST(striker_maps_high_and_centre) {
    // Club 4-4-2 ST: x=60, y=68.
    const auto p = mapClubPosition(60, 68, false);
    FH_EXPECT_EQ(p.base.x.raw, Fixed64::fromFraction(-32, 100).raw);
    FH_EXPECT_EQ(p.base.y.raw, Fixed64::fromFraction(10, 50).raw);
    FH_EXPECT(!p.keeper);
}

FH_TEST(fullbacks_map_to_opposite_wings) {
    const auto rb = mapClubPosition(85, 22, false);
    const auto lb = mapClubPosition(15, 22, false);
    FH_EXPECT_EQ(rb.base.x.raw, lb.base.x.raw);
    FH_EXPECT_EQ(rb.base.y.raw, (-lb.base.y).raw);
    FH_EXPECT(rb.base.y > Fixed64::zero());
}

FH_TEST_MAIN()
