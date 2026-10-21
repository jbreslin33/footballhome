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

    // Teleport an entity to an absolute position, bypassing velocity
    // integration. Slice 16.3 uses this to glue the ball to the owner
    // (pre-step): setPosition on the ball each tick to owner + heading
    // offset, then setVelocity(owner_vel) so physics.step integrates
    // both consistently. Also useful for M2+ kickoff / throw-in resets.
    // Silently no-ops if id is unknown, matching the other setters.
    virtual void     setPosition(EntityId id, math::Vec3 pos) = 0;

    // Reserved for M1+ (impulse-based ball response). StubPhysics
    // implements it as an additive setVelocity so the interface is
    // stable from day 1.
    virtual void     applyImpulse(EntityId id, math::Vec3 impulse) = 0;

    // Slice 27.2 (ADR §22.24): set the body-mass split weight for the
    // circle-circle positional-clamp + tangential-slide collision
    // resolver in BasicPhysics. Values outside [0.5, 1.5] are silently
    // clamped inside BasicPhysics::step so mis-authored profiles can't
    // destabilise the MTV split (equal masses each move penetration/2;
    // 1.5 vs 1.0 heavier entity moves only 40% of the penetration).
    // Called by Match::spawnInitialSlots (default kBodyMassDefault=1.0)
    // and Match::claimSlot (from `PlayerProfile::physical.get(kBodyMass,
    // 1.0)`). StubPhysics implements this as a no-op — M0's kinematic-
    // only integrator has no collision pass to weight, and the M0
    // canonical hash stays byte-identical because no code path in
    // StubPhysics reads the value. Silently no-ops if id is unknown,
    // matching the other setters.
    virtual void     setBodyMass(EntityId id, math::Fixed64 mass) = 0;

    // Read -----------------------------------------------------------
    virtual EntityState               get(EntityId id) const = 0;
    virtual std::vector<EntityId>     all() const = 0;
    virtual bool                      contains(EntityId id) const = 0;
    virtual std::size_t               size() const = 0;

    // Integrate for dt seconds (fixed-point). M0: position += velocity * dt.
    virtual void step(math::Fixed64 dt) = 0;
};

} // namespace fh::sim::physics
