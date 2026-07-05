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
    // prefix is "/api".  Two endpoints:
    //   POST /api/matches/:matchId/remind   (coach)
    //   GET  /api/reminders/verify          (public)
    router.post(prefix + "/matches/:matchId/remind",
                [this](const Request& r) { return handleSendReminders(r); });
    router.get (prefix + "/reminders/verify",
                [this](const Request& r) { return handleVerify(r); });
}

// ---------------------------------------------------------------------
// POST /api/matches/:matchId/remind
// ---------------------------------------------------------------------
Response EventReminderController::handleSendReminders(const Request& request) {
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

        // Non-responder = no player_rsvp_history row for this match
        // (any status).  A row with status "yes"/"no"/"maybe" counts
        // as responded — same rule as the /my/week UI.
        const std::string sql =
            "WITH match_ctx AS ( "
            "  SELECT id AS match_id, home_team_id FROM matches WHERE id = $1::int "
            ") "
            "SELECT p.id AS person_id, pl.id AS player_id, "
            "       p.first_name, p.last_name, "
            + contactSql +
            "  FROM match_ctx mc "
            "  JOIN mens_team_assignments mta ON mta.team_id = mc.home_team_id "
            "                                AND mta.removed_at IS NULL "
            "  JOIN external_person_aliases epa "
            "    ON epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = mta.leagueapps_user_id::text "
            "  JOIN persons p ON p.id = epa.person_id "
            "  LEFT JOIN players pl ON pl.person_id = p.id "
            "  LEFT JOIN player_rsvp_history h "
            "    ON h.event_id  = mc.match_id "
            "   AND h.player_id = pl.id "
            " WHERE h.id IS NULL "
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
            // segment for the common case ("Hi X, RSVP for <title>
            // <date> <time>: <url>").
            std::ostringstream smsBody;
            smsBody << "Hi " << firstName << ", RSVP for ";
            if (!matchTitle.empty()) smsBody << matchTitle << " ";
            if (!dateStr.empty())    smsBody << dateStr;
            if (!timeStr.empty())    smsBody << " " << timeStr;
            smsBody << ": " << verifyUrl;

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
                      << "This link signs you in automatically and expires in 48 hours.\n\n"
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
