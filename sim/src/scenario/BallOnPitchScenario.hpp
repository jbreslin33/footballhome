// footballhome sim - BallOnPitchScenario
//
// M1 demo scenario: 105 m × 68 m pitch, zero player slots, one ball. The
// ball defaults to the centre spot at rest; the constructor accepts a
// BallSpawn override so drills and determinism tests can start the ball
// with a scripted initial velocity (Slice 15.6).
//
// Slice 15 exit gate (DESIGN.md §23.3): "BallOnPitchScenario shows a
// ball rolling from a stationary start (visual test) and from a
// scripted initial velocity (deterministic test). No slot claims
// required; empty match with a rolling ball is a legitimate demo."
//
// DB row + scenario_id: see migration 207-sim-scenarios-ball-on-pitch.sql
// (assigns id=1) and Replay.cpp::makeScenario (adds the id=1 → this-class
// branch). Runtime enum matches DB row per §22.9.

#pragma once

#include "scenario/Scenario.hpp"

#include <optional>

namespace fh::sim::scenario {

class BallOnPitchScenario : public Scenario {
public:
    // Default: ball at the pitch centre (0,0,0), stationary. Callers that
    // need a scripted initial velocity (e.g., the Slice 15.6 cross-arch
    // determinism test) pass a fully-specified BallSpawn.
    explicit BallOnPitchScenario(std::optional<BallSpawn> ball = std::nullopt) noexcept;

    std::string           id() const override          { return "ball_on_pitch"; }
    std::string           displayName() const override { return "Ball on Pitch"; }

    PitchSpec             pitch() const override         { return pitch_; }
    PlayableArea          playableArea() const override  { return playable_; }
    std::vector<SlotSpawn> initialSpawns() const override { return {}; }
    std::optional<BallSpawn> ballSpawn() const override   { return ball_; }

    bool checkSuccess(const awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const awareness::WorldView& w) const override { (void)w; return false; }

    std::vector<std::string> hints() const override;

private:
    PitchSpec       pitch_;
    PlayableArea    playable_;
    BallSpawn       ball_;
};

} // namespace fh::sim::scenario
