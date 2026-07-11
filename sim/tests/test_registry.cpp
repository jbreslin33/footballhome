// footballhome sim - registry tests
//
// Exercises AttributeRegistry, ConceptRegistry, PatternRegistry. All three
// share the same shape, so tests cover them uniformly.

#include "registry/AttributeRegistry.hpp"
#include "registry/ConceptRegistry.hpp"
#include "registry/PatternRegistry.hpp"
#include "test_harness.hpp"

using fh::sim::AttrId;
using fh::sim::ConceptId;
using fh::sim::PatternId;
using fh::sim::registry::AttributeRegistry;
using fh::sim::registry::ConceptRegistry;
using fh::sim::registry::PatternRegistry;

FH_TEST(attribute_registry_add_and_lookup)
{
    AttributeRegistry reg;
    FH_EXPECT(reg.empty());

    FH_EXPECT(reg.addEntry(1, "physical.max_sprint_speed", "physical"));
    FH_EXPECT(reg.addEntry(2, "mental.anticipation",       "mental"));
    FH_EXPECT_EQ(reg.size(), std::size_t{2});

    const auto id = reg.lookup("physical.max_sprint_speed");
    FH_EXPECT(id.has_value());
    FH_EXPECT_EQ(*id, AttrId{1});

    const auto key = reg.keyOf(2);
    FH_EXPECT(key.has_value());
    FH_EXPECT_EQ(*key, std::string{"mental.anticipation"});
}

FH_TEST(attribute_registry_miss)
{
    AttributeRegistry reg;
    FH_EXPECT(!reg.lookup("nope.nope").has_value());
    FH_EXPECT(!reg.keyOf(999).has_value());
    FH_EXPECT(reg.find(999) == nullptr);
    FH_EXPECT(reg.find("nope.nope") == nullptr);
}

FH_TEST(attribute_registry_idempotent_reinsert)
{
    AttributeRegistry reg;
    FH_EXPECT(reg.addEntry(1, "physical.acceleration", "physical"));
    // Re-adding the same triple is idempotent — should succeed.
    FH_EXPECT(reg.addEntry(1, "physical.acceleration", "physical"));
    FH_EXPECT_EQ(reg.size(), std::size_t{1});
}

FH_TEST(attribute_registry_rejects_conflicting_reinsert)
{
    AttributeRegistry reg;
    FH_EXPECT(reg.addEntry(1, "physical.acceleration", "physical"));

    // Same id, different key → reject.
    FH_EXPECT(!reg.addEntry(1, "physical.deceleration", "physical"));
    // Same key, different id → reject.
    FH_EXPECT(!reg.addEntry(2, "physical.acceleration", "physical"));
    // Empty key → reject.
    FH_EXPECT(!reg.addEntry(3, "", "physical"));

    FH_EXPECT_EQ(reg.size(), std::size_t{1});
}

FH_TEST(concept_registry_basic)
{
    ConceptRegistry reg;
    FH_EXPECT(reg.addEntry(1, "run_to_point", "movement"));
    FH_EXPECT_EQ(reg.size(), std::size_t{1});
    const auto id = reg.lookup("run_to_point");
    FH_EXPECT(id.has_value());
    FH_EXPECT_EQ(*id, ConceptId{1});
}

FH_TEST(pattern_registry_starts_empty)
{
    // M0 mandate: PatternRegistry is empty until M4.
    PatternRegistry reg;
    FH_EXPECT(reg.empty());
    FH_EXPECT_EQ(reg.size(), std::size_t{0});
}

FH_TEST(pattern_registry_add_and_clear)
{
    PatternRegistry reg;
    FH_EXPECT(reg.addEntry(1, "pattern_2v1_defender", "defensive_read"));
    FH_EXPECT(!reg.empty());
    FH_EXPECT_EQ(reg.find(1)->category, std::string{"defensive_read"});
    reg.clear();
    FH_EXPECT(reg.empty());
}

FH_TEST_MAIN()
