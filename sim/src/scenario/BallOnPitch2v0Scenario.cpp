// footballhome sim - BallOnPitch2v0Scenario implementation (Slice 26.3)

#include "scenario/BallOnPitch2v0Scenario.hpp"

#include "math/FixedMath.hpp"

namespace fh::sim::scenario {

BallOnPitch2v0Scenario::BallOnPitch2v0Scenario() noexcept
{
    // Pitch + playable area — identical to BallOnPitchScenario's
    // Advisory configuration. Ball wall-bounce / OOB handling stays a
    // Slice 17+ concern; the 2v0 pass drill lives well inside the
    // 105×68 m rectangle so Advisory is sufficient.
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    playable_.polygon.clear();
    playable_.constraint_mode = PlayableArea::Mode::Advisory;
    playable_.zoom_hint       = math::Fixed64::zero();

    // Ball at centre spot, at rest. Slot 1 collects on approach via
    // BallControl's Rule 1 first-touch, then kicks it toward Slot 2.
    ball_.position = math::Vec3{math::Fixed64::zero(),
                                math::Fixed64::zero(),
                                math::Fixed64::zero()};
    ball_.velocity = math::Vec3{};

    // 30 m between the two slots. Chosen so the round-trip pass
    // (15 m out from centre to receiver + 15 m back) can complete
    // in under the kKickAliveTicks (40 tick = 2 s) friction-skip
    // window at pass_power = 15 m/s (15 m / 15 m/s = 1 s per leg).
    // Dribbling the same 15 m at max_dribble_speed × dribble_efficiency
    // (4.0 × 0.8 = 3.2 m/s) would take ~4.7 s — a strong nudge to
    // learn the kick trailer instead.
    SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = math::Vec3{math::Fixed64::fromInt(-15),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s1.heading  = math::Fixed64::zero();   // facing +x (east, toward the ball)
    s1.role     = Role::Any;
    spawns_.push_back(s1);

    SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = math::Vec3{math::Fixed64::fromInt(15),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s2.heading  = math::FX_PI;             // facing -x (west, toward the ball)
    s2.role     = Role::Any;
    spawns_.push_back(s2);
}

std::vector<std::string> BallOnPitch2v0Scenario::hints() const
{
    return {
        "Ball on centre spot — walk toward it to collect.",
        "Slot 1 spawns 15 m west facing east; Slot 2 spawns 15 m east facing west.",
        "Pass to teammate — kick pad or Space key fires the short-pass primitive.",
        "Solo play: your dot walks; the other flank idles as a stationary receiver.",
        "Slice 26.3 demo (DESIGN.md §23.3, ADR §22.23).",
    };
}

} // namespace fh::sim::scenario
