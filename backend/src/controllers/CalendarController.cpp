#include "CalendarController.h"

#include "../core/Crypto.h"
#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cctype>
#include <exception>
#include <iostream>
#include <optional>
#include <regex>
#include <string>
#include <set>
#include <sstream>
#include <vector>

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

// ── Tag audit (2026-08-28) ──────────────────────────────────────────
// gcal-classify.js is forgiving by design: a description missing its
// Type: line still classifies, because the classifier infers kind from
// the resolved team aliases ("any team is pickup → kind=pickup").  That
// guess is invisible and occasionally wrong — tag a PRACTICE with
// `Team: …, Pickup` and it silently becomes a pickup event.  Rather
// than let ops find out from a confused player, we re-read the tag DSL
// here and hand the admin calendar a list of what a description is
// missing, naming the variable to add.  Read-only: this changes nothing
// about how the event classified, it only reports.
//
// Deliberately NOT enforcement.  Refusing to classify an under-tagged
// event would blank it out of everyone's calendar to punish a typo.
// Flag it, name the missing var, let a human fix the description.

// Mirror of jsNormAlias() in scripts/gcal-classify.js and migration
// 121's gcal_norm_alias() — lowercase, non-alphanumerics to spaces,
// collapse runs, trim.  All three must agree or the audit will report
// pairs that actually resolve fine.
std::string normAlias(const std::string& in) {
    std::string out;
    out.reserve(in.size());
    bool prevSpace = true;              // leading spaces collapse away
    for (unsigned char c : in) {
        const char lc = static_cast<char>(std::tolower(c));
        const bool alnum = (lc >= 'a' && lc <= 'z') || (lc >= '0' && lc <= '9');
        if (alnum) { out.push_back(lc); prevSpace = false; }
        else if (!prevSpace) { out.push_back(' '); prevSpace = true; }
    }
    while (!out.empty() && out.back() == ' ') out.pop_back();
    return out;
}

// Collect the values of one `Tag:` line out of a gcal description.
// Values are comma-separated on a line and the tag may repeat across
// lines; both forms accumulate, matching the classifier.
std::vector<std::string> tagValues(const std::string& desc, const std::string& tag) {
    std::vector<std::string> out;
    const std::string needle = normAlias(tag);
    std::istringstream lines(desc);
    std::string line;
    while (std::getline(lines, line)) {
        const auto colon = line.find(':');
        if (colon == std::string::npos) continue;
        if (normAlias(line.substr(0, colon)) != needle) continue;
        std::string rest = line.substr(colon + 1);
        std::string cur;
        std::istringstream vals(rest);
        while (std::getline(vals, cur, ',')) {
            const std::string v = normAlias(cur);
            if (!v.empty()) out.push_back(v);
        }
    }
    return out;
}

// What is this description missing?  Empty vector == fully tagged.
// `aliases` is the gcal_team_aliases set as "club|team" keys.
std::vector<std::string> auditTags(const std::string& desc,
                                   const std::set<std::string>& aliases,
                                   bool checkPairs) {
    std::vector<std::string> issues;
    if (desc.empty()) return issues;

    const auto teams = tagValues(desc, "team");
    const auto clubs = tagValues(desc, "club");
    auto kinds       = tagValues(desc, "type");
    if (kinds.empty()) kinds = tagValues(desc, "kind");

    // An event with no Team: at all is the pre-existing "unclassified"
    // case the admin calendar already surfaces on its own — don't
    // double-report it here as four separate missing variables.
    if (teams.empty() && clubs.empty()) return issues;

    if (teams.empty()) {
        issues.push_back("Missing `Team:` — Club: alone attaches no roster, "
                         "so nobody is RSVP-eligible for this event.");
    }
    if (clubs.empty()) {
        issues.push_back("Missing `Club:` — Team: values only resolve as a "
                         "(Club, Team) pair, so none of them attach.");
    }
    if (kinds.empty()) {
        issues.push_back("Missing `Type:` — kind is being GUESSED from the "
                         "team names. Add `Type: Practice` (or Pickup / Match / "
                         "Meeting / Camp / Other / Barn Night) to make it explicit.");
    }
    // Cross-product every (club, team) exactly as the classifier does,
    // and name any pair that has no gcal_team_aliases row — those
    // silently attach no team instead of erroring.
    // Report a `Team:` value only when NO club on this event resolves
    // it — i.e. it genuinely attaches no roster.  Checking pair-by-pair
    // instead looks correct and is useless in practice: the youth
    // practices are tagged `Club: Boys, Girls`, there is no `girls`
    // alias, and the girls are rostered on the boys-named teams anyway,
    // so every one of those events would carry a warning about a
    // redundant tag that breaks nothing.  Half the calendar lighting up
    // for a non-problem is how a warning gets trained into wallpaper.
    if (checkPairs) {
        for (const auto& t : teams) {
            bool resolvedByAnyClub = false;
            for (const auto& c : clubs) {
                if (aliases.count(c + "|" + t)) { resolvedByAnyClub = true; break; }
            }
            if (resolvedByAnyClub) continue;
            issues.push_back("`Team: " + t + "` matches no team for any Club: on "
                             "this event — no roster attaches for it, so nobody "
                             "becomes RSVP-eligible through it. Fix the spelling "
                             "or add the alias.");
        }
    }
    return issues;
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
                -- showing the wrong club's crest. Third: opponent_logo_cache
                -- (migration 289) — a live TheSportsDb lookup the C++ layer
                -- below performs and caches the first time it sees a new
                -- opponent text; NULLIF collapses its '' ("looked, found
                -- nothing") sentinel back to real NULL. Still-NULL falls
                -- through to the Lighthouse crest on the frontend.
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
                      LIMIT 1),
                    (SELECT NULLIF(olc.logo_url, '') FROM opponent_logo_cache olc
                      WHERE fe.opponent IS NOT NULL
                        AND LOWER(BTRIM(olc.opponent_text)) = LOWER(BTRIM(fe.opponent))
                      LIMIT 1)
                ) AS opponent_logo_url,
                -- Have we ever attempted a live lookup for this opponent
                -- text, success or not? Gates the C++ fallback below so we
                -- hit the external API once per distinct opponent, not on
                -- every request.
                EXISTS (
                    SELECT 1 FROM opponent_logo_cache olc
                     WHERE fe.opponent IS NOT NULL
                       AND LOWER(BTRIM(olc.opponent_text)) = LOWER(BTRIM(fe.opponent))
                ) AS opponent_logo_checked,
                fe.fh_notes,
                fe.league,
                -- The league's own crest, whenever the gcal `League:` tag
                -- is set (owner, 2026-08-28: "we should always have league
                -- logo if league var is set"). Same
                -- fh_events.league -> gcal_league_aliases -> organizations
                -- chain EventController's LEAGUE_CREST_SQL uses, but keyed
                -- straight off fh_events rather than through matches, so a
                -- practice or pickup carrying a League: tag gets one too.
                --
                -- This is what tells two intra-squad games apart on the
                -- RSVP card: "Lighthouse APSL vs Lighthouse Liga 1" has
                -- Lighthouse on both sides, so opponent_logo_url resolves
                -- to the same crest for both and a player cannot see which
                -- game is which.
                -- From fh_event_leagues (migration 318), not by splitting
                -- fh_events.league here: one event can belong to two
                -- leagues (intra-squad APSL vs Liga 1, cross-league
                -- friendlies, cup ties), and that is a many-to-many
                -- relationship rather than a string to be parsed at each
                -- call site. Comma-separated on the way out only because
                -- the JSON field is one string; the frontend splits it to
                -- render one badge per league.
                (SELECT string_agg(DISTINCT o.logo_url, ',')
                   FROM fh_event_leagues fel
                   JOIN organizations o ON o.id = fel.organization_id
                  WHERE fel.fh_event_id = fe.id) AS league_logo_url,
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
                -- Guardian visibility (2026-08-28).  A parent of a
                -- rostered child holds no team_persons row of their own,
                -- so `eligible` is false for them and every one of their
                -- kid's practices was filtered out of their calendar.
                --
                -- Deliberately a SEPARATE column rather than another OR
                -- inside `eligible`: that flag also gates
                -- POST /api/calendar/rsvp, and fh_event_rsvps is keyed on
                -- the CALLER's person_id.  A guardian answering there
                -- would file an RSVP for themselves and show up on the
                -- who's-going list as a player.  Parents get read access
                -- here; RSVP stays with the player, coach, and admin.
                -- Which of the caller's children are on this event's
                -- roster.  NULL (string_agg over no rows) means none,
                -- which is exactly the is_guardian test — so this one
                -- subquery answers both questions and the outer SELECT
                -- derives the boolean from it.  Naming the children is
                -- not decoration: a parent with two players cannot
                -- otherwise tell whose practice a card refers to.
                (
                    SELECT string_agg(DISTINCT child.first_name || ' ' || child.last_name, ', ')
                    FROM fh_event_teams fet
                    JOIN team_persons tp ON tp.team_id = fet.team_id
                                        AND tp.removed_at IS NULL
                    JOIN persons child ON child.id = tp.person_id
                    WHERE fet.fh_event_id = fe.id
                      AND child.parent_person_id = $1::int
                ) AS guardian_children,
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
                                                                     -- the generic Pickup(909) pool —
                                                                     -- not via any specifically-named team tagged on
                                                                     -- the event (any live mens squad). Computed
                                                                     -- person-level (scoped to fe.id's own tagged
                                                                     -- teams) rather than per-row, so it's stable
                                                                     -- under DISTINCT ON regardless of which of a
                                                                     -- multi-team person's rows wins the tie. The
                                                                     -- test is NOT IN (909) rather than a
                                                                     -- whitelist of squad ids: an earlier hardcoded
                                                                     -- whitelist predated the trialist teams and
                                                                     -- wrongly hid trialists tagged on their own
                                                                     -- practice events. Naming the two pool teams
                                                                     -- instead means a new squad needs no edit here.
                                                                     -- Practice (908) dropped from the test with
                                                                     -- migration 309: a practice is a calendar
                                                                     -- event with teams tagged on it, so there is
                                                                     -- no practice pool to exclude any more.
                                                                     WHEN fe.category = 'mens' THEN NOT EXISTS (
                                                                             SELECT 1
                                                                                 FROM team_persons tp_sel
                                                                                 JOIN fh_event_teams fet_sel
                                                                                   ON fet_sel.team_id = tp_sel.team_id
                                                                                WHERE tp_sel.person_id    = p.id
                                                                                    AND tp_sel.removed_at IS NULL
                                                                                    AND fet_sel.fh_event_id = fe.id
                                                                                    AND tp_sel.team_id <> 909
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
                  WHEN $4 = '' THEN ((now() AT TIME ZONE 'America/New_York')::date) AT TIME ZONE 'America/New_York'
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
            SELECT base.*, (base.guardian_children IS NOT NULL) AS is_guardian
            FROM base
            WHERE $1::int = 0 OR base.eligible
               OR base.guardian_children IS NOT NULL
            ORDER BY base.raw_starts_at ASC, base.raw_gcal_id ASC
            LIMIT 500
        )SQL";

        pqxx::result rows = db->query(sql, {
            std::to_string(personId),
            std::to_string(days),
                        includeUnclassified ? "true" : "false",
            startParam,
        });

        // Whole alias table, once per request — it is a handful of rows
        // and the audit needs it for every event's (club, team) pairs.
        std::set<std::string> aliasKeys;
        try {
            auto ar = db->query("SELECT club_alias, team_alias FROM gcal_team_aliases");
            for (const auto& r : ar) {
                aliasKeys.insert(std::string(r["club_alias"].c_str()) + "|"
                               + std::string(r["team_alias"].c_str()));
            }
        } catch (const std::exception& e) {
            // Audit is advisory; a failure here must not cost the caller
            // their calendar.  Empty set == every pair reads as unknown,
            // so bail to "no audit" instead by leaving it empty and
            // skipping the pair check below.
            std::cerr << "[CalendarController] tag audit alias load failed: "
                      << e.what() << std::endl;
        }
        const bool auditPairs = !aliasKeys.empty();

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
            ev["league"]            = textOrNull(row, "league");
            ev["league_logo_url"]   = textOrNull(row, "league_logo_url");
            // No DB match (hand-seeded alias / exact teams.name / prior
            // cache) — try a live lookup exactly once per distinct
            // opponent text, then cache whatever we found (or didn't).
            if (ev["opponent_logo_url"].is_null()
                && !row["opponent"].is_null()
                && std::string(row["kind"].c_str()) == "match"
                && !row["opponent_logo_checked"].as<bool>()) {
                auto found = fetchAndCacheOpponentLogo(row["opponent"].as<std::string>());
                if (found) ev["opponent_logo_url"] = *found;
            }
            ev["fh_notes"]          = textOrNull(row, "fh_notes");
            // What this event's description is missing, in plain words,
            // naming the variable to add.  Empty array == fully tagged.
            // The admin Soccer Calendar (#calendar) badges any event
            // with a non-empty list; player-facing screens ignore it.
            {
                json issues = json::array();
                if (!row["description"].is_null()) {
                    for (const auto& s : auditTags(row["description"].as<std::string>(),
                                                   aliasKeys, auditPairs)) {
                        issues.push_back(s);
                    }
                }
                ev["tag_issues"] = std::move(issues);
            }
            ev["rsvps_open_at"]     = textOrNull(row, "rsvps_open_at");
            ev["rsvps_open_now"]    = row["rsvps_open_now"].as<bool>();
            ev["my_rsvp"]           = textOrNull(row, "my_rsvp");
            ev["my_rsvp_created_via"]= textOrNull(row, "my_rsvp_created_via");
            ev["my_rsvp_eligible"]  = boolOrNull(row, "my_rsvp_eligible");
            ev["is_guardian"]       = row["is_guardian"].as<bool>();
            ev["guardian_children"] = textOrNull(row, "guardian_children");
            {
                const bool eligible = row["eligible"].as<bool>();
                const bool guardian = row["is_guardian"].as<bool>();
                const int teamCount = row["team_count"].as<int>();
                if (row["my_rsvp_eligible"].is_null()) {
                    ev["my_rsvp_eligibility_reason"] = nullptr;
                } else if (!eligible) {
                    if (guardian) {
                        // Explain the event's presence rather than the
                        // absence of a button — a parent seeing "you are
                        // not on the roster" on their own child's
                        // practice reads as an error, not an answer.
                        const std::string kids = row["guardian_children"].is_null()
                            ? std::string("your player")
                            : row["guardian_children"].as<std::string>();
                        ev["my_rsvp_eligibility_reason"] =
                            "You can see this because " + kids +
                            " is on the roster. Players answer their own RSVP.";
                    } else if (teamCount == 0) {
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

        json body = {
            {"days",   days},
            {"count",  events.size()},
            {"events", std::move(events)},
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

std::optional<std::string> CalendarController::fetchAndCacheOpponentLogo(const std::string& opponentText) {
    if (opponentText.empty()) return std::nullopt;

    // Ops sometimes types the league right into the Opponent: tag itself
    // ("Real Central NJ APSL", "German American Kickers Liga 1") to tell
    // two same-week fixtures apart — real enough club-name text for a
    // person reading the card, but it makes the opponent's actual name
    // unsearchable verbatim. Strip one trailing league/division token
    // before searching; the cache key stays the untouched original text
    // so it still matches this exact Opponent: tag next time.
    static const std::regex trailingLeague(
        R"(\s+(APSL|Liga\s?1|Liga\s?2|Adult|Pickup|Practice)\s*$)",
        std::regex::icase);
    const std::string searchText = std::regex_replace(opponentText, trailingLeague, "");

    std::string logoUrl;  // stays empty on any miss/failure — that's the cache's "checked, nothing found" sentinel
    try {
        HttpClient http;
        // TheSportsDb's public test key ("3") — free tier, no account
        // needed, standard for exactly this "look up a club crest by
        // name" use case. Single best-effort attempt; any failure just
        // falls through to caching an empty result.
        const std::string url = "https://www.thesportsdb.com/api/v1/json/3/searchteams.php?t="
                               + HttpClient::urlEncode(searchText);
        auto res = http.get(url);
        if (res.ok()) {
            auto body = json::parse(res.body, nullptr, false);
            if (!body.is_discarded() && body.contains("teams") && body["teams"].is_array()
                && !body["teams"].empty()) {
                const auto& team = body["teams"][0];
                // v1 searchteams.php calls the crest field strBadge (NOT
                // strTeamBadge, which exists in the schema but is always
                // null here) — strLogo as a fallback for the rare record
                // that has a wordmark logo but no badge.
                if (team.contains("strBadge") && team["strBadge"].is_string()
                    && !team["strBadge"].get<std::string>().empty()) {
                    logoUrl = team["strBadge"].get<std::string>();
                } else if (team.contains("strLogo") && team["strLogo"].is_string()) {
                    logoUrl = team["strLogo"].get<std::string>();
                }
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::fetchAndCacheOpponentLogo(" << opponentText
                  << "): " << e.what() << std::endl;
    }

    try {
        Database::getInstance()->query(
            "INSERT INTO opponent_logo_cache (opponent_text, logo_url, source) "
            "VALUES ($1, $2, 'thesportsdb') "
            "ON CONFLICT (LOWER(BTRIM(opponent_text))) "
            "DO UPDATE SET logo_url = EXCLUDED.logo_url, fetched_at = now()",
            {opponentText, logoUrl});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::fetchAndCacheOpponentLogo: cache write failed: "
                  << e.what() << std::endl;
    }

    return logoUrl.empty() ? std::nullopt : std::optional<std::string>(logoUrl);
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
//     409 with an explanatory body.
//   * Upsert one fh_event_rsvps row (fh_event_id, person_id) →
//     (response, responded_at=now(), created_via='manual').
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
