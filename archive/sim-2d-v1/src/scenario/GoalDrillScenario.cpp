// footballhome sim - GoalDrillScenario implementation (Slice 28.2)

#include "scenario/GoalDrillScenario.hpp"

#include "math/FixedMath.hpp"

namespace fh::sim::scenario {

GoalDrillScenario::GoalDrillScenario() noexcept
{
    // Pitch — regulation 105×68 m, identical to BallOnPitch2v0Scenario.
    // Playable area stays Advisory (M2 does not enforce OOB reset on
    // this scenario; goal-detection is the meaningful stop condition
    // once Slice 28.3 lands).
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    playable_.polygon.clear();
    playable_.constraint_mode = PlayableArea::Mode::Advisory;
    playable_.zoom_hint       = math::Fixed64::zero();

    // Ball at centre spot at rest. Kicker will strike it toward whichever
    // goal they're facing (spawn 1 faces east, spawn 2 faces west).
    ball_.position = math::Vec3{math::Fixed64::zero(),
                                math::Fixed64::zero(),
                                math::Fixed64::zero()};
    ball_.velocity = math::Vec3{};

    // Slot geometry mirrors BallOnPitch2v0Scenario exactly so the same
    // dribble-vs-pass timing intuition (15 m at 15 m/s pass = 1 s per
    // leg) carries over. The functional addition here is the goal at
    // the far end of each shot line — the kick sends the ball ~1.75 s
    // to cross the 22.5 m from centre spot to the goal region.
    SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = math::Vec3{math::Fixed64::fromInt(-15),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s1.heading  = math::Fixed64::zero();   // facing +x (east) — shoots at east goal
    s1.role     = Role::Any;
    spawns_.push_back(s1);

    SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = math::Vec3{math::Fixed64::fromInt(15),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s2.heading  = math::FX_PI;             // facing -x (west) — shoots at west goal
    s2.role     = Role::Any;
    spawns_.push_back(s2);

    // --------------------------------------------------------------
    // Goal regions (Slice 28.2 / ADR §22.25).
    //
    // Pitch half-length = 105 / 2 = 52.5 m — exact in Q32.32 via
    // fromFraction. Goal half-width = 7.32 / 2 = 3.66 m — the closest
    // Q32.32 representation of 366/100 (finite-fraction precision loss
    // is < 1 ULP of a Fixed64 raw, i.e. < 2.33e-10 m).
    //
    // Goal depth: 2 m behind the goal line.
    // Goal height: 2.44 m (FIFA regulation; unused by M2 physics).
    //
    // West goal (index 0):  x ∈ [-54.5, -52.5]
    // East goal (index 1):  x ∈ [+52.5, +54.5]
    // Both:                  y ∈ [-3.66, +3.66],  z ∈ [0, 2.44]
    // --------------------------------------------------------------
    const auto half_length     = math::Fixed64::fromFraction(105, 2);   // 52.5
    const auto goal_depth      = math::Fixed64::fromInt(2);
    const auto goal_half_width = math::Fixed64::fromFraction(732, 200); // 3.66
    const auto goal_height     = math::Fixed64::fromFraction(244, 100); // 2.44
    const auto z_floor         = math::Fixed64::zero();
    const auto neg_half_width  = math::Fixed64::zero() - goal_half_width;
    const auto neg_half_length = math::Fixed64::zero() - half_length;

    GoalRegion west;
    west.index = 0;
    west.min   = math::Vec3{neg_half_length - goal_depth,
                            neg_half_width,
                            z_floor};
    west.max   = math::Vec3{neg_half_length,
                            goal_half_width,
                            goal_height};
    goal_regions_.push_back(west);

    GoalRegion east;
    east.index = 1;
    east.min   = math::Vec3{half_length,
                            neg_half_width,
                            z_floor};
    east.max   = math::Vec3{half_length + goal_depth,
                            goal_half_width,
                            goal_height};
    goal_regions_.push_back(east);
}

std::vector<std::string> GoalDrillScenario::hints() const
{
    return {
        "Ball on centre spot — walk toward it to collect.",
        "Slot 1 spawns 15 m west facing east; Slot 2 spawns 15 m east facing west.",
        "Kick the ball into the far goal — regions are 7.32 m wide × 2 m deep.",
        "Solo play: your dot walks; the other flank idles as a stationary target.",
        "Slice 28.2 demo (DESIGN.md §23.3, ADR §22.25).",
    };
}

} // namespace fh::sim::scenario
