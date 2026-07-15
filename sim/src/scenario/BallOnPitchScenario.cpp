// footballhome sim - BallOnPitchScenario implementation

#include "scenario/BallOnPitchScenario.hpp"

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

// Interactive default: centre-spot ball at rest + one demo slot 5 m west
// facing east, so the tactical-games "🎾 Ball on Pitch" tile delivers
// joystick control (BallControl first-touch fires after a short stroll).
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
        "Ball on centre spot — walk east from the spawn point to dribble.",
        "The ball rolls under passive friction and settles at rest.",
        "Slice 15/16/18.1 demo (DESIGN.md §23.3).",
    };
}

} // namespace fh::sim::scenario
