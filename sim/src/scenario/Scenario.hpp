// footballhome sim - Scenario interface
//
// A Scenario declares a self-contained gameplay setup: pitch dimensions,
// playable-area constraints, initial slot spawns, and the ball's starting
// position if any. Scenarios are pure declaration + read-only checks —
// they do not own state or drive simulation.
//
// M0 has exactly one scenario: EmptyPitchScenario.
//
// See DESIGN.md §5.6, §16.1.

#pragma once

#include "awareness/AwarenessView.hpp"
#include "common/IdTypes.hpp"
#include "common/Role.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "profile/ConceptSet.hpp"
#include "profile/PlayerProfile.hpp"

#include <cstdint>
#include <optional>
#include <string>
#include <vector>

namespace fh::sim::scenario {

struct PitchSpec {
    math::Fixed64 length_m;    // FIFA regulation: 105 m
    math::Fixed64 width_m;     // FIFA regulation: 68  m
};

struct PlayableArea {
    // Polygon defining the region where the ball is considered in play.
    // M0: usually a rectangle at the pitch corners. Empty vector = no
    // constraint (M0 default: whole pitch is playable).
    std::vector<math::Vec3> polygon;

    enum class Mode : std::uint8_t {
        Hard      = 0,  // ball is snapped back / play resets
        Soft      = 1,  // event fires but play continues
        Advisory  = 2,  // no engine action; UI hint only
    };
    Mode          constraint_mode{Mode::Advisory};
    math::Fixed64 zoom_hint{math::Fixed64::zero()};   // client camera fit
};

// Initial ball state for a scenario. Returned by Scenario::ballSpawn() to
// let the Match spawn a ball entity (is_ball=true) at construction time.
// Position and velocity are in the same pitch-space Vec3 coordinates as
// player spawns. A zero-velocity BallSpawn is a legitimate "ball at rest
// on the centre spot" configuration (M1's demo case).
//
// Kept as a struct rather than an alias for math::Vec3 so future scenarios
// can add spin, height, owner-slot, etc. without another API break.
//
// See DESIGN.md §23.3 Slice 15.2.
struct BallSpawn {
    math::Vec3 position;
    math::Vec3 velocity;
};

struct SlotSpawn {
    SlotId        slot;
    math::Vec3    position;
    math::Fixed64 heading;
    Role          role{Role::Any};

    // If the slot starts controlled by AI, this is what to plug into it.
    // In M0 the unclaimed default is WanderController; these fields are
    // for M3+ AiController slots.
    //
    // The three fields are mutually exclusive by intent, though we do not
    // enforce it at type level:
    //
    //   ai_profile_source  -> at match setup, runtime calls
    //                         ProfileStore::load(person_id) and injects
    //                         the loaded PlayerProfile into the AI slot.
    //                         Use this to drive AI pieces from a real
    //                         teammate's profile ("our player names on AI
    //                         pieces" product feature). Wiring lands with
    //                         M3's first AiController scenario; M0 leaves
    //                         it nullopt.
    //   ai_profile         -> inline literal profile blob. Use for
    //                         synthetic AI pieces (drills, tutorials)
    //                         where no real person owns the profile.
    //   ai_concepts        -> inline concept overlay layered on top of
    //                         whichever profile source was picked above.
    //                         Use for drill-specific plays that shouldn't
    //                         mutate the AI's persisted concept set.
    //
    // If both ai_profile_source and ai_profile are set, ai_profile_source
    // wins (persisted-profile-of-record takes precedence over inline blob)
    // — see DESIGN.md §21.2 item 1 resolution note.
    std::optional<PersonId>               ai_profile_source;
    std::optional<profile::ConceptSet>    ai_concepts;
    std::optional<profile::PlayerProfile> ai_profile;
};

// Slice 24.3a: which controller kind Match should build for an
// unclaimed slot. Deliberately an enum in Scenario's namespace rather
// than a std::unique_ptr<IPlayerController> factory — that would drag
// the controller/ headers into every scenario translation unit and
// invert the "Scenario is a lower layer than controller" dependency
// direction. Match owns the enum -> concrete controller mapping.
//
// Determinism note (per §22.9 goldens contract): Wander is the ONLY
// kind that consumes RNG. Idle and Defender consume none. Any scenario
// that returns Idle/Defender for every unclaimed slot is safe to add
// without perturbing RNG-keyed goldens; a scenario mixing Wander with
// anything else must ship its own golden hash.
enum class UnclaimedControllerKind : std::uint8_t {
    Wander   = 0,   // WanderController — M0/M1 default, consumes RNG
    Idle     = 1,   // IdleController   — Slice 24.2, zero RNG
    Defender = 2,   // DefenderController — Slice 24.3a, zero RNG, pursues ball
};

class Scenario {
public:
    virtual ~Scenario() = default;

    // Stable identifier, matches sim_scenarios.code_id.
    virtual std::string          id() const = 0;
    virtual std::string          displayName() const = 0;

    virtual PitchSpec            pitch() const = 0;
    virtual PlayableArea         playableArea() const = 0;
    virtual std::vector<SlotSpawn> initialSpawns() const = 0;
    virtual std::optional<BallSpawn> ballSpawn() const = 0;   // M0: none

    // Ended / success / reset predicates over WorldView. M0: all return
    // false (empty-pitch never ends by itself).
    virtual bool                 checkSuccess(const awareness::WorldView& w) const = 0;
    virtual bool                 checkReset(const awareness::WorldView& w)   const = 0;

    // Short user-facing hints shown pre-match.
    virtual std::vector<std::string> hints() const = 0;

    // Slice 24.2 (M2 in progress): controller policy for unclaimed slots.
    //   false (default) -> Match spawns WanderController for unclaimed
    //                      slots, matching the M0/M1 behavior every
    //                      determinism golden was locked against.
    //   true            -> Match spawns IdleController instead — the slot
    //                      stands still until a human client claims it,
    //                      then reverts to Idle on release. Use for
    //                      human-interactive demo scenarios where a
    //                      wandering AI would fight the joystick user.
    //
    // Any override that returns true MUST also have zero determinism
    // goldens that exercise its slots — IdleController consumes zero RNG
    // whereas WanderController consumes RNG on every target repick, so
    // flipping this changes the canonical hash of a scripted-slot run.
    virtual bool                 unclaimedSlotsIdle() const { return false; }

    // Slice 24.3a: finer-grained per-slot controller policy for
    // scenarios that mix multiple AI behaviours (e.g. a demo that puts
    // one unclaimed slot on Idle so the human can claim it and puts
    // another on Defender so the human has something to dribble past).
    //
    // The default implementation collapses to the boolean above so
    // every pre-24.3 scenario keeps its existing behaviour bit-for-bit
    // without an override — WanderController on Wander, IdleController
    // on Idle. Anything richer than "all-idle vs all-wander" overrides
    // this method and returns the correct kind per SlotId.
    //
    // Match (spawnInitialSlots and reclaimSlotToUnclaimed) is the
    // single dispatch point: it takes the returned enum and constructs
    // the matching concrete controller. Scenario stays free of any
    // dependency on controller/ headers — the coupling lives in Match.
    //
    // Determinism: Wander is the ONLY kind that consumes RNG. Idle and
    // Defender consume none. So any new scenario that returns Idle
    // and/or Defender for every unclaimed slot is safe to introduce
    // without breaking scripted-slot goldens keyed to the RNG stream.
    virtual UnclaimedControllerKind
        unclaimedControllerFor(SlotId /*slot*/) const
    {
        return unclaimedSlotsIdle() ? UnclaimedControllerKind::Idle
                                    : UnclaimedControllerKind::Wander;
    }
};

} // namespace fh::sim::scenario
