#include "EventAccess.h"
#include "../database/Database.h"

EventAccess::Tier EventAccess::tierFor(Database* db, long long personId, long long fhEventId) {
    if (personId <= 0) return Tier::Player;
    auto rows = db->query("SELECT fh_event_viewer_tier($1::bigint, $2::int) AS tier",
                          {std::to_string(fhEventId), std::to_string(personId)});
    if (rows.empty() || rows[0]["tier"].is_null()) return Tier::Player;
    return parse(rows[0]["tier"].c_str());
}

std::string EventAccess::name(Tier t) {
    switch (t) {
        case Tier::Admin: return "admin";
        case Tier::Coach: return "coach";
        default:          return "player";
    }
}

EventAccess::Tier EventAccess::parse(const std::string& s) {
    if (s == "admin") return Tier::Admin;
    if (s == "coach") return Tier::Coach;
    return Tier::Player;
}
