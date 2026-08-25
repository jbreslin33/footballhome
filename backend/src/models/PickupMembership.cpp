#include "PickupMembership.h"

#include <iostream>
#include <sstream>
#include <unordered_set>

#include "../database/Database.h"

using nlohmann::json;

namespace PickupMembership {

std::unordered_map<long long, json> loadForPersons(const std::vector<long long>& personIds) {
    std::unordered_map<long long, json> out;

    // De-dupe and drop non-positive ids before building the IN-list.
    std::unordered_set<long long> uniq;
    for (long long pid : personIds) {
        if (pid > 0) uniq.insert(pid);
    }
    if (uniq.empty()) return out;

    std::ostringstream idList;
    bool first = true;
    for (long long pid : uniq) {
        if (!first) idList << ",";
        idList << pid;
        first = false;
    }

    try {
        auto* db = Database::getInstance();
        // variant='pickup' rather than a hardcoded program id: every
        // category has its own pickup program (men 5070075, boys 5064618,
        // girls 5064662, women 5064686) and the registry already knows
        // them all. A category the club adds later needs no code change.
        // ORDER BY la_registered_at DESC so the newest registration wins
        // if someone somehow holds two in the same category.
        pqxx::result rows = db->query(
            "SELECT plm.person_id, lp.category, "
            "       TO_CHAR(plm.la_registered_at, 'YYYY-MM-DD') AS registered_at, "
            "       plm.la_payment_status "
            "  FROM person_la_memberships plm "
            "  JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            " WHERE plm.person_id IN (" + idList.str() + ") "
            "   AND plm.ended_at IS NULL "
            "   AND lp.variant = 'pickup' "
            " ORDER BY plm.la_registered_at DESC NULLS LAST"
        );
        for (const auto& row : rows) {
            if (row["person_id"].is_null()) continue;
            const long long pid = row["person_id"].as<long long>();
            if (out.count(pid)) continue;  // newest already taken
            json m = json::object();
            m["category"] = row["category"].is_null()
                ? json(nullptr) : json(std::string(row["category"].c_str()));
            m["registeredAt"] = row["registered_at"].is_null()
                ? json(nullptr) : json(std::string(row["registered_at"].c_str()));
            m["paymentStatus"] = row["la_payment_status"].is_null()
                ? json(nullptr) : json(std::string(row["la_payment_status"].c_str()));
            out[pid] = std::move(m);
        }
    } catch (const std::exception& e) {
        std::cerr << "[PickupMembership] loadForPersons failed: " << e.what() << std::endl;
    }

    return out;
}

}  // namespace PickupMembership
