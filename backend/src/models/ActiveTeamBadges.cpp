#include "ActiveTeamBadges.h"

#include <iostream>
#include <sstream>
#include <unordered_set>

#include "../database/Database.h"

using nlohmann::json;

namespace ActiveTeamBadges {

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
        pqxx::result rows = db->query(
            "SELECT tp.person_id, t.id AS team_id, t.name, t.gender_category "
            "  FROM team_persons tp "
            "  JOIN teams t ON t.id = tp.team_id "
            " WHERE tp.person_id IN (" + idList.str() + ") "
            "   AND tp.removed_at IS NULL "
            "   AND t.is_active = true "
            " ORDER BY t.gender_category NULLS LAST, t.name"
        );
        for (const auto& row : rows) {
            if (row["person_id"].is_null() || row["team_id"].is_null()) continue;
            const long long pid = row["person_id"].as<long long>();
            json team = json::object();
            team["teamId"] = row["team_id"].as<int>();
            team["name"]   = row["name"].is_null() ? std::string("") : std::string(row["name"].c_str());
            team["genderCategory"] = row["gender_category"].is_null()
                ? json(nullptr)
                : json(std::string(row["gender_category"].c_str()));
            out[pid].push_back(std::move(team));
        }
    } catch (const std::exception& e) {
        std::cerr << "[ActiveTeamBadges] loadForPersons failed: " << e.what() << std::endl;
    }

    return out;
}

}  // namespace ActiveTeamBadges
