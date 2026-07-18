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
// Mirrors MyController::applyImpersonation.  Read endpoints (upcoming,
// my-standing) let an admin pass `?asPersonId=N` to render as person
// N.  Writes deliberately do NOT — an admin viewing as a player must
// not be able to accidentally RSVP as that player.
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
    router.get(prefix + "/calendar/my-standing", [this](const Request& req) {
        return this->handleGetMyStanding(req);
    });
    router.post(prefix + "/calendar/my-standing", [this](const Request& req) {
        return this->handlePostMyStanding(req);
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

        // The query joins the FH classification (fh_events) to its
        // Google mirror row (gcal_events) and the calendar metadata
        // (gcal_calendars).  Filters:
        //   * deleted_at IS NULL     — respects the tombstone contract
        //   * status <> 'cancelled'  — belt-and-suspenders; the sync
        //                              worker sets deleted_at when
        //                              status flips to 'cancelled' but
        //                              guarding both makes the query
        //                              correct regardless of order.
        //   * starts_at >= now() - 1h — include events that are
        //                               currently underway so the
        //                               live day view isn't empty
        //                               right after kickoff.
        //   * starts_at falls inside the currently visible one-week
        //                               window in America/New_York:
        //                               current week until Sunday 20:00 ET,
        //                               then next week after the cutover.
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
        // my_rsvp_eligible walks the same junction to
        // player_rsvp_eligibility (via the leagueapps external alias
        // chain — identical shape to MyController::callerRosteredForMatch)
        // and reports whether the caller has an eligibility grant on
        // ANY team attached to the event.  NULL when anonymous.
        //
        // hangout_link is the Meet URL extracted from the raw gcal
        // event payload — Google puts it on `hangoutLink` for events
        // with a Meet attached.  NULL when no Meet.
        const std::string sql = R"SQL(
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
                fe.kind,
                fe.category,
                fe.is_home,
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
                COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id',              t.id,
                            'name',            t.name,
                            'gender_category', t.gender_category
                        )
                        ORDER BY t.id
                    )
                    FROM fh_event_teams fet
                    JOIN teams t ON t.id = fet.team_id
                    WHERE fet.fh_event_id = fe.id
                ), '[]'::jsonb) AS teams_json,
                CASE
                    WHEN $2::int = 0 THEN NULL
                    ELSE EXISTS (
                        SELECT 1
                        FROM   fh_event_teams fet
                        JOIN   player_rsvp_eligibility ple
                            ON ple.team_id = fet.team_id
                        JOIN   external_person_aliases epa
                            ON epa.provider = 'leagueapps'
                           AND epa.external_user_id = ple.leagueapps_user_id::text
                        WHERE  fet.fh_event_id = fe.id
                          AND  epa.person_id   = $2::int
                    )
                END AS my_rsvp_eligible
            FROM fh_events   fe
            JOIN gcal_events ge ON ge.id = fe.gcal_event_id
            JOIN gcal_calendars gc ON gc.id = ge.calendar_id
            LEFT JOIN fh_event_rsvps mr
                   ON mr.fh_event_id = fe.id
                  AND mr.person_id   = $2::int
            WHERE ge.deleted_at IS NULL
              AND ge.status <> 'cancelled'
              AND ge.starts_at >= now() - INTERVAL '1 hour'
              AND ge.starts_at >= CASE
                    WHEN (now() AT TIME ZONE 'America/New_York') >=
                         (date_trunc('week', now() AT TIME ZONE 'America/New_York')
                          + INTERVAL '6 days'
                          + INTERVAL '20 hours')
                    THEN timezone('UTC',
                        (date_trunc('week', (now() AT TIME ZONE 'America/New_York') + INTERVAL '7 days')::timestamp))
                    ELSE timezone('UTC',
                        (date_trunc('week', now() AT TIME ZONE 'America/New_York')::timestamp))
                END
              AND ge.starts_at < CASE
                    WHEN (now() AT TIME ZONE 'America/New_York') >=
                         (date_trunc('week', now() AT TIME ZONE 'America/New_York')
                          + INTERVAL '6 days'
                          + INTERVAL '20 hours')
                    THEN timezone('UTC',
                        (date_trunc('week', (now() AT TIME ZONE 'America/New_York') + INTERVAL '7 days')::timestamp
                         + INTERVAL '6 days'
                         + INTERVAL '23 hours'
                         + INTERVAL '59 minutes'
                         + INTERVAL '59 seconds'))
                    ELSE timezone('UTC',
                        (date_trunc('week', now() AT TIME ZONE 'America/New_York')::timestamp
                         + INTERVAL '6 days'
                         + INTERVAL '23 hours'
                         + INTERVAL '59 minutes'
                         + INTERVAL '59 seconds'))
                END
            ORDER BY ge.starts_at ASC, ge.id ASC
            LIMIT 500
        )SQL";

        pqxx::result rows = db->query(sql, {std::to_string(personId)});

        json events = json::array();
        events.get_ref<json::array_t&>().reserve(rows.size());

        for (const auto& row : rows) {
            json ev;
            ev["fh_event_id"]       = row["fh_event_id"].as<long long>();
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
            ev["fh_notes"]          = textOrNull(row, "fh_notes");
            ev["rsvps_open_at"]     = textOrNull(row, "rsvps_open_at");
            ev["rsvps_open_now"]    = row["rsvps_open_now"].as<bool>();
            ev["my_rsvp"]           = textOrNull(row, "my_rsvp");
            ev["my_rsvp_created_via"]= textOrNull(row, "my_rsvp_created_via");
            ev["my_rsvp_eligible"]  = boolOrNull(row, "my_rsvp_eligible");
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
            events.push_back(std::move(ev));
        }

        json body = {
            {"days",   days},
            {"count",  events.size()},
            {"events", std::move(events)},
        };
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

        // Eligibility gate — §6.1.5.  The caller must have a
        // player_rsvp_eligibility grant for AT LEAST ONE team attached
        // to this event via the junction (fh_event_teams).  The join
        // chain mirrors MyController::callerRosteredForMatch — team →
        // player_rsvp_eligibility → external_person_aliases → person.
        //
        // Failure modes this gate catches:
        //   * Signed-in mens roster member trying to RSVP a womens
        //     event (no ple.team_id row for them on any womens team).
        //   * DSL-unclassified event (empty fh_event_teams) — no
        //     junction rows means no team means EXISTS = false, so
        //     403 with "event has no roster attached".  The DB never
        //     accepts an RSVP to an event whose team model isn't set
        //     up yet, which is the correct fail-closed behaviour.
        //
        // We fetch team_count separately so the 403 body can
        // distinguish "wrong roster" from "event has no teams yet",
        // which is a much clearer error message for the frontend +
        // for operator debugging.
        auto eligRows = db->query(
            "SELECT "
            "  (SELECT COUNT(*)::int FROM fh_event_teams "
            "     WHERE fh_event_id = $1::bigint) AS team_count, "
            "  EXISTS ( "
            "    SELECT 1 "
            "      FROM fh_event_teams fet "
            "      JOIN player_rsvp_eligibility ple "
            "        ON ple.team_id = fet.team_id "
            "      JOIN external_person_aliases epa "
            "        ON epa.provider = 'leagueapps' "
            "       AND epa.external_user_id = ple.leagueapps_user_id::text "
            "     WHERE fet.fh_event_id = $1::bigint "
            "       AND epa.person_id   = $2::int "
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

// ─── Slice 6a: standing / recurring RSVP preferences (§6.5.3) ──────
//
// Model: one row in fh_recurring_rsvps per (person, kind, category)
// tuple.  `category` may be NULL for a "any category" pref — the
// applier treats NULL as "matches all", so a single row with
// kind='pickup', category=NULL auto-YESes on every pickup event the
// user is roster-eligible for.  The current profile UI (§0.3) will
// generally emit one row per (kind, category) pair the user checks
// so the toggle grid is a straight WYSIWYG match to DB shape, but the
// endpoint accepts NULL for power users / future flexibility.
//
// `active` is a soft-delete flag — flipping to false leaves the row
// (audit / "undo" affordance) and the applier's WHERE active=true
// filter skips it.  This lets a user briefly turn off "auto-RSVP for
// mens practice while I'm out of town" without losing the pref.

Response CalendarController::handleGetMyStanding(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    long long personId = gate.personId;

    // Admin view-as: swap the effective person for read purposes so
    // the standing-prefs grid shows the impersonated player's rows.
    if (auto err = applyImpersonation(request, personId, &personId)) {
        return *err;
    }

    try {
        auto* db = Database::getInstance();
        // Return ALL rows — including inactive ones — so the profile
        // UI can show a "you turned this off on <date>" affordance.
        // Sort deterministically so the client can render the toggle
        // grid in a stable order.
        auto rows = db->query(
            "SELECT id, kind, category, response, active, "
            "       to_char(created_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
            "       to_char(updated_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS updated_at "
            "  FROM fh_recurring_rsvps "
            " WHERE person_id = $1::int "
            " ORDER BY kind ASC, COALESCE(category, '') ASC",
            {std::to_string(personId)});

        json prefs = json::array();
        prefs.get_ref<json::array_t&>().reserve(rows.size());
        for (const auto& row : rows) {
            json p;
            p["id"]         = row["id"].as<long long>();
            p["kind"]       = row["kind"].c_str();
            p["category"]   = textOrNull(row, "category");
            p["response"]   = row["response"].c_str();
            p["active"]     = row["active"].as<bool>();
            p["created_at"] = row["created_at"].c_str();
            p["updated_at"] = row["updated_at"].c_str();
            prefs.push_back(std::move(p));
        }
        return jsonOk({{"prefs", std::move(prefs)}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetMyStanding: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handlePostMyStanding(const Request& request) {
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

    // kind must be one of the fh_events.kind CHECK values — the DB
    // has no CHECK on fh_recurring_rsvps.kind (migration 119 line
    // ~185 kept it flexible), so we enforce here.  Any drift with
    // the fh_events shape means the pref will never match anything
    // and the applier silently skips it, which is a much worse
    // failure mode than a 400 at write time.
    const std::string kind = toLower(jsonStr(body, "kind"));
    static const std::string kAllowedKinds[] = {
        "practice", "pickup", "match", "meeting", "camp", "other"
    };
    bool kindOk = false;
    for (const auto& k : kAllowedKinds) if (k == kind) { kindOk = true; break; }
    if (!kindOk) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "kind must be one of practice|pickup|match|meeting|camp|other");
    }

    // category may be omitted / null / a valid enum.  The DB CHECK
    // on fh_events.category is 'mens|womens|boys|girls|staff'; we
    // mirror that here.  NULL means "matches any category", per the
    // applier semantics (see §6.5.3 rules).
    std::string category;
    bool categoryNull = true;
    if (body.contains("category") && !body["category"].is_null()) {
        category     = toLower(jsonStr(body, "category"));
        categoryNull = false;
        static const std::string kAllowedCategories[] = {
            "mens", "womens", "boys", "girls", "staff"
        };
        bool catOk = false;
        for (const auto& c : kAllowedCategories) if (c == category) { catOk = true; break; }
        if (!catOk) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "category must be null or one of mens|womens|boys|girls|staff");
        }
    }

    const std::string response = toLower(jsonStr(body, "response"));
    if (response != "yes" && response != "no" && response != "maybe") {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "response must be 'yes', 'no', or 'maybe'");
    }

    // `active` defaults to true — the common case is "user just
    // ticked this checkbox in the profile grid".  Only an explicit
    // false turns it off.
    bool active = true;
    if (body.contains("active") && !body["active"].is_null()) {
        if (body["active"].is_boolean()) {
            active = body["active"].get<bool>();
        } else {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "active must be boolean");
        }
    }

    try {
        auto* db = Database::getInstance();

        // Two upsert shapes needed because Postgres treats NULL as
        // distinct in ordinary UNIQUE constraints — migration 119
        // sidesteps this with a functional unique index on
        // (person_id, kind, COALESCE(category, '')).  We invoke
        // that index by NAME (`fh_recurring_rsvps_unique_idx`) so
        // ON CONFLICT resolves correctly whether category is NULL
        // or a value.  (Named-index conflict target is Postgres
        // syntax `ON CONFLICT ON CONSTRAINT <name>`, but that only
        // works for real UNIQUE constraints — for a functional
        // unique index the columns-list form works as long as the
        // expressions match exactly.)
        pqxx::result row;
        if (categoryNull) {
            row = db->query(
                "INSERT INTO fh_recurring_rsvps "
                "    (person_id, kind, category, response, active, updated_at) "
                "VALUES ($1::int, $2, NULL, $3, $4::bool, now()) "
                "ON CONFLICT (person_id, kind, COALESCE(category, '')) DO UPDATE "
                "   SET response   = EXCLUDED.response, "
                "       active     = EXCLUDED.active, "
                "       updated_at = now() "
                "RETURNING id, kind, category, response, active, "
                "          to_char(created_at AT TIME ZONE 'UTC', "
                "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
                "          to_char(updated_at AT TIME ZONE 'UTC', "
                "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS updated_at",
                {std::to_string(personId), kind, response,
                 active ? "true" : "false"});
        } else {
            row = db->query(
                "INSERT INTO fh_recurring_rsvps "
                "    (person_id, kind, category, response, active, updated_at) "
                "VALUES ($1::int, $2, $3, $4, $5::bool, now()) "
                "ON CONFLICT (person_id, kind, COALESCE(category, '')) DO UPDATE "
                "   SET response   = EXCLUDED.response, "
                "       active     = EXCLUDED.active, "
                "       updated_at = now() "
                "RETURNING id, kind, category, response, active, "
                "          to_char(created_at AT TIME ZONE 'UTC', "
                "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
                "          to_char(updated_at AT TIME ZONE 'UTC', "
                "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS updated_at",
                {std::to_string(personId), kind, category, response,
                 active ? "true" : "false"});
        }

        if (row.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "standing upsert returned no row");
        }
        const auto& r0 = row[0];
        json pref = {
            {"id",         r0["id"].as<long long>()},
            {"kind",       r0["kind"].as<std::string>()},
            {"category",   textOrNull(r0, "category")},
            {"response",   r0["response"].as<std::string>()},
            {"active",     r0["active"].as<bool>()},
            {"created_at", r0["created_at"].as<std::string>()},
            {"updated_at", r0["updated_at"].as<std::string>()},
        };
        return jsonOk({{"pref", pref}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handlePostMyStanding: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
