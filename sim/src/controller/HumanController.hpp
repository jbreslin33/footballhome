// footballhome sim - HumanController
//
// Represents one connected human player. The network layer calls
// updateInput(Intent) whenever a new INPUT wire message arrives; decide()
// returns the latest Intent unmodified.
//
// If the player disconnects (no fresh input for a while), the calling code
// is expected to swap in a fallback controller — HumanController itself
// simply keeps returning the last Intent it was given. This is deliberate:
// making HumanController "decay to idle" would introduce ambiguity around
// whose responsibility that is.
//
// See DESIGN.md §5.4, §14.

#pragma once

#include "controller/IPlayerController.hpp"
#include "common/IdTypes.hpp"

namespace fh::sim::controller {

class HumanController : public IPlayerController {
public:
    // owner is the ClientId (fh person_id) whose INPUT messages feed this
    // controller. Kept as immutable identity for logging & disconnect handling.
    explicit HumanController(ClientId owner) noexcept : owner_{owner} {}

    ClientId owner() const noexcept { return owner_; }

    // Called by the network layer on each INPUT arrival.
    void updateInput(const Intent& intent) noexcept { latest_ = intent; }

    // Latest intent (defaults to idle if none received yet).
    const Intent& latest() const noexcept { return latest_; }

    Intent      decide(const awareness::AwarenessView& view,
                       SlotId self) override;
    const char* kind() const override { return "human"; }

private:
    ClientId owner_;
    Intent   latest_{};   // idle by default
};

} // namespace fh::sim::controller
