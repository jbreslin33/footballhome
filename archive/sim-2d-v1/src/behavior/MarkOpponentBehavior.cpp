// footballhome sim - MarkOpponentBehavior implementation

#include "behavior/MarkOpponentBehavior.hpp"

#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"

namespace fh::sim::behavior {

namespace {

const math::Vec3* findSlotPosition(const awareness::AwarenessView& view, SlotId slot)
{
    for (const auto& e : view.entities) {
        if (e.slot_id == slot) {
            return &e.position;
        }
    }
    return nullptr;
}

math::Fixed64 distanceSquared(const math::Vec3& a, const math::Vec3& b)
{
    const math::Fixed64 dx = a.x - b.x;
    const math::Fixed64 dy = a.y - b.y;
    return dx * dx + dy * dy;
}

} // namespace

std::vector<ConceptId> MarkOpponentBehavior::requiredConcepts() const
{
    return {m0::kMarking};
}

math::Fixed64 MarkOpponentBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 MarkOpponentBehavior::utility(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    const profile::AttributeSet&    technical,
    const profile::AttributeSet&    mental,
    std::optional<SlotId>           mark_target)
{
    if (!mark_target.has_value() || *mark_target == self) {
        return math::Fixed64::zero();
    }

    const math::Vec3* my_pos = findSlotPosition(view, self);
    const math::Vec3* target_pos = findSlotPosition(view, *mark_target);
    if (my_pos == nullptr || target_pos == nullptr) {
        return math::Fixed64::zero();
    }

    if (view.ball.has_value()) {
        const math::Vec3* ball_pos = nullptr;
        for (const auto& e : view.entities) {
            if (e.id == *view.ball) {
                ball_pos = &e.position;
                break;
            }
        }
        if (ball_pos != nullptr &&
            distanceSquared(*my_pos, *ball_pos) < distanceSquared(*my_pos, *target_pos)) {
            return math::Fixed64::zero();
        }
    }

    const math::Fixed64 marking = technical.get(
        m0::kMarkingTechnique, math::Fixed64::fromFraction(1, 2));
    const math::Fixed64 positioning = mental.get(
        m0::kPositioningSense, math::Fixed64::fromFraction(1, 2));
    return (marking + positioning) / 2;
}

controller::Intent MarkOpponentBehavior::execute(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    std::optional<SlotId>           mark_target)
{
    if (!mark_target.has_value() || *mark_target == self) {
        return controller::idle();
    }

    const math::Vec3* my_pos = findSlotPosition(view, self);
    const math::Vec3* target_pos = findSlotPosition(view, *mark_target);
    if (my_pos == nullptr || target_pos == nullptr) {
        return controller::idle();
    }

    const math::Vec3 diff{
        target_pos->x - my_pos->x,
        target_pos->y - my_pos->y,
        math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior