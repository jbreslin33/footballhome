#include "SessionPlans.h"

#include <set>

#include "../database/Database.h"

using json = nlohmann::json;

namespace {
Database* db() { return Database::getInstance(); }
json txt(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.c_str()); }
json in(const pqxx::field& f)  { return f.is_null() ? json(nullptr) : json(f.as<int>()); }

// Our club's teams = teams in a club section (Men / Women / Youth), active,
// not archived from the boards.
const char* CLUB_TEAMS =
    "SELECT t.id, COALESCE(t.label, t.name) AS label, "
    "       CASE WHEN t.gender_category IN ('mens','womens') THEN 'match_day' ELSE 'weekday' END AS anchor "
    "  FROM teams t WHERE t.club_section_id IS NOT NULL AND t.is_active AND t.board_archived_at IS NULL ";

json teamRow(const pqxx::row& r) {
    return {{"id", r["id"].as<int>()}, {"label", r["label"].c_str()}, {"anchor", r["anchor"].c_str()}};
}

// Slot from a json body → (anchor, weekday, md_offset) as SQL params ("" = NULL).
struct Slot { std::string anchor, weekday, md; };
Slot slotOf(const json& s) {
    Slot o;
    o.anchor = s.value("anchor", std::string());
    if (o.anchor == "weekday" && s.contains("weekday") && s["weekday"].is_number_integer()) {
        int w = s["weekday"].get<int>(); if (w >= 1 && w <= 7) o.weekday = std::to_string(w);
    } else if (o.anchor == "match_day" && s.contains("md_offset") && s["md_offset"].is_number_integer()) {
        int m = s["md_offset"].get<int>(); if (m >= -6 && m <= 2) o.md = std::to_string(m);
    }
    if (o.anchor == "weekday" && o.weekday.empty()) throw std::runtime_error("bad slot");
    if (o.anchor == "match_day" && o.md.empty()) throw std::runtime_error("bad slot");
    if (o.anchor != "weekday" && o.anchor != "match_day" && o.anchor != "no_game") throw std::runtime_error("bad slot");
    return o;
}

int templateId(int teamId, const Slot& s, bool create) {
    auto r = db()->query(
        "SELECT id FROM session_templates WHERE team_id = $1::int AND anchor = $2 "
        "   AND COALESCE(weekday, 0) = COALESCE(NULLIF($3, '')::smallint, 0) "
        "   AND COALESCE(md_offset, 99) = COALESCE(NULLIF($4, '')::smallint, 99)",
        {std::to_string(teamId), s.anchor, s.weekday, s.md});
    if (!r.empty()) return r[0]["id"].as<int>();
    if (!create) return 0;
    auto c = db()->query(
        "INSERT INTO session_templates (team_id, anchor, weekday, md_offset) "
        "VALUES ($1::int, $2, NULLIF($3, '')::smallint, NULLIF($4, '')::smallint) RETURNING id",
        {std::to_string(teamId), s.anchor, s.weekday, s.md});
    return c[0]["id"].as<int>();
}

// Item rows (template or event) with the exercise facts the screens show.
json items(const std::string& table, const std::string& keyCol, const std::string& key) {
    json out = json::array();
    for (const auto& r : db()->query(
            "SELECT i.id, i.exercise_id, i.minutes, i.note, e.title, e.objective, e.players_text, e.area_text, "
            "       e.opposition, e.duration_min, e.book_id, e.page_from, c.label AS category, c.icon "
            "  FROM " + table + " i JOIN exercises e ON e.id = i.exercise_id "
            "  JOIN exercise_categories c ON c.id = e.category_id "
            " WHERE i." + keyCol + " = $1 ORDER BY i.sort_order, i.id", {key}))
        out.push_back({
            {"id", r["id"].as<int>()}, {"exercise_id", r["exercise_id"].as<int>()},
            {"minutes", in(r["minutes"])}, {"note", txt(r["note"])}, {"title", r["title"].c_str()},
            {"objective", r["objective"].c_str()}, {"players", txt(r["players_text"])}, {"area", txt(r["area_text"])},
            {"opposition", txt(r["opposition"])}, {"book_id", in(r["book_id"])}, {"page_from", in(r["page_from"])},
            {"category", r["category"].c_str()}, {"icon", txt(r["icon"])},
            {"default_minutes", r["duration_min"].is_null() ? json(nullptr) : json((int)r["duration_min"].as<double>())}});
    return out;
}

// Default minutes for a newly added exercise: its own duration, else 15.
int defaultMinutes(int exerciseId, int asked) {
    if (asked > 0) return std::min(asked, 180);
    auto r = db()->query("SELECT duration_min FROM exercises WHERE id = $1::int", {std::to_string(exerciseId)});
    if (!r.empty() && !r[0][0].is_null()) { int m = (int)r[0][0].as<double>(); if (m >= 1 && m <= 180) return m; }
    return 15;
}
}  // namespace

json SessionPlans::teamsFor(long long personId, bool clubAdmin) {
    json out = json::array();
    std::string sql = std::string(CLUB_TEAMS);
    pqxx::result r = clubAdmin
        ? db()->query(sql + " ORDER BY t.club_section_id, t.board_sort_order NULLS LAST, t.id")
        : db()->query(sql + " AND t.id IN (SELECT tc.team_id FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
                            "                WHERE co.person_id = $1::int AND tc.ended_at IS NULL) "
                            " ORDER BY t.club_section_id, t.board_sort_order NULLS LAST, t.id", {std::to_string(personId)});
    for (const auto& row : r) out.push_back(teamRow(row));
    return out;
}

bool SessionPlans::canPlanTeam(long long personId, bool clubAdmin, int teamId) {
    for (const auto& t : teamsFor(personId, clubAdmin)) if (t["id"].get<int>() == teamId) return true;
    return false;
}

json SessionPlans::teamPlan(int teamId) {
    auto tr = db()->query(std::string(CLUB_TEAMS) + " AND t.id = $1::int", {std::to_string(teamId)});
    if (tr.empty()) return nullptr;
    json team = teamRow(tr[0]);
    const std::string anchor = team["anchor"];
    // The slots to show: match-day teams get the fixed week; weekday teams get
    // the weekdays they practise on (calendar, ±45 days) plus any already
    // planned, falling back to Mon / Wed / Fri.  Everyone gets MD 0 (warm-up).
    std::vector<json> slots;
    if (anchor == "match_day") {
        for (int md : {1, -3, -2, -1}) slots.push_back({{"anchor", "match_day"}, {"weekday", nullptr}, {"md_offset", md}});
    } else {
        std::set<int> days;
        for (const auto& r : db()->query(
                "SELECT DISTINCT extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int AS d "
                "  FROM fh_event_teams et JOIN fh_events fe ON fe.id = et.fh_event_id "
                "  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
                " WHERE et.team_id = $1::int AND fe.kind = 'practice' AND ge.deleted_at IS NULL "
                "   AND ge.starts_at BETWEEN now() - interval '45 days' AND now() + interval '45 days'",
                {std::to_string(teamId)})) days.insert(r["d"].as<int>());
        for (const auto& r : db()->query(
                "SELECT weekday FROM session_templates WHERE team_id = $1::int AND anchor = 'weekday'",
                {std::to_string(teamId)})) days.insert(r["weekday"].as<int>());
        if (days.empty()) days = {1, 3, 5};
        for (int d : days) slots.push_back({{"anchor", "weekday"}, {"weekday", d}, {"md_offset", nullptr}});
    }
    slots.push_back({{"anchor", "match_day"}, {"weekday", nullptr}, {"md_offset", 0}});
    if (anchor == "match_day") slots.push_back({{"anchor", "no_game"}, {"weekday", nullptr}, {"md_offset", nullptr}});

    json out = {{"team", team}, {"slots", json::array()}};
    for (auto& s : slots) {
        Slot k = slotOf(s);
        int tid = templateId(teamId, k, false);
        s["template_id"] = tid ? json(tid) : json(nullptr);
        s["theme"] = nullptr;
        s["exercises"] = json::array();
        if (tid) {
            auto th = db()->query("SELECT theme FROM session_templates WHERE id = $1::int", {std::to_string(tid)});
            s["theme"] = txt(th[0]["theme"]);
            s["exercises"] = items("session_template_exercises", "template_id", std::to_string(tid));
        }
        out["slots"].push_back(s);
    }
    return out;
}

int SessionPlans::addToTemplate(int teamId, const json& slot, int exerciseId, int minutes) {
    int tid = templateId(teamId, slotOf(slot), true);
    auto r = db()->query(
        "INSERT INTO session_template_exercises (template_id, exercise_id, sort_order, minutes) "
        "SELECT $1::int, $2::int, COALESCE(MAX(sort_order), 0) + 10, $3::smallint "
        "  FROM session_template_exercises WHERE template_id = $1::int RETURNING id",
        {std::to_string(tid), std::to_string(exerciseId), std::to_string(defaultMinutes(exerciseId, minutes))});
    db()->query("UPDATE session_templates SET updated_at = now() WHERE id = $1::int", {std::to_string(tid)});
    return r[0]["id"].as<int>();
}

void SessionPlans::setTheme(int teamId, const json& slot, const std::string& theme) {
    int tid = templateId(teamId, slotOf(slot), true);
    db()->query("UPDATE session_templates SET theme = NULLIF($2, ''), updated_at = now() WHERE id = $1::int",
                {std::to_string(tid), theme});
}

long long SessionPlans::itemOwner(const std::string& kind, int itemId) {
    pqxx::result r = kind == "template"
        ? db()->query("SELECT t.team_id AS owner FROM session_template_exercises i JOIN session_templates t ON t.id = i.template_id WHERE i.id = $1::int", {std::to_string(itemId)})
        : db()->query("SELECT fh_event_id AS owner FROM fh_event_session_exercises WHERE id = $1::int", {std::to_string(itemId)});
    return r.empty() ? 0 : r[0]["owner"].as<long long>();
}

void SessionPlans::updateItem(const std::string& kind, int itemId, const json& body) {
    const std::string table = kind == "template" ? "session_template_exercises" : "fh_event_session_exercises";
    const std::string group = kind == "template" ? "template_id" : "fh_event_id";
    const std::string id = std::to_string(itemId);
    if (body.contains("minutes") && body["minutes"].is_number_integer()) {
        int m = body["minutes"].get<int>();
        db()->query("UPDATE " + table + " SET minutes = $2::smallint WHERE id = $1::int",
                    {id, std::to_string(std::max(1, std::min(m, 180)))});
    }
    if (body.contains("note") && (body["note"].is_string() || body["note"].is_null()))
        db()->query("UPDATE " + table + " SET note = NULLIF($2, '') WHERE id = $1::int",
                    {id, body["note"].is_null() ? std::string() : body["note"].get<std::string>()});
    if (body.contains("move") && body["move"].is_number_integer()) {
        // Renumber the group 10, 20, 30 … then swap with the neighbour.
        const int dir = body["move"].get<int>() < 0 ? -1 : 1;
        auto g = db()->query("SELECT " + group + "::text AS g FROM " + table + " WHERE id = $1::int", {id});
        if (g.empty()) return;
        std::vector<int> ids;
        for (const auto& r : db()->query("SELECT id FROM " + table + " WHERE " + group + "::text = $1 ORDER BY sort_order, id",
                                         {g[0]["g"].c_str()})) ids.push_back(r["id"].as<int>());
        for (size_t i = 0; i < ids.size(); ++i) {
            if (ids[i] != itemId) continue;
            const long j = (long)i + dir;
            if (j >= 0 && j < (long)ids.size()) std::swap(ids[i], ids[j]);
            break;
        }
        for (size_t i = 0; i < ids.size(); ++i)
            db()->query("UPDATE " + table + " SET sort_order = $2::int WHERE id = $1::int",
                        {std::to_string(ids[i]), std::to_string((i + 1) * 10)});
    }
}

void SessionPlans::deleteItem(const std::string& kind, int itemId) {
    db()->query(std::string("DELETE FROM ") + (kind == "template" ? "session_template_exercises" : "fh_event_session_exercises")
                + " WHERE id = $1::int", {std::to_string(itemId)});
}

json SessionPlans::eventSession(long long fhEventId) {
    const std::string ev = std::to_string(fhEventId);
    auto e = db()->query(
        "SELECT fe.kind, (ge.starts_at AT TIME ZONE 'America/New_York')::date AS d, "
        "       extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int AS dow "
        "  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id WHERE fe.id = $1::bigint", {ev});
    if (e.empty()) return nullptr;
    const std::string kind = e[0]["kind"].c_str();
    json out = {{"fh_event_id", fhEventId}, {"kind", kind}, {"team", nullptr}, {"slot", nullptr},
                {"source", "none"}, {"exercises", json::array()}};
    if (kind != "practice" && kind != "match") return out;

    // The event's team: of its club teams, the one that already has plans,
    // else the first by board order (men's practices carry APSL + Liga 1).
    auto t = db()->query(
        std::string(CLUB_TEAMS) + " AND t.id IN (SELECT team_id FROM fh_event_teams WHERE fh_event_id = $1::bigint) "
        " ORDER BY EXISTS (SELECT 1 FROM session_templates s WHERE s.team_id = t.id) DESC, "
        "          t.board_sort_order NULLS LAST, t.id LIMIT 1", {ev});
    if (!t.empty()) out["team"] = teamRow(t[0]);

    // Slot.
    json slot;
    if (kind == "match") {
        slot = {{"anchor", "match_day"}, {"weekday", nullptr}, {"md_offset", 0}};
    } else if (!out["team"].is_null() && out["team"]["anchor"] == "weekday") {
        slot = {{"anchor", "weekday"}, {"weekday", e[0]["dow"].as<int>()}, {"md_offset", nullptr}};
    } else {
        // Days to the next game of any of this event's teams (≤ 6), else days
        // since the last one (≤ 2, MD+1 / MD+2), else the no-game week.
        auto g = db()->query(
            "WITH me AS (SELECT team_id FROM fh_event_teams WHERE fh_event_id = $1::bigint), "
            "games AS (SELECT DISTINCT (ge.starts_at AT TIME ZONE 'America/New_York')::date AS d "
            "            FROM fh_event_teams et JOIN fh_events fe ON fe.id = et.fh_event_id "
            "            JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            "           WHERE et.team_id IN (SELECT team_id FROM me) AND fe.kind = 'match' AND ge.deleted_at IS NULL) "
            "SELECT (SELECT min(d) - $2::date FROM games WHERE d > $2::date AND d <= $2::date + 6) AS ahead, "
            "       (SELECT $2::date - max(d) FROM games WHERE d < $2::date AND d >= $2::date - 2) AS since",
            {ev, e[0]["d"].c_str()});
        if (!g[0]["ahead"].is_null()) slot = {{"anchor", "match_day"}, {"weekday", nullptr}, {"md_offset", -g[0]["ahead"].as<int>()}};
        else if (!g[0]["since"].is_null()) slot = {{"anchor", "match_day"}, {"weekday", nullptr}, {"md_offset", g[0]["since"].as<int>()}};
        else slot = {{"anchor", "no_game"}, {"weekday", nullptr}, {"md_offset", nullptr}};
    }
    out["slot"] = slot;

    // This event's own copy wins; else the team's template for the slot.
    if (!db()->query("SELECT 1 FROM fh_event_sessions WHERE fh_event_id = $1::bigint", {ev}).empty()) {
        out["source"] = "event";
        out["exercises"] = items("fh_event_session_exercises", "fh_event_id", ev);
    } else if (!out["team"].is_null()) {
        int tid = templateId(out["team"]["id"].get<int>(), slotOf(slot), false);
        if (tid) {
            out["source"] = "template";
            out["exercises"] = items("session_template_exercises", "template_id", std::to_string(tid));
            auto th = db()->query("SELECT theme FROM session_templates WHERE id = $1::int", {std::to_string(tid)});
            out["theme"] = txt(th[0]["theme"]);
        }
    }
    return out;
}

void SessionPlans::startEventEdit(long long fhEventId, long long personId) {
    const std::string ev = std::to_string(fhEventId);
    if (!db()->query("SELECT 1 FROM fh_event_sessions WHERE fh_event_id = $1::bigint", {ev}).empty()) return;
    json cur = eventSession(fhEventId);
    db()->query("INSERT INTO fh_event_sessions (fh_event_id, edited_by) VALUES ($1::bigint, NULLIF($2, '0')::int) "
                "ON CONFLICT DO NOTHING", {ev, std::to_string(personId)});
    int so = 10;
    for (const auto& it : cur["exercises"]) {
        db()->query("INSERT INTO fh_event_session_exercises (fh_event_id, exercise_id, sort_order, minutes, note) "
                    "VALUES ($1::bigint, $2::int, $3::int, NULLIF($4, '')::smallint, NULLIF($5, ''))",
                    {ev, std::to_string(it["exercise_id"].get<int>()), std::to_string(so),
                     it["minutes"].is_null() ? std::string() : std::to_string(it["minutes"].get<int>()),
                     it["note"].is_null() ? std::string() : it["note"].get<std::string>()});
        so += 10;
    }
}

void SessionPlans::resetEvent(long long fhEventId) {
    db()->query("DELETE FROM fh_event_sessions WHERE fh_event_id = $1::bigint", {std::to_string(fhEventId)});
}

int SessionPlans::addToEvent(long long fhEventId, int exerciseId, int minutes, long long personId) {
    startEventEdit(fhEventId, personId);
    const std::string ev = std::to_string(fhEventId);
    auto r = db()->query(
        "INSERT INTO fh_event_session_exercises (fh_event_id, exercise_id, sort_order, minutes) "
        "SELECT $1::bigint, $2::int, COALESCE(MAX(sort_order), 0) + 10, $3::smallint "
        "  FROM fh_event_session_exercises WHERE fh_event_id = $1::bigint RETURNING id",
        {ev, std::to_string(exerciseId), std::to_string(defaultMinutes(exerciseId, minutes))});
    db()->query("UPDATE fh_event_sessions SET updated_at = now(), edited_by = COALESCE(NULLIF($2, '0')::int, edited_by) "
                "WHERE fh_event_id = $1::bigint", {ev, std::to_string(personId)});
    return r[0]["id"].as<int>();
}
