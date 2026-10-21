// game/src/core/World.cpp

#include "core/World.hpp"

namespace fh::game::core {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

World::World(SlotIndex player_count, Fixed64 max_speed)
    : players_(player_count), intents_(player_count) {
    for (auto& p : players_) p.max_speed = max_speed;
}

void World::setIntent(SlotIndex slot, const MoveIntent& intent) {
    if (slot >= intents_.size()) return;  // unknown slot: drop, never throw
    intents_[slot] = intent;
}

void World::placePlayer(SlotIndex slot, const Vec3& pos) {
    if (slot >= players_.size()) return;
    players_[slot].pos = pos;
}

void World::tick() {
    for (SlotIndex i = 0; i < players_.size(); ++i) {
        Vec2 desire = intents_[i].move;

        // Clamp desire to unit length. lengthSquared avoids a sqrt on the
        // common in-range case; the normalize path uses deterministic
        // fx_sqrt via Vec2::normalized().
        if (math::lengthSquared(desire) > Fixed64::one()) {
            desire = desire.normalized();
        }

        PlayerState& p = players_[i];
        p.vel = Vec3{desire.x * p.max_speed, desire.y * p.max_speed,
                     Fixed64::zero()};
        p.pos += p.vel * kTickDt;
    }
    clock_.advance();
}

}  // namespace fh::game::core
