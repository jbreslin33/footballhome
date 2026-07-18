// footballhome sim - JockeyBehavior implementation

#include "behavior/JockeyBehavior.hpp"

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

const EntityState* findEntity(const awareness::AwarenessView& view, EntityId id)
{
    for (const auto& e : view.entities) {
        if (e.id == id) {
            return &e;
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
    const profile::AttributeSet&    mental,
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

    if (view.ball.has_value()) {
        const EntityState* ball = findEntity(view, *view.ball);
        if (ball != nullptr &&
            distanceSquared(me->position, ball->position) <
                distanceSquared(me->position, carrier->position)) {
            return math::Fixed64::zero();
        }
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

    const math::Vec3* my_pos = &me->position;
    const math::Vec3* carrier_pos = &carrier->position;

    const math::Fixed64 cushion = math::Fixed64::fromInt(2);
    math::Vec3 target{};

    const math::Vec3 carrier_velocity{
        carrier->velocity.x,
        carrier->velocity.y,
        math::Fixed64::zero()};
    if (carrier_velocity.length() != math::Fixed64::zero()) {
        const math::Vec3 carrier_path = carrier_velocity.normalized();
        target = math::Vec3{
            carrier_pos->x - carrier_path.x * cushion,
            carrier_pos->y - carrier_path.y * cushion,
            math::Fixed64::zero()};
    } else {
        const math::Vec3 carrier_to_defender{
            my_pos->x - carrier_pos->x,
            my_pos->y - carrier_pos->y,
            math::Fixed64::zero()};
        const math::Fixed64 dist = carrier_to_defender.length();
        if (dist == math::Fixed64::zero()) {
            return controller::idle();
        }

        const math::Vec3 goal_side = carrier_to_defender.normalized();
        target = math::Vec3{
            carrier_pos->x + goal_side.x * cushion,
            carrier_pos->y + goal_side.y * cushion,
            math::Fixed64::zero()};
    }

    const math::Vec3 diff{
        target.x - my_pos->x,
        target.y - my_pos->y,
        math::Fixed64::zero()};
    if (diff.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    controller::Intent intent;
    intent.desired_direction = diff.normalized();
    return intent;
}

} // namespace fh::sim::behavior