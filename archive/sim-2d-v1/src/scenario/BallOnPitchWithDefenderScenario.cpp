// footballhome sim - BallOnPitchWithDefenderScenario implementation

#include "scenario/BallOnPitchWithDefenderScenario.hpp"

#include "common/M0Registry.generated.hpp"
#include "math/FixedMath.hpp"

namespace fh::sim::scenario {

BallOnPitchWithDefenderScenario::BallOnPitchWithDefenderScenario() noexcept
{
    // Same pitch geometry as BallOnPitchScenario — the "with defender"
    // variant is a controller-policy change, not a geometry change.
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    playable_.polygon.clear();
    playable_.constraint_mode = PlayableArea::Mode::Advisory;
    playable_.zoom_hint       = math::Fixed64::zero();

    ball_.position = math::Vec3{math::Fixed64::zero(),
                                math::Fixed64::zero(),
                                math::Fixed64::zero()};
    ball_.velocity = math::Vec3{};  // at rest

    // Slot 1: human-claimable position 5 m west of ball facing east.
    // Idle when unclaimed so the human joystick user isn't fighting an
    // AI on their own side of the ball.
    SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = math::Vec3{math::Fixed64::fromInt(-5),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s1.heading  = math::Fixed64::zero();   // facing +x (east, toward the ball)
    s1.role     = Role::Any;
    spawns_.push_back(s1);

    // Slot 2: DEFENDER spawn 5 m east of ball facing west. On tick 0
    // its AiController will start jogging west toward the ball;
    // whoever claimed slot 1 needs to get the ball first, or catch up
    // and shoulder past. Slice 24.3b will add the actual contest bit.
    SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = math::Vec3{math::Fixed64::fromInt(5),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s2.heading  = math::FX_PI;             // facing -x (west, toward the ball)
    s2.role     = Role::LCB;
    spawns_.push_back(s2);
}

std::vector<std::string> BallOnPitchWithDefenderScenario::hints() const
{
    return {
        "Ball on centre spot — walk toward it to dribble.",
        "Slot 1 spawns 5 m west facing east (claim to control it).",
        "Slot 2 spawns 5 m east facing west with a DEFENDER AI — it will jog toward the ball.",
        "Beat the defender to the ball, then hold shift-sprint to outrun it.",
        "If the defender grabs it first, chase it down within ~0.7 m to strip the ball back.",
        "Slice 24.3b demo (DESIGN.md §23.3).",
    };
}

void BallOnPitchWithDefenderScenario::applyPhysicalOverrides(
    SlotId                 slot,
    profile::AttributeSet& attrs) const
{
    // Only touch slot 2 (the defender). Slot 1 (human) keeps default
    // attributes so the "human dribbles at standard rate" and "default
    // defender fails to strip default attacker" invariants hold.
    if (slot == SlotId{2}) {
        // 0.55 as a rational — fromDouble is banned outside
        // M0Attributes.cpp by check_no_hardcoded_attrs.sh.
        attrs.set(m0::kDribbleEfficiency,
                  math::Fixed64::fromFraction(11, 20));
    }
}

// Slice 30.2: plug the M3 `pressing` concept into slot 2's ConceptSet
// so the AiController that Match spawns for Defender-kind slots finds
// the concept its PursueBallCarrierBehavior presence-gates on
// (ConceptSet::has(id, min) returns false when the concept is absent,
// regardless of min — so a bare kPressing plug with any value is what
// opens the gate). Mastery value is math::Fixed64::one() — arbitrary
// positive, unobservable for the single-behavior bag; kept at 1.0 for
// readability and consistency with M0 defaultConcepts()'s run_to_point
// mastery.
//
// Slot 1 gets no plug. Even if a human client releases slot 1 it
// falls back to Idle (per unclaimedControllerFor), no AiController
// runs on it, no concept read happens — the override would be inert
// but confusing. Skipping it also documents "only defender needs
// pressing" for anyone reading this file later.
void BallOnPitchWithDefenderScenario::applyConceptOverrides(
    SlotId                 slot,
    profile::ConceptSet&   concepts) const
{
    if (slot == SlotId{2}) {
        concepts.plug(m0::kPressing, math::Fixed64::one());
    }
}

} // namespace fh::sim::scenario
