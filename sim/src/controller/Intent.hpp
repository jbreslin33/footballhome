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

    // Slice 16.4: explicit "release the ball" signal. When true, it
    // ALWAYS wins over `wants_dribble` (both the wire-set bit and the
    // HumanController auto-hint). This is the only escape hatch a human
    // has to release a ball they're currently controlling — otherwise
    // the auto-hint would re-grab it every tick as long as they're
    // standing near it. Wire bit 3 of INPUT flags (§7.3).
    //
    // Semantic layering (§23.3 Slice 16.4 release conditions):
    //   * wants_release && wants_dribble  → release wins (drop the ball)
    //   * wants_release && auto-hint      → release wins (auto-hint suppressed)
    //   * wants_release==false            → normal dribble semantics apply
    //
    // Implementation lives in HumanController::decide, which forces
    // `wants_dribble = false` before returning if `wants_release` is
    // set on the wire input. BallControl doesn't need to know about
    // this bit directly — the collapse to `wants_dribble=false` is
    // sufficient to fail Rule 2 (owner retention).
    bool       wants_release{false};

    // Reserved for M1+: pass, shoot, tackle, etc.
    // std::uint8_t action_bits{0};
};

// Helper: idle intent (no movement, no flags).
inline Intent idle()
{
    return Intent{};
}

} // namespace fh::sim::controller
