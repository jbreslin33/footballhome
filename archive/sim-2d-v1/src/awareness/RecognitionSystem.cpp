// footballhome sim - RecognitionSystem implementation
//
// M0: identity pass-through. See RecognitionSystem.hpp.

#include "awareness/RecognitionSystem.hpp"

#include "common/EntityState.hpp"
#include "math/Vec3.hpp"

#include <algorithm>

namespace fh::sim::awareness {

namespace {

constexpr const char* kBeingBeaten1v1Key = "pattern_being_beaten_1v1";
constexpr math::Fixed64 kBeatPatternRadius = math::Fixed64::fromInt(3);
constexpr math::Fixed64 kBeatPatternRadiusSq = kBeatPatternRadius * kBeatPatternRadius;
constexpr TickNum kDirectionHistoryTicks = TickNum{5};

const EntityState* findSlot(const WorldView& world, SlotId slot)
{
    for (const auto& entity : world.entities) {
        if (entity.slot_id == slot) {
            return &entity;
        }
    }
    return nullptr;
}

bool hasPlanarVelocity(const math::Vec3& velocity)
{
    return velocity.x != math::Fixed64::zero()
        || velocity.y != math::Fixed64::zero();
}

math::Fixed64 planarDistanceSquared(const math::Vec3& a, const math::Vec3& b)
{
    const math::Fixed64 dx = a.x - b.x;
    const math::Fixed64 dy = a.y - b.y;
    return dx * dx + dy * dy;
}

math::Fixed64 planarDot(const math::Vec3& a, const math::Vec3& b)
{
    return a.x * b.x + a.y * b.y;
}

} // namespace

void RecognitionSystem::updateCarrierHistory(const WorldView& world) const
{
    if (last_history_tick_.has_value() && *last_history_tick_ == world.tick) {
        return;
    }

    last_history_tick_ = world.tick;
    changed_direction_carrier_.reset();

    if (!world.ball_owner.has_value()) {
        return;
    }

    const EntityState* carrier = findSlot(world, *world.ball_owner);
    if (carrier == nullptr) {
        return;
    }

    if (carrierChangedDirectionRecently(world, *carrier)) {
        changed_direction_carrier_ = *world.ball_owner;
    }

    auto& samples = carrier_velocity_history_[*world.ball_owner];
    samples.erase(
        std::remove_if(samples.begin(), samples.end(),
                       [world](const VelocitySample& sample) {
                           return world.tick < sample.tick
                               || world.tick - sample.tick > kDirectionHistoryTicks;
                       }),
        samples.end());

    if (hasPlanarVelocity(carrier->velocity)) {
        samples.push_back(VelocitySample{world.tick, carrier->velocity});
    }
}

bool RecognitionSystem::carrierChangedDirectionRecently(
    const WorldView& world,
    const EntityState& carrier) const
{
    if (!world.ball_owner.has_value() || !hasPlanarVelocity(carrier.velocity)) {
        return false;
    }

    const auto history_it = carrier_velocity_history_.find(*world.ball_owner);
    if (history_it == carrier_velocity_history_.end()) {
        return false;
    }

    for (const VelocitySample& sample : history_it->second) {
        if (world.tick < sample.tick || world.tick - sample.tick > kDirectionHistoryTicks) {
            continue;
        }
        if (hasPlanarVelocity(sample.velocity)
            && planarDot(sample.velocity, carrier.velocity) < math::Fixed64::zero()) {
            return true;
        }
    }
    return false;
}

bool RecognitionSystem::shouldRecognizeBeingBeaten1v1(const WorldView& world,
                                                      SlotId           self) const
{
    if (!world.ball_owner.has_value() || *world.ball_owner == self) {
        return false;
    }
    if (!changed_direction_carrier_.has_value()
        || *changed_direction_carrier_ != *world.ball_owner) {
        return false;
    }

    const EntityState* self_entity = findSlot(world, self);
    const EntityState* carrier = findSlot(world, *world.ball_owner);
    if (self_entity == nullptr || carrier == nullptr) {
        return false;
    }

    return planarDistanceSquared(self_entity->position, carrier->position)
        <= kBeatPatternRadiusSq;
}

AwarenessView RecognitionSystem::apply(const WorldView&              world,
                                       const profile::PlayerProfile& perceiver,
                                       SlotId                        self) const
{
    updateCarrierHistory(world);

    AwarenessView view;
    view.tick                = world.tick;
    view.time_seconds        = world.time_seconds;
    view.entities            = world.entities;
    view.ball                = world.ball;
    // Slice 24.3b: identity copy through in M0. Future perception
    // milestones may fuzz/hide this if the perceiver hasn't seen the
    // last touch, but for M1 every player knows the current owner.
    view.ball_owner          = world.ball_owner;
    view.recognized_patterns.clear();

    if (patterns_ != nullptr) {
        const auto pattern_id = patterns_->lookup(kBeingBeaten1v1Key);
        if (pattern_id.has_value()
            && perceiver.recognition.skill(*pattern_id) > math::Fixed64::zero()
            && shouldRecognizeBeingBeaten1v1(world, self)) {
            view.recognized_patterns.push_back(*pattern_id);
        }
    }
    return view;
}

} // namespace fh::sim::awareness
