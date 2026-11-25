#include "PersonTodos.h"

#include "../database/Database.h"

using json = nlohmann::json;

namespace {

json textOrNull(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(std::string(f.c_str())); }

// Midnight today, club time — a daily item ticked before it is due again.
const char* const TODAY = "(date_trunc('day', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York')";

std::string trimmed(const std::string& s) {
    const auto b = s.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return "";
    const auto e = s.find_last_not_of(" \t\r\n");
    return s.substr(b, e - b + 1);
}

}  // namespace

json PersonTodos::list(long long personId) {
    json out = {{"todos", json::array()}, {"due", 0}};
    if (personId <= 0) return out;
    auto* db = Database::getInstance();
    const std::string today = TODAY;
    auto rows = db->query(
        "WITH t AS ( "
        "  SELECT pt.*, "
        "         CASE WHEN pt.repeat = 'daily' AND pt.done_at < " + today + " THEN NULL ELSE pt.done_at END AS done_shown "
        "    FROM person_todos pt "
        "   WHERE pt.person_id = $1::int "
        "     AND (pt.repeat = 'daily' OR pt.done_at IS NULL OR pt.done_at > now() - INTERVAL '7 days')) "
        "SELECT t.id, t.body, t.repeat, to_char(t.due_on, 'YYYY-MM-DD') AS due_on, "
        "       to_char(t.remind_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS remind_at, "
        "       to_char(t.done_shown AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS done_at, "
        "       (t.done_shown IS NULL AND (t.remind_at IS NULL OR t.remind_at <= now())) AS due, "
        "       (t.assigned_by_person_id IS NULL OR t.assigned_by_person_id = t.person_id) AS mine, "
        "       NULLIF(TRIM(CONCAT_WS(' ', ap.first_name, ap.last_name)), '') AS from_name "
        "  FROM t LEFT JOIN persons ap ON ap.id = t.assigned_by_person_id AND ap.id <> t.person_id "
        " ORDER BY t.done_shown IS NOT NULL, t.done_shown DESC, t.due_on NULLS LAST, t.remind_at NULLS FIRST, t.id",
        {std::to_string(personId)});
    int due = 0;
    for (const auto& r : rows) {
        const bool isDue = r["due"].as<bool>();
        if (isDue) ++due;
        out["todos"].push_back({
            {"id",        r["id"].as<long long>()},
            {"body",      r["body"].c_str()},
            {"remind_at", textOrNull(r["remind_at"])},
            {"done_at",   textOrNull(r["done_at"])},
            {"due",       isDue},
            {"repeat",    textOrNull(r["repeat"])},
            {"due_on",    textOrNull(r["due_on"])},
            {"from",      textOrNull(r["from_name"])},
            {"mine",      r["mine"].as<bool>()},
        });
    }
    out["due"] = due;
    return out;
}

std::string PersonTodos::add(long long personId, const std::string& body, const std::string& remindAtIso) {
    if (personId <= 0) return "Sign in first";
    const auto b = body.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return "Type what to do";
    if (body.size() > 500) return "Keep it under 500 characters";
    auto* db = Database::getInstance();
    try {
        db->query(
            "INSERT INTO person_todos (person_id, body, remind_at) "
            "VALUES ($1::int, btrim($2), NULLIF($3, '')::timestamptz)",
            {std::to_string(personId), body, remindAtIso});
    } catch (const std::exception&) {
        return "That time didn't read — pick it again";
    }
    return "";
}

bool PersonTodos::setDone(long long personId, long long id, bool done) {
    auto* db = Database::getInstance();
    auto r = db->query(
        std::string("UPDATE person_todos SET done_at = ") + (done ? "now()" : "NULL") +
        " WHERE id = $1::bigint AND person_id = $2::int RETURNING id",
        {std::to_string(id), std::to_string(personId)});
    return !r.empty();
}

bool PersonTodos::remove(long long personId, long long id) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "DELETE FROM person_todos WHERE id = $1::bigint AND person_id = $2::int "
        "   AND (assigned_by_person_id IS NULL OR assigned_by_person_id = person_id) RETURNING id",
        {std::to_string(id), std::to_string(personId)});
    return !r.empty();
}

// ── Staff ───────────────────────────────────────────────────────────────

bool PersonTodos::canGive(long long viewerUserId, long long personId) {
    if (viewerUserId <= 0 || personId <= 0) return false;
    auto* db = Database::getInstance();
    auto r = db->query(
        "SELECT EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
        "                WHERE a.user_id = $1::int AND al.name IN ('club', 'super')) "
        "    OR EXISTS (SELECT 1 FROM team_persons tp "
        "                 JOIN team_coaches tc ON tc.team_id = tp.team_id AND tc.ended_at IS NULL "
        "                 JOIN coaches co ON co.id = tc.coach_id "
        "                 JOIN users u ON u.person_id = co.person_id AND u.id = $1::int "
        "                WHERE tp.person_id = $2::int AND tp.removed_at IS NULL) AS ok",
        {std::to_string(viewerUserId), std::to_string(personId)});
    return !r.empty() && r[0]["ok"].as<bool>();
}

json PersonTodos::sheet(long long personId, long long viewerUserId) {
    auto* db = Database::getInstance();
    const std::string p = std::to_string(personId), v = std::to_string(viewerUserId), today = TODAY;
    json out = {{"personId", personId}, {"canGive", canGive(viewerUserId, personId)},
                {"teams", json::array()}, {"todos", json::array()}};
    if (!out["canGive"].get<bool>()) return out;

    // His teams the viewer may give a whole-team item to.
    for (const auto& t : db->query(
             "SELECT t.id, COALESCE(t.short_label, t.label, t.name) AS label, "
             "       (SELECT count(*) FROM team_persons x WHERE x.team_id = t.id AND x.removed_at IS NULL) AS n "
             "  FROM team_persons tp "
             "  JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.board_sort_order IS NOT NULL "
             " WHERE tp.person_id = $1::int AND tp.removed_at IS NULL "
             "   AND (EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
             "                 WHERE a.user_id = $2::int AND al.name IN ('club', 'super')) "
             "        OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
             "                     JOIN users u ON u.person_id = co.person_id "
             "                    WHERE u.id = $2::int AND tc.team_id = t.id AND tc.ended_at IS NULL)) "
             " ORDER BY t.board_sort_order, t.id", {p, v})) {
        out["teams"].push_back({{"teamId", t["id"].as<long long>()}, {"label", t["label"].c_str()},
                                {"n", t["n"].as<long long>()}});
    }

    for (const auto& r : db->query(
             "SELECT pt.id, pt.body, pt.repeat, pt.batch_id, "
             "       to_char(pt.due_on, 'YYYY-MM-DD') AS due_on, "
             "       to_char(pt.remind_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS remind_at, "
             "       to_char(pt.done_at    AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS done_at, "
             "       to_char(pt.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
             "       (pt.done_at >= " + today + ") AS done_today, "
             "       (pt.assigned_by_person_id IS NULL OR pt.assigned_by_person_id = pt.person_id) AS mine, "
             "       NULLIF(TRIM(CONCAT_WS(' ', ap.first_name, ap.last_name)), '') AS from_name, "
             "       (SELECT count(*) FROM person_todos b WHERE b.batch_id = pt.batch_id) AS batch_n "
             "  FROM person_todos pt LEFT JOIN persons ap ON ap.id = pt.assigned_by_person_id "
             " WHERE pt.person_id = $1::int "
             "   AND (pt.repeat = 'daily' OR pt.done_at IS NULL OR pt.done_at > now() - INTERVAL '60 days') "
             " ORDER BY mine, (pt.repeat IS NULL AND pt.done_at IS NOT NULL), pt.due_on NULLS LAST, pt.created_at DESC",
             {p})) {
        out["todos"].push_back({
            {"id",         r["id"].as<long long>()},
            {"body",       r["body"].c_str()},
            {"repeat",     textOrNull(r["repeat"])},
            {"due_on",     textOrNull(r["due_on"])},
            {"remind_at",  textOrNull(r["remind_at"])},
            {"done_at",    textOrNull(r["done_at"])},
            {"done_today", !r["done_today"].is_null() && r["done_today"].as<bool>()},
            {"created_at", textOrNull(r["created_at"])},
            {"mine",       r["mine"].as<bool>()},
            {"from",       textOrNull(r["from_name"])},
            {"batch_id",   r["batch_id"].is_null() ? json(nullptr) : json(r["batch_id"].as<long long>())},
            {"batch_n",    r["batch_n"].as<long long>()},
        });
    }
    return out;
}

int PersonTodos::give(long long viewerUserId, long long personId, long long teamId,
                      const std::string& body, const std::string& repeat,
                      const std::string& dueOn, std::string& err) {
    const std::string b = trimmed(body);
    if (b.empty()) { err = "Type what to do"; return 0; }
    if (b.size() > 500) { err = "Keep it under 500 characters"; return 0; }
    if (!repeat.empty() && repeat != "daily") { err = "Unknown repeat"; return 0; }
    auto* db = Database::getInstance();
    try {
        // One INSERT: the player, or everyone on the team.  A team add
        // carries one batch_id (a fresh id off the table's own sequence) so
        // the whole lot can be taken back together.
        auto r = db->query(
            "WITH who AS ( "
            "  SELECT DISTINCT tp.person_id FROM team_persons tp "
            "   WHERE $2::int > 0 AND tp.team_id = $2::int AND tp.removed_at IS NULL "
            "  UNION SELECT $1::int WHERE $2::int <= 0), "
            "batch AS (SELECT CASE WHEN $2::int > 0 THEN nextval('person_todos_id_seq') END AS id), "
            "ins AS ( "
            "  INSERT INTO person_todos (person_id, body, repeat, due_on, assigned_by_person_id, batch_id) "
            "  SELECT who.person_id, $3, NULLIF($4, ''), NULLIF($5, '')::date, "
            "         (SELECT u.person_id FROM users u WHERE u.id = $6::int), (SELECT id FROM batch) "
            "    FROM who RETURNING id) "
            "SELECT count(*) AS n FROM ins",
            {std::to_string(personId), std::to_string(teamId), b, repeat, dueOn, std::to_string(viewerUserId)});
        return r.empty() ? 0 : r[0]["n"].as<int>();
    } catch (const std::exception&) {
        err = "That date didn't read — pick it again";
        return 0;
    }
}

bool PersonTodos::take(long long personId, long long id, bool all) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "DELETE FROM person_todos d USING person_todos src "
        " WHERE src.id = $1::bigint AND src.person_id = $2::int "
        "   AND src.assigned_by_person_id IS NOT NULL AND src.assigned_by_person_id <> src.person_id "
        "   AND (d.id = src.id OR ($3::bool AND src.batch_id IS NOT NULL AND d.batch_id = src.batch_id)) "
        "RETURNING d.id",
        {std::to_string(id), std::to_string(personId), all ? "true" : "false"});
    return !r.empty();
}
