// game/src/core/World.hpp
//
// The authoritative world: player entities + the ball, advanced by tick().
// G1 scope: planar locomotion, automatic first-touch possession, glue
// dribble, ground/lofted kicks, bouncing 3D ball, arcade boundary walls
// ([FH] placeholder until G3 restarts), goal detection with kickoff reset.
// Slot-count agnostic by construction (DESIGN.md §3).

#pragma once

#include "core/Ball.hpp"
#include "core/Clock.hpp"
#include "core/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::core {

using SlotIndex = std::uint8_t;

// Kick actions carried in PLAYER_INTENT's `action` field (PROTOCOL.md §4).
enum class Action : std::uint8_t {
    None       = 0,
    GroundKick = 1,
    LoftedKick = 2,
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

// Emitted by tick() when the ball fully crosses a goal mouth.
struct GoalEvent {
    std::uint8_t scoring_team = 0;  // 0 = home (attacks +x), 1 = away
};

class World {
public:
    // All players share max_speed until attributes land (G2). Pitch half
    // extents bound the arcade walls and the goal mouths.
    World(SlotIndex player_count, math::Fixed64 max_speed,
          math::Fixed64 pitch_half_x, math::Fixed64 pitch_half_y);

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

    // Advance one tick. Returns goal events (usually empty).
    std::vector<GoalEvent> tick();

    const PlayerState& player(SlotIndex slot) const { return players_[slot]; }
    const BallState& ball() const noexcept { return ball_; }
    SlotIndex playerCount() const noexcept {
        return static_cast<SlotIndex>(players_.size());
    }
    std::uint64_t tickCount() const noexcept { return clock_.tick(); }
    math::Fixed64 pitchHalfX() const noexcept { return half_x_; }
    math::Fixed64 pitchHalfY() const noexcept { return half_y_; }

private:
    void tickPlayers();
    void tickPossessionAndKicks(std::vector<GoalEvent>& events);
    void tickFreeBall(std::vector<GoalEvent>& events);
    void resetKickoff();

    std::vector<PlayerState> players_;
    std::vector<MoveIntent>  intents_;
    std::vector<Action>      actions_;
    BallState ball_;
    math::Fixed64 half_x_{}, half_y_{};
    Clock clock_;
};

}  // namespace fh::game::core
