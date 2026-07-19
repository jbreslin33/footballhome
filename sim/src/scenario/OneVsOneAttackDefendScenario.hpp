// footballhome sim - OneVsOneAttackDefendScenario (Slice 34.1)

#pragma once

#include "common/IdTypes.hpp"
#include "scenario/Scenario.hpp"

#include <optional>
#include <vector>

namespace fh::sim::scenario {

class OneVsOneAttackDefendScenario : public Scenario {
public:
    explicit OneVsOneAttackDefendScenario(
        std::optional<PersonId> defender_profile_source = std::nullopt) noexcept;

    std::string id() const override { return "one_v_one_attack_defend"; }
    std::string displayName() const override { return "1v1 Attack vs Defend"; }

    PitchSpec pitch() const override { return pitch_; }
    PlayableArea playableArea() const override { return playable_; }
    std::vector<SlotSpawn> initialSpawns() const override { return spawns_; }
    std::optional<BallSpawn> ballSpawn() const override { return ball_; }
    std::vector<GoalRegion> goalRegions() const override { return goal_regions_; }

    bool checkSuccess(const awareness::WorldView& w) const override;
    bool checkReset(const awareness::WorldView& w) const override;

    std::vector<std::string> hints() const override;

    UnclaimedControllerKind unclaimedControllerFor(SlotId slot) const override;

    void applyConceptOverrides(SlotId slot,
                               profile::ConceptSet& concepts) const override;

private:
    bool ballInEastGoal(const awareness::WorldView& w) const;

    PitchSpec pitch_;
    PlayableArea playable_;
    BallSpawn ball_;
    std::vector<SlotSpawn> spawns_;
    std::vector<GoalRegion> goal_regions_;
};

} // namespace fh::sim::scenario