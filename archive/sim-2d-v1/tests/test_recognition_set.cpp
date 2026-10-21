// footballhome sim - RecognitionSet tests
//
// Coverage (post ADR §22.18 — byte codec removed):
//   • Default construction is empty; skill() returns zero for missing.
//   • set()/erase() round-trips small Fixed64 values.
//   • clear() resets to empty.

#include "profile/RecognitionSet.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

using fh::sim::PatternId;
using fh::sim::math::Fixed64;
using fh::sim::profile::RecognitionSet;

FH_TEST(recognition_set_default_is_empty)
{
    RecognitionSet s;
    FH_EXPECT(s.empty());
    FH_EXPECT_EQ(s.size(), std::size_t{0});
    FH_EXPECT_EQ(s.skill(PatternId{1}).raw, Fixed64::zero().raw);
    FH_EXPECT(!s.has(PatternId{1}));
}

FH_TEST(recognition_set_set_erase)
{
    RecognitionSet s;
    s.set(PatternId{5}, Fixed64::fromDouble(0.5));
    FH_EXPECT(s.has(PatternId{5}));
    FH_EXPECT_EQ(s.skill(PatternId{5}).raw, Fixed64::fromDouble(0.5).raw);
    FH_EXPECT_EQ(s.size(), std::size_t{1});

    s.erase(PatternId{5});
    FH_EXPECT(!s.has(PatternId{5}));
    FH_EXPECT_EQ(s.size(), std::size_t{0});
}

FH_TEST(recognition_set_clear_resets)
{
    RecognitionSet s;
    s.set(PatternId{1}, Fixed64::fromInt(1));
    s.set(PatternId{2}, Fixed64::fromInt(1));
    s.clear();
    FH_EXPECT(s.empty());
}

FH_TEST(recognition_set_values_exposes_underlying_map)
{
    RecognitionSet s;
    s.set(PatternId{10}, Fixed64::fromInt(1));
    s.set(PatternId{20}, Fixed64::fromInt(2));

    const auto& m = s.values();
    FH_EXPECT_EQ(m.size(), std::size_t{2});
    FH_EXPECT_EQ(m.at(PatternId{10}).raw, Fixed64::fromInt(1).raw);
    FH_EXPECT_EQ(m.at(PatternId{20}).raw, Fixed64::fromInt(2).raw);
}

FH_TEST_MAIN()
