// game/src/core/Clock.hpp
//
// Tick clock. The simulation advances in fixed ticks; wall-clock pacing is a
// server concern (DESIGN.md §4: sim speed is a parameter — 1x live, Nx
// fast-forward, headless max-speed) and never enters the sim loop.

#pragma once

#include "math/Fixed64.hpp"

#include <cstdint>

namespace fh::game::core {

inline constexpr std::int32_t kTickRate = 30;  // ticks per simulated second

// Fixed-point tick duration in seconds (1/30). fromFraction is exact and
// deterministic — this constant participates in every integration step.
inline const math::Fixed64 kTickDt = math::Fixed64::fromFraction(1, kTickRate);

class Clock {
public:
    Clock() noexcept = default;

    void advance() noexcept { ++tick_; }

    std::uint64_t tick() const noexcept { return tick_; }

private:
    std::uint64_t tick_ = 0;
};

}  // namespace fh::game::core
