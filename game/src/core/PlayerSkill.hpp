// game/src/core/PlayerSkill.hpp
//
// G5.23 (DESIGN §8.121): a player's skill as the World's physics reads it —
// how late he sees, how true he kicks, how hot a ball he can control, how often
// his tackle wins it, a keeper's grip. One block per player. Replaces the
// u10 → world-cup level ladder (Levels.hpp, deleted with its swarm, decision
// jitter, talk/listen dials, concept abilities and attribute bending).
//
// Defaults = the old "pro" band's numbers — [FH] estimates, not data — until
// each is fitted: league-wide from StatsBomb PL 2015/16 (shots on target, save
// %, pass completion, …) as rows physics.skill.*, then per player from his own
// 2015/16 events.
//
// Determinism: detNoise is a pure hash of (match_seed, tick, slot, channel) —
// FNV-1a 64 (public domain); no RNG state, replays stay byte-identical.

#pragma once

#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"

#include <cstdint>

namespace fh::game::core {

struct PlayerSkill {
    std::int32_t perception_delay_ticks = 2;   // he reacts to where the ball was this many ticks ago
    std::int32_t kick_angle_err_deg = 2;       // a kick's direction error, max either way
    std::int32_t kick_power_err_pct = 3;       // its power error
    std::int32_t shot_angle_err_deg = -1;      // a shot's (−1 = the kick's)
    std::int32_t shot_power_err_pct = -1;
    std::int32_t control_speed_mps = 16;       // the fastest ball his first touch holds
    std::int32_t tackle_success_pct = 60;      // a dive in reach wins it
    std::int32_t keeper_fumble_pct = 5;        // a keeper's catch spills
    std::int32_t kick_range_m = 55;            // the longest ball he can hit
    std::int32_t intercept_control_pct = 62;   // a cut-out pass he keeps
    std::int32_t control_settle_ms = 350;      // his control touch, at rest
    std::int32_t control_per_mps_ms = 25;      // + per m/s the ball arrived at

    // The engine's baseline (no noise, no control touch): what a bare World
    // starts with, so the physics tests don't depend on these numbers.
    static PlayerSkill perfect() {
        PlayerSkill k;
        k.perception_delay_ticks = k.kick_angle_err_deg = k.kick_power_err_pct = 0;
        k.control_speed_mps = k.tackle_success_pct = k.keeper_fumble_pct = k.kick_range_m = 0;
        k.intercept_control_pct = k.control_settle_ms = k.control_per_mps_ms = 0;
        return k;
    }

    // League-wide numbers: physics.skill.<field> rows (whole units).
    void configure(const ModelParams& p) {
        perception_delay_ticks = p.integer("physics.skill.perception_delay_ticks", perception_delay_ticks);
        kick_angle_err_deg = p.integer("physics.skill.kick_angle_err_deg", kick_angle_err_deg);
        kick_power_err_pct = p.integer("physics.skill.kick_power_err_pct", kick_power_err_pct);
        shot_angle_err_deg = p.integer("physics.skill.shot_angle_err_deg", shot_angle_err_deg);
        shot_power_err_pct = p.integer("physics.skill.shot_power_err_pct", shot_power_err_pct);
        control_speed_mps = p.integer("physics.skill.control_speed_mps", control_speed_mps);
        tackle_success_pct = p.integer("physics.skill.tackle_success_pct", tackle_success_pct);
        keeper_fumble_pct = p.integer("physics.skill.keeper_fumble_pct", keeper_fumble_pct);
        kick_range_m = p.integer("physics.skill.kick_range_m", kick_range_m);
        intercept_control_pct = p.integer("physics.skill.intercept_control_pct", intercept_control_pct);
        control_settle_ms = p.integer("physics.skill.control_settle_ms", control_settle_ms);
        control_per_mps_ms = p.integer("physics.skill.control_per_mps_ms", control_per_mps_ms);
    }
};

// Pure deterministic noise in [-1, 1) as Fixed64; channel separates uses within one (tick, slot).
inline math::Fixed64 detNoise(std::uint64_t match_seed, std::uint64_t tick, std::uint8_t slot, std::uint8_t channel) {
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
    const std::int64_t frac = static_cast<std::int64_t>(h >> 31) & ((std::int64_t{1} << 33) - 1);
    return math::Fixed64::fromRaw(frac - (std::int64_t{1} << 32));
}

}  // namespace fh::game::core
