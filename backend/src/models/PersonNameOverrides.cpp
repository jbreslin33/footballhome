#include "PersonNameOverrides.h"

#include <iostream>
#include <sstream>
#include <unordered_set>

#include "../database/Database.h"

namespace PersonNameOverrides {

std::unordered_map<long long, Name> loadForPersons(
    const std::vector<long long>& personIds) {
    std::unordered_map<long long, Name> out;

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
            "SELECT person_id, field_name, value "
            "  FROM person_field_overrides "
            " WHERE person_id IN (" + idList.str() + ") "
            "   AND field_name IN ('firstName', 'lastName')"
        );
        for (const auto& row : rows) {
            if (row["person_id"].is_null() || row["field_name"].is_null()) continue;
            if (row["value"].is_null()) continue;  // blanked — leave LA's value
            const long long pid   = row["person_id"].as<long long>();
            const std::string fld = row["field_name"].c_str();
            const std::string val = row["value"].c_str();
            if (val.empty()) continue;
            if (fld == "firstName")     out[pid].first = val;
            else if (fld == "lastName") out[pid].last  = val;
        }
    } catch (const std::exception& e) {
        std::cerr << "[PersonNameOverrides] loadForPersons failed: "
                  << e.what() << std::endl;
    }

    return out;
}

}  // namespace PersonNameOverrides
