// sim/src/math/Vec3.hpp
//
// 3D vector in Fixed64 pitch space. Also provides Vec2 for 2D helpers.
// See DESIGN.md §5.1 and §9 (coordinate system).
//
// Component order convention:
//   x : along pitch length (touchline-to-touchline direction)  [-52.5, +52.5] m
//   y : across pitch width (goal-line-to-goal-line direction)  [-34, +34]     m
//   z : up (reserved for 3D physics; zero in M0)

#pragma once

#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"

namespace fh::sim::math {

struct Vec2 {
    Fixed64 x, y;

    constexpr Vec2() noexcept : x{}, y{} {}
    constexpr Vec2(Fixed64 xi, Fixed64 yi) noexcept : x{xi}, y{yi} {}

    constexpr Vec2 operator+(Vec2 rhs) const noexcept { return {x + rhs.x, y + rhs.y}; }
    constexpr Vec2 operator-(Vec2 rhs) const noexcept { return {x - rhs.x, y - rhs.y}; }
    constexpr Vec2 operator-()         const noexcept { return {-x, -y}; }
    constexpr Vec2 operator*(Fixed64 s) const noexcept { return {x * s, y * s}; }

    constexpr Vec2& operator+=(Vec2 rhs) noexcept { x += rhs.x; y += rhs.y; return *this; }
    constexpr Vec2& operator-=(Vec2 rhs) noexcept { x -= rhs.x; y -= rhs.y; return *this; }

    constexpr auto operator<=>(const Vec2&) const noexcept = default;

    inline Fixed64 length()     const noexcept;
    inline Vec2    normalized() const noexcept;
};

struct Vec3 {
    Fixed64 x, y, z;

    constexpr Vec3() noexcept : x{}, y{}, z{} {}
    constexpr Vec3(Fixed64 xi, Fixed64 yi, Fixed64 zi) noexcept
        : x{xi}, y{yi}, z{zi} {}

    constexpr Vec3 operator+(Vec3 rhs) const noexcept {
        return {x + rhs.x, y + rhs.y, z + rhs.z};
    }
    constexpr Vec3 operator-(Vec3 rhs) const noexcept {
        return {x - rhs.x, y - rhs.y, z - rhs.z};
    }
    constexpr Vec3 operator-() const noexcept { return {-x, -y, -z}; }
    constexpr Vec3 operator*(Fixed64 s) const noexcept {
        return {x * s, y * s, z * s};
    }

    constexpr Vec3& operator+=(Vec3 rhs) noexcept {
        x += rhs.x; y += rhs.y; z += rhs.z; return *this;
    }
    constexpr Vec3& operator-=(Vec3 rhs) noexcept {
        x -= rhs.x; y -= rhs.y; z -= rhs.z; return *this;
    }

    constexpr auto operator<=>(const Vec3&) const noexcept = default;

    // Member wrappers around the free functions defined below. Implemented
    // out-of-line so they can call fx_sqrt etc. without header-order pain.
    inline Fixed64 length()     const noexcept;
    inline Vec3    normalized() const noexcept;
};

// -----------------------------------------------------------------------------
// Free functions
// -----------------------------------------------------------------------------

constexpr Fixed64 dot(Vec2 a, Vec2 b) noexcept { return a.x * b.x + a.y * b.y; }
constexpr Fixed64 dot(Vec3 a, Vec3 b) noexcept {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

// Length. Uses fx_sqrt — deterministic.
inline Fixed64 length(Vec2 v) noexcept { return fx_hypot(v.x, v.y); }
inline Fixed64 length(Vec3 v) noexcept {
    return fx_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}
constexpr Fixed64 lengthSquared(Vec2 v) noexcept { return v.x * v.x + v.y * v.y; }
constexpr Fixed64 lengthSquared(Vec3 v) noexcept {
    return v.x * v.x + v.y * v.y + v.z * v.z;
}

// Normalize. Returns zero vector if input is zero.
inline Vec2 normalized(Vec2 v) noexcept {
    const Fixed64 L = length(v);
    if (L.raw == 0) return {};
    return {v.x / L, v.y / L};
}
inline Vec3 normalized(Vec3 v) noexcept {
    const Fixed64 L = length(v);
    if (L.raw == 0) return {};
    return {v.x / L, v.y / L, v.z / L};
}

// Convenience member wrappers so callers can write `v.length()` /
// `v.normalized()` interchangeably with the free-function form. The free
// functions remain the canonical definitions; these just forward.
inline Fixed64 Vec2::length()     const noexcept { return math::length(*this); }
inline Vec2    Vec2::normalized() const noexcept { return math::normalized(*this); }
inline Fixed64 Vec3::length()     const noexcept { return math::length(*this); }
inline Vec3    Vec3::normalized() const noexcept { return math::normalized(*this); }

}  // namespace fh::sim::math
