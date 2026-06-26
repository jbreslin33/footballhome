#include "PersonBillingService.h"
#include "../database/Database.h"

PersonBillingService& PersonBillingService::getInstance() {
    static PersonBillingService instance;
    return instance;
}

std::unordered_map<std::string, PersonBillingService::Entry>
PersonBillingService::loadAll() {
    auto* db = Database::getInstance();
    // TO_CHAR keeps the date string the same shape JS gets from
    // pg's default DATE parser (YYYY-MM-DD) so the on-wire JSON
    // matches the Node response byte-for-byte.
    auto rows = db->query(
        "SELECT leagueapps_user_id, "
        "       TO_CHAR(next_bill_date, 'YYYY-MM-DD') AS next_bill_date, "
        "       next_bill_amount "
        "  FROM person_billing");
    std::unordered_map<std::string, Entry> out;
    out.reserve(rows.size());
    for (const auto& r : rows) {
        // leagueapps_user_id is bigint in the schema; stringify so the
        // key matches what Node does (`String(r.leagueapps_user_id)`).
        const long long uid = r["leagueapps_user_id"].as<long long>();
        Entry e;
        e.nextBillDate   = r["next_bill_date"].as<std::string>();
        e.nextBillAmount = r["next_bill_amount"].as<double>();
        e.isDefault      = false;
        out.emplace(std::to_string(uid), std::move(e));
    }
    return out;
}

PersonBillingService::Entry
PersonBillingService::billingFor(const std::unordered_map<std::string, Entry>& map,
                                 const std::string& leagueAppsUserId) {
    const auto it = map.find(leagueAppsUserId);
    if (it != map.end()) return it->second;
    return Entry{kDefaultDate, kDefaultAmount, true};
}
