// footballhome sim - BallOnPitchWithDefenderScenario tests

#include "common/Role.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "scenario/BallOnPitchWithDefenderScenario.hpp"
#include "scenario/Scenario.hpp"
#include "test_harness.hpp"

using fh::sim::Role;
using fh::sim::SlotId;
using fh::sim::math::FX_PI;
using fh::sim::math::Fixed64;
using fh::sim::scenario::BallOnPitchWithDefenderScenario;
using fh::sim::scenario::UnclaimedControllerKind;

FH_TEST(spawns_human_slot_and_lcb_defender_slot)
{
    BallOnPitchWithDefenderScenario s;
    const auto spawns = s.initialSpawns();
    FH_EXPECT_EQ(spawns.size(), 2u);

    FH_EXPECT(spawns[0].slot == SlotId{1});
    FH_EXPECT_EQ(spawns[0].position.x, Fixed64::fromInt(-5));
    FH_EXPECT_EQ(spawns[0].heading, Fixed64::zero());
    FH_EXPECT(spawns[0].role == Role::Any);

    FH_EXPECT(spawns[1].slot == SlotId{2});
    FH_EXPECT_EQ(spawns[1].position.x, Fixed64::fromInt(5));
    FH_EXPECT_EQ(spawns[1].heading, FX_PI);
    FH_EXPECT(spawns[1].role == Role::LCB);
}

FH_TEST(slot_two_uses_defender_policy_and_slot_one_idles)
{
    BallOnPitchWithDefenderScenario s;
    FH_EXPECT(s.unclaimedControllerFor(SlotId{1}) == UnclaimedControllerKind::Idle);
    FH_EXPECT(s.unclaimedControllerFor(SlotId{2}) == UnclaimedControllerKind::Defender);
}

FH_TEST_MAIN()