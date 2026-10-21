// footballhome sim - GoalDrillScenario (Slice 28.2)
//
// M2 shots-on-goal demo. Same pitch as BallOnPitch2v0Scenario (105×68 m,
// ball on centre spot) but adds two goal AABBs at the pitch ends via the
// Slice 28.2 Scenario::goalRegions() override. Slot 1 spawns 15 m west
// facing east (aimed at the east goal); Slot 2 spawns 15 m east facing
// west (aimed at the west goal). Both slots are human-claimable; the
// unclaimed policy is Idle so a solo user gets a stationary target
// dummy on the far flank while they practise shooting.
//
// This is the FIRST scenario that actually exercises the goal-region
// API. Match::tick's post-physics goal-detection loop (Slice 28.3) will
// iterate the two regions returned here and emit
// sim_match_events.event_type=9 (Goal, ADR §22.25 v1 payload) when the
// ball enters one for the first time. Slice 28.2 lands the geometry
// without the detection loop; interactive play is a no-op until 28.3.
//
// Goal geometry (regulation-adjacent, deterministic-friendly):
//   * Pitch spans x ∈ [-52.5, +52.5] m, y ∈ [-34, +34] m, z ∈ [0, ∞).
//   * Goal width: FIFA regulation 7.32 m (half = 3.66 m via
//     Fixed64::fromFraction(732, 200) — exact in Q32.32 up to LSB).
//   * Goal depth (behind the goal line, extending outward from pitch
//     centre): 2 m — mirrors real goal-net depth and gives the Slice
//     28.3 AABB-inclusion check enough runway to catch tunneling at
//     pass_power = 15 m/s ⋅ 50 ms/tick = 0.75 m/tick. Ball has to
//     linger in-region for ≥1 tick to be counted, which is trivial at
//     M2 speeds inside a 2 m strip.
//   * Goal height: 2.44 m (FIFA regulation). Currently unused by M2's
//     essentially-2D physics (ball height z stays ≈ 0), but declared
//     honestly so the field renders correctly when we ship 3D shots.
//
// Region indices (per GoalRegion::index contract):
//   * regions[0] = west goal (defended by whoever is playing west;
//     spawns[1] shoots at this one facing -x).
//   * regions[1] = east goal (defended by whoever is playing east;
//     spawns[0] shoots at this one facing +x).
//
// The `index` field is written verbatim into the Goal payload's
// goal_region_index byte (ADR §22.25 v1 offset 1). Do not renumber.
//
// DB row + scenario_id: see migration
// 222-sim-scenarios-goal-drill.sql (assigns id=6) and
// Replay.cpp::makeScenario (adds the id=6 → this-class branch).
// Runtime enum matches DB row per §22.9.

#pragma once

#include "scenario/Scenario.hpp"

#include <optional>
#include <vector>

namespace fh::sim::scenario {

class GoalDrillScenario : public Scenario {
public:
    // Interactive default: ball at centre spot at rest + two SlotSpawns
    // 15 m either side of the centre spot facing the far goal. Goal
    // regions built once in the constructor and returned by value from
    // goalRegions().
    GoalDrillScenario() noexcept;

    // Solo-play behaviour matches BallOnPitch2v0Scenario: unclaimed slots
    // idle so the human can walk over and claim, then pick up a
    // stationary target dummy on the far flank rather than a wandering AI.
    bool unclaimedSlotsIdle() const override { return true; }

    std::string           id() const override          { return "goal_drill"; }
    std::string           displayName() const override { return "Goal Drill"; }

    PitchSpec             pitch() const override         { return pitch_; }
    PlayableArea          playableArea() const override  { return playable_; }
    std::vector<SlotSpawn> initialSpawns() const override { return spawns_; }
    std::optional<BallSpawn> ballSpawn() const override   { return ball_; }

    // Slice 28.2: two goal AABBs at the pitch ends. Constant across the
    // scenario's lifetime; returned by value from a member vector so the
    // Slice 28.3 goal-detection loop can copy-elide the call each tick.
    std::vector<GoalRegion> goalRegions() const override { return goal_regions_; }

    bool checkSuccess(const awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const awareness::WorldView& w) const override { (void)w; return false; }

    std::vector<std::string> hints() const override;

private:
    PitchSpec                pitch_;
    PlayableArea             playable_;
    BallSpawn                ball_;
    std::vector<SlotSpawn>   spawns_;
    std::vector<GoalRegion>  goal_regions_;
};

} // namespace fh::sim::scenario
