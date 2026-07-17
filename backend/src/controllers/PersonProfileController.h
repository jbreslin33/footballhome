#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>
#include <optional>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// PersonProfileController — the "everything about one person" endpoint
// that backs the client-side PersonScreen (2026-07-13 directive: single
// drill-down destination reachable from every card that shows a person).
//
// Route (registered under prefix "/api/persons"):
//   GET /api/persons/la/:leagueAppsUserId
//
// Bridges the LA user id → persons.id via external_person_aliases
// (provider='leagueapps'), then bundles a person's core identity +
// contact + LA memberships + upcoming bill + open charge flags +
// field-level overrides + merge history into one JSON payload.
//
// Payload shape (see .cpp for the full JSON layout):
//   {
//     "leagueAppsUserId": "12345",
//     "personId":         42,
//     "person":       { firstName, lastName, birthDate, … },
//     "contact":      { emails: [ … ], phones: [ … ] },
//     "memberships":  [ { programId, programName, category,
//                         variant, joinedAt, endedAt }, … ],
//     "billing":      { nextBillDate, nextBillAmount, updatedAt } | null,
//     "chargeFlags":  [ { id, programId, amountCents, status, … }, … ],
//     "overrides":    [ { fieldName, value, originalValue, … }, … ],
//     "merges":       [ { mergeId, keptPersonId, droppedPersonId, … } ],
//     "teams":        [ { rosterId, teamId, teamName, teamSlug,
//                         clubId, clubName, divisionName,
//                         jerseyNumber, joinedAt, leftAt }, … ],
//     "rsvpEligibility":  [ { teamId, teamName, clubName,
//                             divisionName, grantedAt }, … ],
//     "upcomingMatches":  [ { id, matchDate, matchTime, title,
//                             homeTeamId, awayTeamId, homeTeamName,
//                             awayTeamName, venueName,
//                             rsvpOpensAt }, … ],
//     "recentRsvps":      [ { id, eventId, changedAt, status,
//                             matchDate, title, homeTeamName,
//                             awayTeamName }, … ]
//   }
//
// Returns:
//   200  — bundle above
//   400  — leagueAppsUserId not a positive integer
//   401  — missing/invalid bearer
//   404  — no external_person_aliases row for that LA user id
//   500  — DB error
//
// Auth: bearer-token presence (same as the other admin controllers).
// ────────────────────────────────────────────────────────────────────────────
class PersonProfileController : public Controller {
public:
    PersonProfileController();
    ~PersonProfileController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;

    Response handleGetByLaUserId(const Request& request, const LaSyncMap& sync);

    // Path parser — returns false if the path doesn't match or the id
    // isn't a positive integer.  Trailing slashes tolerated.
    bool extractLaUserId(const std::string& path, long long& laUserId) const;

    // JSON-string helpers (no JSON lib in this project — same manual
    // string-building pattern as the other Phase-N controllers).
    static std::string jsonEscape(const std::string& in);
    static std::string strOrNull(const pqxx::field& f);
    static std::string boolField(const pqxx::field& f);
    static std::string intOrNull(const pqxx::field& f);
    // Numeric fields (person_billing.next_bill_amount, charge_flag amounts
    // stored as INTEGER cents) — emit as JSON number literals verbatim.
    static std::string numOrNull(const pqxx::field& f);
};
