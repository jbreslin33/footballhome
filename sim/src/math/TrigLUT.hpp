// sim/src/math/TrigLUT.hpp
//
// Deterministic lookup tables for trigonometry.
//
//  sin/cos: 4096 entries covering [0, 2π), linearly interpolated.
//  atan2:   2048 entries covering the ratio y/x ∈ [0, 1], with quadrant
//           fold-in done in fx_atan2 (see FixedMath).
//
// Tables are populated at first use (thread-safe via std::call_once) from
// double-precision math. The double math runs exactly once per process and
// its output is written into an int64_t array, so the *stored* table is
// bit-identical across every run and every host regardless of libm.
//
// Design ref: sim/DESIGN.md §5.1, §10.

#pragma once

#include <cstdint>

namespace fh::sim::math {

// Compile-time sizes.
inline constexpr int SIN_LUT_BITS = 12;                            // 4096 entries
inline constexpr int SIN_LUT_SIZE = 1 << SIN_LUT_BITS;
inline constexpr int ATAN_LUT_BITS = 11;                            // 2048 entries
inline constexpr int ATAN_LUT_SIZE = 1 << ATAN_LUT_BITS;

// Access to the raw int64_t table entries. Each entry is Fixed64::raw for
// the corresponding function value. Consumers should use FixedMath::fx_sin
// etc., not read these directly.
namespace detail {
    const std::int64_t* sin_table();   // SIN_LUT_SIZE entries, sin(2π * i / SIN_LUT_SIZE)
    const std::int64_t* atan_table();  // ATAN_LUT_SIZE entries, atan(i / (SIN_LUT_SIZE - 1))
                                       // where atan_table[i] = atan(i / (ATAN_LUT_SIZE - 1))
}

}  // namespace fh::sim::math
