// game/src/ai/concepts/Machines.cpp — see Machines.hpp.

#include "ai/concepts/Machines.hpp"

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

// Into a new state, unless the machine is committed: a state it is in is kept hold_ticks before it
// drops to a lower one, unless what it lives in has gone (may_leave).
void PlayerMachines::set(MachineState& m, std::uint8_t state, std::int16_t other, std::uint64_t tick, bool may_leave) {
    if (state == m.state) { m.other = other; return; }
    // [behaviour: machine_commit]
    // Committed only on the way DOWN (to a lower state, asleep the lowest): a machine can go deeper
    // into its state at once (on → stepping), but does not drop back for 0.3 s.
    if (m.state != kAsleep && state < m.state && !may_leave && tick < m.since + p_.hold_ticks) return;
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
    {   // RECOVER — the line is broken behind him: get back goal-side first
        // [behaviour: machine_recover]
        auto& m = me[static_cast<int>(MachineId::Recover) - 1];
        if (s.their_ball && s.job == Job::Hold && s.behind) set(m, recover::GettingBack, -1, tick, false);
        else set(m, recover::Asleep, -1, tick, s.job != Job::Hold || !s.their_ball);
    }
    {   // PRESS, LOOSE BALL, DOUBLE-TEAM — the engine's one presser, first man to the loose ball, second man
        // [behaviour: machine_press_chase_double]
        auto& p = me[static_cast<int>(MachineId::Press) - 1];
        if (s.job == Job::Press) set(p, press::Closing, static_cast<std::int16_t>(s.carrier), tick, true);
        else set(p, press::Asleep, -1, tick, true);
        auto& l = me[static_cast<int>(MachineId::LooseBall) - 1];
        if (s.job == Job::Chase) set(l, looseball::Going, -1, tick, true);
        else set(l, looseball::Asleep, -1, tick, true);
        auto& d = me[static_cast<int>(MachineId::DoubleTeam) - 1];
        if (s.job == Job::DoubleTeam) set(d, doubleteam::SecondMan, static_cast<std::int16_t>(s.carrier), tick, true);
        else set(d, doubleteam::Asleep, -1, tick, true);
    }
    {   // COVER — the deeper centre-back behind the one who steps
        // [behaviour: machine_cover]
        auto& m = me[static_cast<int>(MachineId::Cover) - 1];
        if (s.their_ball && s.job == Job::Hold && s.cover) set(m, cover::Behind, -1, tick, false);
        else set(m, cover::Asleep, -1, tick, s.job != Job::Hold || !s.their_ball);
    }
    {   // PRESSING DISTANCE
        // [behaviour: machine_pressing_distance]
        auto& m = me[static_cast<int>(MachineId::PressingDistance) - 1];
        const bool out = s.step.x.raw != 0 || s.step.y.raw != 0;
        const bool on_ball_job = s.job == Job::Press || s.job == Job::Chase || s.job == Job::DoubleTeam;
        // His man: the one he marks while marking (the block's assignment), else his direct opponent —
        // the same man the marking scheme names, never two different "his man" at once.
        const int man = s.job == Job::Mark && s.mark >= 0 ? s.mark : s.direct;
        if (!s.their_ball || keeper || man < 0 || on_ball_job) set(m, pdist::Asleep, -1, tick, true);
        else if (s.job == Job::Hold && out && s.press_hold.raw > 0) set(m, pdist::Stepping, static_cast<std::int16_t>(man), tick, false);
        else set(m, pdist::On, static_cast<std::int16_t>(man), tick, false);
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
    if (outranked(slot, MachineId::PressingDistance)) return false;   // recover is getting him back first
    if (step.x.raw == 0 && step.y.raw == 0) return false;
    target = Vec2{target.x + step.x * dial, target.y + step.y * dial};
    return true;
}

// [behaviour: machine_resolver]
// Two awake machines that want different spots: the higher in kPriority (machine_order) wins.
MachineId PlayerMachines::driver(core::SlotIndex slot, bool& driving) const {
    for (const MachineId m : kPriority)
        if (takesSpot(m) && awake(slot, m)) { driving = true; return m; }
    driving = false;
    return MachineId::Marking;
}

bool PlayerMachines::outranked(core::SlotIndex slot, MachineId m) const {
    bool driving = false;
    const MachineId d = driver(slot, driving);
    return driving && rankOf(d) < rankOf(m);
}

// [behaviour: recover_takes_his_spot]
// The first machine that REPLACES the job's orders: with the line broken behind him (his place 5 m+
// goal-side of him) he goes straight back to it — pressing distance does not pull him off it to
// his man until he is back. The place is the one the job worked out; recover owns it.
bool PlayerMachines::recoverTo(core::SlotIndex slot, Vec2 place, Vec2& target) const {
    bool driving = false;
    if (driver(slot, driving) != MachineId::Recover || !driving) return false;
    target = place;
    return true;
}

}  // namespace fh::game::ai::concepts
