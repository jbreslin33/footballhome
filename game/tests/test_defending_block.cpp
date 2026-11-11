// game/tests/test_defending_block.cpp — G5.21 (DESIGN §8.119): the block spot
// is the real table (DFL, by role and ball band); one presser, the nearest
// outfielder, held until another is switch_m nearer.
#include "test_harness.hpp"
#include "ai/DefendingBlock.hpp"
#include "ai/Brain.hpp"
#include "core/World.hpp"

#include <string>

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
    // The table itself: G5.52's depth for their possession (a roll a spell) held at 0.
    core::ModelParams mp;
    for (const char* q : {"p10", "p25", "p50", "p75", "p90"}) {
        mp.setMilli(std::string("physics.block.line_") + q, 0);
        for (const char* r : {"am", "wide", "st"}) {   // G5.70's per-forward roll, held at 0 too
            mp.setMilli(std::string("physics.block.man_") + q + "_" + r, 0);
            mp.setMilli(std::string("physics.block.man_near_") + q + "_" + r, 0);
        }
    }
    b.configure(mp);
    ai::PlayerView v;
    v.slot = 3; v.team = 0; v.sg = Fixed64::one(); v.role = ai::Role::CB; v.across_def = Fixed64::fromInt(6);
    v.ball_to = Vec2{w.ball().pos.x, w.ball().pos.y};      // carried: where it is (Brain::viewOf)
    const Fixed64 off = kHX + w.ball().pos.x;               // ball metres off our line (≈45)
    const Vec2 s = b.spot(v, w);
    // CB real (settled, ball still — G5.42): 22.8 m at band 35, 27.5 at band 45 (DFL) — interpolated.
    const Fixed64 u = (off - Fixed64::fromInt(35)) / Fixed64::fromInt(10);
    const Fixed64 want = Fixed64::fromFraction(228, 10) + (Fixed64::fromFraction(275, 10) - Fixed64::fromFraction(228, 10)) * u - kHX;
    FH_EXPECT(near(s.x, want, 1));
    FH_EXPECT_EQ(s.y.raw, Fixed64::fromInt(6).raw);
    // Away side defends the +x end: the ball is 60 m off its line, its 9
    // stands 58.9 m off it (DFL settled, ball still: ST 56.6 at band 55, 61.1 at 65) = x -6.4.
    v.team = 1; v.sg = -Fixed64::one(); v.role = ai::Role::ST;
    const Vec2 s2 = b.spot(v, w);
    FH_EXPECT(near(s2.x, Fixed64::fromFraction(-64, 10), 3));
    // G5.30 (§8.128): a ball in flight — the spot is for where it will be
    // taken, not where it is: met 25 m off the home line, the home CB stands
    // at the table's 25 m (17.0 m at band 25) = x -35.5.
    v.team = 0; v.sg = Fixed64::one(); v.role = ai::Role::CB;
    v.ball_to = Vec2{Fixed64::fromFraction(-55, 2), Fixed64::zero()};
    const Vec2 s3 = b.spot(v, w);
    FH_EXPECT(near(s3.x, Fixed64::fromFraction(-355, 10), 1));
}

FH_TEST(one_presser_nearest_and_sticky) {
    core::World w = world22();
    const auto team_of = ai::TeamSetup::splitHalves(22).team_of_slot;
    const std::vector<ai::Role> roles(22, ai::Role::DM);   // G5.41's assign takes roles; no CB pair here
    w.placePlayer(16, Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}, Vec2{-Fixed64::one(), Fixed64::zero()});
    w.giveBall(16);
    w.placePlayer(5, Vec3{Fixed64::fromInt(-5), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    w.placePlayer(6, Vec3{Fixed64::fromInt(-8), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    ai::DefendingBlock b;
    b.configure(core::ModelParams{});
    b.assign(0, w, team_of, roles, ai::Reads::FlightRead{}, -1);
    FH_EXPECT_EQ(w.restartTeam(), 0xFF);   // giveBall puts the ball in play
    FH_EXPECT_EQ(b.presser(0), 5);
    {
        // 6 now 1 m nearer than 5: under switch_m (2 m), 5 keeps it.
        w.placePlayer(6, Vec3{Fixed64::fromInt(-4), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
        b.assign(0, w, team_of, roles, ai::Reads::FlightRead{}, -1);
        FH_EXPECT_EQ(b.presser(0), 5);
        // 6 now 3 m nearer: he takes it.
        w.placePlayer(6, Vec3{Fixed64::fromInt(-2), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
        b.assign(0, w, team_of, roles, ai::Reads::FlightRead{}, -1);
        FH_EXPECT_EQ(b.presser(0), 6);
        FH_EXPECT_EQ(b.presser(1), -1);   // their own ball: they don't press it
    }
}

FH_TEST_MAIN()

// G5.72 (§8.173): marking — their man inside our zone radius is taken by the nearest of ours in
// fact (not by spot), one marker a man, and the mark point is mark_d goal-side of him.
FH_TEST(marking_nearest_in_zone_goal_side) {
    core::World w = world22();
    const auto team_of = ai::TeamSetup::splitHalves(22).team_of_slot;
    const std::vector<ai::Role> roles(22, ai::Role::DM);
    // Their carrier far out on the right; their 9 in our box, 12 m off our line.
    w.placePlayer(20, Vec3{Fixed64::fromInt(10), Fixed64::fromInt(25), Fixed64::zero()}, Vec2{-Fixed64::one(), Fixed64::zero()});
    w.giveBall(20);
    const Vec3 nine{Fixed64::fromFraction(-81, 2), Fixed64::zero(), Fixed64::zero()};
    w.placePlayer(16, nine, Vec2{-Fixed64::one(), Fixed64::zero()});
    // Two of ours whose zone (spot) covers him: 4 is 3 m off him, 5 is 7 m off.
    w.placePlayer(4, Vec3{Fixed64::fromFraction(-75, 2), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    w.placePlayer(5, Vec3{Fixed64::fromFraction(-67, 2), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    ai::DefendingBlock b;
    ai::Reads::FlightRead fr{};
    b.assign(0, w, team_of, roles, fr, -1);
    std::vector<Vec2> spots(22, Vec2{Fixed64::fromInt(-36), Fixed64::zero()});   // both spots 4.5 m off him
    std::vector<bool> marks(22, false);
    marks[4] = marks[5] = true;
    b.assignMarks(0, w, team_of, spots, marks);
    FH_EXPECT_EQ(b.markOf(0, 4), 16);
    FH_EXPECT_EQ(b.markOf(0, 5), -1);   // one marker a man
    // Goal-side: on his line to our goal's centre (-52.5, 0), mark_d (1.5 m, 0-18 band) off him.
    const Vec2 m = b.markPoint(0, 16, w);
    FH_EXPECT(near(m.x, Fixed64::fromInt(-42), 1));
    FH_EXPECT(near(m.y, Fixed64::zero(), 1));
    // Our ball: nobody marks.
    w.giveBall(4);
    b.assignMarks(0, w, team_of, spots, marks);
    FH_EXPECT_EQ(b.markOf(0, 4), -1);
}

// G5.82 (§8.183): their pass, their man first to it — nobody of ours chases it; the man of ours
// nearest where he meets it presses toward that spot as it travels (stand-off goal-side of it).
// Ours first by the read, or the margin off (−1): our first man chases it as before.
FH_TEST(their_pass_no_chaser_presser_steps_out) {
    core::World w = world22();
    const auto team_of = ai::TeamSetup::splitHalves(22).team_of_slot;
    const std::vector<ai::Role> roles(22, ai::Role::DM);
    // Their 8 (slot 19) passes to their 9 (slot 16), who meets it at (-10, 0) in 20 ticks; our 5 at
    // (-14, 0) could first take it at (-6, 0) in 30 ticks, our 6 further back.
    w.placePlayer(19, Vec3{Fixed64::fromInt(10), Fixed64::zero(), Fixed64::zero()}, Vec2{-Fixed64::one(), Fixed64::zero()});
    w.giveBall(19);   // lastTouchTeam = theirs, ball in play
    w.placePlayer(16, Vec3{Fixed64::fromInt(-11), Fixed64::zero(), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    w.placePlayer(5, Vec3{Fixed64::fromInt(-14), Fixed64::fromInt(3), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    w.placePlayer(6, Vec3{Fixed64::fromInt(-25), Fixed64::fromInt(10), Fixed64::zero()}, Vec2{Fixed64::one(), Fixed64::zero()});
    core::BallState bs = w.ball();
    bs.owner.reset(); bs.pos = Vec3{Fixed64::fromInt(8), Fixed64::zero(), Fixed64::zero()};
    bs.vel = Vec3{-Fixed64::fromInt(10), Fixed64::zero(), Fixed64::zero()}; bs.last_kicker = 19; bs.pass_to = 16;
    w.placeBall(bs);
    ai::Reads::FlightRead fr{};
    fr.live = true; fr.tick.assign(22, -1); fr.at.assign(22, Vec2{});
    fr.tick[16] = 20; fr.at[16] = Vec2{Fixed64::fromInt(-10), Fixed64::zero()};
    fr.tick[5] = 30;  fr.at[5] = Vec2{Fixed64::fromInt(-6), Fixed64::zero()};
    fr.first[0] = 5; fr.first[1] = 16;
    ai::DefendingBlock b;
    b.configure(core::ModelParams{});
    b.assign(0, w, team_of, roles, fr, -1);
    FH_EXPECT_EQ(b.chaser(0), -1);
    FH_EXPECT_EQ(b.presser(0), 5);
    FH_EXPECT(b.pressFlight(0));
    FH_EXPECT_EQ(b.pressAt(0).x.raw, Fixed64::fromInt(-10).raw);
    // Ours first by the read: our first man goes for it, no early press.
    fr.tick[5] = 15;
    b.assign(0, w, team_of, roles, fr, -1);
    FH_EXPECT_EQ(b.chaser(0), 5);
    FH_EXPECT(!b.pressFlight(0));
    // Off (margin −1, on_pass 0): the G4.81 chase, whoever is first.
    fr.tick[5] = 30;
    core::ModelParams off;
    off.setMilli("physics.block.their_pass_margin_s", -1000);
    off.setMilli("physics.press.on_pass", 0);
    ai::DefendingBlock b2;
    b2.configure(off);
    b2.assign(0, w, team_of, roles, fr, -1);
    FH_EXPECT_EQ(b2.chaser(0), 5);
    FH_EXPECT_EQ(b2.presser(0), -1);
}
