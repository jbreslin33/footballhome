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

PersonBilling::Row PersonBilling::upsert(long long leagueAppsUserId,
                                          const std::string& nextBillDateIso,
                                          double             nextBillAmount) {
    // INSERT … ON CONFLICT DO UPDATE — RETURNING gives us the post-write
    // row in a single round-trip, matching the Node handler exactly.
    const auto rows = db_->query(
        "INSERT INTO person_billing "
        "  (leagueapps_user_id, next_bill_date, next_bill_amount, updated_at, updated_by_user_id) "
        "VALUES ($1, $2::date, $3, NOW(), NULL) "
        "ON CONFLICT (leagueapps_user_id) DO UPDATE "
        "  SET next_bill_date     = EXCLUDED.next_bill_date, "
        "      next_bill_amount   = EXCLUDED.next_bill_amount, "
        "      updated_at         = NOW(), "
        "      updated_by_user_id = EXCLUDED.updated_by_user_id "
        "RETURNING TO_CHAR(next_bill_date, 'YYYY-MM-DD') AS next_bill_date, "
        "          next_bill_amount",
        {std::to_string(leagueAppsUserId), nextBillDateIso, std::to_string(nextBillAmount)}
    );
    Row r{};
    r.isDefault = false;
    if (!rows.empty()) {
        r.nextBillDate   = rows[0]["next_bill_date"].is_null() ? std::string{} : rows[0]["next_bill_date"].c_str();
        r.nextBillAmount = rows[0]["next_bill_amount"].is_null() ? 0.0 : rows[0]["next_bill_amount"].as<double>();
    }
    return r;
}

PersonBilling::Row PersonBilling::markBilled(long long leagueAppsUserId) {
    // Seed-or-bump: if no row, INSERT (DEFAULT_DATE + 1 month) so the
    // first ever click rolls past the default.  If a row exists, bump
    // its existing date forward by 1 month.  Mirrors the Node handler.
    const auto rows = db_->query(
        "INSERT INTO person_billing "
        "  (leagueapps_user_id, next_bill_date, next_bill_amount, updated_at, updated_by_user_id) "
        "VALUES ($1, ($2::date + INTERVAL '1 month')::date, $3, NOW(), NULL) "
        "ON CONFLICT (leagueapps_user_id) DO UPDATE "
        "  SET next_bill_date     = (person_billing.next_bill_date + INTERVAL '1 month')::date, "
        "      updated_at         = NOW(), "
        "      updated_by_user_id = EXCLUDED.updated_by_user_id "
        "RETURNING TO_CHAR(next_bill_date, 'YYYY-MM-DD') AS next_bill_date, "
        "          next_bill_amount",
        {std::to_string(leagueAppsUserId),
         std::string(DEFAULT_DATE),
         std::to_string(DEFAULT_AMOUNT)}
    );
    Row r{};
    r.isDefault = false;
    if (!rows.empty()) {
        r.nextBillDate   = rows[0]["next_bill_date"].is_null() ? std::string{} : rows[0]["next_bill_date"].c_str();
        r.nextBillAmount = rows[0]["next_bill_amount"].is_null() ? 0.0 : rows[0]["next_bill_amount"].as<double>();
    }
    return r;
}
