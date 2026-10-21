// footballhome sim - ConceptSet tests
//
// Coverage (post ADR §22.18 — byte codec removed):
//   • Default construction is empty; level() returns zero for missing.
//   • has() checks presence with an optional mastery threshold.
//   • plug()/unplug() round-trips small Fixed64 values.
//   • clear() resets to empty.

#include "profile/ConceptSet.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

using fh::sim::ConceptId;
using fh::sim::math::Fixed64;
using fh::sim::profile::ConceptSet;

FH_TEST(concept_set_default_is_empty)
{
    ConceptSet s;
    FH_EXPECT(s.empty());
    FH_EXPECT_EQ(s.size(), std::size_t{0});
    FH_EXPECT_EQ(s.level(ConceptId{1}).raw, Fixed64::zero().raw);
    FH_EXPECT(!s.has(ConceptId{1}));
}

FH_TEST(concept_set_plug_unplug)
{
    ConceptSet s;
    s.plug(ConceptId{7}, Fixed64::fromDouble(0.75));
    FH_EXPECT(s.has(ConceptId{7}));
    FH_EXPECT_EQ(s.level(ConceptId{7}).raw, Fixed64::fromDouble(0.75).raw);
    FH_EXPECT_EQ(s.size(), std::size_t{1});

    s.unplug(ConceptId{7});
    FH_EXPECT(!s.has(ConceptId{7}));
    FH_EXPECT_EQ(s.size(), std::size_t{0});
}

FH_TEST(concept_set_has_threshold)
{
    ConceptSet s;
    s.plug(ConceptId{1}, Fixed64::fromDouble(0.30));

    // Default min_mastery is zero — present entries pass.
    FH_EXPECT(s.has(ConceptId{1}));
    // At-or-above threshold passes.
    FH_EXPECT(s.has(ConceptId{1}, Fixed64::fromDouble(0.30)));
    FH_EXPECT(s.has(ConceptId{1}, Fixed64::fromDouble(0.20)));
    // Above the entry's mastery fails.
    FH_EXPECT(!s.has(ConceptId{1}, Fixed64::fromDouble(0.50)));
}

FH_TEST(concept_set_clear_resets)
{
    ConceptSet s;
    s.plug(ConceptId{1}, Fixed64::fromInt(1));
    s.plug(ConceptId{2}, Fixed64::fromInt(1));
    s.clear();
    FH_EXPECT(s.empty());
}

FH_TEST(concept_set_values_exposes_underlying_map)
{
    ConceptSet s;
    s.plug(ConceptId{10}, Fixed64::fromInt(1));
    s.plug(ConceptId{20}, Fixed64::fromInt(2));

    const auto& m = s.values();
    FH_EXPECT_EQ(m.size(), std::size_t{2});
    FH_EXPECT_EQ(m.at(ConceptId{10}).raw, Fixed64::fromInt(1).raw);
    FH_EXPECT_EQ(m.at(ConceptId{20}).raw, Fixed64::fromInt(2).raw);
}

FH_TEST_MAIN()
