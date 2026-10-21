// footballhome sim - SwitchSideSupportBehavior tests

#include "awareness/AwarenessView.hpp"
#include "behavior/SwitchSideSupportBehavior.hpp"
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
using fh::sim::behavior::SwitchSideSupportBehavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

AwarenessView makeView(const Vec3& self_pos,
                       const Vec3& carrier_pos,
                       const Vec3& teammate_pos,
                       const Vec3& defender_pos,
                       SlotId self_slot = SlotId{2},
                       SlotId carrier_slot = SlotId{3},
                       SlotId teammate_slot = SlotId{4},
                       SlotId defender_slot = SlotId{5})
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

    EntityState teammate{};
    teammate.id = EntityId{4};
    teammate.slot_id = teammate_slot;
    teammate.position = teammate_pos;
    teammate.motion = MotionState::Jog;
    v.entities.push_back(teammate);

    EntityState defender{};
    defender.id = EntityId{5};
    defender.slot_id = defender_slot;
    defender.position = defender_pos;
    defender.motion = MotionState::Jog;
    v.entities.push_back(defender);

    v.ball_owner = carrier_slot;
    return v;
}

ConceptSet switchSideConcepts()
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

FH_TEST(utility_is_positive_when_a_supporter_is_already_on_one_side)
{
    SwitchSideSupportBehavior b;
    const auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(2), Fixed64::fromInt(1), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(6), Fixed64::zero(), Fixed64::zero()});

    const auto score = b.utility(v, SlotId{2}, switchSideConcepts(), emptyAttrs(), emptyAttrs(), std::nullopt);
    FH_EXPECT(score > Fixed64::zero());
}

FH_TEST(execute_moves_to_the_opposite_side_of_the_existing_supporter)
{
    SwitchSideSupportBehavior b;
    const auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(2), Fixed64::fromInt(1), Fixed64::zero()},
                            Vec3{Fixed64::fromInt(6), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, switchSideConcepts());
    FH_EXPECT(intent.desired_direction.y < Fixed64::zero());
}

FH_TEST_MAIN()
