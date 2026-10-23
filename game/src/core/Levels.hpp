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

#include "core/ConceptRegistry.hpp"
#include "math/Fixed64.hpp"

#include <array>
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
    // Touch: fastest ball (m/s) this level can control first-time.
    // 0 = perfect (engine capture cap applies). A faster ball than this
    // bobbles off the touch instead of sticking.
    std::int32_t control_speed_mps = 0;
    // Tackling: chance a committed dive-in wins the ball (rest = beaten +
    // stunned in recovery). Dive EAGERNESS is not a separate dial — it
    // rides swarm_pct (the discipline dial): U-10s dive constantly, pros
    // pick their moment. "In u10 the players would not just retract
    // defensively they would dive in — and prob at higher levels too."
    std::int32_t tackle_success_pct = 0;  // 0 with zero params = no dives
    // Shape discipline [FH, James's law]: percent of swarm-to-the-ball in
    // everyone's positioning. 0 = positional play; high = the U-10 amoeba,
    // which BOTH crowds the defense (bodies stop goals) and bunches the
    // offense (no space to attack) — §5.1's 1860s end of the ladder.
    std::int32_t swarm_pct = 0;
    // Keeper reaction (G4.14, the G4.4 knob): ticks of shot flight before
    // the keeper's dive-lite starts tracking the actual trajectory — until
    // then he holds his angle-play spot. 0 = instant (the baseline every
    // earlier golden locks). Brain-side dial: deliberately NOT in the
    // canonical hash (the hash sees its effects through the intents).
    std::int32_t keeper_reaction_ticks = 0;
    // Keeper handling (G4.23): percent of shot-speed balls a keeper
    // reaches that he fumbles. World-side, so it IS in the canonical hash.
    std::int32_t keeper_fumble_pct = 0;
    // Shots (G4.30, per-player SHOOTING): angle / power error on Shot
    // kicks. -1 = the kick_* errors above (every band row leaves these at
    // -1, so a band alone shoots exactly as before).
    std::int32_t shot_angle_err_deg = -1;
    std::int32_t shot_power_err_pct = -1;

    bool isZero() const noexcept {
        return perception_delay_ticks == 0 && kick_angle_err_deg == 0 &&
               kick_power_err_pct == 0 && decision_jitter_pct == 0 &&
               control_speed_mps == 0 && swarm_pct == 0 &&
               tackle_success_pct == 0 && keeper_reaction_ticks == 0 &&
               keeper_fumble_pct == 0;
    }
};

// Stable wire ids for the bands (PROTOCOL.md §5 MATCH_SETTINGS; append-only).
inline constexpr const char* kLevelNames[] = {
    "perfect", "u10", "u14", "amateur", "semipro", "pro", "world"};
inline constexpr std::uint8_t kLevelCount = 7;

inline const char* levelName(std::uint8_t id) {
    return id < kLevelCount ? kLevelNames[id] : "perfect";
}
inline std::uint8_t levelId(std::string_view name) {
    for (std::uint8_t i = 0; i < kLevelCount; ++i)
        if (name == kLevelNames[i]) return i;
    return 0;
}

// The level ladder (§5.1: the history ladder IS the level ladder — tactical
// ERAS join these bands when concepts/recognitions land in G4.2b+).
// Numbers are first-pass; the calibration harness tunes them.
inline LevelParams levelParams(std::string_view name) {
    if (name == "u10")     return {18, 18, 25, 60, 6, 30, 80, 18, 40};  // amoeba
    if (name == "u14")     return {12, 13, 18, 40, 8, 35, 55, 15, 28};
    if (name == "amateur") return {7, 6, 10, 25, 10, 42, 30, 12, 22};  // Sunday
    if (name == "semipro") return {4, 3, 6, 12, 13, 50, 12, 11, 8};
    if (name == "pro")     return {2, 2, 3, 5, 16, 60, 4, 10, 5};
    if (name == "world")   return {1, 1, 2, 2, 18, 65, 0, 9, 2};
    return {};  // "perfect" and anything unknown: the zero baseline
}

// ── Per-player attributes (G4.30; DB registry game_attributes, mig 636) ─
// 0-100 per player, 50 = the team's band EXACTLY, -1 = not rated (band).
// Each attribute scales the band number(s) it names in game_attributes;
// a player is his band, bent by his attributes [FH]. New attributes = a
// registry row + a field here + the scaling below.
struct PlayerAttributes {
    std::int16_t pace = -1;          // top speed (paceSpeedCms)
    std::int16_t passing = -1;       // kick angle/power error on passes
    std::int16_t shooting = -1;      // shot angle/power error
    std::int16_t first_touch = -1;   // control speed
    std::int16_t tackling = -1;      // tackle success
    std::int16_t anticipation = -1;  // perception delay
    std::int16_t decisions = -1;     // decision jitter
    std::int16_t goalkeeping = -1;   // keeper reaction + fumbles
};

// Wire / registry order (game_attributes.sort_order; PROTOCOL 0x37).
inline constexpr int kAttributeCount = 8;
inline std::int16_t* attributeAt(PlayerAttributes& a, int i) {
    std::int16_t* f[kAttributeCount] = {&a.pace, &a.passing, &a.shooting, &a.first_touch,
                                        &a.tackling, &a.anticipation, &a.decisions,
                                        &a.goalkeeping};
    return i >= 0 && i < kAttributeCount ? f[i] : nullptr;
}

// The scaling itself lives in the Skill classes (core/Skill.hpp, G4.33):
// one class per attribute, numbers from game_model_params.

// ── Concepts: the registry is the curriculum (core/ConceptRegistry.hpp,
// game_concepts mig 650). Ratings are indexed by the stable concept id.

// ── Graded knowledge (James: "implement them on a 0 to 100 scale") ─────
// A rating is CONSISTENCY + MAGNITUDE in one number: branch concepts roll
// (noise < rating%) per application; spatial concepts also lerp their
// distances by rating. 0 = doesn't know it; 100 = textbook every time.
using ConceptRatings = std::array<std::uint8_t, kMaxConcepts>;

// A game model's DEMAND is an OVERLAY vector (mig 652, game_model_concepts;
// was the style preset, mig 630): -1 = the model doesn't say; 0-100 = it
// asks this much (an explicit 0 is meaningful — Sacchi's zonal marking
// ZEROES man-mark). applyPresetOverlay paints a vector directly (the
// calibration harness's "name:rating" overrides).
using PresetOverlay = std::array<std::int16_t, kMaxConcepts>;

inline void applyPresetOverlay(ConceptRatings& r, const PresetOverlay& o) {
    for (int i = 0; i < kMaxConcepts; ++i) {
        if (o[i] < 0) continue;
        r[i] = static_cast<std::uint8_t>(o[i] > 100 ? 100 : o[i]);
    }
}

// The band's place on the level ladder (u10 = 1 … world = 6, perfect = 7),
// by the same thresholds as its quality below.
inline int levelRankOf(const LevelParams& lv) {
    if (lv.swarm_pct >= 70) return 1;
    if (lv.swarm_pct >= 40) return 2;
    if (lv.swarm_pct >= 25) return 3;
    if (lv.swarm_pct >= 10) return 4;
    if (lv.swarm_pct >= 3) return 5;
    if (!lv.isZero()) return 6;
    return 7;
}

// What a band's players KNOW (ability): the band's quality on every concept
// taught at or below its level (game_concepts.taught_from), 0 on the rest —
// U-10s don't do delay theory AT ALL; a semipro knows it all at 68.
// quality (0-100, mig 656) replaces the band's number for a player whose
// teams' records rate him; which concepts he knows stays the band's.
inline ConceptRatings defaultAbility(const LevelParams& lv, int quality = -1) {
    static constexpr std::uint8_t kQuality[] = {0, 12, 30, 50, 68, 82, 92, 100};
    const int rank = levelRankOf(lv);
    const std::uint8_t q = quality >= 0 && quality <= 100 ? static_cast<std::uint8_t>(quality) : kQuality[rank];
    ConceptRatings r{};
    const ConceptRegistry& reg = concepts();
    for (int i = 0; i < reg.size(); ++i) {
        const int from = reg.taughtFrom(i);
        r[i] = (from > 0 && rank >= from) ? q : 0;
    }
    return r;
}

// The taxonomy → game model → formation → player chain (G4.38, mig 652):
// a player PLAYS min(demand, ability). Demand is what his team's game
// model asks (overlay; -1 = unset → the concept's default: core 100,
// style 0); ability is what he knows. demand − ability is what to coach.
inline ConceptRatings effectiveRatings(const ConceptRatings& ability,
                                       const PresetOverlay& demand) {
    ConceptRatings r{};
    const ConceptRegistry& reg = concepts();
    for (int i = 0; i < reg.size(); ++i) {
        int d = demand[i] >= 0 ? demand[i] : reg.defaultDemand(i);
        if (d > 100) d = 100;
        r[i] = static_cast<std::uint8_t>(d < ability[i] ? d : ability[i]);
    }
    return r;
}

// A band with no game model: core concepts at the band's quality, style 0.
inline ConceptRatings defaultRatings(const LevelParams& lv) {
    PresetOverlay none;
    none.fill(-1);
    return effectiveRatings(defaultAbility(lv), none);
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
