// footballhome sim - SupportOffBallBehavior implementation

#include "behavior/SupportOffBallBehavior.hpp"

#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"

namespace fh::sim::behavior {

namespace {

const EntityState* findSlot(const awareness::AwarenessView& view, SlotId slot)
{
    for (const auto& e : view.entities) {
        if (e.slot_id == slot) {
            return &e;
        }
    }
    return nullptr;
}

} // namespace

std::vector<ConceptId> SupportOffBallBehavior::requiredConcepts() const
{
    return {m0::kReturnToBase};
}

math::Fixed64 SupportOffBallBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 SupportOffBallBehavior::utility(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    const profile::AttributeSet&    /*technical*/,
    const profile::AttributeSet&    /*mental*/,
    std::optional<SlotId>           /*mark_target*/)
{
    if (!view.ball_owner.has_value() || *view.ball_owner == self) {
        return math::Fixed64::zero();
    }

    const EntityState* me = findSlot(view, self);
    const EntityState* carrier = findSlot(view, *view.ball_owner);
    if (me == nullptr || carrier == nullptr) {
        return math::Fixed64::zero();
    }

    const math::Vec3 carrier_to_me{
        me->position.x - carrier->position.x,
        me->position.y - carrier->position.y,
        math::Fixed64::zero()};
    const math::Fixed64 dist = carrier_to_me.length();
    if (dist <= math::Fixed64::fromInt(1)) {
        return math::Fixed64::zero();
    }

    math::Fixed64 score = math::Fixed64::fromFraction(3, 4);
    if (!view.recognized_patterns.empty()) {
        score += math::Fixed64::fromFraction(1, 4);
    }
    return score;
}

controller::Intent SupportOffBallBehavior::execute(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    std::optional<SlotId>           /*mark_target*/)
{
    if (!view.ball_owner.has_value() || *view.ball_owner == self) {
        return controller::idle();
    }

    const EntityState* me = findSlot(view, self);
    const EntityState* carrier = findSlot(view, *view.ball_owner);
    if (me == nullptr || carrier == nullptr) {
        return controller::idle();
    }

    const math::Vec3 carrier_to_me{
        me->position.x - carrier->position.x,
        me->position.y - carrier->position.y,
        math::Fixed64::zero()};
    const math::Fixed64 dist = carrier_to_me.length();
    if (dist == math::Fixed64::zero()) {
        return controller::idle();
    }

    const math::Vec3 perpendicular{
        carrier_to_me.y,
        -carrier_to_me.x,
        math::Fixed64::zero()};
    const math::Vec3 support_offset = perpendicular.normalized() * math::Fixed64::fromInt(2);
    const math::Vec3 target{
        carrier->position.x + support_offset.x,
        carrier->position.y + support_offset.y,
        math::Fixed64::zero()};

    const math::Vec3 diff{
        target.x - me->position.x,
        target.y - me->position.y,
        math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior
