// game/tests/test_block.cpp — G5.164 (DESIGN §8.270): a ball off a body. Real blocked shots are next touched in
// play 1.2 / 1.8 / 2.6 s on, 3.8% inside 0.5 s (StatsBomb PL 2015/16, benchmarks_statsbomb_deflect.py); ours were
// taken by the man beside the blocker within a tick, on 7 m/s whatever the turn, after skidding off the height it
// was struck at.

#include "test_harness.hpp"
#include "core/ModelParams.hpp"
#include "core/World.hpp"

#include <cstdint>

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;

namespace {
Vec3 at(int x10, int y10) { return Vec3{Fixed64::fromFraction(x10, 10), Fixed64::fromFraction(y10, 10), Fixed64::zero()}; }
const Vec2 kEast{Fixed64::one(), Fixed64::zero()};

// Slot 0 (home) has just struck it east at 24 m/s, knee high; slot 2 (away) stands in its line 1 m on; slot 1
// (home) and slot 3 (away) stand round the blocker, inside a man's reach of anywhere it can go in the first ticks;
// slot 4 is a far-off stand-in so neither side is a man short.
core::World shot(int seed, std::int64_t unread_milli) {
    core::World w{5, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
    w.setMatchSeed(static_cast<std::uint64_t>(seed));
    w.setTeam(0, 0); w.placePlayer(0, at(290, 0), kEast);
    w.setTeam(1, 0); w.placePlayer(1, at(305, 8), kEast);
    w.setTeam(2, 1); w.placePlayer(2, at(305, 0), kEast);
    w.setTeam(3, 1); w.placePlayer(3, at(310, -8), kEast);
    w.setTeam(4, 1); w.placePlayer(4, at(-500, -300), kEast);
    core::ModelParams p;
    p.setMilli("physics.block.unread_s", unread_milli);
    w.configureAerial(p);
    w.giveBall(4);   // open play: a fresh World sits on its kick-off
    core::BallState b;
    b.pos = Vec3{Fixed64::fromInt(30), Fixed64::zero(), Fixed64::fromFraction(4, 10)};
    b.vel = Vec3{Fixed64::fromInt(24), Fixed64::zero(), Fixed64::zero()};
    b.last_kicker = 0;
    b.kicker_lockout = 15;
    b.kick_alive = core::kKickAliveTicks;
    w.placeBall(b);
    return w;
}

// Ticks until the body block; false if it never came.
bool toBlock(core::World& w) {
    for (int k = 0; k < 10; ++k) {
        w.tick();
        if (w.bodyBlocks(1) > 0) return true;
    }
    return false;
}
}  // namespace

FH_TEST(nobody_gets_a_foot_to_a_ball_just_off_a_body) {
    for (int seed = 1; seed <= 40; ++seed) {
        auto w = shot(seed, 500);
        FH_EXPECT(toBlock(w));
        for (int k = 1; k < 15; ++k) {   // 0.5 s at 30 Hz
            w.tick();
            FH_EXPECT(!w.ball().owner.has_value());
        }
    }
}

FH_TEST(without_the_window_the_man_beside_the_blocker_takes_it_at_once) {
    int taken = 0;
    for (int seed = 1; seed <= 40; ++seed) {
        auto w = shot(seed, 0);
        FH_EXPECT(toBlock(w));
        for (int k = 1; k < 15 && !w.ball().owner; ++k) w.tick();
        if (w.ball().owner) ++taken;
    }
    FH_EXPECT(taken > 0);
}

FH_TEST(it_leaves_the_body_on_the_grass_with_the_pace_its_turn_keeps) {
    int glance = 0, back = 0;
    for (int seed = 1; seed <= 60; ++seed) {
        auto w = shot(seed, 500);
        FH_EXPECT(toBlock(w));
        const auto& b = w.ball();
        FH_EXPECT_EQ(b.pos.z.raw, 0);
        const Fixed64 sp = math::length(Vec2{b.vel.x, b.vel.y});
        const Fixed64 keep = sp / Fixed64::fromInt(24);
        // cos(turn) = vel.x / speed (it came in due east)
        const Fixed64 ct = b.vel.x / sp;
        FH_EXPECT(keep >= Fixed64::fromFraction(28, 100));   // straight back: block.keep 0.3 (less a tick's roll)
        FH_EXPECT(keep <= Fixed64::one());
        if (ct < -Fixed64::fromFraction(95, 100)) { ++back; FH_EXPECT(keep < Fixed64::fromFraction(35, 100)); }
        if (ct > Fixed64::fromFraction(9, 10)) { ++glance; FH_EXPECT(keep > Fixed64::fromFraction(85, 100)); }
    }
    FH_EXPECT(back > 0);
    FH_EXPECT(glance > 0);
}

// G5.165 (§8.271): their kick reaching a man inside his reaction hits him — a blocked pass, not his ball. Slot 0
// (home) drives it east along the ground at slot 2 (away) standing 2.5 m off; it is at him in ~0.15 s, inside his
// 0.2 s reaction + 2 ticks of perception.
core::World pass(std::int64_t react_reach_milli) {
    core::World w{5, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
    w.setMatchSeed(7);
    w.setTeam(0, 0); w.placePlayer(0, at(0, 0), kEast);
    w.setTeam(1, 0); w.placePlayer(1, at(-300, 200), kEast);
    w.setTeam(2, 1); w.placePlayer(2, at(25, 0), Vec2{-Fixed64::one(), Fixed64::zero()});
    w.setTeam(3, 1); w.placePlayer(3, at(-400, -200), kEast);
    w.setTeam(4, 1); w.placePlayer(4, at(400, -200), kEast);
    core::ModelParams p;
    p.setMilli("physics.ball.react_reach", react_reach_milli);
    w.configureAerial(p);
    w.giveBall(0);
    w.setAction(0, core::Action::GroundKick);
    w.tick();
    return w;
}

FH_TEST(a_pass_at_a_man_who_has_not_reacted_comes_off_his_body) {
    auto w = pass(1000);
    FH_EXPECT(!w.ball().owner.has_value());   // kicked
    for (int k = 0; k < 15 && w.bodyBlocks(1) == 0 && !w.ball().owner; ++k) w.tick();
    FH_EXPECT_EQ(w.bodyBlocks(1), 1);
    FH_EXPECT(!w.ball().owner.has_value());
}

FH_TEST(without_the_reaction_rule_he_simply_takes_it) {
    auto w = pass(0);
    for (int k = 0; k < 15 && !w.ball().owner && w.lastTouchTeam() == 0; ++k) w.tick();
    FH_EXPECT_EQ(w.bodyBlocks(1), 0);
    FH_EXPECT_EQ(static_cast<int>(w.lastTouchTeam()), 1);   // his touch: kept or off him loose
}

FH_TEST_MAIN()
