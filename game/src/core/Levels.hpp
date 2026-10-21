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

    bool isZero() const noexcept {
        return perception_delay_ticks == 0 && kick_angle_err_deg == 0 &&
               kick_power_err_pct == 0 && decision_jitter_pct == 0 &&
               control_speed_mps == 0 && swarm_pct == 0 &&
               tackle_success_pct == 0 && keeper_reaction_ticks == 0;
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
    if (name == "u10")     return {18, 18, 25, 60, 6, 30, 80, 18};  // amoeba
    if (name == "u14")     return {12, 13, 18, 40, 8, 35, 55, 14};
    if (name == "amateur") return {7, 6, 10, 25, 10, 42, 30, 6};  // Sunday
    if (name == "semipro") return {4, 3, 6, 12, 13, 50, 12, 14};
    if (name == "pro")     return {2, 2, 3, 5, 16, 60, 4, 11};
    if (name == "world")   return {1, 1, 2, 2, 18, 65, 0, 9};
    return {};  // "perfect" and anything unknown: the zero baseline
}

// ── Concept bits (game/CONCEPTS.md is the registry; append-only) ───────
enum Concept : std::uint32_t {
    kDelayTransition = 1u << 0,
    kManMarking      = 1u << 1,
    kCoverMan        = 1u << 2,
    kSupportSpot     = 1u << 3,
    kBackOutlet      = 1u << 4,
    kRunInBehind     = 1u << 5,
    kPlayOverTop     = 1u << 6,
    kKeeperSweep     = 1u << 7,
    kShotPlacement   = 1u << 8,
    kLineHold        = 1u << 9,
    kJockeyAngle     = 1u << 10,  // show them the touchline
    kRecoverGoalSide = 1u << 11,  // beaten → sprint the cover line
    kDoubleTeam      = 1u << 12,  // trap on the touchline
    kSpreadWide      = 1u << 13,  // attacking WIDTH (James's law, offense side)
    kGiveAndGo       = 1u << 14,  // pass and MOVE
    kPushUp          = 1u << 15,  // squeeze: line steps UP with the ball
    kCounterPress    = 1u << 16,  // 6-second rule after losing it
    kBalance         = 1u << 17,  // weak-side tuck [FA principles]
    // STYLE class [S]: chosen identities, default 0 at every band —
    // schools (Bielsa etc.) are preset vectors over these + the rest.
    kManOrientation  = 1u << 18,  // mark YOUR man, follow him anywhere
    kVerticality     = 1u << 19,  // forward first; accept tighter lanes
    kInterceptRead   = 1u << 20,  // read the pass: earliest-reach cutoff
    kRestraint       = 1u << 21,  // don't dive: the anti-tackle
};
inline constexpr std::uint32_t kAllConcepts = (1u << 22) - 1;
inline constexpr const char* kConceptNames[] = {
    "delay", "marking", "cover", "support", "outlet",
    "runs", "over-top", "sweep", "placement", "line-hold",
    "jockey-angle", "recover", "double-team", "width", "give-and-go",
    "push-up", "counter-press", "balance", "man-mark", "verticality",
    "intercept", "restraint"};
inline constexpr int kConceptCount = 22;

// ── Graded knowledge (James: "implement them on a 0 to 100 scale") ─────
// A rating is CONSISTENCY + MAGNITUDE in one number: branch concepts roll
// (noise < rating%) per application; spatial concepts also lerp their
// distances by rating. 0 = doesn't know it; 100 = textbook every time.
using ConceptRatings = std::array<std::uint8_t, kConceptCount>;

// A style preset is an OVERLAY vector (mig 630, CONCEPTS.md "Schools &
// auteurs"): -1 = this dial untouched; 0-100 = set it (an explicit 0 is
// meaningful — Sacchi's zonal marking ZEROES man-mark). Applying one
// paints only the dials the school names; the rest keep their value.
using PresetOverlay = std::array<std::int16_t, kConceptCount>;

inline void applyPresetOverlay(ConceptRatings& r, const PresetOverlay& o) {
    for (int i = 0; i < kConceptCount; ++i) {
        if (o[i] < 0) continue;
        r[i] = static_cast<std::uint8_t>(o[i] > 100 ? 100 : o[i]);
    }
}



// Default knowledge bundle for a level band. EXACTLY reproduces the
// pre-registry gates (swarm >= 40 lacked the theory), so unedited teams
// behave identically to before the registry existed.
inline std::uint32_t conceptBundle(const LevelParams& lv) {
    std::uint32_t m = kCoverMan | kSupportSpot | kShotPlacement | kLineHold;
    if (lv.swarm_pct < 40) {
        m |= kDelayTransition | kManMarking | kBackOutlet | kRunInBehind |
             kPlayOverTop | kKeeperSweep | kJockeyAngle | kRecoverGoalSide |
             kDoubleTeam | kSpreadWide | kGiveAndGo | kPushUp |
             kCounterPress | kBalance | kInterceptRead | kRestraint;
    }
    return m;
}

// Band defaults: the band's quality on every concept it "knows" (the old
// bundle), 0 on the rest — U-10s don't do delay theory AT ALL; a semipro
// does everything at 68.
inline ConceptRatings defaultRatings(const LevelParams& lv) {
    std::uint8_t q = 50;
    if (lv.swarm_pct >= 70)      q = 12;   // u10
    else if (lv.swarm_pct >= 40) q = 30;   // u14
    else if (lv.swarm_pct >= 25) q = 50;   // amateur
    else if (lv.swarm_pct >= 10) q = 68;   // semipro
    else if (lv.swarm_pct >= 3)  q = 82;   // pro
    else if (!lv.isZero())       q = 92;   // world
    else                         q = 100;  // perfect
    ConceptRatings r{};
    const std::uint32_t bundle = conceptBundle(lv);
    for (int i = 0; i < kConceptCount; ++i)
        r[i] = (bundle & (1u << i)) ? q : 0;
    return r;
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
