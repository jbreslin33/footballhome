// footballhome sim - AttributeSet tests
//
// Coverage (post ADR §22.18 — byte codec removed, persistence moved to
// row-per-attribute in sim_player_attribute):
//   • Default construction is empty.
//   • get() returns the caller-supplied default for missing IDs.
//   • set/get/has/erase round-trips a small handful of Fixed64 values.
//   • clear() resets to empty.
//   • values() exposes the underlying map (used by ProfileStore::save
//     to iterate + sort at the persistence boundary).

#include "profile/AttributeSet.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

using fh::sim::AttrId;
using fh::sim::math::Fixed64;
using fh::sim::profile::AttributeSet;

FH_TEST(attribute_set_default_is_empty)
{
    AttributeSet s;
    FH_EXPECT(s.empty());
    FH_EXPECT_EQ(s.size(), std::size_t{0});
    FH_EXPECT(!s.has(AttrId{1}));
}

FH_TEST(attribute_set_get_returns_default_when_missing)
{
    AttributeSet s;
    const Fixed64 fallback = Fixed64::fromDouble(-1.0);
    FH_EXPECT_EQ(s.get(AttrId{42}, fallback).raw, fallback.raw);
}

FH_TEST(attribute_set_set_get_has_erase)
{
    AttributeSet s;
    s.set(AttrId{1}, Fixed64::fromDouble(7.5));
    s.set(AttrId{2}, Fixed64::fromDouble(2.0));

    FH_EXPECT(s.has(AttrId{1}));
    FH_EXPECT(s.has(AttrId{2}));
    FH_EXPECT(!s.has(AttrId{3}));
    FH_EXPECT_EQ(s.size(), std::size_t{2});
    FH_EXPECT_EQ(s.get(AttrId{1}).raw, Fixed64::fromDouble(7.5).raw);

    s.erase(AttrId{1});
    FH_EXPECT(!s.has(AttrId{1}));
    FH_EXPECT_EQ(s.size(), std::size_t{1});
}

FH_TEST(attribute_set_clear_resets)
{
    AttributeSet s;
    s.set(AttrId{5}, Fixed64::fromInt(3));
    s.set(AttrId{6}, Fixed64::fromInt(4));
    FH_EXPECT_EQ(s.size(), std::size_t{2});
    s.clear();
    FH_EXPECT(s.empty());
    FH_EXPECT_EQ(s.size(), std::size_t{0});
}

FH_TEST(attribute_set_values_exposes_underlying_map)
{
    // ProfileStore::save iterates .values() at the persistence boundary
    // and sorts by id — this test just proves the accessor surface. The
    // sort itself is exercised in test_profile_store.
    AttributeSet s;
    s.set(AttrId{10}, Fixed64::fromInt(1));
    s.set(AttrId{20}, Fixed64::fromInt(2));

    const auto& m = s.values();
    FH_EXPECT_EQ(m.size(), std::size_t{2});
    FH_EXPECT_EQ(m.at(AttrId{10}).raw, Fixed64::fromInt(1).raw);
    FH_EXPECT_EQ(m.at(AttrId{20}).raw, Fixed64::fromInt(2).raw);
}

FH_TEST_MAIN()
