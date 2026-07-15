// footballhome sim - BallOnPitchScenario
//
// M1 demo scenario: 105 m × 68 m pitch, one ball, and — in interactive
// (default-ctor) mode — two player slots flanking the ball 5 m west
// and 5 m east so two clients can contest for it. The scripted-ctor
// path (Slice 15.6 cross-arch determinism test) starts the ball with a
// caller-supplied initial velocity AND emits zero slots so the golden
// hash `ball_roll_east_400_ticks_seed_42` stays locked.
//
// Slice 15 exit gate (DESIGN.md §23.3): "BallOnPitchScenario shows a
// ball rolling from a stationary start (visual test) and from a
// scripted initial velocity (deterministic test)."
//
// Slice 16 / Slice 18.1 landing note: the interactive path additionally
// spawns SlotId{1} at (-5, 0) facing east so the tactical-games
// "🎾 Ball on Pitch" tile actually delivers joystick control
// (BallControl first-touch fires when the claimed player walks the
// ball_control_radius = 0.5 m — so the demo starts with a 5 m stroll).
//
// M2 preview (2026-07-15): the interactive path now ALSO spawns
// SlotId{2} at (+5, 0) facing west so a second connecting client
// contests for the ball from the east side. Slice 16.6's tie-break
// rule (lower SlotId wins equidistant first-touch) is exercised by
// the resulting 5 m symmetric race when both clients walk inward.
// Solo-play behaviour (Slice 24.2): the unclaimed slot spawns an
// IdleController (see Scenario::unclaimedSlotsIdle) and renders as a
// stationary AI dot \u2014 a training-dummy target that will not fight
// the joystick user's dribble line.
//
// DB row + scenario_id: see migration 207-sim-scenarios-ball-on-pitch.sql
// (assigns id=1) and Replay.cpp::makeScenario (adds the id=1 → this-class
// branch). Runtime enum matches DB row per §22.9.

#pragma once

#include "scenario/Scenario.hpp"

#include <optional>
#include <vector>

namespace fh::sim::scenario {

class BallOnPitchScenario : public Scenario {
public:
    // Interactive default: ball at centre spot at rest + two SlotSpawns
    // flanking the ball (SlotId{1} 5 m west facing east, SlotId{2} 5 m
    // east facing west).
    BallOnPitchScenario() noexcept;

    // Slice 24.2: unclaimed slots idle instead of wandering. Preserves
    // solo dribble-practice feel by keeping the un-piloted flank as a
    // stationary target dummy at (+5, 0) or (-5, 0). Scripted ctor is
    // unaffected — it emits zero slots, so this policy is never queried
    // and the Slice 15.6 golden `ball_roll_east_400_ticks_seed_42` =
    // `0x7c3932be60cba2aa` remains locked.
    bool unclaimedSlotsIdle() const override { return true; }

    // Scripted variant (determinism/drills): caller-supplied initial
    // ball state, ZERO slots. Preserves the Slice 15.6 golden hash
    // `ball_roll_east_400_ticks_seed_42` — do not add slots here.
    explicit BallOnPitchScenario(BallSpawn scripted_ball) noexcept;

    std::string           id() const override          { return "ball_on_pitch"; }
    std::string           displayName() const override { return "Ball on Pitch"; }

    PitchSpec             pitch() const override         { return pitch_; }
    PlayableArea          playableArea() const override  { return playable_; }
    std::vector<SlotSpawn> initialSpawns() const override { return spawns_; }
    std::optional<BallSpawn> ballSpawn() const override   { return ball_; }

    bool checkSuccess(const awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const awareness::WorldView& w) const override { (void)w; return false; }

    std::vector<std::string> hints() const override;

private:
    PitchSpec               pitch_;
    PlayableArea            playable_;
    BallSpawn               ball_;
    std::vector<SlotSpawn>  spawns_;   // empty in scripted mode
};

} // namespace fh::sim::scenario
