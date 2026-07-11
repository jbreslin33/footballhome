// footballhome sim - RecognitionSet tests
//
// The key M0 invariant: RecognitionSet must round-trip cleanly through the
// DB DEFAULT '\x0000' bytea. This test locks that in from day 1.

#include "profile/RecognitionSet.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <array>
#include <cstdint>

using fh::sim::PatternId;
using fh::sim::math::Fixed64;
using fh::sim::profile::RecognitionSet;

FH_TEST(recognition_set_default_is_empty)
{
    // Every newly-created RecognitionSet must be empty in M0.
    RecognitionSet s;
    FH_EXPECT(s.empty());
    FH_EXPECT_EQ(s.size(), std::size_t{0});
}

FH_TEST(recognition_set_skill_zero_for_missing)
{
    // Absent pattern reads as skill = 0.0. In M0 this means an M4+ pattern
    // that isn't registered yet cannot be recognised — the safe default.
    RecognitionSet s;
    FH_EXPECT_EQ(s.skill(PatternId{123}).raw, Fixed64::zero().raw);
}

FH_TEST(recognition_set_db_default_bytea_parses_to_empty)
{
    // sim_player_profile.recognition DEFAULT '\x0000'::bytea (§8).
    const std::array<std::uint8_t, 2> db_default{{0x00, 0x00}};
    const RecognitionSet round = RecognitionSet::fromBytes(db_default);
    FH_EXPECT(round.empty());
}

FH_TEST(recognition_set_empty_toBytes_is_db_default)
{
    // Round-trip in the other direction: toBytes on an empty set must produce
    // exactly the DB DEFAULT bytea so freshly-inserted rows are stable.
    const RecognitionSet s;
    const auto bytes = s.toBytes();
    FH_EXPECT_EQ(bytes.size(), std::size_t{2});
    FH_EXPECT_EQ(bytes[0], std::uint8_t{0});
    FH_EXPECT_EQ(bytes[1], std::uint8_t{0});
}

FH_TEST(recognition_set_set_and_erase)
{
    RecognitionSet s;
    s.set(PatternId{1}, Fixed64::fromDouble(0.5));
    s.set(PatternId{7}, Fixed64::fromDouble(0.25));
    FH_EXPECT(s.has(PatternId{1}));
    FH_EXPECT(!s.has(PatternId{2}));
    FH_EXPECT_EQ(s.size(), std::size_t{2});

    s.erase(PatternId{1});
    FH_EXPECT(!s.has(PatternId{1}));
    FH_EXPECT_EQ(s.size(), std::size_t{1});
}

FH_TEST(recognition_set_roundtrip_with_values)
{
    RecognitionSet s;
    s.set(PatternId{2}, Fixed64::fromDouble(0.75));
    s.set(PatternId{5}, Fixed64::fromDouble(0.125));

    const auto bytes = s.toBytes();
    const RecognitionSet round = RecognitionSet::fromBytes(bytes);
    FH_EXPECT_EQ(round.size(), std::size_t{2});
    // 0.75 and 0.125 are exact in float — round-trip is bit-exact.
    FH_EXPECT_EQ(round.skill(PatternId{2}).raw, Fixed64::fromDouble(0.75).raw);
    FH_EXPECT_EQ(round.skill(PatternId{5}).raw, Fixed64::fromDouble(0.125).raw);
}

FH_TEST_MAIN()
