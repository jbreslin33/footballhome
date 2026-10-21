// game/tests/test_world.cpp
//
// World tick integration: exactness, intent clamping, slot independence,
// intent sampling semantics.

#include "test_harness.hpp"
#include "core/World.hpp"

using fh::game::core::MoveIntent;
using fh::game::core::World;
using fh::game::core::kTickDt;
using fh::game::core::kPlayerRadius;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;

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
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent intent;
    intent.move = Vec2{Fixed64::one(), Fixed64::zero()};  // full east
    w.setIntent(0, intent);

    // Expected delta computed with the world's own ops: (1 * max) * dt.
    const Fixed64 per_tick = (Fixed64::one() * kMaxSpeed) * kTickDt;
    Fixed64 expected = Fixed64::zero();
    for (int t = 0; t < 90; ++t) {
        w.tick();
        expected += per_tick;
    }
    FH_EXPECT_EQ(w.tickCount(), 90u);
    FH_EXPECT_EQ(w.player(0).pos.x.raw, expected.raw);
    FH_EXPECT_EQ(w.player(0).pos.y.raw, 0);
    FH_EXPECT_EQ(w.player(0).pos.z.raw, 0);
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
    World w{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent intent;
    intent.move = Vec2{Fixed64::fromFraction(1, 2), Fixed64::zero()};
    w.setIntent(0, intent);
    w.tick();

    const Fixed64 expected =
        (Fixed64::fromFraction(1, 2) * kMaxSpeed) * kTickDt;
    FH_EXPECT_EQ(w.player(0).pos.x.raw, expected.raw);
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

FH_TEST_MAIN()
