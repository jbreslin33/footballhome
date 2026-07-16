// footballhome sim - DefenderController
//
// Slice 24.3a: an AI defender that jogs toward the ball every tick.
// Zero contest mechanics (Slice 24.3b will land the touch-to-steal
// resolution) — this is pure pursuit. When the defender reaches the
// ball owner, it simply stands on top of them; nothing happens on
// collision yet. The whole point is to give the Slice 25.2 sprint-
// with-ball feature a *reason* — outrun the AI or lose ground.
//
// RNG-free by design (consumes zero from the match RNG stream) so it
// can be introduced without perturbing any existing determinism golden.
// Contrast with WanderController (consumes RNG at every retarget) and
// IdleController (also RNG-free, but does nothing).
//
// See DESIGN.md §5.4, §24.3.

#pragma once

#include "controller/IPlayerController.hpp"

namespace fh::sim::controller {

class DefenderController : public IPlayerController {
public:
    DefenderController() noexcept = default;

    Intent      decide(const awareness::AwarenessView& view,
                       SlotId self) override;
    const char* kind() const override { return "defender"; }
};

} // namespace fh::sim::controller
