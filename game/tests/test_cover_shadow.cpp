// game/tests/test_cover_shadow.cpp — ai/concepts/CoverShadow: who can the ball not be passed
// to, because I am standing in the way?
//
// Team 0 (slots 0-2) defends the goal at x = -52.5 (sg = +1) and does not have the ball;
// team 1 (slots 3-6) has it: slot 3 on the ball at the origin.

#include "test_harness.hpp"
#include "ai/concepts/CoverShadow.hpp"
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
const std::vector<std::uint8_t> kTeams = {0, 0, 0, 1, 1, 1, 1};

// Theirs: 3 on the ball (0,0); 4 square of him 12 m away (0,12); 5 ahead toward our goal
// (-15,-10); 6 behind him toward their own goal, the nearest of all (8,0).
core::World shape(Vec3 presser) {
    core::World w{7, Fixed64::fromInt(7), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34), 0};
    const Vec3 ours[3] = {presser, at(-20, 0), at(-30, 10)};
    const Vec3 theirs[4] = {at(0, 0), at(0, 12), at(-15, -10), at(8, 0)};
    for (int i = 0; i < 3; ++i) { w.setTeam(static_cast<std::uint8_t>(i), 0); w.placePlayer(static_cast<std::uint8_t>(i), ours[i], kEast); }
    for (int i = 0; i < 4; ++i) { w.setTeam(static_cast<std::uint8_t>(3 + i), 1); w.placePlayer(static_cast<std::uint8_t>(3 + i), theirs[i], kEast); }
    core::BallState b;
    b.pos = at(0, 0);
    b.owner = std::uint8_t{3};
    w.placeBall(b);
    return w;
}

}  // namespace

// Standing on the line from the ball to their 4, he hides him — and nobody else.
FH_TEST(a_man_on_the_pass_line_hides_the_receiver) {
    core::World w = shape(at(0, 4));
    co::CoverShadows cs;
    cs.read(0, w, kTeams, Fixed64::one());
    FH_EXPECT_EQ(cs.hiddenBy(0), std::uint32_t{1} << 4);
    FH_EXPECT_EQ(cs.hiddenBy(1), std::uint32_t{0});
}

// A stride and a bit off the line still blocks it; three metres off does not. Beyond the
// receiver, or level with him, he hides nobody.
FH_TEST(only_within_a_body_of_the_line_and_in_front_of_the_receiver) {
    co::CoverShadows cs;
    core::World a = shape(at(1, 4));
    cs.read(0, a, kTeams, Fixed64::one());
    FH_EXPECT(cs.hiddenBy(0) & (std::uint32_t{1} << 4));
    core::World b = shape(at(3, 4));
    cs.read(0, b, kTeams, Fixed64::one());
    FH_EXPECT_EQ(cs.hiddenBy(0), std::uint32_t{0});
    core::World c = shape(at(0, 14));
    cs.read(0, c, kTeams, Fixed64::one());
    FH_EXPECT_EQ(cs.hiddenBy(0), std::uint32_t{0});
}

// Straight at the man on the ball from our goal's side — the naive press — hides nobody here.
FH_TEST(running_straight_at_him_hides_nobody) {
    core::World w = shape(at(-4, 0));
    co::CoverShadows cs;
    cs.read(0, w, kTeams, Fixed64::one());
    FH_EXPECT_EQ(cs.hiddenBy(0), std::uint32_t{0});
}

// The pass to block: his nearest mate who is level or nearer our goal — their 4, 12 m square —
// not their 6, nearer still but back toward their own goal.
FH_TEST(the_pass_to_block_is_the_nearest_receiver_not_behind_him) {
    core::World w = shape(at(-4, 0));
    co::CoverShadows cs;
    cs.read(0, w, kTeams, Fixed64::one());
    FH_EXPECT_EQ(cs.screen(0), 4);
    cs.clear(0, kTeams);
    FH_EXPECT_EQ(cs.screen(0), -1);
    FH_EXPECT_EQ(cs.hiddenBy(0), std::uint32_t{0});
}

// Nobody on the ball: there are still shadows from where the ball is, but no pass to block.
FH_TEST(a_loose_ball_gives_shadows_but_no_pass_to_block) {
    core::World w = shape(at(0, 4));
    core::BallState b;
    b.pos = at(0, 0);
    w.placeBall(b);
    co::CoverShadows cs;
    cs.read(0, w, kTeams, Fixed64::one());
    FH_EXPECT_EQ(cs.screen(0), -1);
    FH_EXPECT(cs.hiddenBy(0) & (std::uint32_t{1} << 4));
}

FH_TEST_MAIN()
