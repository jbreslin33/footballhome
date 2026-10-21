// footballhome sim - SupportOffBallBehavior tests

#include "awareness/AwarenessView.hpp"
#include "behavior/SupportOffBallBehavior.hpp"
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
using fh::sim::PatternId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::behavior::SupportOffBallBehavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

AwarenessView makeView(const Vec3& self_pos,
                       const Vec3& carrier_pos,
                       SlotId self_slot = SlotId{2},
                       SlotId carrier_slot = SlotId{3})
{
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState self{};
    self.id       = EntityId{2};
    self.slot_id  = self_slot;
    self.position = self_pos;
    self.motion   = MotionState::Jog;
    v.entities.push_back(self);

    EntityState carrier{};
    carrier.id       = EntityId{3};
    carrier.slot_id  = carrier_slot;
    carrier.position = carrier_pos;
    carrier.motion   = MotionState::Jog;
    v.entities.push_back(carrier);

    v.ball_owner = carrier_slot;
    return v;
}

AwarenessView makeViewWithPattern(const Vec3& self_pos,
                                  const Vec3& carrier_pos,
                                  PatternId pattern_id,
                                  SlotId self_slot = SlotId{2},
                                  SlotId carrier_slot = SlotId{3})
{
    auto v = makeView(self_pos, carrier_pos, self_slot, carrier_slot);
    v.recognized_patterns.push_back(pattern_id);
    return v;
}

ConceptSet supportConcepts()
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
    SupportOffBallBehavior b;
    const auto reqs = b.requiredConcepts();
    FH_EXPECT_EQ(reqs.size(), std::size_t{2});
    FH_EXPECT_EQ(reqs[0], fh::sim::m0::kReturnToBase);
    FH_EXPECT_EQ(reqs[1], fh::sim::m0::kStayInZone);
}

FH_TEST(utility_abstains_without_ball_owner)
{
    SupportOffBallBehavior b;
    auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});
    v.ball_owner.reset();
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, supportConcepts(), emptyAttrs(), emptyAttrs(), std::nullopt),
                 Fixed64::zero());
}

FH_TEST(execute_moves_toward_support_offset_from_carrier)
{
    SupportOffBallBehavior b;
    const auto v = makeView(Vec3{}, Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()});

    const Intent intent = b.execute(v, SlotId{2}, supportConcepts());
    FH_EXPECT(intent.desired_direction.y > Fixed64::zero());
    FH_EXPECT(!intent.wants_dribble);
    FH_EXPECT(!intent.wants_to_press);
}

FH_TEST(patterns_raise_support_utility)
{
    SupportOffBallBehavior b;
    const auto v = makeViewWithPattern(Vec3{Fixed64::fromInt(1), Fixed64::fromInt(1), Fixed64::zero()},
                                       Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()},
                                       PatternId{7});

    const auto score = b.utility(v, SlotId{2}, supportConcepts(), emptyAttrs(), emptyAttrs(), std::nullopt);
    FH_EXPECT(score > Fixed64::fromFraction(3, 4));
}

int main()
{
    if (::fh::sim::test::g_failures != 0) {
        std::fprintf(stderr, "\n%d assertion failure(s)\n",
                     ::fh::sim::test::g_failures);
        return 1;
    }
    std::fprintf(stdout, "\nall tests passed\n");
    return 0;
}
