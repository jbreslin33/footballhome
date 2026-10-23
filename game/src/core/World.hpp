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
// Body height for blocking a ball (G4.25): below this a shot hits a body.
inline const math::Fixed64 kBodyHeight = math::Fixed64::fromFraction(18, 10);

// Kick actions carried in PLAYER_INTENT's `action` field (PROTOCOL.md §4).
enum class Action : std::uint8_t {
    None       = 0,
    GroundKick = 1,  // 14 m/s — drive / long pass / shot
    LoftedKick = 2,  // 12 m/s + rise — chip / clearance
    ShortPass  = 3,  // 8 m/s — feet-to-feet inside ~15 m (G4 passing)
    Shot       = 4,  // 18 m/s — a placed strike
    Tackle     = 5,  // committed dive at an opponent's carried ball (G4.6)
};

struct PlayerState {
    math::Vec3 pos{};   // z stays 0 for players (locomotion is planar)
    math::Vec3 vel{};   // metres / second, fixed point
    std::uint8_t team = 0;  // steal contests are opponent-only
    // Ticks of post-tackle stun: no movement, no actions. The price of
    // diving in — what makes beating a defender possible.
    std::int32_t recovery_ticks = 0;
    // WHY he's recovering (G4.27, presentation only — not hashed; the
    // ticks above carry the gameplay): 1 = went to ground in a tackle,
    // 2 = dispossessed, knocked off balance.
    std::uint8_t recovery_kind = 0;
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
    TackleWon  = 8,  // team = tackler's
    TackleLost = 9,  // team = tackler's (beaten, in recovery)
    Offside    = 10, // team = the AWARDED (defending) team
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
    // Scenario setup (tests, painted situations), like placePlayer.
    void placeBall(const BallState& b) { ball_ = b; }
    void setTeam(SlotIndex slot, std::uint8_t team);
    void setKeeper(SlotIndex slot, bool keeper);
    void setMaxSpeed(SlotIndex slot, math::Fixed64 v) {
        if (slot < players_.size()) players_[slot].max_speed = v;
    }
    bool isKeeper(SlotIndex slot) const { return keeper_[slot]; }
    // Skill-noise config (G4.3). Zero params (the default) = perfect
    // execution; every pre-G4.3 golden locks that baseline.
    void setLevel(std::uint8_t team, const LevelParams& params);
    void setMatchSeed(std::uint64_t seed) { match_seed_ = seed; }
    const LevelParams& level(std::uint8_t team) const {
        return level_[team & 1];
    }
    // Per-player level (G4.30): the team band bent by that player's
    // attributes (levelForPlayer). Unset slots use their team's band, so
    // nothing changes until a roster carries attributes.
    void setSlotLevel(SlotIndex slot, const LevelParams& params);
    void clearSlotLevels() { slot_level_set_.assign(slot_level_set_.size(), 0); }
    bool hasSlotLevel(SlotIndex slot) const {
        return slot < slot_level_set_.size() && slot_level_set_[slot];
    }
    const LevelParams& levelOf(SlotIndex slot) const {
        return hasSlotLevel(slot) ? slot_level_[slot]
                                  : level_[players_[slot].team & 1];
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
    std::uint32_t offsideMask() const noexcept { return offside_mask_; }
    std::uint8_t offsideTeam() const noexcept { return offside_team_; }
    // Transition clock (G4.11): which team LOST the ball last, and when.
    std::uint8_t lastLosingTeam() const noexcept { return losing_team_; }
    std::uint64_t turnoverTick() const noexcept { return turnover_tick_; }
    // Where the ball was won (G4.18): a COUNTER starts from a deep win;
    // a recovered rebound in their box is a scramble, not a transition.
    math::Fixed64 turnoverBallX() const noexcept { return turnover_ball_x_; }
    // Which team touched the ball last — a ball in flight still "belongs"
    // to its kicker's team for possession accounting (G4.1 metric gap).
    std::uint8_t lastTouchTeam() const noexcept { return last_touch_team_; }
    math::Fixed64 pitchHalfX() const noexcept { return half_x_; }
    math::Fixed64 pitchHalfY() const noexcept { return half_y_; }

private:
    void tickPlayers();
    void tickTackles(std::vector<MatchEvent>& events);
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
    // Offside (G4.8): armed at every kick — flags teammates of the kicker
    // beyond the second-last opponent AND the ball, in the opponent half.
    // First same-team touch by a flagged player = whistle. Cleared by any
    // opponent touch, dead ball, or goal.
    std::uint32_t offside_mask_ = 0;
    std::uint8_t  offside_team_ = 0xFF;  // kicking team while armed
    std::uint8_t  losing_team_ = 0xFF;
    std::uint64_t turnover_tick_ = 0;
    math::Fixed64 turnover_ball_x_{};
    std::vector<MatchEvent>* pending_events_ = nullptr;  // tick-scoped
    LevelParams   level_[2];
    std::vector<LevelParams>  slot_level_;
    std::vector<std::uint8_t> slot_level_set_;
    std::uint64_t match_seed_ = 0;
};

}  // namespace fh::game::core
