#include "AwardsController.h"

#include <iostream>
#include <set>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        if (!body->is_object()) *body = json::object();
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}

long long intField(const json& body, const char* key) {
    if (!body.contains(key)) return 0;
    if (body[key].is_number()) return body[key].get<long long>();
    if (body[key].is_string()) { try { return std::stoll(body[key].get<std::string>()); } catch (...) {} }
    return 0;
}

std::string strField(const json& body, const char* key) {
    return body.contains(key) && body[key].is_string() ? body[key].get<std::string>() : std::string();
}

}  // namespace

void AwardsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",  [this](const Request& r) { return handleBoard(r); });
    router.post(prefix + "/toggle", [this](const Request& r) { return handleToggle(r); });
    router.post(prefix + "/sent",   [this](const Request& r) { return handleSent(r); });
}

bool AwardsController::gate(const Request& request, Response* error, long long* personId) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    auto* db = Database::getInstance();
    const std::string uid = std::to_string(bearerUserId(request));
    auto who = db->query("SELECT person_id FROM users WHERE id = $1::int", {uid});
    *personId = (who.empty() || who[0]["person_id"].is_null()) ? 0 : who[0]["person_id"].as<long long>();
    if (!db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {uid}).empty())
        return true;
    if (!db->query("SELECT 1 FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id "
                   "  JOIN users u ON u.person_id = c.person_id "
                   " WHERE u.id = $1::int AND tc.ended_at IS NULL LIMIT 1", {uid}).empty())
        return true;
    // 403, not 401 — a signed-in non-staff is not a dead session.
    *error = jsonError(HttpStatus::FORBIDDEN, "Awards are for club admins and coaches.");
    return false;
}

// The season's teams (team_terms, mig 795 — a team with no terms shows in
// every season), each with its players, the awards given, its league
// director and the sends so far.  No term → the current one; no year →
// the year the current term began.
Response AwardsController::handleBoard(const Request& request) {
    Response err(HttpStatus::OK, "");
    long long me = 0;
    if (!gate(request, &err, &me)) return err;
    const std::string term = request.hasQueryParam("term") ? request.getQueryParam("term") : "";
    const std::string year = request.hasQueryParam("year") ? request.getQueryParam("year") : "";
    try {
        auto rows = Database::getInstance()->query(R"SQL(
          WITH season AS (
            SELECT COALESCE(NULLIF($1, ''), fh_current_term()) AS term,
                   COALESCE(NULLIF($2, '')::int,
                            (SELECT CASE WHEN make_date(extract(year FROM d)::int, t.starts_month, t.starts_day) <= d
                                         THEN extract(year FROM d)::int ELSE extract(year FROM d)::int - 1 END
                               FROM year_terms t, (SELECT (now() AT TIME ZONE 'America/New_York')::date AS d) x
                              WHERE t.code = fh_current_term())) AS year
          ), tm AS (
            SELECT t.* FROM teams t, season s
             WHERE t.is_active AND t.board_sort_order IS NOT NULL
               AND (EXISTS (SELECT 1 FROM team_terms tt WHERE tt.team_id = t.id AND tt.term = s.term)
                    OR NOT EXISTS (SELECT 1 FROM team_terms tt WHERE tt.team_id = t.id))
          )
          SELECT json_build_object(
            'term', s.term, 'year', s.year,
            'terms', (SELECT json_agg(json_build_object('code', code, 'label', label) ORDER BY sort_order) FROM year_terms),
            'types', (SELECT json_agg(json_build_object('code', code, 'label', label, 'emoji', emoji, 'is_league', is_league) ORDER BY sort_order)
                        FROM award_types WHERE is_active),
            'teams', COALESCE((SELECT json_agg(json_build_object(
                'id', tm.id, 'label', COALESCE(tm.label, tm.name), 'color', tm.color, 'section', tm.gender_category,
                'director', (SELECT json_build_object('name', cc.name, 'email', cc.email, 'phone', cc.phone,
                                                      'league_team', d.league_team_label)
                               FROM team_league_directors d JOIN club_contacts cc ON cc.id = d.club_contact_id
                              WHERE d.team_id = tm.id),
                'players', COALESCE((SELECT json_agg(json_build_object(
                                'person_id', p.id,
                                'name', BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')),
                                'age', CASE WHEN tm.gender_category IN ('boys', 'girls')
                                            THEN fh_youth_single_age(p.birth_date, s.year + 1) END)
                              ORDER BY p.last_name, p.first_name)
                       FROM (SELECT DISTINCT person_id FROM team_persons
                              WHERE team_id = tm.id AND removed_at IS NULL) r
                       JOIN persons p ON p.id = r.person_id), '[]'),
                'awards', COALESCE((SELECT json_agg(json_build_object('person_id', a.person_id, 'award_code', a.award_code))
                       FROM person_awards a
                      WHERE a.team_id = tm.id AND a.term = s.term AND a.season_year = s.year), '[]'),
                'sends', COALESCE((SELECT json_agg(json_build_object('award_code', x.award_code, 'channel', x.channel,
                                                                    'sent_at', x.sent_at) ORDER BY x.sent_at DESC)
                       FROM award_submissions x
                      WHERE x.team_id = tm.id AND x.term = s.term AND x.season_year = s.year), '[]')
              ) ORDER BY tm.board_sort_order, tm.id) FROM tm), '[]'),
            'sender', (SELECT BTRIM(COALESCE(first_name, '') || ' ' || COALESCE(last_name, '')) FROM persons WHERE id = $3::int)
          )::text AS body
          FROM season s)SQL", {term, year, std::to_string(me)});
        Response r(HttpStatus::OK, rows[0]["body"].c_str());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "AwardsController::handleBoard: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load awards");
    }
}

// Give (on) or take back (off) one award.
Response AwardsController::handleToggle(const Request& request) {
    Response err(HttpStatus::OK, "");
    long long me = 0;
    if (!gate(request, &err, &me)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    const long long personId = intField(body, "person_id"), teamId = intField(body, "team_id"), year = intField(body, "year");
    const std::string code = strField(body, "award_code"), term = strField(body, "term");
    const bool on = body.value("on", true);
    if (!personId || !teamId || !year || code.empty() || term.empty())
        return jsonError(HttpStatus::BAD_REQUEST, "person_id, team_id, award_code, term and year are required");
    try {
        auto* db = Database::getInstance();
        const std::vector<std::string> p = {std::to_string(personId), std::to_string(teamId), code, term, std::to_string(year)};
        if (on) {
            db->query("INSERT INTO person_awards (person_id, team_id, award_code, term, season_year, awarded_by_person_id) "
                      "VALUES ($1::int, $2::int, $3, $4, $5::int, NULLIF($6, '0')::int) ON CONFLICT DO NOTHING",
                      {p[0], p[1], p[2], p[3], p[4], std::to_string(me)});
        } else {
            db->query("DELETE FROM person_awards WHERE person_id = $1::int AND team_id = $2::int AND award_code = $3 "
                      "   AND term = $4 AND season_year = $5::int", p);
        }
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "AwardsController::handleToggle: " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, "Could not save that award");
    }
}

// The page opened the email / text to the league director — record it.
Response AwardsController::handleSent(const Request& request) {
    Response err(HttpStatus::OK, "");
    long long me = 0;
    if (!gate(request, &err, &me)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    const long long teamId = intField(body, "team_id"), year = intField(body, "year");
    const std::string code = strField(body, "award_code"), term = strField(body, "term"), channel = strField(body, "channel");
    if (!teamId || !year || code.empty() || term.empty() || (channel != "email" && channel != "text"))
        return jsonError(HttpStatus::BAD_REQUEST, "team_id, award_code, term, year and channel (email|text) are required");
    try {
        Database::getInstance()->query(
            "INSERT INTO award_submissions (team_id, award_code, term, season_year, club_contact_id, channel, sent_by_person_id) "
            "SELECT $1::int, $2, $3, $4::int, (SELECT club_contact_id FROM team_league_directors WHERE team_id = $1::int), $5, NULLIF($6, '0')::int",
            {std::to_string(teamId), code, term, std::to_string(year), channel, std::to_string(me)});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "AwardsController::handleSent: " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, "Could not record the send");
    }
}
