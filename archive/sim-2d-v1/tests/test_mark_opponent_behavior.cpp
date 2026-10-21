// footballhome sim - MarkOpponentBehavior tests

#include "awareness/AwarenessView.hpp"
#include "behavior/MarkOpponentBehavior.hpp"
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
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::behavior::MarkOpponentBehavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

AwarenessView makeView(const Vec3& marker_pos,
                       const Vec3& target_pos,
                       bool include_target = true)
{
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState marker{};
    marker.id       = EntityId{2};
    marker.slot_id  = SlotId{2};
    marker.position = marker_pos;
    marker.motion   = MotionState::Idle;
    v.entities.push_back(marker);

    if (include_target) {
        EntityState target{};
        target.id       = EntityId{3};
        target.slot_id  = SlotId{3};
        target.position = target_pos;
        target.motion   = MotionState::Jog;
        v.entities.push_back(target);
    }

    return v;
}

ConceptSet markingConcepts()
{
    ConceptSet c;
    c.plug(fh::sim::m0::kMarking, Fixed64::one());
    return c;
}

AttributeSet emptyAttrs()
{
    return AttributeSet{};
}

} // namespace

FH_TEST(required_concepts_is_marking)
{
    MarkOpponentBehavior b;
    const auto reqs = b.requiredConcepts();
    FH_EXPECT_EQ(reqs.size(), std::size_t{1});
    FH_EXPECT_EQ(reqs[0], fh::sim::m0::kMarking);
}

FH_TEST(min_mastery_is_zero_presence_gated)
{
    MarkOpponentBehavior b;
    FH_EXPECT_EQ(b.minMastery(), Fixed64::zero());
}

FH_TEST(utility_abstains_without_assigned_target)
{
    MarkOpponentBehavior b;
    const auto concepts = markingConcepts();
    const auto attrs = emptyAttrs();
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, attrs, attrs, SlotId{2}),
                 Fixed64::zero());
}

FH_TEST(utility_uses_marking_and_positioning_attributes)
{
    MarkOpponentBehavior b;
    const auto concepts = markingConcepts();
    AttributeSet technical;
    AttributeSet mental;
    technical.set(fh::sim::m0::kMarkingTechnique, Fixed64::fromFraction(4, 5));
    mental.set(fh::sim::m0::kPositioningSense, Fixed64::fromFraction(3, 5));
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});
    const Fixed64 expected =
        (Fixed64::fromFraction(4, 5) + Fixed64::fromFraction(3, 5)) / 2;
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, technical, mental, SlotId{3}),
                 expected);
}

FH_TEST(utility_abstains_when_marker_is_closer_to_ball_than_target)
{
    MarkOpponentBehavior b;
    const auto concepts = markingConcepts();
    const auto attrs = emptyAttrs();
    auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});

    EntityState ball{};
    ball.id       = EntityId{1};
    ball.slot_id  = SlotId{0};
    ball.position = Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()};
    v.entities.push_back(ball);
    v.ball = ball.id;

    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts, attrs, attrs, SlotId{3}),
                 Fixed64::zero());
}

FH_TEST(moves_toward_assigned_target_without_pressing_or_dribbling)
{
    MarkOpponentBehavior b;
    const auto concepts = markingConcepts();
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, concepts, SlotId{3});
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::one());
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
    FH_EXPECT(!intent.wants_sprint);
    FH_EXPECT(!intent.wants_walk);
}

FH_TEST(idles_when_target_missing_or_same_position)
{
    MarkOpponentBehavior b;
    const auto concepts = markingConcepts();

    const auto missing = makeView(Vec3{}, Vec3{}, /*include_target=*/false);
    const Intent missing_intent = b.execute(missing, SlotId{2}, concepts, SlotId{3});
    FH_EXPECT_EQ(missing_intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(missing_intent.desired_direction.y, Fixed64::zero());

    const auto same = makeView(Vec3{}, Vec3{});
    const Intent same_intent = b.execute(same, SlotId{2}, concepts, SlotId{3});
    FH_EXPECT_EQ(same_intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(same_intent.desired_direction.y, Fixed64::zero());
}

FH_TEST(id_string_is_mark_opponent)
{
    MarkOpponentBehavior b;
    FH_EXPECT_EQ(std::string(b.id()), std::string("mark_opponent"));
}

FH_TEST_MAIN()