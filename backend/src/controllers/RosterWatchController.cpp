#include "RosterWatchController.h"

#include <iostream>

#include "../database/Database.h"
#include "../services/RosterWatchSync.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}  // namespace

void RosterWatchController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix,               [this](const Request& r) { return handleGet(r); });
    router.post(prefix + "/refresh", [this](const Request& r) { return handleRefresh(r); });
    router.post(prefix + "/paste",        [this](const Request& r) { return handlePaste(r); });
    router.post(prefix + "/paste/remove", [this](const Request& r) { return handlePasteRemove(r); });
}

Response RosterWatchController::handleGet(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    RosterWatchSync::startIfStale();
    try {
        // A name key with no space is one word ("Junior") — not a person we can tell apart.
        auto rows = Database::getInstance()->query(R"SQL(
          WITH e AS MATERIALIZED (
            SELECT * FROM roster_watch_entries WHERE name_key ~ '^\S+ \S'
          ), g AS (
            SELECT name_key, count(DISTINCT team_ref) AS n_teams, count(DISTINCT club_key) AS n_clubs, count(DISTINCT dob) AS n_dobs
              FROM e GROUP BY name_key HAVING count(DISTINCT team_ref) >= 2
          ), paged AS (
            SELECT CASE WHEN cm.kind = 'conference' THEN 'APSL' ELSE coalesce(cm.short_name, cm.name) END AS label,
                   min(cm.sort_order) FILTER (WHERE cm.kind <> 'conference') AS ord,
                   count(*) AS teams, count(t.people_fetched_at) AS read, min(t.people_fetched_at) AS at,
                   (SELECT count(*) FROM pyramid_team_people p WHERE p.kind = 'player' AND p.team_id = ANY (array_agg(t.id))) AS players
              FROM pyramid_teams t
              JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
              JOIN pyramid_sources s ON s.id = d.source_id AND s.is_active AND s.team_page IS NOT NULL
              JOIN pyramid_competitions cm ON cm.id = d.competition_id
             WHERE t.removed_at IS NULL AND t.external_id ~ '^[0-9]+$'
             GROUP BY 1
          ), src AS (
            SELECT 0 AS grp, coalesce(ord, -1) AS ord, label, teams, read, players, at, true AS ok, NULL::text AS note FROM paged
            UNION ALL
            SELECT 1, s.sort_order, s.league_label,
                   (SELECT count(*) FROM roster_sheet_teams t WHERE t.source_id = s.id),
                   (SELECT count(*) FROM roster_sheet_teams t WHERE t.source_id = s.id),
                   (SELECT count(*) FROM roster_sheet_players p JOIN roster_sheet_teams t ON t.id = p.team_id WHERE t.source_id = s.id),
                   s.last_fetched_at, coalesce(s.last_fetch_ok, true), s.last_fetch_note
              FROM roster_sheet_sources s WHERE s.is_active
          )
          SELECT json_build_object(
            'totals', json_build_object('players', (SELECT count(*) FROM e), 'teams', (SELECT count(DISTINCT team_ref) FROM e)),
            'paste', json_build_object(
              'sources', COALESCE((SELECT json_agg(json_build_object('id', s.id, 'label', s.league_label) ORDER BY s.sort_order, s.id)
                                     FROM roster_sheet_sources s WHERE s.is_active AND s.system = 'paste'), '[]'),
              'teams', COALESCE((SELECT json_agg(json_build_object(
                           'id', t.id, 'league', s.league_label, 'team', t.name,
                           'n', (SELECT count(*) FROM roster_sheet_players p WHERE p.team_id = t.id),
                           'when', to_char(t.loaded_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM'))
                           ORDER BY s.sort_order, t.name)
                         FROM roster_sheet_teams t JOIN roster_sheet_sources s ON s.id = t.source_id
                        WHERE s.is_active AND s.system = 'paste'), '[]')),
            'sources', COALESCE((SELECT json_agg(json_build_object(
                'label', label, 'teams', teams, 'read', read, 'players', players, 'ok', ok, 'note', note,
                'at', to_char(at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM')) ORDER BY grp, ord, label) FROM src), '[]'),
            'matches', COALESCE((SELECT json_agg(json_build_object(
                'key', g.name_key, 'teams', g.n_teams, 'clubs', g.n_clubs, 'dobs', g.n_dobs,
                'dob_same', COALESCE((SELECT max(x.c) FROM (SELECT count(DISTINCT e.team_ref) AS c FROM e
                                       WHERE e.name_key = g.name_key AND e.dob IS NOT NULL GROUP BY e.dob) x), 0) >= 2,
                'rows', (SELECT json_agg(json_build_object(
                           'name', e.full_name, 'league', e.league, 'team', e.team, 'division', e.division, 'club', e.club,
                           'dob', to_char(e.dob, 'FMMM/FMDD/YYYY'), 'added', e.added_on) ORDER BY e.league, e.team)
                         FROM e WHERE e.name_key = g.name_key))
                ORDER BY g.n_clubs DESC, g.n_teams DESC, g.name_key) FROM g), '[]')
          )::text AS body)SQL");
        json body = json::parse(std::string(rows[0]["body"].c_str()));
        body["sweep"] = RosterWatchSync::state();
        return jsonOut(HttpStatus::OK, body);
    } catch (const std::exception& e) {
        std::cerr << "RosterWatchController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the rosters");
    }
}

Response RosterWatchController::handleRefresh(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    const bool started = RosterWatchSync::start(true);
    return jsonOut(HttpStatus::OK, {{"started", started}, {"sweep", RosterWatchSync::state()}});
}

// POST /api/roster-watch/paste {source_id, team, names: ["First Last", …]}
// (mig 1777) — one team's roster as the page picked it out of a pasted
// league page; replaces that team in that source.
Response RosterWatchController::handlePaste(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    json body = json::parse(request.getBody().empty() ? "{}" : request.getBody(), nullptr, false);
    if (body.is_discarded() || !body.is_object()) return jsonError(HttpStatus::BAD_REQUEST, "Bad request");
    const int sourceId = body.value("source_id", 0);
    const std::string team = body.contains("team") && body["team"].is_string() ? body["team"].get<std::string>() : "";
    if (sourceId <= 0 || team.empty() || team.size() > 120) return jsonError(HttpStatus::BAD_REQUEST, "League and team name are required");
    if (!body.contains("names") || !body["names"].is_array() || body["names"].empty() || body["names"].size() > 200)
        return jsonError(HttpStatus::BAD_REQUEST, "No names to save");
    json names = json::array();
    for (const auto& n : body["names"]) if (n.is_string()) names.push_back(n.get<std::string>());
    try {
        auto r = Database::getInstance()->query("SELECT fh_roster_paste_load($1::int, $2, $3::jsonb) AS n",
                                                {std::to_string(sourceId), team, names.dump()});
        const int n = r.empty() || r[0]["n"].is_null() ? 0 : r[0]["n"].as<int>();
        if (n == 0) return jsonError(HttpStatus::BAD_REQUEST, "No names to save");
        return jsonOut(HttpStatus::OK, {{"saved", n}});
    } catch (const std::exception& e) {
        std::cerr << "RosterWatchController::handlePaste: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save the roster");
    }
}

// POST /api/roster-watch/paste/remove {team_id} — take a pasted team out.
Response RosterWatchController::handlePasteRemove(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    json body = json::parse(request.getBody().empty() ? "{}" : request.getBody(), nullptr, false);
    const int teamId = body.is_object() ? body.value("team_id", 0) : 0;
    if (teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "team_id is required");
    try {
        Database::getInstance()->query(
            "DELETE FROM roster_sheet_teams t USING roster_sheet_sources s "
            " WHERE t.id = $1::int AND s.id = t.source_id AND s.system = 'paste'", {std::to_string(teamId)});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "RosterWatchController::handlePasteRemove: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not remove the team");
    }
}
