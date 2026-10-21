// footballhome sim - BasicPhysics implementation
//
// See BasicPhysics.hpp for the header-level contract and ADR §22.24
// for the design rationale. The two behaviours new to Slice 27.2
// versus StubPhysics live in the trailing collision pass invoked from
// step():
//
//   * Positional-clamp: circles overlap by penetration p along the
//     centre-to-centre normal `n = normalize(a.pos - b.pos)`; split the
//     displacement by inverse body_mass so a moves +normal by
//     p * mass_b/(mass_a+mass_b) and b moves -normal by
//     p * mass_a/(mass_a+mass_b). Equal masses each move p/2.
//
//   * Tangential-slide: independently for each entity, if its velocity
//     has a component "toward the contact" (a: dot(v_a, +normal) < 0;
//     b: dot(v_b, +normal) > 0), subtract that component so the
//     tangential (perpendicular-to-normal) component is preserved. A
//     player who was sprinting into the shoulder of a defender loses
//     their forward impulse but can still slide sideways along the
//     defender's contact surface.
//
// Every arithmetic operation is Fixed64 (Q32.32, __int128 mul/div in
// Fixed64::operator*// and operator/) so the whole pass is bit-for-bit
// deterministic across amd64 / arm64. Ascending-EntityId pair
// iteration means the same PairKeys resolve in the same order on every
// replay — no per-tick contact-tracking state needed.

#include "physics/BasicPhysics.hpp"
#include "math/FixedMath.hpp"

#include <algorithm>

namespace fh::sim::physics {

EntityId BasicPhysics::spawn(const EntityDef& def)
{
    const EntityId id = next_id_++;
    EntityState e;
    e.id       = id;
    e.slot_id  = def.slot_id;
    e.position = def.position;
    e.velocity = def.velocity;
    e.heading  = math::Fixed64::zero();
    e.motion   = MotionState::Idle;
    (void)def.radius;   // M2: fixed per-role (kPlayerContactRadius);
                        // per-entity radius override is deferred to M4+.
    (void)def.height;
    entities_.emplace(id, e);
    if (def.is_ball) {
        // Ball is excluded from the collision candidate list per
        // ADR §22.24 (Amendment 2026-07-17). See BasicPhysics.hpp
        // header comment for the kBallControlRadius rationale.
        ball_ids_.insert(id);
    }
    return id;
}

void BasicPhysics::despawn(EntityId id)
{
    entities_.erase(id);
    body_mass_.erase(id);
    ball_ids_.erase(id);
}

void BasicPhysics::setVelocity(EntityId id, math::Vec3 v)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.velocity = v;
    }
}

void BasicPhysics::setHeading(EntityId id, math::Fixed64 rad)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.heading = rad;
    }
}

void BasicPhysics::setMotion(EntityId id, MotionState motion)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.motion = motion;
    }
}

void BasicPhysics::setPosition(EntityId id, math::Vec3 pos)
{
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.position = pos;
    }
}

void BasicPhysics::applyImpulse(EntityId id, math::Vec3 impulse)
{
    // Same additive-velocity convention as StubPhysics — real ball
    // physics is handled by BallPhysics::applyImpulse; the physics
    // world's applyImpulse is used only for direct velocity nudges.
    const auto it = entities_.find(id);
    if (it != entities_.end()) {
        it->second.velocity = it->second.velocity + impulse;
    }
}

void BasicPhysics::setBodyMass(EntityId id, math::Fixed64 mass)
{
    // Silently no-ops for unknown ids (matches setVelocity et al.).
    // The clamp to [0.5, 1.5] happens on READ in clampedBodyMass — we
    // store what the caller gave us so a diagnostic dump shows the
    // raw profile value, not a silently-clamped one.
    if (entities_.find(id) == entities_.end()) { return; }
    body_mass_[id] = mass;
}

EntityState BasicPhysics::get(EntityId id) const
{
    const auto it = entities_.find(id);
    if (it == entities_.end()) {
        return EntityState{};   // id=0 sentinel
    }
    return it->second;
}

std::vector<EntityId> BasicPhysics::all() const
{
    // Deterministic order: ascending EntityId, same convention as
    // StubPhysics. Match's WorldView builder, snapshot serializer,
    // and the collision pass below all rely on this.
    std::vector<EntityId> ids;
    ids.reserve(entities_.size());
    for (const auto& [id, _] : entities_) {
        ids.push_back(id);
    }
    std::sort(ids.begin(), ids.end());
    return ids;
}

bool BasicPhysics::contains(EntityId id) const
{
    return entities_.find(id) != entities_.end();
}

math::Fixed64 BasicPhysics::clampedBodyMass(EntityId id) const
{
    const auto it = body_mass_.find(id);
    const math::Fixed64 raw =
        (it == body_mass_.end()) ? kBodyMassDefault : it->second;
    if (raw < kBodyMassMin) { return kBodyMassMin; }
    if (raw > kBodyMassMax) { return kBodyMassMax; }
    return raw;
}

void BasicPhysics::step(math::Fixed64 dt)
{
    // Phase 1: kinematic integration. Same as StubPhysics.
    for (auto& [id, e] : entities_) {
        (void)id;
        e.position.x = e.position.x + e.velocity.x * dt;
        e.position.y = e.position.y + e.velocity.y * dt;
        e.position.z = e.position.z + e.velocity.z * dt;
    }

    // Phase 2: player-vs-player collision resolution (ADR §22.24
    // option B). Ball entities are excluded via ball_ids_ inside
    // resolveCollisions().
    resolveCollisions();
}

void BasicPhysics::resolveCollisions()
{
    using math::Fixed64;

    // Build the ascending-EntityId candidate list, ball(s) excluded.
    // Small allocation per tick — acceptable at M2 sizes (N <= 22);
    // reservable to a max-slot-count constant later if it shows up
    // in a profile.
    std::vector<EntityId> candidates;
    candidates.reserve(entities_.size());
    for (const auto& [id, _] : entities_) {
        if (ball_ids_.find(id) == ball_ids_.end()) {
            candidates.push_back(id);
        }
    }
    std::sort(candidates.begin(), candidates.end());

    if (candidates.size() < 2) { return; }   // no pairs to check

    // Sum-of-radii is constant across all player-vs-player pairs at
    // M2 (per-entity radius is deferred to M4+). Precompute once.
    const Fixed64 r_sum   = kPlayerContactRadius + kPlayerContactRadius;
    const Fixed64 r_sum_sq = r_sum * r_sum;

    for (std::size_t i = 0; i + 1 < candidates.size(); ++i) {
        for (std::size_t j = i + 1; j < candidates.size(); ++j) {
            EntityState& a = entities_.at(candidates[i]);
            EntityState& b = entities_.at(candidates[j]);

            // Distance in the horizontal plane only. z is reserved
            // for 3D physics (headers, jumps) — no collision impact
            // at M2 where every player-vs-player pair is at z=0.
            const Fixed64 dx = a.position.x - b.position.x;
            const Fixed64 dy = a.position.y - b.position.y;
            const Fixed64 d_sq = dx * dx + dy * dy;
            if (d_sq >= r_sum_sq) { continue; }   // no overlap

            // Non-degenerate normal even at exact coincidence. The
            // epsilon branch resolves to +x deterministically so
            // amd64 / arm64 don't diverge on the near-zero fp path.
            Fixed64 nx, ny;
            Fixed64 penetration;
            if (d_sq > kContactEpsilonSquared) {
                const Fixed64 d = math::fx_sqrt(d_sq);
                nx = dx / d;
                ny = dy / d;
                penetration = r_sum - d;
            } else {
                nx = Fixed64::one();
                ny = Fixed64::zero();
                penetration = r_sum;
            }

            // Mass split (Newton's inverse-mass convention).
            const Fixed64 mass_a = clampedBodyMass(candidates[i]);
            const Fixed64 mass_b = clampedBodyMass(candidates[j]);
            const Fixed64 total_mass = mass_a + mass_b;
            const Fixed64 disp_a = penetration * mass_b / total_mass;
            const Fixed64 disp_b = penetration * mass_a / total_mass;

            // Push a along +normal (away from b), b along -normal.
            a.position.x = a.position.x + nx * disp_a;
            a.position.y = a.position.y + ny * disp_a;
            b.position.x = b.position.x - nx * disp_b;
            b.position.y = b.position.y - ny * disp_b;

            // Tangential-slide velocity zap. For a: `normal` points
            // FROM b TO a, so a moving TOWARD b means
            // dot(a.velocity, normal) < 0. Subtract that negative
            // component to zero the "into contact" part while
            // preserving the tangential (perpendicular to normal)
            // component. Symmetric for b: b moving TOWARD a means
            // dot(b.velocity, normal) > 0, subtract that.
            const Fixed64 va_n = a.velocity.x * nx + a.velocity.y * ny;
            if (va_n < Fixed64::zero()) {
                a.velocity.x = a.velocity.x - nx * va_n;
                a.velocity.y = a.velocity.y - ny * va_n;
            }
            const Fixed64 vb_n = b.velocity.x * nx + b.velocity.y * ny;
            if (vb_n > Fixed64::zero()) {
                b.velocity.x = b.velocity.x - nx * vb_n;
                b.velocity.y = b.velocity.y - ny * vb_n;
            }
        }
    }
}

} // namespace fh::sim::physics
