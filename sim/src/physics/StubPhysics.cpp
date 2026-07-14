// footballhome sim - StubPhysics implementation

#include "physics/StubPhysics.hpp"

#include <algorithm>

namespace fh::sim::physics {

EntityId StubPhysics::spawn(const EntityDef& def)
{
    const EntityId id = next_id_++;
    EntityState e;
    e.id       = id;
    e.slot_id  = def.slot_id;
    e.position = def.position;
    e.velocity = def.velocity;
    e.heading  = math::Fixed64::zero();
    e.motion   = MotionState::Idle;
    (void)def.radius;   // reserved for M2
    (void)def.height;   // reserved for future 3D headers
    (void)def.is_ball;  // no ball in M0
    entities_.emplace(id, e);
    return id;
}

void StubPhysics::despawn(EntityId id)
{
    entities_.erase(id);
}

void StubPhysics::setVelocity(EntityId id, math::Vec3 v)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.velocity = v;
    }
}

void StubPhysics::setHeading(EntityId id, math::Fixed64 rad)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.heading = rad;
    }
}

void StubPhysics::setMotion(EntityId id, MotionState motion)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.motion = motion;
    }
}

void StubPhysics::setPosition(EntityId id, math::Vec3 pos)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.position = pos;
    }
}

void StubPhysics::applyImpulse(EntityId id, math::Vec3 impulse)
{
    // M0 has no mass model — impulse is just an additive velocity change.
    // M1+ (ball) will replace this with real dynamics.
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.velocity = it->second.velocity + impulse;
    }
}

EntityState StubPhysics::get(EntityId id) const
{
    const auto it = entities_.find(id);
    if (it == entities_.end()) {
        return EntityState{};   // id=0 sentinel
    }
    return it->second;
}

std::vector<EntityId> StubPhysics::all() const
{
    // Deterministic order: sort by EntityId so callers (Match building
    // WorldView, tests, snapshot builders) see the same order every tick.
    std::vector<EntityId> ids;
    ids.reserve(entities_.size());
    for (const auto& [id, _] : entities_) {
        ids.push_back(id);
    }
    std::sort(ids.begin(), ids.end());
    return ids;
}

bool StubPhysics::contains(EntityId id) const
{
    return entities_.find(id) != entities_.end();
}

void StubPhysics::step(math::Fixed64 dt)
{
    for (auto& [id, e] : entities_) {
        (void)id;
        e.position.x = e.position.x + e.velocity.x * dt;
        e.position.y = e.position.y + e.velocity.y * dt;
        e.position.z = e.position.z + e.velocity.z * dt;
    }
}

} // namespace fh::sim::physics
