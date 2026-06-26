#include "PersonBilling.h"

#include "../database/Database.h"

PersonBilling::PersonBilling()
    : db_(Database::getInstance()) {}

PersonBilling::Map PersonBilling::loadAll() {
    Map out;
    const auto rows = db_->query(
        "SELECT leagueapps_user_id, "
        "       TO_CHAR(next_bill_date, 'YYYY-MM-DD') AS next_bill_date, "
        "       next_bill_amount "
        "  FROM person_billing"
    );
    out.reserve(rows.size());
    for (const auto& row : rows) {
        if (row["leagueapps_user_id"].is_null()) continue;
        const std::string uid = row["leagueapps_user_id"].c_str();
        Row r;
        r.nextBillDate   = row["next_bill_date"].is_null() ? std::string{} : row["next_bill_date"].c_str();
        r.nextBillAmount = row["next_bill_amount"].is_null() ? 0.0 : row["next_bill_amount"].as<double>();
        r.isDefault      = false;
        out.emplace(uid, std::move(r));
    }
    return out;
}

PersonBilling::Row PersonBilling::resolve(const Map& map,
                                          const std::string& leagueAppsUserId) {
    auto it = map.find(leagueAppsUserId);
    if (it != map.end()) return it->second;
    return Row{DEFAULT_DATE, DEFAULT_AMOUNT, true};
}
