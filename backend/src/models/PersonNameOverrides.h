#pragma once
#include <string>
#include <unordered_map>
#include <vector>

// ────────────────────────────────────────────────────────────────────────────
// PersonNameOverrides — batch lookup of admin-set `firstName` / `lastName`
// rows in person_field_overrides for a set of person ids.
//
// The roster boards (#teams) render names straight off the live LeagueApps
// registration record, not off `persons` — see BoysRoster::shapePlayer, which
// builds firstName/lastName/fullName from the LA payload and consults the DB
// only to resolve personId.  That is the right default: LA is the source of
// truth for who registered.  It is the wrong answer when LA itself holds a
// bad name, which happens routinely when a parent registers a child and the
// form carries the parent's name through to the player record.
//
// migration 055 built person_field_overrides for exactly this — "admin-edit
// any LA-sourced field locally without round-tripping to the upstream system"
// — and names firstName/lastName as the person-scoped fields.  This is the
// resolver half: only a row an admin deliberately set wins over LA, so a
// board with no overrides behaves precisely as it did before.
//
// Clearing the override row snaps the board back to the live LA value with
// no deploy, which is what makes this safe to leave in place after the
// upstream record is fixed.
// ────────────────────────────────────────────────────────────────────────────
namespace PersonNameOverrides {

struct Name {
    // Empty means "no override for this half" — the LA value stands.  A
    // deliberately blanked override (value IS NULL) is also read as empty:
    // a nameless player card helps nobody, and the sort comparators in
    // BoysRoster/MensRoster assume a string.
    std::string first;
    std::string last;
};

// Returns personId -> overridden name halves.  A person with no override
// row is absent from the map.  Non-positive ids are ignored.  Never throws
// — a DB error yields an empty map, degrading to the LA name rather than
// failing the whole board.
std::unordered_map<long long, Name> loadForPersons(
    const std::vector<long long>& personIds);

}  // namespace PersonNameOverrides
