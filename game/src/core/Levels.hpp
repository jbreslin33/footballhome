// game/src/core/Levels.hpp
//
// Skill-scaled noise — the level mechanism [FH] (DESIGN.md §5, §5.1):
// worse players PERCEIVE later, DECIDE worse, and EXECUTE sloppier. One
// parameter block per team; zero everywhere = the perfect-play baseline
// every existing golden locks (levels are config, defaults change nothing).
//
// Determinism: noise is a PURE hash of (match_seed, tick, slot, channel) —
// no RNG state object, so brains stay pure functions and replays stay
// byte-identical. FNV-1a 64 (public domain) supplies the mixing.

#pragma once

#include "math/Fixed64.hpp"

#include <cstdint>
#include <string_view>

namespace fh::game::core {

struct LevelParams {
    // Perception: the brain reacts to where the ball WAS this many ticks
    // ago (approximated linearly as pos - vel * delay — no history state).
    std::int32_t perception_delay_ticks = 0;
    // Execution: kick direction error, max degrees either way.
    std::int32_t kick_angle_err_deg = 0;
    // Execution: kick power error, max percent either way.
    std::int32_t kick_power_err_pct = 0;
    // Decision: jitter (percent) applied to pass/chase thresholds.
    std::int32_t decision_jitter_pct = 0;

    bool isZero() const noexcept {
        return perception_delay_ticks == 0 && kick_angle_err_deg == 0 &&
               kick_power_err_pct == 0 && decision_jitter_pct == 0;
    }
};

// The level ladder (§5.1: the history ladder IS the level ladder — tactical
// ERAS join these bands when concepts/recognitions land in G4.2b+).
// Numbers are first-pass; the calibration harness tunes them.
inline LevelParams levelParams(std::string_view name) {
    if (name == "u10")     return {18, 18, 25, 60};  // sees late, sprays it
    if (name == "u14")     return {12, 11, 18, 40};
    if (name == "amateur") return {7, 6, 10, 25};    // decent Sunday league
    if (name == "semipro") return {4, 3, 6, 12};
    if (name == "pro")     return {2, 2, 3, 5};
    if (name == "world")   return {1, 1, 2, 2};
    return {};  // "perfect" and anything unknown: the zero baseline
}

// Pure deterministic noise in [-1, 1) as Fixed64.
//   channel disambiguates uses within one (tick, slot).
inline math::Fixed64 detNoise(std::uint64_t match_seed, std::uint64_t tick,
                              std::uint8_t slot, std::uint8_t channel) {
    std::uint64_t h = 14695981039346656037ULL ^ match_seed;
    auto mix = [&h](std::uint64_t v) {
        for (int i = 0; i < 8; ++i) {
            h ^= (v >> (i * 8)) & 0xFFu;
            h *= 1099511628211ULL;
        }
    };
    mix(tick);
    mix(slot);
    mix(channel);
    // Top 33 bits → Fixed64 in [-1, 1): sign bit + 32 fraction bits.
    const std::int64_t frac =
        static_cast<std::int64_t>(h >> 31) & ((std::int64_t{1} << 33) - 1);
    return math::Fixed64::fromRaw(frac - (std::int64_t{1} << 32));
}

}  // namespace fh::game::core
