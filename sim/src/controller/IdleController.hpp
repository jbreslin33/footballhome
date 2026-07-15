// footballhome sim - IdleController
//
// Emits a zero Intent every tick — the slot stands still, facing whatever
// heading Scenario::initialSpawns() gave it. Consumes zero RNG.
//
// Used by Match for unclaimed slots on scenarios whose Scenario::
// unclaimedSlotsIdle() returns true — i.e. human-interactive demo
// scenarios where a "wandering AI" would fight the joystick user
// (Slice 24.2: solo BallOnPitch dribble practice, standing target
// dummy at the other slot).
//
// Contrast with WanderController which picks random pitch points and
// jogs to them (consumes RNG — appropriate for M0 wander demos).
//
// See DESIGN.md §5.4, §24 (M2 in progress).

#pragma once

#include "controller/IPlayerController.hpp"

namespace fh::sim::controller {

class IdleController : public IPlayerController {
public:
    IdleController() noexcept = default;

    Intent decide(const awareness::AwarenessView& /*view*/,
                  SlotId /*self*/) override
    {
        return Intent{};   // all-zero: no movement, no dribble, no anything
    }

    const char* kind() const override { return "idle"; }
};

} // namespace fh::sim::controller
