// footballhome sim - CoverShadowBehavior tests

#include "awareness/AwarenessView.hpp"
#include "behavior/CoverShadowBehavior.hpp"
#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"
#include "test_harness.hpp"

#include <optional>

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::behavior::CoverShadowBehavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

AwarenessView makeView(const Vec3& self_pos,
                       const Vec3& carrier_pos,
                       const Vec3& defender_pos,
                       SlotId self_slot = SlotId{2},
                       SlotId carrier_slot = SlotId{3})
{
    AwarenessView v;
    v.tick = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState self{};
    self.id = EntityId{2};
    self.slot_id = self_slot;
    self.position = self_pos;
    self.motion = MotionState::Jog;
    v.entities.push_back(self);

    EntityState carrier{};
    carrier.id = EntityId{3};
    carrier.slot_id = carrier_slot;
    carrier.position = carrier_pos;
    carrier.motion = MotionState::Jog;
    v.entities.push_back(carrier);

    EntityState defender{};
    defender.id = EntityId{4};
    defender.slot_id = SlotId{4};
    defender.position = defender_pos;
    defender.motion = MotionState::Jog;
    v.entities.push_back(defender);

    v.ball_owner = carrier_slot;
    return v;
}

ConceptSet coverConcepts()
{
    ConceptSet c;
    c.plug(fh::sim::m0::kReturnToBase, Fixed64::one());
    c.plug(fh::sim::m0::kStayInZone, Fixed64::one());
    return c;
}

AttributeSet emptyAttrs()
{
    return AttributeSet{};
}

} // namespace

FH_TEST(required_concepts_include_positioning_concepts)
{
    CoverShadowBehavior b;
    const auto reqs = b.requiredConcepts();
    FH_EXPECT_EQ(reqs.size(), std::size_t{2});
    FH_EXPECT_EQ(reqs[0], fh::sim::m0::kReturnToBase);
    FH_EXPECT_EQ(reqs[1], fh::sim::m0::kStayInZone);
}

FH_TEST(utility_abstains_without_opponent)
{
    CoverShadowBehavior b;
    auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()}, Vec3{});
    v.entities.pop_back();
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, coverConcepts(), emptyAttrs(), emptyAttrs(), std::nullopt),
                 Fixed64::zero());
}

FH_TEST(execute_moves_toward_cover_point_between_carrier_and_defender)
{
    CoverShadowBehavior b;
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(3), Fixed64::fromInt(2), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, coverConcepts());
    FH_EXPECT(intent.desired_direction.x > Fixed64::zero());
    FH_EXPECT(intent.desired_direction.y > Fixed64::zero());
}

FH_TEST_MAIN()
