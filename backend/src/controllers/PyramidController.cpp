#include "PyramidController.h"

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
           tr.website_url, tr.standings_url, o.logo_url,
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
           tt.position, tt.name, pc.name AS club,
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
    router.post(prefix + "/zone-rules", [this](const Request& r) { return handleZoneRules(r); });
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
                                    {"logo_url", strOrNull(r, "logo_url")}, {"states", states}, {"source", source}});
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
                {"pos", intOrNull(r, "position")}, {"name", str(r, "name")}, {"club", str(r, "club")},
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

        json kinds = json::array();
        for (const auto& r : db->query("SELECT code, label, moves, color FROM pyramid_zone_kinds ORDER BY sort_order, code"))
            kinds.push_back({{"code", str(r, "code")}, {"label", str(r, "label")}, {"moves", strOrNull(r, "moves")}, {"color", str(r, "color")}});

        return jsonOut(HttpStatus::OK, {
            {"root_id", num(tot[0], "root_id")},
            {"totals", {{"leagues", num(tot[0], "leagues")}, {"clubs", num(tot[0], "clubs")},
                        {"teams", num(tot[0], "teams")}, {"states", num(tot[0], "states")}}},
            {"competitions", competitions}, {"divisions", divisions}, {"links", links}, {"zone_kinds", kinds}});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
