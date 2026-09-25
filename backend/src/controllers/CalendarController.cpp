#include "CalendarController.h"
#include "../models/ClubLogoSearch.h"

#include "../core/Crypto.h"
#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../models/WelcomeLog.h"
#include "../services/MagicLinkService.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cctype>
#include <cstdio>
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
    // No trailing segment is the single-event route itself
    // (GET /calendar/events/:fhEventId).
    auto end = path.find('/', start);
    if (end == std::string::npos) end = path.size();
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

// Shared by handlePostRsvp and handleDeleteRsvp: does the underlying
// gcal event still exist/isn't cancelled, and is the RSVP window open?
// Returns an error Response when the write should be rejected,
// std::nullopt when it's fine to proceed.
std::optional<Response> checkRsvpWindowOpen(Database* db, long long fhEventId) {
    auto checkRows = db->query(
        "SELECT fe.id, "
        "       ge.deleted_at IS NOT NULL AS gcal_tombstoned, "
        "       ge.status = 'cancelled'   AS gcal_cancelled, "
        // Derived from the release rule (migration 335), not the stored column.
        "       fh_event_rsvps_open_at(fe.id) AS rsvps_open_at, "
        "       (fh_event_rsvps_open_at(fe.id) IS NULL "
        "        OR fh_event_rsvps_open_at(fe.id) <= now()) AS rsvps_open_now, "
        "       to_char(fh_event_rsvps_open_at(fe.id) AT TIME ZONE 'UTC', "
        "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS rsvps_open_at_iso "
        "  FROM fh_events   fe "
        "  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
        " WHERE fe.id = $1::bigint",
        {std::to_string(fhEventId)});

    if (checkRows.empty()) {
        return jsonError(HttpStatus::NOT_FOUND, "fh_event not found");
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
    return std::nullopt;
}

// Resolves which person_id an RSVP write (POST or DELETE) should
// target, and whether callerPersonId may write it. Three ways in:
//   - no target requested → caller writes for themselves, and must
//     hold an active (non-suspended) roster/coach spot on one of the
//     event's teams.
//   - target requested and it IS the caller → same as above.
//   - target requested and it is the caller's own child
//     (persons.parent_person_id) → caller may write it on the child's
//     behalf, keyed to the CHILD's person_id, provided the child holds
//     that same active roster spot. A parent can never write for
//     anyone who isn't their own child.
// A club admin always passes, for any target, without a roster check.
std::optional<Response> resolveRsvpTarget(Database* db,
                                           long long callerPersonId,
                                           std::optional<long long> requestedPersonId,
                                           long long fhEventId,
                                           long long* outTargetPersonId) {
    const long long targetPersonId = requestedPersonId.value_or(callerPersonId);

    auto rows = db->query(
        "SELECT "
        "  (SELECT COUNT(*)::int FROM fh_event_teams "
        "     WHERE fh_event_id = $1::bigint) AS team_count, "
        "  EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
        "          WHERE u.person_id = $2::int) AS is_admin, "
        "  ($2::int = $3::int OR EXISTS ("
        "      SELECT 1 FROM persons "
        "       WHERE id = $3::int AND parent_person_id = $2::int"
        "  )) AS may_act_for_target, "
        "  (EXISTS ("
        "    SELECT 1 FROM fh_event_teams fet "
        "    WHERE fet.fh_event_id = $1::bigint "
        "      AND ("
        "        EXISTS ("
        "          SELECT 1 FROM team_persons tp "
        "          WHERE tp.team_id = fet.team_id "
        "            AND tp.person_id = $3::int "
        "            AND tp.removed_at IS NULL "
        "            AND NOT EXISTS ("
        "                SELECT 1 FROM rsvp_suspensions s "
        "                WHERE s.person_id = tp.person_id "
        "                  AND (s.team_id IS NULL OR s.team_id = tp.team_id) "
        "                  AND s.starts_at <= now() "
        "                  AND (s.ends_at IS NULL OR s.ends_at > now())"
        "            )"
        "        )"
        "        OR EXISTS ("
        "          SELECT 1 FROM team_coaches tc "
        "          JOIN coaches co ON co.id = tc.coach_id "
        "          WHERE tc.team_id = fet.team_id AND tc.ended_at IS NULL "
        "            AND co.person_id = $3::int"
        "        )"
        "      )"
        "  ) "
        // Invited (fh_event_invites, migration 355): a call-up or
        // play-down the coach explicitly invited may RSVP like a
        // rostered player. Age-eligibility alone (fh_event_callups)
        // no longer opens the door — owner, 2026-09-12/13.
        "  OR fh_event_invited($1::bigint, $3::int)) AS target_on_roster",
        {std::to_string(fhEventId), std::to_string(callerPersonId), std::to_string(targetPersonId)});

    if (rows.empty()) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                         "eligibility check returned no row");
    }
    const auto& row = rows[0];
    const int teamCount = row["team_count"].as<int>();
    if (teamCount == 0) {
        return jsonError(HttpStatus::FORBIDDEN,
                         "This event has no roster attached yet — "
                         "ops needs to add Team:/Club: tags to the "
                         "Google Calendar description.");
    }
    const bool isAdmin         = row["is_admin"].as<bool>();
    const bool mayActForTarget = row["may_act_for_target"].as<bool>();
    if (!isAdmin && !mayActForTarget) {
        return jsonError(HttpStatus::FORBIDDEN,
                         "You can only RSVP for yourself or your own child.");
    }
    if (!isAdmin && !row["target_on_roster"].as<bool>()) {
        return jsonError(HttpStatus::FORBIDDEN,
                         requestedPersonId.has_value()
                             ? "That player is not on the roster for this event."
                             : "You are not on the roster for this event.");
    }
    *outTargetPersonId = targetPersonId;
    return std::nullopt;
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
    router.del(prefix + "/calendar/rsvp", [this](const Request& req) {
        return this->handleDeleteRsvp(req);
    });
    router.get(prefix + "/calendar/events/:fhEventId", [this](const Request& req) {
        return handleGetEvent(req);
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
    router.get(prefix + "/calendar/events/:fhEventId/session-plan", [this](const Request& req) {
        return handleGetEventSessionPlan(req);
    });
    router.get(prefix + "/calendar/events/:fhEventId/sides", [this](const Request& req) {
        return handleGetEventSides(req);
    });
    router.post(prefix + "/calendar/events/:fhEventId/sides", [this](const Request& req) {
        return handlePostEventSide(req);
    });
    router.get(prefix + "/calendar/events/:fhEventId/invites", [this](const Request& req) {
        return this->handleGetEventInvites(req);
    });
    router.post(prefix + "/calendar/events/:fhEventId/invites", [this](const Request& req) {
        return this->handlePostEventInvite(req);
    });
    router.del(prefix + "/calendar/events/:fhEventId/invites/:personId", [this](const Request& req) {
        return this->handleDeleteEventInvite(req);
    });
}

Response CalendarController::handleGetUpcoming(const Request& request) {
    return upcomingResponse(request, 0);
}

// GET /calendar/events/:fhEventId — one event, in exactly the shape the
// upcoming feed gives it (same query, same visibility rule), whatever its
// date.  Lets a screen open an event from a link instead of needing the
// feed object handed to it.  Members only: 404 covers both "no such event"
// and "not yours to see".
Response CalendarController::handleGetEvent(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");
    }
    return upcomingResponse(request, fhEventId);
}

// onlyFhEventId > 0 swaps the date window for that one event and answers
// { event } (404 when the caller can't see it); 0 is the feed.
Response CalendarController::upcomingResponse(const Request& request, long long onlyFhEventId) {
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

    // Club/super admins see everyone's phone and email on the RSVP lists
    // (for the bulk text/email buttons on #my); nobody else does.
    // …and not while viewing as someone else (?asPersonId): view-as shows
    // exactly what that person gets, contact details included.
    const bool viewerIsAdmin = requireAdminLevel(request, {"club", "super"})
                            && request.getQueryParam("asPersonId").empty();

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
                    -- club_aliases + clubs (migration 428): the curated
                    -- opponent-text -> club mapping the #logos page
                    -- maintains, and a club typed by its exact name.
                    (SELECT NULLIF(c.logo_url, '')
                       FROM club_aliases ca
                       JOIN clubs c ON c.id = ca.club_id
                      WHERE fe.opponent IS NOT NULL
                        AND LOWER(BTRIM(ca.alias)) = LOWER(BTRIM(fe.opponent))
                      LIMIT 1),
                    (SELECT NULLIF(c.logo_url, '') FROM clubs c
                      WHERE fe.opponent IS NOT NULL
                        AND LOWER(BTRIM(c.name)) = LOWER(BTRIM(fe.opponent))
                        AND c.logo_id IS NOT NULL
                      LIMIT 1),
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
                (EXISTS (
                    SELECT 1 FROM opponent_logo_cache olc
                     WHERE fe.opponent IS NOT NULL
                       AND LOWER(BTRIM(olc.opponent_text)) = LOWER(BTRIM(fe.opponent))
                ) OR EXISTS (
                    SELECT 1 FROM club_aliases ca
                     WHERE fe.opponent IS NOT NULL
                       AND LOWER(BTRIM(ca.alias)) = LOWER(BTRIM(fe.opponent))
                )) AS opponent_logo_checked,
                fe.fh_notes,
                -- Tag, else the league default the classifier filled in
                -- (migration 395) — so the card never needs the raw tags.
                to_char(fe.arrival_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS arrival_label,
                to_char(fe.arrival_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS arrival_at_iso,
                to_char(fe.warmup_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS warmup_label,
                to_char(fe.kickoff_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS kickoff_label,
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
                -- Derived from the release rule (migration 335): opening a
                -- week early opens its practice RSVPs too.
                CASE
                    WHEN fh_event_rsvps_open_at(fe.id) IS NULL THEN NULL
                    ELSE to_char(fh_event_rsvps_open_at(fe.id) AT TIME ZONE 'UTC',
                                 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                END AS rsvps_open_at,
                (fh_event_rsvps_open_at(fe.id) IS NULL
                 OR fh_event_rsvps_open_at(fe.id) <= now()) AS rsvps_open_now,
                mr.response    AS my_rsvp,
                mr.created_via AS my_rsvp_created_via,
                -- Late / leaving early (migration 436): NULL = on time.
                to_char(mr.arrive_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS my_arrive_at,
                to_char(mr.leave_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS my_leave_at,
                to_char(mr.arrive_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS my_arrive_label,
                to_char(mr.leave_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS my_leave_label,
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
                    -- Club pass call-ups (migration 329) deliberately do NOT
                    -- grant visibility here (owner, 2026-09-12): a parent
                    -- seeing the older team's game on their kid's page
                    -- could not tell it from the kid's own game. An
                    -- explicit invite (fh_event_invites, migration 355)
                    -- is the only way in for a call-up or play-down.
                    OR fh_event_invited(fe.id, $1::int)
                ) AS eligible,
                -- `eligible` without the admin pass: the caller is on this
                -- event themselves (rostered player, its coach, or invited).
                -- #my shows only these (+ guardian events) so an admin's My
                -- page is their own week, not the whole club's (owner
                -- 2026-09-17: "my page for coaches and admin should be for
                -- them and not an admin type view").
                (
                    EXISTS (
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
                    OR fh_event_invited(fe.id, $1::int)
                    -- Club staff (migration 430, owner 2026-09-25): full-
                    -- time staff see every team's events on their own
                    -- page without a coach row per team.  Admin level is
                    -- still deliberately NOT a pass here.
                    OR fh_event_staff(fe.id, $1::int)
                ) AS is_mine,
                -- Which hat the viewer wears on THIS event (migration 438,
                -- owner 2026-09-25: dual-role people need "COACH" /
                -- "PLAYER" on each card; staff see "STAFF" on teams they
                -- neither coach nor play for).  Coaching a tagged team
                -- beats playing on one; an invite beats staff.  NULL for a
                -- guardian-only card — the child's row says who.
                CASE
                    WHEN EXISTS (
                        SELECT 1 FROM fh_event_teams fet
                        JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                        JOIN coaches co ON co.id = tc.coach_id
                        WHERE fet.fh_event_id = fe.id AND co.person_id = $1::int
                    ) THEN 'coach'
                    WHEN EXISTS (
                        SELECT 1 FROM fh_event_teams fet
                        JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                        WHERE fet.fh_event_id = fe.id AND tp.person_id = $1::int
                    ) THEN 'player'
                    WHEN fh_event_invited(fe.id, $1::int) THEN 'invited'
                    WHEN fh_event_staff(fe.id, $1::int) THEN 'staff'
                END AS my_role,
                -- Guardian visibility (2026-08-28).  A parent of a
                -- rostered child holds no team_persons row of their own,
                -- so `eligible` is false for them and every one of their
                -- kid's practices was filtered out of their calendar.
                --
                -- Deliberately a SEPARATE column rather than another OR
                -- inside `eligible`: that flag also gates the caller's
                -- OWN Go/No row, which is keyed on the caller's
                -- person_id in fh_event_rsvps. A guardian's RSVP for
                -- their kid is submitted as a distinct call naming the
                -- child (see `guardian_targets` below and
                -- CalendarController::resolveRsvpTarget), which writes
                -- the row under the CHILD's person_id — never the
                -- parent's — so the parent never shows up on the
                -- who's-going list as a player themselves.
                -- Which of the caller's children are on this event's
                -- roster.  NULL (string_agg over no rows) means none,
                -- which is exactly the is_guardian test — so this one
                -- subquery answers both questions and the outer SELECT
                -- derives the boolean from it.  Naming the children is
                -- not decoration: a parent with two players cannot
                -- otherwise tell whose practice a card refers to.
                (
                    SELECT string_agg(DISTINCT kids.n, ', ') FROM (
                        SELECT child.first_name || ' ' || child.last_name AS n
                        FROM fh_event_teams fet
                        JOIN team_persons tp ON tp.team_id = fet.team_id
                                            AND tp.removed_at IS NULL
                        JOIN persons child ON child.id = tp.person_id
                        WHERE fet.fh_event_id = fe.id
                          AND child.parent_person_id = $1::int
                        UNION
                        -- Invited kids (fh_event_invites, migration 355):
                        -- a call-up the coach explicitly invited. Age-
                        -- eligibility alone stopped counting 2026-09-12.
                        SELECT child.first_name || ' ' || child.last_name
                        FROM fh_event_invites i
                        JOIN persons child ON child.id = i.person_id
                        WHERE i.fh_event_id = fe.id AND i.revoked_at IS NULL
                          AND child.parent_person_id = $1::int
                    ) kids
                ) AS guardian_children,
                -- Just the invited subset, for the "why can I see this" line.
                (
                    SELECT string_agg(DISTINCT child.first_name || ' ' || child.last_name, ', ')
                    FROM fh_event_invites i
                    JOIN persons child ON child.id = i.person_id
                    WHERE i.fh_event_id = fe.id AND i.revoked_at IS NULL
                      AND child.parent_person_id = $1::int
                ) AS invited_children,
                -- Structured sibling of guardian_children above, used to
                -- actually drive the guardian's Go/No buttons (one row
                -- per child). Excludes a suspended child the same way
                -- `eligible` excludes a suspended caller — otherwise the
                -- button would render enabled and then 403 on submit.
                COALESCE((
                    SELECT jsonb_agg(x ORDER BY x->>'name')
                    FROM (
                        SELECT DISTINCT jsonb_build_object(
                                   'person_id', child.id,
                                   'name', child.first_name || ' ' || child.last_name,
                                   'callup', false
                               ) AS x
                        FROM fh_event_teams fet
                        JOIN team_persons tp ON tp.team_id = fet.team_id
                                            AND tp.removed_at IS NULL
                        JOIN persons child ON child.id = tp.person_id
                        WHERE fet.fh_event_id = fe.id
                          AND child.parent_person_id = $1::int
                          AND NOT EXISTS (
                              SELECT 1 FROM rsvp_suspensions s
                              WHERE s.person_id = tp.person_id
                                AND (s.team_id IS NULL OR s.team_id = tp.team_id)
                                AND s.starts_at <= now()
                                AND (s.ends_at IS NULL OR s.ends_at > now())
                          )
                        UNION
                        -- Invited kids (migration 355). Flagged so the card
                        -- says "invited to play up" instead of treating it
                        -- as the kid's own game.
                        SELECT jsonb_build_object(
                                   'person_id',   child.id,
                                   'name',        child.first_name || ' ' || child.last_name,
                                   'callup',      true,
                                   'callup_from', ft.name
                               )
                        FROM fh_event_invites i
                        JOIN persons child ON child.id = i.person_id
                        LEFT JOIN teams ft ON ft.id = i.from_team_id
                        WHERE i.fh_event_id = fe.id AND i.revoked_at IS NULL
                          AND child.parent_person_id = $1::int
                    ) sub
                ), '[]'::jsonb) AS guardian_targets,
                -- Pickup side / practice group (match_lineups.squad_color,
                -- set on #event-center) for the caller and their children
                -- — "which team am I on?".  Colour label + hex from
                -- squad_colors (migration 372).
                COALESCE((
                    SELECT jsonb_agg(jsonb_build_object(
                               'person_id', sp.id, 'code', sc.code,
                               'label', sc.label, 'hex', sc.hex))
                    FROM match_lineups ml
                    JOIN players spl     ON spl.id = ml.player_id
                    JOIN persons sp      ON sp.id = spl.person_id
                    JOIN squad_colors sc ON sc.code = ml.squad_color
                    WHERE ml.fh_event_id = fe.id
                      AND (sp.id = $1::int OR sp.parent_person_id = $1::int)
                ), '[]'::jsonb) AS my_sides,
                COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id',              t.id,
                            'name',            t.name,
                            'label',           t.label,
                            'short_label',     t.short_label,
                            'gender_category', t.gender_category,
                            'logo_url',        t.logo_url,
                            -- The squad this fixture is actually FOR.
                            -- Every mens game is tagged with both APSL
                            -- and Liga 1 (the other squad is RSVP-
                            -- eligible), so the tag list alone cannot
                            -- say which league game it is. A team is
                            -- primary when its own league's organization
                            -- is one of the event's leagues
                            -- (fh_event_leagues, migration 318):
                            -- teams -> divisions -> seasons -> leagues
                            -- -> organizations. Youth games are tagged
                            -- with exactly one team, which is primary
                            -- the same way (PPR). Practices carry no
                            -- league row, so nothing is primary there
                            -- and the card shows every tagged team.
                            'is_primary',      EXISTS (
                                SELECT 1
                                  FROM divisions     d
                                  JOIN seasons       s   ON s.id  = d.season_id
                                  JOIN leagues       l   ON l.id  = s.league_id
                                  JOIN fh_event_leagues fel
                                       ON fel.organization_id = l.organization_id
                                      AND fel.fh_event_id     = fe.id
                                 WHERE d.id = t.division_id
                            )
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
                                                        -- Late / leaving early (migration 436): NULL = on time.
                                                        'arrive_at',      to_char(roster.arrive_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
                                                        'leave_at',       to_char(roster.leave_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
                                                        'arrive_label',   to_char(roster.arrive_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
                                                        'leave_label',    to_char(roster.leave_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
                                                        'responded_at',   roster.responded_at,
                                                        'is_pickup_only', roster.is_pickup_only,
                                                        'is_coach',       roster.is_coach,
                                                        'is_callup',      roster.is_callup,
                                                        'callup_from',    roster.callup_from,
                                                        'phone',          roster.phone,
                                                        'email',          roster.email,
                                                        -- Youth: the guardian who signs in and RSVPs
                                                        -- (persons.parent_person_id). NULL for adults.
                                                        -- #my per-row reminders mint the magic link
                                                        -- for this id when present (auth model 2026-09-05).
                                                        'parent_person_id', roster.parent_person_id,
                                                        -- Under the dues line (migration 416)?  A yes from
                                                        -- someone over it is kept but counted apart
                                                        -- (owner 2026-09-23: "keep but don't count in
                                                        -- totals instead use sep total for ineligible").
                                                        'dues_eligible', fh_dues_eligible(roster.person_id)
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
                                                             combined.arrive_at,
                                                             combined.leave_at,
                                                             combined.responded_at,
                                                             combined.is_pickup_only,
                                                             combined.is_coach,
                                                             combined.is_callup,
                                                             combined.callup_from,
                                                             combined.phone,
                                                             combined.email,
                                                             combined.parent_person_id
                                                    FROM (
                                                        SELECT
                                                             p.id AS person_id,
                                                             p.first_name,
                                                             p.last_name,
                                                             NULLIF(TRIM(CONCAT_WS(' ', p.first_name, p.last_name)), '') AS name,
                                                             er.response,
                                                             er.created_via,
                                                             er.arrive_at,
                                                             er.leave_at,
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
                                                             false AS is_callup,
                                                             NULL::text AS callup_from,
                                                             -- Youth players usually have no contact rows of their
                                                             -- own (signup collected the parent's) — fall back to
                                                             -- the guardian's phone/email so reminders reach
                                                             -- someone, same pattern as PersonPayments.cpp/LeadsController.cpp.
                                                             COALESCE(
                                                               (SELECT phone_number FROM person_phones
                                                                 WHERE person_id = p.id AND can_receive_sms = true
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                               (SELECT phone_number FROM person_phones
                                                                 WHERE person_id = p.parent_person_id AND can_receive_sms = true
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1)
                                                             ) AS phone,
                                                             COALESCE(
                                                               (SELECT email FROM person_emails
                                                                 WHERE person_id = p.id
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                               (SELECT email FROM person_emails
                                                                 WHERE person_id = p.parent_person_id
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1)
                                                             ) AS email,
                                                             p.parent_person_id
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
                                                             er.arrive_at,
                                                             er.leave_at,
                                                             CASE
                                                                     WHEN er.responded_at IS NULL THEN NULL
                                                                     ELSE to_char(er.responded_at AT TIME ZONE 'UTC',
                                                                                                'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                                                             END,
                                                             false,
                                                             true,
                                                             false,
                                                             NULL::text,
                                                             (SELECT phone_number FROM person_phones
                                                               WHERE person_id = p.id AND can_receive_sms = true
                                                               ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                             (SELECT email FROM person_emails
                                                               WHERE person_id = p.id
                                                               ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                             p.parent_person_id
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

                                                        UNION ALL

                                                        -- Invited players (fh_event_invites,
                                                        -- migration 355): a youth call-up or a
                                                        -- men's play-down the coach explicitly
                                                        -- invited. Age-eligible call-ups alone
                                                        -- were dropped from this list 2026-09-12.
                                                        -- A 'yes' here means AVAILABLE, not
                                                        -- selected — the frontend words it so.
                                                        SELECT
                                                             p.id,
                                                             p.first_name,
                                                             p.last_name,
                                                             NULLIF(TRIM(CONCAT_WS(' ', p.first_name, p.last_name)), ''),
                                                             er.response,
                                                             er.created_via,
                                                             er.arrive_at,
                                                             er.leave_at,
                                                             CASE
                                                                     WHEN er.responded_at IS NULL THEN NULL
                                                                     ELSE to_char(er.responded_at AT TIME ZONE 'UTC',
                                                                                                'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                                                             END,
                                                             false,
                                                             false,
                                                             true,
                                                             ft.name::text,
                                                             COALESCE(
                                                               (SELECT phone_number FROM person_phones
                                                                 WHERE person_id = p.id AND can_receive_sms = true
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                               (SELECT phone_number FROM person_phones
                                                                 WHERE person_id = p.parent_person_id AND can_receive_sms = true
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1)
                                                             ),
                                                             COALESCE(
                                                               (SELECT email FROM person_emails
                                                                 WHERE person_id = p.id
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1),
                                                               (SELECT email FROM person_emails
                                                                 WHERE person_id = p.parent_person_id
                                                                 ORDER BY is_primary DESC, id ASC LIMIT 1)
                                                             ),
                                                             p.parent_person_id
                                                        FROM fh_event_invites i
                                                        JOIN persons p ON p.id = i.person_id
                                                        LEFT JOIN teams ft ON ft.id = i.from_team_id
                                                        LEFT JOIN fh_event_rsvps er
                                                            ON er.fh_event_id = fe.id
                                                         AND er.person_id   = p.id
                                                       WHERE i.fh_event_id = fe.id
                                                         AND i.revoked_at IS NULL
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
                        OR fh_event_invited(fe.id, $1::int)
                    )
                END AS my_rsvp_eligible,
                -- Schedule release window (migration 334): when the
                -- shown week ends for this event's club/section, derived
                -- server-side from the standing policy + early releases.
                -- My Schedule hides events past it. NULL when untagged.
                (
                    SELECT to_char(fh_schedule_window_end(t.club_id, t.club_section_id, now()) AT TIME ZONE 'UTC',
                                   'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
                    FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
                    WHERE fet.fh_event_id = fe.id
                    ORDER BY fet.team_id LIMIT 1
                ) AS schedule_window_end,
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
              AND ($5::bigint = 0 OR fe.id = $5::bigint)
              AND ge.starts_at >= CASE
                  WHEN $5::bigint > 0 THEN '-infinity'::timestamptz
                  WHEN $4 = '' THEN ((now() AT TIME ZONE 'America/New_York')::date) AT TIME ZONE 'America/New_York'
                  ELSE $4::timestamptz
                END
              AND ge.starts_at < CASE
                  WHEN $5::bigint > 0 THEN 'infinity'::timestamptz
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
            std::to_string(onlyFhEventId),
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
            ev["arrival_label"]     = textOrNull(row, "arrival_label");
            ev["arrival_at"]        = textOrNull(row, "arrival_at_iso");
            ev["warmup_label"]      = textOrNull(row, "warmup_label");
            ev["kickoff_label"]     = textOrNull(row, "kickoff_label");
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
            ev["my_arrive_at"]      = textOrNull(row, "my_arrive_at");
            ev["my_leave_at"]       = textOrNull(row, "my_leave_at");
            ev["my_arrive_label"]   = textOrNull(row, "my_arrive_label");
            ev["my_leave_label"]    = textOrNull(row, "my_leave_label");
            ev["my_rsvp_eligible"]  = boolOrNull(row, "my_rsvp_eligible");
            ev["is_mine"]           = row["is_mine"].as<bool>();
            ev["my_role"]           = textOrNull(row, "my_role");
            ev["is_guardian"]       = row["is_guardian"].as<bool>();
            ev["guardian_children"] = textOrNull(row, "guardian_children");
            ev["schedule_window_end"] = textOrNull(row, "schedule_window_end");
            ev["guardian_targets"]  = json::parse(row["guardian_targets"].c_str());
            ev["my_sides"]          = json::parse(row["my_sides"].c_str());
            {
                const bool eligible = row["eligible"].as<bool>();
                const bool guardian = row["is_guardian"].as<bool>();
                const int teamCount = row["team_count"].as<int>();
                if (row["my_rsvp_eligible"].is_null()) {
                    ev["my_rsvp_eligibility_reason"] = nullptr;
                } else if (!eligible) {
                    if (guardian) {
                        // The caller has no RSVP row of their own here,
                        // but the frontend renders a working Go/No row
                        // per guardian_targets entry right on this card
                        // — this reason string only explains why the
                        // caller's OWN row is absent, not that RSVPing
                        // is impossible.
                        const std::string kids = row["guardian_children"].is_null()
                            ? std::string("your player")
                            : row["guardian_children"].as<std::string>();
                        const bool onlyInvited = !row["invited_children"].is_null()
                            && row["invited_children"].as<std::string>() == kids;
                        ev["my_rsvp_eligibility_reason"] = onlyInvited
                            ? "You can see this because " + kids + " was invited to play in this game."
                            : "You can see this because " + kids + " is on the roster.";
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
            // The who's-coming list carries names, phones and emails — it is
            // for signed-in members only.  This endpoint also answers with
            // no login (the public schedule pages), and until 2026-09-18 it
            // handed the full list to anyone who asked.
            ev["rsvps"] = json::array();
            if (personId > 0) {
                try {
                    ev["rsvps"] = json::parse(row["rsvps_json"].c_str());
                    // Other people's phone / email ride along for the
                    // bulk Text All / Email Going buttons, which are for
                    // club admins only (owner 2026-09-25: "they should
                    // not have option to email and text everyone").
                    // Everyone else gets names and answers, nothing to dial.
                    if (!viewerIsAdmin && ev["rsvps"].is_array()) {
                        for (auto& r : ev["rsvps"]) { r.erase("phone"); r.erase("email"); }
                    }
                } catch (...) {}
            }
            events.push_back(std::move(ev));
        }

        // FH-only season fixtures (team_schedule_fixtures, mig 362) for the
        // view-only "My schedule ahead" list on #schedules.  Members only,
        // scoped like events: own team, a child's team, a coached team, or
        // admin.  A fixture drops out once that team has a calendar game
        // on the same local day — gcal stays the truth for anything with
        // an RSVP, this is just the look-ahead.  #my ignores the field.
        if (onlyFhEventId > 0) {
            if (events.empty()) {
                return jsonError(HttpStatus::NOT_FOUND, "fh_event not found");
            }
            return jsonOk(json{{"event", events[0]}});
        }

        json fixtures = json::array();
        if (personId > 0) {
            pqxx::result fx = db->query(R"SQL(
                SELECT f.id, f.team_id, t.name AS team_name, t.label AS team_label,
                       to_char(f.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at,
                       to_char(f.ends_at   AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS ends_at,
                       f.opponent, f.is_home, f.location
                  FROM team_schedule_fixtures f
                  JOIN teams t ON t.id = f.team_id
                 WHERE COALESCE(f.ends_at, f.starts_at) > now()
                   AND f.starts_at < now() + ($2::int * INTERVAL '1 day')
                   AND (
                        EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id
                                 WHERE u.person_id = $1::int)
                     OR EXISTS (SELECT 1 FROM team_persons tp
                                  LEFT JOIN persons child ON child.id = tp.person_id
                                 WHERE tp.team_id = f.team_id AND tp.removed_at IS NULL
                                   AND (tp.person_id = $1::int OR child.parent_person_id = $1::int))
                     OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
                                 WHERE tc.team_id = f.team_id AND tc.ended_at IS NULL
                                   AND co.person_id = $1::int)
                   )
                   AND NOT EXISTS (
                        SELECT 1 FROM fh_events fe
                          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                          JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
                         WHERE fet.team_id = f.team_id
                           AND fe.kind = 'match'
                           AND ge.deleted_at IS NULL
                           AND COALESCE(ge.status, '') <> 'cancelled'
                           AND (ge.starts_at AT TIME ZONE 'America/New_York')::date
                             = (f.starts_at  AT TIME ZONE 'America/New_York')::date
                   )
                 ORDER BY f.starts_at
            )SQL", { std::to_string(personId), std::to_string(days) });
            for (const auto& r : fx) {
                json f = {
                    {"id",        r["id"].as<int>()},
                    {"starts_at", r["starts_at"].c_str()},
                    {"ends_at",   r["ends_at"].is_null() ? json(nullptr) : json(r["ends_at"].c_str())},
                    {"opponent",  r["opponent"].c_str()},
                    {"is_home",   r["is_home"].is_null() ? json(nullptr) : json(r["is_home"].as<bool>())},
                    {"location",  r["location"].is_null() ? json(nullptr) : json(r["location"].c_str())},
                    {"team", {
                        {"id",    r["team_id"].as<int>()},
                        {"name",  r["team_name"].c_str()},
                        {"label", r["team_label"].is_null() ? json(nullptr) : json(r["team_label"].c_str())},
                    }},
                };
                fixtures.push_back(std::move(f));
            }
        }

        // Dues eligibility (migration 416) for the caller and each child
        // on their page, keyed by person id: #my says who is not eligible
        // for games and practices, the balance, the least payment that
        // gets them back under the line, and where to pay.
        json dues = json::object();
        if (personId > 0) {
            try {
                pqxx::result dr = db->query(R"SQL(
                    SELECT p.id, COALESCE(p.first_name, '') AS first_name,
                           fh_dues_balance_usd(p.id)               AS balance,
                           fh_dues_line_usd($2::int)               AS line,
                           fh_dues_eligible(p.id, $2::int)         AS eligible,
                           fh_dues_min_payment_usd(p.id, $2::int)  AS min_payment,
                           fh_fill_form_links('{form:la_dashboard}', $2::int) AS pay_url
                      FROM persons p
                     WHERE p.id = $1::int OR p.parent_person_id = $1::int
                )SQL", {std::to_string(personId), std::to_string(WelcomeLog::kLighthouseClubId)});
                for (const auto& r : dr) {
                    dues[std::string(r["id"].c_str())] = {
                        {"is_self",     r["id"].as<long long>() == personId},
                        {"first_name",  r["first_name"].c_str()},
                        {"balance",     r["balance"].is_null()     ? 0.0 : r["balance"].as<double>()},
                        {"line",        r["line"].is_null()        ? json(nullptr) : json(r["line"].as<double>())},
                        {"eligible",    r["eligible"].is_null()    ? true : r["eligible"].as<bool>()},
                        {"min_payment", r["min_payment"].is_null() ? 0.0 : r["min_payment"].as<double>()},
                        {"pay_url",     r["pay_url"].is_null()     ? "" : r["pay_url"].c_str()},
                    };
                }
            } catch (const std::exception& e) {
                std::cerr << "[calendar/upcoming] dues lookup failed: " << e.what() << std::endl;
            }
        }

        json viewer = nullptr;
        if (personId > 0) {
            auto vp = db->query("SELECT first_name, last_name FROM persons WHERE id = $1::int", {std::to_string(personId)});
            if (!vp.empty()) {
                viewer = {{"person_id", personId},
                          {"first_name", textOrNull(vp[0], "first_name")},
                          {"last_name",  textOrNull(vp[0], "last_name")}};
            }
        }
        json body = {
            {"days",   days},
            {"count",  events.size()},
            {"events", std::move(events)},
            {"dues",   std::move(dues)},
            // Lets a screen that works signed-out too (#schedules) tell a
            // member's team-scoped list from the anonymous unfiltered one.
            {"signed_in", personId > 0},
            {"fixtures", std::move(fixtures)},
            // Who the page is for (after view-as), so a parent who also
            // plays sees "James (you)" and "Grace" as separate rows.
            {"viewer", viewer},
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

    // Nothing anywhere for a brand-new opponent: queue the one-time web
    // search (migration 432).  ClubLogoSearchScheduler does the rest and
    // the crest appears on the next load once it is stored.
    if (logoUrl.empty()) {
        try { ClubLogoSearch().enqueue(opponentText, 0, false); }
        catch (const std::exception& e) {
            std::cerr << "CalendarController: could not queue logo search for " << opponentText
                      << ": " << e.what() << std::endl;
        }
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

    // Optional: a guardian answering on behalf of their own rostered
    // child rather than themselves (see resolveRsvpTarget). Omitted ->
    // caller RSVPs for themselves, same as before this existed.
    std::optional<long long> requestedPersonId;
    if (auto p = jsonInt(body, "person_id"); p && *p > 0) requestedPersonId = *p;

    try {
        auto* db = Database::getInstance();

        // Existence + liveness check.  We look at the fh_events row
        // AND its gcal_events parent — a tombstoned gcal event must
        // not accept new RSVPs even if the fh_events row survives
        // (per §1.1's "no orphan FH data" corollary this is a bug
        // state, but we're defensive here in case the applier races
        // the sync worker).
        if (auto err = checkRsvpWindowOpen(db, fhEventId)) return *err;

        // For this rollout, the My page is the source of truth for
        // whether the caller should be able to RSVP.  If the event is
        // present in the upcoming payload for that caller, the write
        // path accepts the manual RSVP instead of rejecting it on a
        // separate stale roster gate.
        long long targetPersonId = 0;
        if (auto err = resolveRsvpTarget(db, personId, requestedPersonId, fhEventId, &targetPersonId)) {
            return *err;
        }

        // Dues eligibility (migration 416): at or over the line a member
        // is not eligible for games and practices, so a yes/maybe is
        // refused with the least payment that gets them back under it
        // (message_templates my_dues/rsvp_refused).  A no still goes
        // through so the coach's count stays right.
        if (response != "no") {
            auto dq = db->query(
                "SELECT fh_dues_eligible($2::int, $3::int)         AS ok, "
                "       fh_dues_min_payment_usd($2::int, $3::int)  AS min_payment, "
                "       (SELECT kind FROM fh_events WHERE id = $1::bigint) AS kind",
                {std::to_string(fhEventId), std::to_string(targetPersonId),
                 std::to_string(WelcomeLog::kLighthouseClubId)});
            if (!dq.empty() && !dq[0]["ok"].is_null() && !dq[0]["ok"].as<bool>()) {
                const std::string kind = dq[0]["kind"].is_null() ? "" : dq[0]["kind"].c_str();
                if (kind == "match" || kind == "practice") {
                    char amount[32];
                    std::snprintf(amount, sizeof amount, "$%.2f",
                                  dq[0]["min_payment"].is_null() ? 0.0 : dq[0]["min_payment"].as<double>());
                    MessageCopy copy;
                    const auto msg = copy.render("my_dues", "rsvp_refused", {{"min_payment", amount}});
                    return jsonError(HttpStatus::FORBIDDEN,
                                     msg.ok() ? msg.body : std::string("Not eligible for games and practices."));
                }
            }
        }

        // Upsert.  ON CONFLICT overwrites response, responded_at, and
        // created_via — the manual click always beats an earlier
        // standing/admin insert.
        // Late / leaving early (migration 436).  A key present in the
        // body sets that time (ISO, or null/"" = back to on time); a key
        // absent leaves it as it was, so a plain Go tap never wipes an
        // edited time.  A No clears both — they do not apply.
        auto isoOrEmpty = [&](const char* key) -> std::string {
            if (!body.contains(key) || body[key].is_null()) return "";
            return body[key].is_string() ? body[key].get<std::string>() : "";
        };
        const bool setArrive = response == "no" || body.contains("arrive_at");
        const bool setLeave  = response == "no" || body.contains("leave_at");
        const std::string arriveIso = response == "no" ? "" : isoOrEmpty("arrive_at");
        const std::string leaveIso  = response == "no" ? "" : isoOrEmpty("leave_at");
        auto row = db->query(
            "INSERT INTO fh_event_rsvps "
            "    (fh_event_id, person_id, response, responded_at, created_via, arrive_at, leave_at) "
            "VALUES ($1::bigint, $2::int, $3, now(), 'manual', "
            "        NULLIF($4, '')::timestamptz, NULLIF($5, '')::timestamptz) "
            "ON CONFLICT (fh_event_id, person_id) DO UPDATE "
            "   SET response     = EXCLUDED.response, "
            "       responded_at = EXCLUDED.responded_at, "
            "       created_via  = EXCLUDED.created_via, "
            "       arrive_at    = CASE WHEN $6::boolean THEN EXCLUDED.arrive_at ELSE fh_event_rsvps.arrive_at END, "
            "       leave_at     = CASE WHEN $7::boolean THEN EXCLUDED.leave_at  ELSE fh_event_rsvps.leave_at  END "
            "RETURNING id, fh_event_id, person_id, response, created_via, "
            "          to_char(responded_at AT TIME ZONE 'UTC', "
            "                  'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS responded_at, "
            "          to_char(arrive_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS arrive_at, "
            "          to_char(leave_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS leave_at, "
            "          to_char(arrive_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS arrive_label, "
            "          to_char(leave_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS leave_label",
            {std::to_string(fhEventId),
             std::to_string(targetPersonId),
             response,
             arriveIso, leaveIso,
             setArrive ? "true" : "false", setLeave ? "true" : "false"});

        if (row.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "RSVP write returned no row");
        }
        // Standby is opt-out (mig 385 tells the alternate so): Not Going
        // takes the player off the game's alternates.  Starters and bench
        // stay — a coach has to fill that spot, so they see it first.
        // Going again later does not put them back; that is the coach's call.
        json standby = nullptr;
        if (response == "no") {
            auto dropped = db->query(
                "DELETE FROM match_lineups ml "
                " USING fh_events fe, players pl "
                " WHERE fe.id = $1::bigint AND ml.match_id = fe.match_id "
                "   AND pl.id = ml.player_id AND pl.person_id = $2::int "
                "   AND ml.zone = 'alternate' "
                "RETURNING ml.player_id, "
                "          (SELECT COALESCE(p.first_name, '') FROM persons p WHERE p.id = pl.person_id) AS first_name",
                {std::to_string(fhEventId), std::to_string(targetPersonId)});
            if (!dropped.empty()) {
                const bool parent = targetPersonId != personId;
                MessageCopy copy;
                const auto msg = copy.render("squad_notice",
                    parent ? "standby_dropped_parent" : "standby_dropped_adult",
                    {{"child", dropped[0]["first_name"].c_str()}});
                standby = {{"player_id", dropped[0]["player_id"].as<long long>()},
                           {"message", msg.body}};
            }
        }

        const auto& r0 = row[0];
        json rsvp = {
            {"id",            r0["id"].as<long long>()},
            {"fh_event_id",   r0["fh_event_id"].as<long long>()},
            {"person_id",     r0["person_id"].as<long long>()},
            {"response",      r0["response"].as<std::string>()},
            {"created_via",   r0["created_via"].as<std::string>()},
            {"responded_at",  r0["responded_at"].as<std::string>()},
            {"arrive_at",     textOrNull(r0, "arrive_at")},
            {"leave_at",      textOrNull(r0, "leave_at")},
            {"arrive_label",  textOrNull(r0, "arrive_label")},
            {"leave_label",   textOrNull(r0, "leave_label")},
        };
        return jsonOk({{"rsvp", rsvp}, {"standby_dropped", standby}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handlePostRsvp: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handleDeleteRsvp(const Request& request) {
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

    // Same optional guardian target as the POST — clearing your kid's
    // RSVP goes through the same ownership check as setting one.
    std::optional<long long> requestedPersonId;
    if (auto p = jsonInt(body, "person_id"); p && *p > 0) requestedPersonId = *p;

    try {
        auto* db = Database::getInstance();
        if (auto err = checkRsvpWindowOpen(db, fhEventId)) return *err;

        long long targetPersonId = 0;
        if (auto err = resolveRsvpTarget(db, personId, requestedPersonId, fhEventId, &targetPersonId)) {
            return *err;
        }

        auto row = db->query(
            "DELETE FROM fh_event_rsvps "
            " WHERE fh_event_id = $1::bigint AND person_id = $2::int "
            "RETURNING id",
            {std::to_string(fhEventId), std::to_string(targetPersonId)});

        if (row.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "no RSVP to clear");
        }
        return jsonOk({{"cleared", true}, {"person_id", targetPersonId}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleDeleteRsvp: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handleGetEventAttendance(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    // View-as (?asPersonId): can_mark and the roster answer for the person
    // being viewed, so an admin looking at a player's #my sees the
    // player's page — no staff door (owner 2026-09-25).  Reads only; the
    // POST beside this never impersonates.
    long long personId = gate.personId;
    if (auto err = applyImpersonation(request, personId, &personId)) return *err;

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
            "        UNION ALL "
            // Invited call-ups / play-downs (migration 355) show up for check-in too.
            "        SELECT p.id, p.first_name, p.last_name, false "
            "          FROM fh_event_invites i "
            "          JOIN persons p ON p.id = i.person_id "
            "         WHERE i.fh_event_id = $1::bigint AND i.revoked_at IS NULL "
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
            "  UNION ALL "
            "  SELECT 1 WHERE fh_event_invited($1::bigint, $2::int) "
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

// ── Invites (fh_event_invites, migration 355) ────────────────────────
//
// A game is tagged with its own squad only. Anyone else who might play
// — a youth club-pass call-up (fh_event_callups) or a men's player from
// another squad in the section (APSL ⇄ Liga 1 ⇄ Reserves) — is let in
// one at a time by a coach or admin. The invite row is what grants
// visibility, the guardian Go/No row, the coach-list row, and the RSVP
// / attendance eligibility; the magic link is how the player hears.

namespace {

long long extractPersonIdFromInvitePath(const std::string& path) {
    const std::string marker = "/invites/";
    auto pos = path.find(marker);
    if (pos == std::string::npos) return 0;
    auto start = pos + marker.size();
    auto end = path.find_first_of("/?", start);
    const std::string seg = end == std::string::npos ? path.substr(start) : path.substr(start, end - start);
    try { return std::stoll(seg); } catch (...) { return 0; }
}

// Player-facing description of the game for the invite text: squad
// label + opponent + local time. Never the raw gcal title.
struct InviteEventInfo {
    std::string teamLabel;   // "U10 Travel" / "Liga 1"
    std::string opponent;
    std::string whenEt;      // "Sat Sep 19, 10:00 AM"
    std::string kind;
    std::string category;    // 'boys' | 'mens' | ...
};

std::optional<InviteEventInfo> loadInviteEventInfo(Database* db, long long fhEventId) {
    auto rows = db->query(
        "SELECT COALESCE(fe.opponent, '') AS opponent, fe.kind, COALESCE(fe.category, '') AS category, "
        "       to_char(COALESCE(fe.start_at, ge.starts_at) AT TIME ZONE 'America/New_York', "
        "               'Dy Mon FMDD, FMHH12:MI AM') AS when_et, "
        "       COALESCE((SELECT string_agg("
        "                   COALESCE(NULLIF(btrim(regexp_replace(t.label, '^[^[:alnum:]]+', '')), ''), t.name::text), "
        "                   ' / ' ORDER BY t.id) "
        "                   FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id "
        "                  WHERE fet.fh_event_id = fe.id), '') AS team_label "
        "  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
        " WHERE fe.id = $1::bigint",
        {std::to_string(fhEventId)});
    if (rows.empty()) return std::nullopt;
    InviteEventInfo info;
    info.opponent  = rows[0]["opponent"].c_str();
    info.kind      = rows[0]["kind"].c_str();
    info.category  = rows[0]["category"].c_str();
    info.whenEt    = rows[0]["when_et"].c_str();
    info.teamLabel = rows[0]["team_label"].c_str();
    return info;
}

} // namespace

// GET /calendar/events/:fhEventId/sides — who is on which bib colour for a
// pickup (sides) or a practice (groups).  Rows live in match_lineups keyed
// on fh_event_id (migration 316); the colours are squad_colors rows
// (migration 372).  Same people as the attendance roster — players, coaches
// (they play pickup too) and invited call-ups — each with their RSVP so the
// screen can lead with who is actually coming.
Response CalendarController::handleGetEventSides(const Request& request) {
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

        const bool canEdit = isEventCoachOrAdmin(db, personId, fhEventId);

        json colors = json::array();
        for (const auto& row : db->query(
                 "SELECT code, label, hex FROM squad_colors "
                 " WHERE is_active ORDER BY sort_order, code")) {
            colors.push_back({
                {"code",  row["code"].c_str()},
                {"label", row["label"].c_str()},
                {"hex",   row["hex"].c_str()},
            });
        }

        auto rows = db->query(R"SQL(
            SELECT roster.person_id, roster.first_name, roster.last_name,
                   rv.response AS rsvp, ml.squad_color
              FROM (
                SELECT DISTINCT ON (combined.person_id) combined.*
                  FROM (
                    SELECT p.id AS person_id, p.first_name, p.last_name
                      FROM fh_event_teams fet
                      JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                      JOIN persons p ON p.id = tp.person_id
                     WHERE fet.fh_event_id = $1::bigint
                    UNION ALL
                    SELECT p.id, p.first_name, p.last_name
                      FROM fh_event_teams fet
                      JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                      JOIN coaches co ON co.id = tc.coach_id
                      JOIN persons p ON p.id = co.person_id
                     WHERE fet.fh_event_id = $1::bigint
                    UNION ALL
                    SELECT p.id, p.first_name, p.last_name
                      FROM fh_event_invites i
                      JOIN persons p ON p.id = i.person_id
                     WHERE i.fh_event_id = $1::bigint AND i.revoked_at IS NULL
                  ) combined
                 ORDER BY combined.person_id
              ) roster
              LEFT JOIN fh_event_rsvps rv
                     ON rv.fh_event_id = $1::bigint AND rv.person_id = roster.person_id
              LEFT JOIN players pl ON pl.person_id = roster.person_id
              LEFT JOIN match_lineups ml
                     ON ml.fh_event_id = $1::bigint AND ml.player_id = pl.id
             ORDER BY roster.last_name, roster.first_name, roster.person_id)SQL",
            {std::to_string(fhEventId)});

        json players = json::array();
        for (const auto& row : rows) {
            players.push_back({
                {"person_id",   row["person_id"].as<long long>()},
                {"first_name",  textOrNull(row, "first_name")},
                {"last_name",   textOrNull(row, "last_name")},
                {"rsvp",        textOrNull(row, "rsvp")},
                {"squad_color", textOrNull(row, "squad_color")},
            });
        }
        return jsonOk({{"fh_event_id", fhEventId}, {"can_edit", canEdit},
                       {"colors", colors}, {"players", players}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetEventSides: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /calendar/events/:fhEventId/sides  { person_id, squad_color | null }
// Puts one person on a colour, or takes them off (null).  Coach of the
// event's team(s) or admin only.
Response CalendarController::handlePostEventSide(const Request& request) {
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
    const std::string color = toLower(jsonStr(body, "squad_color"));

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
                             "can set sides.");
        }

        if (color.empty()) {
            // Off every side.  A game's lineup row (match_id set) keeps its
            // squad/starter meaning and only loses the colour; an
            // event-only row has no other meaning and goes.
            db->query(
                "UPDATE match_lineups ml SET squad_color = NULL "
                "  FROM players pl "
                " WHERE pl.person_id = $2::int AND ml.player_id = pl.id "
                "   AND ml.fh_event_id = $1::bigint",
                {std::to_string(fhEventId), std::to_string(targetPersonId)});
            db->query(
                "DELETE FROM match_lineups ml USING players pl "
                " WHERE pl.person_id = $2::int AND ml.player_id = pl.id "
                "   AND ml.fh_event_id = $1::bigint "
                "   AND ml.match_id IS NULL AND ml.squad_color IS NULL",
                {std::to_string(fhEventId), std::to_string(targetPersonId)});
            return jsonOk({{"fh_event_id", fhEventId}, {"person_id", targetPersonId},
                           {"squad_color", nullptr}});
        }

        auto colorRows = db->query(
            "SELECT 1 FROM squad_colors WHERE code = $1 AND is_active", {color});
        if (colorRows.empty()) {
            return jsonError(HttpStatus::BAD_REQUEST, "unknown squad_color");
        }

        // Same roster rule as attendance; the team the row hangs off is the
        // person's own among the event's teams, else the event's first.
        auto teamRows = db->query(R"SQL(
            SELECT COALESCE(
                     (SELECT fet.team_id FROM fh_event_teams fet
                        JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                       WHERE fet.fh_event_id = $1::bigint AND tp.person_id = $2::int
                       ORDER BY fet.team_id LIMIT 1),
                     (SELECT fet.team_id FROM fh_event_teams fet
                       WHERE fet.fh_event_id = $1::bigint
                         AND ( EXISTS (SELECT 1 FROM team_coaches tc
                                         JOIN coaches co ON co.id = tc.coach_id
                                        WHERE tc.team_id = fet.team_id AND tc.ended_at IS NULL
                                          AND co.person_id = $2::int)
                               OR fh_event_invited($1::bigint, $2::int) )
                       ORDER BY fet.team_id LIMIT 1)
                   ) AS team_id)SQL",
            {std::to_string(fhEventId), std::to_string(targetPersonId)});
        if (teamRows.empty() || teamRows[0]["team_id"].is_null()) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "person is not on the roster/staff for this event");
        }
        const std::string teamId = std::to_string(teamRows[0]["team_id"].as<long long>());

        // match_lineups hangs off players; a coach or a new call-up may not
        // have that row yet.
        db->query(
            "INSERT INTO players (person_id) VALUES ($1::int) "
            "ON CONFLICT (person_id) DO NOTHING",
            {std::to_string(targetPersonId)});

        db->query(R"SQL(
            INSERT INTO match_lineups (fh_event_id, match_id, player_id, team_id, is_starter, squad_color)
            SELECT $1::bigint, fe.match_id, pl.id, $3::int, false, $4
              FROM fh_events fe, players pl
             WHERE fe.id = $1::bigint AND pl.person_id = $2::int
            ON CONFLICT (fh_event_id, player_id) WHERE fh_event_id IS NOT NULL
            DO UPDATE SET squad_color = EXCLUDED.squad_color)SQL",
            {std::to_string(fhEventId), std::to_string(targetPersonId), teamId, color});

        return jsonOk({{"fh_event_id", fhEventId}, {"person_id", targetPersonId},
                       {"squad_color", color}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handlePostEventSide: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /calendar/events/:fhEventId/session-plan — the practice plan attached
// to this event (club_game_model_practices.fh_event_id → sessions →
// session_exercises → exercises), read-only.  It is edited on
// #practice-plan; `practice` is null when the event has no plan.
Response CalendarController::handleGetEventSessionPlan(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;

    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");
    }

    auto* db = Database::getInstance();
    try {
        auto rows = db->query(R"SQL(
            SELECT jsonb_build_object(
                     'id', pr.id,
                     'notes', pr.notes,
                     'sessions', COALESCE((
                        SELECT jsonb_agg(jsonb_build_object(
                                 'id', s.id, 'title', s.title, 'notes', s.notes,
                                 'start_time', to_char(s.start_time, 'FMHH12:MI AM'),
                                 'end_time',   to_char(s.end_time,   'FMHH12:MI AM'),
                                 'exercises', COALESCE((
                                    SELECT jsonb_agg(jsonb_build_object(
                                             'title', ex.title,
                                             'description', ex.description,
                                             'setup', ex.setup,
                                             'coaching_points', ex.coaching_points,
                                             'player_count', se.player_count,
                                             'notes', se.notes)
                                           ORDER BY se.sequence_order, se.id)
                                      FROM club_game_model_session_exercises se
                                      JOIN club_game_model_exercises ex ON ex.id = se.exercise_id
                                     WHERE se.session_id = s.id), '[]'::jsonb))
                               ORDER BY s.sort_order, s.start_time, s.id)
                          FROM club_game_model_sessions s
                         WHERE s.practice_id = pr.id), '[]'::jsonb)
                   )::text AS practice
              FROM club_game_model_practices pr
             WHERE pr.fh_event_id = $1::bigint
             ORDER BY pr.id DESC LIMIT 1)SQL",
            {std::to_string(fhEventId)});

        json practice = nullptr;
        if (!rows.empty()) practice = json::parse(rows[0]["practice"].c_str());
        return jsonOk({{"fh_event_id", fhEventId}, {"practice", practice}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetEventSessionPlan: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handleGetEventInvites(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId  = gate.personId;
    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");

    try {
        auto* db = Database::getInstance();
        const bool canInvite = isEventCoachOrAdmin(db, personId, fhEventId);
        if (!canInvite) {
            return jsonError(HttpStatus::FORBIDDEN, "Only coaches and admins can invite players");
        }

        json invites = json::array();
        for (const auto& row : db->query(
                "SELECT i.person_id, p.first_name, p.last_name, ft.name AS from_team, "
                "       i.channel, i.contact, er.response, p.parent_person_id, "
                "       to_char(i.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at "
                "  FROM fh_event_invites i "
                "  JOIN persons p ON p.id = i.person_id "
                "  LEFT JOIN teams ft ON ft.id = i.from_team_id "
                "  LEFT JOIN fh_event_rsvps er ON er.fh_event_id = i.fh_event_id AND er.person_id = i.person_id "
                " WHERE i.fh_event_id = $1::bigint AND i.revoked_at IS NULL "
                " ORDER BY p.last_name, p.first_name, p.id",
                {std::to_string(fhEventId)})) {
            invites.push_back({
                {"person_id",        row["person_id"].as<long long>()},
                {"first_name",       textOrNull(row, "first_name")},
                {"last_name",        textOrNull(row, "last_name")},
                {"from_team",        textOrNull(row, "from_team")},
                {"channel",          textOrNull(row, "channel")},
                {"contact",          textOrNull(row, "contact")},
                {"response",         textOrNull(row, "response")},
                {"parent_person_id", row["parent_person_id"].is_null() ? json(nullptr) : json(row["parent_person_id"].as<long long>())},
                {"created_at",       textOrNull(row, "created_at")},
            });
        }

        json candidates = json::array();
        for (const auto& row : db->query(
                "SELECT c.person_id, p.first_name, p.last_name, c.from_team_id, c.from_team_name, "
                "       c.single_age, c.basis, p.parent_person_id, "
                "       COALESCE((SELECT phone_number FROM person_phones "
                "                  WHERE person_id = p.id AND can_receive_sms = true "
                "                  ORDER BY is_primary DESC, id ASC LIMIT 1), "
                "                (SELECT phone_number FROM person_phones "
                "                  WHERE person_id = p.parent_person_id AND can_receive_sms = true "
                "                  ORDER BY is_primary DESC, id ASC LIMIT 1)) AS phone, "
                "       COALESCE((SELECT email FROM person_emails WHERE person_id = p.id "
                "                  ORDER BY is_primary DESC, id ASC LIMIT 1), "
                "                (SELECT email FROM person_emails WHERE person_id = p.parent_person_id "
                "                  ORDER BY is_primary DESC, id ASC LIMIT 1)) AS email "
                "  FROM fh_event_invite_candidates($1::bigint) c "
                "  JOIN persons p ON p.id = c.person_id "
                " ORDER BY c.from_team_name, p.last_name, p.first_name, p.id",
                {std::to_string(fhEventId)})) {
            candidates.push_back({
                {"person_id",        row["person_id"].as<long long>()},
                {"first_name",       textOrNull(row, "first_name")},
                {"last_name",        textOrNull(row, "last_name")},
                {"from_team_id",     row["from_team_id"].is_null() ? json(nullptr) : json(row["from_team_id"].as<long long>())},
                {"from_team",        textOrNull(row, "from_team_name")},
                {"single_age",       row["single_age"].is_null() ? json(nullptr) : json(row["single_age"].as<int>())},
                {"basis",            textOrNull(row, "basis")},
                {"parent_person_id", row["parent_person_id"].is_null() ? json(nullptr) : json(row["parent_person_id"].as<long long>())},
                {"phone",            textOrNull(row, "phone")},
                {"email",            textOrNull(row, "email")},
            });
        }

        return jsonOk({{"fh_event_id", fhEventId}, {"can_invite", true},
                       {"invites", invites}, {"candidates", candidates}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetEventInvites: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handlePostEventInvite(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId  = gate.personId;
    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON body"); }
    const auto targetOpt = jsonInt(body, "person_id");
    if (!targetOpt || *targetOpt <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    const long long targetPersonId = *targetOpt;
    std::string channel = body.value("channel", std::string("copy"));
    if (channel != "sms" && channel != "email" && channel != "copy") {
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be sms, email or copy");
    }
    std::string contact = body.value("contact", std::string(""));
    if (channel != "copy" && contact.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "contact required for sms/email");
    }

    try {
        auto* db = Database::getInstance();
        if (!isEventCoachOrAdmin(db, personId, fhEventId)) {
            return jsonError(HttpStatus::FORBIDDEN, "Only coaches and admins can invite players");
        }

        // Who is this, and may they be invited here? Either a fresh
        // candidate (derived) or an existing open invite (re-send).
        auto who = db->query(
            "SELECT p.first_name, p.last_name, p.parent_person_id, "
            "       c.from_team_id, c.from_team_name, "
            "       i.from_team_id AS inv_from_team_id, ft.name AS inv_from_team_name, "
            "       (c.person_id IS NOT NULL) AS is_candidate, (i.id IS NOT NULL) AS already "
            "  FROM persons p "
            "  LEFT JOIN fh_event_invite_candidates($1::bigint) c ON c.person_id = p.id "
            "  LEFT JOIN fh_event_invites i ON i.fh_event_id = $1::bigint AND i.person_id = p.id AND i.revoked_at IS NULL "
            "  LEFT JOIN teams ft ON ft.id = i.from_team_id "
            " WHERE p.id = $2::int",
            {std::to_string(fhEventId), std::to_string(targetPersonId)});
        if (who.empty()) return jsonError(HttpStatus::NOT_FOUND, "Person not found");
        const auto& w = who[0];
        const bool isCandidate = w["is_candidate"].as<bool>();
        const bool already     = w["already"].as<bool>();
        if (!isCandidate && !already) {
            return jsonError(HttpStatus::FORBIDDEN,
                             "That player is not eligible to be invited to this game "
                             "(rostered already, wrong age or program, or another section).");
        }
        const std::string firstName = w["first_name"].is_null() ? "" : w["first_name"].c_str();
        const bool youth = !w["parent_person_id"].is_null();
        const long long recipientPersonId = youth ? w["parent_person_id"].as<long long>() : targetPersonId;
        const std::string fromTeamId = !w["from_team_id"].is_null() ? std::string(w["from_team_id"].c_str())
                                     : !w["inv_from_team_id"].is_null() ? std::string(w["inv_from_team_id"].c_str()) : "";
        const std::string fromTeamName = !w["from_team_name"].is_null() ? std::string(w["from_team_name"].c_str())
                                       : !w["inv_from_team_name"].is_null() ? std::string(w["inv_from_team_name"].c_str()) : "";

        const auto info = loadInviteEventInfo(db, fhEventId);
        if (!info) return jsonError(HttpStatus::NOT_FOUND, "Event not found");

        const std::string adminUserIdStr = resolveUserId(db, personId);
        const long long adminUserId = adminUserIdStr.empty() ? 0 : std::stoll(adminUserIdStr);

        // Magic link for the RECIPIENT (parent for youth). magic_link_tokens
        // only knows sms/email; a copied link is minted as sms.
        const auto minted = MagicLinkService::mint(recipientPersonId,
                                                   channel == "email" ? "email" : "sms",
                                                   contact, adminUserId);

        auto ins = db->query(
            "INSERT INTO fh_event_invites "
            "    (fh_event_id, person_id, from_team_id, recipient_person_id, invited_by_user_id, channel, contact) "
            "VALUES ($1::bigint, $2::int, NULLIF($3, '')::int, $4::int, NULLIF($5, '')::int, $6, NULLIF($7, '')) "
            "ON CONFLICT (fh_event_id, person_id) WHERE revoked_at IS NULL DO UPDATE "
            "   SET channel = EXCLUDED.channel, contact = COALESCE(EXCLUDED.contact, fh_event_invites.contact), "
            "       invited_by_user_id = EXCLUDED.invited_by_user_id "
            "RETURNING id, to_char(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at",
            {std::to_string(fhEventId), std::to_string(targetPersonId), fromTeamId,
             std::to_string(recipientPersonId), adminUserIdStr, channel, contact});

        // Recipient's first name for the greeting (parent for youth).
        std::string recipientFirst = firstName;
        if (youth) {
            auto r = db->query("SELECT COALESCE(first_name, '') AS fn FROM persons WHERE id = $1::int",
                               {std::to_string(recipientPersonId)});
            if (!r.empty()) recipientFirst = r[0]["fn"].c_str();
        }

        // ── Copy ── message_templates kind 'event_invite' / 'event_invite_sms',
        // tier adult|parent (migration 366).  Player-facing: squad + kind
        // label + opponent + time, never the gcal title.
        std::string kindLabel;
        {
            auto k = db->query("SELECT player_label FROM fh_event_kind_labels WHERE kind = $1", {info->kind});
            if (!k.empty()) kindLabel = k[0]["player_label"].c_str();
        }
        MessageCopy copy;
        const MessageCopy::Tokens tokens = {
            {"first", recipientFirst}, {"child", youth ? firstName : std::string{}},
            {"team", info->teamLabel}, {"from_team", fromTeamName}, {"kind", kindLabel},
            {"opponent", info->kind == "match" ? info->opponent : std::string{}},
            {"when", info->whenEt}, {"link", minted.url},
        };
        const std::string tier = youth ? "parent" : "adult";
        const auto email = copy.render("event_invite", tier, tokens);
        const auto sms   = copy.render("event_invite_sms", tier, tokens);
        if (!email.ok() || !sms.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "event_invite template missing (migration 366)");
        const std::string smsBody = copy.withSmsLinkHint(sms.body);

        json invite = {
            {"person_id",  targetPersonId},
            {"first_name", firstName},
            {"last_name",  w["last_name"].is_null() ? "" : w["last_name"].c_str()},
            {"from_team",  fromTeamName.empty() ? json(nullptr) : json(fromTeamName)},
            {"channel",    channel},
            {"contact",    contact.empty() ? json(nullptr) : json(contact)},
            {"response",   nullptr},
            {"created_at", ins.empty() ? json(nullptr) : json(std::string(ins[0]["created_at"].c_str()))},
        };
        json out = {
            {"url",        minted.url},
            {"expires_at", minted.expiresIso},
            {"invite",     invite},
            {"sms_body",   smsBody},
        };
        copy.addComposeHrefs(out, channel, contact, email.subject, email.body, sms.body);
        Response r(HttpStatus::CREATED, out.dump());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handlePostEventInvite: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response CalendarController::handleDeleteEventInvite(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId  = gate.personId;
    const long long fhEventId = extractEventIdFromAttendancePath(request.getPath());
    const long long targetPersonId = extractPersonIdFromInvitePath(request.getPath());
    if (fhEventId <= 0 || targetPersonId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id and person_id required");
    }
    try {
        auto* db = Database::getInstance();
        if (!isEventCoachOrAdmin(db, personId, fhEventId)) {
            return jsonError(HttpStatus::FORBIDDEN, "Only coaches and admins can revoke invites");
        }
        const std::string userId = resolveUserId(db, personId);
        auto rows = db->query(
            "UPDATE fh_event_invites SET revoked_at = now(), revoked_by_user_id = NULLIF($3, '')::int "
            " WHERE fh_event_id = $1::bigint AND person_id = $2::int AND revoked_at IS NULL "
            "RETURNING id",
            {std::to_string(fhEventId), std::to_string(targetPersonId), userId});
        return jsonOk({{"fh_event_id", fhEventId}, {"person_id", targetPersonId},
                       {"revoked", !rows.empty()}});
    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleDeleteEventInvite: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
