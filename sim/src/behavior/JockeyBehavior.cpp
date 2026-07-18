// footballhome sim - JockeyBehavior implementation

#include "behavior/JockeyBehavior.hpp"

#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"

namespace fh::sim::behavior {

std::vector<ConceptId> JockeyBehavior::requiredConcepts() const
{
    return {m0::kJockey};
}

math::Fixed64 JockeyBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 JockeyBehavior::utility(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    const profile::AttributeSet&    /*technical*/,
    const profile::AttributeSet&    mental)
{
    if (!view.ball_owner.has_value() || *view.ball_owner == self) {
        return math::Fixed64::zero();
    }

    const math::Fixed64 positioning = mental.get(
        m0::kPositioningSense, math::Fixed64::fromFraction(1, 2));
    const math::Fixed64 composure = mental.get(
        m0::kComposure, math::Fixed64::fromFraction(3, 5));
    return (positioning + composure) / 2;
}

controller::Intent JockeyBehavior::execute(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/)
{
    if (!view.ball_owner.has_value() || *view.ball_owner == self) {
        return controller::idle();
    }

    const math::Vec3* my_pos = nullptr;
    const math::Vec3* carrier_pos = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self) {
            my_pos = &e.position;
        }
        if (e.slot_id == *view.ball_owner) {
            carrier_pos = &e.position;
        }
    }
    if (my_pos == nullptr || carrier_pos == nullptr) {
        return controller::idle();
    }

    const math::Vec3 diff{
        carrier_pos->x - my_pos->x,
        carrier_pos->y - my_pos->y,
        math::Fixed64::zero()};
    const math::Fixed64 dist = diff.length();
    if (dist == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior