#include "EventRsvpController.h"

#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cctype>
#include <iostream>
#include <optional>
#include <stdexcept>
#include <string>

using nlohmann::json;

namespace {

Response jsonError(HttpStatus s, const std::string& message) {
    json body = {{"error", message}};
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonOk(const json& body) {
    Response r(HttpStatus::OK, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

// Cookie-session gate.  Returns the resolved session on success and
// emits the proper 401 ("Not signed in" if there was no cookie at
// all, "Session expired" if the cookie was present but invalid) on
// failure — matches the Node `requireSession` middleware exactly.
struct SessionGate {
    std::optional<SessionService::ResolvedSession> session;
    std::optional<Response>                        error;
};

SessionGate requireSession(const Request& request) {
    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (!resolved) {
        return {std::nullopt,
                jsonError(HttpStatus::UNAUTHORIZED,
                          sessVal.empty() ? "Not signed in" : "Session expired")};
    }
    return {std::move(resolved), std::nullopt};
}

// Carve the trailing path segment out of /api/events/:chatEventId.
// Router has already pattern-matched so we know the prefix is there.
std::string trailingSegment(const std::string& path, const std::string& prefix) {
    if (path.size() <= prefix.size() + 1) return {};
    if (path.compare(0, prefix.size(), prefix) != 0) return {};
    if (path[prefix.size()] != '/') return {};
    std::string seg = path.substr(prefix.size() + 1);
    // Strip a trailing slash if any.
    while (!seg.empty() && seg.back() == '/') seg.pop_back();
    return seg;
}

}  // namespace

EventRsvpController::EventRsvpController() = default;
EventRsvpController::~EventRsvpController() = default;

void EventRsvpController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix is "/api" — keeps the controller's two routes co-located
    // even though they don't share a deeper path root.
    router.get (prefix + "/events/:chatEventId",
                [this](const Request& r) { return handleGetEvent(r); });
}

Response EventRsvpController::handleGetEvent(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    // Pull the chat_event id out of /api/events/<id>.
    const std::string idStr = trailingSegment(request.getPath(), "/api/events");
    long long chatEventId = 0;
    try { chatEventId = std::stoll(idStr); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "chat_event_id required"); }
    if (chatEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "chat_event_id required");

    auto* db = Database::getInstance();
    try {
        // Date/time columns are formatted server-side to match the JSON
        // shape pg's default type parsers produce in Node:
        //   DATE        → "YYYY-MM-DDT00:00:00.000Z"  (UTC midnight)
        //   TIME        → "HH24:MI:SS"
        //   TIMESTAMPTZ → "YYYY-MM-DDTHH24:MI:SS.MSZ"
        // The "when" string uses the same America/New_York to_char
        // pattern as Phase 4's mint path so all four endpoints emit
        // glyph-identical event labels.
        auto evRow = db->query(
            "SELECT ce.id, ce.title, ce.location, "
            "       to_char(ce.event_date, 'YYYY-MM-DD\"T00:00:00.000Z\"')         AS event_date, "
            "       to_char(ce.event_time, 'HH24:MI:SS')                             AS event_time, "
            "       to_char(ce.start_at  AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"')                     AS start_at, "
            "       ce.match_id, ce.chat_id, c.team_id, t.name AS team_name, "
            "       t.gender_category AS gender_category, "
            "       to_char( "
            "         COALESCE(ce.start_at, "
            "                  (ce.event_date::timestamp + ce.event_time))::timestamptz "
            "           AT TIME ZONE 'America/New_York', "
            "         'Dy, Mon FMDD\" \u00b7 \"FMHH12:MI AM')                         AS when_str "
            "  FROM chat_events ce "
            "  LEFT JOIN chats c ON c.id = ce.chat_id "
            "  LEFT JOIN teams t ON t.id = c.team_id "
            " WHERE ce.id = $1::int",
            {std::to_string(chatEventId)});
        if (evRow.empty()) return jsonError(HttpStatus::NOT_FOUND, "Event not found");

        const auto& ev = evRow[0];
        auto strOrNull = [&](const char* col) -> json {
            return ev[col].is_null() ? json(nullptr) : json(ev[col].as<std::string>());
        };

        json event = {
            {"id",         ev["id"].as<long long>()},
            {"title",      strOrNull("title")},
            {"location",   strOrNull("location")},
            {"event_date", strOrNull("event_date")},
            {"event_time", strOrNull("event_time")},
            {"start_at",   strOrNull("start_at")},
            {"team_name",  strOrNull("team_name")},
            {"gender_category", strOrNull("gender_category")},
            {"when",       ev["when_str"].is_null() ? json(nullptr)
                                                    : json(ev["when_str"].as<std::string>())},
        };

        // Current FH-native RSVP for the signed-in person.  Null when
        // they haven't responded yet — matches Node `rows[0] || null`.
        auto rsvpRow = db->query(
            "SELECT er.rsvp_status_id, rs.name AS status, er.response_note "
            "  FROM event_rsvps er "
            "  JOIN rsvp_statuses rs ON rs.id = er.rsvp_status_id "
            " WHERE er.chat_event_id = $1::int AND er.person_id = $2::int",
            {std::to_string(chatEventId), std::to_string(personId)});

        json myRsvp = nullptr;
        if (!rsvpRow.empty()) {
            myRsvp = {
                {"rsvp_status_id", rsvpRow[0]["rsvp_status_id"].as<long long>()},
                {"status",         rsvpRow[0]["status"].as<std::string>()},
                {"response_note",  rsvpRow[0]["response_note"].is_null()
                                      ? json(nullptr)
                                      : json(rsvpRow[0]["response_note"].as<std::string>())},
            };
        }

        return jsonOk({{"event", event}, {"my_rsvp", myRsvp}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/events/:chatEventId] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
