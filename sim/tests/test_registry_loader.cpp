// footballhome sim - RegistryLoader tests
//
// Exercises the free-function loader + boot-time drift check that bridges
// the DB (via IPgClient) to the runtime AttributeRegistry / ConceptRegistry
// / PatternRegistry types. See DESIGN.md §16.6, §22.9.

#include "common/M0Registry.generated.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "persistence/RegistryLoader.hpp"
#include "registry/AttributeRegistry.hpp"
#include "registry/ConceptRegistry.hpp"
#include "registry/PatternRegistry.hpp"
#include "test_harness.hpp"

#include <string>
#include <vector>

using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::PgError;
using fh::sim::persistence::RegistryRow;
using fh::sim::registry::AttributeRegistry;
using fh::sim::registry::ConceptRegistry;
using fh::sim::registry::PatternRegistry;

namespace {

// Build a canonical M0 attribute-row set (matches migration 200 /
// M0Registry.generated.hpp). Kept local to this test so the drift-check
// tests can mutate a copy without perturbing other tests.
std::vector<RegistryRow> canonicalM0Attrs()
{
    return {
        {1,  "physical.max_walk_speed",        "physical"},
        {2,  "physical.max_jog_speed",         "physical"},
        {3,  "physical.max_sprint_speed",      "physical"},
        {4,  "physical.acceleration",          "physical"},
        {5,  "physical.deceleration",          "physical"},
        {6,  "physical.agility",               "physical"},
        {7,  "physical.stamina_max",           "physical"},
        {8,  "physical.stamina_drain_rate",    "physical"},
        {9,  "physical.stamina_recovery_rate", "physical"},
        {10, "physical.dribble_efficiency",    "physical"},
        // Slice 25.2: ball-carry speed pair (migration 209).
        {11, "physical.max_dribble_speed",      "physical"},
        {12, "physical.max_carry_sprint_speed", "physical"},
        // Slice 24.3b: touch-to-steal (migration 216).
        {13, "physical.press_resistance",       "physical"},
        // Slice 26.1: short-pass primitive kick speed (migration 217).
        {14, "physical.pass_power",             "physical"},
        // Slice 27.3: body_mass for the positional-clamp + tangential-
        // slide collision resolver split (migration 220, ADR §22.24).
        {15, "physical.body_mass",              "physical"},
    };
}

std::vector<RegistryRow> canonicalM0Concepts()
{
    return { {1, "run_to_point", "movement"} };
}

} // namespace

// ============================================================================
// loadAttributeRegistryFromDb — happy path + edge cases
// ============================================================================

FH_TEST(load_attribute_registry_populates_and_indexes)
{
    InMemoryPgClient db;
    db.seedAttributeRegistry(canonicalM0Attrs());

    AttributeRegistry reg;
    fh::sim::persistence::loadAttributeRegistryFromDb(reg, db);

    FH_EXPECT_EQ(reg.size(), std::size_t{15});
    // Round-trip lookup by id.
    const auto* e = reg.find(static_cast<fh::sim::AttrId>(3));
    FH_EXPECT(e != nullptr);
    FH_EXPECT(e->key == "physical.max_sprint_speed");
    // Round-trip lookup by key.
    const auto id = reg.lookup("physical.agility");
    FH_EXPECT(id.has_value());
    FH_EXPECT_EQ(*id, fh::sim::AttrId{6});
    // Slice 16.1: dribble_efficiency at id=10.
    const auto did = reg.lookup("physical.dribble_efficiency");
    FH_EXPECT(did.has_value());
    FH_EXPECT_EQ(*did, fh::sim::AttrId{10});
    // Slice 25.2: ball-carry speed pair.
    const auto mds = reg.lookup("physical.max_dribble_speed");
    FH_EXPECT(mds.has_value());
    FH_EXPECT_EQ(*mds, fh::sim::AttrId{11});
    const auto mcs = reg.lookup("physical.max_carry_sprint_speed");
    FH_EXPECT(mcs.has_value());
    FH_EXPECT_EQ(*mcs, fh::sim::AttrId{12});
    // Slice 24.3b: press_resistance at id=13.
    const auto prd = reg.lookup("physical.press_resistance");
    FH_EXPECT(prd.has_value());
    FH_EXPECT_EQ(*prd, fh::sim::AttrId{13});
    // Slice 26.1: pass_power at id=14.
    const auto ppw = reg.lookup("physical.pass_power");
    FH_EXPECT(ppw.has_value());
    FH_EXPECT_EQ(*ppw, fh::sim::AttrId{14});
    // Slice 27.3: body_mass at id=15 (migration 220, ADR §22.24).
    const auto bmd = reg.lookup("physical.body_mass");
    FH_EXPECT(bmd.has_value());
    FH_EXPECT_EQ(*bmd, fh::sim::AttrId{15});
}

FH_TEST(load_attribute_registry_clears_prior_contents)
{
    InMemoryPgClient db;
    db.seedAttributeRegistry(canonicalM0Attrs());

    AttributeRegistry reg;
    // Pre-populate with junk that would falsely satisfy a "size increased"
    // check if the loader didn't clear.
    reg.addEntry(static_cast<fh::sim::AttrId>(999), "junk.key", "junk");
    fh::sim::persistence::loadAttributeRegistryFromDb(reg, db);

    FH_EXPECT_EQ(reg.size(), std::size_t{15});
    FH_EXPECT(reg.find(static_cast<fh::sim::AttrId>(999)) == nullptr);
}

FH_TEST(load_attribute_registry_throws_when_db_empty)
{
    InMemoryPgClient db;   // no seed → empty
    AttributeRegistry reg;
    bool threw = false;
    try {
        fh::sim::persistence::loadAttributeRegistryFromDb(reg, db);
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT(e.context() == "loadAttributeRegistry");
    }
    FH_EXPECT(threw);
    FH_EXPECT(reg.empty());  // clear() ran before throw
}

// ============================================================================
// loadConceptRegistryFromDb / loadPatternRegistryFromDb
// ============================================================================

FH_TEST(load_concept_registry_populates)
{
    InMemoryPgClient db;
    db.seedConceptRegistry(canonicalM0Concepts());

    ConceptRegistry reg;
    fh::sim::persistence::loadConceptRegistryFromDb(reg, db);

    FH_EXPECT_EQ(reg.size(), std::size_t{1});
    const auto* e = reg.find(static_cast<fh::sim::ConceptId>(1));
    FH_EXPECT(e != nullptr);
    FH_EXPECT(e->key == "run_to_point");
}

FH_TEST(load_concept_registry_throws_when_db_empty)
{
    InMemoryPgClient db;
    ConceptRegistry reg;
    bool threw = false;
    try {
        fh::sim::persistence::loadConceptRegistryFromDb(reg, db);
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT(e.context() == "loadConceptRegistry");
    }
    FH_EXPECT(threw);
}

FH_TEST(load_pattern_registry_allows_empty_db)
{
    // §12.5: patterns are M4+; M0 database has zero pattern rows. The
    // loader must accept this without throwing — unlike attribute /
    // concept where an empty table indicates a broken migration.
    InMemoryPgClient db;
    PatternRegistry reg;
    reg.addEntry(static_cast<fh::sim::PatternId>(999), "junk", "junk");
    fh::sim::persistence::loadPatternRegistryFromDb(reg, db);
    FH_EXPECT(reg.empty());
}

// ============================================================================
// verifyM0RegistryConsistency — drift check
// ============================================================================

FH_TEST(verify_passes_when_db_matches_compile_time_catalog)
{
    InMemoryPgClient db;
    db.seedAttributeRegistry(canonicalM0Attrs());
    db.seedConceptRegistry(canonicalM0Concepts());

    AttributeRegistry attrs;
    ConceptRegistry   concepts;
    fh::sim::persistence::loadAttributeRegistryFromDb(attrs,    db);
    fh::sim::persistence::loadConceptRegistryFromDb  (concepts, db);

    // Should not throw.
    fh::sim::persistence::verifyM0RegistryConsistency(attrs, concepts);
}

FH_TEST(verify_throws_on_missing_attribute_row)
{
    auto rows = canonicalM0Attrs();
    rows.pop_back();   // Slice 27.3: drop kBodyMass (id=15, now the
                       // tail entry after migration 220).

    InMemoryPgClient db;
    db.seedAttributeRegistry(std::move(rows));
    db.seedConceptRegistry(canonicalM0Concepts());

    AttributeRegistry attrs;
    ConceptRegistry   concepts;
    fh::sim::persistence::loadAttributeRegistryFromDb(attrs,    db);
    fh::sim::persistence::loadConceptRegistryFromDb  (concepts, db);

    bool threw = false;
    try {
        fh::sim::persistence::verifyM0RegistryConsistency(attrs, concepts);
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT(e.context() == "verifyM0RegistryConsistency");
        const std::string msg{e.what()};
        FH_EXPECT(msg.find("id=15") != std::string::npos);
        FH_EXPECT(msg.find("missing") != std::string::npos);
    }
    FH_EXPECT(threw);
}

FH_TEST(verify_throws_on_key_mismatch)
{
    auto rows = canonicalM0Attrs();
    rows[0].key = "physical.SNEAKY_WRONG_KEY";

    InMemoryPgClient db;
    db.seedAttributeRegistry(std::move(rows));
    db.seedConceptRegistry(canonicalM0Concepts());

    AttributeRegistry attrs;
    ConceptRegistry   concepts;
    fh::sim::persistence::loadAttributeRegistryFromDb(attrs,    db);
    fh::sim::persistence::loadConceptRegistryFromDb  (concepts, db);

    bool threw = false;
    try {
        fh::sim::persistence::verifyM0RegistryConsistency(attrs, concepts);
    } catch (const PgError& e) {
        threw = true;
        const std::string msg{e.what()};
        FH_EXPECT(msg.find("key mismatch") != std::string::npos);
        FH_EXPECT(msg.find("SNEAKY_WRONG_KEY") != std::string::npos);
    }
    FH_EXPECT(threw);
}

FH_TEST(verify_throws_on_category_mismatch)
{
    auto rows = canonicalM0Attrs();
    rows[0].category = "mental";   // was "physical"

    InMemoryPgClient db;
    db.seedAttributeRegistry(std::move(rows));
    db.seedConceptRegistry(canonicalM0Concepts());

    AttributeRegistry attrs;
    ConceptRegistry   concepts;
    fh::sim::persistence::loadAttributeRegistryFromDb(attrs,    db);
    fh::sim::persistence::loadConceptRegistryFromDb  (concepts, db);

    bool threw = false;
    try {
        fh::sim::persistence::verifyM0RegistryConsistency(attrs, concepts);
    } catch (const PgError& e) {
        threw = true;
        const std::string msg{e.what()};
        FH_EXPECT(msg.find("category mismatch") != std::string::npos);
    }
    FH_EXPECT(threw);
}

FH_TEST(verify_throws_when_db_has_extra_rows)
{
    auto rows = canonicalM0Attrs();
    rows.push_back({100, "physical.SURPRISE", "physical"});

    InMemoryPgClient db;
    db.seedAttributeRegistry(std::move(rows));
    db.seedConceptRegistry(canonicalM0Concepts());

    AttributeRegistry attrs;
    ConceptRegistry   concepts;
    fh::sim::persistence::loadAttributeRegistryFromDb(attrs,    db);
    fh::sim::persistence::loadConceptRegistryFromDb  (concepts, db);

    bool threw = false;
    try {
        fh::sim::persistence::verifyM0RegistryConsistency(attrs, concepts);
    } catch (const PgError& e) {
        threw = true;
        const std::string msg{e.what()};
        FH_EXPECT(msg.find("size mismatch") != std::string::npos);
    }
    FH_EXPECT(threw);
}

FH_TEST(verify_throws_on_concept_mismatch)
{
    InMemoryPgClient db;
    db.seedAttributeRegistry(canonicalM0Attrs());
    // Seed WRONG concept key.
    db.seedConceptRegistry({{1, "wrong_concept", "movement"}});

    AttributeRegistry attrs;
    ConceptRegistry   concepts;
    fh::sim::persistence::loadAttributeRegistryFromDb(attrs,    db);
    fh::sim::persistence::loadConceptRegistryFromDb  (concepts, db);

    bool threw = false;
    try {
        fh::sim::persistence::verifyM0RegistryConsistency(attrs, concepts);
    } catch (const PgError& e) {
        threw = true;
        const std::string msg{e.what()};
        FH_EXPECT(msg.find("concept") != std::string::npos);
        FH_EXPECT(msg.find("key mismatch") != std::string::npos);
    }
    FH_EXPECT(threw);
}

// ============================================================================
// entries() accessor — sanity (used by drift check internally)
// ============================================================================

FH_TEST(registry_entries_returns_ascending_by_id)
{
    AttributeRegistry reg;
    reg.addEntry(static_cast<fh::sim::AttrId>(3), "c", "physical");
    reg.addEntry(static_cast<fh::sim::AttrId>(1), "a", "physical");
    reg.addEntry(static_cast<fh::sim::AttrId>(2), "b", "physical");
    const auto es = reg.entries();
    FH_EXPECT_EQ(es.size(), std::size_t{3});
    FH_EXPECT_EQ(es[0].id, fh::sim::AttrId{1});
    FH_EXPECT_EQ(es[1].id, fh::sim::AttrId{2});
    FH_EXPECT_EQ(es[2].id, fh::sim::AttrId{3});
}

FH_TEST_MAIN()
