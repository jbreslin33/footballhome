// footballhome sim - OneVsOneAttackDefendScenario tests (Slice 34.1)

#include "awareness/AwarenessView.hpp"
#include "common/EntityState.hpp"
#include "common/IdTypes.hpp"
#include "common/M0Registry.generated.hpp"
#include "common/Role.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "scenario/OneVsOneAttackDefendScenario.hpp"
#include "scenario/Scenario.hpp"
#include "test_harness.hpp"

#include <optional>
#include <string>

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::PersonId;
using fh::sim::Role;
using fh::sim::SlotId;
using fh::sim::awareness::WorldView;
using fh::sim::math::FX_PI;
using fh::sim::math::Fixed64;
using fh::sim::scenario::OneVsOneAttackDefendScenario;
using fh::sim::scenario::UnclaimedControllerKind;

namespace {

WorldView worldWithBallAt(const fh::sim::math::Vec3& ball_position,
                          Fixed64 time_seconds = Fixed64::zero())
{
    WorldView w;
    w.tick = 1;
    w.time_seconds = time_seconds;
    w.ball = EntityId{99};

    EntityState ball;
    ball.id = EntityId{99};
    ball.position = ball_position;
    ball.motion = MotionState::Idle;
    w.entities.push_back(ball);

    return w;
}

} // namespace

FH_TEST(id_and_display_name)
{
    OneVsOneAttackDefendScenario s;
    FH_EXPECT_EQ(std::string(s.id()), std::string("one_v_one_attack_defend"));
    FH_EXPECT_EQ(std::string(s.displayName()), std::string("1v1 Attack vs Defend"));
}

FH_TEST(spawns_attacker_on_ball_and_defender_between_attacker_and_goal)
{
    OneVsOneAttackDefendScenario s{PersonId{42}};
    const auto spawns = s.initialSpawns();
    FH_EXPECT_EQ(spawns.size(), 2u);

    FH_EXPECT(spawns[0].slot == SlotId{1});
    FH_EXPECT_EQ(spawns[0].position.x, Fixed64::fromInt(-15));
    FH_EXPECT_EQ(spawns[0].position.y, Fixed64::zero());
    FH_EXPECT_EQ(spawns[0].heading, Fixed64::zero());
    FH_EXPECT(spawns[0].role == Role::ST9);
    FH_EXPECT(!spawns[0].ai_profile_source.has_value());

    FH_EXPECT(spawns[1].slot == SlotId{2});
    FH_EXPECT_EQ(spawns[1].position.x, Fixed64::fromInt(10));
    FH_EXPECT_EQ(spawns[1].position.y, Fixed64::zero());
    FH_EXPECT_EQ(spawns[1].heading, FX_PI);
    FH_EXPECT(spawns[1].role == Role::LCB);
    FH_EXPECT(spawns[1].ai_profile_source.has_value());
    FH_EXPECT_EQ(*spawns[1].ai_profile_source, PersonId{42});
    FH_EXPECT(spawns[1].mark_target.has_value());
    FH_EXPECT_EQ(*spawns[1].mark_target, SlotId{1});
}

FH_TEST(ball_starts_glued_to_attacker_spawn)
{
    OneVsOneAttackDefendScenario s;
    const auto ball = s.ballSpawn();
    FH_EXPECT(ball.has_value());
    FH_EXPECT_EQ(ball->position.x, Fixed64::fromInt(-15));
    FH_EXPECT_EQ(ball->position.y, Fixed64::zero());
    FH_EXPECT_EQ(ball->velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(ball->velocity.y, Fixed64::zero());
}

FH_TEST(controller_policy_keeps_attacker_claimable_and_defender_ai)
{
    OneVsOneAttackDefendScenario s;
    FH_EXPECT(s.unclaimedControllerFor(SlotId{1}) == UnclaimedControllerKind::Idle);
    FH_EXPECT(s.unclaimedControllerFor(SlotId{2}) == UnclaimedControllerKind::Defender);
}

FH_TEST(defender_concepts_are_plugged)
{
    OneVsOneAttackDefendScenario s;
    fh::sim::profile::ConceptSet attacker;
    fh::sim::profile::ConceptSet defender;
    s.applyConceptOverrides(SlotId{1}, attacker);
    s.applyConceptOverrides(SlotId{2}, defender);

    FH_EXPECT(!attacker.has(fh::sim::m0::kPressing, Fixed64::zero()));
    FH_EXPECT(defender.has(fh::sim::m0::kPressing, Fixed64::zero()));
    FH_EXPECT(defender.has(fh::sim::m0::kJockey, Fixed64::zero()));
    FH_EXPECT(defender.has(fh::sim::m0::kMarking, Fixed64::zero()));
}

FH_TEST(goal_regions_match_goal_drill_geometry)
{
    OneVsOneAttackDefendScenario s;
    const auto regions = s.goalRegions();
    FH_EXPECT_EQ(regions.size(), 2u);
    FH_EXPECT_EQ(regions[0].index, std::uint8_t{0});
    FH_EXPECT_EQ(regions[1].index, std::uint8_t{1});

    const auto half_length = Fixed64::fromFraction(105, 2);
    const auto goal_depth = Fixed64::fromInt(2);
    const auto goal_half_width = Fixed64::fromFraction(732, 200);
    const auto goal_height = Fixed64::fromFraction(244, 100);

    FH_EXPECT_EQ(regions[1].min.x, half_length);
    FH_EXPECT_EQ(regions[1].max.x, half_length + goal_depth);
    FH_EXPECT_EQ(regions[1].min.y, Fixed64::zero() - goal_half_width);
    FH_EXPECT_EQ(regions[1].max.y, goal_half_width);
    FH_EXPECT_EQ(regions[1].min.z, Fixed64::zero());
    FH_EXPECT_EQ(regions[1].max.z, goal_height);
}

FH_TEST(success_when_ball_enters_east_goal)
{
    OneVsOneAttackDefendScenario s;
    const auto w = worldWithBallAt(
        fh::sim::math::Vec3{Fixed64::fromInt(53),
                            Fixed64::zero(),
                            Fixed64::zero()});
    FH_EXPECT(s.checkSuccess(w));
}

FH_TEST(no_success_when_ball_is_outside_east_goal)
{
    OneVsOneAttackDefendScenario s;
    const auto w = worldWithBallAt(
        fh::sim::math::Vec3{Fixed64::zero(),
                            Fixed64::zero(),
                            Fixed64::zero()});
    FH_EXPECT(!s.checkSuccess(w));
}

FH_TEST(resets_at_twenty_seconds)
{
    OneVsOneAttackDefendScenario s;
    FH_EXPECT(!s.checkReset(worldWithBallAt(
        fh::sim::math::Vec3{}, Fixed64::fromInt(19))));
    FH_EXPECT(s.checkReset(worldWithBallAt(
        fh::sim::math::Vec3{}, Fixed64::fromInt(20))));
}

FH_TEST_MAIN()