// footballhome sim - RegistryLoader implementation
// See RegistryLoader.hpp and DESIGN.md §16.6, §22.9, §22.11.

#include "persistence/RegistryLoader.hpp"

#include "common/M0Registry.generated.hpp"

#include <sstream>
#include <utility>

namespace fh::sim::persistence {

namespace {

template <typename Registry, typename Rows>
void populate(Registry& out, Rows rows)
{
    out.clear();
    for (auto& r : rows) {
        // addEntry returns false only on duplicate/mismatch; DB has
        // PRIMARY KEY + UNIQUE constraints so duplicates are impossible
        // in practice. Ignore the return value.
        (void)out.addEntry(r.id, std::move(r.key), std::move(r.category));
    }
}

} // namespace

void loadAttributeRegistryFromDb(registry::AttributeRegistry& out, IPgClient& db)
{
    auto rows = db.loadAttributeRegistry();
    if (rows.empty()) {
        throw PgError("loadAttributeRegistry",
                      "sim_attribute_registry returned zero rows "
                      "(migration 200 not applied?)");
    }
    populate(out, std::move(rows));
}

void loadConceptRegistryFromDb(registry::ConceptRegistry& out, IPgClient& db)
{
    auto rows = db.loadConceptRegistry();
    if (rows.empty()) {
        throw PgError("loadConceptRegistry",
                      "sim_concept_registry returned zero rows "
                      "(migration 200 not applied?)");
    }
    populate(out, std::move(rows));
}

void loadPatternRegistryFromDb(registry::PatternRegistry& out, IPgClient& db)
{
    // Pattern catalog is legitimately empty in M0 (patterns land in M4;
    // see §12.5). No fail-loud here.
    populate(out, db.loadPatternRegistry());
}

// -----------------------------------------------------------------------
// Drift check
// -----------------------------------------------------------------------
namespace {

template <typename Registry>
void verify_registry(const Registry& expected,
                     const Registry& actual,
                     const char*     kind /* "attribute" | "concept" */)
{
    // 1) Every compile-time entry must exist in DB and match key + category.
    const auto expected_entries = expected.entries();
    for (const auto& e : expected_entries) {
        const auto* found = actual.find(e.id);
        if (found == nullptr) {
            std::ostringstream os;
            os << kind << " id=" << e.id << " key='" << e.key
               << "' present in compile-time catalog but missing from DB";
            throw PgError("verifyM0RegistryConsistency", os.str());
        }
        if (found->key != e.key) {
            std::ostringstream os;
            os << kind << " id=" << e.id
               << " key mismatch: compile-time='" << e.key
               << "' db='" << found->key << "'";
            throw PgError("verifyM0RegistryConsistency", os.str());
        }
        if (found->category != e.category) {
            std::ostringstream os;
            os << kind << " id=" << e.id << " key='" << e.key
               << "' category mismatch: compile-time='" << e.category
               << "' db='" << found->category << "'";
            throw PgError("verifyM0RegistryConsistency", os.str());
        }
    }

    // 2) DB must not have MORE rows than compile-time expects (extras
    //    signal a migration that wasn't reflected in seedRegistries()).
    if (actual.size() != expected.size()) {
        std::ostringstream os;
        os << kind << " registry size mismatch: compile-time="
           << expected.size() << " db=" << actual.size()
           << " (regenerate M0Registry.generated.hpp?)";
        throw PgError("verifyM0RegistryConsistency", os.str());
    }
}

} // namespace

void verifyM0RegistryConsistency(const registry::AttributeRegistry& attrs,
                                 const registry::ConceptRegistry&   concepts)
{
    registry::AttributeRegistry expected_a;
    registry::ConceptRegistry   expected_c;
    m0::seedRegistries(expected_a, expected_c);

    verify_registry(expected_a, attrs,    "attribute");
    verify_registry(expected_c, concepts, "concept");
}

} // namespace fh::sim::persistence
