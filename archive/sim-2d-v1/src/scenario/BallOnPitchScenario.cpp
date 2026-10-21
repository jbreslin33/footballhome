// footballhome sim - BallOnPitchScenario implementation

#include "scenario/BallOnPitchScenario.hpp"

#include "math/FixedMath.hpp"

namespace fh::sim::scenario {

namespace {

void configurePitchAndPlayable(PitchSpec& pitch, PlayableArea& playable)
{
    pitch.length_m = math::Fixed64::fromInt(105);
    pitch.width_m  = math::Fixed64::fromInt(68);

    // Advisory playable-area constraint (same shape as EmptyPitchScenario).
    // Ball wall-bounce / out-of-bounds handling is a Slice 17+ concern.
    playable.polygon.clear();
    playable.constraint_mode = PlayableArea::Mode::Advisory;
    playable.zoom_hint       = math::Fixed64::zero();
}

} // namespace

// Interactive default: centre-spot ball at rest + two demo slots
// flanking the ball 5 m west and 5 m east. The tactical-games
// "🎾 Ball on Pitch" tile delivers joystick control to whichever
// slot(s) get claimed; unclaimed slot(s) render as AI dots under
// WanderController. Two clients ⇒ symmetric 5 m race with Slice
// 16.6's SlotId tie-break as the fallback for equidistant first-touch.
BallOnPitchScenario::BallOnPitchScenario() noexcept
{
    configurePitchAndPlayable(pitch_, playable_);

    ball_.position = math::Vec3{math::Fixed64::zero(),
                                math::Fixed64::zero(),
                                math::Fixed64::zero()};
    ball_.velocity = math::Vec3{};   // at rest

    SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = math::Vec3{math::Fixed64::fromInt(-5),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s1.heading  = math::Fixed64::zero();   // facing +x (east, toward the ball)
    s1.role     = Role::Any;
    spawns_.push_back(s1);

    SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = math::Vec3{math::Fixed64::fromInt(5),
                             math::Fixed64::zero(),
                             math::Fixed64::zero()};
    s2.heading  = math::FX_PI;             // facing -x (west, toward the ball)
    s2.role     = Role::Any;
    spawns_.push_back(s2);
}

// Scripted variant: caller-supplied ball state, ZERO slots. This is the
// path the Slice 15.6 cross-arch determinism test uses — adding any
// slot here would consume the RNG stream via WanderController and shift
// the golden `ball_roll_east_400_ticks_seed_42` hash.
BallOnPitchScenario::BallOnPitchScenario(BallSpawn scripted_ball) noexcept
{
    configurePitchAndPlayable(pitch_, playable_);
    ball_ = scripted_ball;
    // spawns_ intentionally empty.
}

std::vector<std::string> BallOnPitchScenario::hints() const
{
    return {
        "Ball on centre spot — walk toward it to dribble.",
        "Slot 1 spawns 5 m west facing east; Slot 2 spawns 5 m east facing west.",
        "Solo play: your dot walks; the other flank wanders as an AI.",
        "Two clients: symmetric first-touch race with lower-SlotId tie-break.",
        "Slice 15/16/18.1 demo (DESIGN.md §23.3).",
    };
}

} // namespace fh::sim::scenario
