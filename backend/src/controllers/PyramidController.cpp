#include "PyramidController.h"

#include <iostream>
#include <map>

#include "../database/Database.h"
#include "../models/WelcomeLog.h"
#include "../services/PyramidSync.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
json strOrNull(const pqxx::row& r, const char* c) { return r[c].is_null() ? json(nullptr) : json(std::string(r[c].c_str())); }
int num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0 : r[c].as<int>(); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

// The root and everything under it.
constexpr const char* kTreeCte = R"SQL(
    WITH RECURSIVE tr AS (
        SELECT c.* FROM pyramid_competitions c WHERE c.slug = $1 AND c.is_active
        UNION ALL
        SELECT c.* FROM pyramid_competitions c JOIN tr ON c.parent_id = tr.id WHERE c.is_active),
    -- A table counts toward the totals unless its source says not, and
    -- never when it hangs straight off the root league (APSL's cups).
    td AS (
        SELECT d.*, (d.counts AND tr.kind <> 'league') AS counted
          FROM pyramid_divisions d JOIN tr ON tr.id = d.competition_id
         WHERE d.removed_at IS NULL),
    tt AS (
        SELECT t.*, td.competition_id, td.counted
          FROM pyramid_teams t JOIN td ON td.id = t.division_id
         WHERE t.removed_at IS NULL)
)SQL";

constexpr const char* kNodesSql = R"SQL(
    SELECT tr.id, tr.parent_id, tr.kind, tr.tier, tr.name, tr.short_name, tr.region,
           tr.website_url, tr.standings_url, tr.sort_order,
           (SELECT string_agg(s.state_code, ',' ORDER BY s.state_code)
              FROM pyramid_competition_states s WHERE s.competition_id = tr.id) AS states,
           ps.system, ps.last_fetch_ok,
           to_char(ps.last_fetched_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM') AS read_at,
           to_char(ps.last_ok_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM') AS ok_at,
           ps.last_fetch_note,
           (SELECT count(DISTINCT tt.pyramid_club_id) FROM tt WHERE tt.competition_id = tr.id AND tt.counted) AS clubs,
           (SELECT count(*) FROM tt WHERE tt.competition_id = tr.id AND tt.counted) AS teams
      FROM tr
      LEFT JOIN LATERAL (SELECT * FROM pyramid_sources s WHERE s.competition_id = tr.id AND s.is_active
                          ORDER BY s.id LIMIT 1) ps ON true
     ORDER BY tr.tier, tr.sort_order, tr.name)SQL";

constexpr const char* kTablesSql = R"SQL(
    SELECT td.competition_id, td.id AS division_id, td.name AS division, td.counted,
           tt.position, tt.name, pc.name AS club, pc.club_id AS fh_club_id, tt.played, tt.wins, tt.draws, tt.losses,
           tt.goals_for, tt.goals_against, tt.goal_diff, tt.points
      FROM td
      JOIN tt ON tt.division_id = td.id
      JOIN pyramid_clubs pc ON pc.id = tt.pyramid_club_id
     ORDER BY td.competition_id, td.sort_order, td.name, tt.position NULLS LAST, tt.points DESC, tt.name)SQL";

constexpr const char* kTotalsSql = R"SQL(
    SELECT (SELECT count(*) FROM tr WHERE tr.kind IN ('league', 'affiliate'))           AS leagues,
           (SELECT count(DISTINCT pyramid_club_id) FROM tt WHERE counted)               AS clubs,
           (SELECT count(*) FROM tt WHERE counted)                                      AS teams,
           (SELECT count(DISTINCT s.state_code) FROM pyramid_competition_states s
              JOIN tr ON tr.id = s.competition_id)                                      AS states,
           (SELECT id FROM tr WHERE tr.slug = $1)                                       AS root_id)SQL";
} // namespace

PyramidController::PyramidController() {}

void PyramidController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleGet(r); });
}

Response PyramidController::handleGet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    try {
        std::string root = request.getQueryParam("root");
        if (root.empty()) root = "apsl";
        PyramidSync::refreshIfStale(request.getQueryParam("refresh") == "1");

        auto* db = Database::getInstance();
        const std::string cte = kTreeCte;
        auto tot = db->query(cte + kTotalsSql, {root});
        if (tot.empty() || tot[0]["root_id"].is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such pyramid");

        std::map<int, json> divisionsByNode;     // competition_id → [divisions]
        std::map<int, size_t> divIndex;          // division_id → index in its node's list
        for (const auto& r : db->query(cte + kTablesSql, {root})) {
            const int comp = num(r, "competition_id"), div = num(r, "division_id");
            json& list = divisionsByNode[comp];
            if (!list.is_array()) list = json::array();
            if (!divIndex.count(div)) {
                divIndex[div] = list.size();
                list.push_back({{"id", div}, {"name", str(r, "division")}, {"counts", r["counted"].as<bool>()}, {"teams", json::array()}});
            }
            list[divIndex[div]]["teams"].push_back({
                {"pos", r["position"].is_null() ? json(nullptr) : json(r["position"].as<int>())},
                {"name", str(r, "name")}, {"club", str(r, "club")},
                {"ours", !r["fh_club_id"].is_null() && r["fh_club_id"].as<int>() == WelcomeLog::kLighthouseClubId},
                {"gp", num(r, "played")}, {"w", num(r, "wins")}, {"d", num(r, "draws")}, {"l", num(r, "losses")},
                {"gf", num(r, "goals_for")}, {"ga", num(r, "goals_against")}, {"gd", num(r, "goal_diff")},
                {"pts", num(r, "points")}});
        }

        json nodes = json::array();
        for (const auto& r : db->query(cte + kNodesSql, {root})) {
            const int id = num(r, "id");
            json states = json::array();
            std::string st = str(r, "states");
            for (size_t p = 0; !st.empty() && p <= st.size();) {
                size_t c = st.find(',', p);
                states.push_back(st.substr(p, c == std::string::npos ? std::string::npos : c - p));
                if (c == std::string::npos) break;
                p = c + 1;
            }
            json source = nullptr;
            if (!r["system"].is_null()) {
                source = {{"system", str(r, "system")},
                          {"ok", r["last_fetch_ok"].is_null() ? json(nullptr) : json(r["last_fetch_ok"].as<bool>())},
                          {"read_at", strOrNull(r, "read_at")}, {"ok_at", strOrNull(r, "ok_at")},
                          {"note", strOrNull(r, "last_fetch_note")}};
            }
            nodes.push_back({{"id", id},
                             {"parent_id", r["parent_id"].is_null() ? json(nullptr) : json(r["parent_id"].as<int>())},
                             {"kind", str(r, "kind")}, {"tier", num(r, "tier")}, {"name", str(r, "name")},
                             {"short_name", strOrNull(r, "short_name")}, {"region", strOrNull(r, "region")},
                             {"website_url", strOrNull(r, "website_url")}, {"standings_url", strOrNull(r, "standings_url")},
                             {"states", states}, {"source", source},
                             {"clubs", num(r, "clubs")}, {"teams", num(r, "teams")},
                             {"divisions", divisionsByNode.count(id) ? divisionsByNode[id] : json::array()}});
        }
        return jsonOut(HttpStatus::OK, {
            {"root_id", num(tot[0], "root_id")},
            {"totals", {{"leagues", num(tot[0], "leagues")}, {"clubs", num(tot[0], "clubs")},
                        {"teams", num(tot[0], "teams")}, {"states", num(tot[0], "states")}}},
            {"nodes", nodes}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
