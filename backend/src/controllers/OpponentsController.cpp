#include "OpponentsController.h"

#include <iostream>
#include <regex>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../models/WelcomeLog.h"
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

json tiers() {
    json out = json::array();
    auto rows = Database::getInstance()->query(
        "SELECT tier, label FROM message_templates WHERE kind = 'opponent' AND is_active AND subject IS NOT NULL ORDER BY sort_order, id");
    for (const auto& r : rows) {
        std::string label = str(r, "label");
        auto dash = label.find(" — ");
        if (dash != std::string::npos) label = label.substr(dash + 5);
        out.push_back({{"tier", str(r, "tier")}, {"label", label}});
    }
    return out;
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
        // Who is writing — the signed-in user's first name.
        std::string sender;
        const long long userId = bearerUserId(request);
        if (userId > 0) {
            auto u = db->query("SELECT COALESCE(p.first_name,'') || CASE WHEN p.last_name IS NULL THEN '' ELSE ' ' || p.last_name END AS nm FROM users us JOIN persons p ON p.id = us.person_id WHERE us.id = $1::int", {std::to_string(userId)});
            if (!u.empty()) sender = str(u[0], "nm");
        }
        MessageCopy copy;
        MessageCopy::Tokens tokens = {{"club", str(c, "club_name")}, {"contact_first", first}, {"our_team", mi.ourTeam.empty() ? "Lighthouse 1893 SC" : mi.ourTeam},
                                      {"date", mi.date.empty() ? "our next game" : mi.date}, {"time", mi.time.empty() ? "kick-off" : mi.time},
                                      {"venue", mi.venue.empty() ? "the field" : mi.venue}, {"home_away", mi.id ? (mi.isHome ? "vs" : "at") : "vs"},
                                      {"sender", sender.empty() ? "Lighthouse 1893 SC" : sender}};
        auto r = copy.render("opponent", tier, tokens);
        if (!r.ok()) return jsonError(HttpStatus::BAD_REQUEST, "no message template '" + tier + "'");
        db->query("INSERT INTO club_contact_messages (club_id, contact_id, match_id, channel, contact, tier, sent_by_user_id) VALUES ($1::int, $2::int, NULLIF($3,'0')::int, $4, $5, $6, NULLIF($7,'0')::int)",
                  {std::to_string(c["club_id"].as<long long>()), std::to_string(contactId), std::to_string(matchId), channel, contact, tier, std::to_string(userId > 0 ? userId : 0)});
        json out = {{"ok", true}, {"subject", r.subject}, {"body", r.body}, {"contact", contact}};
        copy.addComposeHrefs(out, channel, contact, r.subject, r.body, r.body);
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[opponents message] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
