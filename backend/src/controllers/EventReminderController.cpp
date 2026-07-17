#include "EventReminderController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <regex>
#include <sstream>
#include <string>
#include <unordered_set>

using nlohmann::json;

namespace {

// Rate limit: at most one link generation per (fh_event, person) inside
// this window.  Narrow safety net against UI double-taps — coaches can
// still re-nudge the same person any time it's been longer.
constexpr int kRateLimitWindowSeconds = 5 * 60;       // 5 minutes
// Token freshness — magic links stop working after this from sent_at.
constexpr int kReminderTtlSeconds     = 48 * 60 * 60; // 48 hours

// Same PUBLIC_BASE_URL convention as MagicLinkAuthController.  Kept as
// a private duplicate to avoid pulling MagicLinkAuthController.h in.
const std::string& publicBaseUrl() {
    static const std::string value = [] {
        const char* env = std::getenv("PUBLIC_BASE_URL");
        std::string v = (env && *env)
                            ? std::string(env)
                            : std::string("https://footballhome.org");
        while (!v.empty() && v.back() == '/') v.pop_back();
        return v;
    }();
    return value;
}

bool useSecureCookies() {
    const std::string& base = publicBaseUrl();
    if (base.size() < 7) return true;
    std::string scheme = base.substr(0, 7);
    std::transform(scheme.begin(), scheme.end(), scheme.begin(),
                   [](unsigned char c) {
                       return static_cast<char>(std::tolower(c));
                   });
    return scheme != "http://";
}

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

Response htmlError(HttpStatus s, const std::string& msg) {
    Response r(s, msg);
    r.setHeader("Content-Type", "text/plain; charset=utf-8");
    return r;
}

// Extract the numeric fh_event id from `/api/events/<id>/remind`.
// Returns 0 on parse failure.
long long extractFhEventIdFromPath(const std::string& path) {
    static const std::regex re(R"(/api/events/([0-9]+)/remind)");
    std::smatch m;
    if (std::regex_search(path, m, re)) {
        try { return std::stoll(m[1].str()); } catch (...) { return 0; }
    }
    return 0;
}

// Extract `userId` from a signed bearer token.  requireBearer() has
// already verified the signature by the time this runs, so we don't
// re-check; we only decode the payload to get the audit column.
std::string bearerUserIdString(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    if (h.size() < 8 || h.compare(0, 7, "Bearer ") != 0) return {};
    const std::string token = h.substr(7);
    const auto d1 = token.find('.');
    if (d1 == std::string::npos) return {};
    const auto d2 = token.find('.', d1 + 1);
    if (d2 == std::string::npos) return {};

    const std::string payload =
        fh::crypto::base64UrlDecode(token.substr(d1 + 1, d2 - d1 - 1));

    const std::string needle = "\"userId\":\"";
    auto pos = payload.find(needle);
    if (pos == std::string::npos) return {};
    pos += needle.size();
    auto end = payload.find('"', pos);
    if (end == std::string::npos) return {};
    return payload.substr(pos, end - pos);
}

// First-forwarded IP — same helper as MagicLinkAuthController.
std::string firstForwardedIp(const std::string& xff) {
    const std::size_t comma = xff.find(',');
    std::string ip = xff.substr(0, comma == std::string::npos ? xff.size() : comma);
    auto issp = [](unsigned char c) { return std::isspace(c) != 0; };
    while (!ip.empty() && issp(static_cast<unsigned char>(ip.front()))) ip.erase(ip.begin());
    while (!ip.empty() && issp(static_cast<unsigned char>(ip.back())))  ip.pop_back();
    return ip;
}

std::string toLower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) {
                       return static_cast<char>(std::tolower(c));
                   });
    return s;
}

// Human "type" label for a fh_events.kind value.  Cosmetic only.
std::string kindLabel(const std::string& kind) {
    if (kind == "practice") return "Practice";
    if (kind == "pickup")   return "Pickup";
    if (kind == "match")    return "Match";
    if (kind == "meeting")  return "Meeting";
    if (kind == "camp")     return "Camp";
    return "Event";
}

}  // namespace

EventReminderController::EventReminderController()  = default;
EventReminderController::~EventReminderController() = default;

void EventReminderController::registerRoutes(Router& router,
                                             const std::string& prefix) {
    // prefix is "/api".  Three endpoints:
    //   POST /api/events/:fhEventId/remind   (coach)   — laPost + all LA
    //   GET  /api/reminders/verify           (public)  — no LA read
    //   GET  /api/mens/week-availability     (coach)   — laGet  + all LA
    //
    // /remind and /mens/week-availability read person_la_memberships to
    // filter out paused-variant members (§ Membership Data Flow) — so
    // they route through the la* helpers and receive a fresh LaSyncMap
    // covering every LA program in the registry.  /verify is a public
    // token exchange that never touches LA membership state, so it
    // stays on router.get.
    laPost(router, prefix + "/events/:fhEventId/remind",
           [](const Request&) { return Controller::allLaProgramIds(); },
           [this](const Request& r, const LaSyncMap& sync) {
               return handleSendReminders(r, sync);
           });
    router.get (prefix + "/reminders/verify",
                [this](const Request& r) { return handleVerify(r); });
    laGet(router, prefix + "/mens/week-availability",
          [](const Request&) { return Controller::allLaProgramIds(); },
          [this](const Request& r, const LaSyncMap& sync) {
              return handleGetMensWeek(r, sync);
          });
}

// ---------------------------------------------------------------------
// POST /api/events/:fhEventId/remind
// ---------------------------------------------------------------------
Response EventReminderController::handleSendReminders(const Request& request,
                                                     const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laPost(); handler reads DB only.
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }

    const long long fhEventId = extractFhEventIdFromPath(request.getPath());
    if (fhEventId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid fh_event id");
    }

    // Parse body — everything optional.
    json body;
    if (!request.getBody().empty()) {
        try { body = json::parse(request.getBody()); }
        catch (const std::exception& e) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             std::string("invalid JSON: ") + e.what());
        }
    } else {
        body = json::object();
    }

    std::string channel = "sms";
    if (body.contains("channel") && body["channel"].is_string()) {
        channel = toLower(body["channel"].get<std::string>());
    }
    if (channel != "sms" && channel != "email") {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "channel must be 'sms' or 'email'");
    }

    // Explicit person_ids filter — coach can narrow the batch.  When
    // omitted or empty, every non-responder on the event's roster is
    // targeted.
    std::unordered_set<long long> filterPersonIds;
    if (body.contains("person_ids") && body["person_ids"].is_array()) {
        for (const auto& p : body["person_ids"]) {
            if (p.is_number_integer())        filterPersonIds.insert(p.get<long long>());
            else if (p.is_number_unsigned())  filterPersonIds.insert(static_cast<long long>(p.get<unsigned long long>()));
            else if (p.is_string()) {
                try { filterPersonIds.insert(std::stoll(p.get<std::string>())); }
                catch (...) {}
            }
        }
    }

    const std::string senderUserId = bearerUserIdString(request);

    auto* db = Database::getInstance();

    try {
        // 1) Event must exist + not be a deleted gcal row + in future.
        auto ev = db->query(
            "SELECT fe.id, fe.kind, "
            "       COALESCE(NULLIF(ge.summary,''), 'Event') AS title, "
            "       (ge.starts_at AT TIME ZONE 'America/New_York')::date AS event_date, "
            "       TO_CHAR(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy, Mon FMDD') AS date_str, "
            "       TO_CHAR(ge.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS time_str, "
            "       ge.starts_at AS starts_at, "
            "       ge.deleted_at IS NOT NULL AS deleted "
            "  FROM fh_events fe "
            "  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            " WHERE fe.id = $1::bigint",
            {std::to_string(fhEventId)});
        if (ev.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "fh_event not found");
        }
        if (ev[0]["deleted"].as<bool>()) {
            return jsonError(HttpStatus::BAD_REQUEST, "event is cancelled");
        }

        const std::string eventTitle = ev[0]["title"].is_null()
                                     ? std::string{}
                                     : ev[0]["title"].as<std::string>();
        const std::string dateStr    = ev[0]["date_str"].is_null()
                                     ? std::string{}
                                     : ev[0]["date_str"].as<std::string>();
        const std::string timeStr    = ev[0]["time_str"].is_null()
                                     ? std::string{}
                                     : ev[0]["time_str"].as<std::string>();

        // 2) Non-responders on the event's roster with the requested
        //    channel available.  Roster comes from fh_event_teams →
        //    player_rsvp_eligibility → external_person_aliases → persons.
        //    A "non-responder" has no row in fh_event_rsvps for this
        //    event (unique index on (fh_event_id, person_id) guarantees
        //    at most one row per person, so we can just LEFT JOIN and
        //    filter on NULL).
        //
        //    Paused-variant members are excluded — they're
        //    members-in-name-only.  They can still self-serve via
        //    /#calendar; we just don't clutter reminders.
        std::string contactSql;
        if (channel == "sms") {
            contactSql =
                " (SELECT phone_number FROM person_phones "
                "   WHERE person_id = p.id "
                "     AND can_receive_sms = true "
                "   ORDER BY is_primary DESC, id ASC "
                "   LIMIT 1) AS contact ";
        } else {
            contactSql =
                " (SELECT email FROM person_emails "
                "   WHERE person_id = p.id "
                "   ORDER BY is_primary DESC, id ASC "
                "   LIMIT 1) AS contact ";
        }

        const std::string sql =
            "SELECT DISTINCT p.id AS person_id, "
            "       p.first_name, p.last_name, "
            + contactSql +
            "  FROM fh_event_teams fet "
            "  JOIN player_rsvp_eligibility ple "
            "    ON ple.team_id = fet.team_id "
            "  JOIN external_person_aliases epa "
            "    ON epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = ple.leagueapps_user_id::text "
            "  JOIN persons p ON p.id = epa.person_id "
            "  LEFT JOIN fh_event_rsvps r "
            "    ON r.fh_event_id = fet.fh_event_id "
            "   AND r.person_id   = p.id "
            " WHERE fet.fh_event_id = $1::bigint "
            "   AND r.id IS NULL "
            "   AND NOT EXISTS ( "
            "     SELECT 1 FROM person_la_memberships plm "
            "       JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "      WHERE plm.person_id = p.id "
            "        AND plm.ended_at IS NULL "
            "        AND lp.variant   = 'paused' "
            "   ) "
            " ORDER BY p.last_name, p.first_name";
        auto rows = db->query(sql, {std::to_string(fhEventId)});

        // 3) Send loop — rate-limit + insert + build URLs.
        json recipients = json::array();
        int sent = 0;
        int skippedRateLimited = 0;
        int skippedNoContact   = 0;

        for (const auto& r : rows) {
            const long long personId = r["person_id"].as<long long>();

            if (!filterPersonIds.empty() && !filterPersonIds.count(personId)) {
                continue;
            }
            if (r["contact"].is_null()) {
                ++skippedNoContact;
                continue;
            }

            // Rate-limit: any row in the last kRateLimitWindowSeconds?
            auto rl = db->query(
                "SELECT 1 FROM player_event_reminders "
                " WHERE fh_event_id = $1::bigint "
                "   AND person_id   = $2::int "
                "   AND sent_at     > NOW() - ($3 || ' seconds')::interval "
                " LIMIT 1",
                {std::to_string(fhEventId),
                 std::to_string(personId),
                 std::to_string(kRateLimitWindowSeconds)});
            if (!rl.empty()) {
                ++skippedRateLimited;
                continue;
            }

            const std::string firstName = r["first_name"].as<std::string>();
            const std::string lastName  = r["last_name"].as<std::string>();
            const std::string contact   = r["contact"].as<std::string>();

            // Random 32-byte token, stored as SHA-256 hex.  Raw token
            // goes only into the URL.  UNIQUE constraint on magic_token
            // guarantees we can't collide even under high concurrency.
            const std::string raw   = fh::crypto::randomTokenB64Url(32);
            const std::string hash  = fh::crypto::sha256Hex(raw);

            try {
                db->query(
                    "INSERT INTO player_event_reminders "
                    "  (fh_event_id, person_id, channel, magic_token, sent_by) "
                    "VALUES ($1::bigint, $2::int, $3, $4, NULLIF($5, '')::int)",
                    {std::to_string(fhEventId),
                     std::to_string(personId),
                     channel,
                     hash,
                     senderUserId});
            } catch (const std::exception& e) {
                std::cerr << "[reminders] insert failed for person "
                          << personId << ": " << e.what() << std::endl;
                continue;
            }

            const std::string verifyUrl = publicBaseUrl()
                                        + "/api/reminders/verify?token="
                                        + fh::crypto::urlEncode(raw);

            std::ostringstream smsBody;
            smsBody << "Hi " << firstName << ", RSVP for ";
            if (!eventTitle.empty()) smsBody << eventTitle << " ";
            if (!dateStr.empty())    smsBody << dateStr;
            if (!timeStr.empty())    smsBody << " " << timeStr;
            smsBody << ": " << verifyUrl
                    << " (RSVP required for every event so we can plan)";

            std::ostringstream emailBody;
            emailBody << "Hi " << firstName << ",\n\n"
                      << "Please RSVP for ";
            if (!eventTitle.empty()) emailBody << eventTitle;
            if (!dateStr.empty() || !timeStr.empty()) {
                emailBody << " (";
                if (!dateStr.empty()) emailBody << dateStr;
                if (!timeStr.empty()) emailBody << (dateStr.empty() ? "" : " ") << timeStr;
                emailBody << ")";
            }
            emailBody << ":\n" << verifyUrl << "\n\n"
                      << "RSVPing to every event on your schedule is required "
                      << "\u2014 it\u2019s how we plan rosters, subs, and cancellations. "
                      << "Not sure? Tap Not Going \u2014 you can always change it later "
                      << "if plans free up. This link signs you in automatically and "
                      << "expires in 48 hours.\n\n"
                      << "\u2014 Lighthouse Soccer";

            const std::string subject =
                std::string("Football Home \u2014 RSVP")
                + (eventTitle.empty() ? "" : (" for " + eventTitle));

            json rec = {
                {"person_id",  personId},
                {"name",       firstName + " " + lastName},
                {"contact",    contact},
                {"url",        verifyUrl},
            };
            if (channel == "sms") {
                rec["sms_href"] = "sms:" + fh::crypto::urlEncode(contact)
                                + "?body=" + fh::crypto::urlEncode(smsBody.str());
            } else {
                rec["mailto_href"] = "mailto:" + fh::crypto::urlEncode(contact)
                                   + "?subject=" + fh::crypto::urlEncode(subject)
                                   + "&body="    + fh::crypto::urlEncode(emailBody.str());
            }
            recipients.push_back(rec);
            ++sent;
        }

        return jsonOk({
            {"fh_event_id",          fhEventId},
            {"channel",              channel},
            {"sent",                 sent},
            {"skipped_rate_limited", skippedRateLimited},
            {"skipped_no_contact",   skippedNoContact},
            {"recipients",           recipients},
        });
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/events/:id/remind] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ---------------------------------------------------------------------
// GET /api/reminders/verify?token=...
// ---------------------------------------------------------------------
Response EventReminderController::handleVerify(const Request& request) {
    const std::string rawToken = request.getQueryParam("token");
    if (rawToken.empty()) {
        return htmlError(HttpStatus::BAD_REQUEST, "Missing token");
    }

    auto* db = Database::getInstance();
    const std::string hash = fh::crypto::sha256Hex(rawToken);

    try {
        auto row = db->query(
            "SELECT id, fh_event_id, person_id, delivered_at, "
            "       (sent_at < NOW() - ($2 || ' seconds')::interval) AS expired "
            "  FROM player_event_reminders "
            " WHERE magic_token = $1 "
            " LIMIT 1",
            {hash, std::to_string(kReminderTtlSeconds)});
        if (row.empty()) {
            return htmlError(HttpStatus::NOT_FOUND, "Invalid link");
        }
        if (row[0]["expired"].as<bool>()) {
            return htmlError(HttpStatus(410),
                             "This link has expired \u2014 open the app "
                             "and sign in the normal way.");
        }

        const long long reminderId = row[0]["id"].as<long long>();
        const long long personId   = row[0]["person_id"].as<long long>();
        const bool alreadyUsed     = !row[0]["delivered_at"].is_null();

        const std::string ua  = request.getHeader("User-Agent");
        const std::string xff = request.getHeader("X-Forwarded-For");
        const std::string ip  = firstForwardedIp(xff);

        auto& sessions = SessionService::getInstance();
        auto minted    = sessions.createSession(personId, ua, ip);

        // First hit records delivered_at.  Subsequent hits still mint
        // a fresh session (recipients often re-open the SMS on a new
        // device) but don't overwrite the original delivery timestamp.
        if (!alreadyUsed) {
            db->query(
                "UPDATE player_event_reminders "
                "   SET delivered_at = NOW() "
                " WHERE id = $1::int",
                {std::to_string(reminderId)});
        }

        // Land the recipient on the CalendarScreen — the canonical RSVP
        // surface post-gcal.  User directive 2026-07-17: "the reminder
        // just sends them to fooballhome and it should for most be
        // already logged in.  and if t hey are are only a player its
        // supposed ot default to their rsvp page."
        const std::string target = publicBaseUrl() + "/#calendar";

        Response r(HttpStatus::FOUND);
        r.setHeader("Location",  target);
        r.setHeader("Set-Cookie",
                    sessions.buildSetCookie(minted.cookieValue,
                                            SessionService::kSessionTtl,
                                            useSecureCookies()));
        r.setBody("Redirecting...");
        r.setHeader("Content-Type", "text/plain; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/reminders/verify] " << e.what() << std::endl;
        return htmlError(HttpStatus::INTERNAL_SERVER_ERROR, "Sign-in failed");
    }
}

// ---------------------------------------------------------------------
// GET /api/mens/week-availability?days=7
// ---------------------------------------------------------------------
//
// Returns the full RSVP picture for every mens fh_event in the next
// `days` (default 7, capped at 30) — one row per event with a nested
// `players` array containing every roster-eligible player and their
// current RSVP status.  Powers the horizontal event-columns
// "Mens Reminders" screen.
//
// Response shape:
//   {
//     "week_start": "2026-07-06",
//     "week_end":   "2026-07-12",
//     "events": [
//       {
//         "fh_event_id": 420,
//         "kind": "pickup" | "practice" | "match" | ...,
//         "type_label": "Pickup",
//         "title": "Soccer 11th grade+ Practice",
//         "match_date": "2026-07-18", "match_time": "11:00:00",
//         "date_str": "Sat, Jul 18", "time_str": "11:00 AM",
//         "venue_name": "Lighthouse Sport Complex",
//         "players": [
//           { "person_id":1234, "first_name":"Jim", "last_name":"Breslin",
//             "email":"j@x", "phone":"+12155551234",
//             "sms_capable":true,
//             "home_team_id": 35, "home_team_short": "APSL",
//             "is_pickup_only": false,
//             "rsvp_status": "yes" | "no" | "maybe" | null }
//         ]
//       }, ...
//     ]
//   }
Response EventReminderController::handleGetMensWeek(const Request& request,
                                                    const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laGet(); handler reads DB only.
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }

    int days = 7;
    {
        const std::string s = request.getQueryParam("days");
        if (!s.empty()) {
            try {
                days = std::stoi(s);
                if (days < 1)  days = 1;
                if (days > 30) days = 30;
            } catch (...) { days = 7; }
        }
    }

    auto* db = Database::getInstance();

    try {
        // 1) Event metadata for the window — mens fh_events, non-deleted
        //    gcal row, starts_at inside [today 00:00 ET, today+days 00:00 ET).
        auto events = db->query(
            "SELECT fe.id AS fh_event_id, "
            "       fe.kind, "
            "       COALESCE(NULLIF(ge.summary,''), 'Event') AS title, "
            "       (ge.starts_at AT TIME ZONE 'America/New_York')::date::text AS match_date, "
            "       TO_CHAR(ge.starts_at AT TIME ZONE 'America/New_York', 'HH24:MI:SS') AS match_time, "
            "       TO_CHAR(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy, Mon FMDD') AS date_str, "
            "       TO_CHAR(ge.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS time_str, "
            "       COALESCE(ge.location, '') AS venue_name "
            "  FROM fh_events fe "
            "  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            " WHERE fe.category = 'mens' "
            "   AND ge.deleted_at IS NULL "
            "   AND ge.starts_at >= (((NOW() AT TIME ZONE 'America/New_York')::date)::timestamp) "
            "                        AT TIME ZONE 'America/New_York' "
            "   AND ge.starts_at <  ((((NOW() AT TIME ZONE 'America/New_York')::date "
            "                          + ($1 || ' days')::interval)::timestamp)) "
            "                        AT TIME ZONE 'America/New_York' "
            " ORDER BY ge.starts_at ASC",
            {std::to_string(days)});

        // Week window strings — return the actual range we queried so
        // the front-end can label the header.
        std::string weekStart, weekEnd;
        {
            auto wk = db->query(
                "SELECT ((NOW() AT TIME ZONE 'America/New_York')::date)::text AS ws, "
                "       ((NOW() AT TIME ZONE 'America/New_York')::date "
                "        + ($1 || ' days')::interval - INTERVAL '1 day')::date::text AS we",
                {std::to_string(days)});
            if (!wk.empty()) {
                weekStart = wk[0]["ws"].as<std::string>();
                weekEnd   = wk[0]["we"].as<std::string>();
            }
        }

        json evList = json::array();
        for (const auto& e : events) {
            const long long fhEventId = e["fh_event_id"].as<long long>();
            const std::string kind    = e["kind"].is_null() ? "" : e["kind"].as<std::string>();

            // 2) Roster-eligible players + latest RSVP for this event.
            //    Roster comes from fh_event_teams → player_rsvp_eligibility
            //    (908/909 pool teams for practice/pickup, real team_id for
            //    match).  fh_event_rsvps is one-row-per-person by unique
            //    index so a LEFT JOIN is enough.
            //
            //    home_team_short chips ("APSL 5 · L1 3 · L2 6 · Adult 2")
            //    are still driven by the person's real mens roster
            //    (35/120/121/122).  is_pickup_only mirrors the same
            //    lookup so pickup-only members render in the collapsed
            //    section at the bottom of the column (user directive
            //    2026-07-07).
            auto players = db->query(
                "SELECT DISTINCT p.id AS person_id, "
                "       p.first_name, p.last_name, "
                "       (SELECT email FROM person_emails "
                "         WHERE person_id = p.id "
                "         ORDER BY is_primary DESC, id ASC LIMIT 1) AS email, "
                "       (SELECT phone_number FROM person_phones "
                "         WHERE person_id = p.id "
                "         ORDER BY is_primary DESC, id ASC LIMIT 1) AS phone_any, "
                "       (SELECT phone_number FROM person_phones "
                "         WHERE person_id = p.id AND can_receive_sms = true "
                "         ORDER BY is_primary DESC, id ASC LIMIT 1) AS phone_sms, "
                "       r.response AS rsvp_status, "
                "       NOT EXISTS ( "
                "         SELECT 1 FROM roster_assignments ra_sel "
                "          WHERE ra_sel.domain              = 'mens' "
                "            AND ra_sel.removed_at          IS NULL "
                "            AND ra_sel.leagueapps_user_id  = ple.leagueapps_user_id "
                "            AND ra_sel.team_id             IN (35, 120, 121, 122) "
                "       ) AS is_pickup_only, "
                "       ht.team_id AS home_team_id, "
                "       CASE ht.team_id "
                "         WHEN 35  THEN 'APSL' "
                "         WHEN 120 THEN 'L1' "
                "         WHEN 121 THEN 'L2' "
                "         WHEN 122 THEN 'Adult' "
                "         ELSE NULL END AS home_team_short "
                "  FROM fh_event_teams fet "
                "  JOIN player_rsvp_eligibility ple "
                "    ON ple.team_id = fet.team_id "
                "  JOIN external_person_aliases epa "
                "    ON epa.provider = 'leagueapps' "
                "   AND epa.external_user_id = ple.leagueapps_user_id::text "
                "  JOIN persons p ON p.id = epa.person_id "
                "  LEFT JOIN LATERAL ( "
                "     SELECT ra.team_id "
                "       FROM roster_assignments ra "
                "      WHERE ra.leagueapps_user_id = ple.leagueapps_user_id "
                "        AND ra.domain = 'mens' "
                "        AND ra.removed_at IS NULL "
                "        AND ra.team_id IN (35, 120, 121, 122) "
                "      ORDER BY ra.team_id LIMIT 1 "
                "  ) ht ON true "
                "  LEFT JOIN fh_event_rsvps r "
                "    ON r.fh_event_id = $1::bigint "
                "   AND r.person_id   = p.id "
                " WHERE fet.fh_event_id = $1::bigint "
                "   AND NOT EXISTS ( "
                "     SELECT 1 FROM person_la_memberships plm "
                "       JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
                "      WHERE plm.person_id = p.id "
                "        AND plm.ended_at IS NULL "
                "        AND lp.variant   = 'paused' "
                "   ) "
                " ORDER BY p.last_name, p.first_name",
                {std::to_string(fhEventId)});

            json plist = json::array();
            for (const auto& r : players) {
                json rec = {
                    {"person_id",  r["person_id"].as<long long>()},
                    {"first_name", r["first_name"].is_null() ? "" : r["first_name"].as<std::string>()},
                    {"last_name",  r["last_name"].is_null()  ? "" : r["last_name"].as<std::string>()},
                    {"email",      r["email"].is_null()      ? "" : r["email"].as<std::string>()},
                    {"phone",      r["phone_any"].is_null()  ? "" : r["phone_any"].as<std::string>()},
                    {"sms_capable",!r["phone_sms"].is_null() && !r["phone_sms"].as<std::string>().empty()},
                    {"home_team_id",    r["home_team_id"].is_null()    ? json(nullptr) : json(r["home_team_id"].as<long long>())},
                    {"home_team_short", r["home_team_short"].is_null() ? json(nullptr) : json(r["home_team_short"].as<std::string>())},
                    {"rsvp_status",r["rsvp_status"].is_null() ? json(nullptr)
                                                              : json(r["rsvp_status"].as<std::string>())},
                    {"is_pickup_only", !r["is_pickup_only"].is_null() && r["is_pickup_only"].as<bool>()},
                };
                plist.push_back(std::move(rec));
            }

            json evj = {
                {"fh_event_id",    fhEventId},
                {"kind",           kind},
                {"type_label",     kindLabel(kind)},
                {"title",          e["title"].is_null() ? "" : e["title"].as<std::string>()},
                {"match_date",     e["match_date"].is_null() ? "" : e["match_date"].as<std::string>()},
                {"match_time",     e["match_time"].is_null() ? "" : e["match_time"].as<std::string>()},
                {"date_str",       e["date_str"].is_null() ? "" : e["date_str"].as<std::string>()},
                {"time_str",       e["time_str"].is_null() ? "" : e["time_str"].as<std::string>()},
                {"venue_name",     e["venue_name"].is_null() ? "" : e["venue_name"].as<std::string>()},
                {"players",        std::move(plist)},
            };
            evList.push_back(std::move(evj));
        }

        return jsonOk({
            {"week_start", weekStart},
            {"week_end",   weekEnd},
            {"days",       days},
            {"events",     evList},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/mens/week-availability] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
