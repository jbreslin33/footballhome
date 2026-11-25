// game/tests/test_double_team.cpp — ai/concepts/DoubleTeam: trap him on the touchline.
//
// Team 0 (slots 0-2) defends the goal at x = -52.5 and does not have the ball; team 1 (slots 3-4)
// has it: slot 3 on the ball. The pitch is 105 x 68: a touchline at y = +34.

#include "test_harness.hpp"
#include "ai/concepts/DoubleTeam.hpp"
#include "core/World.hpp"

#include <vector>

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec3;
namespace co = fh::game::ai::concepts;

namespace {

Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const math::Vec2 kEast{Fixed64::one(), Fixed64::zero()};
const std::vector<std::uint8_t> kTeams = {0, 0, 0, 1, 1};

// Theirs: 3 on the ball at carrier; 4 far away. Ours: 0 the presser, 1 a second man, 2 far back.
core::World shape(Vec3 carrier, Vec3 presser, Vec3 second) {
    core::World w{5, Fixed64::fromInt(7), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34), 0};
    const Vec3 ours[3] = {presser, second, at(-45, 0)};
    const Vec3 theirs[2] = {carrier, at(30, -20)};
    for (int i = 0; i < 3; ++i) { w.setTeam(static_cast<std::uint8_t>(i), 0); w.placePlayer(static_cast<std::uint8_t>(i), ours[i], kEast); }
    for (int i = 0; i < 2; ++i) { w.setTeam(static_cast<std::uint8_t>(3 + i), 1); w.placePlayer(static_cast<std::uint8_t>(3 + i), theirs[i], kEast); }
    core::BallState b;
    b.pos = carrier;
    b.owner = std::uint8_t{3};
    w.placeBall(b);
    return w;
}

co::DoubleTeam on(int share_permille) {
    co::DoubleTeam dt;
    co::DoubleTeamParams p;
    p.share = Fixed64::fromFraction(share_permille, 1000);
    dt.configure(p);
    return dt;
}

}  // namespace

// By the touchline with our presser on him, the nearest other man is the second, and his spot is
// inside the carrier — toward the middle, level with him.
FH_TEST(by_the_touchline_the_second_man_closes_the_inside) {
    core::World w = shape(at(0, 30), at(-3, 30), at(-4, 22));
    co::DoubleTeam dt = on(1000);
    dt.read(0, w, kTeams, 0, 7);
    const auto& r = dt.of(0);
    FH_EXPECT_EQ(r.carrier, 3);
    FH_EXPECT_EQ(r.second, 1);
    FH_EXPECT(r.chosen);
    FH_EXPECT_EQ(r.spot.x.raw, Fixed64::zero().raw);
    FH_EXPECT_EQ(r.spot.y.raw, (Fixed64::fromInt(30) - Fixed64::fromFraction(3, 2)).raw);
    FH_EXPECT(dt.isSecond(0, 1));
    FH_EXPECT(!dt.isSecond(0, 0));
}

// The other touchline: inside is upward.
FH_TEST(the_inside_is_toward_the_middle_on_either_line) {
    core::World w = shape(at(10, -31), at(7, -31), at(5, -24));
    co::DoubleTeam dt = on(1000);
    dt.read(0, w, kTeams, 0, 7);
    FH_EXPECT_EQ(dt.of(0).second, 1);
    FH_EXPECT_EQ(dt.of(0).spot.y.raw, (Fixed64::fromInt(-31) + Fixed64::fromFraction(3, 2)).raw);
}

// In the middle of the pitch the line cannot help: no trap.
FH_TEST(no_trap_in_the_middle) {
    core::World w = shape(at(0, 5), at(-3, 5), at(-4, 0));
    co::DoubleTeam dt = on(1000);
    dt.read(0, w, kTeams, 0, 7);
    FH_EXPECT_EQ(dt.of(0).second, -1);
    FH_EXPECT(!dt.isSecond(0, 1));
}

// The presser is not on him yet (8 m off), or no second man is near enough (20 m): no trap.
FH_TEST(no_trap_without_an_engaged_presser_or_a_second_man) {
    co::DoubleTeam dt = on(1000);
    core::World a = shape(at(0, 30), at(-8, 30), at(-4, 22));
    dt.read(0, a, kTeams, 0, 7);
    FH_EXPECT_EQ(dt.of(0).second, -1);
    core::World b = shape(at(0, 30), at(-3, 30), at(-20, 20));
    dt.read(0, b, kTeams, 0, 7);
    FH_EXPECT_EQ(dt.of(0).carrier, 3);
    FH_EXPECT_EQ(dt.of(0).second, -1);
}

// The side WITH the ball never traps.
FH_TEST(the_side_on_the_ball_reads_nothing) {
    core::World w = shape(at(0, 30), at(-3, 30), at(-4, 22));
    co::DoubleTeam dt = on(1000);
    dt.read(1, w, kTeams, 4, 7);
    FH_EXPECT_EQ(dt.of(1).carrier, -1);
}

// The dial: no row = 0 = the read runs, nobody is chosen; a share between rolls per spell and is
// the same for the same world and seed.
FH_TEST(the_dial_chooses_and_is_deterministic) {
    core::World w = shape(at(0, 30), at(-3, 30), at(-4, 22));
    co::DoubleTeam off = on(0);
    off.read(0, w, kTeams, 0, 7);
    FH_EXPECT_EQ(off.of(0).second, 1);
    FH_EXPECT(!off.of(0).chosen);
    FH_EXPECT(!off.isSecond(0, 1));
    int chosen = 0;
    for (std::uint64_t seed = 1; seed <= 200; ++seed) {
        co::DoubleTeam half = on(500), again = on(500);
        half.read(0, w, kTeams, 0, seed);
        again.read(0, w, kTeams, 0, seed);
        FH_EXPECT_EQ(half.of(0).chosen, again.of(0).chosen);
        chosen += half.of(0).chosen;
    }
    FH_EXPECT(chosen > 60 && chosen < 140);
}

FH_TEST_MAIN()
