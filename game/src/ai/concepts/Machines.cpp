// game/src/ai/concepts/Machines.cpp — see Machines.hpp.

#include "ai/concepts/Machines.hpp"

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

// Into a new state, unless the machine is awake and committed: an awake state is kept for
// hold_ticks, unless what it lives in has gone (may_leave).
void PlayerMachines::set(MachineState& m, std::uint8_t state, std::int16_t other, std::uint64_t tick, bool may_leave) {
    if (state == m.state) { m.other = other; return; }
    // [behaviour: machine_commit]
    if (m.state != kAsleep && !may_leave && tick < m.since + p_.hold_ticks) return;
    m.state = state;
    m.other = other;
    m.since = tick;
}

void PlayerMachines::update(core::SlotIndex slot, const MachineSense& s, std::uint64_t tick) {
    auto& me = st_[slot & 31];
    const bool keeper = s.job == Job::Keeper;

    {   // MARKING SCHEME
        // [behaviour: machine_marking_scheme]
        auto& m = me[static_cast<int>(MachineId::Marking) - 1];
        if (!s.their_ball || keeper) set(m, marking::Asleep, -1, tick, true);
        else if (s.job == Job::Mark && s.mark >= 0) set(m, marking::Zonal, static_cast<std::int16_t>(s.mark), tick, false);
        else if (s.direct >= 0) set(m, marking::Watching, static_cast<std::int16_t>(s.direct), tick, false);
        else set(m, marking::Free, -1, tick, false);
    }
    {   // COVER SHADOW
        // [behaviour: machine_cover_shadow]
        auto& m = me[static_cast<int>(MachineId::CoverShadow) - 1];
        int first = -1;
        for (int t = 0; t < 32 && first < 0; ++t) if ((s.hidden >> t) & 1u) first = t;
        if (!s.their_ball || keeper) set(m, shadow::Asleep, -1, tick, true);
        else if (s.job == Job::Press && s.shadow_press.raw > 0 && s.screen >= 0)
            set(m, shadow::OnTheLane, static_cast<std::int16_t>(s.screen), tick, false);
        else if (first >= 0) set(m, shadow::Hiding, static_cast<std::int16_t>(first), tick, s.job != Job::Press);
        else set(m, shadow::Asleep, -1, tick, s.job != Job::Press);
    }
    {   // PRESSING DISTANCE
        // [behaviour: machine_pressing_distance]
        auto& m = me[static_cast<int>(MachineId::PressingDistance) - 1];
        const bool out = s.step.x.raw != 0 || s.step.y.raw != 0;
        if (!s.their_ball || s.job != Job::Hold || s.press_hold.raw <= 0) set(m, pdist::Asleep, -1, tick, true);
        else if (out && s.direct >= 0) set(m, pdist::Stepping, static_cast<std::int16_t>(s.direct), tick, false);
        else set(m, pdist::Asleep, -1, tick, false);
    }
}

// [behaviour: cs_press_along_the_lane]
// The cover shadow's proposal while he presses: his spot off the carrier's line to our goal onto
// the carrier's line to the receiver he hides, the same stand-off from the carrier, by the dial's
// share — he arrives along the pass he blocks.
bool PlayerMachines::bendPress(core::SlotIndex slot, Vec2 carrier, Fixed64 standoff, Vec2 receiver, Fixed64 dial, Vec2& target) const {
    if (of(slot, MachineId::CoverShadow).state != shadow::OnTheLane || dial.raw <= 0) return false;
    const Vec2 to_r{receiver.x - carrier.x, receiver.y - carrier.y};
    const Fixed64 lr = math::length(to_r);
    if (lr <= standoff) return false;
    const Vec2 lane{carrier.x + to_r.x * standoff / lr, carrier.y + to_r.y * standoff / lr};
    target = Vec2{target.x + (lane.x - target.x) * dial, target.y + (lane.y - target.y) * dial};
    return true;
}

// [behaviour: pd_bend_his_place]
// Pressing distance's proposal while he holds his place: off it toward his man by the dial's
// share of the step that puts his man back in reach.
bool PlayerMachines::bendHold(core::SlotIndex slot, Vec2 step, Fixed64 dial, Vec2& target) const {
    if (of(slot, MachineId::PressingDistance).state != pdist::Stepping || dial.raw <= 0) return false;
    if (step.x.raw == 0 && step.y.raw == 0) return false;
    target = Vec2{target.x + step.x * dial, target.y + step.y * dial};
    return true;
}

}  // namespace fh::game::ai::concepts
