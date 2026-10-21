// footballhome sim - BallOnPitchWithDefenderScenario
//
// Slice 24.3a demo scenario: identical geometry to BallOnPitchScenario
// (105 m × 68 m pitch, ball at centre spot at rest, SlotId{1} 5 m west
// facing east, SlotId{2} 5 m east facing west) but slot 2 is spawned
// as an LCB with Defender-kind AiController policy — an AI that jogs
// toward the ball every tick instead of standing still. Slot 1 stays Idle so the human
// client can claim it and take the ball; the point of the demo is to
// give the Slice 25.2 sprint-with-ball feature a *reason* — outrun
// the AI or lose ground.
//
// No contest / touch-to-steal mechanic yet — that lands in Slice 24.3b.
// So if the defender reaches the ball first (human afk) it just stands
// on top of it; if the human owns the ball and the defender catches
// up, the defender stands on top of the owner. Visually the "chase"
// is the whole point of the slice.
//
// DB row + scenario_id: see migration
// 215-sim-scenarios-ball-on-pitch-with-defender.sql (assigns id=4)
// and Replay.cpp / main.cpp (add matching id=4 branches). Runtime
// enum matches DB row per §22.9.
//
// See DESIGN.md §23.3 Slice 24.3.

#pragma once

#include "scenario/Scenario.hpp"

#include <optional>
#include <vector>

namespace fh::sim::scenario {

class BallOnPitchWithDefenderScenario : public Scenario {
public:
    // Interactive: ball at centre spot at rest, SlotId{1} 5 m west
    // facing east (human-claimable, defaults to Idle when unclaimed),
    // SlotId{2} 5 m east facing west (LCB Defender-kind AI, jogs toward the ball).
    BallOnPitchWithDefenderScenario() noexcept;

    std::string           id() const override          { return "ball_on_pitch_with_defender"; }
    std::string           displayName() const override { return "Ball on Pitch + Defender"; }

    PitchSpec              pitch() const override          { return pitch_; }
    PlayableArea           playableArea() const override   { return playable_; }
    std::vector<SlotSpawn> initialSpawns() const override  { return spawns_; }
    std::optional<BallSpawn> ballSpawn() const override    { return ball_; }

    bool checkSuccess(const awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const awareness::WorldView& w) const override { (void)w; return false; }

    std::vector<std::string> hints() const override;

    // Slot 1 → Idle (waits for a human client to claim it; falls back
    // to Idle on release so a disconnect doesn't hand the ball back
    // to a wandering AI). Slot 2 → Defender (jogs toward the ball).
    // Any other slot ID → Idle for safety, though this scenario only
    // spawns slots 1 and 2.
    UnclaimedControllerKind unclaimedControllerFor(SlotId slot) const override
    {
        return (slot == SlotId{2}) ? UnclaimedControllerKind::Defender
                                   : UnclaimedControllerKind::Idle;
    }

    // Slice 24.3b: give slot 2 (the AI defender) a WEAK dribble so the
    // demo's steal-back leg actually resolves. Default dribble_efficiency
    // is 0.85 and default press_resistance is 0.75 → skill_delta clamps
    // to 0 → effective retention radius equals the ball glue distance
    // (both 0.4 m) → Rule 2's `<=` retention holds forever and the
    // human can never strip. Lowering slot 2's dribble_efficiency to
    // 0.55 puts the human's default 0.75 press 0.20 above it, which
    // shrinks the retention radius to 0.5 - 0.1 - 0.5*0.20 = 0.30 m —
    // well under the 0.4 m glue distance, so a same-tick press ends
    // retention and Rule 1 first-touch hands the ball to whoever's
    // closer (the pressing human).
    //
    // Slot 1 (human) uses defaults so it dribbles at the standard
    // rate once it owns the ball, and the defender's default 0.75
    // press vs the human's 0.85 dribble_efficiency correctly FAILS to
    // strip — matching M0Attributes' design comment ("default defender
    // pressing a default attacker does NOT win"). The asymmetry lives
    // in this scenario only; global defaults stay balanced.
    void applyPhysicalOverrides(SlotId                 slot,
                                profile::AttributeSet& attrs) const override;

    // Slice 30.2: plug the `pressing` concept into slot 2's ConceptSet
    // so the AiController spawned by Match for Defender-kind slots
    // finds the concept its PursueBallCarrierBehavior presence-gates
    // on. Slot 1 (human) gets no override — even if a client releases
    // slot 1 it stays Idle, no AI reads its concepts.
    void applyConceptOverrides(SlotId                 slot,
                               profile::ConceptSet&   concepts) const override;

private:
    PitchSpec               pitch_;
    PlayableArea            playable_;
    BallSpawn               ball_;
    std::vector<SlotSpawn>  spawns_;
};

} // namespace fh::sim::scenario
