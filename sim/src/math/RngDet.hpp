// sim/src/math/RngDet.hpp
//
// Deterministic random-number generator wrapper.
//
// Uses std::mt19937_64 because its output is fully specified by the C++
// standard: same seed produces identical uint64_t sequence on every
// conforming implementation. See DESIGN.md §10 rule 3.
//
// Do NOT use std::random_device, std::default_random_engine, or std::rand().
// Do NOT use distribution objects from <random> in gameplay — their
// implementations are not portable. Compute distributions by hand from
// raw uint64_t outputs.

#pragma once

#include "math/Fixed64.hpp"

#include <cstdint>
#include <random>

namespace fh::sim::math {

class RngDet {
public:
    explicit RngDet(std::uint64_t seed) noexcept : eng_{seed} {}

    // Raw 64-bit output. Deterministic.
    std::uint64_t nextU64() noexcept { return eng_(); }

    // Uniform Fixed64 in [0, 1). Uses the top 32 bits of the raw output as
    // the fractional part of a Q32.32.
    Fixed64 nextUnit() noexcept {
        const std::uint64_t r = eng_();
        // Take upper 32 bits so the result is a valid Fixed64 fractional.
        return Fixed64::fromRaw(
            static_cast<std::int64_t>(r >> 32) & Fixed64::FRAC_MASK);
    }

    // Uniform Fixed64 in [lo, hi). Requires hi > lo. Deterministic.
    Fixed64 nextRange(Fixed64 lo, Fixed64 hi) noexcept {
        const Fixed64 t = nextUnit();
        return lo + (hi - lo) * t;
    }

    // Uniform integer in [lo, hi) using rejection sampling (no modulo bias).
    std::int32_t nextInt(std::int32_t lo, std::int32_t hi) noexcept {
        // Callers must ensure hi > lo.
        const std::uint64_t span = static_cast<std::uint64_t>(hi - lo);
        // Reject values above the largest multiple of span that fits in 2^64.
        const std::uint64_t limit = ~std::uint64_t{0} - (~std::uint64_t{0} % span);
        std::uint64_t r;
        do { r = eng_(); } while (r >= limit);
        return lo + static_cast<std::int32_t>(r % span);
    }

private:
    std::mt19937_64 eng_;
};

}  // namespace fh::sim::math
