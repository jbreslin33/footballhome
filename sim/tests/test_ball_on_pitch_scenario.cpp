// footballhome sim - BallOnPitchScenario tests (Slice 15.3)

#include "scenario/BallOnPitchScenario.hpp"
#include "awareness/AwarenessView.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <optional>
#include <string>

using fh::sim::awareness::WorldView;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::scenario::BallOnPitchScenario;
using fh::sim::scenario::BallSpawn;

FH_TEST(id_and_display_name) {
    BallOnPitchScenario s;
    FH_EXPECT_EQ(std::string(s.id()),          std::string("ball_on_pitch"));
    FH_EXPECT_EQ(std::string(s.displayName()), std::string("Ball on Pitch"));
}

FH_TEST(pitch_is_regulation) {
    BallOnPitchScenario s;
    const auto p = s.pitch();
    FH_EXPECT_EQ(p.length_m, Fixed64::fromInt(105));
    FH_EXPECT_EQ(p.width_m,  Fixed64::fromInt(68));
}

FH_TEST(no_player_slots) {
    BallOnPitchScenario s;
    FH_EXPECT_EQ(s.initialSpawns().size(), 0u);
}

// Default ctor: ball at centre spot, stationary.
FH_TEST(default_ball_at_centre_stationary) {
    BallOnPitchScenario s;
    const auto bs = s.ballSpawn();
    FH_EXPECT(bs.has_value());
    FH_EXPECT_EQ(bs->position.x, Fixed64::zero());
    FH_EXPECT_EQ(bs->position.y, Fixed64::zero());
    FH_EXPECT_EQ(bs->position.z, Fixed64::zero());
    FH_EXPECT_EQ(bs->velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(bs->velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(bs->velocity.z, Fixed64::zero());
}

// Ctor override: injected BallSpawn round-trips verbatim through ballSpawn().
// This is the API Slice 15.6's cross-arch determinism test will use to
// script an initial velocity for the trajectory-lock test.
FH_TEST(override_ball_spawn_round_trips) {
    BallSpawn injected;
    injected.position = Vec3{Fixed64::fromInt(-10),
                             Fixed64::fromInt(5),
                             Fixed64::zero()};
    injected.velocity = Vec3{Fixed64::fromInt(3),
                             Fixed64::fromInt(-2),
                             Fixed64::zero()};

    BallOnPitchScenario s(injected);
    const auto bs = s.ballSpawn();
    FH_EXPECT(bs.has_value());
    FH_EXPECT_EQ(bs->position.x, Fixed64::fromInt(-10));
    FH_EXPECT_EQ(bs->position.y, Fixed64::fromInt(5));
    FH_EXPECT_EQ(bs->velocity.x, Fixed64::fromInt(3));
    FH_EXPECT_EQ(bs->velocity.y, Fixed64::fromInt(-2));
}

FH_TEST(success_and_reset_always_false) {
    BallOnPitchScenario s;
    WorldView w;
    FH_EXPECT(!s.checkSuccess(w));
    FH_EXPECT(!s.checkReset(w));
}

// Default ball position must be inside the pitch — sanity guard against
// a future accidental offset that puts the ball out of the playable area.
FH_TEST(default_ball_inside_pitch) {
    BallOnPitchScenario s;
    const auto p   = s.pitch();
    const auto bs  = s.ballSpawn();
    FH_EXPECT(bs.has_value());
    const Fixed64 halfL = p.length_m * Fixed64::fromFraction(1, 2);
    const Fixed64 halfW = p.width_m  * Fixed64::fromFraction(1, 2);
    FH_EXPECT_GE(bs->position.x, -halfL);
    FH_EXPECT_LE(bs->position.x,  halfL);
    FH_EXPECT_GE(bs->position.y, -halfW);
    FH_EXPECT_LE(bs->position.y,  halfW);
}

FH_TEST_MAIN()
