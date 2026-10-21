// footballhome sim - Feint1v1Behavior tests

#include "awareness/AwarenessView.hpp"
#include "behavior/Feint1v1Behavior.hpp"
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
using fh::sim::behavior::Feint1v1Behavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

AwarenessView makeView(const Vec3& attacker_pos,
                       const Vec3& defender_pos,
                       bool include_defender = true,
                       const Vec3& defender_velocity = Vec3{})
{
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState attacker{};
    attacker.id       = EntityId{2};
    attacker.slot_id  = SlotId{1};
    attacker.position = attacker_pos;
    attacker.motion   = MotionState::Jog;
    v.entities.push_back(attacker);

    if (include_defender) {
        EntityState defender{};
        defender.id       = EntityId{3};
        defender.slot_id  = SlotId{2};
        defender.position = defender_pos;
        defender.velocity = defender_velocity;
        defender.motion   = MotionState::Jog;
        v.entities.push_back(defender);
    }

    v.ball_owner = SlotId{1};
    return v;
}

ConceptSet beatConcepts()
{
    ConceptSet c;
    c.plug(fh::sim::m0::k1v1Beat, Fixed64::one());
    return c;
}

AttributeSet emptyAttrs()
{
    return AttributeSet{};
}

} // namespace

FH_TEST(required_concepts_is_1v1_beat)
{
    Feint1v1Behavior b;
    const auto reqs = b.requiredConcepts();
    FH_EXPECT_EQ(reqs.size(), std::size_t{1});
    FH_EXPECT_EQ(reqs[0], fh::sim::m0::k1v1Beat);
}

FH_TEST(min_mastery_is_zero_presence_gated_and_min_ticks_is_short)
{
    Feint1v1Behavior b;
    FH_EXPECT_EQ(b.minMastery(), Fixed64::zero());
    FH_EXPECT_EQ(b.minTicks(), TickNum{8});
}

FH_TEST(utility_abstains_without_ball_ownership_or_self_entity)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    const auto attrs = emptyAttrs();
    auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()});

    v.ball_owner.reset();
    FH_EXPECT_EQ(b.utility(v, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());

    v.ball_owner = SlotId{2};
    FH_EXPECT_EQ(b.utility(v, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());

    const auto missing_self = makeView(Vec3{}, Vec3{}, /*include_defender=*/false);
    FH_EXPECT_EQ(b.utility(missing_self, SlotId{9}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());
}

FH_TEST(utility_requires_exactly_one_nearby_defender)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    const auto attrs = emptyAttrs();

    const auto no_defender = makeView(Vec3{}, Vec3{}, /*include_defender=*/false);
    FH_EXPECT_EQ(b.utility(no_defender, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());

    const auto far_defender = makeView(
        Vec3{}, Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});
    FH_EXPECT_EQ(b.utility(far_defender, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());

    auto two_defenders = makeView(
        Vec3{}, Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()});
    EntityState second{};
    second.id       = EntityId{4};
    second.slot_id  = SlotId{3};
    second.position = Vec3{Fixed64::zero(), Fixed64::fromInt(2), Fixed64::zero()};
    two_defenders.entities.push_back(second);
    FH_EXPECT_EQ(b.utility(two_defenders, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());
}

FH_TEST(utility_uses_feint_and_composure_attributes)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    AttributeSet technical;
    AttributeSet mental;
    technical.set(fh::sim::m0::kFeint, Fixed64::fromFraction(4, 5));
    mental.set(fh::sim::m0::kComposure, Fixed64::fromFraction(3, 5));
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()});
    const Fixed64 expected = Fixed64::fromFraction(4, 5) * Fixed64::fromFraction(3, 5);
    FH_EXPECT_EQ(b.utility(v, SlotId{1}, concepts, technical, mental, std::nullopt),
                 expected);
}

FH_TEST(utility_uses_neutral_defaults_when_attrs_absent)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    const auto attrs = emptyAttrs();
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()});
    FH_EXPECT_EQ(b.utility(v, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::fromFraction(3, 10));
}

FH_TEST(executes_lateral_dribble_away_from_stationary_defender)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{1}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::one());
    FH_EXPECT(intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
    FH_EXPECT(!intent.wants_sprint);
    FH_EXPECT(!intent.wants_walk);
}

FH_TEST(executes_lateral_dribble_from_defender_velocity)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    const auto v = makeView(
        Vec3{Fixed64::zero(), Fixed64::fromInt(1), Fixed64::zero()},
        Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()},
        /*include_defender=*/true,
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{1}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::one());
    FH_EXPECT(intent.wants_dribble);
}

FH_TEST(cooldown_abstains_after_execution)
{
    Feint1v1Behavior b;
    const auto concepts = beatConcepts();
    const auto attrs = emptyAttrs();
    auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{1}, concepts);
    FH_EXPECT(intent.wants_dribble);
    v.tick = TickNum{1};
    FH_EXPECT_EQ(b.utility(v, SlotId{1}, concepts, attrs, attrs, std::nullopt),
                 Fixed64::zero());
    v.tick = TickNum{20};
    FH_EXPECT(b.utility(v, SlotId{1}, concepts, attrs, attrs, std::nullopt) > Fixed64::zero());
}

FH_TEST(id_string_is_feint_1v1)
{
    Feint1v1Behavior b;
    FH_EXPECT_EQ(std::string(b.id()), std::string("feint_1v1"));
}

FH_TEST_MAIN()
