// game/src/core/World.hpp
//
// The authoritative world: player entities + the ball, advanced by tick().
// G1 scope: planar locomotion, automatic first-touch possession, glue
// dribble, ground/lofted kicks, bouncing 3D ball, arcade boundary walls
// ([FH] placeholder until G3 restarts), goal detection with kickoff reset.
// Slot-count agnostic by construction (DESIGN.md §3).

#pragma once

#include "core/Ball.hpp"
#include "core/Levels.hpp"
#include "core/Clock.hpp"
#include "core/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::core {

using SlotIndex = std::uint8_t;

// Player body radius (m) for circle-circle collision [v1 Slice 27].
inline const math::Fixed64 kPlayerRadius = math::Fixed64::fromFraction(45, 100);

// Kick actions carried in PLAYER_INTENT's `action` field (PROTOCOL.md §4).
enum class Action : std::uint8_t {
    None       = 0,
    GroundKick = 1,  // 14 m/s — drive / long pass / shot
    LoftedKick = 2,  // 12 m/s + rise — chip / clearance
    ShortPass  = 3,  // 8 m/s — feet-to-feet inside ~15 m (G4 passing)
    Shot       = 4,  // 24 m/s — a real strike; outfielders can't catch it
};

struct PlayerState {
    math::Vec3 pos{};   // z stays 0 for players (locomotion is planar)
    math::Vec3 vel{};   // metres / second, fixed point
    std::uint8_t team = 0;  // steal contests are opponent-only
    // Last movement direction (unit-ish); kick/carry direction when the
    // current intent is idle. Set at spawn to face the opponent goal.
    math::Vec2 face{math::Fixed64::one(), math::Fixed64::zero()};
    // max_speed is a per-player attribute (registry-backed from G2 on).
    math::Fixed64 max_speed{};
};

// Match events emitted by tick(). Wire ids in PROTOCOL.md §7 match these
// values exactly — append-only, never renumber.
enum class MatchEventType : std::uint8_t {
    Goal     = 1,  // team = scorer
    ThrowIn  = 2,  // team = awarded
    GoalKick = 3,  // team = awarded
    Corner   = 4,  // team = awarded
    Kickoff  = 5,  // team = awarded (after goals and at period starts)
    HalfTime = 6,  // team unused
    FullTime = 7,  // team unused
};

struct MatchEvent {
    MatchEventType type;
    std::uint8_t team = 0;
};

class World {
public:
    // All players share max_speed until attributes land (G2). Pitch half
    // extents bound the lines and the goal mouths. half_length_ticks = 0
    // means an untimed sandbox (no halves, score still kept).
    World(SlotIndex player_count, math::Fixed64 max_speed,
          math::Fixed64 pitch_half_x, math::Fixed64 pitch_half_y,
          std::uint32_t half_length_ticks = 0);

    // Record the latest intent for a slot. Last write before tick() wins —
    // movement is sampled; a non-None action LATCHES until consumed by the
    // tick (so a tap between ticks is never lost).
    void setIntent(SlotIndex slot, const MoveIntent& intent);
    void setAction(SlotIndex slot, Action action);

    // Spawn/reset placement (scenario setup, not gameplay). `face` is the
    // initial kick/carry direction (toward the opponent goal).
    void placePlayer(SlotIndex slot, const math::Vec3& pos,
                     const math::Vec2& face);
    void setTeam(SlotIndex slot, std::uint8_t team);
    void setKeeper(SlotIndex slot, bool keeper);
    bool isKeeper(SlotIndex slot) const { return keeper_[slot]; }
    // Skill-noise config (G4.3). Zero params (the default) = perfect
    // execution; every pre-G4.3 golden locks that baseline.
    void setLevel(std::uint8_t team, const LevelParams& params);
    void setMatchSeed(std::uint64_t seed) { match_seed_ = seed; }
    const LevelParams& level(std::uint8_t team) const {
        return level_[team & 1];
    }
    std::uint64_t matchSeed() const noexcept { return match_seed_; }

    // Advance one tick. Returns match events (usually empty).
    std::vector<MatchEvent> tick();

    const PlayerState& player(SlotIndex slot) const { return players_[slot]; }
    const BallState& ball() const noexcept { return ball_; }
    SlotIndex playerCount() const noexcept {
        return static_cast<SlotIndex>(players_.size());
    }
    std::uint64_t tickCount() const noexcept { return clock_.tick(); }
    std::uint8_t score(std::uint8_t team) const { return score_[team & 1]; }
    std::uint8_t period() const noexcept { return period_; }
    std::uint32_t matchClockTicks() const noexcept { return match_clock_; }
    // 0xFF = live ball; else the team awaiting a dead-ball first touch.
    std::uint8_t restartTeam() const noexcept { return restart_team_; }
    math::Fixed64 pitchHalfX() const noexcept { return half_x_; }
    math::Fixed64 pitchHalfY() const noexcept { return half_y_; }

private:
    void tickPlayers();
    void tickPossessionAndKicks(std::vector<MatchEvent>& events);
    void tickFreeBall(std::vector<MatchEvent>& events);
    void awardKickoff(std::uint8_t team, std::vector<MatchEvent>& events);
    void awardRestart(MatchEventType type, std::uint8_t team,
                      const math::Vec3& spot, std::vector<MatchEvent>& events);
    void tickClock(std::vector<MatchEvent>& events);

    std::vector<PlayerState> players_;
    std::vector<MoveIntent>  intents_;
    std::vector<Action>      actions_;
    std::vector<bool>        keeper_;
    BallState ball_;
    math::Fixed64 half_x_{}, half_y_{};
    Clock clock_;

    // Match structure (G3.3). match_clock_ resets at full time (perpetual
    // sandbox); kickoff_team_ alternates per period and per full match.
    std::uint8_t  score_[2] = {0, 0};
    std::uint8_t  period_ = 1;
    std::uint32_t match_clock_ = 0;
    std::uint32_t half_length_ticks_ = 0;
    std::uint8_t  kickoff_team_ = 0;
    std::uint8_t  restart_team_ = 0xFF;   // 0xFF = live ball
    std::uint8_t  last_touch_team_ = 0;
    LevelParams   level_[2];
    std::uint64_t match_seed_ = 0;
};

}  // namespace fh::game::core
