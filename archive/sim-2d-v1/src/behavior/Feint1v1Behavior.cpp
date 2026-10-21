// footballhome sim - Feint1v1Behavior implementation

#include "behavior/Feint1v1Behavior.hpp"

#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"

namespace fh::sim::behavior {

namespace {

constexpr math::Fixed64 kFeintDefenderRadius = math::Fixed64::fromInt(3);
constexpr math::Fixed64 kFeintDefenderRadiusSq = kFeintDefenderRadius * kFeintDefenderRadius;
constexpr TickNum kFeintCooldownTicks = TickNum{20};

const EntityState* findSlot(const awareness::AwarenessView& view, SlotId slot)
{
    for (const auto& e : view.entities) {
        if (e.slot_id == slot) {
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

const EntityState* findSingleNearbyDefender(const awareness::AwarenessView& view,
                                            SlotId self,
                                            const math::Vec3& self_pos)
{
    const EntityState* defender = nullptr;
    for (const auto& e : view.entities) {
        if (e.slot_id == SlotId{0} || e.slot_id == self) {
            continue;
        }
        if (distanceSquared(self_pos, e.position) > kFeintDefenderRadiusSq) {
            continue;
        }
        if (defender != nullptr) {
            return nullptr;
        }
        defender = &e;
    }
    return defender;
}

math::Vec3 lateralAwayFromDefender(const math::Vec3& self_pos,
                                   const EntityState& defender)
{
    math::Vec3 base{
        defender.velocity.x,
        defender.velocity.y,
        math::Fixed64::zero()};
    if (base.length() == math::Fixed64::zero()) {
        base = math::Vec3{
            defender.position.x - self_pos.x,
            defender.position.y - self_pos.y,
            math::Fixed64::zero()};
    }
    if (base.length() == math::Fixed64::zero()) {
        return {};
    }

    const math::Vec3 left{-base.y, base.x, math::Fixed64::zero()};
    const math::Vec3 right{base.y, -base.x, math::Fixed64::zero()};
    const math::Vec3 away{
        self_pos.x - defender.position.x,
        self_pos.y - defender.position.y,
        math::Fixed64::zero()};
    return math::dot(left, away) >= math::dot(right, away)
        ? left.normalized()
        : right.normalized();
}

} // namespace

std::vector<ConceptId> Feint1v1Behavior::requiredConcepts() const
{
    return {m0::k1v1Beat};
}

math::Fixed64 Feint1v1Behavior::minMastery() const
{
    return math::Fixed64::zero();
}

math::Fixed64 Feint1v1Behavior::utility(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    const profile::AttributeSet&    technical,
    const profile::AttributeSet&    mental,
    std::optional<SlotId>           /*mark_target*/)
{
    if (!view.ball_owner.has_value() || *view.ball_owner != self) {
        return math::Fixed64::zero();
    }
    if (next_feint_tick_.has_value() && view.tick < *next_feint_tick_) {
        return math::Fixed64::zero();
    }

    const EntityState* me = findSlot(view, self);
    if (me == nullptr) {
        return math::Fixed64::zero();
    }
    if (findSingleNearbyDefender(view, self, me->position) == nullptr) {
        return math::Fixed64::zero();
    }

    const math::Fixed64 feint = technical.get(
        m0::kFeint, math::Fixed64::fromFraction(1, 2));
    const math::Fixed64 composure = mental.get(
        m0::kComposure, math::Fixed64::fromFraction(3, 5));
    return feint * composure;
}

controller::Intent Feint1v1Behavior::execute(
    const awareness::AwarenessView& view,
    SlotId                          self,
    const profile::ConceptSet&      /*concepts*/,
    std::optional<SlotId>           /*mark_target*/)
{
    if (!view.ball_owner.has_value() || *view.ball_owner != self) {
        return controller::idle();
    }

    const EntityState* me = findSlot(view, self);
    if (me == nullptr) {
        return controller::idle();
    }

    const EntityState* defender = findSingleNearbyDefender(view, self, me->position);
    if (defender == nullptr) {
        return controller::idle();
    }

    const math::Vec3 lateral = lateralAwayFromDefender(me->position, *defender);
    if (lateral.length() == math::Fixed64::zero()) {
        return controller::idle();
    }

    next_feint_tick_ = static_cast<TickNum>(view.tick + kFeintCooldownTicks);

    controller::Intent intent;
    intent.desired_direction = lateral;
    intent.wants_dribble = true;
    return intent;
}

} // namespace fh::sim::behavior
