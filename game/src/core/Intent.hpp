// game/src/core/Intent.hpp
//
// Player intent — the only thing a player-client (or an AI controller) may
// tell the server about a slot (PROTOCOL.md §4). High-level desires, never
// positions: the server owns all movement. [QUAKE] — the classic
// server-authoritative model: intents up, snapshots down.
//
// Tactical intents (PROTOCOL.md §5) are a separate type and arrive with G5.

#pragma once

#include "math/Vec3.hpp"

namespace fh::game::core {

struct MoveIntent {
    // Desired movement direction in pitch space. Magnitude is desire
    // strength in [0, 1]; the world clamps anything longer to unit length,
    // so a hostile client cannot move faster by sending a long vector.
    math::Vec2 move{};
    // Where he wants his body to face (G4.53), any length; zero = the way
    // he's travelling. Facing away from his travel costs speed (Body::gait):
    // a backpedal or side-shuffle is slower than running forward.
    math::Vec2 face{};
};

}  // namespace fh::game::core
