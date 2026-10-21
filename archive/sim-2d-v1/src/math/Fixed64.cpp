// sim/src/math/Fixed64.cpp
//
// Non-constexpr Fixed64 members — the float/double conversion boundaries.
// See Fixed64.hpp header for full contract.

#include "math/Fixed64.hpp"

#include <cmath>     // std::nearbyint
#include <cfenv>     // (not used, but documents that we care about rounding)

namespace fh::sim::math {

// ---- fromFloat / fromDouble -------------------------------------------------
// Boundary function. Runs only at DB-load and test-construction. Uses
// nearbyint with the current rounding mode (default: round-to-nearest,
// ties-to-even) to produce a deterministic result per-platform. Callers must
// treat this as approximate — do not round-trip Fixed64→float→Fixed64 in
// gameplay code.

Fixed64 Fixed64::fromFloat(float f) noexcept {
    // Clamp defensively so pathological inputs (NaN, ±inf, values outside
    // ±2^31) don't produce garbage. INT64_MIN is reserved for "unset" by
    // convention elsewhere; here we just saturate.
    if (!(f == f)) return Fixed64{0};                 // NaN → 0
    const double scaled = static_cast<double>(f) * static_cast<double>(ONE);
    if (scaled >  9.223372036854775e18) return Fixed64{INT64_MAX};
    if (scaled < -9.223372036854775e18) return Fixed64{INT64_MIN};
    return Fixed64{static_cast<std::int64_t>(std::nearbyint(scaled))};
}

Fixed64 Fixed64::fromDouble(double d) noexcept {
    if (!(d == d)) return Fixed64{0};
    const double scaled = d * static_cast<double>(ONE);
    if (scaled >  9.223372036854775e18) return Fixed64{INT64_MAX};
    if (scaled < -9.223372036854775e18) return Fixed64{INT64_MIN};
    return Fixed64{static_cast<std::int64_t>(std::nearbyint(scaled))};
}

// ---- toFloat / toDouble -----------------------------------------------------
// Boundary function. Wire encoding and debug logs only. NOT used in gameplay.

float Fixed64::toFloat() const noexcept {
    return static_cast<float>(static_cast<double>(raw)
                              / static_cast<double>(ONE));
}

double Fixed64::toDouble() const noexcept {
    return static_cast<double>(raw) / static_cast<double>(ONE);
}

}  // namespace fh::sim::math
