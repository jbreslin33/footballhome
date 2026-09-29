#include "LineupDraftController.h"

#include <iostream>

#include "../database/Database.h"

using nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"success", false}, {"error", message}, {"message", message}}); }
long long idFromPath(const std::string& path) {
    // /api/lineup-drafts/<id>[/mine]
    auto p = path.find("/lineup-drafts/"); if (p == std::string::npos) return 0;
    p += 15; auto e = path.find('/', p);
    try { return std::stoll(path.substr(p, e == std::string::npos ? std::string::npos : e - p)); } catch (...) { return 0; }
}
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
} // namespace

void LineupDraftController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/:matchId",      [this](const Request& r) { return handleGet(r); });
    router.put(prefix + "/:matchId/mine", [this](const Request& r) { return handlePutMine(r); });
}

// Who is asking and what they may do for this game's teams.
LineupDraftController::Access LineupDraftController::access(const Request& request, long long matchId) {
    Access a; a.userId = bearerUserId(request);
    if (a.userId <= 0) return a;
    auto* db = Database::getInstance();
    const std::string uid = std::to_string(a.userId), mid = std::to_string(matchId);
    auto rows = db->query(R"SQL(
        WITH teams_of AS (
            SELECT COALESCE(
                (SELECT array_agg(DISTINCT fet.team_id) FROM fh_events fe JOIN fh_event_teams fet ON fet.fh_event_id = fe.id WHERE fe.match_id = $2::int),
                (SELECT array_remove(ARRAY[m.home_team_id, m.away_team_id], NULL) FROM matches m WHERE m.id = $2::int)) AS ids
        )
        SELECT u.person_id, t.ids AS team_ids,
               EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id WHERE a.user_id = u.id AND al.name IN ('club','super')) AS is_admin,
               EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
                        WHERE co.person_id = u.person_id AND tc.ended_at IS NULL AND tc.team_id = ANY(t.ids)) AS is_coach,
               EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = u.person_id AND tp.removed_at IS NULL
                          AND tp.team_id = ANY(t.ids)) AS is_drafter   -- on the roster (mig 496)
          FROM users u CROSS JOIN teams_of t WHERE u.id = $1::int)SQL", {uid, mid});
    if (rows.empty()) return a;
    a.personId = rows[0]["person_id"].is_null() ? 0 : rows[0]["person_id"].as<long long>();
    a.coach = rows[0]["is_admin"].as<bool>() || rows[0]["is_coach"].as<bool>();
    a.drafter = rows[0]["is_drafter"].as<bool>();
    a.teamIds = str(rows[0], "team_ids");
    return a;
}

Response LineupDraftController::handleGet(const Request& request) {
    const long long matchId = idFromPath(request.getPath());
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match id");
    try {
        Access a = access(request, matchId);
        if (a.userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
        if (!a.coach && !a.drafter) return jsonError(HttpStatus::FORBIDDEN, "no draft access for this game");
        auto* db = Database::getInstance();
        const std::string mid = std::to_string(matchId);
        json out = {{"success", true}, {"canDraft", true}, {"viewerPersonId", a.personId}, {"isCoach", a.coach}, {"drafters", json::array()}, {"drafts", json::array()}};
        // A pill each for the viewer and for everyone who has started a draft
        // (mig 496: any rostered player may, so only started drafts are listed).
        for (const auto& r : db->query(R"SQL(
            SELECT p.id, p.first_name || ' ' || p.last_name AS name, p.first_name, p.last_name
              FROM persons p
             WHERE p.id = $2::int OR p.id IN (SELECT author_person_id FROM match_lineup_drafts WHERE match_id = $1::int)
             ORDER BY (p.id = $2::int) DESC, p.last_name, p.first_name)SQL", {mid, std::to_string(a.personId)}))
            out["drafters"].push_back({{"personId", r["id"].as<long long>()}, {"name", str(r, "name")}, {"firstName", str(r, "first_name")}, {"mine", r["id"].as<long long>() == a.personId}});
        for (const auto& d : db->query(R"SQL(
            SELECT d.id, d.author_person_id, p.first_name || ' ' || p.last_name AS name, p.first_name,
                   f.code AS formation_code, to_char(d.updated_at AT TIME ZONE 'America/New_York', 'Mon FMDD, FMHH12:MI AM') AS updated_label
              FROM match_lineup_drafts d JOIN persons p ON p.id = d.author_person_id LEFT JOIN formations f ON f.id = d.formation_id
             WHERE d.match_id = $1::int ORDER BY p.last_name, p.first_name)SQL", {mid})) {
            json rows = json::array();
            for (const auto& r : db->query("SELECT player_id, zone, position_id, slot_number FROM match_lineup_draft_rows WHERE draft_id = $1::int ORDER BY zone, slot_number, player_id", {std::string(d["id"].c_str())}))
                rows.push_back({{"playerId", r["player_id"].as<long long>()}, {"zone", str(r, "zone")},
                                {"positionId", r["position_id"].is_null() ? json(nullptr) : json(r["position_id"].as<long long>())},
                                {"slotNumber", r["slot_number"].is_null() ? json(nullptr) : json(r["slot_number"].as<long long>())}});
            const long long author = d["author_person_id"].as<long long>();
            out["drafts"].push_back({{"id", d["id"].as<long long>()}, {"authorPersonId", author}, {"authorName", str(d, "name")}, {"firstName", str(d, "first_name")},
                                     {"mine", author == a.personId}, {"formationCode", d["formation_code"].is_null() ? json(nullptr) : json(str(d, "formation_code"))},
                                     {"updatedAt", str(d, "updated_label")}, {"rows", rows}});
        }
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[lineup-drafts get] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response LineupDraftController::handlePutMine(const Request& request) {
    const long long matchId = idFromPath(request.getPath());
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match id");
    json body;
    try { body = json::parse(request.getBody()); } catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    try {
        Access a = access(request, matchId);
        if (a.userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
        if (!a.coach && !a.drafter) return jsonError(HttpStatus::FORBIDDEN, "no draft access for this game");
        if (a.personId <= 0) return jsonError(HttpStatus::FORBIDDEN, "your login has no person");
        auto* db = Database::getInstance();
        const std::string mid = std::to_string(matchId), pid = std::to_string(a.personId);
        const long long formationId = body.value("formationId", 0LL);
        // First team of the game, for the record.
        std::string teamId;
        { auto t = db->query("SELECT (array_remove(ARRAY[m.home_team_id, m.away_team_id], NULL))[1] AS t FROM matches m WHERE m.id = $1::int", {mid}); if (!t.empty()) teamId = str(t[0], "t"); }
        auto up = db->query(R"SQL(
            INSERT INTO match_lineup_drafts (match_id, team_id, author_person_id, formation_id, updated_at)
            VALUES ($1::int, NULLIF($2,'')::int, $3::int, NULLIF($4,'0')::int, now())
            ON CONFLICT (match_id, author_person_id) DO UPDATE SET
                formation_id = COALESCE(NULLIF($4,'0')::int, match_lineup_drafts.formation_id), updated_at = now()
            RETURNING id)SQL", {mid, teamId, pid, std::to_string(formationId)});
        const std::string did = std::string(up[0]["id"].c_str());
        db->query("DELETE FROM match_lineup_draft_rows WHERE draft_id = $1::int", {did});
        auto put = [&](const json& arr, const char* zone) {
            if (!arr.is_array()) return;
            for (const auto& r : arr) {
                if (!r.is_object() || !r.contains("playerId")) continue;
                const long long playerId = r["playerId"].is_number() ? r["playerId"].get<long long>() : std::stoll(r["playerId"].get<std::string>());
                const std::string pos = r.contains("positionId") && r["positionId"].is_number() ? std::to_string(r["positionId"].get<long long>()) : "";
                const std::string slot = r.contains("slotNumber") && r["slotNumber"].is_number() ? std::to_string(r["slotNumber"].get<long long>()) : "";
                db->query("INSERT INTO match_lineup_draft_rows (draft_id, player_id, zone, position_id, slot_number) VALUES ($1::int, $2::int, $3, NULLIF($4,'')::int, NULLIF($5,'')::int) "
                          "ON CONFLICT (draft_id, player_id) DO UPDATE SET zone = EXCLUDED.zone, position_id = EXCLUDED.position_id, slot_number = EXCLUDED.slot_number",
                          {did, std::to_string(playerId), zone, pos, slot});
            }
        };
        put(body.value("starters", json::array()), "starter");
        put(body.value("bench", json::array()), "bench");
        put(body.value("alternates", json::array()), "alternate");
        return jsonOut(HttpStatus::OK, {{"success", true}, {"draftId", std::stoll(did)}});
    } catch (const std::exception& e) { std::cerr << "[lineup-drafts put] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
