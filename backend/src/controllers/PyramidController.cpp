#include "PyramidController.h"

#include <algorithm>
#include <iostream>
#include <map>

#include "../database/Database.h"
#include "../services/PyramidSync.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
json strOrNull(const pqxx::row& r, const char* c) { return r[c].is_null() ? json(nullptr) : json(std::string(r[c].c_str())); }
json intOrNull(const pqxx::row& r, const char* c) { return r[c].is_null() ? json(nullptr) : json(r[c].as<int>()); }
int num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0 : r[c].as<int>(); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

// The root and everything under it, its live tables and teams.
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

constexpr const char* kCompetitionsSql = R"SQL(
    SELECT tr.id, tr.parent_id, tr.kind, tr.tier, tr.name, tr.short_name, tr.region,
           tr.website_url, tr.standings_url, o.logo_url, tr.lat, tr.lon,
           (SELECT string_agg(s.state_code, ',' ORDER BY s.state_code)
              FROM pyramid_competition_states s WHERE s.competition_id = tr.id) AS states,
           ps.system, ps.last_fetch_ok,
           to_char(ps.last_fetched_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM') AS read_at,
           to_char(ps.last_ok_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM') AS ok_at,
           ps.last_fetch_note
      FROM tr
      -- The crest is the league's organization's (organizations.logo_url,
      -- the same column LeagueCrest reads).
      LEFT JOIN leagues lg ON lg.id = tr.league_id
      LEFT JOIN organizations o ON o.id = lg.organization_id
      LEFT JOIN LATERAL (SELECT * FROM pyramid_sources s WHERE s.competition_id = tr.id AND s.is_active
                          ORDER BY s.id LIMIT 1) ps ON true
     ORDER BY tr.tier, tr.sort_order, tr.name)SQL";

constexpr const char* kTablesSql = R"SQL(
    SELECT td.competition_id, td.id AS division_id, td.name AS division, td.counted,
           tt.id AS team_id, tt.position, tt.name, pc.name AS club, pc.id AS club_id,
           tt.played, tt.wins, tt.draws, tt.losses,
           tt.goals_for, tt.goals_against, tt.goal_diff, tt.points
      FROM td
      JOIN tt ON tt.division_id = td.id
      JOIN pyramid_clubs pc ON pc.id = tt.pyramid_club_id
     ORDER BY td.competition_id, td.sort_order, td.name, tt.position NULLS LAST, tt.points DESC, tt.name)SQL";

// A table's EFFECTIVE zones (mig 828: default rules for every table, a
// table's own override rows, the source's marks for what the rules don't
// decide), what the kind means (pyramid_zone_kinds) and where its teams go
// (pyramid_zone_moves).
constexpr const char* kZonesSql = R"SQL(
    SELECT z.division_id, z.kind, z.from_pos, z.to_pos, z.label, z.origin, k.color, k.moves,
           (SELECT string_agg(coalesce(tc.short_name || ' · ' || td2.name, cc.short_name, cc.name), ', '
                              ORDER BY coalesce(tc.short_name, cc.short_name), td2.name)
              FROM pyramid_zone_moves m
              LEFT JOIN pyramid_divisions td2 ON td2.id = m.to_division_id
              LEFT JOIN pyramid_competitions tc ON tc.id = td2.competition_id
              LEFT JOIN pyramid_competitions cc ON cc.id = m.to_competition_id
             WHERE m.division_id = z.division_id AND m.kind = z.kind AND m.from_pos = z.from_pos) AS targets
      FROM pyramid_zones_effective z
      JOIN td ON td.id = z.division_id
      JOIN pyramid_zone_kinds k ON k.code = z.kind
     ORDER BY z.division_id, z.from_pos)SQL";

// Links resolved to live tables: source + table name → the table row.
// One row carries both directions (promotes up, relegates down).
constexpr const char* kLinksSql = R"SQL(
    SELECT l.id, ld.id AS lower_division, ud.id AS upper_division, l.upper_competition_id,
           l.promotes, l.relegates
      FROM pyramid_links l
      JOIN td ld ON ld.source_id = l.lower_source_id AND ld.name = l.lower_division
      LEFT JOIN td ud ON ud.source_id = l.upper_source_id AND ud.name = l.upper_division
     WHERE l.upper_competition_id IS NOT NULL OR ud.id IS NOT NULL
     ORDER BY l.id)SQL";

// A table's own override rows (mig 828) — what the ✏️ editor opens on.
constexpr const char* kOverridesSql = R"SQL(
    SELECT td.id AS division_id, r.direction, r.kind, r.from_pos, r.to_pos,
           to_char(r.expires_on, 'FMMM/FMDD/YYYY') AS until
      FROM pyramid_zone_rules r JOIN td ON td.source_id = r.source_id AND td.name = r.division
     WHERE r.expires_on IS NULL OR r.expires_on >= current_date
     ORDER BY td.id, r.direction, r.from_pos NULLS FIRST)SQL";

// Replace one table's override rows for one direction, atomically: the
// delete and the insert are one statement.  An empty list = back to the
// defaults; [{kind: null}] = "none that way".  The new rows keep the
// replaced rows' expires_on (mig 836: a this-season-only exception stays
// this-season-only when edited).
constexpr const char* kReplaceOverridesSql = R"SQL(
    WITH d AS (SELECT source_id, name FROM pyramid_divisions WHERE id = $1::int AND removed_at IS NULL),
    del AS (DELETE FROM pyramid_zone_rules r USING d
             WHERE r.source_id = d.source_id AND r.division = d.name AND r.direction = $2
            RETURNING r.expires_on)
    INSERT INTO pyramid_zone_rules (source_id, division, direction, kind, from_pos, to_pos, expires_on, note)
    SELECT d.source_id, d.name, $2, x.kind, x.f, x.t, (SELECT max(expires_on) FROM del), $4
      FROM d, jsonb_to_recordset($3::jsonb) AS x(kind text, f int, t int))SQL";

// Every club playing in the tree and the tables it has a team in.
constexpr const char* kClubsSql = R"SQL(
    SELECT pc.id, pc.name, string_agg(DISTINCT tt.division_id::text, ',') AS divisions
      FROM tt JOIN pyramid_clubs pc ON pc.id = tt.pyramid_club_id
     GROUP BY pc.id
     ORDER BY pc.name)SQL";

// Where each team plays (mig 855): its ground — the venue of most of the
// games it hosts — when the feed names one.
constexpr const char* kPlacesSql = R"SQL(
    SELECT tt.id AS team_id, tt.pyramid_club_id AS club_id, tt.division_id, tt.name,
           v.name AS venue_name, v.address, v.lat, v.lon
      FROM tt JOIN pyramid_venues v ON v.id = tt.venue_id
     ORDER BY tt.id)SQL";

// Each league's seasons (mig 847, Growth by season): sides per competition
// (distinct clubs), and distinct clubs outside the root league's own tables
// (the APSL cups re-list conference clubs).  A former conference (inactive
// row, e.g. Northeast) comes with its name.
constexpr const char* kSeasonsSql = R"SQL(
    SELECT ps.id, ps.source_id, src.competition_id AS league_id, ps.name, ps.is_current, ps.games,
           -- A competition's size that season = its DISTINCT clubs: a
           -- conference played Fall + Spring lists the same sides twice.
           (SELECT json_agg(json_build_object('competition_id', x.cid, 'teams', x.teams, 'kind', x.kind,
                                              'active', x.is_active, 'name', x.short))
              FROM (SELECT sd.competition_id AS cid, c.kind, c.is_active, coalesce(c.short_name, c.name) AS short,
                           count(DISTINCT k)::int AS teams
                      FROM pyramid_season_divisions sd
                      JOIN pyramid_competitions c ON c.id = sd.competition_id
                      CROSS JOIN LATERAL unnest(sd.club_keys) AS k
                     WHERE sd.season_id = ps.id
                     GROUP BY 1, 2, 3, 4) x)::text AS by_comp,
           (SELECT count(DISTINCT k)
              FROM pyramid_season_divisions sd
              JOIN pyramid_competitions c ON c.id = sd.competition_id
              CROSS JOIN LATERAL unnest(sd.club_keys) AS k
             WHERE sd.season_id = ps.id AND c.kind <> 'league') AS clubs,
           -- Teams = team entries (a club's first team, reserves, …), the
           -- same rule outside the root league's own tables.
           (SELECT coalesce(sum(sd.teams), 0)::int
              FROM pyramid_season_divisions sd
              JOIN pyramid_competitions c ON c.id = sd.competition_id
             WHERE sd.season_id = ps.id AND c.kind <> 'league') AS teams
      FROM pyramid_seasons ps
      JOIN pyramid_sources src ON src.id = ps.source_id
      JOIN tr ON tr.id = src.competition_id
     ORDER BY src.competition_id, ps.name)SQL";

// Leagues: APSL + its affiliates, one per league row (CASA Select's four
// regions are one league).
constexpr const char* kTotalsSql = R"SQL(
    SELECT (SELECT count(DISTINCT coalesce(tr.league_id, -tr.id)) FROM tr
             WHERE tr.kind IN ('league', 'affiliate'))                                  AS leagues,
           (SELECT count(DISTINCT pyramid_club_id) FROM tt WHERE counted)               AS clubs,
           (SELECT count(*) FROM tt WHERE counted)                                      AS teams,
           (SELECT count(DISTINCT s.state_code) FROM pyramid_competition_states s
              JOIN tr ON tr.id = s.competition_id)                                      AS states,
           (SELECT id FROM tr WHERE tr.slug = $1)                                       AS root_id)SQL";
} // namespace

PyramidController::PyramidController() {}

void PyramidController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleGet(r); });
    router.get(prefix + "/roots", [this](const Request& r) { return handleRoots(r); });
    router.get(prefix + "/territory", [this](const Request& r) { return handleTerritory(r); });
    router.get(prefix + "/club", [this](const Request& r) { return handleClub(r); });
    router.post(prefix + "/club", [this](const Request& r) { return handleClubSave(r); });
    router.post(prefix + "/zone-rules", [this](const Request& r) { return handleZoneRules(r); });
}

// GET /api/pyramid/territory?conf=<id> (mig 852) — a conference's ground:
// its counties (pyramid_county_conference: nearest APSL club within reach,
// or a county override) as GeoJSON, the population inside, and its Sunday
// drive times (PyramidSync::conferenceTravel).
Response PyramidController::handleTerritory(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const std::string conf = request.getQueryParam("conf");
    if (conf.empty() || conf.find_first_not_of("0123456789") != std::string::npos) return jsonError(HttpStatus::BAD_REQUEST, "conf required");
    try {
        auto rows = Database::getInstance()->query(
            "SELECT k.fips, k.name, k.state, k.population, k.geometry::text AS geometry "
            "  FROM pyramid_county_conference cc JOIN pyramid_counties k ON k.fips = cc.fips "
            " WHERE cc.conference_id = $1::int ORDER BY k.fips", {conf});
        json features = json::array();
        long long population = 0;
        for (const auto& r : rows) {
            population += r["population"].as<long long>();
            features.push_back({{"type", "Feature"},
                                {"properties", {{"fips", str(r, "fips")}, {"name", str(r, "name")}, {"state", str(r, "state")},
                                                {"population", r["population"].as<long long>()}}},
                                {"geometry", json::parse(str(r, "geometry"), nullptr, false)}});
        }
        // The main city (mig 860): its outline, its collar counties, and the
        // conference's APSL teams in three rings — inside the city limits;
        // in a core or bordering (collar) county; further out.
        json city = PyramidSync::cityOutline(std::stoi(conf));
        if (city.is_object()) {
            auto* db = Database::getInstance();
            auto ring = db->query(R"SQL(
                WITH m AS (SELECT core_fips FROM pyramid_main_cities WHERE competition_id = $1::int),
                     zone AS (SELECT unnest(core_fips) AS fips FROM m
                              UNION SELECT n.neighbour FROM pyramid_county_neighbours n, m WHERE n.fips = ANY (m.core_fips))
                SELECT k.fips, k.geometry::text AS g, k.fips = ANY ((SELECT core_fips FROM m)) AS core
                  FROM zone JOIN pyramid_counties k ON k.fips = zone.fips)SQL", {conf});
            std::vector<json> zoneGeoms;
            json collar = json::array();
            for (const auto& r : ring) {
                zoneGeoms.push_back(json::parse(str(r, "g"), nullptr, false));
                if (!r["core"].as<bool>()) collar.push_back(str(r, "fips"));
            }
            json inCity = json::array(), inCollar = json::array(), further = json::array();
            for (const auto& t : db->query(
                     "SELECT t.name, tc.lat, tc.lon FROM pyramid_team_conference tc JOIN pyramid_teams t ON t.id = tc.team_id "
                     " WHERE tc.conference_id = $1::int ORDER BY t.name", {conf})) {
                const double lat = t["lat"].as<double>(), lon = t["lon"].as<double>();
                if (!city["geometry"].is_null() && PyramidSync::inside(city["geometry"], lon, lat)) inCity.push_back(str(t, "name"));
                else if (std::any_of(zoneGeoms.begin(), zoneGeoms.end(), [&](const json& g) { return PyramidSync::inside(g, lon, lat); })) inCollar.push_back(str(t, "name"));
                else further.push_back(str(t, "name"));
            }
            city["collar_fips"] = collar;
            city["rings"] = {{"city", inCity}, {"collar", inCollar}, {"further", further}};
        }
        return jsonOut(HttpStatus::OK, {{"conference_id", std::stoi(conf)}, {"population", population},
                                        {"counties", features.size()},
                                        {"geojson", {{"type", "FeatureCollection"}, {"features", features}}},
                                        {"travel", PyramidSync::conferenceTravel(std::stoi(conf))},
                                        {"city", city}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] territory: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /api/pyramid/club?id=<pyramid club> (mig 856) — the club card: crest,
// year established, and per live team its table, place, record, effective
// zone, home ground, staff and roster (the roster read from the league's
// team page when a day old — PyramidSync::teamPeople).
Response PyramidController::handleClub(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const std::string id = request.getQueryParam("id");
    if (id.empty() || id.find_first_not_of("0123456789") != std::string::npos) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        auto* db = Database::getInstance();
        auto c = db->query("SELECT id, name, founded, logo_url FROM pyramid_clubs WHERE id = $1::int", {id});
        if (c.empty()) return jsonError(HttpStatus::NOT_FOUND, "No such club");
        auto teams = db->query(R"SQL(
            SELECT t.id, t.name, t.position, t.played, t.wins, t.draws, t.losses, t.points,
                   d.name AS division, coalesce(cm.short_name, cm.name) AS league, cm.kind,
                   v.name AS venue_name, v.address AS venue, s.team_page IS NOT NULL AS has_page,
                   to_char(t.people_fetched_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM') AS people_at,
                   (SELECT z.label FROM pyramid_zones_effective z
                     WHERE z.division_id = d.id AND t.position BETWEEN z.from_pos AND z.to_pos LIMIT 1) AS zone,
                   (SELECT k.color FROM pyramid_zones_effective z JOIN pyramid_zone_kinds k ON k.code = z.kind
                     WHERE z.division_id = d.id AND t.position BETWEEN z.from_pos AND z.to_pos LIMIT 1) AS zone_color
              FROM pyramid_teams t
              JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
              JOIN pyramid_competitions cm ON cm.id = d.competition_id
              JOIN pyramid_sources s ON s.id = d.source_id
              LEFT JOIN pyramid_venues v ON v.id = t.venue_id
             WHERE t.pyramid_club_id = $1::int AND t.removed_at IS NULL
             ORDER BY (cm.kind = 'conference') DESC, cm.sort_order, d.name)SQL", {id});
        json out = json::array();
        for (const auto& t : teams) {
            const int tid = num(t, "id");
            if (t["has_page"].as<bool>()) PyramidSync::teamPeople(tid);
            json staff = json::array(), roster = json::array();
            for (const auto& p : db->query("SELECT kind, name, role, goals, assists, added_on FROM pyramid_team_people "
                                           " WHERE team_id = $1::int ORDER BY kind, sort", {std::to_string(tid)})) {
                if (str(p, "kind") == "staff") staff.push_back({{"name", str(p, "name")}, {"role", str(p, "role")}});
                else roster.push_back({{"name", str(p, "name")}, {"goals", intOrNull(p, "goals")}, {"assists", intOrNull(p, "assists")},
                                       {"added", strOrNull(p, "added_on")}});
            }
            auto at = db->query("SELECT to_char(people_fetched_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD FMHH12:MI AM') AS at "
                                "  FROM pyramid_teams WHERE id = $1::int", {std::to_string(tid)});
            out.push_back({{"id", tid}, {"name", str(t, "name")}, {"league", str(t, "league")}, {"division", str(t, "division")},
                           {"apsl", str(t, "kind") == "conference"}, {"pos", intOrNull(t, "position")},
                           {"gp", num(t, "played")}, {"w", num(t, "wins")}, {"d", num(t, "draws")}, {"l", num(t, "losses")},
                           {"pts", num(t, "points")}, {"zone", strOrNull(t, "zone")}, {"zone_color", strOrNull(t, "zone_color")},
                           {"venue_name", strOrNull(t, "venue_name")}, {"venue", strOrNull(t, "venue")},
                           {"roster_published", t["has_page"].as<bool>()},
                           {"people_at", at.empty() ? json(nullptr) : strOrNull(at[0], "at")},
                           {"staff", staff}, {"roster", roster}});
        }
        return jsonOut(HttpStatus::OK, {{"id", num(c[0], "id")}, {"name", str(c[0], "name")},
                                        {"founded", intOrNull(c[0], "founded")}, {"logo_url", strOrNull(c[0], "logo_url")},
                                        {"teams", out}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] club: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/pyramid/club {club_id, founded} — the year established (club
// admins; null clears it).
Response PyramidController::handleClubSave(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    try {
        json body = json::parse(request.getBody().empty() ? "{}" : request.getBody(), nullptr, false);
        if (body.is_discarded() || !body.is_object() || !body.contains("club_id") || !body["club_id"].is_number())
            return jsonError(HttpStatus::BAD_REQUEST, "club_id required");
        std::string founded;
        if (body.contains("founded") && body["founded"].is_number()) {
            const int y = body["founded"].get<int>();
            if (y < 1800 || y > 2100) return jsonError(HttpStatus::BAD_REQUEST, "a year between 1800 and 2100");
            founded = std::to_string(y);
        }
        Database::getInstance()->query("UPDATE pyramid_clubs SET founded = NULLIF($2, '')::smallint WHERE id = $1::int",
                                       {std::to_string(body["club_id"].get<int>()), founded});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] club save: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /api/pyramid/roots — each pyramid's root league with its crest, for
// the picker tile (owner 2026-10-29: "use apsl logo at top of page and on
// button in main fh screen").  Reads only; never re-reads a source.
Response PyramidController::handleRoots(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    try {
        json roots = json::array();
        for (const auto& r : Database::getInstance()->query(
                 "SELECT c.slug, c.name, c.short_name, o.logo_url FROM pyramid_competitions c "
                 "  LEFT JOIN leagues lg ON lg.id = c.league_id "
                 "  LEFT JOIN organizations o ON o.id = lg.organization_id "
                 " WHERE c.slug IS NOT NULL AND c.parent_id IS NULL AND c.is_active ORDER BY c.sort_order, c.id"))
            roots.push_back({{"slug", str(r, "slug")}, {"name", str(r, "name")},
                             {"short_name", strOrNull(r, "short_name")}, {"logo_url", strOrNull(r, "logo_url")}});
        return jsonOut(HttpStatus::OK, {{"roots", roots}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] roots: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/pyramid/zone-rules  {division_id, direction: up|down|stay,
//   mode: default|none|custom, zones: [{kind, from, to}]}
// Owner 2026-10-29: "that should be default for all divisions conferences
// etc. but then those that differ we can edit over time."
Response PyramidController::handleZoneRules(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    try {
        json body = json::parse(request.getBody().empty() ? "{}" : request.getBody(), nullptr, false);
        if (body.is_discarded() || !body.is_object()) return jsonError(HttpStatus::BAD_REQUEST, "Bad JSON");
        const int divisionId = body.value("division_id", 0);
        const std::string direction = body.value("direction", "");
        const std::string mode = body.value("mode", "");
        if (divisionId <= 0 || (direction != "up" && direction != "down" && direction != "stay")
            || (mode != "default" && mode != "none" && mode != "custom"))
            return jsonError(HttpStatus::BAD_REQUEST, "division_id, direction (up|down|stay) and mode (default|none|custom) required");

        auto* db = Database::getInstance();
        json rows = json::array();
        if (mode == "none") rows.push_back({{"kind", nullptr}, {"f", nullptr}, {"t", nullptr}});
        if (mode == "custom") {
            if (!body.contains("zones") || !body["zones"].is_array() || body["zones"].empty())
                return jsonError(HttpStatus::BAD_REQUEST, "custom needs at least one zone");
            for (const auto& z : body["zones"]) {
                const std::string kind = z.value("kind", "");
                const int from = z.value("from", 0), to = z.value("to", 0);
                if (from < 1 || to < from) return jsonError(HttpStatus::BAD_REQUEST, "places must run from >= 1 to >= from");
                // The kind must move the way this direction does ('stay' =
                // a kind that moves nowhere, e.g. playoff — mig 835).
                auto k = db->query("SELECT 1 FROM pyramid_zone_kinds WHERE code = $1 AND coalesce(moves, 'stay') = $2", {kind, direction});
                if (k.empty()) return jsonError(HttpStatus::BAD_REQUEST, "'" + kind + "' is not a " + direction + " zone");
                rows.push_back({{"kind", kind}, {"f", from}, {"t", to}});
            }
        }
        auto d = db->query("SELECT 1 FROM pyramid_divisions WHERE id = $1::int AND removed_at IS NULL", {std::to_string(divisionId)});
        if (d.empty()) return jsonError(HttpStatus::NOT_FOUND, "No such table");
        db->query(kReplaceOverridesSql, {std::to_string(divisionId), direction, rows.dump(),
                                         "set on #apsl by user " + std::to_string(bearerUserId(request))});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] zone rules: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
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

        json competitions = json::array();
        for (const auto& r : db->query(cte + kCompetitionsSql, {root})) {
            json states = json::array();
            const std::string st = str(r, "states");
            for (size_t p = 0; !st.empty();) {
                const size_t c = st.find(',', p);
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
            competitions.push_back({{"id", num(r, "id")}, {"parent_id", intOrNull(r, "parent_id")},
                                    {"kind", str(r, "kind")}, {"tier", num(r, "tier")}, {"name", str(r, "name")},
                                    {"short_name", strOrNull(r, "short_name")}, {"region", strOrNull(r, "region")},
                                    {"website_url", strOrNull(r, "website_url")}, {"standings_url", strOrNull(r, "standings_url")},
                                    {"logo_url", strOrNull(r, "logo_url")},
                                    {"lat", r["lat"].is_null() ? json(nullptr) : json(r["lat"].as<double>())},
                                    {"lon", r["lon"].is_null() ? json(nullptr) : json(r["lon"].as<double>())},
                                    {"states", states}, {"source", source}});
        }

        json divisions = json::array();
        std::map<int, size_t> at;    // division id → index in divisions
        for (const auto& r : db->query(cte + kTablesSql, {root})) {
            const int div = num(r, "division_id");
            if (!at.count(div)) {
                at[div] = divisions.size();
                divisions.push_back({{"id", div}, {"competition_id", num(r, "competition_id")}, {"name", str(r, "division")},
                                     {"counts", r["counted"].as<bool>()}, {"zones", json::array()},
                                     {"overrides", {{"up", nullptr}, {"stay", nullptr}, {"down", nullptr}}}, {"teams", json::array()}});
            }
            divisions[at[div]]["teams"].push_back({
                {"id", num(r, "team_id")}, {"pos", intOrNull(r, "position")}, {"name", str(r, "name")}, {"club", str(r, "club")},
                {"club_id", num(r, "club_id")},
                {"gp", num(r, "played")}, {"w", num(r, "wins")}, {"d", num(r, "draws")}, {"l", num(r, "losses")},
                {"gf", num(r, "goals_for")}, {"ga", num(r, "goals_against")}, {"gd", num(r, "goal_diff")},
                {"pts", num(r, "points")}});
        }
        for (const auto& r : db->query(cte + kZonesSql, {root})) {
            auto it = at.find(num(r, "division_id"));
            if (it == at.end()) continue;
            divisions[it->second]["zones"].push_back({{"kind", str(r, "kind")}, {"from", num(r, "from_pos")},
                                                      {"to", num(r, "to_pos")}, {"label", str(r, "label")},
                                                      {"color", str(r, "color")}, {"moves", strOrNull(r, "moves")}, {"origin", str(r, "origin")},
                                                      {"targets", strOrNull(r, "targets")}});
        }

        // overrides.{up,down}: null = defaults; [] = none; [{kind, from, to}] = custom.
        for (const auto& r : db->query(cte + kOverridesSql, {root})) {
            auto it = at.find(num(r, "division_id"));
            if (it == at.end()) continue;
            json& o = divisions[it->second]["overrides"][str(r, "direction")];
            if (o.is_null()) o = json::array();
            if (!r["kind"].is_null()) o.push_back({{"kind", str(r, "kind")}, {"from", num(r, "from_pos")}, {"to", num(r, "to_pos")},
                                                   {"until", strOrNull(r, "until")}});
        }

        json links = json::array();
        for (const auto& r : db->query(cte + kLinksSql, {root}))
            links.push_back({{"lower", num(r, "lower_division")}, {"upper_division", intOrNull(r, "upper_division")},
                             {"upper_competition", intOrNull(r, "upper_competition_id")},
                             {"promotes", r["promotes"].as<bool>()}, {"relegates", r["relegates"].as<bool>()}});

        json clubs = json::array();
        for (const auto& r : db->query(cte + kClubsSql, {root})) {
            json ids = json::array();
            const std::string list = str(r, "divisions");
            for (size_t p = 0; !list.empty();) {
                const size_t c = list.find(',', p);
                ids.push_back(std::stoi(list.substr(p, c == std::string::npos ? std::string::npos : c - p)));
                if (c == std::string::npos) break;
                p = c + 1;
            }
            clubs.push_back({{"id", num(r, "id")}, {"name", str(r, "name")}, {"divisions", ids}});
        }
        json places = json::array();
        for (const auto& r : db->query(cte + kPlacesSql, {root}))
            places.push_back({{"team_id", num(r, "team_id")}, {"club_id", num(r, "club_id")}, {"division_id", num(r, "division_id")},
                              {"name", str(r, "name")}, {"venue_name", strOrNull(r, "venue_name")}, {"venue", strOrNull(r, "address")},
                              {"lat", r["lat"].is_null() ? json(nullptr) : json(r["lat"].as<double>())},
                              {"lon", r["lon"].is_null() ? json(nullptr) : json(r["lon"].as<double>())}});

        json seasons = json::array();
        for (const auto& r : db->query(cte + kSeasonsSql, {root})) {
            json byComp = json::parse(r["by_comp"].is_null() ? "[]" : r["by_comp"].c_str(), nullptr, false);
            seasons.push_back({{"league_id", num(r, "league_id")}, {"name", str(r, "name")},
                               {"current", r["is_current"].as<bool>()}, {"games", num(r, "games")},
                               {"clubs", num(r, "clubs")}, {"teams", num(r, "teams")},
                               {"by_competition", byComp.is_discarded() ? json::array() : byComp}});
        }

        json kinds = json::array();
        for (const auto& r : db->query("SELECT code, label, moves, color FROM pyramid_zone_kinds ORDER BY sort_order, code"))
            kinds.push_back({{"code", str(r, "code")}, {"label", str(r, "label")}, {"moves", strOrNull(r, "moves")}, {"color", str(r, "color")}});

        return jsonOut(HttpStatus::OK, {
            {"root_id", num(tot[0], "root_id")},
            {"totals", {{"leagues", num(tot[0], "leagues")}, {"clubs", num(tot[0], "clubs")},
                        {"teams", num(tot[0], "teams")}, {"states", num(tot[0], "states")}}},
            {"competitions", competitions}, {"divisions", divisions}, {"links", links}, {"zone_kinds", kinds},
            {"clubs", clubs}, {"places", places}, {"seasons", seasons}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
