// footballhome sim - BasicPhysics
//
// Slice 27.2 (ADR §22.24). Successor to StubPhysics for M2+ scenarios
// that need player-vs-player collision resolution. Adds two behaviours
// on top of StubPhysics's kinematic integrator:
//
//   1. Circle-circle collision pass at the end of every step():
//      positional-clamp + tangential-slide (option B in ADR §22.24).
//      Iterates every player-vs-player pair in ascending-EntityId order
//      (deterministic on Fixed64, stateless across ticks), computes the
//      minimum-translation-vector (MTV) along the centre-to-centre
//      normal, splits the displacement by inverse `body_mass`, then
//      zeroes each entity's closing-velocity component along the
//      normal (preserving tangential slide).
//
//   2. Per-entity body_mass storage (via IPhysicsWorld::setBodyMass).
//      Clamped to [0.5, 1.5] at read time so a mis-authored profile
//      can't destabilise the resolver. Default 1.0 for any entity
//      whose body_mass was never set.
//
// The ball entity (EntityDef::is_ball) is **always excluded** from the
// collision-candidate list — a narrowing of ADR §22.24's "excluded iff
// BallControl::owner().has_value()" clause; see the "Amendment
// 2026-07-17 (Slice 27.2)" section appended to that ADR. The narrowing
// is forced by kBallControlRadius=0.5 m < kPlayerContactRadius (0.4) +
// kBallContactRadius (~0.11) = 0.51 m: if the ball were in the
// collision list even when loose, an approaching defender would be
// MTV-clamped *away* from the ball before it ever got within
// kBallControlRadius, breaking BallControl's first-touch rule
// (Slice 16.3). The M2 rule "only wants_kick can accelerate the ball"
// remains intact — the ball is neither displaced by nor imparted
// velocity from a player intersecting it during the collision pass.
//
// See DESIGN.md §5.3, §22.24 (ADR), §24.3 / §24.5 Slice 27.

#pragma once

#include "physics/IPhysicsWorld.hpp"

#include <cstddef>
#include <unordered_map>
#include <unordered_set>

namespace fh::sim::physics {

// ---------------------------------------------------------------------
// Tuning constants (ADR §22.24 "Constants" section).
// ---------------------------------------------------------------------

// Per-player collision radius (m). Sum of two players' radii = 0.8 m
// body diameter. Deliberately a physics constant (not a per-player
// attribute) at M2; body-size variation via attribute is deferred to
// M4+ per §22.24's Revisit clause.
inline constexpr math::Fixed64 kPlayerContactRadius =
    math::Fixed64::fromFraction(4, 10);

// Squared-distance epsilon below which two entity centres are treated
// as coincident. On the epsilon branch the collision normal falls back
// to +x deterministically (no arch-dependent fp path). (0.01 m)^2.
inline constexpr math::Fixed64 kContactEpsilonSquared =
    math::Fixed64::fromFraction(1, 10000);

// body_mass runtime clamp (ADR §22.24). Lower value = displaced more
// per contact. Both endpoints inclusive.
inline constexpr math::Fixed64 kBodyMassMin =
    math::Fixed64::fromFraction(5, 10);
inline constexpr math::Fixed64 kBodyMassMax =
    math::Fixed64::fromFraction(15, 10);

// Default body_mass for any entity whose setBodyMass was never called.
// M0 profile default (physical.body_mass, migration 220) also 1.0, so
// a Match::spawnInitialSlots that forgets to plumb the default still
// gets the same behaviour as an explicit setBodyMass(_, 1.0).
inline constexpr math::Fixed64 kBodyMassDefault = math::Fixed64::fromInt(1);

class BasicPhysics : public IPhysicsWorld {
public:
    BasicPhysics() = default;

    EntityId spawn(const EntityDef& def) override;
    void     despawn(EntityId id) override;

    void     setVelocity(EntityId id, math::Vec3 v) override;
    void     setHeading(EntityId id, math::Fixed64 rad) override;
    void     setMotion(EntityId id, MotionState motion) override;
    void     setPosition(EntityId id, math::Vec3 pos) override;
    void     applyImpulse(EntityId id, math::Vec3 impulse) override;
    void     setBodyMass(EntityId id, math::Fixed64 mass) override;

    EntityState              get(EntityId id) const override;
    std::vector<EntityId>    all() const override;
    bool                     contains(EntityId id) const override;
    std::size_t              size() const override { return entities_.size(); }

    void step(math::Fixed64 dt) override;

private:
    // Read body_mass with the [0.5, 1.5] clamp applied. Falls back to
    // kBodyMassDefault (1.0) if the entity has no explicit mass row.
    math::Fixed64 clampedBodyMass(EntityId id) const;

    // Player-vs-player collision pass; called at the tail of step().
    // Balls (entries in ball_ids_) are excluded from the candidate
    // list before iteration begins.
    void resolveCollisions();

    EntityId                                    next_id_{1};
    std::unordered_map<EntityId, EntityState>   entities_;
    std::unordered_map<EntityId, math::Fixed64> body_mass_;
    std::unordered_set<EntityId>                ball_ids_;
};

} // namespace fh::sim::physics
