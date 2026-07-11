// sim/src/math/TrigLUT.cpp
//
// Table population. Uses <cmath> exactly once at process startup to fill
// int64_t arrays. From then on, every gameplay caller only sees integer
// data — deterministic across compilers, libcs, and CPUs.

#include "math/TrigLUT.hpp"
#include "math/Fixed64.hpp"

#include <array>
#include <cmath>
#include <mutex>

namespace fh::sim::math::detail {

namespace {

constexpr double kPI  = 3.14159265358979323846;
constexpr double kTAU = 2.0 * kPI;

std::array<std::int64_t, SIN_LUT_SIZE>  g_sin;
std::array<std::int64_t, ATAN_LUT_SIZE> g_atan;
std::once_flag g_once;

void populate() {
    // sin: uniform over [0, 2π)
    for (int i = 0; i < SIN_LUT_SIZE; ++i) {
        const double theta = kTAU * (static_cast<double>(i)
                                     / static_cast<double>(SIN_LUT_SIZE));
        const double v = std::sin(theta);
        const double scaled = v * static_cast<double>(Fixed64::ONE);
        g_sin[static_cast<std::size_t>(i)] =
            static_cast<std::int64_t>(std::nearbyint(scaled));
    }

    // atan: y/x ratio in [0, 1], where entry i corresponds to ratio
    //   r = i / (ATAN_LUT_SIZE - 1)
    // We store atan(r) as Fixed64 raw. Range: [0, π/4].
    for (int i = 0; i < ATAN_LUT_SIZE; ++i) {
        const double r = static_cast<double>(i)
                       / static_cast<double>(ATAN_LUT_SIZE - 1);
        const double v = std::atan(r);
        const double scaled = v * static_cast<double>(Fixed64::ONE);
        g_atan[static_cast<std::size_t>(i)] =
            static_cast<std::int64_t>(std::nearbyint(scaled));
    }
}

void ensure_populated() {
    std::call_once(g_once, populate);
}

}  // namespace

const std::int64_t* sin_table() {
    ensure_populated();
    return g_sin.data();
}

const std::int64_t* atan_table() {
    ensure_populated();
    return g_atan.data();
}

}  // namespace fh::sim::math::detail
