#pragma once
#include <string>
#include <unordered_map>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PersonBilling — read-side model for the `person_billing` table.
//
// `person_billing` holds the per-LA-user next-bill-date / next-bill-amount
// the admin sets monthly.  Every roster surface (youth + mens) needs to
// project this onto each registrant row, and falls back to a club-wide
// default when no row exists for the user (so the UI never shows blank
// billing).  Defaults mirror the schema (`'2026-07-02'::date` / `35.00`).
//
// loadAll() returns a hash keyed by stringified leagueapps_user_id so the
// downstream resolver doesn't care whether LA gives the id back as a string
// or an int.
//
// Used by Phase 7 (youth-roster), Phase 8 (mens-roster) and Phase 9
// (person-billing POST endpoints).
// ────────────────────────────────────────────────────────────────────────────
class PersonBilling {
public:
    struct Row {
        std::string nextBillDate;    // "YYYY-MM-DD"
        double      nextBillAmount;  // dollars
        bool        isDefault;       // true → no person_billing row, default applied
    };

    using Map = std::unordered_map<std::string, Row>;

    static constexpr const char* DEFAULT_DATE   = "2026-07-02";
    static constexpr double      DEFAULT_AMOUNT = 35.00;

    PersonBilling();

    // SELECT leagueapps_user_id, next_bill_date, next_bill_amount
    //   FROM person_billing
    Map loadAll();

    // map.get(uid) ?? { defaults, isDefault:true }
    static Row resolve(const Map& map, const std::string& leagueAppsUserId);

private:
    Database* db_;
};
