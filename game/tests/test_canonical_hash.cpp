// game/tests/test_canonical_hash.cpp

#include "test_harness.hpp"
#include "core/CanonicalHash.hpp"
#include "core/World.hpp"

using fh::game::core::MoveIntent;
using fh::game::core::World;
using fh::game::core::canonicalHash;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;

namespace {
const Fixed64 kMaxSpeed = Fixed64::fromInt(6);
}

FH_TEST(hash_equal_worlds_equal_hashes) {
    World a{2, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    World b{2, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    FH_EXPECT_EQ(canonicalHash(a), canonicalHash(b));

    MoveIntent east;
    east.move = Vec2{Fixed64::one(), Fixed64::zero()};
    a.setIntent(0, east);
    b.setIntent(0, east);
    a.tick();
    b.tick();
    FH_EXPECT_EQ(canonicalHash(a), canonicalHash(b));
}

FH_TEST(hash_sees_position_difference) {
    World a{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    World b{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    MoveIntent east;
    east.move = Vec2{Fixed64::one(), Fixed64::zero()};
    a.setIntent(0, east);
    a.tick();
    b.tick();  // b idles — same tick count, different position
    FH_EXPECT_NE(canonicalHash(a), canonicalHash(b));
}

FH_TEST(hash_sees_tick_count) {
    // Identical state surface except tick count: idle world, two ticks vs
    // one. Positions all stay zero, so only the clock differs.
    World a{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    World b{1, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    a.tick();
    a.tick();
    b.tick();
    FH_EXPECT_NE(canonicalHash(a), canonicalHash(b));
}

FH_TEST(hash_sees_player_count) {
    World a{2, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    World b{3, kMaxSpeed, Fixed64::fromInt(52), Fixed64::fromInt(34)};
    FH_EXPECT_NE(canonicalHash(a), canonicalHash(b));
}

FH_TEST_MAIN()
