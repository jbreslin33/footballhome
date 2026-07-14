// footballhome sim - Intent
//
// One tick of player-intent. Produced by IPlayerController::decide().
// Consumed by Match's mechanics stage which translates Intent + attributes
// into new velocity/heading/motion for the physics entity.
//
// desired_direction is the target direction of movement, NOT the target
// velocity. Magnitude is only used to distinguish "moving" (any non-zero
// length) from "idle" (zero-length); the actual speed comes from the
// wants_walk / wants_sprint flags gated by attributes + stamina.
//
// See DESIGN.md §5.4, §7.3.

#pragma once

#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

namespace fh::sim::controller {

struct Intent {
    // Desired direction. Zero-length ⇒ "idle" (no movement requested).
    // Non-zero ⇒ direction of intended movement. Match normalises it.
    math::Vec3 desired_direction{};

    // At most one of these should be true in practice, but Match resolves
    // conflicts (sprint wins over walk) deterministically.
    bool       wants_sprint{false};
    bool       wants_walk{false};

    // Slice 16.2: signal to BallControl (Slice 16.3+) that this player
    // wants to take / keep control of the ball. Interpretation:
    //   * Set by the wire (bit 2 of INPUT flags, §7.3) when a client
    //     explicitly requests dribble.
    //   * Also auto-set by HumanController::decide when the player is
    //     within `kBallAutoDribbleRadius` of the ball, so joystick-only
    //     UX works without adding a dribble button.
    //   * BallControl still decides who ACTUALLY owns the ball each tick
    //     (§16.3 first-touch: closest-of-those-wanting, ties broken by
    //     lower SlotId). `wants_dribble` is a *hint*, not a claim.
    bool       wants_dribble{false};

    // Reserved for M1+: pass, shoot, tackle, etc.
    // std::uint8_t action_bits{0};
};

// Helper: idle intent (no movement, no flags).
inline Intent idle()
{
    return Intent{};
}

} // namespace fh::sim::controller
