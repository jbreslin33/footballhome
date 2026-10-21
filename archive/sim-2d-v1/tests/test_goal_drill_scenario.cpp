// footballhome sim - GoalDrillScenario tests (Slice 28.2)
//
// Verifies:
//   * Base Scenario::goalRegions() defaults to empty (grandfathers every
//     pre-28 scenario at zero cost — critical contract).
//   * GoalDrillScenario exposes exactly two goal regions with the
//     documented geometry (west at index 0, east at index 1).
//   * Ball spawns at centre, both slot spawns 15 m from centre facing
//     the far goal, unclaimed policy is Idle (parity with 2v0).
//   * The AABBs' min/max are ordered (min <= max componentwise).
//   * Regions do not overlap.

#include "scenario/GoalDrillScenario.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "awareness/AwarenessView.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <string>

using fh::sim::SlotId;
using fh::sim::awareness::WorldView;
using fh::sim::math::Fixed64;
using fh::sim::scenario::EmptyPitchScenario;
using fh::sim::scenario::GoalDrillScenario;

// ─────────────────────────────────────────────────────────────────────
// Base-class default: any scenario that does NOT override goalRegions()
// must return an empty vector. This is the Slice 28.2 grandfather
// clause — Match::tick's goal-detection loop (Slice 28.3) will be a
// no-op on pre-28 scenarios. Regressions here would cause phantom
// Goal events in every existing scenario.
// ─────────────────────────────────────────────────────────────────────
FH_TEST(base_scenario_goal_regions_defaults_to_empty) {
    EmptyPitchScenario s;
    FH_EXPECT_EQ(s.goalRegions().size(), 0u);
}

FH_TEST(id_and_display_name) {
    GoalDrillScenario s;
    FH_EXPECT_EQ(std::string(s.id()),          std::string("goal_drill"));
    FH_EXPECT_EQ(std::string(s.displayName()), std::string("Goal Drill"));
}

FH_TEST(pitch_is_regulation) {
    GoalDrillScenario s;
    const auto p = s.pitch();
    FH_EXPECT_EQ(p.length_m, Fixed64::fromInt(105));
    FH_EXPECT_EQ(p.width_m,  Fixed64::fromInt(68));
}

FH_TEST(ball_at_centre_spot_at_rest) {
    GoalDrillScenario s;
    const auto b = s.ballSpawn();
    FH_EXPECT(b.has_value());
    FH_EXPECT_EQ(b->position.x, Fixed64::zero());
    FH_EXPECT_EQ(b->position.y, Fixed64::zero());
    FH_EXPECT_EQ(b->position.z, Fixed64::zero());
    FH_EXPECT_EQ(b->velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(b->velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(b->velocity.z, Fixed64::zero());
}

FH_TEST(two_slots_at_plus_minus_15m) {
    GoalDrillScenario s;
    const auto spawns = s.initialSpawns();
    FH_EXPECT_EQ(spawns.size(), 2u);

    // Slot 1 spawns 15 m west facing east.
    FH_EXPECT_EQ(spawns[0].slot, SlotId{1});
    FH_EXPECT_EQ(spawns[0].position.x, Fixed64::fromInt(-15));
    FH_EXPECT_EQ(spawns[0].position.y, Fixed64::zero());
    FH_EXPECT_EQ(spawns[0].heading,    Fixed64::zero());

    // Slot 2 spawns 15 m east facing west (π radians).
    FH_EXPECT_EQ(spawns[1].slot, SlotId{2});
    FH_EXPECT_EQ(spawns[1].position.x, Fixed64::fromInt(15));
    FH_EXPECT_EQ(spawns[1].position.y, Fixed64::zero());
    FH_EXPECT_EQ(spawns[1].heading,    fh::sim::math::FX_PI);
}

FH_TEST(unclaimed_slots_idle_matches_2v0) {
    GoalDrillScenario s;
    FH_EXPECT(s.unclaimedSlotsIdle());
}

// ─────────────────────────────────────────────────────────────────────
// Goal geometry.
//
//   half_length     = 105 / 2 = 52.5 m
//   goal_depth      = 2 m           (extends behind the goal line)
//   goal_half_width = 7.32 / 2 = 3.66 m   (FIFA regulation goal)
//   goal_height     = 2.44 m        (FIFA regulation crossbar)
//
//   West goal (index 0): x ∈ [-54.5, -52.5], y ∈ [-3.66, 3.66], z ∈ [0, 2.44]
//   East goal (index 1): x ∈ [+52.5, +54.5], y ∈ [-3.66, 3.66], z ∈ [0, 2.44]
//
// The `index` field is written verbatim into the Goal payload's
// goal_region_index byte (ADR §22.25 v1 offset 1) — MUST equal the
// region's position in the returned vector.
// ─────────────────────────────────────────────────────────────────────
FH_TEST(exposes_two_goal_regions) {
    GoalDrillScenario s;
    const auto regions = s.goalRegions();
    FH_EXPECT_EQ(regions.size(), 2u);
    FH_EXPECT_EQ(regions[0].index, std::uint8_t{0});
    FH_EXPECT_EQ(regions[1].index, std::uint8_t{1});
}

FH_TEST(west_goal_aabb_matches_spec) {
    GoalDrillScenario s;
    const auto regions = s.goalRegions();
    FH_EXPECT_EQ(regions.size(), 2u);
    const auto& west = regions[0];

    const auto half_length     = Fixed64::fromFraction(105, 2);   // 52.5
    const auto goal_depth      = Fixed64::fromInt(2);
    const auto goal_half_width = Fixed64::fromFraction(732, 200); // 3.66
    const auto goal_height     = Fixed64::fromFraction(244, 100); // 2.44

    FH_EXPECT_EQ(west.min.x, Fixed64::zero() - half_length - goal_depth);
    FH_EXPECT_EQ(west.max.x, Fixed64::zero() - half_length);
    FH_EXPECT_EQ(west.min.y, Fixed64::zero() - goal_half_width);
    FH_EXPECT_EQ(west.max.y, goal_half_width);
    FH_EXPECT_EQ(west.min.z, Fixed64::zero());
    FH_EXPECT_EQ(west.max.z, goal_height);
}

FH_TEST(east_goal_aabb_matches_spec) {
    GoalDrillScenario s;
    const auto regions = s.goalRegions();
    FH_EXPECT_EQ(regions.size(), 2u);
    const auto& east = regions[1];

    const auto half_length     = Fixed64::fromFraction(105, 2);   // 52.5
    const auto goal_depth      = Fixed64::fromInt(2);
    const auto goal_half_width = Fixed64::fromFraction(732, 200); // 3.66
    const auto goal_height     = Fixed64::fromFraction(244, 100); // 2.44

    FH_EXPECT_EQ(east.min.x, half_length);
    FH_EXPECT_EQ(east.max.x, half_length + goal_depth);
    FH_EXPECT_EQ(east.min.y, Fixed64::zero() - goal_half_width);
    FH_EXPECT_EQ(east.max.y, goal_half_width);
    FH_EXPECT_EQ(east.min.z, Fixed64::zero());
    FH_EXPECT_EQ(east.max.z, goal_height);
}

FH_TEST(goal_regions_are_well_ordered_aabbs) {
    GoalDrillScenario s;
    for (const auto& r : s.goalRegions()) {
        FH_EXPECT_LE(r.min.x, r.max.x);
        FH_EXPECT_LE(r.min.y, r.max.y);
        FH_EXPECT_LE(r.min.z, r.max.z);
    }
}

FH_TEST(goal_regions_do_not_overlap_on_x) {
    // West.max.x = -52.5; East.min.x = +52.5. Gap = 105 m (whole pitch).
    GoalDrillScenario s;
    const auto regions = s.goalRegions();
    FH_EXPECT_EQ(regions.size(), 2u);
    FH_EXPECT_LT(regions[0].max.x, regions[1].min.x);
}

FH_TEST(success_and_reset_are_false_in_slice_28_2) {
    // Slice 28.3 will flip these; 28.2 lands geometry only.
    GoalDrillScenario s;
    WorldView w;
    FH_EXPECT(!s.checkSuccess(w));
    FH_EXPECT(!s.checkReset(w));
}

FH_TEST_MAIN()
