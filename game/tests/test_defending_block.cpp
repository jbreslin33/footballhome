// game/tests/test_defending_block.cpp — G5.21 (DESIGN §8.119): the block spot
// is the real table (DFL, by role and ball band); one presser, the nearest
// outfielder, held until another is switch_m nearer.
#include "test_harness.hpp"
#include "ai/DefendingBlock.hpp"
#include "ai/Brain.hpp"
#include "core/World.hpp"

using namespace fh::game;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {
const Fixed64 kHX = Fixed64::fromFraction(105, 2);
const Fixed64 kHY = Fixed64::fromInt(34);
core::World world22() {
    core::World w{22, Fixed64::fromInt(6), kHX, kHY};
    for (std::uint8_t i = 0; i < 22; ++i) {
        const bool home = i < 11;
        w.placePlayer(i, Vec3{Fixed64::fromInt(home ? -30 : 30), Fixed64::fromInt((i % 11) * 5 - 25), Fixed64::zero()},
                      Vec2{home ? Fixed64::one() : -Fixed64::one(), Fixed64::zero()});
        w.setTeam(i, home ? 0 : 1);
    }
    return w;
}
bool near(Fixed64 a, Fixed64 b, int tenths) { return math::fx_abs(a - b) <= Fixed64::fromFraction(tenths, 10); }
}  // namespace

FH_TEST(block_spot_is_the_real_table) {
    core::World w = world22();
    // Their 9 on the ball 45 m off our (home) line: x = -52.5 + 45 = -7.5.
    w.placePlayer(16, Vec3{Fixed64::fromFraction(-15, 2), Fixed64::zero(), Fixed64::zero()}, Vec2{-Fixed64::one(), Fixed64::zero()});
    w.giveBall(16);
    ai::DefendingBlock b;
    b.configure(core::ModelParams{});
    ai::PlayerView v;
    v.slot = 3; v.team = 0; v.sg = Fixed64::one(); v.role = ai::Role::CB; v.across = Fixed64::fromInt(6);
    const Fixed64 off = kHX + w.ball().pos.x;               // ball metres off our line (≈45)
    const Vec2 s = b.spot(v, w);
    // CB real: 25.4 m at band 35, 30.9 at band 45 (DFL) — interpolated.
    const Fixed64 u = (off - Fixed64::fromInt(35)) / Fixed64::fromInt(10);
    const Fixed64 want = Fixed64::fromFraction(254, 10) + (Fixed64::fromFraction(309, 10) - Fixed64::fromFraction(254, 10)) * u - kHX;
    FH_EXPECT(near(s.x, want, 1));
    FH_EXPECT_EQ(s.y.raw, Fixed64::fromInt(6).raw);
    // Away side defends the +x end: the ball is 60 m off its line, its 9
    // stands 64.1 m off it (DFL ST 61.6 at band 55, 66.6 at 65) = x -11.6.
    v.team = 1; v.sg = -Fixed64::one(); v.role = ai::Role::ST;
    const Vec2 s2 = b.spot(v, w);
    FH_EXPECT(near(s2.x, Fixed64::fromFraction(-116, 10), 3));
}

FH_TEST(one_presser_nearest_and_sticky) {
    core::World w = world22();
    const auto team_of = ai::TeamSetup::splitHalves(22).team_of_slot;
    w.placePlayer(16, Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}, Vec2{-Fixed64::one(), Fixed64::zero()});
    w.giveBall(16);
    w.placePlayer(5, Vec3{Fixed64::fromInt(-5), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    w.placePlayer(6, Vec3{Fixed64::fromInt(-8), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    ai::DefendingBlock b;
    b.configure(core::ModelParams{});
    b.assign(0, w, team_of, -1, -1);
    FH_EXPECT_EQ(w.restartTeam(), 0xFF);   // giveBall puts the ball in play
    FH_EXPECT_EQ(b.presser(0), 5);
    {
        // 6 now 1 m nearer than 5: under switch_m (2 m), 5 keeps it.
        w.placePlayer(6, Vec3{Fixed64::fromInt(-4), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
        b.assign(0, w, team_of, -1, -1);
        FH_EXPECT_EQ(b.presser(0), 5);
        // 6 now 3 m nearer: he takes it.
        w.placePlayer(6, Vec3{Fixed64::fromInt(-2), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
        b.assign(0, w, team_of, -1, -1);
        FH_EXPECT_EQ(b.presser(0), 6);
        FH_EXPECT_EQ(b.presser(1), -1);   // their own ball: they don't press it
    }
}

FH_TEST_MAIN()
