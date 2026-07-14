// footballhome sim - PlayableAreaConstraint
//
// Slice 17.1: Hard-mode boundary clamp.
// Slice 17.2: Soft-mode inward force proportional to outward penetration.
//
// Contract:
//
//   apply_hard(pos, vel, polygon)
//     If the polygon has fewer than 3 vertices → no-op (defensive; an
//     empty polygon is the M0 "no constraint" configuration).
//
//     Otherwise the polygon is assumed convex and its vertices listed in
//     either winding order (CW or CCW — the module infers the sign from
//     the first non-collinear vertex triple). M1's shipped scenarios use
//     a rectangle covering half of the 105×68 m pitch (HalfPitchScenario)
//     or a smaller rectangle inside it (SoftDrillScenario), both of which
//     satisfy the convexity assumption.
//
//     Only the XY components of pos and vel are considered; pos.z and
//     vel.z are preserved as-is (M0/M1 are grounded — z is reserved for
//     3D physics in later milestones).
//
//     If the (x, y) point lies inside the polygon (or on its boundary),
//     pos and vel are left untouched. Otherwise:
//
//       1. Find the closest point on the polygon boundary (nearest edge
//          projection, clamped to segment endpoints).
//       2. Snap pos.x/pos.y to that closest point.
//       3. Compute the outward-pointing unit normal of the winning edge.
//       4. If vel has an outward-facing component (`dot(vel_xy, n) > 0`),
//          subtract it out — i.e., allow the player to slide tangentially
//          along the wall and to move back inward, but not to push further
//          out. If vel is already tangential or inward, it is unchanged.
//
//     After apply_hard, the (x, y) point is guaranteed to lie on the
//     polygon's boundary or interior, and vel has no outward-facing
//     component perpendicular to the winning edge.
//
//   apply_soft(pos, vel, polygon, k)
//     Same polygon assumptions as apply_hard (convex, ≥3 vertices; XY
//     only). If the (x, y) point lies inside the polygon (or on its
//     boundary), pos and vel are left untouched.
//
//     Otherwise:
//
//       1. Find the closest point on the polygon boundary (same routine
//          as apply_hard).
//       2. Compute penetration depth = |p - closest_point|.
//       3. Compute the inward-pointing unit normal (opposite of the
//          outward normal used by apply_hard).
//       4. Apply an inward-facing velocity delta:
//            vel += inward_normal * (penetration_depth * k)
//          The delta is added BEFORE position integration, so the next
//          physics step naturally advects the player back toward the
//          polygon. `k` has units of 1/s (spring stiffness). Higher `k`
//          → sharper snap-back; lower `k` → gentler drift.
//       5. **Position is NOT clamped**. Soft mode explicitly allows the
//          player to briefly leave the polygon (a lunging tackle, an
//          over-run) — the accumulating inward velocity delta over
//          multiple ticks bounces them back.
//
//     After apply_soft, the (x, y) point is unchanged and vel has an
//     extra inward-facing component sized to the penetration depth.
//
// Determinism:
//   Everything runs in Fixed64. apply_hard uses signed 2D cross products
//   for the point-in-polygon test (no sqrt). apply_soft additionally
//   evaluates one fx_hypot for the penetration depth. Edge projection
//   uses one Fixed64 divide per edge (edge_length_squared > 0 is
//   guaranteed by the convex-polygon assumption plus a zero-length-edge
//   defensive skip). All ordering (edge iteration, tie-breaking on equal
//   distances) is deterministic and independent of host arch.
//
// See DESIGN.md §5.6 (PlayableArea semantics), §23.3 Slice 17.1, 17.2.

#pragma once

#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <vector>

namespace fh::sim::physics {

// Slice 17.1 — Hard-mode boundary clamp. See file header for contract.
void apply_hard(math::Vec3& pos,
                math::Vec3& vel,
                const std::vector<math::Vec3>& polygon) noexcept;

// Slice 17.2 — Soft-mode inward spring. See file header for contract.
void apply_soft(math::Vec3& pos,
                math::Vec3& vel,
                const std::vector<math::Vec3>& polygon,
                math::Fixed64 k) noexcept;

} // namespace fh::sim::physics
