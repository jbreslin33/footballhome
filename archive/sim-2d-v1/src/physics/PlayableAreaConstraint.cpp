// footballhome sim - PlayableAreaConstraint (impl)
//
// Slice 17.1: apply_hard boundary clamp for convex polygons.
// Slice 17.2: apply_soft inward spring for convex polygons.
//
// See PlayableAreaConstraint.hpp for the contract.

#include "physics/PlayableAreaConstraint.hpp"

#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"

#include <cstddef>

namespace fh::sim::physics {

namespace {

using math::Fixed64;
using math::Vec3;

// Signed 2D cross product of (b - a) with (c - a). Positive when
// (a, b, c) is a left turn (CCW), negative for a right turn (CW),
// zero for collinear. All ops are Fixed64 — no float promotion.
inline Fixed64 cross2d(const Vec3& a, const Vec3& b, const Vec3& c) noexcept
{
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

// Closest point on the segment [a, b] to point p, considering only
// the XY components. Returns a Vec3 with z = 0 (caller preserves the
// original pos.z separately).
//
// Standard clamped-projection: t = clamp(dot(p-a, b-a) / |b-a|^2, 0, 1).
// If |b-a|^2 == 0 (degenerate edge), returns a — caller filters this.
Vec3 closestPointOnSegment(const Vec3& a, const Vec3& b, const Vec3& p) noexcept
{
    const Vec3    ab   = Vec3{b.x - a.x, b.y - a.y, Fixed64::zero()};
    const Fixed64 abSq = ab.x * ab.x + ab.y * ab.y;
    if (abSq.raw == 0) { return a; }
    const Vec3    ap  = Vec3{p.x - a.x, p.y - a.y, Fixed64::zero()};
    const Fixed64 dotAp = ap.x * ab.x + ap.y * ab.y;
    // t = dotAp / abSq, clamped to [0, 1].
    Fixed64 t = dotAp / abSq;
    if (t.raw < Fixed64::zero().raw) { t = Fixed64::zero(); }
    if (t.raw > Fixed64::one().raw)  { t = Fixed64::one();  }
    return Vec3{a.x + ab.x * t, a.y + ab.y * t, Fixed64::zero()};
}

// Result of the shared "find nearest boundary point + outward normal"
// step used by both apply_hard and apply_soft. `outside` is false when
// the point is inside or on the polygon boundary (in which case the
// other fields are unspecified and callers should short-circuit).
struct BoundaryHit {
    bool    outside;
    Vec3    closest_pt;     // z = 0
    Vec3    outward_normal; // unit vector, z = 0
    Fixed64 penetration;    // 0 if !outside; else |p - closest_pt|
};

// Shared engine for apply_hard and apply_soft. Handles:
//   1. Defensive no-op for empty / <3-vertex / all-collinear polygons.
//   2. Point-in-convex-polygon test.
//   3. Nearest-edge projection + outward-normal computation.
//
// Returns { outside=false } when the point is inside (or the polygon
// is degenerate) — caller must no-op.
BoundaryHit findBoundary(const Vec3& p_xy,
                         const std::vector<Vec3>& polygon) noexcept
{
    BoundaryHit hit{};
    hit.outside = false;

    const std::size_t n = polygon.size();
    if (n < 3) { return hit; }

    // Winding sign from the first non-collinear vertex triple.
    Fixed64 winding = Fixed64::zero();
    for (std::size_t i = 0; i < n; ++i) {
        const Vec3& a = polygon[i];
        const Vec3& b = polygon[(i + 1) % n];
        const Vec3& c = polygon[(i + 2) % n];
        const Fixed64 s = cross2d(a, b, c);
        if (s.raw != 0) { winding = s; break; }
    }
    if (winding.raw == 0) { return hit; }   // degenerate polygon

    // Point-in-convex-polygon test.
    bool inside = true;
    for (std::size_t i = 0; i < n; ++i) {
        const Vec3& a = polygon[i];
        const Vec3& b = polygon[(i + 1) % n];
        const Fixed64 s = cross2d(a, b, p_xy);
        if (s.raw != 0 &&
            ((s.raw > 0) != (winding.raw > 0)))
        {
            inside = false;
            break;
        }
    }
    if (inside) { return hit; }

    // Find nearest boundary point (per-edge projection).
    std::size_t best_i = 0;
    Vec3        best_pt{};
    Fixed64     best_dsq{Fixed64::fromRaw(std::int64_t{0x7fffffffffffffffLL})};

    for (std::size_t i = 0; i < n; ++i) {
        const Vec3& a = polygon[i];
        const Vec3& b = polygon[(i + 1) % n];
        const Vec3  q = closestPointOnSegment(a, b, p_xy);
        const Fixed64 dx = p_xy.x - q.x;
        const Fixed64 dy = p_xy.y - q.y;
        const Fixed64 dsq = dx * dx + dy * dy;
        if (dsq.raw < best_dsq.raw) {
            best_dsq = dsq;
            best_pt  = q;
            best_i   = i;
        }
    }

    // Outward-pointing unit normal of the winning edge.
    const Vec3&   a = polygon[best_i];
    const Vec3&   b = polygon[(best_i + 1) % n];
    const Fixed64 tx = b.x - a.x;
    const Fixed64 ty = b.y - a.y;

    Vec3 outward_dir;
    if (winding.raw > 0) {
        outward_dir = Vec3{ty, -tx, Fixed64::zero()};
    } else {
        outward_dir = Vec3{-ty, tx, Fixed64::zero()};
    }
    const Fixed64 nlen = math::fx_hypot(outward_dir.x, outward_dir.y);
    if (nlen.raw == 0) { return hit; }   // zero-length winning edge

    hit.outside        = true;
    hit.closest_pt     = best_pt;
    hit.outward_normal = Vec3{outward_dir.x / nlen, outward_dir.y / nlen,
                              Fixed64::zero()};
    // Penetration depth = |p - closest_pt|. Reuse dx/dy from the winning
    // iteration would require plumbing them out — cheaper to just recompute
    // here since we already know the winning point.
    const Fixed64 pdx = p_xy.x - best_pt.x;
    const Fixed64 pdy = p_xy.y - best_pt.y;
    hit.penetration    = math::fx_hypot(pdx, pdy);
    return hit;
}

} // namespace

void apply_hard(math::Vec3& pos,
                math::Vec3& vel,
                const std::vector<math::Vec3>& polygon) noexcept
{
    const Vec3 p_xy{pos.x, pos.y, Fixed64::zero()};
    const BoundaryHit hit = findBoundary(p_xy, polygon);
    if (!hit.outside) { return; }

    // Snap position (XY only; z preserved).
    pos.x = hit.closest_pt.x;
    pos.y = hit.closest_pt.y;

    // Zero the outward-facing component of vel only if it is > 0.
    // Tangential and inward-facing components are preserved so the
    // player can slide along the wall and move back into the polygon.
    const Fixed64 outward_dot =
        vel.x * hit.outward_normal.x + vel.y * hit.outward_normal.y;
    if (outward_dot.raw > 0) {
        vel.x = vel.x - hit.outward_normal.x * outward_dot;
        vel.y = vel.y - hit.outward_normal.y * outward_dot;
    }
    // vel.z is preserved (grounded game — z reserved).
}

void apply_soft(math::Vec3& pos,
                math::Vec3& vel,
                const std::vector<math::Vec3>& polygon,
                math::Fixed64 k) noexcept
{
    const Vec3 p_xy{pos.x, pos.y, Fixed64::zero()};
    const BoundaryHit hit = findBoundary(p_xy, polygon);
    if (!hit.outside) { return; }

    // Inward normal = -outward_normal. Apply the velocity delta
    // proportional to penetration depth × k.
    //
    // Position is NOT clamped: the player is allowed to briefly leave
    // the polygon; the accumulating inward velocity delta over
    // subsequent ticks bounces them back.
    const Fixed64 mag = hit.penetration * k;
    vel.x = vel.x - hit.outward_normal.x * mag;
    vel.y = vel.y - hit.outward_normal.y * mag;
    // vel.z is preserved.
}

} // namespace fh::sim::physics
