// footballhome sim - Slot
//
// Per-scenario-slot runtime state owned by Match. Bundles the controller,
// the physics entity backing it, the player profile, the stamina pool,
// and (if occupied by a human) the owning ClientId.
//
// See DESIGN.md §5.7, §16.2.

#pragma once

#include "common/IdTypes.hpp"
#include "common/Role.hpp"
#include "controller/IPlayerController.hpp"
#include "math/Fixed64.hpp"
#include "profile/PlayerProfile.hpp"

#include <memory>
#include <optional>

namespace fh::sim::match {

struct Slot {
    SlotId                                       slot_id{0};
    EntityId                                     entity{0};
    std::unique_ptr<controller::IPlayerController> controller;
    profile::PlayerProfile                       profile;
    std::optional<ClientId>                      owner;       // set if human
    Role                                         role{Role::Any};

    // Stamina lives here (not on the physics entity) because it is a
    // gameplay-side pool consumed by the mechanics stage, not a physics
    // quantity. Starts full; mechanics clamps to [0, stamina_max].
    math::Fixed64                                stamina{math::Fixed64::one()};
};

} // namespace fh::sim::match
