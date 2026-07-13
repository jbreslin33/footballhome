// footballhome sim - BallOnPitchScenario implementation

#include "scenario/BallOnPitchScenario.hpp"

namespace fh::sim::scenario {

BallOnPitchScenario::BallOnPitchScenario(std::optional<BallSpawn> ball) noexcept
{
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    // Advisory playable-area constraint (same shape as EmptyPitchScenario).
    // Ball wall-bounce / out-of-bounds handling is a Slice 17 concern.
    playable_.polygon.clear();
    playable_.constraint_mode = PlayableArea::Mode::Advisory;
    playable_.zoom_hint       = math::Fixed64::zero();

    // Default ball: centre spot, stationary. The optional-ctor path lets
    // the Slice 15.6 determinism test inject a scripted initial velocity.
    if (ball.has_value()) {
        ball_ = *ball;
    } else {
        ball_.position = math::Vec3{math::Fixed64::zero(),
                                    math::Fixed64::zero(),
                                    math::Fixed64::zero()};
        ball_.velocity = math::Vec3{};   // at rest
    }
}

std::vector<std::string> BallOnPitchScenario::hints() const
{
    return {
        "Ball on centre spot — no players, no goals.",
        "The ball rolls under passive friction and settles at rest.",
        "Slice 15 demo (DESIGN.md §23.3).",
    };
}

} // namespace fh::sim::scenario
