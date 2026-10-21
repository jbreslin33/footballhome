// footballhome sim - OverloadSupportBehavior implementation

#include "behavior/OverloadSupportBehavior.hpp"

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

std::vector<ConceptId> OverloadSupportBehavior::requiredConcepts() const
{
    return {m0::kReturnToBase, m0::kStayInZone};
}

math::Fixed64 OverloadSupportBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 OverloadSupportBehavior::utility(
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
    const EntityState* teammate = nullptr;
    const EntityState* defender = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self || e.slot_id == *view.ball_owner || e.slot_id == SlotId{0}) {
            continue;
        }
        if (teammate == nullptr) {
            teammate = &e;
        } else {
            defender = &e;
            break;
        }
    }

    if (me == nullptr || carrier == nullptr || teammate == nullptr || defender == nullptr) {
        return math::Fixed64::zero();
    }

    const math::Vec3 carrier_to_teammate{
        teammate->position.x - carrier->position.x,
        teammate->position.y - carrier->position.y,
        math::Fixed64::zero()};
    const math::Vec3 carrier_to_defender{
        defender->position.x - carrier->position.x,
        defender->position.y - carrier->position.y,
        math::Fixed64::zero()};

    const math::Fixed64 dot = carrier_to_teammate.x * carrier_to_defender.x +
                              carrier_to_teammate.y * carrier_to_defender.y;
    if (dot >= math::Fixed64::zero()) {
        return math::Fixed64::zero();
    }

    return math::Fixed64::fromFraction(2, 3);
}

controller::Intent OverloadSupportBehavior::execute(
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
    const EntityState* teammate = nullptr;
    const EntityState* defender = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self || e.slot_id == *view.ball_owner || e.slot_id == SlotId{0}) {
            continue;
        }
        if (teammate == nullptr) {
            teammate = &e;
        } else {
            defender = &e;
            break;
        }
    }

    if (me == nullptr || carrier == nullptr || teammate == nullptr || defender == nullptr) {
        return controller::idle();
    }

    const math::Vec3 overload_vector{
        teammate->position.x - defender->position.x,
        teammate->position.y - defender->position.y,
        math::Fixed64::zero()};
    const math::Vec3 support_target{
        carrier->position.x + overload_vector.x,
        carrier->position.y + overload_vector.y,
        math::Fixed64::zero()};

    const math::Vec3 diff{
        support_target.x - me->position.x,
        support_target.y - me->position.y,
        math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior
