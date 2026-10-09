#include "RosterSheetController.h"

#include <iostream>
#include <regex>
#include <string>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
long long tailId(const std::string& path, const char* re) {
    std::smatch m; const std::regex rx(re);
    return std::regex_search(path, m, rx) ? std::stoll(m[1].str()) : 0;
}
// Coaches of a team with role and roster status, head first, then by role
// order and when they started.
json coachesOf(Database* db, long long teamId, bool onRosterOnly) {
    json out = json::array();
    int assistantN = 0;
    for (const auto& r : db->query(R"SQL(
        SELECT p.id AS person_id, COALESCE(p.first_name,'') AS first_name, COALESCE(p.last_name,'') AS last_name,
               cr.name AS role, cr.description AS role_desc, cr.sort_order AS role_order,
               rs.code AS status, rs.display_name AS status_label, COALESCE(rs.counts_as_on_roster, false) AS on_roster,
               (SELECT e.email FROM person_emails e WHERE e.person_id = p.id ORDER BY e.is_primary DESC NULLS LAST, e.id LIMIT 1) AS email,
               (SELECT x.phone_number FROM person_phones x WHERE x.person_id = p.id ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS phone
          FROM team_coaches tc
          JOIN coaches c ON c.id = tc.coach_id
          JOIN persons p ON p.id = c.person_id
          LEFT JOIN coach_roles cr ON cr.id = tc.coach_role_id
          LEFT JOIN roster_statuses rs ON rs.id = tc.roster_status_id
         WHERE tc.team_id = $1::int AND tc.ended_at IS NULL
         ORDER BY (rs.id IS NULL), cr.sort_order NULLS LAST, tc.started_at, p.last_name, p.first_name)SQL", {std::to_string(teamId)})) {
        const bool onRoster = r["on_roster"].as<bool>() || str(r, "status") == "on_roster";
        if (onRosterOnly && !onRoster) continue;
        const std::string role = str(r, "role");
        std::string label = "Coach";
        if (role == "head") label = "Coach (Primary)";
        else if (role == "assistant") label = "Coach (Assistant " + std::to_string(++assistantN) + ")";
        else if (!role.empty()) label = str(r, "role_desc");
        out.push_back({{"person_id", r["person_id"].as<long long>()}, {"first_name", str(r, "first_name")}, {"last_name", str(r, "last_name")},
                       {"name", str(r, "last_name") + ", " + str(r, "first_name")}, {"role", role}, {"role_label", label},
                       {"status", str(r, "status")}, {"status_label", str(r, "status_label")}, {"on_roster", onRoster},
                       {"email", str(r, "email")}, {"phone", str(r, "phone")}});
    }
    return out;
}
} // namespace

void RosterSheetController::registerRoutes(Router& router, const std::string& prefix) {
    (void)prefix;
    router.get("/api/roster-sheet/:matchId", [this](const Request& r) { return handleSheet(r); });
    router.get("/api/team-coaches/:teamId", [this](const Request& r) { return handleCoaches(r); });
    router.put("/api/team-coaches/:teamId/:personId", [this](const Request& r) { return handlePutCoach(r); });
}

// GET /api/roster-sheet/:matchId
Response RosterSheetController::handleSheet(const Request& request) {
    const long long matchId = tailId(request.getPath(), "/api/roster-sheet/(\\d+)");
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        // The game: its tagged team(s) — the first by board order is the
        // sheet's team — opponent, time, venue.
        auto g = db->query(R"SQL(
            SELECT fe.id AS fh_event_id, COALESCE(NULLIF(BTRIM(fe.opponent), ''), 'TBD') AS opponent, fe.is_home, fe.league,
                   to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, YYYY FMHH12:MI AM') AS when_text,
                   split_part(COALESCE(ge.location, ''), ',', 1) AS venue,
                   (SELECT fet.team_id FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id WHERE fet.fh_event_id = fe.id ORDER BY t.board_sort_order NULLS LAST, t.id LIMIT 1) AS team_id
              FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
             WHERE fe.match_id = $1::int ORDER BY fe.id LIMIT 1)SQL", {std::to_string(matchId)});
        long long teamId = 0; json match;
        if (!g.empty() && !g[0]["team_id"].is_null()) {
            teamId = g[0]["team_id"].as<long long>();
            match = {{"opponent", str(g[0], "opponent")}, {"is_home", g[0]["is_home"].is_null() ? json(nullptr) : json(g[0]["is_home"].as<bool>())},
                     {"when_text", str(g[0], "when_text")}, {"venue", str(g[0], "venue")}, {"league", str(g[0], "league")}};
        } else {
            auto m = db->query("SELECT home_team_id, away_team_id FROM matches WHERE id = $1::int", {std::to_string(matchId)});
            if (m.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such game");
            auto pick = db->query("SELECT id FROM teams WHERE id IN ($1::int, $2::int) AND club_id = 134 ORDER BY board_sort_order NULLS LAST LIMIT 1",
                                  {m[0]["home_team_id"].is_null() ? "0" : m[0]["home_team_id"].c_str(), m[0]["away_team_id"].is_null() ? "0" : m[0]["away_team_id"].c_str()});
            if (pick.empty()) return jsonError(HttpStatus::NOT_FOUND, "no Lighthouse team on this game");
            teamId = pick[0]["id"].as<long long>();
            match = {{"opponent", ""}, {"is_home", nullptr}, {"when_text", ""}, {"venue", ""}, {"league", ""}};
        }
        // Who may see it: admins, the team's coaches, anyone on its roster.
        auto ok = db->query(R"SQL(
            SELECT EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id WHERE a.user_id = u.id AND al.name IN ('club','super'))
                OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id WHERE co.person_id = u.person_id AND tc.ended_at IS NULL AND tc.team_id = $2::int)
                OR EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = u.person_id AND tp.removed_at IS NULL AND tp.team_id = $2::int) AS allowed
              FROM users u WHERE u.id = $1::int)SQL", {std::to_string(userId), std::to_string(teamId)});
        if (ok.empty() || !ok[0]["allowed"].as<bool>()) return jsonError(HttpStatus::FORBIDDEN, "The roster sheet is for this game's team.");

        auto t = db->query(R"SQL(
            SELECT t.id, COALESCE(t.label, t.name) AS label, t.name, t.gender_category, t.is_travel,
                   s.roster_title, s.club_name, s.team_name, s.association, s.season_label, s.official_label, s.level, s.gender_label,
                   s.external_team_id, s.division, s.color
              FROM teams t LEFT JOIN team_roster_sheets s ON s.team_id = t.id WHERE t.id = $1::int)SQL", {std::to_string(teamId)});
        const auto& tr = t[0];
        std::string age; { std::smatch m; static const std::regex re("U(\\d{1,2})"); const std::string lbl = str(tr, "label"); if (std::regex_search(lbl, m, re)) age = "U" + m[1].str(); }
        json team = {{"id", teamId}, {"label", str(tr, "label")}, {"age", age},
                     {"roster_title", str(tr, "roster_title")}, {"club_name", str(tr, "club_name")}, {"team_name", str(tr, "team_name").empty() ? str(tr, "label") : str(tr, "team_name")},
                     {"association", str(tr, "association")}, {"season_label", str(tr, "season_label")}, {"official_label", str(tr, "official_label")},
                     {"level", str(tr, "level").empty() ? (tr["is_travel"].is_null() ? "" : (tr["is_travel"].as<bool>() ? "Travel" : "Intramural")) : str(tr, "level")},
                     {"gender", str(tr, "gender_label").empty() ? (str(tr, "gender_category") == "boys" ? "Male" : str(tr, "gender_category") == "girls" ? "Female" : "") : str(tr, "gender_label")},
                     {"external_team_id", str(tr, "external_team_id")}, {"division", str(tr, "division")}, {"color", str(tr, "color")}};

        json players = json::array(); int n = 0;
        for (const auto& r : db->query(R"SQL(
            SELECT p.id AS person_id, COALESCE(p.first_name,'') AS first_name, COALESCE(p.last_name,'') AS last_name,
                   to_char(p.birth_date, 'YYYY') AS birthyear, to_char(p.birth_date, 'FMMM/FMDD/YYYY') AS dob,
                   to_char(tp.joined_at AT TIME ZONE 'America/New_York', 'FMMM/FMDD/YY') AS assigned,
                   (SELECT n.jersey_number FROM person_uniform_numbers n WHERE n.uniform_set_id = team_uniform_set_id($1::int) AND n.person_id = p.id LIMIT 1) AS jersey,
                   rs.code AS status,
                   EXISTS (SELECT 1 FROM match_lineups ml JOIN players pl ON pl.id = ml.player_id WHERE ml.match_id = $2::int AND pl.person_id = p.id AND ml.is_starter) AS starter,
                   EXISTS (SELECT 1 FROM match_lineups ml JOIN players pl ON pl.id = ml.player_id WHERE ml.match_id = $2::int AND pl.person_id = p.id AND NOT ml.is_starter) AS bench
              FROM team_persons tp JOIN persons p ON p.id = tp.person_id
              LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
             WHERE tp.team_id = $1::int AND tp.removed_at IS NULL
               AND (tp.roster_status_id IS NULL OR COALESCE(rs.show_in_official_roster, true))
             ORDER BY p.last_name, p.first_name)SQL", {std::to_string(teamId), std::to_string(matchId)})) {
            players.push_back({{"n", ++n}, {"person_id", r["person_id"].as<long long>()}, {"first_name", str(r, "first_name")}, {"last_name", str(r, "last_name")},
                               {"name", str(r, "last_name") + ", " + str(r, "first_name")}, {"jersey", str(r, "jersey")}, {"birthyear", str(r, "birthyear")}, {"dob", str(r, "dob")},
                               {"assigned", str(r, "assigned")}, {"status", str(r, "status")}, {"starter", r["starter"].as<bool>()}, {"bench", r["bench"].as<bool>()}});
        }
        auto now = db->query("SELECT to_char(now() AT TIME ZONE 'America/New_York', 'FMMM/FMDD/YYYY FMHH12:MI AM') AS t");
        return jsonOut(HttpStatus::OK, {{"match_id", matchId}, {"match", match}, {"team", team}, {"coaches", coachesOf(db, teamId, true)}, {"players", players},
                                        {"printed_at", now.empty() ? "" : str(now[0], "t")}});
    } catch (const std::exception& e) { std::cerr << "[roster-sheet] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// GET /api/team-coaches/:teamId — every current coach with role and status.
Response RosterSheetController::handleCoaches(const Request& request) {
    const long long teamId = tailId(request.getPath(), "/api/team-coaches/(\\d+)");
    if (teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "team id");
    if (bearerUserId(request) <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        json roles = json::array();
        for (const auto& r : db->query("SELECT name, description FROM coach_roles ORDER BY sort_order, id"))
            roles.push_back({{"name", str(r, "name")}, {"label", str(r, "description")}});
        return jsonOut(HttpStatus::OK, {{"team_id", teamId}, {"coaches", coachesOf(db, teamId, false)}, {"roles", roles}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// PUT /api/team-coaches/:teamId/:personId { rosterStatus, coachRole }
Response RosterSheetController::handlePutCoach(const Request& request) {
    std::smatch m; static const std::regex re("/api/team-coaches/(\\d+)/(\\d+)");
    const std::string path = request.getPath();
    if (!std::regex_search(path, m, re)) return jsonError(HttpStatus::BAD_REQUEST, "team id and person id");
    const long long teamId = std::stoll(m[1].str()), personId = std::stoll(m[2].str());
    if (bearerUserId(request) <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    if (!canManageTeam(request, (int)teamId)) return jsonError(HttpStatus::FORBIDDEN, "Only a coach of this team or a club admin can set a coach's roster status.");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    try {
        auto* db = Database::getInstance();
        if (body.contains("rosterStatus")) {
            const std::string code = body["rosterStatus"].is_string() ? body["rosterStatus"].get<std::string>() : "";
            if (!code.empty() && db->query("SELECT 1 FROM roster_statuses WHERE code = $1 AND is_active", {code}).empty()) return jsonError(HttpStatus::BAD_REQUEST, "no such status");
            db->query("UPDATE team_coaches tc SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = NULLIF($3,'')) "
                      "  FROM coaches c WHERE c.id = tc.coach_id AND tc.team_id = $1::int AND c.person_id = $2::int AND tc.ended_at IS NULL",
                      {std::to_string(teamId), std::to_string(personId), code});
        }
        if (body.contains("coachRole")) {
            const std::string role = body["coachRole"].is_string() ? body["coachRole"].get<std::string>() : "";
            if (!role.empty() && db->query("SELECT 1 FROM coach_roles WHERE name = $1", {role}).empty()) return jsonError(HttpStatus::BAD_REQUEST, "no such role");
            db->query("UPDATE team_coaches tc SET coach_role_id = (SELECT id FROM coach_roles WHERE name = NULLIF($3,'')) "
                      "  FROM coaches c WHERE c.id = tc.coach_id AND tc.team_id = $1::int AND c.person_id = $2::int AND tc.ended_at IS NULL",
                      {std::to_string(teamId), std::to_string(personId), role});
        }
        return jsonOut(HttpStatus::OK, {{"team_id", teamId}, {"coaches", coachesOf(db, teamId, false)}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
