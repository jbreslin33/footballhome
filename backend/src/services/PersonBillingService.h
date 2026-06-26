#pragma once

#include <optional>
#include <string>
#include <unordered_map>

// PersonBillingService — singleton wrapper around the `person_billing`
// table used by both the Men's and Youth roster screens.  Mirrors the
// Node helpers `loadPersonBilling` / `billingFor` / `BILLING_DEFAULT_*`
// in meta-leads-webhook/index.js so the C++ admin surfaces emit the
// exact same shape.
//
// Rows are seeded lazily — a player with no row gets the schema
// defaults ($35 on 2026-07-02, marked `is_default: true`).  Edits go
// through POST /api/person-billing and POST /api/person-billing/mark-billed
// in LaRosterController.
class PersonBillingService {
public:
    struct Entry {
        std::string nextBillDate;     // YYYY-MM-DD
        double      nextBillAmount;
        bool        isDefault;
    };

    static PersonBillingService& getInstance();

    static constexpr const char* kDefaultDate   = "2026-07-02";
    static constexpr double      kDefaultAmount = 35.00;

    // Snapshot of every row in person_billing, keyed by stringified
    // leagueapps_user_id.  Computed per-request so the lineup screen
    // always sees the latest bill state.
    std::unordered_map<std::string, Entry> loadAll();

    // Per-user lookup against a previously-loaded snapshot.  Falls
    // back to the schema defaults (isDefault=true) when no row exists.
    static Entry billingFor(const std::unordered_map<std::string, Entry>& map,
                            const std::string& leagueAppsUserId);

private:
    PersonBillingService() = default;
    PersonBillingService(const PersonBillingService&) = delete;
    PersonBillingService& operator=(const PersonBillingService&) = delete;
};
