// footballhome sim - IPhysicsWorld
//
// The physics layer owns per-entity kinematic state (position, velocity,
// heading, motion) and integrates positions once per tick.
//
// Match owns intent-translation (Intent → velocity + heading + motion via
// mechanics functions) and writes updated fields into physics BEFORE
// calling step(dt). Physics then integrates position from velocity.
//
// M0 = StubPhysics: no collisions, no ball, plain Euler integration.
// M1+ replaces StubPhysics with BasicPhysics without changing this
// interface.
//
// See DESIGN.md §5.3, §14.

#pragma once

#include "common/EntityState.hpp"
#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <vector>

namespace fh::sim::physics {

struct EntityDef {
    // Scenario slot this entity represents. 0 = ball or unassigned; 1..N =
    // player slot. Stored on EntityState so controllers can locate themselves.
    SlotId        slot_id{0};
    math::Vec3    position;
    math::Vec3    velocity;
    math::Fixed64 radius;      // reserved for M2 collisions
    math::Fixed64 height;      // reserved for 3D headers
    bool          is_ball{false};
};

class IPhysicsWorld {
public:
    virtual ~IPhysicsWorld() = default;

    // Lifecycle -------------------------------------------------------
    virtual EntityId spawn(const EntityDef& def) = 0;
    virtual void     despawn(EntityId id) = 0;

    // Per-tick mutators (called by Match before step()) ---------------
    // Written by mechanics; physics simply stores them.
    virtual void     setVelocity(EntityId id, math::Vec3 v) = 0;
    virtual void     setHeading(EntityId id, math::Fixed64 rad) = 0;
    virtual void     setMotion(EntityId id, MotionState motion) = 0;

    // Reserved for M1+ (impulse-based ball response). StubPhysics
    // implements it as an additive setVelocity so the interface is
    // stable from day 1.
    virtual void     applyImpulse(EntityId id, math::Vec3 impulse) = 0;

    // Read -----------------------------------------------------------
    virtual EntityState               get(EntityId id) const = 0;
    virtual std::vector<EntityId>     all() const = 0;
    virtual bool                      contains(EntityId id) const = 0;
    virtual std::size_t               size() const = 0;

    // Integrate for dt seconds (fixed-point). M0: position += velocity * dt.
    virtual void step(math::Fixed64 dt) = 0;
};

} // namespace fh::sim::physics
