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

// MatchId lives in `fh::sim` (common/IdTypes.hpp) so persistence and other
// non-match subsystems can spell it without pulling in this heavy header.
// Name lookup from within fh::sim::match resolves it transparently.

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
    // Human ↔ AI swap. `profile` becomes the slot's profile and is used
    // to recompute MechanicsParams (max speeds, acceleration, stamina
    // curves) — the profile IS the source of truth for gameplay balance
    // per-person (§16.6). `person` is stored on the slot to enable
    // audit / event-log SlotClaim records (§14 / §22.12).
    //
    // Idempotent: claiming a slot already owned by the same client is a
    // no-op even if the caller passes a different profile — the first
    // claim wins for the session's lifetime.
    void claimSlot(SlotId slot,
                   ClientId client,
                   PersonId person,
                   profile::PlayerProfile profile);
    void releaseSlot(SlotId slot);
    void applyInput(ClientId client, const controller::Intent& intent);

    // Slice 16.4: mark the match as ended. Subsequent tick() calls
    // return immediately (no physics step, no BallControl pass, no
    // snapshot mutation). Also clears ball_owner_ so a final snapshot
    // emitted after end() shows the ball as loose (owner_slot on the
    // wire trailer decodes to kBallOwnerLoose = 0xFFFF), matching the
    // §23.3 Slice 16.4 rule "owner releases ball on match end".
    //
    // Idempotent: safe to call multiple times.
    void end() noexcept;

    // Read -----------------------------------------------------------------
    MatchId                       id() const noexcept  { return id_; }
    TickNum                       tick_num() const noexcept;
    math::Fixed64                 elapsedSeconds() const noexcept;
    bool                          ended() const noexcept { return ended_; }
    Snapshot                      snapshot() const;
    const std::vector<Slot>&      slots() const noexcept { return slots_; }

    // Slice 17.7a: exposed so SimServer can encode SCENARIO_META right
    // after HELLO_ACK. Cached at construction from
    // scenario_->playableArea(); never mutated after that (playable-area
    // deltas mid-match need a new msg_type — see §22.22).
    const scenario::PlayableArea& playableArea() const noexcept {
        return playable_area_;
    }

    // Slice 28.3: one queued goal detected in Match::tick, pending
    // persistence + wire emission by SimServer. Match itself owns no
    // IPgClient / IEventLog — the domain-simulation ↔ persistence
    // separation established in Slice 13 is preserved by exposing
    // detected goals through this drain-on-read structure, exactly as
    // Snapshot() already does for wire state.
    //
    // `kicker_slot` is nullopt when Match cannot attribute the goal to
    // a slot — e.g. the ball was dribbled into the region (no kick
    // fired since match start), or the last kicker was cleared by a
    // previous goal. Encoded as kGoalKickerSlotUnknown = 0 on the
    // wire (see ADR §22.25).
    struct PendingGoal {
        TickNum                tick_num{0};
        std::uint8_t           goal_region_index{0};
        std::optional<SlotId>  kicker_slot{std::nullopt};
    };

    // Slice 28.3: hand the caller the goals detected since the last
    // drain and clear the internal queue in one atomic step. SimServer
    // calls this after `match_->tick()` each frame and pushes every
    // returned entry to the async EventLog. Match retains no reference.
    // Test callers use this same API to assert emission.
    std::vector<PendingGoal>      drainPendingGoals();

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

    // Slice 17.3: cached playable-area constraint from
    // scenario_->playableArea() at construction time. Held by value
    // (small struct: vector<Vec3> + mode enum + zoom hint) so tick()
    // can hot-path the polygon without a virtual dispatch per tick.
    // Mode == Advisory (M0/M1 default) or an empty polygon → tick()
    // skips constraint work entirely, preserving the canonical hash
    // for the baseline scenarios.
    scenario::PlayableArea                      playable_area_;

    std::vector<Slot>                           slots_;
    std::vector<MechanicsParams>                params_by_slot_;   // 1:1 with slots_
    std::optional<EntityId>                     ball_{std::nullopt};

    // Slice 16.3: which slot currently controls the ball, if any.
    // Set/cleared by BallControl each tick (see mechanics/BallControl.hpp).
    // Also surfaced through snapshot() so the wire trailer's owner
    // field can convey it to clients for the Slice 16.5 indicator ring.
    std::optional<SlotId>                       ball_owner_{std::nullopt};

    // Slice 26.3 (ADR §22.23): countdown of remaining ticks during
    // which BallPhysics::tickBall must suppress its snap-to-rest
    // clamp. Armed to physics::kKickAliveTicks the tick a kick fires
    // (via BallControl::resolveBallControl returning `kicked = true`),
    // decremented each tick, saturated at 0. Zero for every tick of
    // every existing determinism golden (no kick fires), so
    // tickBall's default `skip_rest_snap = false` path is preserved
    // byte-identically.
    int                                         kick_alive_ticks_remaining_{0};

    // Slice 28.3: last kicker for Goal event attribution.
    //
    // Set whenever the release-on-kick path fires (BallControl returns
    // `kicked = true`) to the slot that was the ball's owner
    // immediately before the release, i.e. whichever slot's Intent
    // asserted `wants_kick`. Read once by the post-physics goal-
    // detection loop below; cleared after a goal fires so a subsequent
    // goal in a different region is not misattributed to a stale
    // kicker. nullopt on match start and after every emitted goal.
    // Written into the ADR §22.25 v1 payload's kicker_slot_id field
    // (u16 LE, offset 2..3); nullopt → kGoalKickerSlotUnknown = 0.
    std::optional<SlotId>                       last_kicker_slot_{std::nullopt};

    // Slice 28.3: previous-tick goal-region containment for edge-
    // triggered goal detection.
    //
    // Set at the tail of tick() to whichever `GoalRegion::index` the
    // ball's post-physics AABB check landed in, or nullopt when the
    // ball was outside every region (the common case). A goal fires
    // only on the transition `nullopt/other -> index_i`, so the ball
    // sitting still inside the region across many ticks (which Slice
    // 28.3 arranges by zeroing ball velocity on emit) emits exactly
    // one row.
    std::optional<std::uint8_t>                 prev_ball_goal_region_index_{std::nullopt};

    // Slice 28.3: drain queue for goals detected in tick(). SimServer
    // consumes via drainPendingGoals() after each tick. Kept small and
    // stack-friendly; a well-behaved M2 match emits << 100 goals total.
    std::vector<PendingGoal>                    pending_goals_;

    bool                                        ended_{false};
};

} // namespace fh::sim::match
