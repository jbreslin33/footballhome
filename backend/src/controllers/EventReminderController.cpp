#include "EventReminderController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <regex>
#include <sstream>
#include <string>
#include <unordered_set>

using nlohmann::json;

namespace {

// Rate limit: at most one link generation per (match, person) inside
// this window.  Narrow safety net against UI double-taps — coaches
// can still re-nudge the same person any time it's been longer.
constexpr int kRateLimitWindowSeconds = 5 * 60;       // 5 minutes
// Token freshness: verify links stop working after this from sent_at.
constexpr int kReminderTtlSeconds     = 48 * 60 * 60; // 48 hours

// Same PUBLIC_BASE_URL convention as MagicLinkAuthController.  Kept
// as a private duplicate to avoid pulling MagicLinkAuthController.h in.
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

// Extract the numeric `matchId` from `/api/matches/<id>/remind`.
// Returns 0 on parse failure.
long long extractMatchIdFromPath(const std::string& path) {
    static const std::regex re(R"(/api/matches/([0-9]+)/remind)");
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

// Firstforwarded IP — same helper as MagicLinkAuthController.
std::string firstForwardedIp(const std::string& xff) {
    const std::size_t comma = xff.find(',');
    std::string ip = xff.substr(0, comma == std::string::npos ? xff.size() : comma);
    auto issp = [](unsigned char c) { return std::isspace(c) != 0; };
    while (!ip.empty() && issp(static_cast<unsigned char>(ip.front()))) ip.erase(ip.begin());
    while (!ip.empty() && issp(static_cast<unsigned char>(ip.back())))  ip.pop_back();
    return ip;
}

std::optional<long long> jsonInt(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return std::nullopt;
    if (j[key].is_number_integer())  return j[key].get<long long>();
    if (j[key].is_number_unsigned()) return static_cast<long long>(j[key].get<unsigned long long>());
    if (j[key].is_string()) {
        try { return std::stoll(j[key].get<std::string>()); } catch (...) { return std::nullopt; }
    }
    return std::nullopt;
}

std::string toLower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) {
                       return static_cast<char>(std::tolower(c));
                   });
    return s;
}

}  // namespace

EventReminderController::EventReminderController()  = default;
EventReminderController::~EventReminderController() = default;

void EventReminderController::registerRoutes(Router& router,
                                             const std::string& prefix) {
    // prefix is "/api".  Three endpoints:
    //   POST /api/matches/:matchId/remind   (coach)     — laPost + all LA
    //   GET  /api/reminders/verify          (public)    — no LA read
    //   GET  /api/mens/week-availability    (coach)     — laGet  + all LA
    //
    // The /remind and /mens/week-availability handlers both read
    // person_la_memberships (paused-variant exclusion, § Membership Data
    // Flow) — so they route through la* helpers and receive a fresh
    // LaSyncMap covering every LA program in the registry.  /verify is a
    // public token exchange that never touches LA membership state, so
    // it stays on router.get.
    laPost(router, prefix + "/matches/:matchId/remind",
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
// POST /api/matches/:matchId/remind
// ---------------------------------------------------------------------
Response EventReminderController::handleSendReminders(const Request& request, const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laPost(); handler reads DB only.
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }

    const long long matchId = extractMatchIdFromPath(request.getPath());
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid match id");
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
    // omitted or empty, we target every non-responder on the home team.
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

    // player_ids filter — same purpose as person_ids but keyed on
    // `players.id` (what the front-end roster JSON uses).  Either or
    // both may be supplied; a row must pass every non-empty filter.
    std::unordered_set<long long> filterPlayerIds;
    if (body.contains("player_ids") && body["player_ids"].is_array()) {
        for (const auto& p : body["player_ids"]) {
            if (p.is_number_integer())        filterPlayerIds.insert(p.get<long long>());
            else if (p.is_number_unsigned())  filterPlayerIds.insert(static_cast<long long>(p.get<unsigned long long>()));
            else if (p.is_string()) {
                try { filterPlayerIds.insert(std::stoll(p.get<std::string>())); }
                catch (...) {}
            }
        }
    }

    const std::string senderUserId = bearerUserIdString(request);

    auto* db = Database::getInstance();

    try {
        // 1) Match must exist + be uncancelled + in the future (or today).
        auto mrow = db->query(
            "SELECT m.id, m.title, m.match_date, m.match_time, "
            "       m.home_team_id, m.cancelled_at, "
            "       to_char(m.match_date, 'Dy, Mon FMDD') AS date_str, "
            "       to_char(m.match_time, 'FMHH12:MI AM') AS time_str "
            "  FROM matches m "
            " WHERE m.id = $1::int",
            {std::to_string(matchId)});
        if (mrow.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "match not found");
        }
        if (!mrow[0]["cancelled_at"].is_null()) {
            return jsonError(HttpStatus::BAD_REQUEST, "match is cancelled");
        }
        const std::string matchTitle = mrow[0]["title"].is_null()
                                     ? std::string{}
                                     : mrow[0]["title"].as<std::string>();
        const std::string dateStr    = mrow[0]["date_str"].is_null()
                                     ? std::string{}
                                     : mrow[0]["date_str"].as<std::string>();
        const std::string timeStr    = mrow[0]["time_str"].is_null()
                                     ? std::string{}
                                     : mrow[0]["time_str"].as<std::string>();

        // 2) Find non-responders on the home team roster with the requested
        //    channel available.  Bridge: mens_team_assignments →
        //    external_person_aliases → persons.  Contact comes from
        //    person_phones (sms) or person_emails (email), preferring the
        //    primary row.
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

        // Non-responder = latest player_rsvp_history row is NULL (no
        // response yet).  "maybe" was deprecated 2026-07-10 so there is
        // no longer a maybe-branch; reminders go only to people who
        // haven't RSVP'd at all.
        //
        // Eligibility (migration 107): the responder has a
        // player_rsvp_eligibility grant for the match's home_team_id.
        // Practice → home_team_id=908, Pickup → 909, games → physical
        // home team.  Mirrors MyController + RsvpMaterialization.
        const std::string sql =
            "WITH match_ctx AS ( "
            "  SELECT id AS match_id, match_type_id, home_team_id "
            "    FROM matches WHERE id = $1::int "
            ") "
            "SELECT DISTINCT p.id AS person_id, pl.id AS player_id, "
            "       p.first_name, p.last_name, "
            + contactSql +
            "  FROM match_ctx mc "
            "  JOIN player_rsvp_eligibility ple "
            "    ON ple.team_id = mc.home_team_id "
            "  JOIN external_person_aliases epa "
            "    ON epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = ple.leagueapps_user_id::text "
            "  JOIN persons p ON p.id = epa.person_id "
            "  LEFT JOIN players pl ON pl.person_id = p.id "
            "  LEFT JOIN LATERAL ( "
            "    SELECT rsvp_status_id "
            "      FROM player_rsvp_history hh "
            "     WHERE hh.event_id  = mc.match_id "
            "       AND hh.player_id = pl.id "
            "     ORDER BY hh.changed_at DESC "
            "     LIMIT 1 "
            "  ) h ON true "
            " WHERE h.rsvp_status_id IS NULL "
            // Paused-membership filter (user directive 2026-07-06): people
            // whose ONLY active LA membership is in a `variant='paused'`
            // program are members-in-name-only — they can still RSVP via
            // /#my but should NOT clutter reminder lists.  We're only
            // nudging active members.  Anti-join mirrors LaPool.cpp +
            // Team.cpp::getTeamRoster.
            "   AND NOT EXISTS ( "
            "     SELECT 1 FROM person_la_memberships plm "
            "       JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "      WHERE plm.person_id = p.id "
            "        AND plm.ended_at IS NULL "
            "        AND lp.variant   = 'paused' "
            "   ) "
            " ORDER BY p.last_name, p.first_name";
        auto rows = db->query(sql, {std::to_string(matchId)});

        // 3) Send loop — rate-limit + insert + build URLs.
        json recipients = json::array();
        int sent = 0;
        int skippedRateLimited = 0;
        int skippedNoContact   = 0;

        for (const auto& r : rows) {
            const long long personId = r["person_id"].as<long long>();
            const long long playerId = r["player_id"].is_null()
                                       ? 0LL
                                       : r["player_id"].as<long long>();

            if (!filterPersonIds.empty() && !filterPersonIds.count(personId)) {
                continue;
            }
            if (!filterPlayerIds.empty() &&
                (playerId == 0 || !filterPlayerIds.count(playerId))) {
                continue;
            }
            if (r["contact"].is_null()) {
                ++skippedNoContact;
                continue;
            }

            // Rate-limit: any row in the last kRateLimitWindowSeconds?
            auto rl = db->query(
                "SELECT 1 FROM player_event_reminders "
                " WHERE match_id  = $1::int "
                "   AND person_id = $2::int "
                "   AND sent_at   > NOW() - ($3 || ' seconds')::interval "
                " LIMIT 1",
                {std::to_string(matchId),
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
                    "  (match_id, person_id, channel, magic_token, sent_by) "
                    "VALUES ($1::int, $2::int, $3, $4, NULLIF($5, '')::int)",
                    {std::to_string(matchId),
                     std::to_string(personId),
                     channel,
                     hash,
                     senderUserId});
            } catch (const std::exception& e) {
                // Any DB-side failure (unique violation, FK, etc.) — log
                // and skip so the rest of the batch still goes out.
                std::cerr << "[reminders] insert failed for person "
                          << personId << ": " << e.what() << std::endl;
                continue;
            }

            const std::string verifyUrl = publicBaseUrl()
                                        + "/api/reminders/verify?token="
                                        + fh::crypto::urlEncode(raw);

            // Message copy — kept short enough to stay in a single SMS
            // segment for the common case.  Non-responders only ("maybe"
            // was deprecated 2026-07-10; only people with no RSVP row
            // reach this loop).
            //   "Hi X, RSVP for <title> <date> <time>: <url>"
            // RSVP is club policy for every event; both the plain body
            // (mens-events-reminders.js) and this magic-link body call
            // it out so the tone is consistent no matter which of the
            // four buttons the coach taps.
            std::ostringstream smsBody;
            smsBody << "Hi " << firstName << ", RSVP for ";
            if (!matchTitle.empty()) smsBody << matchTitle << " ";
            if (!dateStr.empty())    smsBody << dateStr;
            if (!timeStr.empty())    smsBody << " " << timeStr;
            smsBody << ": " << verifyUrl
                    << " (RSVP required for every event so we can plan)";

            std::ostringstream emailBody;
            emailBody << "Hi " << firstName << ",\n\n"
                      << "Please RSVP for ";
            if (!matchTitle.empty()) emailBody << matchTitle;
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
                + (matchTitle.empty() ? "" : (" for " + matchTitle));

            json rec = {
                {"person_id",  personId},
                {"player_id",  playerId},
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
            {"match_id",             matchId},
            {"channel",              channel},
            {"sent",                 sent},
            {"skipped_rate_limited", skippedRateLimited},
            {"skipped_no_contact",   skippedNoContact},
            {"recipients",           recipients},
        });
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/matches/:id/remind] " << e.what() << std::endl;
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
            "SELECT id, match_id, person_id, delivered_at, "
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

        const std::string target = publicBaseUrl() + "/#my";

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
// Returns the full RSVP picture for every mens event in the next
// `days` days (default 7, capped at 30) — one row per event with a
// nested `players` array containing every roster-eligible player and
// their most recent RSVP status.  Powers the horizontal event-columns
// "Mens Reminders" screen.
//
// Response shape:
//   {
//     "week_start": "2026-07-06",
//     "week_end":   "2026-07-12",
//     "events": [
//       {
//         "match_id": 456, "chat_event_id": 789 | null,
//         "title": "APSL vs FC Delco", "type": "league",
//         "match_type_id": 1, "home_team_id": 35,
//         "home_team_name": "APSL", "away_team_name": "FC Delco",
//         "match_date": "2026-07-08", "match_time": "20:00:00",
//         "date_str": "Wed, Jul 8", "time_str": "8:00 PM",
//         "venue_name": "Barrett Park",
//         "players": [
//           { "person_id":1234, "player_id":5678,
//             "first_name":"Jim", "last_name":"Breslin",
//             "email":"j@x", "phone":"+12155551234",
//             "sms_capable":true,
//             "rsvp_status": "yes" | "no" | null }
//         ]
//       }, ...
//     ]
//   }
//
// Eligibility rules mirror EventReminderController::handleSendReminders
// and MyController::handleGetWeek exactly — DO NOT drift.
Response EventReminderController::handleGetMensWeek(const Request& request, const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laGet(); handler reads DB only.
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }

    // Parse ?days= (bounded).  Default 7.  Cap at 30 so an accidental
    // /week-availability?days=9999 can't scan the whole schedule.
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
        // 1) Event metadata for the window — mens teams only, uncancelled,
        //    match_date in [today, today + days).
        //
        //    "mens" = home team gender_category='mens'.  This grabs the
        //    game teams (APSL/Liga1/Liga2/U23) and the pool teams for
        //    shared practice/pickup (908/909).
        //
        //    chat_event_id is joined in as a subquery so a match without
        //    a materialized chat_event row still comes back (chat_event_id
        //    just goes NULL and the frontend falls back to /#my).
        auto events = db->query(
            "SELECT m.id AS match_id, "
            "       COALESCE(NULLIF(m.title,''), "
            "                CONCAT(COALESCE(ht.name,'TBD'),' vs ',COALESCE(awt.name,'TBD'))) AS title, "
            "       COALESCE(mt.name,'') AS type, "
            "       COALESCE(m.match_type_id, 0) AS match_type_id, "
            "       m.home_team_id, "
            "       m.match_date::text AS match_date, "
            "       COALESCE(TO_CHAR(m.match_time, 'HH24:MI:SS'),'') AS match_time, "
            "       TO_CHAR(m.match_date, 'Dy, Mon FMDD') AS date_str, "
            "       COALESCE(TO_CHAR(m.match_time, 'FMHH12:MI AM'),'') AS time_str, "
            "       COALESCE(ht.name,'') AS home_team_name, "
            "       COALESCE(awt.name,'') AS away_team_name, "
            "       COALESCE(v.name,'')  AS venue_name, "
            "       (SELECT ce.id FROM chat_events ce "
            "         WHERE ce.match_id = m.id "
            "         ORDER BY ce.id ASC LIMIT 1) AS chat_event_id "
            "  FROM matches m "
            "  JOIN teams ht ON ht.id = m.home_team_id "
            "  LEFT JOIN teams awt ON awt.id = m.away_team_id "
            "  LEFT JOIN match_types mt ON mt.id = m.match_type_id "
            "  LEFT JOIN venues v ON v.id = m.venue_id "
            " WHERE ht.gender_category = 'mens' "
            "   AND m.cancelled_at IS NULL "
            "   AND m.match_date >= (NOW() AT TIME ZONE 'America/New_York')::date "
            "   AND m.match_date <  (NOW() AT TIME ZONE 'America/New_York')::date "
            "                         + ($1 || ' days')::interval "
            " ORDER BY m.match_date ASC, m.match_time ASC NULLS LAST",
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
            const long long matchId      = e["match_id"].as<long long>();
            const long long matchTypeId  = e["match_type_id"].as<long long>();

            // 2) Roster-eligible players + latest RSVP for this event.
            //    Same eligibility as /remind (practice/game/pickup rules)
            //    but WITHOUT the "no RSVP row" filter — we want the full
            //    picture so the front-end can bucket into Going / Can't /
            //    No response.  ("maybe" was deprecated 2026-07-10.)
            //
            //    LEFT JOIN LATERAL picks the most recent player_rsvp_history
            //    row per (event, player) — matches MyController's /my/week.
            auto players = db->query(
                "SELECT DISTINCT p.id AS person_id, pl.id AS player_id, "
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
                "       rs.name AS rsvp_status, "
                // is_pickup_only: TRUE when this person has NO active
                // roster_assignments row on any mens-selection team
                // (APSL 35, Liga 1 120, Liga 2 121, LL 122).  Powers the frontend
                // split for pickup events: regular members render in the
                // main Going/Can't/No-response sections, pickup-only
                // members render in a collapsed "PICKUP ONLY" section at
                // the bottom of the column so they don't clutter the
                // coach's "who to nudge" view (user directive 2026-07-07).
                "       NOT EXISTS ( "
                "         SELECT 1 FROM roster_assignments ra_sel "
                "          WHERE ra_sel.domain              = 'mens' "
                "            AND ra_sel.removed_at          IS NULL "
                "            AND ra_sel.leagueapps_user_id  = ple.leagueapps_user_id "
                "            AND ra_sel.team_id             IN (35, 120, 121, 122) "
                "       ) AS is_pickup_only, "
                // home_team_id + short label (user directive 2026-07-07)
                // — powers the "RSVP breakdown" chips on each event card
                // ("APSL 5 · L1 3 · L2 6 · Adult 2").  Prefer the lowest
                // team_id when a player is on more than one (in practice
                // the mutex partial index prevents that anyway).
                "       ht.team_id AS home_team_id, "
                "       CASE ht.team_id "
                "         WHEN 35  THEN 'APSL' "
                "         WHEN 120 THEN 'L1' "
                "         WHEN 121 THEN 'L2' "
                "         WHEN 122 THEN 'Adult' "
                "         ELSE NULL END AS home_team_short "
                "  FROM player_rsvp_eligibility ple "
                "  JOIN external_person_aliases epa "
                "    ON epa.provider = 'leagueapps' "
                "   AND epa.external_user_id = ple.leagueapps_user_id::text "
                "  JOIN persons p ON p.id = epa.person_id "
                "  LEFT JOIN players pl ON pl.person_id = p.id "
                "  LEFT JOIN LATERAL ( "
                "     SELECT ra.team_id "
                "       FROM roster_assignments ra "
                "      WHERE ra.leagueapps_user_id = ple.leagueapps_user_id "
                "        AND ra.domain = 'mens' "
                "        AND ra.removed_at IS NULL "
                "        AND ra.team_id IN (35, 120, 121, 122) "
                "      ORDER BY ra.team_id LIMIT 1 "
                "  ) ht ON true "
                "  LEFT JOIN LATERAL ( "
                "     SELECT h.rsvp_status_id "
                "       FROM player_rsvp_history h "
                "      WHERE h.event_id  = $1::int "
                "        AND h.player_id = pl.id "
                "      ORDER BY h.changed_at DESC LIMIT 1 "
                "  ) latest ON true "
                "  LEFT JOIN rsvp_statuses rs ON rs.id = latest.rsvp_status_id "
                // Eligibility (migration 107): the responder has a
                // player_rsvp_eligibility grant for the match's
                // home_team_id.  $2 is the match's home_team_id.
                " WHERE ple.team_id = $2::int "
                // Paused-membership filter (user directive 2026-07-06):
                // hide members-in-name-only from the coach reminders
                // board.  They can still self-serve at /#my; we just
                // don't want them cluttering the "who to nudge" view.
                "   AND NOT EXISTS ( "
                "     SELECT 1 FROM person_la_memberships plm "
                "       JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
                "      WHERE plm.person_id = p.id "
                "        AND plm.ended_at IS NULL "
                "        AND lp.variant   = 'paused' "
                "   ) "
                " ORDER BY p.last_name, p.first_name",
                {std::to_string(matchId),
                 e["home_team_id"].is_null() ? std::string("0")
                                             : std::to_string(e["home_team_id"].as<long long>())});

            json plist = json::array();
            for (const auto& r : players) {
                json rec = {
                    {"person_id",  r["person_id"].as<long long>()},
                    {"player_id",  r["player_id"].is_null() ? json(nullptr)
                                                            : json(r["player_id"].as<long long>())},
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

            json ev = {
                {"match_id",       matchId},
                {"chat_event_id",  e["chat_event_id"].is_null() ? json(nullptr)
                                                                : json(e["chat_event_id"].as<long long>())},
                {"title",          e["title"].is_null() ? "" : e["title"].as<std::string>()},
                {"type",           e["type"].is_null() ? "" : e["type"].as<std::string>()},
                {"match_type_id",  matchTypeId},
                {"home_team_id",   e["home_team_id"].is_null() ? json(nullptr)
                                                               : json(e["home_team_id"].as<long long>())},
                {"home_team_name", e["home_team_name"].is_null() ? "" : e["home_team_name"].as<std::string>()},
                {"away_team_name", e["away_team_name"].is_null() ? "" : e["away_team_name"].as<std::string>()},
                {"match_date",     e["match_date"].is_null() ? "" : e["match_date"].as<std::string>()},
                {"match_time",     e["match_time"].is_null() ? "" : e["match_time"].as<std::string>()},
                {"date_str",       e["date_str"].is_null() ? "" : e["date_str"].as<std::string>()},
                {"time_str",       e["time_str"].is_null() ? "" : e["time_str"].as<std::string>()},
                {"venue_name",     e["venue_name"].is_null() ? "" : e["venue_name"].as<std::string>()},
                {"players",        std::move(plist)},
            };
            evList.push_back(std::move(ev));
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
