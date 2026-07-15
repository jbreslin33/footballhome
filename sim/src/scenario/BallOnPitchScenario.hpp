// footballhome sim - BallOnPitchScenario
//
// M1 demo scenario: 105 m × 68 m pitch, one ball, and — in interactive
// (default-ctor) mode — one player slot 5 m west of the ball so a
// connecting client can dribble it. The scripted-ctor path (Slice 15.6
// cross-arch determinism test) starts the ball with a caller-supplied
// initial velocity AND emits zero slots so the golden hash
// `ball_roll_east_400_ticks_seed_42` stays locked.
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
    // Interactive default: ball at centre spot at rest + one SlotSpawn
    // (SlotId{1}) 5 m west of the ball facing east.
    BallOnPitchScenario() noexcept;

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
