// footballhome sim - HalfPitchScenario
//
// Slice 17.4: first scenario to exercise the M1 PlayableAreaConstraint
// stack (Slices 17.1–17.3) in Hard mode. Playable area is the east
// half of the standard 105×68 m pitch — an axis-aligned rectangle:
//
//                    y = +34 ─────────────────────
//                              │                  │
//                              │    playable      │
//                              │      area        │
//                              │  (Hard clamp)    │
//                              │                  │
//                    y = -34 ─────────────────────
//                              x = 0             x = 52.5
//
// Two demo slots spawn well inside the polygon so a claiming client can
// walk around and observe the wall behaviour on the west (x = 0) and
// east (x = 52.5) boundaries. Wander AI on unclaimed slots also
// exercises the boundary passively.
//
// DB row + scenario_id: sim_scenarios id=2, code_id='half_pitch_hard'
// (see migration 212-sim-scenarios-half-pitch-hard.sql). Runtime
// makeScenario branch: sim/src/tools/Replay.cpp.
//
// See DESIGN.md §5.6 (PlayableArea semantics), §22.9 (scenario ID
// contract), §23.3 Slice 17.4.

#pragma once

#include "scenario/Scenario.hpp"

namespace fh::sim::scenario {

class HalfPitchScenario : public Scenario {
public:
    HalfPitchScenario() noexcept;

    std::string           id() const override          { return "half_pitch_hard"; }
    std::string           displayName() const override { return "Half Pitch (Hard)"; }

    PitchSpec             pitch() const override          { return pitch_; }
    PlayableArea          playableArea() const override   { return playable_; }
    std::vector<SlotSpawn> initialSpawns() const override { return spawns_; }
    std::optional<BallSpawn> ballSpawn() const override   { return std::nullopt; }

    bool checkSuccess(const awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const awareness::WorldView& w) const override { (void)w; return false; }

    std::vector<std::string> hints() const override;

private:
    PitchSpec              pitch_;
    PlayableArea           playable_;
    std::vector<SlotSpawn> spawns_;
};

} // namespace fh::sim::scenario
