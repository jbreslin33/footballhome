// game/src/core/World.hpp
//
// The authoritative world: N player entities advanced by tick(). G0 scope:
// planar locomotion from MoveIntents — no ball, no collisions, no pitch
// bounds yet (those are G1 slices). Slot-count agnostic by construction
// (DESIGN.md §3: a component that only works at 22 slots fails CI).

#pragma once

#include "core/Clock.hpp"
#include "core/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::core {

using SlotIndex = std::uint8_t;

struct PlayerState {
    math::Vec3 pos{};   // z stays 0 for players (locomotion is planar)
    math::Vec3 vel{};   // metres / second, fixed point
    // max_speed is a per-player attribute (registry-backed from G2 on;
    // constructor-supplied until then).
    math::Fixed64 max_speed{};
};

class World {
public:
    // All players share max_speed until attributes land (G2).
    World(SlotIndex player_count, math::Fixed64 max_speed);

    // Record the latest intent for a slot. Last write before tick() wins —
    // intents are sampled, not queued (one effective intent per tick).
    void setIntent(SlotIndex slot, const MoveIntent& intent);

    // Place a player (spawn/reset positioning — scenario setup, not
    // gameplay). Formation-driven placement replaces ad-hoc spawns in G2.
    void placePlayer(SlotIndex slot, const math::Vec3& pos);

    // Advance one tick: for every player, velocity = clamped desire *
    // max_speed; position += velocity * dt. Deterministic.
    void tick();

    const PlayerState& player(SlotIndex slot) const { return players_[slot]; }
    SlotIndex playerCount() const noexcept {
        return static_cast<SlotIndex>(players_.size());
    }
    std::uint64_t tickCount() const noexcept { return clock_.tick(); }

private:
    std::vector<PlayerState> players_;
    std::vector<MoveIntent>  intents_;
    Clock clock_;
};

}  // namespace fh::game::core
