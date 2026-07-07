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
//
// SECURITY: When BOTH a Bearer JWT and an fh_sess cookie are present we
// prefer the Bearer JWT.  The JWT is scoped to localStorage of the
// specific browser/tab that just logged in via OAuth, while the cookie
// can bleed across users on shared devices (e.g. someone clicked a
// different user's magic-link email on this phone earlier).  Preferring
// the JWT prevents the "logged in as A but seeing B's data" class of
// bug — the 2026-07-06 incident that motivated this comment.
SessionGate requireSession(const Request& request) {
    // Try Bearer JWT first — it's the explicit "I just logged in as X"
    // signal from the frontend and always represents the current tab's
    // intent, unlike cookies which persist across users.
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

    // No Bearer (or Bearer invalid) → fall back to the fh_sess cookie
    // used by the magic-link flow.
    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (resolved) {
        return {std::move(resolved), std::nullopt};
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
//   pickup (mt=7):          ANY mens roster (active OR soft-deleted / dues-owed)
// Pure roster model (2026-07-07):  a person is eligible for a match
// iff they hold an active `roster_assignments` row on the match's
// home_team.  Play-up is expressed by putting the same person on
// multiple team rosters; pool events (practice/pickup) work because
// their home_team_id points at a pool team and every eligible person
// is on that pool team's roster.
bool callerRosteredForMatch(long long personId, long long matchId) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "SELECT 1 "
        "  FROM matches m "
        "  JOIN roster_assignments ra "
        "    ON ra.team_id = m.home_team_id "
        "   AND ra.removed_at IS NULL "
        "  JOIN external_person_aliases epa "
        "    ON epa.provider = 'leagueapps' "
        "   AND epa.external_user_id = ra.leagueapps_user_id::text "
        " WHERE m.id = $1::int "
        "   AND m.cancelled_at IS NULL "
        "   AND epa.person_id = $2::int "
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
    router.get (prefix + "/week",           [this](const Request& r) { return handleGetWeek(r); });
    router.post(prefix + "/rsvp",           [this](const Request& r) { return handlePostRsvp(r); });
    router.get (prefix + "/recurring",      [this](const Request& r) { return handleGetRecurring(r); });
    router.put (prefix + "/recurring",      [this](const Request& r) { return handlePutRecurring(r); });
    router.get (prefix + "/chat/messages",  [this](const Request& r) { return handleGetChatMessages(r); });
    router.post(prefix + "/chat/messages",  [this](const Request& r) { return handlePostChatMessage(r); });
    router.get (prefix + "/event-rsvps",    [this](const Request& r) { return handleGetEventRsvps(r); });
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
            // Pure roster eligibility (2026-07-07): match visible iff
            // caller has an active roster_assignments row on the
            // match's home_team.  Keep in sync with
            // callerRosteredForMatch() and
            // services/RsvpMaterialization.cpp kApplyRecurringSql.
            "WITH eligible_matches AS ( "
            "  SELECT DISTINCT m.id, m.match_type_id, m.home_team_id, m.match_date, "
            "         m.match_time, m.end_time, m.venue_id, m.title, "
            "         m.description, m.rsvp_opens_at, m.series_id "
            "    FROM matches m "
            "    JOIN roster_assignments ra "
            "      ON ra.team_id = m.home_team_id "
            "     AND ra.removed_at IS NULL "
            "    JOIN external_person_aliases epa "
            "      ON epa.provider = 'leagueapps' "
            "     AND epa.external_user_id = ra.leagueapps_user_id::text "
            "     AND epa.person_id = $1::int "
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

        // Membership status — drives the amber "dues owed" banner in
        // the frontend.  Pure roster model (2026-07-07): any club
        // membership counts.  'active' = at least one active
        // roster_assignments row; 'dues_owed' = only soft-deleted rows;
        // 'none' = no rows at all (e.g. a person who was never rostered
        // or fully cleared out).
        std::string membershipStatus = "none";
        long long duesDaysOverdue = 0;
        {
            auto s = db->query(
                "SELECT "
                "  COUNT(*) FILTER (WHERE ra.removed_at IS NULL)     AS active_ct, "
                "  COUNT(*) FILTER (WHERE ra.removed_at IS NOT NULL) AS dues_owed_ct, "
                "  EXTRACT(DAY FROM (NOW() - MIN(ra.removed_at)))::int AS days_overdue "
                "  FROM external_person_aliases epa "
                "  JOIN roster_assignments ra "
                "    ON ra.leagueapps_user_id::text = epa.external_user_id "
                " WHERE epa.provider = 'leagueapps' "
                "   AND epa.person_id = $1::int",
                {std::to_string(personId)});
            if (!s.empty()) {
                const long long activeCt = s[0]["active_ct"].as<long long>();
                const long long duesCt   = s[0]["dues_owed_ct"].as<long long>();
                if (activeCt > 0)     membershipStatus = "active";
                else if (duesCt > 0)  membershipStatus = "dues_owed";
                if (membershipStatus == "dues_owed" && !s[0]["days_overdue"].is_null()) {
                    duesDaysOverdue = s[0]["days_overdue"].as<long long>();
                }
            }
        }

        json response = {
            {"player_id",         playerId == 0 ? json(nullptr) : json(playerId)},
            {"membership_status", membershipStatus},
            {"events",            events},
        };
        if (membershipStatus == "dues_owed") {
            response["dues_days_overdue"] = duesDaysOverdue;
        }

        // Pickup signup CTA — always emit the free-tier pickup program URL
        // from `leagueapps_programs` so the frontend can render a
        // "Register for Pickup" card when membership_status == 'none' (no
        // mens roster row at all).  Sourced from DB (migration 097)
        // instead of hard-coding so ops can update the URL without a
        // code push if LA ever renames the program.  Silent fallback to
        // null when the row is missing (unmigrated dev DB) — frontend
        // just won't show the button.
        try {
            auto pu = db->query(
                "SELECT registration_url "
                "  FROM leagueapps_programs "
                " WHERE category = 'men' AND variant = 'pickup' "
                "   AND registration_url IS NOT NULL "
                " LIMIT 1");
            if (!pu.empty() && !pu[0]["registration_url"].is_null()) {
                response["pickup_signup_url"] = pu[0]["registration_url"].as<std::string>();
            } else {
                response["pickup_signup_url"] = nullptr;
            }
        } catch (const std::exception& e) {
            std::cerr << "[GET /api/my/week] pickup url lookup failed: "
                      << e.what() << std::endl;
            response["pickup_signup_url"] = nullptr;
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

// ─── Men's chat ───────────────────────────────────────────────────────
// The single "Chat" tab on /#my.  Practical stuff — cancellations,
// weather, running late, anything schedule-adjacent.  Membership is
// implicit: caller must be on the men's roster (any un-removed
// roster_assignments row with domain='mens') OR carry any admins row.
// No pins, no moderation, no image upload for v1.
//
// Message table: `chat_messages(chat_id, user_id, message, created_at)`.
// The men's chat id is looked up once by slug ('mens') from `chats`.

namespace {

// Return the chat.id for slug='mens', or 0 if not seeded.
long long mensChatId() {
    static long long cached = 0;
    if (cached > 0) return cached;
    try {
        auto* db = Database::getInstance();
        auto r = db->query("SELECT id FROM chats WHERE slug = 'mens' LIMIT 1", {});
        if (!r.empty() && !r[0]["id"].is_null()) {
            cached = r[0]["id"].as<long long>();
        }
    } catch (...) {}
    return cached;
}

// Return true if the caller is allowed to read/post in the men's chat.
// Rule: any un-removed men's roster row, OR any admins row.
bool isMensChatMember(long long personId) {
    if (personId <= 0) return false;
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT 1 FROM roster_assignments ra "
            "  JOIN external_person_aliases epa "
            "    ON epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = ra.leagueapps_user_id::text "
            " WHERE ra.domain = 'mens' "
            "   AND ra.removed_at IS NULL "
            "   AND epa.person_id = $1::int "
            " UNION ALL "
            "SELECT 1 FROM admins a "
            "  JOIN users u ON u.id = a.user_id "
            " WHERE u.person_id = $1::int "
            " LIMIT 1",
            {std::to_string(personId)});
        return !r.empty();
    } catch (const std::exception& e) {
        std::cerr << "[isMensChatMember] " << e.what() << std::endl;
        return false;
    }
}

// users.id for caller.  chat_messages.user_id is NOT NULL, so a
// missing users row means "cannot post" (403).
std::string usersIdForPerson(long long personId) {
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT id FROM users WHERE person_id = $1::int LIMIT 1",
            {std::to_string(personId)});
        if (!r.empty() && !r[0]["id"].is_null()) {
            return std::to_string(r[0]["id"].as<long long>());
        }
    } catch (...) {}
    return {};
}

std::string trimCopy(const std::string& s) {
    auto b = s.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return {};
    auto e = s.find_last_not_of(" \t\r\n");
    return s.substr(b, e - b + 1);
}

}  // namespace

// GET /api/my/chat/messages?since_id=<int>
// Returns:
//   {
//     "chat_id": int,
//     "messages": [
//       { "id": int, "user_id": int, "person_id": int,
//         "author_first_name": str, "author_last_name": str,
//         "message": str, "created_at": iso }, ...
//     ]
//   }
// Oldest-first order.  Hard cap of 200 rows.  since_id lets pollers
// fetch only new rows.
Response MyController::handleGetChatMessages(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    if (!isMensChatMember(personId)) {
        return jsonError(HttpStatus::FORBIDDEN, "Not a member of the men's chat");
    }

    const long long chatId = mensChatId();
    if (chatId <= 0) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "men's chat not configured");
    }

    // Optional since_id: clients pass their newest seen id to get
    // deltas only.  Missing / non-numeric → 0 (return all recent).
    long long sinceId = 0;
    const std::string sinceStr = request.getQueryParam("since_id");
    if (!sinceStr.empty()) {
        try { sinceId = std::stoll(sinceStr); } catch (...) { sinceId = 0; }
    }

    try {
        auto* db = Database::getInstance();
        // Order DESC + LIMIT 200 so we cap history, then reverse below
        // to send oldest-first.  since_id filter allows efficient polls.
        auto r = db->query(
            "SELECT cm.id, cm.user_id, u.person_id, "
            "       p.first_name, p.last_name, cm.message, "
            "       TO_CHAR(cm.created_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
            "       cm.created_at AS created_at_raw "
            "  FROM chat_messages cm "
            "  JOIN users   u ON u.id = cm.user_id "
            "  JOIN persons p ON p.id = u.person_id "
            " WHERE cm.chat_id = $1::int "
            "   AND cm.id > $2::int "
            " ORDER BY cm.created_at DESC, cm.id DESC "
            " LIMIT 200",
            {std::to_string(chatId), std::to_string(sinceId)});

        // Reverse to oldest-first for display.
        std::vector<json> messages;
        messages.reserve(r.size());
        for (auto it = r.rbegin(); it != r.rend(); ++it) {
            const auto& row = *it;
            messages.push_back({
                {"id",                row["id"].as<long long>()},
                {"user_id",           row["user_id"].as<long long>()},
                {"person_id",         row["person_id"].as<long long>()},
                {"author_first_name", row["first_name"].is_null() ? std::string{} : row["first_name"].as<std::string>()},
                {"author_last_name",  row["last_name"].is_null()  ? std::string{} : row["last_name"].as<std::string>()},
                {"message",           row["message"].as<std::string>()},
                {"created_at",        row["created_at"].as<std::string>()},
            });
        }
        // Include the viewer's own users.id so the client can style
        // their own bubbles ("mine" vs "theirs") without a second RTT.
        const std::string viewerIdStr = usersIdForPerson(personId);
        const long long   viewerId    = viewerIdStr.empty() ? 0 : std::stoll(viewerIdStr);

        return jsonOk({
            {"chat_id",        chatId},
            {"viewer_user_id", viewerId},
            {"messages",       messages},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/my/chat/messages] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/my/chat/messages
// Body: { message: string }
// Rate limit: 3 messages per 10 sec per user.
// Body length: 1..2000 chars after trim.
Response MyController::handlePostChatMessage(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    if (!isMensChatMember(personId)) {
        return jsonError(HttpStatus::FORBIDDEN, "Not a member of the men's chat");
    }

    const long long chatId = mensChatId();
    if (chatId <= 0) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "men's chat not configured");
    }

    const std::string userIdStr = usersIdForPerson(personId);
    if (userIdStr.empty()) {
        return jsonError(HttpStatus::FORBIDDEN, "no users row for caller");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    if (!body.contains("message") || !body["message"].is_string()) {
        return jsonError(HttpStatus::BAD_REQUEST, "message string required");
    }
    const std::string trimmed = trimCopy(body["message"].get<std::string>());
    if (trimmed.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "message cannot be blank");
    }
    if (trimmed.size() > 2000) {
        return jsonError(HttpStatus::BAD_REQUEST, "message too long (max 2000 chars)");
    }

    try {
        auto* db = Database::getInstance();

        // Rate limit: caller has posted <3 rows to this chat in the
        // last 10 seconds.  Cheap query — chat_messages is indexed
        // by (chat_id) and (user_id).
        auto rl = db->query(
            "SELECT COUNT(*) AS n FROM chat_messages "
            " WHERE chat_id = $1::int "
            "   AND user_id = $2::int "
            "   AND created_at > NOW() - INTERVAL '10 seconds'",
            {std::to_string(chatId), userIdStr});
        const long long recent = rl.empty() ? 0 : rl[0]["n"].as<long long>();
        if (recent >= 3) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "slow down — 3 messages / 10 sec limit");
        }

        auto ins = db->query(
            "INSERT INTO chat_messages (chat_id, user_id, message) "
            "VALUES ($1::int, $2::int, $3) "
            "RETURNING id, "
            "  TO_CHAR(created_at AT TIME ZONE 'UTC', "
            "          'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at",
            {std::to_string(chatId), userIdStr, trimmed});

        if (ins.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "insert failed");
        }

        // Pull author name for the echo — client can insert straight
        // into its list without waiting for the next poll.
        auto meta = db->query(
            "SELECT p.first_name, p.last_name, u.person_id "
            "  FROM users u JOIN persons p ON p.id = u.person_id "
            " WHERE u.id = $1::int LIMIT 1",
            {userIdStr});

        json out = {
            {"id",         ins[0]["id"].as<long long>()},
            {"user_id",    std::stoll(userIdStr)},
            {"message",    trimmed},
            {"created_at", ins[0]["created_at"].as<std::string>()},
        };
        if (!meta.empty()) {
            out["author_first_name"] = meta[0]["first_name"].is_null() ? std::string{} : meta[0]["first_name"].as<std::string>();
            out["author_last_name"]  = meta[0]["last_name"].is_null()  ? std::string{} : meta[0]["last_name"].as<std::string>();
            out["person_id"]         = meta[0]["person_id"].as<long long>();
        }
        return jsonOk(out);
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/chat/messages] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /api/my/event-rsvps?match_id=<int>
// ─────────────────────────────────────────────────────────────────────
// Return the full eligible roster for a single match, bucketed by
// RSVP status.  Eligibility rules mirror `handleGetWeek` / the
// eligible_matches CTE:
//   pickup   (mt=7):        ANY mens roster row (active OR removed)
//   practice (mt=3):        active roster to team ∈ (35, 120, 121)
//   APSL game (mt∈{1,4,6}, home=35):
//                           active roster to team ∈ (35, 120)
//   other game (mt∈{1,4,6}):
//                           active roster to home_team_id
//   other (mt∈{2,5}):       active roster to home_team_id
//
// Response payload:
//   {
//     "match_id":    <int>,
//     "counts":      {"going":N, "maybe":N, "not_going":N, "no_response":N, "total":N},
//     "going":       [{"person_id":X, "first_name":"Luke", "last_name":"Breslin"}, ...],
//     "maybe":       [...],
//     "not_going":   [...],
//     "no_response": [...]
//   }
Response MyController::handleGetEventRsvps(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    const std::string midParam = request.getQueryParam("match_id");
    if (midParam.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "match_id required");
    }
    long long matchId = 0;
    try { matchId = std::stoll(midParam); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "match_id must be an integer"); }
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "match_id must be positive");
    }

    auto* db = Database::getInstance();
    try {
        // Verify the match exists and grab its type/home_team for eligibility.
        auto m = db->query(
            "SELECT id, match_type_id, home_team_id FROM matches "
            " WHERE id = $1::int AND cancelled_at IS NULL",
            {std::to_string(matchId)});
        if (m.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "match not found");
        }

        // Caller must be on this match's roster themselves, OR carry
        // an admins row — we don't leak rosters to arbitrary logged-in
        // users.  Same eligibility rule as callerRosteredForMatch().
        auto membership = db->query(
            "SELECT 1 "
            "  FROM roster_assignments ra "
            "  JOIN matches m ON m.id = $2::int "
            "  JOIN external_person_aliases epa "
            "    ON epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = ra.leagueapps_user_id::text "
            " WHERE ra.team_id = m.home_team_id "
            "   AND ra.removed_at IS NULL "
            "   AND epa.person_id = $1::int "
            " UNION ALL "
            " SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
            "  WHERE u.person_id = $1::int "
            " LIMIT 1",
            {std::to_string(personId), std::to_string(matchId)});
        if (membership.empty()) {
            return jsonError(HttpStatus::FORBIDDEN, "not on this event's roster");
        }

        // Eligible roster + latest RSVP status per person.
        auto rows = db->query(
            "WITH m AS ( "
            "  SELECT id, match_type_id, home_team_id FROM matches WHERE id = $1::int "
            "), "
            "eligible AS ( "
            "  SELECT DISTINCT epa.person_id "
            "    FROM m "
            "    JOIN roster_assignments ra "
            "      ON ra.team_id = m.home_team_id "
            "     AND ra.removed_at IS NULL "
            "    JOIN external_person_aliases epa "
            "      ON epa.provider = 'leagueapps' "
            "     AND epa.external_user_id = ra.leagueapps_user_id::text "
            ") "
            "SELECT e.person_id, p.first_name, p.last_name, "
            "       COALESCE(h.rsvp_status_id, 0) AS status_id "
            "  FROM eligible e "
            "  JOIN persons p ON p.id = e.person_id "
            "  LEFT JOIN players pl ON pl.person_id = e.person_id "
            "  LEFT JOIN LATERAL ( "
            "    SELECT rsvp_status_id "
            "      FROM player_rsvp_history hh "
            "     WHERE hh.event_id = $1::int "
            "       AND hh.player_id = pl.id "
            "     ORDER BY hh.changed_at DESC "
            "     LIMIT 1 "
            "  ) h ON true "
            " ORDER BY p.last_name NULLS LAST, p.first_name NULLS LAST",
            {std::to_string(matchId)});

        json going       = json::array();
        json maybe       = json::array();
        json notGoing    = json::array();
        json noResponse  = json::array();
        for (const auto& r : rows) {
            const int statusId = r["status_id"].is_null() ? 0 : r["status_id"].as<int>();
            json entry = {
                {"person_id",  r["person_id"].as<long long>()},
                {"first_name", r["first_name"].is_null() ? std::string{} : r["first_name"].as<std::string>()},
                {"last_name",  r["last_name"].is_null()  ? std::string{} : r["last_name"].as<std::string>()},
            };
            switch (statusId) {
                case 1: going.push_back(entry);      break;
                case 2: notGoing.push_back(entry);   break;
                case 3: maybe.push_back(entry);      break;
                default: noResponse.push_back(entry); break;
            }
        }

        json counts = {
            {"going",       (long long)going.size()},
            {"maybe",       (long long)maybe.size()},
            {"not_going",   (long long)notGoing.size()},
            {"no_response", (long long)noResponse.size()},
            {"total",       (long long)(going.size() + maybe.size() + notGoing.size() + noResponse.size())},
        };

        return jsonOk({
            {"match_id",    matchId},
            {"counts",      counts},
            {"going",       going},
            {"maybe",       maybe},
            {"not_going",   notGoing},
            {"no_response", noResponse},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/my/event-rsvps] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
