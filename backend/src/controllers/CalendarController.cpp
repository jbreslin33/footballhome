#include "CalendarController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cctype>
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

// Small helper for pqxx::field → json.  pqxx exposes is_null() +
// c_str() for text; we let nlohmann::json infer types from the
// SELECT projection.
json textOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.c_str();
}

json boolOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.as<bool>();
}

json longLongOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.as<long long>();
}

std::string urlDecode(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i];
        if (c == '+') { out.push_back(' '); continue; }
        if (c == '%' && i + 2 < s.size()) {
            auto hex = [](char h) -> int {
                if (h >= '0' && h <= '9') return h - '0';
                if (h >= 'a' && h <= 'f') return 10 + (h - 'a');
                if (h >= 'A' && h <= 'F') return 10 + (h - 'A');
                return -1;
            };
            int hi = hex(s[i + 1]);
            int lo = hex(s[i + 2]);
            if (hi >= 0 && lo >= 0) {
                out.push_back(static_cast<char>((hi << 4) | lo));
                i += 2;
                continue;
            }
        }
        out.push_back(c);
    }
    return out;
}

// ─── Optional session resolution ────────────────────────────────────
//
// The read endpoint is intentionally public (see header) but we want
// to enrich the response with the caller's own RSVP when a session is
// present.  This helper mirrors MyController::requireSession's dual
// path (Bearer JWT first, then fh_sess cookie) but returns 0 on any
// failure instead of a 401 — the caller decides what to do with an
// anonymous request.
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

long long resolveOptionalPersonId(const Request& request) {
    // Prefer Bearer JWT for the same "current tab intent" reason
    // MyController documents at length — a stale cookie must not
    // shadow a fresh login.
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long personId = personIdFromJwtPayload(payloadJson);
            if (personId > 0) return personId;
        }
    }
    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    if (sessVal.empty()) return 0;
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (!resolved) return 0;
    return resolved->personId;
}

// ─── View-as / impersonation ────────────────────────────────────────
//
// Mirrors MyController::applyImpersonation.  Read endpoints (upcoming)
// let an admin pass `?asPersonId=N` to render as person N.  Writes
// deliberately do NOT — an admin viewing as a player must not be able
// to accidentally RSVP as that player.
//
// Returns std::nullopt on success (with *effective updated).  Returns
// a populated Response (403 / 404 / 500) on any failure the caller
// must surface unchanged.
std::optional<Response> applyImpersonation(const Request& request,
                                            long long authPersonId,
                                            long long* effectivePersonId) {
    *effectivePersonId = authPersonId;
    const std::string q = request.getQueryParam("asPersonId");
    if (q.empty()) return std::nullopt;
    long long target = 0;
    try { target = std::stoll(q); } catch (...) { target = 0; }
    if (target <= 0 || target == authPersonId) return std::nullopt;

    auto* db = Database::getInstance();
    try {
        auto isAdmin = db->query(
            "SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
            " WHERE u.person_id = $1::int LIMIT 1",
            {std::to_string(authPersonId)});
        if (isAdmin.empty()) {
            return jsonError(HttpStatus::FORBIDDEN,
                              "only admins may use view-as");
        }
        auto exists = db->query(
            "SELECT 1 FROM persons WHERE id = $1::int LIMIT 1",
            {std::to_string(target)});
        if (exists.empty()) {
            return jsonError(HttpStatus::NOT_FOUND,
                              "view-as target person not found");
        }
    } catch (const std::exception& e) {
        std::cerr << "[CalendarController::applyImpersonation] "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                          "view-as check failed");
    }
    *effectivePersonId = target;
    return std::nullopt;
}

// Write endpoints (POST /api/calendar/rsvp) MUST reject anonymous
// callers with a 401 — different behaviour from the read path.
struct SessionGate {
    long long                 personId = 0;
    std::optional<Response>   error;
};

SessionGate requireSession(const Request& request) {
    const long long personId = resolveOptionalPersonId(request);
    if (personId > 0) return {personId, std::nullopt};

    // Distinguish "no credentials at all" from "credentials present
    // but invalid" — matches MyController's 401 body strings so the
    // frontend session-expiry handler picks up both flavours.
    const std::string authHeader = request.getHeader("Authorization");
    const bool hasBearer = authHeader.size() > 7 &&
                           authHeader.substr(0, 7) == "Bearer ";
    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    const bool present = hasBearer || !sessVal.empty();
    return {0, jsonError(HttpStatus::UNAUTHORIZED,
                         present ? "Session expired" : "Not signed in")};
}

// JSON body helpers — same shape MyController / EventRsvpController use.
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

std::string jsonStr(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return {};
    if (j[key].is_string()) return j[key].get<std::string>();
    return j[key].dump();
}

std::string toLower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

// Pulls the numeric fh_event_id out of
// ".../calendar/events/<id>/attendance" — Router matches :params by
// segment but doesn't expose them on Request, so we parse the path
// ourselves, same approach as EventRsvpController's trailingSegment.
long long extractEventIdFromAttendancePath(const std::string& path) {
    const std::string marker = "/calendar/events/";
    auto pos = path.find(marker);
    if (pos == std::string::npos) return 0;
    auto start = pos + marker.size();
    auto end = path.find('/', start);
    if (end == std::string::npos) return 0;
    try { return std::stoll(path.substr(start, end - start)); }
    catch (...) { return 0; }
}

// Resolves users.id for a person, for the marked_by_user_id audit FK.
// NULL when the person has no users row. Mirrors
// EventRsvpController::resolveChangedByUserId.
std::string resolveUserId(Database* db, long long personId) {
    auto row = db->query(
        "SELECT id FROM users WHERE person_id = $1::int LIMIT 1",
        {std::to_string(personId)});
    if (row.empty() || row[0]["id"].is_null()) return {};
    return std::to_string(row[0]["id"].as<long long>());
}

// True when personId may mark attendance for fhEventId — a club admin,
// or a coach of one of the teams attached to the event. Same shape as
// the eligibility EXISTS block in handlePostRsvp; factored out here
// because both attendance handlers need the identical check.
bool isEventCoachOrAdmin(Database* db, long long personId, long long fhEventId) {
    auto rows = db->query(
        "SELECT ("
        "  EXISTS ("
        "    SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
        "    WHERE u.person_id = $2::int"
        "  )"
        "  OR EXISTS ("
        "    SELECT 1 FROM fh_event_teams fet "
        "    JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL "
        "    JOIN coaches co ON co.id = tc.coach_id "
        "    WHERE fet.fh_event_id = $1::bigint AND co.person_id = $2::int"
        "  )"
        ") AS can_mark",
        {std::to_string(fhEventId), std::to_string(personId)});
    return !rows.empty() && rows[0]["can_mark"].as<bool>();
}

}  // namespace

CalendarController::CalendarController() = default;

void CalendarController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering calendar routes with prefix: " << prefix << std::endl;

    router.get(prefix + "/calendar/upcoming", [this](const Request& req) {
        return this->handleGetUpcoming(req);
    });
    router.post(prefix + "/calendar/rsvp", [this](const Request& req) {
        return this->handlePostRsvp(req);
    });
    router.get(prefix + "/calendar/events/:fhEventId/attendance", [this](const Request& req) {
        return this->handleGetEventAttendance(req);
    });
    router.post(prefix + "/calendar/events/:fhEventId/attendance", [this](const Request& req) {
        return this->handlePostEventAttendance(req);
    });
    router.del(prefix + "/calendar/events/:fhEventId/attendance", [this](const Request& req) {
        return this->handleDeleteEventAttendance(req);
    });
}

Response CalendarController::handleGetUpcoming(const Request& request) {
    // Parse ?days= with defensible bounds.  A stray days=1000 would drag
    // the response into "next year's practices" territory and blow past
    // the LIMIT — cap at 90 days which covers the longest reasonable
    // planning horizon (a full academic quarter).
    int days = 14;
    if (request.hasQueryParam("days")) {
        try {
            days = std::stoi(request.getQueryParam("days"));
        } catch (...) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "days must be an integer");
        }
        if (days < 1)  days = 1;
        if (days > 90) days = 90;
    }

    const bool includeUnclassified =
        request.getQueryParam("include_unclassified") == "1" ||
        request.getQueryParam("include_unclassified") == "true";
    const std::string startParam = urlDecode(request.getQueryParam("start"));

    // Optional session — enriches each event with the caller's RSVP.
    // Anonymous callers see `my_rsvp: null` on every event; no auth
    // error is raised here (write endpoint enforces auth).
    long long personId = resolveOptionalPersonId(request);

    // Admin view-as: `?asPersonId=N` swaps the effective person for
    // read purposes so an admin sees exactly what N sees.  Ignored
    // for anonymous callers (personId == 0).
    if (personId > 0) {
        if (auto err = applyImpersonation(request, personId, &personId)) {
            return *err;
        }
    }

    try {
        auto* db = Database::getInstance();

        // The query starts from the Google mirror row (gcal_events),
        // joins calendar metadata, and LEFT JOINs FH classification.
        // Default callers still see classified FH events only.  Admin
        // Soccer Calendar can pass include_unclassified=1 to also show
        // raw soccer-calendar Google rows while ops catches up on DSL
        // tagging/classification.  Filters:
        //   * deleted_at IS NULL     — respects the tombstone contract
        //   * status <> 'cancelled'  — belt-and-suspenders; the sync
        //                              worker sets deleted_at when
        //                              status flips to 'cancelled' but
        //                              guarding both makes the query
        //                              correct regardless of order.
        //   * start omitted: starts_at >= now() - 1h and < now()+?days.
        //   * start present: starts_at >= start and < start+?days so
        //                    the admin calendar can page backward and
        //                    forward like Google Calendar.
        //
        // rsvps_open_now is computed here so the frontend doesn't
        // have to re-implement §6.5.2's window check just to decide
        // whether to show the RSVP button vs a countdown.
        //
        // my_rsvp is a LEFT JOIN against fh_event_rsvps for the
        // caller's person_id — NULL when unauthenticated (personId=0)
        // because no persons row has id=0, so the JOIN drops out.
        //
        // teams[] is aggregated in a correlated subquery over the
        // §6.1.5 junction (fh_event_teams) — one row per (event,
        // team) link, JSON-encoded on the DB side so we don't have
        // to reshape it in C++.  Empty array when no teams attached
        // (legacy-classified events without DSL tags).
        //
        // my_rsvp_eligible walks the same junction to team_persons:
        // the caller is eligible when they hold an active membership
        // on ANY team attached to the event (group model — see
        // docs/adr/2026-07-30-roster-membership-rsvp-normalization.md),
        // minus any active rsvp_suspensions row.  NULL when anonymous.
        //
        // hangout_link is the Meet URL extracted from the raw gcal
        // event payload — Google puts it on `hangoutLink` for events
        // with a Meet attached.  NULL when no Meet.
        const std::string sql = R"SQL(
            WITH base AS (
            SELECT
                fe.id                  AS fh_event_id,
                ge.id                  AS gcal_event_id,
                gc.role                AS calendar_role,
                gc.time_zone           AS calendar_time_zone,
                ge.google_event_id,
                ge.recurring_event_id,
                ge.summary,
                ge.description,
                ge.location,
                to_char(ge.starts_at AT TIME ZONE 'UTC',
                        'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at,
                to_char(ge.ends_at   AT TIME ZONE 'UTC',
                        'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS ends_at,
                ge.all_day,
                ge.status,
                ge.html_link,
                ge.raw->>'hangoutLink' AS hangout_link,
                COALESCE(fe.kind, 'other') AS kind,
                fe.category,
                fe.is_home,
                fe.match_id,
                fe.opponent,
                -- Opponent crest: gcal_opponent_aliases (migration 258)
                -- first — the hand-seeded, unambiguous mapping from
                -- free-form Opponent: text to a real team, same pattern
                -- as gcal_team_aliases for our own Team:/Club: tags — then
                -- falls back to an exact (case/whitespace-insensitive)
                -- teams.name match for opponents that happen to be typed
                -- verbatim. No fuzzy/substring matching: "Oaklyn United"
                -- as typed is a substring/word-match against three
                -- different scraped team rows, so guessing would risk
                -- showing the wrong club's crest. NULL falls through to
                -- the Lighthouse crest on the frontend. New opponents
                -- just need one INSERT into gcal_opponent_aliases.
                COALESCE(
                    (SELECT t.logo_url
                       FROM gcal_opponent_aliases goa
                       JOIN teams t ON t.id = goa.team_id
                      WHERE fe.opponent IS NOT NULL
                        AND LOWER(BTRIM(goa.alias)) = LOWER(BTRIM(fe.opponent))
                      LIMIT 1),
                    (SELECT t.logo_url FROM teams t
                      WHERE fe.opponent IS NOT NULL
                        AND LOWER(BTRIM(t.name)) = LOWER(BTRIM(fe.opponent))
                      LIMIT 1)
                ) AS opponent_logo_url,
                fe.fh_notes,
                CASE
                    WHEN fe.rsvps_open_at IS NULL THEN NULL
                    ELSE to_char(fe.rsvps_open_at AT TIME ZONE 'UTC',
                                 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                END AS rsvps_open_at,
                (fe.rsvps_open_at IS NULL
                 OR fe.rsvps_open_at <= now()) AS rsvps_open_now,
                mr.response    AS my_rsvp,
                mr.created_via AS my_rsvp_created_via,
                (
                    SELECT COUNT(*)::int
                    FROM fh_event_teams fet2
                    WHERE fet2.fh_event_id = fe.id
                ) AS team_count,
                (
                    EXISTS (
                        SELECT 1
                        FROM admins a
                        JOIN users u ON u.id = a.user_id
                        WHERE u.person_id = $1::int
                    )
                    OR EXISTS (
                        SELECT 1
                        FROM fh_event_teams fet
                        WHERE fet.fh_event_id = fe.id
                          AND (
                              EXISTS (
                                  SELECT 1
                                  FROM team_persons tp
                                  WHERE tp.team_id = fet.team_id
                                    AND tp.person_id = $1::int
                                    AND tp.removed_at IS NULL
                                    AND NOT EXISTS (
                                        SELECT 1 FROM rsvp_suspensions s
                                        WHERE s.person_id = tp.person_id
                                          AND (s.team_id IS NULL OR s.team_id = tp.team_id)
                                          AND s.starts_at <= now()
                                          AND (s.ends_at IS NULL OR s.ends_at > now())
                                    )
                              )
                              OR EXISTS (
                                  SELECT 1
                                  FROM team_coaches tc
                                  JOIN coaches co ON co.id = tc.coach_id
                                  WHERE tc.team_id = fet.team_id
                                    AND tc.ended_at IS NULL
                                    AND co.person_id = $1::int
                              )
                          )
                    )
                ) AS eligible,
                COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id',              t.id,
                            'name',            t.name,
                            'gender_category', t.gender_category,
                            'logo_url',        t.logo_url
                        )
                        ORDER BY t.id
                    )
                    FROM fh_event_teams fet
                    JOIN teams t ON t.id = fet.team_id
                    WHERE fet.fh_event_id = fe.id
                ), '[]'::jsonb) AS teams_json,
                COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                                                        'person_id',      roster.person_id,
                                                        'first_name',     roster.first_name,
                                                        'last_name',      roster.last_name,
                                                        'name',           roster.name,
                                                        'response',       roster.response,
                                                        'created_via',    roster.created_via,
                                                        'responded_at',   roster.responded_at,
                                                        'is_pickup_only', roster.is_pickup_only,
                                                        'is_coach',       roster.is_coach,
                                                        'phone',          roster.phone,
                                                        'email',          roster.email
                        )
                                                ORDER BY CASE roster.response
                                   WHEN 'yes' THEN 1
                                                                     WHEN 'no' THEN 2
                                                                     WHEN 'maybe' THEN 3
                                   ELSE 4
                                 END,
                                                                 roster.last_name ASC,
                                                                 roster.first_name ASC,
                                                                 roster.person_id ASC
                    )
                                        FROM (
                                                -- Players (team_persons) unioned with coaches (team_coaches, §5.3
                                                -- roster-membership-adjacent but a separate role/table entirely) —
                                                -- coaches are RSVP-eligible (see EXISTS block below / isEventCoachOrAdmin)
                                                -- but were invisible in this player-facing "who's going" list since it
                                                -- only ever walked team_persons. DISTINCT ON (person_id) picks the
                                                -- player row over the coach row on the rare overlap (ORDER BY is_coach
                                                -- puts is_coach=false first).
                                                SELECT DISTINCT ON (combined.person_id)
                                                             combined.person_id,
                                                             combined.first_name,
                                                             combined.last_name,
                                                             combined.name,
                                                             combined.response,
                                                             combined.created_via,
                                                             combined.responded_at,
                                                             combined.is_pickup_only,
                                                             combined.is_coach,
                                                             combined.phone,
                                                             combined.email
                                                    FROM (
                                                        SELECT
                                                             p.id AS person_id,
                                                             p.first_name,
                                                             p.last_name,
                                                             NULLIF(TRIM(CONCAT_WS(' ', p.first_name, p.last_name)), '') AS name,
                                                             er.response,
                                                             er.created_via,
                                                             CASE
                                                                     WHEN er.responded_at IS NULL THEN NULL
                                                                     ELSE to_char(er.responded_at AT TIME ZONE 'UTC',
                                                                                                'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                                                             END AS responded_at,
                                                             CASE
                                                                     -- "Pickup only" means this person's ONLY
                                                                     -- connection to THIS event's tagged teams is via
                                                                     -- the generic Practice(908)/Pickup(909) pool —
                                                                     -- not via any specifically-named team tagged on
                                                                     -- the event, official (35/120/121/122) or
                                                                     -- trialist/reserve (924-929). Computed
                                                                     -- person-level (scoped to fe.id's own tagged
                                                                     -- teams) rather than per-row, so it's stable
                                                                     -- under DISTINCT ON regardless of which of a
                                                                     -- multi-team person's rows wins the tie. A
                                                                     -- hardcoded (35,120,121,122) whitelist predates
                                                                     -- the trialist teams and wrongly hid trialists
                                                                     -- tagged on their own practice events (they'd
                                                                     -- never RSVP'd yet, so got filtered out below
                                                                     -- entirely).
                                                                     WHEN fe.category = 'mens' THEN NOT EXISTS (
                                                                             SELECT 1
                                                                                 FROM team_persons tp_sel
                                                                                 JOIN fh_event_teams fet_sel
                                                                                   ON fet_sel.team_id = tp_sel.team_id
                                                                                WHERE tp_sel.person_id    = p.id
                                                                                    AND tp_sel.removed_at IS NULL
                                                                                    AND fet_sel.fh_event_id = fe.id
                                                                                    AND tp_sel.team_id NOT IN (908, 909)
                                                                     )
                                                                     ELSE false
                                                             END AS is_pickup_only,
                                                             false AS is_coach,
                                                             (SELECT phone_number FROM person_phones
                                                               WHERE person_id = p.id AND can_receive_sms = true
                                                               ORDER BY is_primary DESC, id ASC LIMIT 1) AS phone,
                                                             (SELECT email FROM person_emails
                                                               WHERE person_id = p.id
                                                               ORDER BY is_primary DESC, id ASC LIMIT 1) AS email
                                                        FROM fh_event_teams fet
                                                        JOIN team_persons tp
                                                            ON tp.team_id = fet.team_id
                                                           AND tp.removed_at IS NULL
                                                        JOIN persons p ON p.id = tp.person_id
                                                        LEFT JOIN fh_event_rsvps er
                                                            ON er.fh_event_id = fe.id
                                                         AND er.person_id   = p.id
                                                     WHERE fet.fh_event_id = fe.id

                                                        UNION ALL

                                                        SELECT
                                                             p.id,
                                                             p.first_name,
                                                             p.last_name,
                                                             NULLIF(TRIM(CONCAT_WS(' ', p.first_name, p.last_name)), ''),
                                                             er.response,
                                                             er.created_via,
                                                             CASE
                                                                     WHEN er.responded_at IS NULL THEN NULL
                                                                     ELSE to_char(er.responded_at AT TIME ZONE 'UTC',
                                                                                                'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                                                             END,
                                                             false,
                                                             true,
                                                             (SELECT phone_number FROM person_phones
                                                               WHERE person_id = p.id AND can_receive_sms = true
                                                               ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                             (SELECT email FROM person_emails
                                                               WHERE person_id = p.id
                                                               ORDER BY is_primary DESC, id ASC LIMIT 1)
                                                        FROM fh_event_teams fet
                                                        JOIN team_coaches tc
                                                            ON tc.team_id = fet.team_id
                                                           AND tc.ended_at IS NULL
                                                        JOIN coaches co ON co.id = tc.coach_id
                                                        JOIN persons p ON p.id = co.person_id
                                                        LEFT JOIN fh_event_rsvps er
                                                            ON er.fh_event_id = fe.id
                                                         AND er.person_id   = p.id
                                                     WHERE fet.fh_event_id = fe.id
                                                    ) combined
                                                 ORDER BY combined.person_id, combined.is_coach ASC
                                        ) roster
                                        WHERE roster.is_pickup_only = false
                                             OR roster.response = 'yes'
                ), '[]'::jsonb) AS rsvps_json,
                CASE
                    WHEN $1::int = 0 OR fe.id IS NULL THEN NULL
                    ELSE (
                        EXISTS (
                            SELECT 1
                            FROM admins a
                            JOIN users u ON u.id = a.user_id
                            WHERE u.person_id = $1::int
                        )
                        OR EXISTS (
                            SELECT 1
                            FROM fh_event_teams fet
                            WHERE fet.fh_event_id = fe.id
                              AND (
                                  EXISTS (
                                      SELECT 1
                                      FROM team_persons tp
                                      WHERE tp.team_id = fet.team_id
                                        AND tp.person_id = $1::int
                                        AND tp.removed_at IS NULL
                                        AND NOT EXISTS (
                                            SELECT 1 FROM rsvp_suspensions s
                                            WHERE s.person_id = tp.person_id
                                              AND (s.team_id IS NULL OR s.team_id = tp.team_id)
                                              AND s.starts_at <= now()
                                              AND (s.ends_at IS NULL OR s.ends_at > now())
                                        )
                                  )
                                  OR EXISTS (
                                      SELECT 1
                                      FROM team_coaches tc
                                      JOIN coaches co ON co.id = tc.coach_id
                                      WHERE tc.team_id = fet.team_id
                                        AND tc.ended_at IS NULL
                                        AND co.person_id = $1::int
                                  )
                              )
                        )
                    )
                END AS my_rsvp_eligible,
                ge.starts_at            AS raw_starts_at,
                ge.id                   AS raw_gcal_id
                        FROM gcal_events ge
            JOIN gcal_calendars gc ON gc.id = ge.calendar_id
                        LEFT JOIN fh_events fe ON fe.gcal_event_id = ge.id
            LEFT JOIN fh_event_rsvps mr
                   ON mr.fh_event_id = fe.id
                  AND mr.person_id   = $1::int
            WHERE ge.deleted_at IS NULL
                            AND COALESCE(ge.status, '') <> 'cancelled'
              AND ge.starts_at >= CASE
                  WHEN $4 = '' THEN now() - INTERVAL '1 hour'
                  ELSE $4::timestamptz
                END
              AND ge.starts_at < CASE
                  WHEN $4 = '' THEN now() + ($2::int * INTERVAL '1 day')
                  ELSE $4::timestamptz + ($2::int * INTERVAL '1 day')
                END
                               AND (
                                        fe.id IS NOT NULL
                                   OR ($3::bool AND (gc.role = 'soccer' OR ge.summary ILIKE '%Soccer%'))
                               )
            )
            -- Team-scoped visibility: everyone (player, coach, or admin)
            -- only sees events for teams they're actually on/coach —
            -- `eligible` already ORs in "caller is admin" so admins keep
            -- seeing every event for free. Anonymous callers ($1=0) are
            -- left unfiltered (unchanged public-calendar behavior).
            SELECT * FROM base
            WHERE $1::int = 0 OR base.eligible
            ORDER BY base.raw_starts_at ASC, base.raw_gcal_id ASC
            LIMIT 500
        )SQL";

        pqxx::result rows = db->query(sql, {
            std::to_string(personId),
            std::to_string(days),
                        includeUnclassified ? "true" : "false",
            startParam,
        });

        json events = json::array();
        events.get_ref<json::array_t&>().reserve(rows.size());

        for (const auto& row : rows) {
            json ev;
            ev["fh_event_id"]       = longLongOrNull(row, "fh_event_id");
            ev["gcal_event_id"]     = row["gcal_event_id"].as<long long>();
            ev["calendar_role"]     = row["calendar_role"].c_str();
            ev["calendar_time_zone"]= row["calendar_time_zone"].c_str();
            ev["google_event_id"]   = row["google_event_id"].c_str();
            ev["recurring_event_id"]= textOrNull(row, "recurring_event_id");
            ev["summary"]           = textOrNull(row, "summary");
            ev["description"]       = textOrNull(row, "description");
            ev["location"]          = textOrNull(row, "location");
            ev["starts_at"]         = row["starts_at"].c_str();
            ev["ends_at"]           = row["ends_at"].c_str();
            ev["all_day"]           = row["all_day"].as<bool>();
            ev["status"]            = row["status"].c_str();
            ev["html_link"]         = textOrNull(row, "html_link");
            ev["hangout_link"]      = textOrNull(row, "hangout_link");
            ev["kind"]              = row["kind"].c_str();
            ev["category"]          = textOrNull(row, "category");
            ev["is_home"]           = boolOrNull(row, "is_home");
            ev["match_id"]          = longLongOrNull(row, "match_id");
            ev["opponent"]          = textOrNull(row, "opponent");
            ev["opponent_logo_url"] = textOrNull(row, "opponent_logo_url");
            ev["fh_notes"]          = textOrNull(row, "fh_notes");
            ev["rsvps_open_at"]     = textOrNull(row, "rsvps_open_at");
            ev["rsvps_open_now"]    = row["rsvps_open_now"].as<bool>();
            ev["my_rsvp"]           = textOrNull(row, "my_rsvp");
            ev["my_rsvp_created_via"]= textOrNull(row, "my_rsvp_created_via");
            ev["my_rsvp_eligible"]  = boolOrNull(row, "my_rsvp_eligible");
            {
                const bool eligible = row["eligible"].as<bool>();
                const int teamCount = row["team_count"].as<int>();
                if (row["my_rsvp_eligible"].is_null()) {
                    ev["my_rsvp_eligibility_reason"] = nullptr;
                } else if (!eligible) {
                    if (teamCount == 0) {
                        ev["my_rsvp_eligibility_reason"] = "This event has no roster attached yet — ops needs to add Team:/Club: tags to the Google Calendar description.";
                    } else {
                        ev["my_rsvp_eligibility_reason"] = "You are not on the roster for this event.";
                    }
                } else {
                    ev["my_rsvp_eligibility_reason"] = nullptr;
                }
            }
            // teams comes from the DB as a JSONB aggregate string
            // (jsonb_agg → text via row["…"].c_str()).  Parse it back
            // into a json array — cheap because the payload is tiny
            // (0..a few teams per event) and it lets the frontend see
            // a real array instead of an opaque string.
            try {
                ev["teams"] = json::parse(row["teams_json"].c_str());
            } catch (...) {
                ev["teams"] = json::array();
            }
            try {
                ev["rsvps"] = json::parse(row["rsvps_json"].c_str());
            } catch (...) {
                ev["rsvps"] = json::array();
            }
            events.push_back(std::move(ev));
        }

        // Caller's own mens-team membership — as a player OR a coach —
        // cheap enough to check on every /upcoming call, and lets #my
        // show mens-only content (e.g. the club WhatsApp link) without
        // a separate round trip.
        bool viewerIsMens = false;
        if (personId > 0) {
            pqxx::result mensRows = db->query(
                "SELECT EXISTS ("
                "  SELECT 1 FROM team_persons tp "
                "  JOIN teams t ON t.id = tp.team_id "
                "  WHERE tp.person_id = $1 AND tp.removed_at IS NULL "
                "    AND t.gender_category = 'mens'"
                "  UNION ALL "
                "  SELECT 1 FROM team_coaches tc "
                "  JOIN coaches c ON c.id = tc.coach_id "
                "  JOIN teams t ON t.id = tc.team_id "
                "  WHERE c.person_id = $1 AND tc.ended_at IS NULL "
                "    AND t.gender_category = 'mens'"
                ") AS is_mens",
                {std::to_string(personId)});
            if (!mensRows.empty()) {
                viewerIsMens = mensRows[0]["is_mens"].as<bool>();
            }
        }

        json body = {
            {"days",   days},
            {"count",  events.size()},
            {"events", std::move(events)},
            {"viewer_is_mens", viewerIsMens},
        };
        if (!startParam.empty()) {
            body["start"] = startParam;
        }
        return jsonOk(body);

    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetUpcoming: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/calendar/rsvp — Slice 6 write path (see design doc §6.5.2).
//
// Body: { fh_event_id:int, response:'yes'|'no'|'maybe', note?:string }
//
// Contract:
//   * Session-gated (401 when anonymous).
//   * fh_event_id must resolve to a live fh_events row whose parent
//     gcal_events is NOT tombstoned/cancelled — otherwise 404.
//   * If fh_events.rsvps_open_at IS NOT NULL AND now() < it, return
//     409 with an explanatory body.  The standing-RSVP applier
//     (§6.5.3) is the only writer allowed before the window opens,
//     and it doesn't go through this endpoint.
//   * Upsert one fh_event_rsvps row (fh_event_id, person_id) →
//     (response, responded_at=now(), created_via='manual').  Any
//     prior 'standing' row for the same (event, person) is
//     overwritten and its created_via flips to 'manual' — the
//     manual click is authoritative.
Response CalendarController::handlePostRsvp(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.personId;

    json body;
    try {
        body = request.getBody().empty()
            ? json::object()
            : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         std::string("Invalid JSON: ") + e.what());
    }

    auto fhEventIdOpt = jsonInt(body, "fh_event_id");
    if (!fhEventIdOpt || *fhEventIdOpt <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "fh_event_id (positive int) required");
    }
    const long long fhEventId = *fhEventIdOpt;

    const std::string response = toLower(jsonStr(body, "response"));
    if (response != "yes" && response != "no" && response != "maybe") {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "response must be 'yes', 'no', or 'maybe'");
    }

    // Optional freeform note — trimmed to 1000 chars like the older
    // RSVP endpoint.  Not persisted in fh_event_rsvps today (no note
    // column per migration 119); accepted for forward-compat with the
    // §6.5.3 profile flow but silently dropped.  Add a note column
    // when the UI actually collects one.
    std::string note = jsonStr(body, "note");
    if (note.size() > 1000) note.resize(1000);

    try {
        auto* db = Database::getInstance();

        // Existence + liveness check.  We look at the fh_events row
        // AND its gcal_events parent — a tombstoned gcal event must
        // not accept new RSVPs even if the fh_events row survives
        // (per §1.1's "no orphan FH data" corollary this is a bug
        // state, but we're defensive here in case the applier races
        // the sync worker).
        auto checkRows = db->query(
            "SELECT fe.id, "
            "       ge.deleted_at IS NOT NULL AS gcal_tombstoned, "
            "       ge.status = 'cancelled'   AS gcal_cancelled, "
            "       fe.rsvps_open_at, "
            "       (fe.rsvps_open_at IS NULL "
            "        OR fe.rsvps_open_at <= now()) AS rsvps_open_now, "
            "       to_char(fe.rsvps_open_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS rsvps_open_at_iso "
            "  FROM fh_events   fe "
            "  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            " WHERE fe.id = $1::bigint",
            {std::to_string(fhEventId)});

        if (checkRows.empty()) {
            return jsonError(HttpStatus::NOT_FOUND,
                             "fh_event not found");
        }
        const auto& c = checkRows[0];
        if (c["gcal_tombstoned"].as<bool>() || c["gcal_cancelled"].as<bool>()) {
            return jsonError(HttpStatus::NOT_FOUND,
                             "event is cancelled or removed from Google Calendar");
        }
        if (!c["rsvps_open_now"].as<bool>()) {
            json err = {
                {"error",         "RSVP window not open yet"},
                {"rsvps_open_at", c["rsvps_open_at_iso"].is_null()
                                     ? json(nullptr)
                                     : json(c["rsvps_open_at_iso"].as<std::string>())},
            };
            Response r(HttpStatus::CONFLICT, err.dump());
            r.setHeader("Content-Type", "application/json; charset=utf-8");
            return r;
        }

        // For this rollout, the My page is the source of truth for
        // whether the caller should be able to RSVP.  If the event is
        // present in the upcoming payload for that caller, the write
        // path accepts the manual RSVP instead of rejecting it on a
        // separate stale roster gate.
        //
        // We still keep the check lightweight: admins can always save,
        // and non-admins must hold an active team_persons membership
        // (not suspended) on one of the event's attached teams.  If
        // that check fails, we return a clear 403 so the UI can
        // surface a helpful error.
        auto eligRows = db->query(
            "SELECT "
            "  (SELECT COUNT(*)::int FROM fh_event_teams "
            "     WHERE fh_event_id = $1::bigint) AS team_count, "
            "  ("
            "    EXISTS ( "
            "      SELECT 1 "
            "      FROM admins a "
            "      JOIN users u ON u.id = a.user_id "
            "      WHERE u.person_id = $2::int "
            "    ) "
            "    OR EXISTS ( "
            "      SELECT 1 "
            "      FROM fh_event_teams fet "
            "      WHERE fet.fh_event_id = $1::bigint "
            "        AND ( "
            "          EXISTS ( "
            "            SELECT 1 "
            "            FROM team_persons tp "
            "            WHERE tp.team_id = fet.team_id "
            "              AND tp.person_id = $2::int "
            "              AND tp.removed_at IS NULL "
            "              AND NOT EXISTS ( "
            "                  SELECT 1 FROM rsvp_suspensions s "
            "                  WHERE s.person_id = tp.person_id "
            "                    AND (s.team_id IS NULL OR s.team_id = tp.team_id) "
            "                    AND s.starts_at <= now() "
            "                    AND (s.ends_at IS NULL OR s.ends_at > now()) "
            "              ) "
            "          ) "
            "          OR EXISTS ( "
            "            SELECT 1 "
            "            FROM team_coaches tc "
            "            JOIN coaches co ON co.id = tc.coach_id "
            "            WHERE tc.team_id = fet.team_id "
            "              AND tc.ended_at IS NULL "
            "              AND co.person_id = $2::int "
            "          ) "
            "        ) "
            "    )"
            "  ) AS eligible",
            {std::to_string(fhEventId), std::to_string(personId)});
        if (eligRows.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "eligibility check returned no row");
        }
        const auto& e0 = eligRows[0];
        const int  teamCount = e0["team_count"].as<int>();
        const bool eligible  = e0["eligible"].as<bool>();
        if (teamCount == 0) {
            return jsonError(HttpStatus::FORBIDDEN,
                             "This event has no roster attached yet — "
                             "ops needs to add Team:/Club: tags to the "
                             "Google Calendar description.");
        }
        if (!eligible) {
            return jsonError(HttpStatus::FORBIDDEN,
                             "You are not on the roster for this event.");
        }

        // Upsert.  ON CONFLICT overwrites response, responded_at, and
        // created_via — the manual click always beats an earlier
        // standing/admin insert.
        auto row = db->query(
            "INSERT INTO fh_event_rsvps "
            "    (fh_event_id, person_id, response, responded_at, created_via) "
            "VALUES ($1::bigint, $2::int, $3, now(), 'manual') "
            "ON CONFLICT (fh_event_id, person_id) DO UPDATE "
            "   SET response     = EXCLUDED.response, "
            "       responded_at = EXCLUDED.responded_at, "
            "       created_via  = EXCLUDED.created_via "
            "RETURNING id, fh_event_id, person_id, response, created_via, "
            "          to_char(responded_at AT TIME ZONE 'UTC', "
            "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS responded_at",
            {std::to_string(fhEventId),
             std::to_string(personId),
             response});

        if (row.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "RSVP write returned no row");
        }
        const auto& r0 = row[0];
        json rsvp = {
            {"id",            r0["id"].as<long long>()},
            {"fh_event_id",   r0["fh_event_id"].as<long long>()},
            {"person_id",     r0["person_id"].as<long long>()},
            {"response",      r0["response"].as<std::string>()},
            {"created_via",   r0["created_via"].as<std::string>()},
            {"responded_at",  r0["responded_at"].as<std::string>()},
        };
        return jsonOk({{"rsvp", rsvp}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handlePostRsvp: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handleGetEventAttendance(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.personId;

    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");
    }

    auto* db = Database::getInstance();
    try {
        auto evRows = db->query(
            "SELECT 1 FROM fh_events WHERE id = $1::bigint",
            {std::to_string(fhEventId)});
        if (evRows.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "fh_event not found");
        }

        const bool canMark = isEventCoachOrAdmin(db, personId, fhEventId);

        // Roster for every team attached to this event, players (team_persons)
        // unioned with coaches (team_coaches) — same pattern as the rsvps_json
        // subquery in handleGetUpcoming, so coaches can be checked in too, not
        // just players. Left-joined to the current attendance mark.
        // DISTINCT ON (combined.person_id) collapses a person who's on more
        // than one attached team, or who is both a player and a coach
        // (ORDER BY is_coach ASC prefers the player row on that overlap);
        // nested so we can still sort alphabetically outside the DISTINCT
        // ON's forced person_id order.
        auto rows = db->query(
            "SELECT person_id, first_name, last_name, is_coach, status, marked_at "
            "  FROM ( "
            "    SELECT DISTINCT ON (combined.person_id) "
            "           combined.person_id, combined.first_name, combined.last_name, "
            "           combined.is_coach, "
            "           fea.status, "
            "           to_char(fea.marked_at AT TIME ZONE 'UTC', "
            "                   'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS marked_at "
            "      FROM ( "
            "        SELECT p.id AS person_id, p.first_name, p.last_name, false AS is_coach "
            "          FROM fh_event_teams fet "
            "          JOIN team_persons tp ON tp.team_id = fet.team_id "
            "                              AND tp.removed_at IS NULL "
            "          JOIN persons p ON p.id = tp.person_id "
            "         WHERE fet.fh_event_id = $1::bigint "
            "        UNION ALL "
            "        SELECT p.id, p.first_name, p.last_name, true "
            "          FROM fh_event_teams fet "
            "          JOIN team_coaches tc ON tc.team_id = fet.team_id "
            "                              AND tc.ended_at IS NULL "
            "          JOIN coaches co ON co.id = tc.coach_id "
            "          JOIN persons p ON p.id = co.person_id "
            "         WHERE fet.fh_event_id = $1::bigint "
            "      ) combined "
            "      LEFT JOIN fh_event_attendance fea "
            "             ON fea.fh_event_id = $1::bigint "
            "            AND fea.person_id   = combined.person_id "
            "     ORDER BY combined.person_id, combined.is_coach ASC "
            "  ) roster "
            " ORDER BY roster.last_name, roster.first_name, roster.person_id",
            {std::to_string(fhEventId)});

        json roster = json::array();
        for (const auto& row : rows) {
            roster.push_back({
                {"person_id",  row["person_id"].as<long long>()},
                {"first_name", textOrNull(row, "first_name")},
                {"last_name",  textOrNull(row, "last_name")},
                {"is_coach",   row["is_coach"].as<bool>()},
                {"status",     textOrNull(row, "status")},
                {"marked_at",  textOrNull(row, "marked_at")},
            });
        }
        return jsonOk({{"fh_event_id", fhEventId}, {"can_mark", canMark}, {"roster", roster}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetEventAttendance: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handlePostEventAttendance(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.personId;

    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");
    }

    json body;
    try {
        body = request.getBody().empty()
            ? json::object()
            : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         std::string("Invalid JSON: ") + e.what());
    }

    auto targetPersonIdOpt = jsonInt(body, "person_id");
    if (!targetPersonIdOpt || *targetPersonIdOpt <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "person_id (positive int) required");
    }
    const long long targetPersonId = *targetPersonIdOpt;

    const std::string status = toLower(jsonStr(body, "status"));
    if (status != "present" && status != "absent" &&
        status != "late"    && status != "excused") {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "status must be 'present', 'absent', 'late', or 'excused'");
    }

    auto* db = Database::getInstance();
    try {
        auto evRows = db->query(
            "SELECT 1 FROM fh_events WHERE id = $1::bigint",
            {std::to_string(fhEventId)});
        if (evRows.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "fh_event not found");
        }

        if (!isEventCoachOrAdmin(db, personId, fhEventId)) {
            return jsonError(HttpStatus::FORBIDDEN,
                             "Only a coach of this event's team(s) or a club admin "
                             "can mark attendance.");
        }

        // The target must be a player OR coach on one of the event's
        // teams — otherwise a coach could mark attendance for an
        // arbitrary person_id outside the event's roster/staff.
        auto rosterCheck = db->query(
            "SELECT EXISTS ( "
            "  SELECT 1 FROM fh_event_teams fet "
            "  JOIN team_persons tp ON tp.team_id = fet.team_id "
            "                      AND tp.removed_at IS NULL "
            "  WHERE fet.fh_event_id = $1::bigint AND tp.person_id = $2::int "
            "  UNION ALL "
            "  SELECT 1 FROM fh_event_teams fet "
            "  JOIN team_coaches tc ON tc.team_id = fet.team_id "
            "                      AND tc.ended_at IS NULL "
            "  JOIN coaches co ON co.id = tc.coach_id "
            "  WHERE fet.fh_event_id = $1::bigint AND co.person_id = $2::int "
            ") AS on_roster",
            {std::to_string(fhEventId), std::to_string(targetPersonId)});
        if (rosterCheck.empty() || !rosterCheck[0]["on_roster"].as<bool>()) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "person is not on the roster/staff for this event");
        }

        const std::string markedByUserId = resolveUserId(db, personId);

        auto row = db->query(
            "INSERT INTO fh_event_attendance "
            "    (fh_event_id, person_id, status, marked_by_user_id, marked_at) "
            "VALUES ($1::bigint, $2::int, $3, NULLIF($4, '')::int, now()) "
            "ON CONFLICT (fh_event_id, person_id) DO UPDATE "
            "   SET status            = EXCLUDED.status, "
            "       marked_by_user_id = EXCLUDED.marked_by_user_id, "
            "       marked_at         = EXCLUDED.marked_at "
            "RETURNING id, fh_event_id, person_id, status, "
            "          to_char(marked_at AT TIME ZONE 'UTC', "
            "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS marked_at",
            {std::to_string(fhEventId), std::to_string(targetPersonId),
             status, markedByUserId});

        if (row.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "attendance write returned no row");
        }
        const auto& r0 = row[0];
        json attendance = {
            {"id",           r0["id"].as<long long>()},
            {"fh_event_id",  r0["fh_event_id"].as<long long>()},
            {"person_id",    r0["person_id"].as<long long>()},
            {"status",       r0["status"].as<std::string>()},
            {"marked_at",    r0["marked_at"].as<std::string>()},
        };
        return jsonOk({{"attendance", attendance}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handlePostEventAttendance: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handleDeleteEventAttendance(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.personId;

    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");
    }

    json body;
    try {
        body = request.getBody().empty()
            ? json::object()
            : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         std::string("Invalid JSON: ") + e.what());
    }

    auto targetPersonIdOpt = jsonInt(body, "person_id");
    if (!targetPersonIdOpt || *targetPersonIdOpt <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "person_id (positive int) required");
    }
    const long long targetPersonId = *targetPersonIdOpt;

    auto* db = Database::getInstance();
    try {
        auto evRows = db->query(
            "SELECT 1 FROM fh_events WHERE id = $1::bigint",
            {std::to_string(fhEventId)});
        if (evRows.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "fh_event not found");
        }

        if (!isEventCoachOrAdmin(db, personId, fhEventId)) {
            return jsonError(HttpStatus::FORBIDDEN,
                             "Only a coach of this event's team(s) or a club admin "
                             "can mark attendance.");
        }

        auto row = db->query(
            "DELETE FROM fh_event_attendance "
            " WHERE fh_event_id = $1::bigint AND person_id = $2::int "
            "RETURNING id",
            {std::to_string(fhEventId), std::to_string(targetPersonId)});

        if (row.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "no attendance mark to clear");
        }
        return jsonOk({{"cleared", true}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleDeleteEventAttendance: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
