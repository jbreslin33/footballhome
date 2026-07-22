// footballhome sim - JockeyBehavior tests (Slice 31.2 skeleton)

#include "awareness/AwarenessView.hpp"
#include "behavior/JockeyBehavior.hpp"
#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"
#include "test_harness.hpp"

#include <optional>
#include <string>

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::PatternId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::behavior::JockeyBehavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

AwarenessView makeView(const Vec3& defender_pos,
                       const Vec3& carrier_pos,
                       bool include_carrier = true,
                       const Vec3& carrier_velocity = Vec3{})
{
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState defender{};
    defender.id       = EntityId{2};
    defender.slot_id  = SlotId{2};
    defender.position = defender_pos;
    defender.motion   = MotionState::Idle;
    v.entities.push_back(defender);

    if (include_carrier) {
        EntityState carrier{};
        carrier.id       = EntityId{3};
        carrier.slot_id  = SlotId{3};
        carrier.position = carrier_pos;
        carrier.velocity = carrier_velocity;
        carrier.motion   = MotionState::Jog;
        v.entities.push_back(carrier);
    }

    v.ball_owner = SlotId{3};
    return v;
}

ConceptSet jockeyConcepts()
{
    ConceptSet c;
    c.plug(fh::sim::m0::kJockey, Fixed64::one());
    return c;
}

AttributeSet emptyAttrs()
{
    return AttributeSet{};
}

} // namespace

FH_TEST(required_concepts_is_jockey)
{
    JockeyBehavior b;
    const auto reqs = b.requiredConcepts();
    FH_EXPECT_EQ(reqs.size(), std::size_t{1});
    FH_EXPECT_EQ(reqs[0], fh::sim::m0::kJockey);
}

FH_TEST(min_mastery_is_zero_presence_gated)
{
    JockeyBehavior b;
    FH_EXPECT_EQ(b.minMastery(), Fixed64::zero());
}

FH_TEST(utility_abstains_without_opposing_ball_owner)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto technical = emptyAttrs();
    const auto mental = emptyAttrs();
    auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});

    v.ball_owner.reset();
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, technical, mental, std::nullopt),
                 Fixed64::zero());

    v.ball_owner = SlotId{2};
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, technical, mental, std::nullopt),
                 Fixed64::zero());
}

FH_TEST(utility_abstains_when_positions_missing_or_ball_is_more_relevant)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto technical = emptyAttrs();
    const auto mental = emptyAttrs();

    const auto missing_carrier = makeView(Vec3{}, Vec3{}, /*include_carrier=*/false);
    FH_EXPECT_EQ(b.utility(missing_carrier, SlotId{2}, concepts, technical, mental, std::nullopt),
                 Fixed64::zero());

    auto loose_ball_nearby = makeView(
        Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});
    EntityState ball{};
    ball.id       = EntityId{1};
    ball.slot_id  = SlotId{0};
    ball.position = Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()};
    loose_ball_nearby.entities.push_back(ball);
    loose_ball_nearby.ball = ball.id;

    FH_EXPECT_EQ(b.utility(loose_ball_nearby, SlotId{2}, concepts, technical, mental, std::nullopt),
                 Fixed64::zero());
}

FH_TEST(utility_uses_positioning_sense_and_composure)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto technical = emptyAttrs();
    AttributeSet mental;
    mental.set(fh::sim::m0::kPositioningSense, Fixed64::fromFraction(4, 5));
    mental.set(fh::sim::m0::kComposure, Fixed64::fromFraction(3, 5));
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});
    const Fixed64 expected =
        (Fixed64::fromFraction(4, 5) + Fixed64::fromFraction(3, 5)) / 2;
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, technical, mental, std::nullopt),
                 expected + Fixed64::fromFraction(1, 10));
}

FH_TEST(utility_uses_neutral_defaults_when_attrs_absent)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto technical = emptyAttrs();
    const auto mental = emptyAttrs();
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, technical, mental, std::nullopt),
                 Fixed64::fromFraction(11, 20) + Fixed64::fromFraction(1, 10));
}

FH_TEST(utility_boosts_when_self_is_the_closest_defender_to_carrier)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto technical = emptyAttrs();
    AttributeSet mental;
    mental.set(fh::sim::m0::kPositioningSense, Fixed64::fromFraction(1, 2));
    mental.set(fh::sim::m0::kComposure, Fixed64::fromFraction(1, 2));

    auto v = makeView(Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()},
                      Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});
    EntityState other_defender{};
    other_defender.id = EntityId{4};
    other_defender.slot_id = SlotId{4};
    other_defender.position = Vec3{Fixed64::fromInt(10), Fixed64::zero(), Fixed64::zero()};
    other_defender.motion = MotionState::Jog;
    v.entities.push_back(other_defender);

    const Fixed64 utility = b.utility(v, SlotId{2}, concepts, technical, mental, std::nullopt);
    FH_EXPECT(utility > Fixed64::fromFraction(1, 2));
}

FH_TEST(utility_boosts_when_recognized_pattern_marks_being_beaten)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto technical = emptyAttrs();
    AttributeSet mental;
    mental.set(fh::sim::m0::kPositioningSense, Fixed64::fromFraction(1, 2));
    mental.set(fh::sim::m0::kComposure, Fixed64::fromFraction(1, 2));

    auto v = makeView(Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()},
                      Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});
    v.recognized_patterns.push_back(PatternId{1});

    const Fixed64 utility = b.utility(v, SlotId{2}, concepts, technical, mental, std::nullopt);
    FH_EXPECT(utility > Fixed64::fromFraction(1, 2));
}

FH_TEST(moves_to_goal_side_cushion_without_pressing_or_dribbling)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::one());
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
    FH_EXPECT(!intent.wants_sprint);
    FH_EXPECT(!intent.wants_walk);
}

FH_TEST(recognized_pattern_pushes_jockey_toward_goal_side_offset)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                      Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});
    v.recognized_patterns.push_back(PatternId{1});

    const Intent intent = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT(intent.desired_direction.x > Fixed64::zero());
    FH_EXPECT(intent.desired_direction.y != Fixed64::zero());
}

FH_TEST(moves_to_carrier_path_cushion_when_carrier_is_moving)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto v = makeView(
        Vec3{Fixed64::fromInt(4), Fixed64::fromInt(-4), Fixed64::zero()},
        Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()},
        /*include_carrier=*/true,
        Vec3{Fixed64::zero(), Fixed64::one(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::one());
    FH_EXPECT(!intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
}

FH_TEST(backs_away_when_inside_jockey_cushion)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto v = makeView(Vec3{Fixed64::fromInt(3), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::fromInt(-1));
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
}

FH_TEST(idles_when_already_at_jockey_cushion)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();
    const auto v = makeView(Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
}

FH_TEST(idles_when_carrier_missing_or_same_position)
{
    JockeyBehavior b;
    const auto concepts = jockeyConcepts();

    const auto missing = makeView(Vec3{}, Vec3{}, /*include_carrier=*/false);
    const Intent missing_intent = b.execute(missing, SlotId{2}, concepts);
    FH_EXPECT_EQ(missing_intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(missing_intent.desired_direction.y, Fixed64::zero());

    const auto same = makeView(Vec3{}, Vec3{});
    const Intent same_intent = b.execute(same, SlotId{2}, concepts);
    FH_EXPECT_EQ(same_intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(same_intent.desired_direction.y, Fixed64::zero());
}

FH_TEST(id_string_is_jockey)
{
    JockeyBehavior b;
    FH_EXPECT_EQ(std::string(b.id()), std::string("jockey"));
}

FH_TEST_MAIN()