#include "OfficialRosterController.h"

#include <iostream>

#include "../database/Database.h"
#include "../services/TeamPassRoster.h"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"success", false}, {"error", message}}); }

long long idFromPath(const std::string& path) {
    // /api/official-roster/<id>[/refresh|/pdf]
    const std::string key = "/official-roster/";
    auto p = path.find(key); if (p == std::string::npos) return 0;
    p += key.size(); auto e = path.find('/', p);
    try { return std::stoll(path.substr(p, e == std::string::npos ? std::string::npos : e - p)); } catch (...) { return 0; }
}

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

std::string hexOf(const std::string& bytes) {
    static const char* d = "0123456789abcdef";
    std::string out;
    out.reserve(bytes.size() * 2);
    for (unsigned char c : bytes) { out.push_back(d[c >> 4]); out.push_back(d[c & 15]); }
    return out;
}

std::string unhex(const std::string& h) {
    std::string out;
    out.reserve(h.size() / 2);
    auto v = [](char c) -> int {
        if (c >= '0' && c <= '9') return c - '0';
        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
        if (c >= 'A' && c <= 'F') return c - 'A' + 10;
        return 0;
    };
    for (size_t i = 0; i + 1 < h.size(); i += 2) out.push_back(static_cast<char>((v(h[i]) << 4) | v(h[i + 1])));
    return out;
}

// The game's teams: what its calendar event is tagged with, else home/away.
constexpr const char* kTeamsOf = R"SQL(
    COALESCE(
        (SELECT array_agg(DISTINCT fet.team_id) FROM fh_events fe JOIN fh_event_teams fet ON fet.fh_event_id = fe.id WHERE fe.match_id = $1::int),
        (SELECT array_remove(ARRAY[m.home_team_id, m.away_team_id], NULL) FROM matches m WHERE m.id = $1::int)))SQL";

// The league sheet this game prints: the active source of one of its teams.
const std::string kSourceOf = std::string(R"SQL(
    SELECT s.id, s.league_label, s.season, s.system, s.site_slug, s.external_team_id, s.credentials_key
      FROM official_roster_sources s
     WHERE s.is_active AND s.team_id = ANY()SQL") + kTeamsOf + R"SQL()
     ORDER BY s.id LIMIT 1)SQL";

} // namespace

void OfficialRosterController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/:matchId",         [this](const Request& r) { return handleGet(r); });
    router.post(prefix + "/:matchId/refresh", [this](const Request& r) { return handleRefresh(r); });
    router.get (prefix + "/:matchId/pdf",     [this](const Request& r) { return handlePdf(r); });
}

OfficialRosterController::Access OfficialRosterController::access(const Request& request, long long matchId) {
    Access a; a.userId = bearerUserId(request);
    if (a.userId <= 0) return a;
    auto rows = Database::getInstance()->query(std::string(R"SQL(
        WITH teams_of AS (SELECT )SQL") + kTeamsOf + R"SQL( AS ids)
        SELECT u.person_id,
               EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id WHERE a.user_id = u.id AND al.name IN ('club','super')) AS is_admin,
               EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
                        WHERE co.person_id = u.person_id AND tc.ended_at IS NULL AND tc.team_id = ANY(t.ids)) AS is_coach,
               EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = u.person_id AND tp.removed_at IS NULL
                          AND tp.team_id = ANY(t.ids)) AS is_rostered
          FROM users u CROSS JOIN teams_of t WHERE u.id = $2::int)SQL", {std::to_string(matchId), std::to_string(a.userId)});
    if (rows.empty()) return a;
    a.personId = rows[0]["person_id"].is_null() ? 0 : rows[0]["person_id"].as<long long>();
    a.allowed = rows[0]["is_admin"].as<bool>() || rows[0]["is_coach"].as<bool>() || rows[0]["is_rostered"].as<bool>();
    return a;
}

bool OfficialRosterController::gate(const Request& request, long long matchId, Access* who, Response* error) {
    if (matchId <= 0) { *error = jsonError(HttpStatus::BAD_REQUEST, "match id"); return false; }
    *who = access(request, matchId);
    if (who->userId <= 0) { *error = jsonError(HttpStatus::UNAUTHORIZED, "sign in"); return false; }
    if (!who->allowed) { *error = jsonError(HttpStatus::FORBIDDEN, "The official roster is for this game's teams."); return false; }
    return true;
}

json OfficialRosterController::state(long long matchId) {
    auto* db = Database::getInstance();
    const std::string mid = std::to_string(matchId);
    json out = {{"success", true}, {"available", false}, {"league", nullptr}, {"season", nullptr}, {"saved", nullptr}};
    auto src = db->query(kSourceOf, {mid});
    if (src.empty()) return out;
    out["available"] = true;
    out["league"] = str(src[0], "league_label");
    out["season"] = str(src[0], "season");
    auto saved = db->query(R"SQL(
        SELECT to_char(r.fetched_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS fetched_at, r.byte_size,
               NULLIF(trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), '') AS fetched_by
          FROM match_official_rosters r LEFT JOIN persons p ON p.id = r.fetched_by
         WHERE r.match_id = $1::int)SQL", {mid});
    if (!saved.empty())
        out["saved"] = {{"fetchedAt", str(saved[0], "fetched_at")}, {"byteSize", saved[0]["byte_size"].as<long long>()},
                        {"fetchedBy", saved[0]["fetched_by"].is_null() ? json(nullptr) : json(str(saved[0], "fetched_by"))}};
    return out;
}

Response OfficialRosterController::handleGet(const Request& request) {
    const long long matchId = idFromPath(request.getPath());
    Access who; Response error(HttpStatus::OK, "");
    try {
        if (!gate(request, matchId, &who, &error)) return error;
        return jsonOut(HttpStatus::OK, state(matchId));
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/official-roster] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

// Always a fresh pull: the row for this game is replaced, never reused, so
// what prints is the league's roster as of this tap.
Response OfficialRosterController::handleRefresh(const Request& request) {
    const long long matchId = idFromPath(request.getPath());
    Access who; Response error(HttpStatus::OK, "");
    try {
        if (!gate(request, matchId, &who, &error)) return error;
        auto* db = Database::getInstance();
        const std::string mid = std::to_string(matchId);
        auto src = db->query(kSourceOf, {mid});
        if (src.empty()) return jsonError(HttpStatus::NOT_FOUND, "No league roster is set up for this game's team.");
        const std::string sourceId = str(src[0], "id"), system = str(src[0], "system");

        TeamPassRoster::Result pulled;
        if (system == "teampass") pulled = TeamPassRoster::fetch(str(src[0], "site_slug"), str(src[0], "external_team_id"), str(src[0], "credentials_key"));
        else pulled.error = "no fetcher for " + system;

        db->query("UPDATE official_roster_sources SET last_fetched_at = now(), last_fetch_ok = $2::boolean, last_fetch_note = NULLIF($3, '') WHERE id = $1::int",
                  {sourceId, pulled.ok ? "true" : "false", pulled.error});
        if (!pulled.ok) {
            std::cerr << "[POST /api/official-roster] match " << mid << ": " << pulled.error << std::endl;
            // 200, not 502: a gateway status can be swapped for a proxy's own
            // error page on the way out, and the coach needs the reason.
            return jsonError(HttpStatus::OK, pulled.error);
        }

        db->query(R"SQL(
            INSERT INTO match_official_rosters (match_id, source_id, mime, byte_size, bytes, fetched_at, fetched_by)
            VALUES ($1::int, $2::int, 'application/pdf', $3::int, decode($4, 'hex'), now(), NULLIF($5, '0')::int)
            ON CONFLICT (match_id) DO UPDATE SET
                source_id = EXCLUDED.source_id, mime = EXCLUDED.mime, byte_size = EXCLUDED.byte_size,
                bytes = EXCLUDED.bytes, fetched_at = EXCLUDED.fetched_at, fetched_by = EXCLUDED.fetched_by)SQL",
            {mid, sourceId, std::to_string(pulled.pdf.size()), hexOf(pulled.pdf), std::to_string(who.personId)});
        return jsonOut(HttpStatus::OK, state(matchId));
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/official-roster] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response OfficialRosterController::handlePdf(const Request& request) {
    const long long matchId = idFromPath(request.getPath());
    Access who; Response error(HttpStatus::OK, "");
    try {
        if (!gate(request, matchId, &who, &error)) return error;
        auto rows = Database::getInstance()->query(
            "SELECT mime, encode(bytes, 'hex') AS h FROM match_official_rosters WHERE match_id = $1::int", {std::to_string(matchId)});
        if (rows.empty()) return jsonError(HttpStatus::NOT_FOUND, "No roster saved for this game yet.");
        Response r(HttpStatus::OK, unhex(str(rows[0], "h")));
        r.setHeader("Content-Type", str(rows[0], "mime"));
        r.setHeader("Content-Disposition", "inline; filename=\"official-roster-" + std::to_string(matchId) + ".pdf\"");
        r.setHeader("X-Content-Type-Options", "nosniff");
        r.setHeader("Cache-Control", "private, no-store");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/official-roster/pdf] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
