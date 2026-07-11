// footballhome sim - ConceptSet tests

#include "profile/ConceptSet.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <array>
#include <cstdint>

using fh::sim::ConceptId;
using fh::sim::math::Fixed64;
using fh::sim::profile::ConceptSet;

FH_TEST(concept_set_default_is_empty)
{
    ConceptSet s;
    FH_EXPECT(s.empty());
    FH_EXPECT_EQ(s.size(), std::size_t{0});
}

FH_TEST(concept_set_level_zero_for_missing)
{
    // Absent concept must read as 0.0 — this is the "no mastery" default that
    // the behavior gate in §5.5 relies on.
    ConceptSet s;
    FH_EXPECT_EQ(s.level(ConceptId{42}).raw, Fixed64::zero().raw);
}

FH_TEST(concept_set_has_with_min_mastery)
{
    ConceptSet s;
    s.plug(ConceptId{1}, Fixed64::fromDouble(0.75));

    // Default min_mastery = 0 — must be present with any level ≥ 0.
    FH_EXPECT(s.has(ConceptId{1}));

    // Threshold above stored value — must NOT satisfy the gate.
    FH_EXPECT(!s.has(ConceptId{1}, Fixed64::fromDouble(0.9)));

    // Threshold at exactly the stored value — must satisfy.
    FH_EXPECT(s.has(ConceptId{1}, Fixed64::fromDouble(0.75)));
}

FH_TEST(concept_set_plug_unplug)
{
    ConceptSet s;
    s.plug(ConceptId{1}, Fixed64::fromDouble(0.5));
    s.plug(ConceptId{2}, Fixed64::fromDouble(1.0));
    FH_EXPECT_EQ(s.size(), std::size_t{2});

    s.unplug(ConceptId{1});
    FH_EXPECT(!s.has(ConceptId{1}));
    FH_EXPECT(s.has(ConceptId{2}));
    FH_EXPECT_EQ(s.size(), std::size_t{1});
}

FH_TEST(concept_set_empty_roundtrip)
{
    const ConceptSet s;
    const auto bytes = s.toBytes();
    FH_EXPECT_EQ(bytes.size(), std::size_t{2});
    FH_EXPECT(ConceptSet::fromBytes(bytes).empty());
}

FH_TEST(concept_set_roundtrip_preserves_values)
{
    ConceptSet s;
    s.plug(ConceptId{1}, Fixed64::fromDouble(0.5));
    s.plug(ConceptId{7}, Fixed64::fromDouble(0.25));

    const auto bytes = s.toBytes();
    FH_EXPECT_EQ(bytes.size(), std::size_t{2 + 2 * 6});

    const ConceptSet round = ConceptSet::fromBytes(bytes);
    FH_EXPECT_EQ(round.size(), std::size_t{2});

    // Both 0.5 and 0.25 are exactly representable as float, so this
    // round-trip should be bit-exact.
    FH_EXPECT_EQ(round.level(ConceptId{1}).raw, Fixed64::fromDouble(0.5).raw);
    FH_EXPECT_EQ(round.level(ConceptId{7}).raw, Fixed64::fromDouble(0.25).raw);
}

FH_TEST_MAIN()
