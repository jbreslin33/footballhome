// footballhome sim - EmptyPitchScenario
//
// The M0 scenario. 105 m × 68 m pitch, up to 12 slots, no ball, no playable-
// area constraint, no success/reset conditions. All slots start on a simple
// 3-line grid so joining players see themselves immediately.
//
// See DESIGN.md §5.6, §16.1, §16.4.

#pragma once

#include "scenario/Scenario.hpp"

namespace fh::sim::scenario {

class EmptyPitchScenario : public Scenario {
public:
    // Default: 12 slots. Match will only spawn as many as are claimed.
    explicit EmptyPitchScenario(std::size_t slot_count = 12) noexcept;

    std::string                 id() const override            { return "empty_pitch"; }
    std::string                 displayName() const override   { return "Empty Pitch"; }
    PitchSpec                   pitch() const override         { return pitch_; }
    PlayableArea                playableArea() const override  { return playable_; }
    std::vector<SlotSpawn>      initialSpawns() const override { return spawns_; }
    std::optional<math::Vec3>   ballSpawn() const override     { return std::nullopt; }

    bool checkSuccess(const awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset(const awareness::WorldView& w)   const override { (void)w; return false; }

    std::vector<std::string>    hints() const override;

private:
    PitchSpec               pitch_;
    PlayableArea            playable_;   // M0: empty polygon = no constraint
    std::vector<SlotSpawn>  spawns_;
};

} // namespace fh::sim::scenario
