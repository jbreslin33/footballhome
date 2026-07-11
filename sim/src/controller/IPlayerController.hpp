// footballhome sim - IPlayerController
//
// Every slot in a match has exactly one IPlayerController. It receives an
// AwarenessView (not WorldView — see §16.5 + check_no_floats.sh) and returns
// a single Intent for the current tick.
//
// Three concrete impls exist:
//   • HumanController  — reads the latest network Intent for its owner
//   • WanderController — jogs to a random pitch point (M0 unclaimed slots)
//   • AiController     — utility-AI over IBehaviors (skeleton until M3)
//
// See DESIGN.md §5.4, §14, §16.5.

#pragma once

#include "awareness/AwarenessView.hpp"
#include "common/IdTypes.hpp"
#include "controller/Intent.hpp"

namespace fh::sim::controller {

class IPlayerController {
public:
    virtual ~IPlayerController() = default;

    // Produce this tick's Intent for the slot occupying `self`.
    virtual Intent      decide(const awareness::AwarenessView& view,
                                SlotId self) = 0;

    // Short human-readable label used by logs and event records.
    // Stable strings expected: "human", "wander", "ai".
    virtual const char* kind() const = 0;
};

} // namespace fh::sim::controller
