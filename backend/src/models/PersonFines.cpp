#include "PersonFines.h"

#include <sstream>

#include "../database/Database.h"

using nlohmann::json;

PersonFines::PersonFines()
    : db_(Database::getInstance()) {}

namespace {

std::string idList(const std::vector<int>& ids) {
    std::ostringstream s;
    bool first = true;
    for (int id : ids) {
        if (id <= 0) continue;
        if (!first) s << ',';
        s << id;
        first = false;
    }
    return s.str();
}

json strOrNull(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? json(nullptr) : json(std::string(r[col].c_str()));
}

} // namespace

PersonFines::Map PersonFines::monthsFor(const std::vector<int>& personIds, int monthsBack) {
    Map out;
    const std::string ids = idList(personIds);
    if (ids.empty()) return out;
    if (monthsBack <= 0) monthsBack = 3;
    const std::string back = std::to_string(monthsBack - 1);

    // Who is fineable, and since when: on an active team in a section with
    // a fine policy in force today.  `since` is the earliest such policy,
    // so the month boxes never reach back before fines existed.
    std::ostringstream who;
    who << "SELECT tp.person_id, min(fp.effective_from)::text AS since"
        << "  FROM team_persons tp"
        << "  JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.club_section_id IS NOT NULL"
        << "  JOIN fine_policies fp ON fp.club_id = t.club_id"
        << "   AND (fp.club_section_id IS NULL OR fp.club_section_id = t.club_section_id)"
        << "   AND fp.effective_from <= CURRENT_DATE"
        << " WHERE tp.removed_at IS NULL AND tp.person_id IN (" << ids << ")"
        << " GROUP BY tp.person_id";
    auto whoRows = db_->query(who.str());
    if (whoRows.empty()) return out;

    // The month boxes: this month and the (monthsBack − 1) before it, club
    // time, oldest first.
    std::ostringstream months;
    months << "SELECT to_char(d, 'YYYY-MM') AS ym, to_char(d, 'Mon') AS label,"
           << "       to_char(d, 'YYYY-MM-DD') AS first_day"
           << "  FROM generate_series("
           << "         date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date - interval '" << back << " months',"
           << "         date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date,"
           << "         interval '1 month') d ORDER BY d";
    auto monthRows = db_->query(months.str());

    // Every fine since the first shown month, oldest first, with its label.
    std::ostringstream fines;
    fines << "SELECT f.person_id, f.fh_event_id, f.event_kind, f.opponent, f.fine_kind, k.label,"
          << "       f.amount_usd::text AS amount, f.response, f.attendance,"
          << "       to_char(f.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym,"
          << "       to_char(f.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS start_iso"
          << "  FROM fh_person_fines(ARRAY[" << ids << "]::int[],"
          << "         ((date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date"
          << "            - interval '" << back << " months')::timestamp AT TIME ZONE 'America/New_York')) f"
          << "  JOIN fine_kinds k ON k.code = f.fine_kind"
          << " ORDER BY f.person_id, f.starts_at";
    auto fineRows = db_->query(fines.str());

    // person → ym → items
    std::unordered_map<int, std::unordered_map<std::string, json>> byPerson;
    std::unordered_map<int, std::unordered_map<std::string, double>> totals;
    for (const auto& r : fineRows) {
        const int pid = r["person_id"].as<int>();
        const std::string ym = r["ym"].c_str();
        const double amount = std::atof(r["amount"].c_str());
        auto& items = byPerson[pid][ym];
        if (!items.is_array()) items = json::array();
        items.push_back({
            {"fhEventId",  r["fh_event_id"].as<long long>()},
            {"startAt",    r["start_iso"].c_str()},
            {"eventKind",  r["event_kind"].c_str()},
            {"opponent",   strOrNull(r, "opponent")},
            {"kind",       r["fine_kind"].c_str()},
            {"label",      r["label"].c_str()},
            {"amount",     amount},
            {"response",   strOrNull(r, "response")},
            {"attendance", strOrNull(r, "attendance")},
        });
        totals[pid][ym] += amount;
    }

    const std::string currentYm = monthRows.empty() ? std::string{} : std::string(monthRows.back()["ym"].c_str());
    for (const auto& w : whoRows) {
        const int pid = w["person_id"].as<int>();
        const std::string since = w["since"].c_str();          // YYYY-MM-DD
        const std::string sinceYm = since.substr(0, 7);
        json monthsJson = json::array();
        double total = 0;
        for (const auto& m : monthRows) {
            const std::string ym = m["ym"].c_str();
            if (ym < sinceYm) continue;                           // before fines existed
            const double t = totals[pid].count(ym) ? totals[pid][ym] : 0.0;
            json items = byPerson[pid].count(ym) ? byPerson[pid][ym] : json::array();
            monthsJson.push_back({
                {"month",   ym},
                {"label",   m["label"].c_str()},
                {"current", ym == currentYm},
                {"total",   t},
                {"items",   std::move(items)},
            });
            total += t;
        }
        out[pid] = json{{"since", since}, {"total", total}, {"months", std::move(monthsJson)}};
    }
    return out;
}
