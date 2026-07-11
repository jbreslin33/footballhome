// footballhome sim - Match
//
// Owns one live match: physics world, scenario, clock, slots, RNG, and the
// per-slot mechanics params. Drives the tick loop that wires the four
// cognitive stages together:
//
//   Perception  — physics.step() from previous tick provides the ground truth
//   Recognition — RecognitionSystem::apply(WorldView, profile, self)
//   Decision    — controller.decide(AwarenessView, self)
//   Execution   — Mechanics::applyIntent → write back to physics, then step
//
// Match itself does NOT touch WorldView after this class file — it hands
// WorldView to RecognitionSystem which returns AwarenessViews. Only Match
// and RecognitionSystem see WorldView; every downstream consumer sees
// AwarenessView. (Enforced by check_no_floats.sh.)
//
// See DESIGN.md §5.7, §14, §16.1, §19.

#pragma once

#include "awareness/RecognitionSystem.hpp"
#include "common/IdTypes.hpp"
#include "controller/IPlayerController.hpp"
#include "match/Mechanics.hpp"
#include "match/MatchClock.hpp"
#include "match/Slot.hpp"
#include "match/Snapshot.hpp"
#include "math/RngDet.hpp"
#include "physics/IPhysicsWorld.hpp"
#include "scenario/Scenario.hpp"

#include <cstdint>
#include <memory>
#include <optional>
#include <vector>

namespace fh::sim::match {

using MatchId = std::uint64_t;

struct MatchConfig {
    MatchId                                    id{0};
    std::uint64_t                              seed{0};
    std::string                                server_version{"m0"};
    std::unique_ptr<physics::IPhysicsWorld>    physics;
    std::unique_ptr<scenario::Scenario>        scenario;
    std::unique_ptr<MatchClock>                clock;
};

class Match {
public:
    explicit Match(MatchConfig cfg);
    ~Match() = default;

    Match(const Match&)            = delete;
    Match& operator=(const Match&) = delete;

    // Advance the simulation by one tick. Drives all four cognitive stages
    // in the order documented in §14.
    void tick();

    // Slot lifecycle -----------------------------------------------------
    //
    // Human ↔ AI swap. Human takes over the slot's controller; the previous
    // controller is destroyed. Idempotent: claiming a slot already owned by
    // the same client is a no-op.
    void claimSlot(SlotId slot, ClientId client);
    void releaseSlot(SlotId slot);
    void applyInput(ClientId client, const controller::Intent& intent);

    // Read -----------------------------------------------------------------
    MatchId                       id() const noexcept  { return id_; }
    TickNum                       tick_num() const noexcept;
    math::Fixed64                 elapsedSeconds() const noexcept;
    bool                          ended() const noexcept { return ended_; }
    Snapshot                      snapshot() const;
    const std::vector<Slot>&      slots() const noexcept { return slots_; }

    // Test-only accessor. Kept out of hot paths.
    physics::IPhysicsWorld*       physics_for_tests() noexcept { return physics_.get(); }

private:
    // Build a WorldView from current physics + slot metadata. Called at
    // the top of tick() to feed Recognition.
    awareness::WorldView buildWorldView() const;

    // Slot lookup by SlotId. Returns nullptr on miss.
    Slot*       findSlot(SlotId slot) noexcept;
    const Slot* findSlot(SlotId slot) const noexcept;
    Slot*       findSlotByOwner(ClientId client) noexcept;

    // Spawn all scenario slots at construction time.
    void spawnInitialSlots();

    MatchId                                     id_;
    std::uint64_t                               seed_;
    std::string                                 server_version_;

    std::unique_ptr<physics::IPhysicsWorld>     physics_;
    std::unique_ptr<scenario::Scenario>         scenario_;
    std::unique_ptr<MatchClock>                 clock_;
    awareness::RecognitionSystem                recognition_;
    math::RngDet                                rng_;

    std::vector<Slot>                           slots_;
    std::vector<MechanicsParams>                params_by_slot_;   // 1:1 with slots_
    std::optional<EntityId>                     ball_{std::nullopt};

    bool                                        ended_{false};
};

} // namespace fh::sim::match
