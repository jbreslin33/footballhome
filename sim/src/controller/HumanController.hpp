// footballhome sim - HumanController
//
// Represents one connected human player. The network layer calls
// updateInput(Intent) whenever a new INPUT wire message arrives; decide()
// returns the latest Intent, with `wants_dribble` OR-augmented by
// ball-proximity so joystick-only clients can dribble without adding a
// dedicated button (Slice 16.2).
//
// If the player disconnects (no fresh input for a while), the calling code
// is expected to swap in a fallback controller — HumanController itself
// simply keeps returning the last Intent it was given. This is deliberate:
// making HumanController "decay to idle" would introduce ambiguity around
// whose responsibility that is.
//
// See DESIGN.md §5.4, §14, §23.3 Slice 16.2.

#pragma once

#include "controller/IPlayerController.hpp"
#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

namespace fh::sim::controller {

// Slice 16.2: HumanController auto-sets Intent::wants_dribble when its
// own entity is within this many metres of the ball. Chosen as 1.5 m so
// a player who walks up to the ball naturally "takes it" without a
// dedicated joystick button, but far enough that a player merely
// passing by 2-3 m away doesn't silently claim it. Slice 16.3's
// BallControl.cpp will define the tighter `ball_control_radius` for
// the actual glue-to-owner distance (this constant is intentionally
// larger — it's a *hint threshold*, not the *claim threshold*).
inline constexpr math::Fixed64 kBallAutoDribbleRadius = math::Fixed64::fromFraction(3, 2);

class HumanController : public IPlayerController {
public:
    // owner is the ClientId (fh person_id) whose INPUT messages feed this
    // controller. Kept as immutable identity for logging & disconnect handling.
    explicit HumanController(ClientId owner) noexcept : owner_{owner} {}

    ClientId owner() const noexcept { return owner_; }

    // Called by the network layer on each INPUT arrival.
    void updateInput(const Intent& intent) noexcept { latest_ = intent; }

    // Latest intent (defaults to idle if none received yet). Read-only —
    // does NOT reflect the ball-proximity auto-dribble augmentation
    // (decide() applies that on top of latest_ each tick).
    const Intent& latest() const noexcept { return latest_; }

    Intent      decide(const awareness::AwarenessView& view,
                       SlotId self) override;
    const char* kind() const override { return "human"; }

private:
    ClientId owner_;
    Intent   latest_{};   // idle by default
};

} // namespace fh::sim::controller
