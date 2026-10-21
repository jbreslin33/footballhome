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
        // Slice 31.3: M3 behavior attribute batch (migration 226).
        {16, "technical.marking_technique",     "technical"},
        {17, "technical.standing_tackle",       "technical"},
        {18, "technical.interception",          "technical"},
        {19, "technical.feint",                 "technical"},
        {20, "technical.first_time_pass",       "technical"},
        {21, "mental.aggression",               "mental"},
        {22, "mental.positioning_sense",        "mental"},
        {23, "mental.composure",                "mental"},
        {24, "mental.anticipation",             "mental"},
    };
}

std::vector<RegistryRow> canonicalM0Concepts()
{
    return {
        {1, "run_to_point", "movement"},
        // Slice 30.2: pressing (migration 224) — gates
        // PursueBallCarrierBehavior. Note the id-3 gap where
        // `pass_to_teammate` (id=2) will land in Slice 31.x; the
        // registry loader tolerates gaps.
        {3, "pressing",     "defensive"},
        // Slice 31.1: marking + jockey (migration 225) — defensive
        // concepts used by the first true defender-behavior slice.
        {4, "marking",      "defensive"},
        {5, "jockey",       "defensive"},
        // Slice 33.1: 1v1_beat (migration 229) — gates the first
        // attacker feint behavior.
        {6, "1v1_beat",     "on_ball"},
        // Slice 34.4: positioning concepts for future defender shape work.
        {7, "return_to_base", "positioning"},
        {8, "stay_in_zone",   "positioning"},
    };
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

    FH_EXPECT_EQ(reg.size(), std::size_t{24});
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
    // Slice 31.3: M3 behavior attribute batch.
    FH_EXPECT_EQ(fh::sim::m0::kMarkingTechnique, fh::sim::AttrId{16});
    FH_EXPECT_EQ(fh::sim::m0::kStandingTackle, fh::sim::AttrId{17});
    FH_EXPECT_EQ(fh::sim::m0::kInterception, fh::sim::AttrId{18});
    FH_EXPECT_EQ(fh::sim::m0::kFeint, fh::sim::AttrId{19});
    FH_EXPECT_EQ(fh::sim::m0::kFirstTimePass, fh::sim::AttrId{20});
    FH_EXPECT_EQ(fh::sim::m0::kAggression, fh::sim::AttrId{21});
    FH_EXPECT_EQ(fh::sim::m0::kPositioningSense, fh::sim::AttrId{22});
    FH_EXPECT_EQ(fh::sim::m0::kComposure, fh::sim::AttrId{23});
    FH_EXPECT_EQ(fh::sim::m0::kAnticipation, fh::sim::AttrId{24});
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

    FH_EXPECT_EQ(reg.size(), std::size_t{24});
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

    FH_EXPECT_EQ(reg.size(), std::size_t{7});
    const auto* e = reg.find(static_cast<fh::sim::ConceptId>(1));
    FH_EXPECT(e != nullptr);
    FH_EXPECT(e->key == "run_to_point");
    // Slice 30.2: pressing lands at id=3 (migration 224).
    const auto* p = reg.find(static_cast<fh::sim::ConceptId>(3));
    FH_EXPECT(p != nullptr);
    FH_EXPECT(p->key == "pressing");
    // Slice 31.1: marking + jockey land at ids 4 + 5 (migration 225).
    const auto* m = reg.find(static_cast<fh::sim::ConceptId>(4));
    FH_EXPECT(m != nullptr);
    FH_EXPECT(m->key == "marking");
    const auto* j = reg.find(static_cast<fh::sim::ConceptId>(5));
    FH_EXPECT(j != nullptr);
    FH_EXPECT(j->key == "jockey");
    FH_EXPECT_EQ(fh::sim::m0::kMarking, fh::sim::ConceptId{4});
    FH_EXPECT_EQ(fh::sim::m0::kJockey, fh::sim::ConceptId{5});
    // Slice 33.1: 1v1_beat lands at id=6 (migration 229).
    const auto* beat = reg.find(static_cast<fh::sim::ConceptId>(6));
    FH_EXPECT(beat != nullptr);
    FH_EXPECT(beat->key == "1v1_beat");
    FH_EXPECT_EQ(fh::sim::m0::k1v1Beat, fh::sim::ConceptId{6});
    const auto* return_to_base = reg.find(static_cast<fh::sim::ConceptId>(7));
    FH_EXPECT(return_to_base != nullptr);
    FH_EXPECT(return_to_base->key == "return_to_base");
    const auto* stay_in_zone = reg.find(static_cast<fh::sim::ConceptId>(8));
    FH_EXPECT(stay_in_zone != nullptr);
    FH_EXPECT(stay_in_zone->key == "stay_in_zone");
    FH_EXPECT_EQ(fh::sim::m0::kReturnToBase, fh::sim::ConceptId{7});
    FH_EXPECT_EQ(fh::sim::m0::kStayInZone, fh::sim::ConceptId{8});
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

FH_TEST(load_pattern_registry_populates_first_m3_pattern)
{
    InMemoryPgClient db;
    db.seedPatternRegistry({{1, "pattern_being_beaten_1v1", "defensive_read"}});

    PatternRegistry reg;
    fh::sim::persistence::loadPatternRegistryFromDb(reg, db);

    FH_EXPECT_EQ(reg.size(), std::size_t{1});
    const auto* pattern = reg.find(static_cast<fh::sim::PatternId>(1));
    FH_EXPECT(pattern != nullptr);
    FH_EXPECT(pattern->key == "pattern_being_beaten_1v1");
    const auto id = reg.lookup("pattern_being_beaten_1v1");
    FH_EXPECT(id.has_value());
    FH_EXPECT_EQ(*id, fh::sim::PatternId{1});
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
    rows.pop_back();   // Slice 31.3: drop kAnticipation (id=24, now the
                       // tail entry after migration 226).

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
        FH_EXPECT(msg.find("id=24") != std::string::npos);
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
