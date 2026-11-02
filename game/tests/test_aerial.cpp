// game/tests/test_aerial.cpp — G5.3: the ball in the air is contested. Until
// now a delivery fell to the nearest man's chest, and nobody could touch it
// above 1.5 m: a corner was a free control eight metres out.

#include "test_harness.hpp"
#include "core/ModelParams.hpp"
#include "core/World.hpp"

using namespace fh::game;
using core::Action;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;

namespace {
Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const Vec2 kEast{Fixed64::one(), Fixed64::zero()};

core::ModelParams on() {
    core::ModelParams p;
    p.setMilli("physics.aerial.radius_m", 1000);
    return p;
}

core::Body bodyOf(int reach_cm, int aerial) {
    core::Body b;
    return core::Body(b.tau(), b.brake(), b.turn(), b.dribble(), b.diveSpeed(), b.side(), b.back(), b.yaw(),
                      Fixed64::fromFraction(1, 2), b.brakeTau(), b.reaction(),
                      Fixed64::fromFraction(reach_cm, 100), Fixed64::fromInt(aerial));
}

// Slot 0 home kicks from `from`; 1 home and 2 away stand under the ball at
// the spot; slot 3 is the away keeper's stand-in, far off.
core::World air(int seed, const Vec3& spot, const core::Body& attacker, const core::Body& defender, bool enabled) {
    core::World w{4, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
    w.setMatchSeed(static_cast<std::uint64_t>(seed));
    w.setTeam(0, 0); w.placePlayer(0, at(0, 30), kEast);
    w.setTeam(1, 0); w.placePlayer(1, spot, kEast);
    w.setTeam(2, 1); w.placePlayer(2, Vec3{spot.x + Fixed64::fromFraction(1, 2), spot.y, Fixed64::zero()}, kEast);
    w.setTeam(3, 1); w.placePlayer(3, at(-50, -30), kEast);
    w.setBody(1, attacker);
    w.setBody(2, defender);
    if (enabled) w.configureAerial(on());
    w.giveBall(3);   // open play: a fresh World sits on its kick-off
    return w;
}

// Drops a ball on him at head height, moving, and returns after the first tick.
void drop(core::World& w, const Vec3& spot) {
    core::BallState b;
    b.pos = Vec3{spot.x, spot.y, Fixed64::fromInt(2)};
    b.vel = Vec3{Fixed64::fromInt(10), Fixed64::zero(), -Fixed64::fromInt(2)};
    w.placeBall(b);
    w.tick();
}
}  // namespace

FH_TEST(off_without_a_db_row_so_no_duels_are_fought) {
    auto w = air(1, at(40, 0), core::Body{}, core::Body{}, false);
    drop(w, at(40, 0));
    FH_EXPECT_EQ(w.aerialDuels(), 0);
}

FH_TEST(two_men_under_it_fight_a_duel_and_a_header_at_goal_goes_at_goal) {
    int at_goal = 0, away = 0;
    for (int seed = 1; seed <= 40; ++seed) {
        auto w = air(seed, at(42, 2), core::Body{}, core::Body{}, true);
        drop(w, at(42, 2));
        FH_EXPECT_EQ(w.aerialDuels(), 1);
        at_goal += w.headersAtGoal(0);
        away += w.headersClear(1);
        if (w.headersAtGoal(0)) FH_EXPECT(w.ball().vel.x > Fixed64::zero());
        if (w.headersClear(1)) FH_EXPECT(w.ball().vel.x < Fixed64::zero());
    }
    FH_EXPECT(at_goal > 10);   // equals: about half each way
    FH_EXPECT(away > 10);
}

FH_TEST(the_stronger_jumper_wins_more_of_them) {
    int strong = 0;
    for (int seed = 1; seed <= 60; ++seed) {
        auto w = air(seed, at(42, 2), bodyOf(260, 90), bodyOf(260, 30), true);
        drop(w, at(42, 2));
        strong += w.headersAtGoal(0);
    }
    FH_EXPECT(strong > 45);
}

FH_TEST(a_ball_over_his_reach_is_not_his) {
    auto w = air(3, at(42, 2), bodyOf(170, 50), bodyOf(170, 50), true);
    drop(w, at(42, 2));
    FH_EXPECT_EQ(w.aerialDuels(), 0);
    FH_EXPECT_EQ(w.aerialLone(), 0);
}

FH_TEST(alone_at_their_goal_he_heads_it_alone_in_midfield_he_lets_it_drop) {
    auto w = air(4, at(42, 2), core::Body{}, core::Body{}, true);
    w.placePlayer(2, at(-20, 20), kEast);
    drop(w, at(42, 2));
    FH_EXPECT_EQ(w.aerialLone(), 1);
    auto m = air(5, at(5, 2), core::Body{}, core::Body{}, true);
    m.placePlayer(2, at(-20, 20), kEast);
    drop(m, at(5, 2));
    FH_EXPECT_EQ(m.aerialLone(), 0);
}

FH_TEST(on_the_touchline_a_header_isnt_at_goal) {
    auto w = air(6, at(45, 30), core::Body{}, core::Body{}, true);
    w.placePlayer(2, at(-20, 20), kEast);
    drop(w, at(45, 30));
    FH_EXPECT_EQ(w.headersAtGoal(0), 0);
}

FH_TEST(a_rising_ball_goes_past_him) {
    auto w = air(7, at(42, 2), core::Body{}, core::Body{}, true);
    core::BallState b;
    b.pos = Vec3{Fixed64::fromInt(42), Fixed64::fromInt(2), Fixed64::fromInt(2)};
    b.vel = Vec3{Fixed64::fromInt(10), Fixed64::zero(), Fixed64::fromInt(4)};
    w.placeBall(b);
    w.tick();
    FH_EXPECT_EQ(w.aerialDuels(), 0);
    FH_EXPECT_EQ(w.aerialLone(), 0);
}

FH_TEST_MAIN()
