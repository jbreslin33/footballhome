// footballhome sim - PlayableAreaConstraint (impl)
//
// Slice 17.1: apply_hard boundary clamp for convex polygons.
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

inline Fixed64 dot2d(const Vec3& a, const Vec3& b) noexcept
{
    return a.x * b.x + a.y * b.y;
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

} // namespace

void apply_hard(math::Vec3& pos,
                math::Vec3& vel,
                const std::vector<math::Vec3>& polygon) noexcept
{
    const std::size_t n = polygon.size();
    if (n < 3) { return; }   // no constraint

    // Winding sign: pick the first non-zero cross product from consecutive
    // vertex triples. For a convex polygon this fixes the "which side is
    // inside" question globally. If all triples are collinear the polygon
    // is degenerate — treat as no-op.
    Fixed64 winding = Fixed64::zero();
    for (std::size_t i = 0; i < n; ++i) {
        const Vec3& a = polygon[i];
        const Vec3& b = polygon[(i + 1) % n];
        const Vec3& c = polygon[(i + 2) % n];
        const Fixed64 s = cross2d(a, b, c);
        if (s.raw != 0) { winding = s; break; }
    }
    if (winding.raw == 0) { return; }

    // Point-in-convex-polygon: for each edge (v[i], v[i+1]), check that
    // cross2d(v[i], v[i+1], p) has the same sign as winding (allowing
    // zero → on the edge counts as inside).
    const Vec3 p2d{pos.x, pos.y, Fixed64::zero()};
    bool inside = true;
    for (std::size_t i = 0; i < n; ++i) {
        const Vec3& a = polygon[i];
        const Vec3& b = polygon[(i + 1) % n];
        const Fixed64 s = cross2d(a, b, p2d);
        // s and winding must have the same sign (or s == 0).
        if (s.raw != 0 &&
            ((s.raw > 0) != (winding.raw > 0)))
        {
            inside = false;
            break;
        }
    }
    if (inside) { return; }

    // Outside: find the nearest boundary point. Iterate all edges,
    // project p2d onto each, track the minimum squared distance.
    // Tie-break: first winning edge in iteration order — deterministic
    // because iteration order is fixed by the polygon vertex sequence.
    std::size_t best_i = 0;
    Vec3        best_pt{};
    Fixed64     best_dsq{Fixed64::fromRaw(std::int64_t{0x7fffffffffffffffLL})};

    for (std::size_t i = 0; i < n; ++i) {
        const Vec3& a = polygon[i];
        const Vec3& b = polygon[(i + 1) % n];
        const Vec3  q = closestPointOnSegment(a, b, p2d);
        const Fixed64 dx = p2d.x - q.x;
        const Fixed64 dy = p2d.y - q.y;
        const Fixed64 dsq = dx * dx + dy * dy;
        if (dsq.raw < best_dsq.raw) {
            best_dsq = dsq;
            best_pt  = q;
            best_i   = i;
        }
    }

    // Snap position (XY only; z preserved).
    pos.x = best_pt.x;
    pos.y = best_pt.y;

    // Compute the outward-pointing unit normal for the winning edge.
    // Edge tangent t = (v[i+1] - v[i]). The two perpendiculars are
    // (t.y, -t.x) and (-t.y, t.x). The one that points AWAY from the
    // polygon interior is the outward normal.
    //
    // For a polygon whose winding sign is positive (CCW), the interior
    // lies on the LEFT of each edge, so the outward normal is (t.y, -t.x).
    // For negative winding (CW), interior is on the RIGHT, so outward is
    // (-t.y, t.x). We branch on the sign of `winding` computed above.
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
    // Normalize (safe: winning edge has non-zero length or
    // closestPointOnSegment would have returned a and dsq would still be
    // well-defined; but we filter zero-length edges defensively).
    const Fixed64 nlen = math::fx_hypot(outward_dir.x, outward_dir.y);
    if (nlen.raw == 0) { return; }
    const Vec3 n_out{outward_dir.x / nlen, outward_dir.y / nlen,
                     Fixed64::zero()};

    // Zero the outward-facing component of vel only if it is > 0.
    // Tangential and inward-facing components are preserved so the
    // player can slide along the wall and move back into the polygon.
    const Fixed64 outward_dot = vel.x * n_out.x + vel.y * n_out.y;
    if (outward_dot.raw > 0) {
        vel.x = vel.x - n_out.x * outward_dot;
        vel.y = vel.y - n_out.y * outward_dot;
    }
    // vel.z is preserved (grounded game — z reserved).
}

} // namespace fh::sim::physics
