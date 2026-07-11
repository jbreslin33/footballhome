// footballhome sim - AiController (skeleton)
//
// Utility-AI over IBehavior. In M3+ the ctor will take a bag of behaviors,
// and decide() will score each with `utility()` and execute the winner.
//
// In M0 the class exists only so all references + wiring compile — it
// returns idle() every tick.
//
// See DESIGN.md §5.4, §5.5, §16.4.

#pragma once

#include "controller/IPlayerController.hpp"
#include "common/Role.hpp"
#include "profile/ConceptSet.hpp"

namespace fh::sim::controller {

class AiController : public IPlayerController {
public:
    AiController() = default;
    AiController(Role role, profile::ConceptSet concepts) noexcept
        : role_(role), concepts_(std::move(concepts)) {}

    Role                        role() const noexcept { return role_; }
    const profile::ConceptSet&  concepts() const noexcept { return concepts_; }

    Intent      decide(const awareness::AwarenessView& view,
                       SlotId self) override;
    const char* kind() const override { return "ai"; }

private:
    Role                role_{Role::Any};
    profile::ConceptSet concepts_{};
};

} // namespace fh::sim::controller
