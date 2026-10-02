#include "PersonHealth.h"

#include <regex>
#include <stdexcept>

#include "../database/Database.h"

using nlohmann::json;

namespace {

json textOrNull(const pqxx::row& row, const char* col) {
    return row[col].is_null() ? json(nullptr) : json(std::string(row[col].c_str()));
}

// Injuries covering now, newest first per person.  $1 = person (0 = all).
const char* kCurrentSql = R"SQL(
    SELECT DISTINCT ON (i.person_id) i.person_id, h.code,
           to_char(i.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS since,
           to_char(i.ends_at   AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS until,
           fh_person_injury_label(i.person_id) AS label
      FROM person_injuries i
      JOIN health_statuses h ON h.id = i.health_status_id
     WHERE i.starts_at <= now() AND (i.ends_at IS NULL OR i.ends_at > now())
       AND ($1::int = 0 OR i.person_id = $1::int)
     ORDER BY i.person_id, i.starts_at DESC
)SQL";

json entry(const pqxx::row& row) {
    return {{"code",  row["code"].c_str()},
            {"since", textOrNull(row, "since")},
            {"until", textOrNull(row, "until")},
            {"label", textOrNull(row, "label")}};
}

bool isDate(const std::string& s) {
    static const std::regex re(R"(^\d{4}-\d{2}-\d{2}$)");
    return std::regex_match(s, re);
}

}  // namespace

json PersonHealth::board() {
    auto* db = Database::getInstance();
    json statuses = json::array();
    for (const auto& r : db->query(
            "SELECT code, display_name, icon, is_injured, color_bg, color_fg, color_border "
            "  FROM health_statuses WHERE is_active ORDER BY sort_order, id")) {
        statuses.push_back({
            {"code",        r["code"].c_str()},
            {"displayName", r["display_name"].c_str()},
            {"icon",        textOrNull(r, "icon")},
            {"isInjured",   r["is_injured"].as<bool>()},
            {"colorBg",     textOrNull(r, "color_bg")},
            {"colorFg",     textOrNull(r, "color_fg")},
            {"colorBorder", textOrNull(r, "color_border")},
        });
    }
    json copy = json::object();
    for (const auto& r : db->query(
            "SELECT tier, body FROM message_templates "
            " WHERE kind = 'health' AND is_active ORDER BY sort_order DESC, id DESC")) {
        copy[r["tier"].c_str()] = r["body"].c_str();   // first row per tier wins
    }
    json people = json::object();
    for (const auto& r : db->query(kCurrentSql, {"0"})) people[r["person_id"].c_str()] = entry(r);
    return {{"statuses", statuses}, {"copy", copy}, {"people", people}};
}

json PersonHealth::current(long long personId) {
    auto rows = Database::getInstance()->query(kCurrentSql, {std::to_string(personId)});
    return rows.empty() ? json(nullptr) : entry(rows[0]);
}

json PersonHealth::set(long long personId, const std::string& statusCode,
                       const std::string& since, const std::string& until, long long userId) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);

    if (db->query("SELECT 1 FROM persons WHERE id = $1::int", {pid}).empty())
        throw std::invalid_argument("Person not found");
    auto status = db->query("SELECT id, is_injured FROM health_statuses WHERE code = $1 AND is_active",
                            {statusCode});
    if (status.empty()) throw std::invalid_argument("Unknown health status");

    if (!status[0]["is_injured"].as<bool>()) {
        db->query("UPDATE person_injuries SET ends_at = now() "
                  " WHERE person_id = $1::int AND starts_at <= now() AND (ends_at IS NULL OR ends_at > now())",
                  {pid});
        return current(personId);
    }

    if (!since.empty() && !isDate(since)) throw std::invalid_argument("since must be YYYY-MM-DD");
    if (!until.empty() && !isDate(until)) throw std::invalid_argument("until must be YYYY-MM-DD");
    // Club-local midnights: injured from the start of `since`, back at the
    // start of `until`.
    pqxx::result ok;
    try {
        ok = db->query(
            "WITH v AS (SELECT (NULLIF($1, '')::date)::timestamp AT TIME ZONE 'America/New_York' AS s, "
            "                  (NULLIF($2, '')::date)::timestamp AT TIME ZONE 'America/New_York' AS e) "
            "SELECT (s IS NULL OR s <= now()) AS since_ok, (e IS NULL OR e > now()) AS until_ok FROM v",
            {since, until});
    } catch (const std::exception&) {
        throw std::invalid_argument("That is not a real date");
    }
    if (!ok[0]["since_ok"].as<bool>()) throw std::invalid_argument("Injured-since cannot be in the future");
    if (!ok[0]["until_ok"].as<bool>()) throw std::invalid_argument("Back-on must be a day after today");

    const std::string statusId = status[0]["id"].c_str();
    auto open = db->query(
        "SELECT id FROM person_injuries "
        " WHERE person_id = $1::int AND starts_at <= now() AND (ends_at IS NULL OR ends_at > now()) "
        " ORDER BY starts_at DESC LIMIT 1", {pid});
    if (!open.empty()) {
        db->query(
            "UPDATE person_injuries "
            "   SET health_status_id = $2::int, "
            "       starts_at = COALESCE((NULLIF($3, '')::date)::timestamp AT TIME ZONE 'America/New_York', starts_at), "
            "       ends_at   = (NULLIF($4, '')::date)::timestamp AT TIME ZONE 'America/New_York' "
            " WHERE id = $1::bigint",
            {open[0]["id"].c_str(), statusId, since, until});
    } else {
        db->query(
            "INSERT INTO person_injuries (person_id, health_status_id, starts_at, ends_at, created_by_user_id) "
            "VALUES ($1::int, $2::int, "
            "        COALESCE((NULLIF($3, '')::date)::timestamp AT TIME ZONE 'America/New_York', now()), "
            "        (NULLIF($4, '')::date)::timestamp AT TIME ZONE 'America/New_York', NULLIF($5::int, 0))",
            {pid, statusId, since, until, std::to_string(userId)});
    }
    return current(personId);
}

bool PersonHealth::coachCovers(long long userId, long long personId) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM users u "
        "  JOIN coaches co      ON co.person_id = u.person_id "
        "  JOIN team_coaches tc ON tc.coach_id = co.id AND tc.ended_at IS NULL "
        "  JOIN team_persons tp ON tp.team_id = tc.team_id AND tp.removed_at IS NULL "
        " WHERE u.id = $1::int AND tp.person_id = $2::int LIMIT 1",
        {std::to_string(userId), std::to_string(personId)}).empty();
}
