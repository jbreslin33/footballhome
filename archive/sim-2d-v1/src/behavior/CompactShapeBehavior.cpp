// footballhome sim - CompactShapeBehavior implementation

#include "behavior/CompactShapeBehavior.hpp"

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

std::vector<ConceptId> CompactShapeBehavior::requiredConcepts() const
{
    return {m0::kReturnToBase, m0::kStayInZone};
}

math::Fixed64 CompactShapeBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 CompactShapeBehavior::utility(
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
    for (const auto& e : view.entities) {
        if (e.slot_id == self || e.slot_id == *view.ball_owner || e.slot_id == SlotId{0}) {
            continue;
        }
        teammate = &e;
        break;
    }

    if (me == nullptr || carrier == nullptr || teammate == nullptr) {
        return math::Fixed64::zero();
    }

    const math::Vec3 centroid{
        (carrier->position.x + teammate->position.x + me->position.x) / math::Fixed64::fromInt(3),
        (carrier->position.y + teammate->position.y + me->position.y) / math::Fixed64::fromInt(3),
        math::Fixed64::zero()};
    const math::Vec3 diff{centroid.x - me->position.x, centroid.y - me->position.y, math::Fixed64::zero()};
    if (diff.length() <= math::Fixed64::fromInt(1)) {
        return math::Fixed64::zero();
    }

    return math::Fixed64::fromFraction(2, 3);
}

controller::Intent CompactShapeBehavior::execute(
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
    for (const auto& e : view.entities) {
        if (e.slot_id == self || e.slot_id == *view.ball_owner || e.slot_id == SlotId{0}) {
            continue;
        }
        teammate = &e;
        break;
    }

    if (me == nullptr || carrier == nullptr || teammate == nullptr) {
        return controller::idle();
    }

    const math::Vec3 centroid{
        (carrier->position.x + teammate->position.x + me->position.x) / math::Fixed64::fromInt(3),
        (carrier->position.y + teammate->position.y + me->position.y) / math::Fixed64::fromInt(3),
        math::Fixed64::zero()};

    const math::Vec3 diff{centroid.x - me->position.x, centroid.y - me->position.y, math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior
