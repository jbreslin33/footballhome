#include "CupRosterController.h"

#include <iostream>
#include <set>
#include <string>
#include <vector>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
constexpr int kPoolMax = 30;   // "Pool is set at 30" — the form's own limit.
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
bool parseBody(const Request& request, json* body, Response* error) {
    try { *body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); if (!body->is_object()) *body = json::object(); return true; }
    catch (const std::exception& e) { *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); return false; }
}
// "/api/cup-rosters/12/update" → 12.
long long idFromPath(const std::string& path) {
    const std::string marker = "/api/cup-rosters/";
    const auto at = path.find(marker); if (at == std::string::npos) return 0;
    std::string rest = path.substr(at + marker.size());
    const auto q = rest.find('?'); if (q != std::string::npos) rest = rest.substr(0, q);
    const auto sl = rest.find('/'); if (sl != std::string::npos) rest = rest.substr(0, sl);
    try { return std::stoll(rest); } catch (...) { return 0; }
}
const char* kHeaderFields[] = {"title", "team_name", "cup", "state_association", "competition", "state",
                               "shirt_primary", "shorts_primary", "socks_primary", "shirt_alt", "shorts_alt", "socks_alt",
                               "coach_name", "coach_email", "coach_phone", "verification_name"};

// The whole sheet: header + players in order, names and DOB from persons.
json sheetJson(Database* db, const std::string& where, const std::string& arg) {
    auto rows = db->query("SELECT r.*, r.public_slug::text AS slug, r.sheet_date::text AS sheet_date_iso, "
                          "       to_char(r.sheet_date, 'FMMM/FMDD/YYYY') AS sheet_date_us, "
                          "       to_char(r.updated_at AT TIME ZONE 'America/New_York', 'Mon FMDD, FMHH12:MI AM') AS updated_label "
                          "  FROM cup_rosters r WHERE " + where, {arg});
    if (rows.empty()) return nullptr;
    const auto& r = rows[0];
    json out = {{"id", r["id"].as<long long>()}, {"public_slug", str(r, "slug")}, {"sheet_date", str(r, "sheet_date_iso")},
                {"sheet_date_us", str(r, "sheet_date_us")}, {"updated_label", str(r, "updated_label")}, {"max", kPoolMax}, {"players", json::array()}};
    for (const char* f : kHeaderFields) out[f] = str(r, f);
    for (const auto& p : db->query(R"SQL(
        SELECT p.id AS person_id, COALESCE(p.first_name,'') AS first_name, COALESCE(p.last_name,'') AS last_name,
               to_char(p.birth_date, 'FMMM/FMDD/YYYY') AS dob, p.birth_date::text AS dob_iso, cp.sort_order
          FROM cup_roster_players cp JOIN persons p ON p.id = cp.person_id
         WHERE cp.cup_roster_id = $1::int
         ORDER BY cp.sort_order, p.last_name, p.first_name)SQL", {std::to_string(r["id"].as<long long>())})) {
        out["players"].push_back({{"person_id", p["person_id"].as<long long>()}, {"first_name", str(p, "first_name")}, {"last_name", str(p, "last_name")},
                                  {"dob", str(p, "dob")}, {"dob_iso", str(p, "dob_iso")}});
    }
    return out;
}
} // namespace

CupRosterController::CupRosterController() {}

bool CupRosterController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Cup rosters are for club admins.");
    return false;
}

void CupRosterController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",        [this](const Request& r) { return handleBoard(r); });
    router.post(prefix + "/new",          [this](const Request& r) { return handleNew(r); });
    router.get (prefix + "/public/:slug", [this](const Request& r) { return handlePublic(r); });
    router.del (prefix,                   [this](const Request& r) { return handleDelete(r); });
    router.post(prefix + "/:id/update",   [this](const Request& r) { return handleUpdate(r); });
    router.post(prefix + "/:id/players",  [this](const Request& r) { return handlePlayers(r); });
    router.get (prefix + "/:id",          [this](const Request& r) { return handleGet(r); });
}

// GET /api/cup-rosters/board — every sheet, newest first, and the pool: every
// player on an active men's board team (APSL, Reserves, Liga 1 — the Mens
// section's teams, not hardcoded ids), once, with the teams they are on.
Response CupRosterController::handleBoard(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        auto* db = Database::getInstance();
        json rosters = json::array();
        for (const auto& r : db->query(R"SQL(
            SELECT r.id, r.title, r.cup, r.competition, r.team_name, r.sheet_date::text AS sheet_date, r.public_slug::text AS slug,
                   to_char(r.updated_at AT TIME ZONE 'America/New_York', 'Mon FMDD, YYYY') AS updated_label,
                   (SELECT count(*) FROM cup_roster_players cp WHERE cp.cup_roster_id = r.id) AS players
              FROM cup_rosters r ORDER BY r.updated_at DESC, r.id DESC)SQL")) {
            rosters.push_back({{"id", r["id"].as<long long>()}, {"title", str(r, "title")}, {"cup", str(r, "cup")}, {"competition", str(r, "competition")},
                               {"team_name", str(r, "team_name")}, {"sheet_date", str(r, "sheet_date")}, {"public_slug", str(r, "slug")},
                               {"updated_label", str(r, "updated_label")}, {"players", r["players"].as<long long>()}});
        }
        json teams = json::array();
        for (const auto& t : db->query(R"SQL(
            SELECT t.id, COALESCE(t.label, t.name) AS label FROM teams t JOIN club_sections cs ON cs.id = t.club_section_id
             WHERE cs.code = 'M' AND t.is_active AND t.board_sort_order IS NOT NULL ORDER BY t.board_sort_order)SQL"))
            teams.push_back({{"id", t["id"].as<long long>()}, {"label", str(t, "label")}});
        json pool = json::array();
        for (const auto& p : db->query(R"SQL(
            SELECT p.id AS person_id, COALESCE(p.first_name,'') AS first_name, COALESCE(p.last_name,'') AS last_name,
                   to_char(p.birth_date, 'FMMM/FMDD/YYYY') AS dob,
                   array_agg(DISTINCT t.id) AS team_ids,
                   string_agg(DISTINCT COALESCE(t.label, t.name), ' · ') AS teams
              FROM team_persons tp
              JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.board_sort_order IS NOT NULL
              JOIN club_sections cs ON cs.id = t.club_section_id AND cs.code = 'M'
              JOIN persons p ON p.id = tp.person_id
             WHERE tp.removed_at IS NULL
             GROUP BY p.id ORDER BY p.last_name, p.first_name)SQL")) {
            json ids = json::array();
            { std::string a = str(p, "team_ids"); std::string cur;   // "{35,120}" → [35,120]
              for (char ch : a) { if (ch >= '0' && ch <= '9') cur += ch; else if (!cur.empty()) { ids.push_back(std::stoll(cur)); cur.clear(); } }
              if (!cur.empty()) ids.push_back(std::stoll(cur)); }
            pool.push_back({{"person_id", p["person_id"].as<long long>()}, {"first_name", str(p, "first_name")}, {"last_name", str(p, "last_name")},
                            {"dob", str(p, "dob")}, {"team_ids", ids}, {"teams", str(p, "teams")}});
        }
        // Who a sheet is emailed to (cup_roster_recipients, mig 557).
        json recipients = json::array();
        for (const auto& r : db->query("SELECT name, role, email FROM cup_roster_recipients WHERE is_active ORDER BY sort_order, id"))
            recipients.push_back({{"name", str(r, "name")}, {"role", str(r, "role")}, {"email", str(r, "email")}});
        // The sender's name for the email's sign-off.
        std::string sender;
        { auto me = db->query("SELECT COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'') AS n FROM users u JOIN persons p ON p.id = u.person_id WHERE u.id = $1::int",
                              {std::to_string(bearerUserId(request))});
          if (!me.empty()) sender = str(me[0], "n"); }
        return jsonOut(HttpStatus::OK, {{"rosters", rosters}, {"pool", pool}, {"teams", teams}, {"max", kPoolMax}, {"recipients", recipients}, {"sender", sender}});
    } catch (const std::exception& e) { std::cerr << "[cup-rosters board] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// POST /api/cup-rosters/new — a sheet whose header is the last sheet's; the
// first ever starts from the copy defaults (message_templates kind
// cup_roster, default_*) and the men's coach on record with their contact.
Response CupRosterController::handleNew(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        auto* db = Database::getInstance();
        const std::string uid = std::to_string(bearerUserId(request));
        auto last = db->query("SELECT id FROM cup_rosters ORDER BY updated_at DESC, id DESC LIMIT 1");
        pqxx::result made;
        if (!last.empty()) {
            made = db->query(R"SQL(
                INSERT INTO cup_rosters (title, team_name, cup, state_association, competition, state,
                                         shirt_primary, shorts_primary, socks_primary, shirt_alt, shorts_alt, socks_alt,
                                         coach_name, coach_email, coach_phone, verification_name, sheet_date, created_by_user_id)
                SELECT '', team_name, cup, state_association, competition, state,
                       shirt_primary, shorts_primary, socks_primary, shirt_alt, shorts_alt, socks_alt,
                       coach_name, coach_email, coach_phone, verification_name, CURRENT_DATE, $2::int
                  FROM cup_rosters WHERE id = $1::int RETURNING id)SQL", {std::to_string(last[0]["id"].as<long long>()), uid});
        } else {
            made = db->query(R"SQL(
                WITH d AS (SELECT tier, body FROM message_templates WHERE kind = 'cup_roster' AND is_active),
                     coach AS (
                       SELECT COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'') AS name,
                              (SELECT e.email FROM person_emails e WHERE e.person_id = p.id ORDER BY e.is_primary DESC NULLS LAST, e.id LIMIT 1) AS email,
                              (SELECT x.phone_number FROM person_phones x WHERE x.person_id = p.id ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS phone
                         FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id JOIN persons p ON p.id = c.person_id
                         JOIN teams t ON t.id = tc.team_id JOIN club_sections cs ON cs.id = t.club_section_id AND cs.code = 'M'
                        WHERE tc.ended_at IS NULL ORDER BY t.board_sort_order, tc.started_at LIMIT 1)
                INSERT INTO cup_rosters (team_name, cup, state_association, competition, state, coach_name, coach_email, coach_phone, sheet_date, created_by_user_id)
                SELECT COALESCE((SELECT body FROM d WHERE tier = 'default_team_name'), ''),
                       COALESCE((SELECT body FROM d WHERE tier = 'default_cup'), ''),
                       COALESCE((SELECT body FROM d WHERE tier = 'default_assoc'), ''),
                       COALESCE((SELECT body FROM d WHERE tier = 'default_competition'), ''),
                       COALESCE((SELECT body FROM d WHERE tier = 'default_state'), ''),
                       COALESCE((SELECT name FROM coach), ''), COALESCE((SELECT email FROM coach), ''), COALESCE((SELECT phone FROM coach), ''),
                       CURRENT_DATE, $1::int
                RETURNING id)SQL", {uid});
        }
        return jsonOut(HttpStatus::OK, {{"id", made[0]["id"].as<long long>()}});
    } catch (const std::exception& e) { std::cerr << "[cup-rosters new] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response CupRosterController::handleGet(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "bad id");
    try {
        json sheet = sheetJson(Database::getInstance(), "r.id = $1::int", std::to_string(id));
        if (sheet.is_null()) return jsonError(HttpStatus::NOT_FOUND, "no such sheet");
        return jsonOut(HttpStatus::OK, sheet);
    } catch (const std::exception& e) { std::cerr << "[cup-rosters get] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// POST /:id/update { field: value, … } — any header field, sheet_date as ISO.
Response CupRosterController::handleUpdate(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "bad id");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    try {
        auto* db = Database::getInstance();
        for (const char* f : kHeaderFields) {
            if (!body.contains(f)) continue;
            const std::string v = body[f].is_string() ? body[f].get<std::string>() : body[f].dump();
            db->query(std::string("UPDATE cup_rosters SET ") + f + " = $2, updated_at = now() WHERE id = $1::int", {std::to_string(id), v});
        }
        if (body.contains("sheet_date")) {
            const std::string v = body["sheet_date"].is_string() ? body["sheet_date"].get<std::string>() : "";
            db->query("UPDATE cup_rosters SET sheet_date = NULLIF($2,'')::date, updated_at = now() WHERE id = $1::int", {std::to_string(id), v});
        }
        return jsonOut(HttpStatus::OK, sheetJson(db, "r.id = $1::int", std::to_string(id)));
    } catch (const std::exception& e) { std::cerr << "[cup-rosters update] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// POST /:id/players { person_ids: [...] } — the ticked set, in surname order.
Response CupRosterController::handlePlayers(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "bad id");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    if (!body.contains("person_ids") || !body["person_ids"].is_array()) return jsonError(HttpStatus::BAD_REQUEST, "person_ids required");
    std::set<long long> ids;
    for (const auto& v : body["person_ids"]) { if (v.is_number_integer()) ids.insert(v.get<long long>()); else if (v.is_string()) { try { ids.insert(std::stoll(v.get<std::string>())); } catch (...) {} } }
    if ((int)ids.size() > kPoolMax) return jsonError(HttpStatus::BAD_REQUEST, "Pool is set at " + std::to_string(kPoolMax) + ".");
    try {
        auto* db = Database::getInstance();
        std::string arr = "{"; bool first = true;
        for (long long v : ids) { if (!first) arr += ','; first = false; arr += std::to_string(v); }
        arr += "}";
        db->query("DELETE FROM cup_roster_players WHERE cup_roster_id = $1::int AND NOT (person_id = ANY($2::int[]))", {std::to_string(id), arr});
        db->query(R"SQL(
            INSERT INTO cup_roster_players (cup_roster_id, person_id, sort_order)
            SELECT $1::int, p.id, 0 FROM persons p WHERE p.id = ANY($2::int[])
            ON CONFLICT DO NOTHING)SQL", {std::to_string(id), arr});
        // Surname order on the sheet.
        db->query(R"SQL(
            UPDATE cup_roster_players cp SET sort_order = o.n
              FROM (SELECT cp2.person_id, row_number() OVER (ORDER BY p.last_name, p.first_name) AS n
                      FROM cup_roster_players cp2 JOIN persons p ON p.id = cp2.person_id WHERE cp2.cup_roster_id = $1::int) o
             WHERE cp.cup_roster_id = $1::int AND cp.person_id = o.person_id)SQL", {std::to_string(id)});
        db->query("UPDATE cup_rosters SET updated_at = now() WHERE id = $1::int", {std::to_string(id)});
        return jsonOut(HttpStatus::OK, sheetJson(db, "r.id = $1::int", std::to_string(id)));
    } catch (const std::exception& e) { std::cerr << "[cup-rosters players] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response CupRosterController::handleDelete(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    long long id = 0; try { id = std::stoll(request.getQueryParam("id")); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try { Database::getInstance()->query("DELETE FROM cup_rosters WHERE id = $1::int", {std::to_string(id)}); return jsonOut(HttpStatus::OK, {{"ok", true}}); }
    catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// GET /api/cup-rosters/public/<slug> — no sign-in; the slug is a UUID, so the
// link is the only way in.  The printable page /cup-roster?k=<slug>.
Response CupRosterController::handlePublic(const Request& request) {
    const std::string path = request.getPath();
    const std::string marker = "/public/";
    const auto at = path.find(marker);
    if (at == std::string::npos) return jsonError(HttpStatus::BAD_REQUEST, "bad link");
    std::string slug = path.substr(at + marker.size());
    const auto q = slug.find('?'); if (q != std::string::npos) slug = slug.substr(0, q);
    const auto sl = slug.find('/'); if (sl != std::string::npos) slug = slug.substr(0, sl);
    if (slug.size() != 36) return jsonError(HttpStatus::NOT_FOUND, "no such sheet");
    try {
        json sheet = sheetJson(Database::getInstance(), "r.public_slug::text = $1", slug);
        if (sheet.is_null()) return jsonError(HttpStatus::NOT_FOUND, "no such sheet");
        sheet.erase("public_slug");
        return jsonOut(HttpStatus::OK, sheet);
    } catch (const std::exception& e) { std::cerr << "[cup-rosters public] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
