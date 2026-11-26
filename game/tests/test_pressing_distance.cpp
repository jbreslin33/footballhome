// game/tests/test_pressing_distance.cpp — ai/concepts/PressingDistance: can he get to his man
// while a pass to him travels?
//
// Team 0 (slots 0-3) defends the goal at x = -52.5 and does not have the ball; team 1
// (slots 4-7) has it. No keepers. Ours: a sweeper deep, three across. Theirs: three high,
// one deep (left free). The pairs are DirectOpponents' own: 1-4, 2-5, 3-6.

#include "test_harness.hpp"
#include "ai/concepts/DirectOpponent.hpp"
#include "ai/concepts/PressingDistance.hpp"
#include "core/World.hpp"

#include <vector>

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;
namespace co = fh::game::ai::concepts;

namespace {

Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const Vec2 kEast{Fixed64::one(), Fixed64::zero()};
const std::vector<std::uint8_t> kTeams = {0, 0, 0, 0, 1, 1, 1, 1};
const Fixed64 kGoal = Fixed64::fromFraction(-105, 2);

core::World shape(Vec3 ball, int owner = -1) {
    core::World w{8, Fixed64::fromInt(7), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34), 0};
    const Vec3 ours[4] = {at(-40, 0), at(-25, -15), at(-25, 0), at(-25, 15)};
    const Vec3 theirs[4] = {at(-18, -15), at(-21, 1), at(-20, 16), at(30, 0)};
    for (int i = 0; i < 4; ++i) { w.setTeam(static_cast<std::uint8_t>(i), 0); w.placePlayer(static_cast<std::uint8_t>(i), ours[i], kEast); }
    for (int i = 0; i < 4; ++i) { w.setTeam(static_cast<std::uint8_t>(4 + i), 1); w.placePlayer(static_cast<std::uint8_t>(4 + i), theirs[i], kEast); }
    core::BallState b;
    b.pos = ball;
    if (owner >= 0) b.owner = static_cast<std::uint8_t>(owner);
    w.placeBall(b);
    return w;
}
std::vector<Vec2> places(const core::World& w) {
    std::vector<Vec2> p(8);
    for (std::uint8_t i = 0; i < 4; ++i) p[i] = Vec2{w.player(i).pos.x, w.player(i).pos.y};
    return p;
}
// Numbers so the matchups are the 4-v-4 these tests mean: our 1-3 on their 4-6 by touchline.
const std::vector<std::int16_t> kNum = {5, 2, 6, 3, 11, 10, 7, 4};
std::vector<Fixed64> sides() {
    return {Fixed64::zero(), Fixed64::fromFraction(-8, 10), Fixed64::zero(), Fixed64::fromFraction(8, 10),
            Fixed64::fromFraction(-8, 10), Fixed64::zero(), Fixed64::fromFraction(8, 10), Fixed64::zero()};
}
void pair(co::DirectOpponents& d, const core::World& w) {
    core::ModelParams mp;
    mp.setMilli("concept.direct.pair_2_11", 1000); mp.setMilli("concept.direct.pair_3_7", 1000); mp.setMilli("concept.direct.pair_6_10", 1000);
    d.configure(mp);
    d.assign(0, w, kTeams, places(w), kGoal, kNum, sides());
}
struct Read { co::DirectOpponents d; co::PressingDistance pd; };
Read readOf(const core::World& w) {
    Read r;
    pair(r.d, w);
    r.pd.read(0, w, kTeams, r.d, places(w));
    return r;
}

}  // namespace

// The further the ball has to travel to his man, the further off him he may stand: the same
// 7 m gap is in pressing distance with the ball 40 m away and out of it with the ball 8 m away.
FH_TEST(the_same_gap_is_in_with_the_ball_far_and_out_with_it_near) {
    const Read far = readOf(shape(at(22, -15)));        // 40 m from their 4
    const Read near = readOf(shape(at(-10, -15)));      // 8 m from their 4
    FH_EXPECT_EQ(far.pd.of(1).man, 4);
    FH_EXPECT_EQ(near.pd.of(1).man, 4);
    FH_EXPECT(far.pd.of(1).gap_m == Fixed64::fromInt(7));
    FH_EXPECT(far.pd.of(1).reach_m > near.pd.of(1).reach_m);
    FH_EXPECT(far.pd.of(1).ball_s > near.pd.of(1).ball_s);
    FH_EXPECT(far.pd.of(1).in);
    FH_EXPECT(!near.pd.of(1).in);
}

// In distance: he has nothing to do. Out of it: the step is toward his man and exactly long
// enough to leave the gap equal to his reach.
FH_TEST(out_of_distance_the_step_closes_exactly_what_is_missing) {
    const Read far = readOf(shape(at(22, -15)));
    FH_EXPECT(far.pd.of(1).step.x.raw == 0 && far.pd.of(1).step.y.raw == 0);
    const Read near = readOf(shape(at(-10, -15)));
    const auto& r = near.pd.of(1);
    FH_EXPECT(r.step.x > Fixed64::zero());              // his man is straight up the pitch from him
    FH_EXPECT(r.step.y.raw == 0);
    const Fixed64 left = r.gap_m - r.step.x - r.reach_m;   // the gap after the step, less his reach
    FH_EXPECT(math::fx_abs(left) < Fixed64::fromFraction(1, 100));
}

// The step never takes him more than max_step_m off his place.
FH_TEST(the_step_is_capped) {
    core::World w = shape(at(-10, -15));
    w.placePlayer(4, at(-5, -15), kEast);               // his man 20 m off him, the ball 5 m from the man
    co::DirectOpponents d;
    pair(d, w);
    co::PressingDistance pd;
    pd.read(0, w, kTeams, d, places(w));
    if (pd.of(1).man == 4) FH_EXPECT(pd.of(1).step.x == pd.params().max_step_m);
    for (std::uint8_t s = 0; s < 4; ++s) FH_EXPECT(math::length(pd.of(s).step) <= pd.params().max_step_m + Fixed64::fromFraction(1, 100));
}

// His man has the ball: that is closing down, not pressing distance — no reach, no step.
FH_TEST(the_man_on_the_ball_is_not_pressing_distance) {
    const Read r = readOf(shape(at(-18, -15), 4));
    FH_EXPECT_EQ(r.pd.of(1).man, 4);
    FH_EXPECT(r.pd.of(1).man_on_ball);
    FH_EXPECT(!r.pd.of(1).in);
    FH_EXPECT(r.pd.of(1).step.x.raw == 0 && r.pd.of(1).step.y.raw == 0);
}

// The spare man has nobody; and a man counts the others he could get to as well.
FH_TEST(the_spare_man_has_no_man_and_help_is_counted) {
    const Read r = readOf(shape(at(22, -15)));
    FH_EXPECT_EQ(r.pd.of(0).man, -1);
    FH_EXPECT(!r.pd.of(0).in);
    // Our 2 (middle) with the ball far away: his own man and both wide men are within a long pass's reach.
    FH_EXPECT(r.pd.of(2).in);
    FH_EXPECT(r.pd.of(2).help >= 1);
    // The side with the ball has no read at all.
    co::PressingDistance pd = r.pd;
    pd.clear(0, kTeams);
    for (std::uint8_t s = 0; s < 4; ++s) FH_EXPECT_EQ(pd.of(s).man, -1);
}

// Goal side (owner 11/25: "being able to press but the player can dribble to our goal lol is bad as we are
// 'chasing'"). His man has got goal side of his place: the step does not go toward the man (it would leave him
// level or behind) but to the spot on the man's line to our goal, a reach off him.
FH_TEST(a_man_behind_his_place_gets_a_step_to_the_goal_side_spot) {
    for (int mx : {-28, -26}) {                          // their 4 is 3 m / 1 m nearer our goal than our 1's place
        core::World w = shape(at(-20, -15));
        w.placePlayer(4, at(mx, -15), kEast);
        co::DirectOpponents d;
        pair(d, w);
        co::PressingDistance pd;
        pd.read(0, w, kTeams, d, places(w));
        const auto& r = pd.of(1);
        FH_EXPECT_EQ(r.man, 4);
        FH_EXPECT(!r.goal_side);
        FH_EXPECT(r.step.x < Fixed64::zero());          // back toward our goal, not up at his man
        const Fixed64 len = math::length(r.step);
        FH_EXPECT(len <= pd.params().max_step_m + Fixed64::fromFraction(1, 100));
        const Vec2 end{Fixed64::fromInt(-25) + r.step.x, Fixed64::fromInt(-15) + r.step.y};
        const Vec2 goal{kGoal, Fixed64::zero()};
        const Vec2 him{Fixed64::fromInt(mx), Fixed64::fromInt(-15)};
        FH_EXPECT(math::length(goal - end) < math::length(goal - him));      // goal side after the step
        if (mx == -26) {                                 // not capped: exactly a reach off him
            FH_EXPECT(len < pd.params().max_step_m - Fixed64::fromFraction(1, 100));
            FH_EXPECT(math::fx_abs(math::length(end - him) - r.reach_m) < Fixed64::fromFraction(1, 100));
        }
    }
}

// Already in reach and goal side: still nothing to do.
FH_TEST(in_reach_and_goal_side_no_step) {
    const Read far = readOf(shape(at(22, -15)));
    FH_EXPECT(far.pd.of(1).in);
    FH_EXPECT(far.pd.of(1).goal_side);
    FH_EXPECT(far.pd.of(1).step.x.raw == 0 && far.pd.of(1).step.y.raw == 0);
}

FH_TEST_MAIN()
