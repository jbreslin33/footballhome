#include "MatchPlanController.h"

#include <iostream>
#include <map>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"success", false}, {"error", message}}); }

std::string str(const pqxx::row& r, const char* k) { return r[k].is_null() ? std::string{} : std::string(r[k].c_str()); }

// "/api/match-plan/123" → 123.
long long eventIdFromPath(const std::string& path) {
    const std::string marker = "/match-plan/";
    const auto at = path.find(marker);
    if (at == std::string::npos) return 0;
    std::string rest = path.substr(at + marker.size());
    const auto cut = rest.find_first_of("/?");
    if (cut != std::string::npos) rest = rest.substr(0, cut);
    try { return std::stoll(rest); } catch (...) { return 0; }
}

struct Viewer { long long personId = 0; bool canRead = false; bool canEdit = false; };

// The account's person and what it may do on this game.
bool loadViewer(long long userId, long long eventId, Viewer* out) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT u.person_id,
               EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id
                        WHERE a.user_id = u.id AND al.name IN ('club','super')) AS is_admin,
               COALESCE(fh_match_plan_editor($2::bigint, u.person_id), false) AS editor,
               COALESCE(fh_match_plan_reader($2::bigint, u.person_id), false) AS reader
          FROM users u WHERE u.id = $1::int)SQL", {std::to_string(userId), std::to_string(eventId)});
    if (rows.empty() || rows[0]["person_id"].is_null()) return false;
    out->personId = rows[0]["person_id"].as<long long>();
    const bool admin = rows[0]["is_admin"].as<bool>();
    // Editing is the match_plan_editors list alone (mig 991) — no admin pass.
    out->canEdit = rows[0]["editor"].as<bool>();
    out->canRead = out->canEdit || admin || rows[0]["reader"].as<bool>();
    return true;
}

bool gate(long long userId, long long eventId, Viewer* v, Response* error) {
    if (eventId <= 0) { *error = jsonError(HttpStatus::BAD_REQUEST, "event id"); return false; }
    if (userId <= 0) { *error = jsonError(HttpStatus::UNAUTHORIZED, "sign in"); return false; }
    if (Database::getInstance()->query("SELECT 1 FROM fh_events WHERE id = $1::bigint AND kind = 'match'",
                                       {std::to_string(eventId)}).empty()) {
        *error = jsonError(HttpStatus::NOT_FOUND, "No such game.");
        return false;
    }
    if (!loadViewer(userId, eventId, v) || !v->canRead) {
        *error = jsonError(HttpStatus::FORBIDDEN, "The match plan is for people on this game.");
        return false;
    }
    return true;
}

// Splits a ", "-joined name list.
json splitNames(const std::string& all) {
    json out = json::array();
    std::string cur;
    for (size_t i = 0; i <= all.size(); ++i) {
        if (i == all.size() || all.compare(i, 2, ", ") == 0) {
            if (!cur.empty()) out.push_back(cur);
            cur.clear();
            if (i < all.size()) ++i;
        } else cur.push_back(all[i]);
    }
    return out;
}

json routineOf(const std::string& rid) {
    auto* db = Database::getInstance();
    auto r = db->query("SELECT title, source_url, level FROM warmup_routines WHERE id = $1::int", {rid});
    json routine = {{"title", str(r[0], "title")},
                    {"sourceUrl", r[0]["source_url"].is_null() ? json(nullptr) : json(str(r[0], "source_url"))},
                    {"level", r[0]["level"].is_null() ? json(nullptr) : json(r[0]["level"].as<int>())},
                    {"sections", json::array()}, {"teams", json::array()}};
    std::map<int, size_t> at;
    for (const auto& s : db->query(R"SQL(
        SELECT s.id, s.title, s.minutes, w.step_no, w.title AS step_title, w.sets_label, w.description
          FROM warmup_routine_sections s
          JOIN warmup_routines r ON r.id = s.routine_id
          LEFT JOIN warmup_steps w ON w.section_id = s.id
                                  AND (w.level IS NULL OR r.level IS NULL OR w.level = r.level)
         WHERE s.routine_id = $1::int
         ORDER BY s.sort_order, s.id, w.sort_order, w.id)SQL", {rid})) {
        const int sid = s["id"].as<int>();
        if (!at.count(sid)) {
            at[sid] = routine["sections"].size();
            routine["sections"].push_back({{"title", str(s, "title")},
                                           {"minutes", s["minutes"].is_null() ? json(nullptr) : json(s["minutes"].as<int>())},
                                           {"steps", json::array()}});
        }
        if (s["step_no"].is_null()) continue;
        routine["sections"][at[sid]]["steps"].push_back({{"no", s["step_no"].as<int>()}, {"title", str(s, "step_title")},
                                                         {"sets", str(s, "sets_label")}, {"description", str(s, "description")}});
    }
    // The sides of a game-shaped drill: shirt numbers (the lineup's
    // position numbers) + how many of the first bench players join.
    for (const auto& t : db->query(R"SQL(
        SELECT t.slug, t.title, t.bench_extras, t.bib_label, COALESCE(t.bib_color, '') AS bib_color,
               COALESCE((SELECT json_agg(n.shirt_no ORDER BY n.shirt_no) FROM warmup_routine_team_numbers n WHERE n.team_id = t.id), '[]'::json)::text AS numbers
          FROM warmup_routine_teams t WHERE t.routine_id = $1::int
         ORDER BY t.sort_order, t.id)SQL", {rid}))
        routine["teams"].push_back({{"slug", str(t, "slug")}, {"title", str(t, "title")},
                                    {"benchExtras", t["bench_extras"].as<int>()},
                                    {"bib", str(t, "bib_label")}, {"bibColor", str(t, "bib_color")}, {"numbers", json::parse(str(t, "numbers"))}});
    return routine;
}

// The match-day timeline: every active stage in order, the time it is
// pinned to, who leads it (holders of its job), its routine (the
// league's, else every league's) and, for a checklist stage, its items
// with the viewer's own ticks.
json stagesOf(long long eventId, long long personId) {
    auto* db = Database::getInstance();
    const std::string eid = std::to_string(eventId), pid = std::to_string(personId);
    json stages = json::array();
    for (const auto& p : db->query(R"SQL(
        SELECT st.id, st.slug, st.title, st.description, st.minutes,
               CASE st.time_key
                    WHEN 'arrival' THEN to_char(fe.arrival_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM')
                    WHEN 'warmup'  THEN to_char(fe.warmup_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM')
                    WHEN 'kickoff' THEN to_char(fe.kickoff_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM')
               END AS time_label,
               st.job_slug IS NOT NULL AS has_job,
               (SELECT r.id FROM warmup_routines r
                 WHERE r.stage_id = st.id AND r.is_active
                   AND (r.league_label IS NULL OR r.league_label = fe.league)
                 ORDER BY (r.league_label IS NULL), r.id LIMIT 1) AS routine_id,
               (SELECT string_agg(BTRIM(COALESCE(pe.first_name,'') || ' ' || COALESCE(pe.last_name,'')), ', ' ORDER BY ja.id)
                  FROM job_assignments ja
                  JOIN job_definitions d ON d.id = ja.job_definition_id AND d.slug = st.job_slug
                  JOIN persons pe ON pe.id = ja.person_id
                 WHERE ja.fh_event_id = fe.id) AS leaders
          FROM match_day_stages st CROSS JOIN fh_events fe
         WHERE fe.id = $1::bigint AND st.is_active
         ORDER BY st.sort_order, st.id)SQL", {eid})) {
        json stage = {{"slug", str(p, "slug")}, {"title", str(p, "title")}, {"description", str(p, "description")},
                      {"minutes", p["minutes"].is_null() ? json(nullptr) : json(p["minutes"].as<int>())},
                      {"time", str(p, "time_label")}, {"hasJob", p["has_job"].as<bool>()},
                      {"leaders", splitNames(str(p, "leaders"))}, {"routine", nullptr}, {"checklist", json::array()}};
        if (!p["routine_id"].is_null()) stage["routine"] = routineOf(p["routine_id"].c_str());
        for (const auto& c : db->query(R"SQL(
            SELECT i.id, i.title,
                   EXISTS (SELECT 1 FROM event_checklist_ticks k
                            WHERE k.fh_event_id = $2::bigint AND k.item_id = i.id AND k.person_id = $3::int) AS ticked
              FROM match_day_checklist_items i
             WHERE i.stage_id = $1::int AND i.is_active
             ORDER BY i.sort_order, i.id)SQL", {p["id"].c_str(), eid, pid}))
            stage["checklist"].push_back({{"id", c["id"].as<int>()}, {"title", str(c, "title")}, {"ticked", c["ticked"].as<bool>()}});
        stages.push_back(stage);
    }
    return stages;
}

// The game whose picks show: this one if it has any, else the latest
// earlier game sharing a team that has some.
json setPiecesOf(long long eventId) {
    auto* db = Database::getInstance();
    const std::string eid = std::to_string(eventId);
    long long sourceId = eventId;
    json inheritedFrom = nullptr;
    if (db->query("SELECT 1 FROM event_set_piece_picks WHERE fh_event_id = $1::bigint LIMIT 1", {eid}).empty()) {
        auto prev = db->query(R"SQL(
            SELECT e.id, to_char(g.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS when_label
              FROM fh_events e
              JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL
             WHERE e.kind = 'match' AND e.id <> $1::bigint
               AND EXISTS (SELECT 1 FROM event_set_piece_picks k WHERE k.fh_event_id = e.id)
               AND EXISTS (SELECT 1 FROM fh_event_teams a JOIN fh_event_teams b ON b.team_id = a.team_id
                            WHERE a.fh_event_id = e.id AND b.fh_event_id = $1::bigint)
               AND g.starts_at < COALESCE((SELECT g2.starts_at FROM fh_events e2 JOIN gcal_events g2 ON g2.id = e2.gcal_event_id
                                            WHERE e2.id = $1::bigint), now())
             ORDER BY g.starts_at DESC LIMIT 1)SQL", {eid});
        if (!prev.empty()) { sourceId = prev[0]["id"].as<long long>(); inheritedFrom = str(prev[0], "when_label"); }
    }
    json groups = json::array();
    std::map<int, size_t> gAt;
    std::map<int, std::pair<size_t, size_t>> rAt;
    for (const auto& r : db->query(R"SQL(
        SELECT g.id AS group_id, g.slug AS group_slug, g.title AS group_title,
               r.id, r.title, r.description, r.needed_count
          FROM set_piece_roles r JOIN set_piece_groups g ON g.id = r.group_id
         WHERE r.is_active
         ORDER BY g.sort_order, g.id, r.sort_order, r.id)SQL")) {
        const int gid = r["group_id"].as<int>();
        if (!gAt.count(gid)) {
            gAt[gid] = groups.size();
            groups.push_back({{"slug", str(r, "group_slug")}, {"title", str(r, "group_title")}, {"roles", json::array()}});
        }
        json& roles = groups[gAt[gid]]["roles"];
        rAt[r["id"].as<int>()] = {gAt[gid], roles.size()};
        roles.push_back({{"id", r["id"].as<int>()}, {"title", str(r, "title")}, {"description", str(r, "description")},
                         {"needed", r["needed_count"].as<int>()}, {"picks", json::array()}});
    }
    for (const auto& p : db->query(R"SQL(
        SELECT k.set_piece_role_id, k.slot, k.person_id,
               BTRIM(COALESCE(pe.first_name,'') || ' ' || COALESCE(pe.last_name,'')) AS name
          FROM event_set_piece_picks k JOIN persons pe ON pe.id = k.person_id
         WHERE k.fh_event_id = $1::bigint
         ORDER BY k.set_piece_role_id, k.slot)SQL", {std::to_string(sourceId)})) {
        auto it = rAt.find(p["set_piece_role_id"].as<int>());
        if (it == rAt.end()) continue;
        groups[it->second.first]["roles"][it->second.second]["picks"].push_back(
            {{"slot", p["slot"].as<int>()}, {"personId", p["person_id"].as<long long>()}, {"name", str(p, "name")}});
    }
    return {{"groups", groups}, {"inheritedFrom", inheritedFrom}};
}

}  // namespace

void MatchPlanController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/:fhEventId", [this](const Request& r) { return handleGet(r); });
    router.post(prefix + "/:fhEventId", [this](const Request& r) { return handleSave(r); });
    router.post(prefix + "/:fhEventId/tick", [this](const Request& r) { return handleTick(r); });
}

Response MatchPlanController::handleGet(const Request& request) {
    const long long eventId = eventIdFromPath(request.getPath());
    Viewer v; Response error(HttpStatus::OK, "");
    try {
        if (!gate(bearerUserId(request), eventId, &v, &error)) return error;
        auto* db = Database::getInstance();
        const std::string eid = std::to_string(eventId);
        auto ev = db->query(R"SQL(
            SELECT to_char(fe.arrival_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS arrival,
                   to_char(fe.warmup_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS warmup,
                   to_char(fe.kickoff_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS kickoff,
                   COALESCE(mp.tactics, '') AS tactics
              FROM fh_events fe LEFT JOIN event_match_plans mp ON mp.fh_event_id = fe.id
             WHERE fe.id = $1::bigint)SQL", {eid});
        json out = {{"success", true}, {"canEdit", v.canEdit},
                    {"times", {{"arrival", str(ev[0], "arrival")}, {"warmup", str(ev[0], "warmup")}, {"kickoff", str(ev[0], "kickoff")}}},
                    {"stages", stagesOf(eventId, v.personId)}, {"setPieces", setPiecesOf(eventId)}, {"tactics", str(ev[0], "tactics")}};
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/match-plan] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response MatchPlanController::handleSave(const Request& request) {
    const long long eventId = eventIdFromPath(request.getPath());
    Viewer v; Response error(HttpStatus::OK, "");
    try {
        if (!gate(bearerUserId(request), eventId, &v, &error)) return error;
        if (!v.canEdit) return jsonError(HttpStatus::FORBIDDEN, "Only the match plan editors change it.");
        json body;
        try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
        catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
        if (!body.is_object()) return jsonError(HttpStatus::BAD_REQUEST, "body");

        // Keep only well-formed picks; the SQL drops slots past a role's
        // needed_count and a person picked twice in one role.
        json picks = json::array();
        if (body.contains("picks") && body["picks"].is_array())
            for (const auto& p : body["picks"]) {
                if (!p.is_object() || !p.contains("roleId") || !p.contains("slot") || !p.contains("personId")) continue;
                if (!p["roleId"].is_number_integer() || !p["slot"].is_number_integer() || !p["personId"].is_number_integer()) continue;
                picks.push_back({{"role_id", p["roleId"]}, {"slot", p["slot"]}, {"person_id", p["personId"]}});
            }
        const std::string tactics = body.contains("tactics") && body["tactics"].is_string() ? body["tactics"].get<std::string>() : "";

        auto* db = Database::getInstance();
        const std::string eid = std::to_string(eventId), pid = std::to_string(v.personId);
        // One statement: the delete and the upsert touch disjoint
        // (role, slot) keys, so the game never sits half-saved.
        db->query(R"SQL(
            WITH incoming AS (
                SELECT DISTINCT ON (x.role_id, x.person_id) x.role_id, x.slot, x.person_id
                  FROM json_to_recordset($2::json) AS x(role_id int, slot int, person_id int)
                  JOIN set_piece_roles r ON r.id = x.role_id AND r.is_active AND x.slot BETWEEN 1 AND r.needed_count
                  JOIN persons pe ON pe.id = x.person_id
                 ORDER BY x.role_id, x.person_id, x.slot),
            gone AS (
                DELETE FROM event_set_piece_picks k
                 WHERE k.fh_event_id = $1::bigint
                   AND NOT EXISTS (SELECT 1 FROM incoming i WHERE i.role_id = k.set_piece_role_id AND i.slot = k.slot))
            INSERT INTO event_set_piece_picks (fh_event_id, set_piece_role_id, slot, person_id, picked_by)
            SELECT $1::bigint, i.role_id, i.slot, i.person_id, $3::int FROM incoming i
            ON CONFLICT (fh_event_id, set_piece_role_id, slot)
            DO UPDATE SET person_id = EXCLUDED.person_id, picked_by = EXCLUDED.picked_by, picked_at = now()
             WHERE event_set_piece_picks.person_id IS DISTINCT FROM EXCLUDED.person_id)SQL",
            {eid, picks.dump(), pid});
        db->query(R"SQL(
            INSERT INTO event_match_plans (fh_event_id, tactics, updated_by, updated_at)
            VALUES ($1::bigint, $2, $3::int, now())
            ON CONFLICT (fh_event_id) DO UPDATE SET tactics = EXCLUDED.tactics, updated_by = EXCLUDED.updated_by, updated_at = now()
             WHERE event_match_plans.tactics IS DISTINCT FROM EXCLUDED.tactics)SQL", {eid, tactics, pid});
        return handleGet(request);
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/match-plan] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

// A player's own tick on a checklist item: { itemId, ticked }.
Response MatchPlanController::handleTick(const Request& request) {
    const long long eventId = eventIdFromPath(request.getPath());
    Viewer v; Response error(HttpStatus::OK, "");
    try {
        if (!gate(bearerUserId(request), eventId, &v, &error)) return error;
        json body;
        try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
        catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
        if (!body.is_object() || !body.contains("itemId") || !body["itemId"].is_number_integer())
            return jsonError(HttpStatus::BAD_REQUEST, "itemId");
        const bool ticked = body.contains("ticked") && body["ticked"].is_boolean() ? body["ticked"].get<bool>() : true;
        auto* db = Database::getInstance();
        const std::string eid = std::to_string(eventId), item = std::to_string(body["itemId"].get<long long>()),
                          pid = std::to_string(v.personId);
        if (ticked)
            db->query(R"SQL(
                INSERT INTO event_checklist_ticks (fh_event_id, item_id, person_id)
                SELECT $1::bigint, i.id, $3::int FROM match_day_checklist_items i WHERE i.id = $2::int AND i.is_active
                ON CONFLICT DO NOTHING)SQL", {eid, item, pid});
        else
            db->query("DELETE FROM event_checklist_ticks WHERE fh_event_id = $1::bigint AND item_id = $2::int AND person_id = $3::int",
                      {eid, item, pid});
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/match-plan/tick] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
