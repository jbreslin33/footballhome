// footballhome sim - CoverShadowBehavior implementation

#include "behavior/CoverShadowBehavior.hpp"

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

std::vector<ConceptId> CoverShadowBehavior::requiredConcepts() const
{
    return {m0::kReturnToBase, m0::kStayInZone};
}

math::Fixed64 CoverShadowBehavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 CoverShadowBehavior::utility(
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
    const EntityState* danger = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self || e.slot_id == *view.ball_owner || e.slot_id == SlotId{0}) {
            continue;
        }
        danger = &e;
        break;
    }

    if (me == nullptr || carrier == nullptr || danger == nullptr) {
        return math::Fixed64::zero();
    }

    const math::Vec3 carrier_to_danger{
        danger->position.x - carrier->position.x,
        danger->position.y - carrier->position.y,
        math::Fixed64::zero()};
    if (carrier_to_danger.length() <= math::Fixed64::fromInt(1)) {
        return math::Fixed64::zero();
    }

    return math::Fixed64::fromFraction(3, 4);
}

controller::Intent CoverShadowBehavior::execute(
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
    const EntityState* danger = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == self || e.slot_id == *view.ball_owner || e.slot_id == SlotId{0}) {
            continue;
        }
        danger = &e;
        break;
    }

    if (me == nullptr || carrier == nullptr || danger == nullptr) {
        return controller::idle();
    }

    const math::Vec3 midpoint{
        (carrier->position.x + danger->position.x) / math::Fixed64::fromInt(2),
        (carrier->position.y + danger->position.y) / math::Fixed64::fromInt(2),
        math::Fixed64::zero()};

    const math::Vec3 diff{
        midpoint.x - me->position.x,
        midpoint.y - me->position.y,
        math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior
