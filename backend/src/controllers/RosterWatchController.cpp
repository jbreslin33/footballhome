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
