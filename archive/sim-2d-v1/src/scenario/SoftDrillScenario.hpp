// footballhome sim - SoftDrillScenario
//
// Slice 17.5: first scenario to exercise the M1 PlayableAreaConstraint
// stack in Soft mode. Playable area is a small rectangle sitting inside
// the full 105×68 m pitch — the "drill zone". A claiming client that
// leaves the drill zone is NOT snapped back (Soft mode does not clamp
// position); instead they receive an inward-facing velocity delta
// proportional to how far they've strayed, so their subsequent motion
// naturally bounces them back inside.
//
//                    y = +15 ─────────────
//                              │  drill  │
//                              │  zone   │
//                              │  (Soft) │
//                              │         │
//                    y = -15 ─────────────
//                              x=-20   x=+20
//
// One demo slot spawns at the centre of the drill zone. Claiming
// clients can wander out through any wall to feel the Soft pushback.
//
// DB row + scenario_id: sim_scenarios id=3, code_id='soft_drill'
// (see migration 213-sim-scenarios-soft-drill.sql). Runtime
// makeScenario branch: sim/src/tools/Replay.cpp.
//
// See DESIGN.md §5.6 (PlayableArea semantics), §22.9 (scenario ID
// contract), §23.3 Slice 17.5.

#pragma once

#include "scenario/Scenario.hpp"

namespace fh::sim::scenario {

class SoftDrillScenario : public Scenario {
public:
    SoftDrillScenario() noexcept;

    std::string           id() const override          { return "soft_drill"; }
    std::string           displayName() const override { return "Soft Drill Zone"; }

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
