#include "MyController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <exception>
#include <iostream>
#include <optional>
#include <string>

using nlohmann::json;

namespace {

Response jsonError(HttpStatus s, const std::string& msg) {
    json body = {{"error", msg}};
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonOk(const json& body) {
    Response r(HttpStatus::OK, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

// Decode a JWT payload, look for the string "userId" claim (which is
// what AuthController emits at login time), then map users.id →
// persons.id.  Returns 0 on any failure.  Only called after the
// signature has been verified by verifyJwtHS256.
long long personIdFromJwtPayload(const std::string& payloadJson) {
    const std::string needle = "\"userId\":\"";
    auto pos = payloadJson.find(needle);
    if (pos == std::string::npos) return 0;
    pos += needle.size();
    auto end = payloadJson.find('"', pos);
    if (end == std::string::npos) return 0;
    const std::string userIdStr = payloadJson.substr(pos, end - pos);
    if (userIdStr.empty()) return 0;

    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT person_id FROM users WHERE id = $1::int LIMIT 1",
            {userIdStr});
        if (r.empty() || r[0]["person_id"].is_null()) return 0;
        return r[0]["person_id"].as<long long>();
    } catch (...) {
        return 0;
    }
}

struct SessionGate {
    std::optional<SessionService::ResolvedSession> session;
    std::optional<Response>                        error;
};

// Accepts either the fh_sess cookie session OR a JWT bearer.  MyController
// endpoints are called from both the magic-link flow (cookie) and the
// regular password/OAuth flow (JWT), so we transparently support both.
SessionGate requireSession(const Request& request) {
    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (resolved) {
        return {std::move(resolved), std::nullopt};
    }

    // Cookie missing / expired → fall back to JWT bearer if present.
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long personId = personIdFromJwtPayload(payloadJson);
            if (personId > 0) {
                SessionService::ResolvedSession synth;
                synth.sessionId = "";        // JWT flow has no session row
                synth.personId  = personId;
                return {std::move(synth), std::nullopt};
            }
        }
    }

    return {std::nullopt,
            jsonError(HttpStatus::UNAUTHORIZED,
                      sessVal.empty() ? "Not signed in" : "Session expired")};
}

// Resolve players.id for the caller.  Only signed-in persons with a
// `players` row can RSVP or hold recurring preferences — matches
// player_rsvp_history's FK on player_id.  Returns 0 when the caller
// is not yet a player (they'll get a 403 in that case).
long long resolvePlayerId(long long personId) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "SELECT id FROM players WHERE person_id = $1::int LIMIT 1",
        {std::to_string(personId)});
    if (r.empty() || r[0]["id"].is_null()) return 0;
    return r[0]["id"].as<long long>();
}

// Resolve users.id for a person — audit FK on the rsvp_history INSERT.
// Returns empty string when there's no users row (RSVP audit stays
// NULL in that case).
std::string resolveChangedByUserId(long long personId) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "SELECT id FROM users WHERE person_id = $1::int LIMIT 1",
        {std::to_string(personId)});
    if (r.empty() || r[0]["id"].is_null()) return {};
    return std::to_string(r[0]["id"].as<long long>());
}

// Verify the caller is on the match's home_team roster.  Returns
// false if the match doesn't exist, is cancelled, or the caller is
// not currently assigned to home_team.  Uses the same
// external_person_aliases bridge as RsvpMaterialization.
// Eligibility rules (see repo memory: footballhome.md § RSVP eligibility):
//   practice (mt=3):        active mens roster to team ∈ (35 APSL, 120 Liga1, 121 Liga2)
//   game APSL home (mt∈{1,4,6}, home=35):  active mens roster to team ∈ (35, 120)  (play-up)
//   game other (mt∈{1,4,6}): active mens roster to team = home_team_id
//   pickup (mt=7):          ANY mens roster (active OR soft-deleted purgatory)
//   other (mt∈{2,5}):       fall back to active roster to team = home_team_id
bool callerRosteredForMatch(long long personId, long long matchId) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "SELECT 1 "
        "  FROM matches m "
        "  JOIN external_person_aliases epa "
        "    ON epa.provider = 'leagueapps' "
        "   AND epa.person_id = $2::int "
        "  JOIN roster_assignments mta "
        "    ON mta.domain = 'mens' "
        "   AND mta.leagueapps_user_id::text = epa.external_user_id "
        "   AND ( "
        "     m.match_type_id = 7 "
        "     OR ( "
        "       mta.removed_at IS NULL "
        "       AND mta.team_id = ANY( "
        "         CASE "
        "           WHEN m.match_type_id = 3 THEN ARRAY[35, 120, 121] "
        "           WHEN m.match_type_id IN (1,4,6) AND m.home_team_id = 35 THEN ARRAY[35, 120] "
        "           ELSE ARRAY[m.home_team_id] "
        "         END "
        "       ) "
        "     ) "
        "   ) "
        " WHERE m.id = $1::int "
        "   AND m.cancelled_at IS NULL "
        " LIMIT 1",
        {std::to_string(matchId), std::to_string(personId)});
    return !r.empty();
}

std::optional<long long> jsonInt(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return std::nullopt;
    if (j[key].is_number_integer())  return j[key].get<long long>();
    if (j[key].is_number_unsigned()) return static_cast<long long>(j[key].get<unsigned long long>());
    if (j[key].is_number_float())    return static_cast<long long>(j[key].get<double>());
    if (j[key].is_string()) {
        try { return std::stoll(j[key].get<std::string>()); }
        catch (...) { return std::nullopt; }
    }
    return std::nullopt;
}

}  // namespace

MyController::MyController() = default;
MyController::~MyController() = default;

void MyController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix is "/api/my".
    router.get (prefix + "/week",      [this](const Request& r) { return handleGetWeek(r); });
    router.post(prefix + "/rsvp",      [this](const Request& r) { return handlePostRsvp(r); });
    router.get (prefix + "/recurring", [this](const Request& r) { return handleGetRecurring(r); });
    router.put (prefix + "/recurring", [this](const Request& r) { return handlePutRecurring(r); });
}

// GET /api/my/week
// Returns:
//   {
//     "player_id": int|null,
//     "events": [
//       { "match_id": int, "match_type_id": int, "match_type": str,
//         "home_team_id": int, "match_date": "YYYY-MM-DD",
//         "match_time": "HH:MI:SS", "end_time": "HH:MI:SS"|null,
//         "venue_id": int|null, "title": str|null,
//         "rsvp_opens_at": iso, "series_id": int|null,
//         "my_rsvp": { "rsvp_status_id": int, "status": str, "notes": str|null } | null
//       }, ...
//     ]
//   }
//
// Filters:
//   - rsvp_opens_at <= NOW  (window is currently open)
//   - cancelled_at IS NULL
//   - match_date >= today (America/New_York)
//   - caller is rostered to home_team_id via
//     external_person_aliases → mens_team_assignments
Response MyController::handleGetWeek(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    auto* db = Database::getInstance();
    try {
        const long long playerId = resolvePlayerId(personId);

        auto rows = db->query(
            // Eligibility rules — keep in sync with callerRosteredForMatch()
            // above and services/RsvpMaterialization.cpp kApplyRecurringSql.
            "WITH eligible_matches AS ( "
            "  SELECT DISTINCT m.id, m.match_type_id, m.home_team_id, m.match_date, "
            "         m.match_time, m.end_time, m.venue_id, m.title, "
            "         m.description, m.rsvp_opens_at, m.series_id "
            "    FROM matches m "
            "    JOIN external_person_aliases epa "
            "      ON epa.provider = 'leagueapps' "
            "     AND epa.person_id = $1::int "
            "    JOIN roster_assignments mta "
            "      ON mta.domain = 'mens' "
            "     AND mta.leagueapps_user_id::text = epa.external_user_id "
            "     AND ( "
            "       m.match_type_id = 7 "
            "       OR ( "
            "         mta.removed_at IS NULL "
            "         AND mta.team_id = ANY( "
            "           CASE "
            "             WHEN m.match_type_id = 3 THEN ARRAY[35, 120, 121] "
            "             WHEN m.match_type_id IN (1,4,6) AND m.home_team_id = 35 THEN ARRAY[35, 120] "
            "             ELSE ARRAY[m.home_team_id] "
            "           END "
            "         ) "
            "       ) "
            "     ) "
            "   WHERE m.cancelled_at IS NULL "
            "     AND m.rsvp_opens_at IS NOT NULL "
            "     AND m.rsvp_opens_at <= NOW() "
            "     AND m.match_date >= (NOW() AT TIME ZONE 'America/New_York')::date "
            ") "
            "SELECT em.id AS match_id, em.match_type_id, mt.name AS match_type, "
            "       em.home_team_id, em.match_date::text AS match_date, "
            "       to_char(em.match_time, 'HH24:MI:SS') AS match_time, "
            "       to_char(em.end_time,   'HH24:MI:SS') AS end_time, "
            "       em.venue_id, em.title, em.description, "
            "       to_char(em.rsvp_opens_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS rsvp_opens_at, "
            "       em.series_id, "
            "       ( "
            "         SELECT jsonb_build_object( "
            "                  'rsvp_status_id', h.rsvp_status_id, "
            "                  'status',         rs.name, "
            "                  'notes',          h.notes, "
            "                  'change_source',  cs.name, "
            "                  'changed_at', to_char(h.changed_at AT TIME ZONE 'UTC', "
            "                                        'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') "
            "                ) "
            "           FROM player_rsvp_history h "
            "           JOIN rsvp_statuses rs ON rs.id = h.rsvp_status_id "
            "           LEFT JOIN rsvp_change_sources cs ON cs.id = h.change_source_id "
            "          WHERE h.event_id = em.id "
            "            AND h.player_id = $2::int "
            "          ORDER BY h.changed_at DESC "
            "          LIMIT 1 "
            "       ) AS my_rsvp "
            "  FROM eligible_matches em "
            "  JOIN match_types mt ON mt.id = em.match_type_id "
            " ORDER BY em.match_date, em.match_time",
            {std::to_string(personId), std::to_string(playerId)});

        json events = json::array();
        for (const auto& row : rows) {
            auto strOrNull = [&](const char* col) -> json {
                return row[col].is_null()
                       ? json(nullptr)
                       : json(row[col].as<std::string>());
            };
            auto intOrNull = [&](const char* col) -> json {
                return row[col].is_null()
                       ? json(nullptr)
                       : json(row[col].as<long long>());
            };
            json rsvp = nullptr;
            if (!row["my_rsvp"].is_null()) {
                rsvp = json::parse(row["my_rsvp"].as<std::string>());
            }
            events.push_back({
                {"match_id",      row["match_id"].as<long long>()},
                {"match_type_id", row["match_type_id"].as<long long>()},
                {"match_type",    row["match_type"].as<std::string>()},
                {"home_team_id",  intOrNull("home_team_id")},
                {"match_date",    strOrNull("match_date")},
                {"match_time",    strOrNull("match_time")},
                {"end_time",      strOrNull("end_time")},
                {"venue_id",      intOrNull("venue_id")},
                {"title",         strOrNull("title")},
                {"description",   strOrNull("description")},
                {"rsvp_opens_at", strOrNull("rsvp_opens_at")},
                {"series_id",     intOrNull("series_id")},
                {"my_rsvp",       rsvp},
            });
        }

        // Membership status — for the purgatory banner.  'active' means
        // at least one active mens roster_assignment; 'purgatory' means
        // every mens row is soft-deleted (delinquent dues); 'none' means
        // no mens rows at all (shouldn't normally happen for signed-in
        // players, but guard anyway).
        std::string membershipStatus = "none";
        long long purgatoryDaysOverdue = 0;
        {
            auto s = db->query(
                "SELECT "
                "  COUNT(*) FILTER (WHERE mta.removed_at IS NULL) AS active_ct, "
                "  COUNT(*) FILTER (WHERE mta.removed_at IS NOT NULL) AS purgatory_ct, "
                "  EXTRACT(DAY FROM (NOW() - MIN(mta.removed_at)))::int AS days_overdue "
                "  FROM external_person_aliases epa "
                "  JOIN roster_assignments mta "
                "    ON mta.domain = 'mens' "
                "   AND mta.leagueapps_user_id::text = epa.external_user_id "
                " WHERE epa.provider = 'leagueapps' "
                "   AND epa.person_id = $1::int",
                {std::to_string(personId)});
            if (!s.empty()) {
                const long long activeCt   = s[0]["active_ct"].as<long long>();
                const long long purgCt     = s[0]["purgatory_ct"].as<long long>();
                if (activeCt > 0)       membershipStatus = "active";
                else if (purgCt > 0)    membershipStatus = "purgatory";
                if (membershipStatus == "purgatory" && !s[0]["days_overdue"].is_null()) {
                    purgatoryDaysOverdue = s[0]["days_overdue"].as<long long>();
                }
            }
        }

        json response = {
            {"player_id",         playerId == 0 ? json(nullptr) : json(playerId)},
            {"membership_status", membershipStatus},
            {"events",            events},
        };
        if (membershipStatus == "purgatory") {
            response["purgatory_days_overdue"] = purgatoryDaysOverdue;
        }
        return jsonOk(response);
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/my/week] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/my/rsvp
// Body: {match_id, rsvp_status_id, note?}
// Inserts a player_rsvp_history row with change_source_id=1 (app).
Response MyController::handlePostRsvp(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    auto matchIdOpt  = jsonInt(body, "match_id");
    auto statusIdOpt = jsonInt(body, "rsvp_status_id");
    if (!matchIdOpt  || *matchIdOpt  <= 0)
        return jsonError(HttpStatus::BAD_REQUEST, "match_id required");
    if (!statusIdOpt || *statusIdOpt <= 0)
        return jsonError(HttpStatus::BAD_REQUEST, "rsvp_status_id required");

    const long long matchId  = *matchIdOpt;
    const long long statusId = *statusIdOpt;

    std::string note;
    if (body.contains("note") && body["note"].is_string()) {
        note = body["note"].get<std::string>();
    }

    // Membership check first (403 before we touch history).
    if (!callerRosteredForMatch(personId, matchId)) {
        return jsonError(HttpStatus::FORBIDDEN, "not rostered on this team");
    }

    const long long playerId = resolvePlayerId(personId);
    if (playerId == 0) {
        return jsonError(HttpStatus::FORBIDDEN, "no player record");
    }

    auto* db = Database::getInstance();
    try {
        const std::string changedBy = resolveChangedByUserId(personId);
        std::vector<std::string> params = {
            std::to_string(matchId),
            std::to_string(playerId),
            std::to_string(statusId),
            changedBy,   // may be empty; passed as NULL via COALESCE below
            note,
        };
        auto r = db->query(
            "INSERT INTO player_rsvp_history "
            "  (event_id, player_id, rsvp_status_id, changed_by, "
            "   change_source_id, notes) "
            "VALUES ($1::int, $2::int, $3::int, "
            "        NULLIF($4, '')::int, 1, NULLIF($5, '')) "
            "RETURNING id, changed_at",
            params);

        if (r.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "insert failed");
        }

        return jsonOk({
            {"success",  true},
            {"rsvp_id",  r[0]["id"].as<std::string>()},
        });
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/rsvp] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /api/my/recurring
Response MyController::handleGetRecurring(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    auto* db = Database::getInstance();
    try {
        auto rows = db->query(
            "SELECT prr.day_of_week, prr.match_type_id, mt.name AS match_type, "
            "       prr.rsvp_status_id, rs.name AS status "
            "  FROM player_recurring_rsvps prr "
            "  JOIN match_types    mt ON mt.id = prr.match_type_id "
            "  JOIN rsvp_statuses  rs ON rs.id = prr.rsvp_status_id "
            " WHERE prr.person_id = $1::int "
            " ORDER BY prr.day_of_week, prr.match_type_id",
            {std::to_string(personId)});

        json prefs = json::array();
        for (const auto& r : rows) {
            prefs.push_back({
                {"day_of_week",    r["day_of_week"].as<int>()},
                {"match_type_id",  r["match_type_id"].as<long long>()},
                {"match_type",     r["match_type"].as<std::string>()},
                {"rsvp_status_id", r["rsvp_status_id"].as<long long>()},
                {"status",         r["status"].as<std::string>()},
            });
        }
        return jsonOk({{"prefs", prefs}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/my/recurring] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /api/my/recurring
// Body: {prefs: [{day_of_week, match_type_id, rsvp_status_id}]}
// Replaces the caller's entire prefs set (delete-then-insert).
// Empty prefs array clears all preferences.
Response MyController::handlePutRecurring(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    if (!body.contains("prefs") || !body["prefs"].is_array()) {
        return jsonError(HttpStatus::BAD_REQUEST, "prefs array required");
    }
    const auto& incoming = body["prefs"];

    // Validate every row up-front so a bad element short-circuits
    // before we mutate the DB.
    struct Row { int dow; long long mtype; long long status; };
    std::vector<Row> rows;
    rows.reserve(incoming.size());
    for (const auto& p : incoming) {
        auto dowOpt   = jsonInt(p, "day_of_week");
        auto mtypeOpt = jsonInt(p, "match_type_id");
        auto statOpt  = jsonInt(p, "rsvp_status_id");
        if (!dowOpt || *dowOpt < 0 || *dowOpt > 6)
            return jsonError(HttpStatus::BAD_REQUEST, "day_of_week 0-6 required");
        if (!mtypeOpt  || *mtypeOpt  <= 0)
            return jsonError(HttpStatus::BAD_REQUEST, "match_type_id required");
        if (!statOpt   || *statOpt   <= 0)
            return jsonError(HttpStatus::BAD_REQUEST, "rsvp_status_id required");
        rows.push_back({static_cast<int>(*dowOpt), *mtypeOpt, *statOpt});
    }

    auto* db = Database::getInstance();
    try {
        // Delete-then-insert.  We don't wrap this in an explicit
        // transaction because Database::query() commits each call,
        // but the pk (person_id, day_of_week, match_type_id) makes
        // the insert step idempotent even if a race happens.
        db->query(
            "DELETE FROM player_recurring_rsvps WHERE person_id = $1::int",
            {std::to_string(personId)});

        for (const auto& r : rows) {
            db->query(
                "INSERT INTO player_recurring_rsvps "
                "  (person_id, day_of_week, match_type_id, rsvp_status_id) "
                "VALUES ($1::int, $2::smallint, $3::int, $4::int) "
                "ON CONFLICT (person_id, day_of_week, match_type_id) "
                "DO UPDATE SET rsvp_status_id = EXCLUDED.rsvp_status_id, "
                "              updated_at = NOW()",
                {std::to_string(personId),
                 std::to_string(r.dow),
                 std::to_string(r.mtype),
                 std::to_string(r.status)});
        }

        return jsonOk({{"success", true}, {"count", static_cast<int>(rows.size())}});
    } catch (const std::exception& e) {
        std::cerr << "[PUT /api/my/recurring] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
