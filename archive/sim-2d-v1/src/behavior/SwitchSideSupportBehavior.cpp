// footballhome sim - SwitchSideSupportBehavior implementation

#include "behavior/SwitchSideSupportBehavior.hpp"

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

std::vector<ConceptId> SwitchSideSupportBehavior::requiredConcepts() const
{
    return {m0::kReturnToBase, m0::kStayInZone};
}

math::Fixed64 SwitchSideSupportBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 SwitchSideSupportBehavior::utility(
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

    const math::Vec3 carrier_to_me{
        me->position.x - carrier->position.x,
        me->position.y - carrier->position.y,
        math::Fixed64::zero()};
    const math::Vec3 carrier_to_teammate{
        teammate->position.x - carrier->position.x,
        teammate->position.y - carrier->position.y,
        math::Fixed64::zero()};
    const math::Vec3 carrier_to_defender{
        defender->position.x - carrier->position.x,
        defender->position.y - carrier->position.y,
        math::Fixed64::zero()};

    const math::Fixed64 same_side = carrier_to_me.x * carrier_to_teammate.x +
                                     carrier_to_me.y * carrier_to_teammate.y;
    const math::Fixed64 opposite_side = carrier_to_me.x * carrier_to_defender.x +
                                        carrier_to_me.y * carrier_to_defender.y;

    if (same_side <= math::Fixed64::zero() || opposite_side >= math::Fixed64::zero()) {
        return math::Fixed64::zero();
    }

    return math::Fixed64::fromFraction(2, 3);
}

controller::Intent SwitchSideSupportBehavior::execute(
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

    const math::Vec3 switch_target{
        carrier->position.x + (carrier->position.x - teammate->position.x),
        carrier->position.y + (carrier->position.y - teammate->position.y),
        math::Fixed64::zero()};

    const math::Vec3 diff{
        switch_target.x - me->position.x,
        switch_target.y - me->position.y,
        math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior
