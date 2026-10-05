#include "OpponentsController.h"

#include <iostream>
#include <regex>
#include <ctime>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../models/WelcomeLog.h"
#include "../services/LeagueFixtureSync.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        if (!body->is_object()) *body = json::object();
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}
std::string s(const json& b, const char* k) {
    if (!b.contains(k) || b[k].is_null()) return {};
    if (b[k].is_string()) { std::string v = b[k].get<std::string>(); while (!v.empty() && std::isspace((unsigned char)v.back())) v.pop_back(); while (!v.empty() && std::isspace((unsigned char)v.front())) v.erase(v.begin()); return v; }
    return b[k].dump();
}
long long n(const json& b, const char* k) {
    if (!b.contains(k) || b[k].is_null()) return 0;
    if (b[k].is_number()) return b[k].get<long long>();
    if (b[k].is_string()) { try { return std::stoll(b[k].get<std::string>()); } catch (...) {} }
    return 0;
}
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
json nul(const pqxx::row& r, const char* c) { return r[c].is_null() ? json(nullptr) : json(std::string(r[c].c_str())); }

json contactJson(const pqxx::row& r) {
    return {{"id", r["id"].as<long long>()}, {"club_id", r["club_id"].as<long long>()},
            {"competition_id", r["competition_id"].is_null() ? json(nullptr) : json(r["competition_id"].as<long long>())},
            {"name", nul(r, "name")}, {"role", nul(r, "role")}, {"phone", nul(r, "phone")}, {"email", nul(r, "email")},
            {"note", nul(r, "note")}, {"source", nul(r, "source")},
            {"last_sent_at", nul(r, "last_sent_at")}, {"last_channel", nul(r, "last_channel")}};
}

const char* kContactsSql =
    "SELECT c.id, c.club_id, c.competition_id, c.name, c.role, c.phone, c.email, c.note, c.source, "
    "       (SELECT to_char(MAX(m.sent_at) AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') FROM club_contact_messages m WHERE m.contact_id = c.id) AS last_sent_at, "
    "       (SELECT m.channel FROM club_contact_messages m WHERE m.contact_id = c.id ORDER BY m.sent_at DESC LIMIT 1) AS last_channel "
    "  FROM club_contacts c WHERE c.is_active ";

json tiers(const std::string& kind = "opponent") {
    json out = json::array();
    auto rows = Database::getInstance()->query(
        "SELECT tier, label FROM message_templates WHERE kind = $1 AND is_active AND subject IS NOT NULL ORDER BY sort_order, id", {kind});
    for (const auto& r : rows) {
        std::string label = str(r, "label");
        auto dash = label.find(" — ");
        if (dash != std::string::npos) label = label.substr(dash + 5);
        auto colon = label.find(": ");
        if (colon != std::string::npos) label = label.substr(colon + 2);
        out.push_back({{"tier", str(r, "tier")}, {"label", label}});
    }
    return out;
}

// leagues row for a label on club_competitions ('CASA' → CASA Select).
json leagueFor(const std::string& label) {
    auto rows = Database::getInstance()->query(
        "SELECT l.id, l.name, COALESCE(l.website_url,'') AS website_url, COALESCE(l.correspondence_email,'') AS correspondence_email "
        "  FROM leagues l WHERE l.id = (SELECT MIN(league_id) FROM club_competitions WHERE league_label = $1 AND league_id IS NOT NULL) "
        "     OR (LOWER(l.name) LIKE LOWER($1) || '%' AND NOT EXISTS (SELECT 1 FROM club_competitions WHERE league_label = $1 AND league_id IS NOT NULL)) "
        " ORDER BY l.id LIMIT 1", {label});
    if (rows.empty()) return {{"id", 0}, {"name", label}, {"website_url", ""}, {"correspondence_email", ""}};
    const auto& r = rows[0];
    return {{"id", r["id"].as<long long>()}, {"name", str(r, "name")}, {"website_url", str(r, "website_url")}, {"correspondence_email", str(r, "correspondence_email")}};
}

std::string senderName(long long userId) {
    std::string sender;
    if (userId > 0) {
        auto u = Database::getInstance()->query("SELECT COALESCE(p.first_name,'') || CASE WHEN p.last_name IS NULL THEN '' ELSE ' ' || p.last_name END AS nm FROM users us JOIN persons p ON p.id = us.person_id WHERE us.id = $1::int", {std::to_string(userId)});
        if (!u.empty()) sender = str(u[0], "nm");
    }
    return sender;
}

// The opponent club of a match: the other team's clubs row, else the
// calendar's opponent text through club_aliases / clubs.name (the same
// chain the crests use, EventController).  Returns 0 when unmatched.
struct MatchInfo { long long id = 0; long long clubId = 0; std::string opponentText, date, time, venue, ourTeam; bool isHome = true; long long homeTeamId = 0, awayTeamId = 0; };
bool loadMatch(long long matchId, MatchInfo* mi) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT m.id, m.home_team_id, m.away_team_id, ht.name AS home_name, awt.name AS away_name,
               ht.club_id AS home_club, awt.club_id AS away_club,
               fe.opponent, fe.is_home,
               to_char(m.match_date, 'Dy Mon FMDD') AS date_label,
               to_char(COALESCE(fe.kickoff_at AT TIME ZONE 'America/New_York', (m.match_date + COALESCE(m.match_time,'00:00'::time))), 'FMHH12:MI AM') AS time_label,
               COALESCE(v.name, '') AS venue
          FROM matches m
          LEFT JOIN teams ht ON ht.id = m.home_team_id
          LEFT JOIN teams awt ON awt.id = m.away_team_id
          LEFT JOIN fh_events fe ON fe.match_id = m.id
          LEFT JOIN venues v ON v.id = m.venue_id
         WHERE m.id = $1::int LIMIT 1)SQL", {std::to_string(matchId)});
    if (rows.empty()) return false;
    const auto& r = rows[0];
    mi->id = matchId;
    mi->homeTeamId = r["home_team_id"].is_null() ? 0 : r["home_team_id"].as<long long>();
    mi->awayTeamId = r["away_team_id"].is_null() ? 0 : r["away_team_id"].as<long long>();
    const long long ours = WelcomeLog::kLighthouseClubId;
    const long long homeClub = r["home_club"].is_null() ? 0 : r["home_club"].as<long long>();
    const long long awayClub = r["away_club"].is_null() ? 0 : r["away_club"].as<long long>();
    mi->date = str(r, "date_label"); mi->time = str(r, "time_label"); mi->venue = str(r, "venue");
    if (!r["is_home"].is_null()) mi->isHome = r["is_home"].as<bool>();
    else if (awayClub == ours && homeClub != ours) mi->isHome = false;
    mi->ourTeam = mi->isHome ? str(r, "home_name") : str(r, "away_name");
    if (homeClub && homeClub != ours) { mi->clubId = homeClub; mi->opponentText = str(r, "home_name"); }
    else if (awayClub && awayClub != ours) { mi->clubId = awayClub; mi->opponentText = str(r, "away_name"); }
    if (!mi->clubId) {
        mi->opponentText = str(r, "opponent");
        if (mi->opponentText.empty()) mi->opponentText = mi->isHome ? str(r, "away_name") : str(r, "home_name");
        if (!mi->opponentText.empty()) {
            auto c = Database::getInstance()->query(
                "SELECT COALESCE((SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM($1)) LIMIT 1), "
                "                (SELECT id FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM($1)) ORDER BY id LIMIT 1), 0) AS cid",
                {mi->opponentText});
            if (!c.empty()) mi->clubId = c[0]["cid"].as<long long>();
        }
    }
    return true;
}

json clubJson(long long clubId) {
    auto rows = Database::getInstance()->query(
        "SELECT c.id, c.name, COALESCE(c.logo_url,'') AS logo_url FROM clubs c WHERE c.id = $1::int", {std::to_string(clubId)});
    if (rows.empty()) return nullptr;
    json out = {{"id", clubId}, {"name", str(rows[0], "name")}, {"logo_url", str(rows[0], "logo_url")}, {"contacts", json::array()}, {"competitions", json::array()}};
    for (const auto& r : Database::getInstance()->query(std::string(kContactsSql) + " AND c.club_id = $1::int ORDER BY c.competition_id NULLS FIRST, c.id", {std::to_string(clubId)}))
        out["contacts"].push_back(contactJson(r));
    for (const auto& r : Database::getInstance()->query(
            "SELECT id, league_label, division_label, season, status, lead_name, last_contacted, notes, home_field, external_url "
            "  FROM club_competitions WHERE club_id = $1::int ORDER BY season DESC, league_label, division_label", {std::to_string(clubId)}))
        out["competitions"].push_back({{"id", r["id"].as<long long>()}, {"league_label", str(r, "league_label")}, {"division_label", str(r, "division_label")},
                                       {"season", str(r, "season")}, {"status", str(r, "status")}, {"lead_name", nul(r, "lead_name")},
                                       {"last_contacted", nul(r, "last_contacted")}, {"notes", nul(r, "notes")}, {"home_field", nul(r, "home_field")}, {"external_url", nul(r, "external_url")}});
    return out;
}

// ─── league fixtures (mig 488) ──────────────────────────────────────────────
// The sources of one league label with their last-pull state.  `pulls` is
// what LeagueFixtureSync::refreshLeague just returned, so "fresh" means this
// very request got the feed.
json fixturesSummary(const std::string& label, const json& pulls) {
    json out = {{"n", 0}, {"last_fetched_at", nullptr}, {"fresh", false}, {"note", ""}, {"sources", json::array()}};
    long long n = 0; bool anyFresh = false;
    for (const auto& r : Database::getInstance()->query(R"SQL(
        SELECT s.id, s.season, s.program_id, COALESCE(s.label,'') AS label, s.last_fetch_ok, COALESCE(s.last_fetch_note,'') AS note,
               to_char(s.last_fetched_at AT TIME ZONE 'America/New_York', 'Mon FMDD, FMHH12:MI AM') AS fetched_label,
               (SELECT COUNT(*) FROM league_fixtures f WHERE f.source_id = s.id AND f.removed_at IS NULL) AS n
          FROM league_fixture_sources s WHERE s.league_label = $1 AND s.is_active ORDER BY s.season DESC, s.id)SQL", {label})) {
        const long long id = r["id"].as<long long>();
        bool fresh = false;
        for (const auto& p : pulls) if (p.value("source_id", 0LL) == id && p.value("ok", false)) fresh = true;
        anyFresh = anyFresh || fresh; n += r["n"].as<long long>();
        out["sources"].push_back({{"id", id}, {"season", str(r, "season")}, {"program_id", str(r, "program_id")}, {"label", str(r, "label")},
                                  {"last_fetch_ok", r["last_fetch_ok"].is_null() ? json(nullptr) : json(r["last_fetch_ok"].as<bool>())},
                                  {"note", str(r, "note")}, {"last_fetched_at", nul(r, "fetched_label")}, {"fresh", fresh}, {"n", r["n"].as<long long>()}});
        if (out["last_fetched_at"].is_null()) { out["last_fetched_at"] = nul(r, "fetched_label"); out["note"] = str(r, "note"); }
    }
    out["n"] = n; out["fresh"] = anyFresh;
    return out;
}

} // namespace

OpponentsController::OpponentsController() = default;
OpponentsController::~OpponentsController() = default;

void OpponentsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get   (prefix + "/board",              [this](const Request& r) { return handleBoard(r); });
    router.post  (prefix + "/contact",            [this](const Request& r) { return handleContact(r); });
    router.del   (prefix + "/contact",            [this](const Request& r) { return handleDeleteContact(r); });
    router.post  (prefix + "/competition",        [this](const Request& r) { return handleCompetition(r); });
    router.post  (prefix + "/alias",              [this](const Request& r) { return handleAlias(r); });
    router.post  (prefix + "/message",            [this](const Request& r) { return handleMessage(r); });
    router.get   (prefix + "/league",             [this](const Request& r) { return handleLeague(r); });
    router.post  (prefix + "/group-message",      [this](const Request& r) { return handleGroupMessage(r); });
    router.get   (prefix + "/league-fixtures",    [this](const Request& r) { return handleLeagueFixtures(r); });
    router.get   (prefix + "/league-scores",      [this](const Request& r) { return handleLeagueScores(r); });
    router.post  (prefix + "/score-request",      [this](const Request& r) { return handleScoreRequest(r); });
    router.post  (prefix + "/score-contact",      [this](const Request& r) { return handleScoreContact(r); });
    router.get   (prefix + "/for-match/:matchId", [this](const Request& r) { return handleForMatch(r); });
}

bool OpponentsController::adminGate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super", "marketing"})) return true;
    *error = jsonError(denialStatus(request), "Opponent contacts are for club admins.");
    return false;
}

bool OpponentsController::matchGate(const Request& request, long long matchId, Response* error) {
    if (requireAdminLevel(request, {"club", "super", "marketing"})) return true;
    MatchInfo mi;
    if (loadMatch(matchId, &mi) && ((mi.homeTeamId && canManageTeam(request, (int)mi.homeTeamId)) || (mi.awayTeamId && canManageTeam(request, (int)mi.awayTeamId)))) return true;
    *error = jsonError(denialStatus(request), "Only the coaches of this game can contact the opponent.");
    return false;
}

Response OpponentsController::handleBoard(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    try {
        auto* db = Database::getInstance();
        json out = {{"competitions", json::array()}, {"contacts", json::array()}, {"tiers", tiers()}, {"leagues", json::array()}};
        for (const auto& r : db->query(R"SQL(
            SELECT k.id, k.club_id, c.name AS club_name, COALESCE(c.logo_url,'') AS logo_url, k.league_id, k.league_label, k.division_label,
                   k.season, k.status, k.lead_name, k.last_contacted, k.notes, k.home_field, k.external_url,
                   (SELECT to_char(MAX(m.sent_at) AT TIME ZONE 'America/New_York', 'Mon DD') FROM club_contact_messages m WHERE m.club_id = k.club_id) AS last_sent
              FROM club_competitions k JOIN clubs c ON c.id = k.club_id
             ORDER BY k.season DESC, k.league_label, k.division_label, c.name)SQL"))
            out["competitions"].push_back({{"id", r["id"].as<long long>()}, {"club_id", r["club_id"].as<long long>()}, {"club_name", str(r, "club_name")},
                                           {"logo_url", str(r, "logo_url")}, {"league_label", str(r, "league_label")}, {"division_label", str(r, "division_label")},
                                           {"season", str(r, "season")}, {"status", str(r, "status")}, {"lead_name", nul(r, "lead_name")},
                                           {"last_contacted", nul(r, "last_contacted")}, {"notes", nul(r, "notes")}, {"home_field", nul(r, "home_field")},
                                           {"external_url", nul(r, "external_url")}, {"last_sent", nul(r, "last_sent")}});
        for (const auto& r : db->query(std::string(kContactsSql) + " ORDER BY c.club_id, c.competition_id NULLS FIRST, c.id"))
            out["contacts"].push_back(contactJson(r));
        for (const auto& r : db->query("SELECT id, name FROM leagues WHERE is_active ORDER BY name"))
            out["leagues"].push_back({{"id", r["id"].as<long long>()}, {"name", str(r, "name")}});
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents board] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response OpponentsController::handleForMatch(const Request& request) {
    long long matchId = 0;
    { std::smatch m; static const std::regex re("/for-match/(\\d+)"); const std::string& p = request.getPath();
      if (std::regex_search(p, m, re)) matchId = std::stoll(m[1].str()); }
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "bad match id");
    Response denied; if (!matchGate(request, matchId, &denied)) return denied;
    try {
        MatchInfo mi;
        if (!loadMatch(matchId, &mi)) return jsonError(HttpStatus::NOT_FOUND, "no such match");
        json out = {{"match_id", matchId}, {"opponent_text", mi.opponentText}, {"is_home", mi.isHome}, {"date", mi.date}, {"time", mi.time},
                    {"venue", mi.venue}, {"our_team", mi.ourTeam}, {"club", nullptr}, {"tiers", tiers()}};
        if (mi.clubId) out["club"] = clubJson(mi.clubId);
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents for-match] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response OpponentsController::handleContact(const Request& request) {
    json b; Response err;
    if (!parseBody(request, &b, &err)) return err;
    const long long matchId = n(b, "match_id");
    if (matchId) { if (!matchGate(request, matchId, &err)) return err; }
    else if (!adminGate(request, &err)) return err;
    const long long id = n(b, "id"), clubId = n(b, "club_id"), compId = n(b, "competition_id");
    const std::string name = s(b, "name"), role = s(b, "role"), phone = s(b, "phone"), email = s(b, "email"), note = s(b, "note");
    if (!clubId && !id) return jsonError(HttpStatus::BAD_REQUEST, "club_id required");
    if (name.empty() && phone.empty() && email.empty()) return jsonError(HttpStatus::BAD_REQUEST, "a name, phone or email is required");
    if (!email.empty() && email.find('@') == std::string::npos) return jsonError(HttpStatus::BAD_REQUEST, "that email has no @");
    try {
        auto* db = Database::getInstance();
        pqxx::result r;
        if (id) r = db->query("UPDATE club_contacts SET name = NULLIF($2,''), role = NULLIF($3,''), phone = NULLIF($4,''), email = NULLIF(LOWER($5),''), note = NULLIF($6,''), "
                              "  competition_id = NULLIF($7,'0')::int, updated_at = now() WHERE id = $1::int RETURNING id",
                              {std::to_string(id), name, role, phone, email, note, std::to_string(compId)});
        else r = db->query("INSERT INTO club_contacts (club_id, competition_id, name, role, phone, email, note, source) "
                           "VALUES ($1::int, NULLIF($2,'0')::int, NULLIF($3,''), NULLIF($4,''), NULLIF($5,''), NULLIF(LOWER($6),''), NULLIF($7,''), 'manual') RETURNING id",
                           {std::to_string(clubId), std::to_string(compId), name, role, phone, email, note});
        if (r.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such contact");
        return jsonOut(HttpStatus::OK, {{"id", r[0]["id"].as<long long>()}});
    } catch (const std::exception& e) { std::cerr << "[opponents contact] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response OpponentsController::handleDeleteContact(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    long long id = 0; try { id = std::stoll(request.getQueryParam("id")); } catch (...) {}
    if (!id) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        Database::getInstance()->query("UPDATE club_contacts SET is_active = false, updated_at = now() WHERE id = $1::int", {std::to_string(id)});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response OpponentsController::handleCompetition(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    json b; Response err; if (!parseBody(request, &b, &err)) return err;
    try {
        auto* db = Database::getInstance();
        const long long id = n(b, "id");
        if (id) {
            // Only the keys present change; the page sends one field at a time.
            static const char* cols[] = {"lead_name", "last_contacted", "notes", "home_field", "status", "division_label", "league_label", "season"};
            for (const char* c : cols) if (b.contains(c)) {
                if (std::string(c) == "status" && s(b, c) != "opponent" && s(b, c) != "prospect" && s(b, c) != "inactive") return jsonError(HttpStatus::BAD_REQUEST, "bad status");
                db->query(std::string("UPDATE club_competitions SET ") + c + " = NULLIF($2,''), updated_at = now() WHERE id = $1::int", {std::to_string(id), s(b, c)});
            }
            return jsonOut(HttpStatus::OK, {{"id", id}});
        }
        long long clubId = n(b, "club_id");
        const std::string clubName = s(b, "club_name"), league = s(b, "league_label"), division = s(b, "division_label");
        std::string season = s(b, "season"); if (season.empty()) season = "2026/27";
        std::string status = s(b, "status"); if (status.empty()) status = "opponent";
        if (league.empty() || division.empty()) return jsonError(HttpStatus::BAD_REQUEST, "league and division are required");
        if (!clubId) {
            if (clubName.empty()) return jsonError(HttpStatus::BAD_REQUEST, "pick a club or type a new club name");
            auto ex = db->query("SELECT COALESCE((SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM($1)) LIMIT 1), "
                                "                (SELECT id FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM($1)) ORDER BY id LIMIT 1), 0) AS cid", {clubName});
            clubId = ex.empty() ? 0 : ex[0]["cid"].as<long long>();
            if (!clubId) clubId = db->query("INSERT INTO clubs (name, sport_id, is_active) VALUES (BTRIM($1), 1, true) RETURNING id", {clubName})[0]["id"].as<long long>();
        }
        long long lid = n(b, "league_id");
        auto r = db->query("INSERT INTO club_competitions (club_id, league_id, league_label, division_label, season, status) VALUES ($1::int, NULLIF($2,'0')::int, $3, $4, $5, $6) "
                           "ON CONFLICT (club_id, league_label, division_label, season) DO UPDATE SET status = EXCLUDED.status, updated_at = now() RETURNING id",
                           {std::to_string(clubId), std::to_string(lid), league, division, season, status});
        return jsonOut(HttpStatus::OK, {{"id", r[0]["id"].as<long long>()}, {"club_id", clubId}});
    } catch (const std::exception& e) { std::cerr << "[opponents competition] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response OpponentsController::handleAlias(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    json b; Response err; if (!parseBody(request, &b, &err)) return err;
    const long long clubId = n(b, "club_id"); const std::string alias = s(b, "alias");
    if (!clubId || alias.empty()) return jsonError(HttpStatus::BAD_REQUEST, "club_id and alias required");
    try {
        Database::getInstance()->query("INSERT INTO club_aliases (club_id, alias, notes) SELECT $1::int, BTRIM($2), 'opponents page' "
                                       "WHERE NOT EXISTS (SELECT 1 FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM($2)))", {std::to_string(clubId), alias});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// One tap: render the chosen template for this contact (and game, when sent
// from Game Center), log it, hand back the compose hrefs — the same shape
// /api/rsvp-board/remind returns, so the buttons behave identically.
Response OpponentsController::handleMessage(const Request& request) {
    json b; Response err; if (!parseBody(request, &b, &err)) return err;
    const long long contactId = n(b, "contact_id"), matchId = n(b, "match_id");
    const std::string channel = s(b, "channel"); std::string tier = s(b, "tier"); if (tier.empty()) tier = "general";
    std::string kind = s(b, "kind"); if (kind != "casa") kind = "opponent";
    const std::string leagueLabel = s(b, "league_label");
    if (!contactId || (channel != "email" && channel != "sms")) return jsonError(HttpStatus::BAD_REQUEST, "contact_id and channel (email|sms) required");
    if (matchId) { if (!matchGate(request, matchId, &err)) return err; }
    else if (!adminGate(request, &err)) return err;
    try {
        auto* db = Database::getInstance();
        auto rows = db->query("SELECT c.id, c.club_id, c.name, c.phone, c.email, k.name AS club_name FROM club_contacts c JOIN clubs k ON k.id = c.club_id WHERE c.id = $1::int AND c.is_active", {std::to_string(contactId)});
        if (rows.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such contact");
        const auto& c = rows[0];
        const std::string contact = channel == "email" ? str(c, "email") : str(c, "phone");
        if (contact.empty()) return jsonError(HttpStatus::BAD_REQUEST, channel == "email" ? "this contact has no email" : "this contact has no phone");
        MatchInfo mi; if (matchId) loadMatch(matchId, &mi);
        std::string first = str(c, "name"); if (auto sp = first.find(' '); sp != std::string::npos) first = first.substr(0, sp);
        if (first.empty()) first = "there";
        // Who is writing — the signed-in user.  From the commissioner section
        // the mail is composed as the league's address (leagues.correspondence_email).
        long long userId = bearerUserId(request); if (userId < 0) userId = 0;
        std::string sender = senderName(userId);
        json league = kind == "casa" ? leagueFor(leagueLabel.empty() ? "CASA" : leagueLabel) : json(nullptr);
        const std::string fromEmail = league.is_null() ? std::string() : league.value("correspondence_email", "");
        std::string division;
        if (!leagueLabel.empty()) {
            auto d = db->query("SELECT division_label FROM club_competitions WHERE club_id = $1::int AND league_label = $2 ORDER BY season DESC LIMIT 1", {std::to_string(c["club_id"].as<long long>()), leagueLabel});
            if (!d.empty()) division = str(d[0], "division_label");
        }
        MessageCopy copy;
        MessageCopy::Tokens tokens = {{"club", str(c, "club_name")}, {"contact_first", first}, {"our_team", mi.ourTeam.empty() ? "Lighthouse 1893 SC" : mi.ourTeam},
                                      {"date", mi.date.empty() ? "our next game" : mi.date}, {"time", mi.time.empty() ? "kick-off" : mi.time},
                                      {"venue", mi.venue.empty() ? "the field" : mi.venue}, {"home_away", mi.id ? (mi.isHome ? "vs" : "at") : "vs"},
                                      {"sender", sender.empty() ? "Lighthouse 1893 SC" : sender}, {"from_email", fromEmail},
                                      {"league", league.is_null() ? "" : league.value("name", "")}, {"division", division}};
        auto r = copy.render(kind, tier, tokens);
        if (!r.ok()) return jsonError(HttpStatus::BAD_REQUEST, "no message template '" + tier + "'");
        db->query("INSERT INTO club_contact_messages (club_id, contact_id, match_id, channel, contact, tier, sent_by_user_id, sender_email, league_label) "
                  "VALUES ($1::int, $2::int, NULLIF($3,'0')::int, $4, $5, $6, NULLIF($7,'0')::int, NULLIF($8,''), NULLIF($9,''))",
                  {std::to_string(c["club_id"].as<long long>()), std::to_string(contactId), std::to_string(matchId), channel, contact, tier, std::to_string(userId), fromEmail, leagueLabel});
        json out = {{"ok", true}, {"subject", r.subject}, {"body", r.body}, {"contact", contact}, {"from_email", fromEmail}};
        copy.addComposeHrefs(out, channel, contact, r.subject, r.body, r.body);
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents message] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// ─── the commissioner view of one league (mig 486) ──────────────────────────
Response OpponentsController::handleLeague(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    std::string label = request.getQueryParam("label"); if (label.empty()) label = "CASA";
    try {
        auto* db = Database::getInstance();
        // Every access to the section pulls the league's fixture feed first (mig 488).
        json pulls = LeagueFixtureSync::refreshLeague(label);
        json out = {{"league", leagueFor(label)}, {"label", label}, {"competitions", json::array()}, {"contacts", json::array()},
                    {"tiers", tiers("casa")}, {"our_links", json::array()}, {"recent", json::array()}, {"fixtures", fixturesSummary(label, pulls)}};
        // Played games still without a score — the count on the hub's "Scores to chase" tile (mig 520).
        out["fixtures"]["waiting"] = db->query(
            "SELECT COUNT(*) AS n FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id "
            " WHERE s.league_label = $1 AND s.is_active AND f.removed_at IS NULL AND s.score_due_after_minutes IS NOT NULL "
            "   AND f.starts_at + make_interval(mins => s.score_due_after_minutes) < now() "
            "   AND f.status NOT IN ('postponed', 'cancelled', 'canceled', 'forfeit') AND (f.home_score IS NULL OR f.away_score IS NULL)", {label})[0]["n"].as<long long>();
        for (const auto& r : db->query(R"SQL(
            SELECT k.id, k.club_id, c.name AS club_name, COALESCE(c.logo_url,'') AS logo_url, k.division_label, k.season, k.status,
                   k.lead_name, k.last_contacted, k.notes, k.home_field, k.external_url,
                   (SELECT to_char(MAX(m.sent_at) AT TIME ZONE 'America/New_York', 'Mon DD') FROM club_contact_messages m WHERE m.club_id = k.club_id AND m.league_label = k.league_label) AS last_sent
              FROM club_competitions k JOIN clubs c ON c.id = k.club_id
             WHERE k.league_label = $1 AND k.status = 'opponent'
             ORDER BY k.season DESC, k.division_label, c.name)SQL", {label}))
            out["competitions"].push_back({{"id", r["id"].as<long long>()}, {"club_id", r["club_id"].as<long long>()}, {"club_name", str(r, "club_name")},
                                           {"logo_url", str(r, "logo_url")}, {"division_label", str(r, "division_label")}, {"season", str(r, "season")},
                                           {"status", str(r, "status")}, {"lead_name", nul(r, "lead_name")}, {"last_contacted", nul(r, "last_contacted")},
                                           {"notes", nul(r, "notes")}, {"home_field", nul(r, "home_field")}, {"external_url", nul(r, "external_url")}, {"last_sent", nul(r, "last_sent")}});
        for (const auto& r : db->query(std::string(kContactsSql) +
                " AND c.club_id IN (SELECT club_id FROM club_competitions WHERE league_label = $1 AND status = 'opponent') ORDER BY c.club_id, c.competition_id NULLS FIRST, c.id", {label}))
            out["contacts"].push_back(contactJson(r));
        for (const auto& r : db->query(
                "SELECT t.name AS team, l.label, l.url FROM team_schedule_links l JOIN teams t ON t.id = l.team_id "
                " WHERE t.club_id = $1::int AND (l.label ILIKE '%' || $2 || '%' OR l.url ILIKE '%casasoccer%' OR l.url ILIKE '%season-microsites%') ORDER BY t.name, l.sort_order",
                {std::to_string((long long)WelcomeLog::kLighthouseClubId), label}))
            out["our_links"].push_back({{"team", str(r, "team")}, {"label", str(r, "label")}, {"url", str(r, "url")}});
        for (const auto& r : db->query(R"SQL(
            SELECT to_char(MAX(m.sent_at) AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') AS sent_at, m.tier, m.channel,
                   COALESCE(m.group_key, m.id::text) AS grp, COUNT(*) AS n, STRING_AGG(DISTINCT c.name, ', ' ORDER BY c.name) AS clubs
              FROM club_contact_messages m JOIN clubs c ON c.id = m.club_id
             WHERE m.league_label = $1
             GROUP BY COALESCE(m.group_key, m.id::text), m.tier, m.channel
             ORDER BY MAX(m.sent_at) DESC LIMIT 25)SQL", {label}))
            out["recent"].push_back({{"sent_at", str(r, "sent_at")}, {"tier", str(r, "tier")}, {"channel", str(r, "channel")}, {"n", r["n"].as<long long>()}, {"clubs", str(r, "clubs")}});
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents league] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// One BCC draft to every club in a division (or the whole league): the
// recipients are every active contact with an email in scope, de-duplicated.
// Logged one row per contact under a shared group_key; the client opens Gmail
// with the league address as authuser.
Response OpponentsController::handleGroupMessage(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    json b; Response err; if (!parseBody(request, &b, &err)) return err;
    std::string label = s(b, "league_label"); if (label.empty()) label = "CASA";
    const std::string division = s(b, "division_label");
    std::string tier = s(b, "tier"); if (tier.empty()) tier = "all_announcement";
    try {
        auto* db = Database::getInstance();
        long long userId = bearerUserId(request); if (userId < 0) userId = 0;
        const std::string sender = senderName(userId);
        json league = leagueFor(label);
        const std::string fromEmail = league.value("correspondence_email", "");
        MessageCopy copy;
        auto r = copy.render("casa", tier, {{"sender", sender.empty() ? "The commissioner" : sender}, {"from_email", fromEmail},
                                            {"league", league.value("name", "")}, {"division", division.empty() ? "Liga 1 & Liga 2" : division}});
        if (!r.ok()) return jsonError(HttpStatus::BAD_REQUEST, "no message template '" + tier + "'");
        auto rows = db->query(R"SQL(
            SELECT DISTINCT ON (LOWER(t.email)) t.id, t.club_id, LOWER(t.email) AS email
              FROM club_contacts t JOIN club_competitions k ON k.club_id = t.club_id AND (t.competition_id IS NULL OR t.competition_id = k.id)
             WHERE t.is_active AND t.email IS NOT NULL AND k.league_label = $1 AND k.status = 'opponent' AND ($2 = '' OR k.division_label = $2)
             ORDER BY LOWER(t.email), t.id)SQL", {label, division});
        auto scopeClubs = db->query("SELECT COUNT(*) AS n FROM club_competitions k WHERE k.league_label = $1 AND k.status = 'opponent' AND ($2 = '' OR k.division_label = $2)", {label, division});
        auto withEmail = db->query(R"SQL(
            SELECT COUNT(DISTINCT k.club_id) AS n FROM club_competitions k
             WHERE k.league_label = $1 AND k.status = 'opponent' AND ($2 = '' OR k.division_label = $2)
               AND EXISTS (SELECT 1 FROM club_contacts t WHERE t.club_id = k.club_id AND t.is_active AND t.email IS NOT NULL AND (t.competition_id IS NULL OR t.competition_id = k.id)))SQL", {label, division});
        const std::string groupKey = std::to_string(std::time(nullptr)) + "-" + std::to_string(userId);
        json contacts = json::array();
        for (const auto& c : rows) {
            contacts.push_back(str(c, "email"));
            db->query("INSERT INTO club_contact_messages (club_id, contact_id, channel, contact, tier, sent_by_user_id, sender_email, league_label, group_key) "
                      "VALUES ($1::int, $2::int, 'email', $3, $4, NULLIF($5,'0')::int, NULLIF($6,''), $7, $8)",
                      {std::to_string(c["club_id"].as<long long>()), std::to_string(c["id"].as<long long>()), str(c, "email"), tier, std::to_string(userId), fromEmail, label, groupKey});
        }
        const long long total = scopeClubs.empty() ? 0 : scopeClubs[0]["n"].as<long long>();
        const long long covered = withEmail.empty() ? 0 : withEmail[0]["n"].as<long long>();
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"subject", r.subject}, {"body", r.body}, {"contacts", contacts}, {"clubs", covered},
                                        {"skipped", total - covered}, {"from_email", fromEmail}, {"group_key", groupKey}});
    } catch (const std::exception& e) { std::cerr << "[opponents group-message] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// ─── every game of the league season (mig 488) ──────────────────────────────
Response OpponentsController::handleLeagueFixtures(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    std::string label = request.getQueryParam("label"); if (label.empty()) label = "CASA";
    try {
        auto* db = Database::getInstance();
        json pulls = LeagueFixtureSync::refreshLeague(label);
        json out = {{"league", leagueFor(label)}, {"label", label}, {"summary", fixturesSummary(label, pulls)},
                    {"divisions", json::array()}, {"fixtures", json::array()}, {"our_links", json::array()}, {"our_club_id", (long long)WelcomeLog::kLighthouseClubId}};
        for (const auto& r : db->query(R"SQL(
            SELECT f.id, f.division_label, f.status, f.home_name, f.away_name, f.home_club_id, f.away_club_id, f.home_score, f.away_score,
                   f.venue_name, f.venue_detail, f.venue_address, f.home_ext_team_id, f.away_ext_team_id, s.team_page_base,
                   COALESCE(hc.logo_url,'') AS home_logo, COALESCE(ac.logo_url,'') AS away_logo,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS date_key,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS date_label,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS time_label,
                   (f.starts_at < now()) AS past
              FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id
              LEFT JOIN clubs hc ON hc.id = f.home_club_id LEFT JOIN clubs ac ON ac.id = f.away_club_id
             WHERE s.league_label = $1 AND s.is_active AND f.removed_at IS NULL
             ORDER BY f.starts_at, f.division_label, f.id)SQL", {label})) {
            const std::string base = str(r, "team_page_base");
            const auto team = [&](const char* ext) { std::string e = str(r, ext); return base.empty() || e.empty() ? json(nullptr) : json(base + e); };
            out["fixtures"].push_back({{"id", r["id"].as<long long>()}, {"division_label", str(r, "division_label")}, {"status", str(r, "status")},
                                       {"home_name", str(r, "home_name")}, {"away_name", str(r, "away_name")},
                                       {"home_club_id", r["home_club_id"].is_null() ? json(nullptr) : json(r["home_club_id"].as<long long>())},
                                       {"away_club_id", r["away_club_id"].is_null() ? json(nullptr) : json(r["away_club_id"].as<long long>())},
                                       {"home_score", r["home_score"].is_null() ? json(nullptr) : json(r["home_score"].as<long long>())},
                                       {"away_score", r["away_score"].is_null() ? json(nullptr) : json(r["away_score"].as<long long>())},
                                       {"home_logo", str(r, "home_logo")}, {"away_logo", str(r, "away_logo")},
                                       {"home_url", team("home_ext_team_id")}, {"away_url", team("away_ext_team_id")},
                                       {"venue_name", nul(r, "venue_name")}, {"venue_detail", nul(r, "venue_detail")}, {"venue_address", nul(r, "venue_address")},
                                       {"date_key", str(r, "date_key")}, {"date_label", str(r, "date_label")}, {"time_label", str(r, "time_label")},
                                       {"past", r["past"].as<bool>()}});
        }
        for (const auto& r : db->query("SELECT DISTINCT f.division_label FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id "
                                       " WHERE s.league_label = $1 AND s.is_active AND f.removed_at IS NULL AND f.division_label IS NOT NULL ORDER BY 1", {label}))
            out["divisions"].push_back(str(r, "division_label"));
        for (const auto& r : db->query(
                "SELECT t.name AS team, l.label, l.url FROM team_schedule_links l JOIN teams t ON t.id = l.team_id "
                " WHERE t.club_id = $1::int AND (l.label ILIKE '%' || $2 || '%' OR l.url ILIKE '%casasoccer%' OR l.url ILIKE '%season-microsites%') ORDER BY t.name, l.sort_order",
                {std::to_string((long long)WelcomeLog::kLighthouseClubId), label}))
            out["our_links"].push_back({{"team", str(r, "team")}, {"label", str(r, "label")}, {"url", str(r, "url")}});
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents league-fixtures] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// ─── the score chase (mig 520) ──────────────────────────────────────────────
// Owner 2026-10-05: "every time i open results page … it should check casa
// website for scores as source of truth on what is in. then it should for
// each game have a text and email button to request the score from the
// manager".  The feed is pulled first; a game is "waiting" once it is
// score_due_after_minutes past kick-off with no score and not called off.
Response OpponentsController::handleLeagueScores(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    std::string label = request.getQueryParam("label"); if (label.empty()) label = "CASA";
    try {
        auto* db = Database::getInstance();
        json pulls = LeagueFixtureSync::refreshLeague(label);
        json out = {{"league", leagueFor(label)}, {"label", label}, {"summary", fixturesSummary(label, pulls)},
                    {"waiting", json::array()}, {"recent", json::array()}, {"competitions", json::array()}, {"contacts", json::array()},
                    {"asks", json::array()}, {"our_club_id", (long long)WelcomeLog::kLighthouseClubId}};
        const auto fixture = [](const pqxx::row& r) {
            return json{{"id", r["id"].as<long long>()}, {"division_label", str(r, "division_label")}, {"status", str(r, "status")},
                        {"home_name", str(r, "home_name")}, {"away_name", str(r, "away_name")},
                        {"home_club_id", r["home_club_id"].is_null() ? json(nullptr) : json(r["home_club_id"].as<long long>())},
                        {"away_club_id", r["away_club_id"].is_null() ? json(nullptr) : json(r["away_club_id"].as<long long>())},
                        {"home_score", r["home_score"].is_null() ? json(nullptr) : json(r["home_score"].as<long long>())},
                        {"away_score", r["away_score"].is_null() ? json(nullptr) : json(r["away_score"].as<long long>())},
                        {"home_logo", str(r, "home_logo")}, {"away_logo", str(r, "away_logo")},
                        {"date_key", str(r, "date_key")}, {"date_label", str(r, "date_label")}, {"time_label", str(r, "time_label")}};
        };
        const std::string cols = R"SQL(
            SELECT f.id, f.division_label, f.status, f.home_name, f.away_name, f.home_club_id, f.away_club_id, f.home_score, f.away_score,
                   COALESCE(hc.logo_url,'') AS home_logo, COALESCE(ac.logo_url,'') AS away_logo,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS date_key,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS date_label,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS time_label
              FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id
              LEFT JOIN clubs hc ON hc.id = f.home_club_id LEFT JOIN clubs ac ON ac.id = f.away_club_id
             WHERE s.league_label = $1 AND s.is_active AND f.removed_at IS NULL AND s.score_due_after_minutes IS NOT NULL )SQL";
        for (const auto& r : db->query(cols +
                " AND f.starts_at + make_interval(mins => s.score_due_after_minutes) < now() "
                " AND f.status NOT IN ('postponed', 'cancelled', 'canceled', 'forfeit') AND (f.home_score IS NULL OR f.away_score IS NULL) "
                " ORDER BY f.starts_at, f.division_label, f.id", {label}))
            out["waiting"].push_back(fixture(r));
        for (const auto& r : db->query(cols +
                " AND f.home_score IS NOT NULL AND f.away_score IS NOT NULL AND f.starts_at > now() - interval '15 days' "
                " ORDER BY f.starts_at DESC, f.division_label, f.id", {label}))
            out["recent"].push_back(fixture(r));
        for (const auto& r : db->query(
                "SELECT k.id, k.club_id, k.division_label FROM club_competitions k WHERE k.league_label = $1 AND k.status = 'opponent' ORDER BY k.season DESC, k.id", {label}))
            out["competitions"].push_back({{"id", r["id"].as<long long>()}, {"club_id", r["club_id"].as<long long>()}, {"division_label", str(r, "division_label")}});
        for (const auto& r : db->query(
                "SELECT c.id, c.club_id, c.competition_id, c.name, c.role, c.phone, c.email, c.score_role FROM club_contacts c "
                " WHERE c.is_active AND c.club_id IN (SELECT club_id FROM club_competitions WHERE league_label = $1 AND status = 'opponent') "
                " ORDER BY c.club_id, (c.score_role = 'main') DESC NULLS LAST, (c.score_role IS NULL), c.id", {label}))
            out["contacts"].push_back({{"id", r["id"].as<long long>()}, {"club_id", r["club_id"].as<long long>()},
                                       {"competition_id", r["competition_id"].is_null() ? json(nullptr) : json(r["competition_id"].as<long long>())},
                                       {"name", nul(r, "name")}, {"role", nul(r, "role")}, {"phone", nul(r, "phone")}, {"email", nul(r, "email")},
                                       {"score_role", nul(r, "score_role")}});
        // What was already asked, per game and person (latest per channel).
        for (const auto& r : db->query(R"SQL(
            SELECT m.league_fixture_id, m.contact_id, m.channel, (m.tier LIKE 'score_app%') AS app, COUNT(*) AS n,
                   to_char(MAX(m.sent_at) AT TIME ZONE 'America/New_York', 'Dy FMHH12:MI AM') AS last_label,
                   EXTRACT(EPOCH FROM MAX(m.sent_at))::bigint AS last_epoch
              FROM club_contact_messages m JOIN league_fixtures f ON f.id = m.league_fixture_id
              JOIN league_fixture_sources s ON s.id = f.source_id
             WHERE s.league_label = $1 AND (f.home_score IS NULL OR f.away_score IS NULL)
             GROUP BY m.league_fixture_id, m.contact_id, m.channel, (m.tier LIKE 'score_app%'))SQL", {label}))
            out["asks"].push_back({{"fixture_id", r["league_fixture_id"].as<long long>()},
                                   {"contact_id", r["contact_id"].is_null() ? json(nullptr) : json(r["contact_id"].as<long long>())},
                                   {"channel", str(r, "channel")}, {"app", r["app"].as<bool>()}, {"n", r["n"].as<long long>()}, {"last", str(r, "last_label")}, {"last_epoch", r["last_epoch"].as<long long>()}});
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents league-scores] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// One ask for one game's score, to one person or several of a team at once.
// Rendered from message_templates kind 'casa' (score_request for email,
// score_request_sms for a text), logged per recipient against the game; the
// client opens Gmail as the league address or the phone's messages.
Response OpponentsController::handleScoreRequest(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    json b; Response err; if (!parseBody(request, &b, &err)) return err;
    const long long fixtureId = n(b, "fixture_id");
    const std::string channel = s(b, "channel");
    std::string ids;
    if (b.contains("contact_ids") && b["contact_ids"].is_array())
        for (const auto& v : b["contact_ids"]) if (v.is_number_integer()) ids += (ids.empty() ? "" : ",") + std::to_string(v.get<long long>());
    if (!fixtureId || ids.empty() || (channel != "email" && channel != "sms")) return jsonError(HttpStatus::BAD_REQUEST, "fixture_id, contact_ids and channel (email|sms) required");
    try {
        auto* db = Database::getInstance();
        auto fx = db->query(R"SQL(
            SELECT f.id, f.home_name, f.away_name, COALESCE(f.division_label,'') AS division_label, s.league_label,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS date_label
              FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id WHERE f.id = $1::int)SQL", {std::to_string(fixtureId)});
        if (fx.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such game");
        const auto& f = fx[0];
        const std::string label = str(f, "league_label");
        auto rows = db->query(std::string("SELECT c.id, c.club_id, c.name, ") + (channel == "email" ? "LOWER(c.email)" : "c.phone") + " AS contact "
                              "  FROM club_contacts c WHERE c.is_active AND c.id = ANY($1::int[]) AND " + (channel == "email" ? "c.email" : "c.phone") + " IS NOT NULL ORDER BY (c.score_role = 'main') DESC NULLS LAST, c.id",
                              {"{" + ids + "}"});
        if (rows.empty()) return jsonError(HttpStatus::BAD_REQUEST, channel == "email" ? "nobody picked has an email" : "nobody picked has a phone");
        std::string first = "all";
        if (rows.size() == 1) { first = str(rows[0], "name"); if (auto sp = first.find(' '); sp != std::string::npos) first = first.substr(0, sp); }
        long long userId = bearerUserId(request); if (userId < 0) userId = 0;
        const std::string sender = senderName(userId);
        json league = leagueFor(label);
        const std::string fromEmail = league.value("correspondence_email", "");
        MessageCopy copy;
        const MessageCopy::Tokens tokens = {{"contact_first", first}, {"sender", sender.empty() ? "The commissioner" : sender}, {"from_email", fromEmail},
                                            {"league", league.value("name", "")}, {"division", str(f, "division_label")},
                                            {"home", str(f, "home_name")}, {"away", str(f, "away_name")}, {"date", str(f, "date_label")}};
        // Which message: score_request (reply to me) or score_app (enter it in
        // the SportsEngine app, mig 522); a text uses the row's _sms twin.
        std::string base = s(b, "tier"); if (base != "score_app") base = "score_request";
        std::string tier = channel == "sms" ? base + "_sms" : base;
        auto r = copy.render("casa", tier, tokens);
        if (!r.ok() && channel == "sms") { tier = base; r = copy.render("casa", tier, tokens); }
        if (!r.ok()) return jsonError(HttpStatus::BAD_REQUEST, "no message template '" + tier + "'");
        const std::string groupKey = rows.size() > 1 ? std::to_string(std::time(nullptr)) + "-" + std::to_string(userId) : std::string();
        json recipients = json::array();
        for (const auto& c : rows) {
            recipients.push_back({{"contact_id", c["id"].as<long long>()}, {"contact", str(c, "contact")}});
            db->query("INSERT INTO club_contact_messages (club_id, contact_id, channel, contact, tier, sent_by_user_id, sender_email, league_label, group_key, league_fixture_id) "
                      "VALUES ($1::int, $2::int, $3, $4, $5, NULLIF($6,'0')::int, NULLIF($7,''), $8, NULLIF($9,''), $10::int)",
                      {std::to_string(c["club_id"].as<long long>()), std::to_string(c["id"].as<long long>()), channel, str(c, "contact"), tier,
                       std::to_string(userId), fromEmail, label, groupKey, std::to_string(fixtureId)});
        }
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"subject", r.subject}, {"body", r.body}, {"recipients", recipients}, {"from_email", fromEmail}});
    } catch (const std::exception& e) { std::cerr << "[opponents score-request] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// Tag a contact for score chasing.  'main' is one per team: making someone
// main turns the previous main of the same club (and overlapping division
// scope) into a plain manager.
Response OpponentsController::handleScoreContact(const Request& request) {
    Response denied; if (!adminGate(request, &denied)) return denied;
    json b; Response err; if (!parseBody(request, &b, &err)) return err;
    const long long id = n(b, "contact_id"); const std::string role = s(b, "score_role");
    if (!id || (role != "main" && role != "manager" && !role.empty())) return jsonError(HttpStatus::BAD_REQUEST, "contact_id and score_role (main|manager|'') required");
    try {
        auto* db = Database::getInstance();
        auto r = db->query("UPDATE club_contacts SET score_role = NULLIF($2,''), updated_at = now() WHERE id = $1::int AND is_active RETURNING club_id, competition_id", {std::to_string(id), role});
        if (r.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such contact");
        if (role == "main")
            db->query("UPDATE club_contacts SET score_role = 'manager', updated_at = now() "
                      " WHERE club_id = $1::int AND id <> $2::int AND score_role = 'main' "
                      "   AND (competition_id IS NULL OR NULLIF($3,'0')::int IS NULL OR competition_id = NULLIF($3,'0')::int)",
                      {std::to_string(r[0]["club_id"].as<long long>()), std::to_string(id),
                       r[0]["competition_id"].is_null() ? std::string("0") : std::to_string(r[0]["competition_id"].as<long long>())});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { std::cerr << "[opponents score-contact] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
