// game/tests/test_world.cpp
//
// World tick integration: exactness, intent clamping, slot independence,
// intent sampling semantics.

#include "test_harness.hpp"
#include "core/World.hpp"
#include <cstdlib>

using fh::game::core::MoveIntent;
using fh::game::core::World;
using fh::game::core::kTickDt;
using fh::game::core::kPlayerRadius;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
namespace math = fh::game::math;

namespace {
const Fixed64 kMaxSpeed = Fixed64::fromInt(6);  // m/s
}

FH_TEST(world_starts_at_origin_tick_zero) {
    World w{3, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    FH_EXPECT_EQ(w.tickCount(), 0u);
    FH_EXPECT_EQ(w.playerCount(), 3);
    for (int i = 0; i < 3; ++i) {
        FH_EXPECT_EQ(w.player(i).pos.x.raw, 0);
        FH_EXPECT_EQ(w.player(i).pos.y.raw, 0);
        FH_EXPECT_EQ(w.player(i).pos.z.raw, 0);
    }
}

FH_TEST(world_integrates_exactly) {
    // G4.51: velocity follows the locomotion law, integrated with the
    // world's own ops. Off the ball (y = 10) so he runs at full top speed.
    // G5.77: the point-mass law, with the footstep body off (physics.body.steps_on 0).
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    { fh::game::core::ModelParams off; off.setMilli("physics.body.steps_on", 0); w.setFootsteps(fh::game::core::Footsteps(off)); }
    w.placePlayer(0, {Fixed64::zero(), Fixed64::fromInt(10), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    MoveIntent intent;
    intent.move = Vec2{Fixed64::one(), Fixed64::zero()};  // full east
    w.setIntent(0, intent);

    const fh::game::core::Body loco;
    Vec2 v{};
    Fixed64 expected = Fixed64::zero();
    for (int t = 0; t < 90; ++t) {
        w.tick();
        v = loco.step(v, Vec2{Fixed64::one() * kMaxSpeed, Fixed64::zero()}, kTickDt);
        expected += v.x * kTickDt;
    }
    FH_EXPECT_EQ(w.tickCount(), 90u);
    FH_EXPECT_EQ(w.player(0).pos.x.raw, expected.raw);
    FH_EXPECT_EQ(w.player(0).pos.y.raw, Fixed64::fromInt(10).raw);
    FH_EXPECT_EQ(w.player(0).pos.z.raw, 0);
}

FH_TEST(locomotion_gets_up_to_speed_and_brakes) {
    // From rest: ~63% of top speed after one tau (1.2 s = 36 ticks), not
    // top speed in one tick; a reversal at speed can't flip in a tick.
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    w.placePlayer(0, {Fixed64::zero(), Fixed64::fromInt(10), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    MoveIntent east;
    east.move = Vec2{Fixed64::one(), Fixed64::zero()};
    w.setIntent(0, east);
    w.tick();
    FH_EXPECT(w.player(0).vel.x < kMaxSpeed * Fixed64::fromFraction(1, 10));
    for (int t = 1; t < 36; ++t) w.tick();
    const Fixed64 frac = w.player(0).vel.x / kMaxSpeed;
    FH_EXPECT(frac > Fixed64::fromFraction(60, 100) && frac < Fixed64::fromFraction(66, 100));
    for (int t = 0; t < 120; ++t) w.tick();
    MoveIntent west;
    west.move = Vec2{-Fixed64::one(), Fixed64::zero()};
    w.setIntent(0, west);
    w.tick();
    FH_EXPECT(w.player(0).vel.x > Fixed64::zero());  // still going east
}

FH_TEST(keeper_dive_flies_then_lands) {
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    w.setKeeper(0, true);
    w.placePlayer(0, {Fixed64::fromInt(-50), Fixed64::zero(), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    MoveIntent left;
    left.move = Vec2{Fixed64::zero(), Fixed64::one()};
    w.setIntent(0, left);
    w.setAction(0, fh::game::core::Action::Dive);
    w.tick();
    const auto& loco = w.locomotion();
    FH_EXPECT_EQ(w.player(0).vel.y.raw, w.body(0).diveSpeed().raw);  // launched, not accelerating
    for (int t = 1; t < loco.diveAirTicks(); ++t) w.tick();
    FH_EXPECT_EQ(w.player(0).dive_ticks, 0);
    FH_EXPECT(w.player(0).recovery_ticks > 0);  // down on the turf
    FH_EXPECT_EQ(w.player(0).vel.y.raw, 0);
}

FH_TEST(world_clamps_overlong_desire) {
    // A hostile client sends a length-10 vector; speed must equal a unit
    // vector's speed in the same direction.
    World cheat{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent long_intent;
    long_intent.move = Vec2{Fixed64::fromInt(10), Fixed64::zero()};
    cheat.setIntent(0, long_intent);
    cheat.tick();

    World honest{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent unit_intent;
    unit_intent.move = Vec2{Fixed64::one(), Fixed64::zero()};
    honest.setIntent(0, unit_intent);
    honest.tick();

    FH_EXPECT_EQ(cheat.player(0).pos.x.raw, honest.player(0).pos.x.raw);
}

FH_TEST(world_half_desire_is_half_speed) {
    // G4.51: half desire settles at half top speed (the law's target),
    // within 1% after 10 s. Off the ball, so no dribble share.
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    w.placePlayer(0, {Fixed64::fromInt(-50), Fixed64::fromInt(10), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    MoveIntent intent;
    intent.move = Vec2{Fixed64::fromFraction(1, 2), Fixed64::zero()};
    w.setIntent(0, intent);
    for (int t = 0; t < 300; ++t) w.tick();

    const Fixed64 half = Fixed64::fromFraction(1, 2) * kMaxSpeed;
    FH_EXPECT(math::fx_abs(w.player(0).vel.x - half) < half * Fixed64::fromFraction(1, 100));
}

FH_TEST(world_slots_are_independent) {
    World w{2, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    // Spawn apart: both default to the origin, where the collision
    // resolver (correctly) pushes overlapping bodies off each other.
    w.placePlayer(0, {Fixed64::fromInt(-5), Fixed64::zero(), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    w.placePlayer(1, {Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    MoveIntent east;
    east.move = Vec2{Fixed64::one(), Fixed64::zero()};
    w.setIntent(0, east);  // slot 1 stays idle
    w.tick();

    FH_EXPECT(w.player(0).pos.x.raw > Fixed64::fromInt(-5).raw);
    FH_EXPECT_EQ(w.player(1).pos.x.raw, Fixed64::fromInt(5).raw);
    FH_EXPECT_EQ(w.player(1).pos.y.raw, 0);
}

FH_TEST(world_intent_is_sampled_last_write_wins) {
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent east;
    east.move = Vec2{Fixed64::one(), Fixed64::zero()};
    MoveIntent north;
    north.move = Vec2{Fixed64::zero(), Fixed64::one()};
    w.setIntent(0, east);
    w.setIntent(0, north);  // overwrites east before the tick
    w.tick();

    FH_EXPECT_EQ(w.player(0).pos.x.raw, 0);
    FH_EXPECT(w.player(0).pos.y.raw > 0);
}

FH_TEST(world_unknown_slot_intent_is_dropped) {
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent intent;
    intent.move = Vec2{Fixed64::one(), Fixed64::zero()};
    w.setIntent(42, intent);  // out of range: no crash, no effect
    w.tick();
    FH_EXPECT_EQ(w.player(0).pos.x.raw, 0);
}

FH_TEST(players_cannot_occupy_same_spot) {
    // Drive two players head-on through each other for 3 seconds; they
    // must never overlap (combined radius 0.9 m) and must end up pushed
    // past/beside each other, not superimposed. [v1 Slice 27]
    World w{2, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34),};
    w.placePlayer(0, {Fixed64::fromInt(-3), Fixed64::zero(), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    w.placePlayer(1, {Fixed64::fromInt(3), Fixed64::zero(), Fixed64::zero()},
                  {-Fixed64::one(), Fixed64::zero()});
    MoveIntent east, west;
    east.move = Vec2{Fixed64::one(), Fixed64::zero()};
    west.move = Vec2{-Fixed64::one(), Fixed64::zero()};
    const Fixed64 min_d_sq =
        (kPlayerRadius + kPlayerRadius) * (kPlayerRadius + kPlayerRadius);
    for (int t = 0; t < 90; ++t) {
        w.setIntent(0, east);
        w.setIntent(1, west);
        w.tick();
        const Vec2 d{w.player(1).pos.x - w.player(0).pos.x,
                     w.player(1).pos.y - w.player(0).pos.y};
        // Allow a hair of tolerance for the single-pass resolve.
        FH_EXPECT(fh::game::math::lengthSquared(d).raw >=
                  (min_d_sq * Fixed64::fromFraction(9, 10)).raw);
    }
}

// G5.77 (§8.178): the footstep body. Running flat out, his velocity changes only on ticks with a
// foot on the ground (none in the stride's flight), a planted foot never moves while it is down,
// and the stride has flight at speed.
FH_TEST(footsteps_velocity_changes_only_through_a_planted_foot) {
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    w.placePlayer(0, {Fixed64::fromInt(-40), Fixed64::fromInt(10), Fixed64::zero()},
                  {Fixed64::one(), Fixed64::zero()});
    MoveIntent intent;
    intent.move = Vec2{Fixed64::one(), Fixed64::zero()};
    w.setIntent(0, intent);
    int flight = 0, contact = 0, moved_while_down = 0, changed_in_air = 0;
    Vec2 plant_was[2] = {};
    bool down_was[2] = {false, false};
    for (int t = 0; t < 150; ++t) {
        const Fixed64 vx0 = w.player(0).vel.x, vy0 = w.player(0).vel.y;
        w.tick();
        const auto& f = w.feet(0);
        const bool any = f.down[0] || f.down[1];
        if (any) ++contact; else ++flight;
        if (!any && t > 30 && (w.player(0).vel.x != vx0 || w.player(0).vel.y != vy0)) ++changed_in_air;
        for (int i = 0; i < 2; ++i) {
            if (f.down[i] && down_was[i] && (f.plant[i].x != plant_was[i].x || f.plant[i].y != plant_was[i].y)) ++moved_while_down;
            plant_was[i] = f.plant[i]; down_was[i] = f.down[i];
        }
    }
    FH_EXPECT(flight > 10);          // a running stride leaves the ground
    FH_EXPECT(contact > flight);
    FH_EXPECT_EQ(changed_in_air, 0);
    FH_EXPECT_EQ(moved_while_down, 0);
}

FH_TEST(footsteps_envelope_falls_with_speed) {
    // DFL p99 (benchmarks_tracking_envelope.py): speeding up 4.4 m/s^2 slow, 2.4 at 7-8 m/s.
    const fh::game::core::Footsteps F;
    auto ms = [](Fixed64 v) { return static_cast<int>((v * Fixed64::fromInt(1000)).raw >> Fixed64::FRAC_BITS); };
    FH_EXPECT(std::abs(ms(F.accCap(Fixed64::fromFraction(1, 2))) - 4400) <= 2);
    FH_EXPECT(std::abs(ms(F.accCap(Fixed64::fromFraction(15, 2))) - 2400) <= 2);
    FH_EXPECT(std::abs(ms(F.latCap(Fixed64::fromFraction(13, 2))) - 6100) <= 2);
    const auto slow = fh::game::core::Footsteps::timing(Fixed64::fromFraction(3, 2));
    const auto fast = fh::game::core::Footsteps::timing(Fixed64::fromInt(8));
    FH_EXPECT(slow.cf == Fixed64::one());         // walking: always a foot down
    FH_EXPECT(fast.cf < Fixed64::fromFraction(1, 2));   // sprinting: mostly in the air
}

// G5.78 (§8.179): the carried ball rolls and he touches it — never glued at a fixed lead, touched
// every 0.3-2 s running, never more than 2.5 m off; a keeper's stays in his hands (glued).
FH_TEST(dribble_ball_rolls_and_is_touched) {
    World w{2, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    w.setTeam(1, 1);
    w.placePlayer(0, {Fixed64::fromInt(-40), Fixed64::zero(), Fixed64::zero()}, {Fixed64::one(), Fixed64::zero()});
    w.placePlayer(1, {Fixed64::fromInt(45), Fixed64::fromInt(30), Fixed64::zero()}, {-Fixed64::one(), Fixed64::zero()});
    w.giveBall(0);
    MoveIntent run;
    run.move = Vec2{Fixed64::one(), Fixed64::zero()};
    w.setIntent(0, run);
    double lo = 9, hi = -9;
    const std::uint32_t t0 = w.dribbleTouches();
    for (int t = 0; t < 150; ++t) {
        w.tick();
        if (!w.ball().owner) break;
        const double gap = (w.ball().pos.x - w.player(0).pos.x).toDouble();
        if (t > 30) { lo = std::min(lo, gap); hi = std::max(hi, gap); }
    }
    FH_EXPECT(w.ball().owner.has_value());           // he kept it
    FH_EXPECT(hi - lo > 0.15);                        // it rolls out and back, not a fixed lead
    FH_EXPECT(hi < 2.5);
    const std::uint32_t n = w.dribbleTouches() - t0;
    FH_EXPECT(n >= 2 && n <= 16);                     // 5 s running: a touch every 0.3-2.5 s
}

FH_TEST_MAIN()
