// footballhome sim - StubPhysics
//
// Kinematic-only integrator for M0. No collisions, no bounds, no dynamics.
// Each tick: position += velocity * dt for every entity.
//
// Entity IDs are handed out monotonically starting at 1 so 0 remains an
// "unset" sentinel throughout the codebase.
//
// See DESIGN.md §5.3, §16.4 (no collisions in M0).

#pragma once

#include "physics/IPhysicsWorld.hpp"

#include <unordered_map>

namespace fh::sim::physics {

class StubPhysics : public IPhysicsWorld {
public:
    StubPhysics() = default;

    EntityId spawn(const EntityDef& def) override;
    void     despawn(EntityId id) override;

    void     setVelocity(EntityId id, math::Vec3 v) override;
    void     setHeading(EntityId id, math::Fixed64 rad) override;
    void     setMotion(EntityId id, MotionState motion) override;
    void     applyImpulse(EntityId id, math::Vec3 impulse) override;

    EntityState              get(EntityId id) const override;
    std::vector<EntityId>    all() const override;
    bool                     contains(EntityId id) const override;
    std::size_t              size() const override { return entities_.size(); }

    void step(math::Fixed64 dt) override;

private:
    EntityId                                next_id_{1};
    std::unordered_map<EntityId, EntityState> entities_;
};

} // namespace fh::sim::physics
