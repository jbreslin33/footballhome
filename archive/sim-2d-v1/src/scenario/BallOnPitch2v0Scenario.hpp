// footballhome sim - BallOnPitch2v0Scenario (Slice 26.3)
//
// M2 short-pass primitive demo. Same geometry family as
// BallOnPitchScenario but the two claimable slots spawn 15 m either
// side of the centre spot (30 m apart total) — far enough that
// dribbling to close the distance is slower than passing, so the new
// wants_kick trailer + BallControl release-on-kick + BallPhysics::
// applyImpulse code paths (Slice 26.3, ADR §22.23) are the fastest way
// to get the ball from slot 1 to slot 2 and back.
//
// Ball rests on the centre spot. Both slots are human-claimable; the
// unclaimed policy is Idle (same as BallOnPitchScenario) so a solo
// user gets a stationary receiver dummy on the far flank instead of
// an AI that wanders into or away from the pass line.
//
// This is the FIRST scenario whose intended play loop requires the
// short-pass primitive. Determinism goldens are added in Slice 26.6;
// through Slice 26.3-26.5 the scenario is only exercised interactively
// via the tactical-games UI + wire path.
//
// DB row + scenario_id: see migration
// 219-sim-scenarios-ball-on-pitch-2v0.sql (assigns id=5) and
// Replay.cpp::makeScenario (adds the id=5 → this-class branch).
// Runtime enum matches DB row per §22.9.

#pragma once

#include "scenario/Scenario.hpp"

#include <optional>
#include <vector>

namespace fh::sim::scenario {

class BallOnPitch2v0Scenario : public Scenario {
public:
    // Interactive default: ball at centre spot at rest + two SlotSpawns
    // 15 m either side of the centre spot (SlotId{1} at (-15, 0)
    // facing east, SlotId{2} at (+15, 0) facing west).
    BallOnPitch2v0Scenario() noexcept;

    // Solo-play behaviour: the unclaimed flank spawns an IdleController
    // (per Scenario::unclaimedSlotsIdle) so it stands still as a
    // pass target instead of wandering. Symmetric with
    // BallOnPitchScenario's Slice 24.2 policy.
    bool unclaimedSlotsIdle() const override { return true; }

    std::string           id() const override          { return "ball_on_pitch_2v0"; }
    std::string           displayName() const override { return "Ball on Pitch 2v0"; }

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
    std::vector<SlotSpawn>  spawns_;
};

} // namespace fh::sim::scenario
