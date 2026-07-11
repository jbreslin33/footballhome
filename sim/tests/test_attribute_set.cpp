// footballhome sim - AttributeSet tests
//
// Coverage:
//   • Empty set round-trip (default '\x0000' bytea produces empty set).
//   • set/get/has/erase.
//   • Default value returned for missing IDs.
//   • Deterministic byte output (sorted by id ascending) independent of
//     insertion order.
//   • Full round-trip through toBytes/fromBytes preserves values within
//     f32 precision.
//   • Malformed input returns an empty set.

#include "profile/AttributeSet.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <array>
#include <cstdint>
#include <span>
#include <vector>

using fh::sim::AttrId;
using fh::sim::math::Fixed64;
using fh::sim::profile::AttributeSet;

namespace {

// f32 → Fixed64 → f32 costs about 7 fractional decimal digits. Compare
// on Fixed64 raw within a generous ulp tolerance so tests are portable.
bool close_raw(Fixed64 a, Fixed64 b, std::int64_t tol_raw = 4096)
{
    const std::int64_t d = a.raw - b.raw;
    const std::int64_t abs_d = (d < 0) ? -d : d;
    return abs_d <= tol_raw;
}

} // namespace

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

FH_TEST(attribute_set_empty_roundtrip)
{
    // toBytes of an empty set must produce exactly 2 bytes: u16 count = 0.
    const AttributeSet s;
    const auto bytes = s.toBytes();
    FH_EXPECT_EQ(bytes.size(), std::size_t{2});
    FH_EXPECT_EQ(bytes[0], std::uint8_t{0});
    FH_EXPECT_EQ(bytes[1], std::uint8_t{0});

    // And parsing that must yield an empty set.
    const AttributeSet round = AttributeSet::fromBytes(bytes);
    FH_EXPECT(round.empty());
}

FH_TEST(attribute_set_db_default_bytea_parses_to_empty)
{
    // The DB DEFAULT '\x0000' — verify the codec parses it back to empty.
    const std::array<std::uint8_t, 2> db_default{{0x00, 0x00}};
    const AttributeSet round = AttributeSet::fromBytes(db_default);
    FH_EXPECT(round.empty());
}

FH_TEST(attribute_set_roundtrip_preserves_values)
{
    AttributeSet s;
    s.set(AttrId{10}, Fixed64::fromDouble(4.5));
    s.set(AttrId{20}, Fixed64::fromDouble(7.5));
    s.set(AttrId{30}, Fixed64::fromDouble(0.10));

    const auto bytes = s.toBytes();
    // 2 (count) + 3 * 6 (record) = 20 bytes.
    FH_EXPECT_EQ(bytes.size(), std::size_t{20});

    const AttributeSet round = AttributeSet::fromBytes(bytes);
    FH_EXPECT_EQ(round.size(), std::size_t{3});
    FH_EXPECT(close_raw(round.get(AttrId{10}), Fixed64::fromDouble(4.5)));
    FH_EXPECT(close_raw(round.get(AttrId{20}), Fixed64::fromDouble(7.5)));
    FH_EXPECT(close_raw(round.get(AttrId{30}), Fixed64::fromDouble(0.10)));
}

FH_TEST(attribute_set_byte_output_deterministic)
{
    // Insertion order should NOT affect the byte output (sorted by id).
    AttributeSet a;
    a.set(AttrId{30}, Fixed64::fromDouble(3.0));
    a.set(AttrId{10}, Fixed64::fromDouble(1.0));
    a.set(AttrId{20}, Fixed64::fromDouble(2.0));

    AttributeSet b;
    b.set(AttrId{10}, Fixed64::fromDouble(1.0));
    b.set(AttrId{20}, Fixed64::fromDouble(2.0));
    b.set(AttrId{30}, Fixed64::fromDouble(3.0));

    const auto ba = a.toBytes();
    const auto bb = b.toBytes();
    FH_EXPECT_EQ(ba.size(), bb.size());
    for (std::size_t i = 0; i < ba.size(); ++i) {
        FH_EXPECT_EQ(ba[i], bb[i]);
    }

    // And IDs are ordered 10, 20, 30 in the byte stream.
    // Records start at offset 2 with stride 6 each; id is the first u16 LE.
    FH_EXPECT_EQ(ba[2],  std::uint8_t{10});
    FH_EXPECT_EQ(ba[3],  std::uint8_t{0});
    FH_EXPECT_EQ(ba[8],  std::uint8_t{20});
    FH_EXPECT_EQ(ba[9],  std::uint8_t{0});
    FH_EXPECT_EQ(ba[14], std::uint8_t{30});
    FH_EXPECT_EQ(ba[15], std::uint8_t{0});
}

FH_TEST(attribute_set_malformed_input_returns_empty)
{
    // Zero-length buffer.
    const std::span<const std::uint8_t> empty_span{};
    FH_EXPECT(AttributeSet::fromBytes(empty_span).empty());

    // Count claims 3 records but only enough bytes for one.
    const std::array<std::uint8_t, 8> truncated{
        {0x03, 0x00,                            // count = 3
         0x01, 0x00, 0x00, 0x00, 0x80, 0x3F}};  // one record (id=1, val=1.0f)
    FH_EXPECT(AttributeSet::fromBytes(truncated).empty());
}

FH_TEST_MAIN()
