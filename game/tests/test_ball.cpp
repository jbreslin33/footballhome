// game/tests/test_ball.cpp
//
// G1 ball mechanics: roll decay + rest snap, kick-alive runway, gravity +
// bounce, first-touch capture rules, glue carry, kicks, arcade walls, goal
// detection + kickoff reset. All through the public World API — the same
// surface the server drives.

#include "test_harness.hpp"
#include "core/BallFlight.hpp"
#include "core/CanonicalHash.hpp"
#include "core/World.hpp"
#include "math/FixedMath.hpp"

#include <cstdio>

using namespace fh::game::core;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;

namespace {

World makeWorld(std::uint8_t n = 2) {
    World w{n, Fixed64::fromInt(6), Fixed64::fromInt(52), Fixed64::fromInt(34)};
    // Park players far from the centre so the ball stays free unless a
    // test moves someone in.
    for (std::uint8_t i = 0; i < n; ++i) {
        w.placePlayer(i, Vec3{Fixed64::fromInt(-40 + i * 5),
                              Fixed64::fromInt(30), Fixed64::zero()},
                      Vec2{Fixed64::one(), Fixed64::zero()});
    }
    return w;
}

MoveIntent east() {
    MoveIntent m;
    m.move = Vec2{Fixed64::one(), Fixed64::zero()};
    return m;
}
MoveIntent idle() { return MoveIntent{}; }

// Walk slot 0 onto the centre spot and capture the ball.
void captureBall(World& w) {
    w.placePlayer(0, Vec3{Fixed64::fromFraction(-3, 10), Fixed64::zero(),
                          Fixed64::zero()},
                  Vec2{Fixed64::one(), Fixed64::zero()});
    w.tick();  // capture fires: ball at origin is within 0.3 m
}

}  // namespace

FH_TEST(free_ball_at_rest_stays_put) {
    World w = makeWorld();
    for (int i = 0; i < 30; ++i) w.tick();
    FH_EXPECT_EQ(w.ball().pos.x.raw, 0);
    FH_EXPECT_EQ(w.ball().pos.z.raw, 0);
    FH_EXPECT(!w.ball().owner.has_value());
}

FH_TEST(capture_within_radius_slow_ball) {
    World w = makeWorld();
    captureBall(w);
    FH_EXPECT(w.ball().owner.has_value());
    FH_EXPECT_EQ(*w.ball().owner, 0);
}

FH_TEST(nearest_player_wins_capture_tie_by_lower_slot) {
    World w = makeWorld(3);
    // Slot 2 closer than slot 1; both in radius.
    w.placePlayer(1, Vec3{Fixed64::fromFraction(4, 10), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{Fixed64::one(), {}});
    w.placePlayer(2, Vec3{Fixed64::fromFraction(2, 10), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{Fixed64::one(), {}});
    w.tick();
    FH_EXPECT(w.ball().owner.has_value());
    FH_EXPECT_EQ(*w.ball().owner, 2);
}

FH_TEST(carry_glues_ball_ahead_of_facing) {
    World w = makeWorld();
    captureBall(w);
    w.setIntent(0, idle());
    w.tick();
    // Facing east: ball sits kBallCarryLead ahead of the owner's x.
    const auto& o = w.player(0);
    FH_EXPECT_EQ(w.ball().pos.x.raw, (o.pos.x + kBallCarryLead).raw);
    FH_EXPECT_EQ(w.ball().pos.y.raw, o.pos.y.raw);
}

FH_TEST(dribble_moves_ball_with_player) {
    World w = makeWorld();
    captureBall(w);
    w.setIntent(0, east());
    const auto bx0 = w.ball().pos.x.raw;
    for (int i = 0; i < 30; ++i) w.tick();
    FH_EXPECT(w.ball().owner.has_value());
    FH_EXPECT(w.ball().pos.x.raw > bx0);
}

FH_TEST(ground_kick_releases_ball_east) {
    World w = makeWorld();
    captureBall(w);
    w.setIntent(0, idle());  // kick along facing (east)
    w.setAction(0, Action::GroundKick);
    w.tick();
    FH_EXPECT(!w.ball().owner.has_value());
    FH_EXPECT_EQ(w.ball().vel.y.raw, 0);
    FH_EXPECT(w.ball().vel.x > Fixed64::fromInt(10));  // ~14 minus one decay
    FH_EXPECT_EQ(w.ball().pos.z.raw, 0);
}

FH_TEST(kicked_ball_cannot_be_instantly_recaptured) {
    World w = makeWorld();
    captureBall(w);
    w.setAction(0, Action::GroundKick);
    w.tick();
    w.tick();
    // Ball is fast (>> capture max) even while still near the kicker.
    FH_EXPECT(!w.ball().owner.has_value());
}

FH_TEST(lofted_kick_rises_then_bounces_then_stops) {
    World w = makeWorld();
    captureBall(w);
    w.setIntent(0, idle());
    w.setAction(0, Action::LoftedKick);
    w.tick();
    FH_EXPECT(w.ball().vel.z.raw > 0);

    bool airborne_seen = false, bounced = false;
    Fixed64 max_z{};
    for (int i = 0; i < 400; ++i) {
        const auto z_before = w.ball().pos.z;
        const auto vz_before = w.ball().vel.z;
        w.tick();
        if (w.ball().pos.z.raw > 0) airborne_seen = true;
        if (w.ball().pos.z > max_z) max_z = w.ball().pos.z;
        if (z_before.raw > 0 && w.ball().pos.z.raw == 0 &&
            vz_before.raw < 0 && w.ball().vel.z.raw > 0) {
            bounced = true;
        }
    }
    FH_EXPECT(airborne_seen);
    FH_EXPECT(bounced);
    FH_EXPECT(max_z > Fixed64::one());  // a real loft, not a scuff
    // Long after: grounded and (at least vertically) settled.
    FH_EXPECT_EQ(w.ball().pos.z.raw, 0);
    FH_EXPECT_EQ(w.ball().vel.z.raw, 0);
}

FH_TEST(rolling_ball_decays_to_rest_after_runway) {
    World w = makeWorld();
    captureBall(w);
    w.setAction(0, Action::GroundKick);
    w.tick();
    // 14 m/s with 1.3%/tick decay reaches the 0.01 floor in ~18 s; the
    // 2 s kick-alive runway must NOT keep it alive forever.
    for (int i = 0; i < 30 * 60; ++i) w.tick();
    FH_EXPECT_EQ(w.ball().vel.x.raw, 0);
    FH_EXPECT_EQ(w.ball().vel.y.raw, 0);
}

FH_TEST(goal_scores_and_resets_kickoff) {
    World w = makeWorld();
    // Put the carrier near the east goal and shoot straight at it.
    captureBall(w);
    w.placePlayer(0, Vec3{Fixed64::fromInt(45), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{Fixed64::one(), {}});
    w.tick();  // glue to new spot
    w.setAction(0, Action::GroundKick);
    w.tick();

    bool scored = false;
    std::uint8_t team = 99;
    for (int i = 0; i < 90 && !scored; ++i) {
        for (const MatchEvent& e : w.tick())
            if (e.type == MatchEventType::Goal) { scored = true; team = e.team; }
    }
    FH_EXPECT(scored);
    FH_EXPECT_EQ(team, 0);  // crossed +x: home scores
    // Kickoff reset: ball free at the centre spot.
    FH_EXPECT(!w.ball().owner.has_value());
    FH_EXPECT_EQ(w.ball().pos.x.raw, 0);
    FH_EXPECT_EQ(w.ball().pos.y.raw, 0);
}

FH_TEST(wide_shot_bounces_off_wall_not_goal) {
    World w = makeWorld();
    captureBall(w);
    // Near the east line but WAY outside the mouth (y = 20).
    w.placePlayer(0, Vec3{Fixed64::fromInt(45), Fixed64::fromInt(20),
                          Fixed64::zero()}, Vec2{Fixed64::one(), {}});
    w.tick();
    w.setAction(0, Action::GroundKick);
    w.tick();
    bool scored = false;
    bool restarted = false;
    std::uint8_t restart_to = 99;
    for (int i = 0; i < 120; ++i) {
        for (const MatchEvent& e : w.tick()) {
            if (e.type == MatchEventType::Goal) scored = true;
            if (e.type == MatchEventType::GoalKick) {
                restarted = true;
                restart_to = e.team;
            }
        }
    }
    FH_EXPECT(!scored);
    // G3: the wide shot crosses the end line → goal kick to the DEFENDING
    // team (away defends +x), ball dead on their 6-metre spot.
    FH_EXPECT(restarted);
    FH_EXPECT_EQ(restart_to, 1);
    FH_EXPECT_EQ(w.restartTeam(), 1);
}

FH_TEST(non_owner_action_never_kicks) {
    World w = makeWorld();
    captureBall(w);
    w.setAction(1, Action::GroundKick);  // slot 1 doesn't own the ball
    w.tick();
    FH_EXPECT(w.ball().owner.has_value());  // still carried by slot 0
}

FH_TEST(ball_determinism_two_runs_identical) {
    auto run = []() {
        World w = makeWorld();
        captureBall(w);
        w.setIntent(0, east());
        for (int i = 0; i < 20; ++i) w.tick();
        w.setAction(0, Action::LoftedKick);
        for (int i = 0; i < 300; ++i) w.tick();
        return canonicalHash(w);
    };
    const auto a = run(), b = run();
    FH_EXPECT_EQ(a, b);
    std::printf("ball sequence hash: 0x%016llx\n",
                static_cast<unsigned long long>(a));
}

// G4.87 air drag [Goff & Carré 2009]: the solved launch lands the loft at its
// carry; drag makes it a harder strike than the drag-free v = sqrt(g·d/2r)
// and it comes down slower than it went up.
FH_TEST(ball_flight_drag_loft_lands_at_carry) {
    const BallFlight f;
    FH_EXPECT_GT(f.k(), Fixed64::fromFraction(9, 1000));    // ≈ 0.0105 / m
    FH_EXPECT_LT(f.k(), Fixed64::fromFraction(12, 1000));
    for (int c : {10, 30, 50}) {
        const Fixed64 v = f.launchSpeed(Fixed64::fromInt(c));
        const Fixed64 vacuum = fx_sqrt(kGravity * Fixed64::fromInt(c));   // 2r = 1
        FH_EXPECT_GT(v, vacuum);
        Vec3 vel{v, Fixed64::zero(), v * kLoftLaunchRatio}, pos{};
        int ticks = 0;
        while (ticks < 600) {
            f.step(vel);
            vel.z -= kGravity * kTickDt;
            pos += vel * kTickDt;
            ++ticks;
            if (pos.z.raw < 0) break;
        }
        const Fixed64 miss = fx_abs(pos.x - Fixed64::fromInt(c));
        FH_EXPECT_LT(miss, Fixed64::fromFraction(1, 2));
        FH_EXPECT_LT(vel.x, v);   // horizontal speed lost to the air
        FH_EXPECT_EQ(Fixed64::fromInt(ticks) * kTickDt, f.flightTime(Fixed64::fromInt(c)));
        std::printf("loft %d m: strike %.1f m/s (vacuum %.1f), lands at %.1f m/s after %.2f s\n", c, v.toDouble(),
                    vacuum.toDouble(), vel.x.toDouble(), f.flightTime(Fixed64::fromInt(c)).toDouble());
    }
}

FH_TEST_MAIN()
