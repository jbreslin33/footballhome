#include "RsvpBoardController.h"

#include <algorithm>
#include <cctype>
#include <iostream>
#include <sstream>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../models/RsvpBoard.h"
#include "../models/MessageCopy.h"
#include "../services/MagicLinkService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonError(HttpStatus s, const std::string& message) {
    return jsonOut(s, {{"error", message}});
}

// Frontend section keys → club_sections.code / leagueapps_programs.category.
struct SectionDef { const char* key; const char* code; std::vector<std::string> laCategories; };
const std::vector<SectionDef>& sections() {
    // Boys and Girls share teams and are told apart by LA programme, so
    // either one needs both programmes fresh.
    static const std::vector<SectionDef> defs = {
        {"mens",   "M", {"men"}},
        {"womens", "W", {"women"}},
        {"boys",   "B", {"boys", "girls"}},
        {"girls",  "G", {"boys", "girls"}},
    };
    return defs;
}
const SectionDef* findSection(const std::string& key) {
    for (const auto& d : sections()) if (key == d.key) return &d;
    return nullptr;
}

}  // namespace

RsvpBoardController::RsvpBoardController() : model_(std::make_unique<RsvpBoard>()) {}
RsvpBoardController::~RsvpBoardController() = default;

void RsvpBoardController::registerRoutes(Router& router, const std::string& prefix) {
    // Dues and the boys/girls split read person_la_memberships, so the
    // section's LA programmes sync before the handler runs (§ Membership
    // Data Flow).  An unknown section syncs nothing and 400s in the handler.
    laGet(router, prefix,
        [](const Request& req) {
            std::vector<int> programs;
            const SectionDef* def = findSection(req.getQueryParam("section"));
            if (!def) return programs;
            try {
                std::ostringstream cats;
                cats << '{';
                for (size_t i = 0; i < def->laCategories.size(); ++i) {
                    if (i) cats << ',';
                    cats << def->laCategories[i];
                }
                cats << '}';
                auto rows = Database::getInstance()->query(
                    "SELECT program_id FROM leagueapps_programs "
                    " WHERE category = ANY($1::text[]) AND variant IN ('active', 'inactive') "
                    " ORDER BY program_id", {cats.str()});
                for (const auto& row : rows) programs.push_back(row["program_id"].as<int>());
            } catch (const std::exception& e) {
                std::cerr << "[RsvpBoard] programme lookup failed: " << e.what() << std::endl;
            }
            return programs;
        },
        [this](const Request& req, const LaSyncMap&) { return handleList(req); });

    router.post(prefix + "/remind", [this](const Request& r) { return handleRemind(r); });
    router.post(prefix + "/remind-event", [this](const Request& r) { return handleRemindEvent(r); });
    router.get(prefix + "/reminders", [this](const Request& r) { return handleReminders(r); });
    router.post(prefix + "/squad-notice", [this](const Request& r) { return handleSquadNotice(r); });
    router.get(prefix + "/squad-notice", [this](const Request& r) { return handleSquadNoticeStatus(r); });
}

bool RsvpBoardController::resolveScope(const Request& request, Scope* scope, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    scope->userId = bearerUserId(request);
    auto* db = Database::getInstance();
    auto me = db->query("SELECT person_id FROM users WHERE id = $1::int",
                        {std::to_string(scope->userId)});
    if (me.empty() || me[0]["person_id"].is_null()) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    scope->personId = me[0]["person_id"].as<long long>();
    scope->isAdmin = !db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                {std::to_string(scope->userId)}).empty();
    // Admins only for now (owner 2026-09-17: "coaches don't need this yet
    // just me").  The coach scoping below is ready for when that changes —
    // delete this block to let a coach see the teams they coach.
    if (!scope->isAdmin) {
        *error = jsonError(HttpStatus::FORBIDDEN, "The RSVP board is for club admins.");
        return false;
    }
    if (!scope->isAdmin) {
        auto teams = db->query(
            "SELECT DISTINCT tc.team_id FROM team_coaches tc "
            "  JOIN coaches c ON c.id = tc.coach_id "
            " WHERE c.person_id = $1::int AND tc.ended_at IS NULL",
            {std::to_string(scope->personId)});
        for (const auto& row : teams) scope->coachTeamIds.push_back(row["team_id"].as<long long>());
        if (scope->coachTeamIds.empty()) {
            *error = jsonError(HttpStatus::FORBIDDEN,
                               "The RSVP board is for club admins and coaches of a team.");
            return false;
        }
    }
    return true;
}

Response RsvpBoardController::handleList(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    const SectionDef* def = findSection(request.getQueryParam("section"));
    if (!def) return jsonError(HttpStatus::BAD_REQUEST, "section must be mens, womens, boys or girls");

    std::string window = request.getQueryParam("window");
    if (window.empty()) window = "week";
    // Window START only — every window ends at the schedule release
    // window, so upcoming released events always count.  Weeks run
    // Monday–Sunday, club time.
    std::string startExpr;
    if      (window == "week")  startExpr = "date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York'";
    else if (window == "2w")    startExpr = "(date_trunc('week', now() AT TIME ZONE 'America/New_York') - interval '7 days') AT TIME ZONE 'America/New_York'";
    else if (window == "month") startExpr = "now() - interval '30 days'";
    else if (window == "all")   startExpr = "";
    else return jsonError(HttpStatus::BAD_REQUEST, "window must be week, 2w, month or all");

    std::string kind = request.getQueryParam("kind");
    if (kind.empty()) kind = "all";
    if (kind != "all" && kind != "games" && kind != "practices")
        return jsonError(HttpStatus::BAD_REQUEST, "kind must be all, games or practices");

    try {
        std::string windowStart;
        if (!startExpr.empty()) {
            auto row = Database::getInstance()->query(
                "SELECT to_char((" + startExpr + ") AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS t");
            windowStart = row[0]["t"].c_str();
        }

        json people = model_->list(def->code, windowStart, kind, scope.coachTeamIds);
        if (!scope.isAdmin) {
            // Coaches get the dues pill the roster boards already show
            // them, but not what was paid or when.
            for (auto& p : people) {
                p.erase("last_payment_amount");
                p.erase("last_payment_at");
            }
        }
        return jsonOut(HttpStatus::OK, {
            {"section",      def->key},
            {"window",       window},
            {"kind",         kind},
            {"window_start", windowStart.empty() ? json(nullptr) : json(windowStart)},
            {"is_admin",     scope.isAdmin},
            {"events",       model_->weekEvents(def->code, scope.coachTeamIds)},
            {"team_groups",  model_->teamGroups()},   // migration 419
            {"people",       std::move(people)},
        });
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleList: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response RsvpBoardController::handleRemind(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    long long personId = 0;
    std::string channel;
    try {
        personId = body.value("person_id", 0LL);
        channel  = body.value("channel", std::string{});
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "person_id must be a number and channel a string");
    }
    std::transform(channel.begin(), channel.end(), channel.begin(),
                   [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    if (channel != "sms" && channel != "email")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'sms' or 'email'");

    try {
        auto ctx = model_->reminderContext(personId);
        if (!ctx.found) return jsonError(HttpStatus::NOT_FOUND, "Person not found");

        if (!scope.isAdmin) {
            const bool coaches = std::any_of(ctx.teamIds.begin(), ctx.teamIds.end(), [&](long long t) {
                return std::find(scope.coachTeamIds.begin(), scope.coachTeamIds.end(), t) != scope.coachTeamIds.end();
            });
            if (!coaches) return jsonError(HttpStatus::FORBIDDEN, "That player is not on a team you coach.");
        }

        // Contact comes from the DB, never the request: the message carries
        // the recipient's sign-in credential.
        const std::string contact = channel == "sms" ? ctx.phone : ctx.email;
        if (contact.empty())
            return jsonError(HttpStatus::CONFLICT, channel == "sms" ? "No mobile number on file." : "No email on file.");
        // The board's day pills narrow the cards, not the message: a
        // reminder always lists every still-answerable event of the week
        // (owner 2026-09-22).
        if (ctx.openEvents.empty())
            return jsonError(HttpStatus::CONFLICT, "Nothing to remind — nothing left to answer this week.");

        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        const auto minted = MagicLinkService::mint(ctx.recipientPersonId, channel, contact, scope.userId);

        // Only events that can still be answered — one that already went
        // by would just confuse the player (owner 2026-09-19).
        std::string events;
        for (const auto& ev : ctx.openEvents) events += "• " + ev.line + "\n";
        if (!events.empty()) events.pop_back();

        // kind 'rsvp_reminder' (migration 363); empty names fall back to
        // the kind='fallback' words (migration 366).
        MessageCopy copy;
        const auto msg = copy.render("rsvp_reminder", ctx.youth ? "parent" : "adult", {
            {"first", ctx.recipientFirstName}, {"child", ctx.playerFirstName},
            {"events", events}, {"link", minted.url}, {"sender", senderName}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "rsvp_reminder template missing (migration 363)");

        json lastReminder = model_->logReminder(personId, ctx.recipientPersonId, channel, contact,
                                                scope.userId, ctx.openEvents);

        json out = {
            {"url",           minted.url},
            {"expires_at",    minted.expiresIso},
            {"event_count",   ctx.openEvents.size()},
            {"last_reminder", lastReminder},
        };
        copy.addComposeHrefs(out, channel, contact, msg.subject, msg.body, msg.body);
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleRemind: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the reminder");
    }
}

Response RsvpBoardController::handleRemindEvent(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    long long fhEventId = 0, teamId = 0, matchId = 0;
    std::string channel, sectionKey, reach;
    try {
        fhEventId  = body.value("fh_event_id", 0LL);
        matchId    = body.value("match_id", 0LL);
        reach      = body.value("scope", std::string("event"));
        teamId     = body.contains("team_id") && !body["team_id"].is_null() ? body["team_id"].get<long long>() : 0LL;
        channel    = body.value("channel", std::string{});
        sectionKey = body.value("section", std::string{});
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id and team_id must be numbers, channel and section strings");
    }
    // #rsvps names a section; Game Center names the match and lets the
    // event's own team tags decide who is expected.
    const SectionDef* def = findSection(sectionKey);
    if (!def && !sectionKey.empty())
        return jsonError(HttpStatus::BAD_REQUEST, "section must be mens, womens, boys or girls");
    if (reach != "event" && reach != "week")
        return jsonError(HttpStatus::BAD_REQUEST, "scope must be 'event' or 'week'");
    if (fhEventId <= 0 && matchId > 0) {
        auto ev = Database::getInstance()->query(
            "SELECT id FROM fh_events WHERE match_id = $1::int ORDER BY id LIMIT 1", {std::to_string(matchId)});
        if (ev.empty()) return jsonError(HttpStatus::NOT_FOUND, "That game is not on the calendar, so nobody can RSVP to it yet.");
        fhEventId = ev[0]["id"].as<long long>();
    }
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id or match_id required");
    if (channel != "sms" && channel != "email")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'sms' or 'email'");

    // The teams asked for (team_ids, or the older single team_id), else
    // whatever the caller may see.  #rsvps sends several since its team
    // pills multi-select (migration 419).
    std::vector<long long> picked;
    if (body.contains("team_ids") && body["team_ids"].is_array())
        for (const auto& v : body["team_ids"]) if (v.is_number()) picked.push_back(v.get<long long>());
    if (picked.empty() && teamId > 0) picked = {teamId};
    std::vector<long long> teamIds = scope.coachTeamIds;
    if (!picked.empty()) {
        for (long long t : picked)
            if (!scope.isAdmin && std::find(teamIds.begin(), teamIds.end(), t) == teamIds.end())
                return jsonError(HttpStatus::FORBIDDEN, "That is not a team you coach.");
        teamIds = picked;
    }

    try {
        auto ctx = model_->groupReminderContext(def ? def->code : "", fhEventId, teamIds);
        if (ctx.recipients.empty())
            return jsonError(HttpStatus::CONFLICT,
                "Nothing to remind — nobody can still answer that event (all answered, not released yet, or already over).");

        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        // Parents are the recipients as soon as one player has one.
        const bool youth = std::any_of(ctx.recipients.begin(), ctx.recipients.end(),
            [](const RsvpBoard::GroupRecipient& r) { return r.recipientPersonId != r.personId; });
        const bool week = reach == "week";
        std::string eventLines;
        for (const auto& ev : ctx.weekEvents) eventLines += "• " + ev.line + "\n";
        if (!eventLines.empty()) eventLines.pop_back();
        MessageCopy copy;
        const auto msg = copy.render("rsvp_reminder",
            std::string(week ? "group_week_" : "group_") + (youth ? "parent" : "adult"),
            {{"event", ctx.line}, {"events", eventLines}, {"sender", senderName}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "group rsvp_reminder template missing (migration 380 / 381)");

        // Siblings share a parent: one contact, every player logged.
        json contacts = json::array();
        json reminded = json::object();
        long long noContact = 0;
        const std::vector<RsvpBoard::OpenEvent> events = {{fhEventId, ctx.line}};
        for (const auto& r : ctx.recipients) {
            const std::string& contact = channel == "sms" ? r.phone : r.email;
            if (contact.empty()) { ++noContact; continue; }
            if (std::find(contacts.begin(), contacts.end(), json(contact)) == contacts.end())
                contacts.push_back(contact);
            reminded[std::to_string(r.personId)] =
                model_->logReminder(r.personId, r.recipientPersonId, channel, contact, scope.userId,
                                    week ? r.weekEvents : events, true);
        }
        if (contacts.empty())
            return jsonError(HttpStatus::CONFLICT, channel == "sms"
                ? "Nobody unanswered has a mobile number on file." : "Nobody unanswered has an email on file.");

        return jsonOut(HttpStatus::CREATED, {
            {"channel",    channel},
            {"subject",    msg.subject},
            {"body",       msg.body},
            {"contacts",   contacts},
            {"reminded",   reminded},      // person_id → the card's fresh last_reminder
            {"no_contact", noContact},
        });
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleRemindEvent: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the reminder");
    }
}

// GET /reminders?match_id= — who has already been reminded about a game,
// per channel.  Game Center's No Response cards dim a sent button with it.
Response RsvpBoardController::handleReminders(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    long long matchId = 0;
    try { matchId = std::stoll(request.getQueryParam("match_id")); } catch (const std::exception&) {}
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match_id required");
    try {
        auto ev = Database::getInstance()->query(
            "SELECT id FROM fh_events WHERE match_id = $1::int ORDER BY id LIMIT 1", {std::to_string(matchId)});
        json reminders = json::object();
        if (!ev.empty()) reminders = model_->remindersForEvent(ev[0]["id"].as<long long>());
        return jsonOut(HttpStatus::OK, {{"reminders", reminders}});
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleReminders: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load reminders");
    }
}

// POST /squad-notice {match_id, channel, scope?, person_id?} — the game
// reminder to the squad (Starting, Bench, Alternates), Going or not: the
// RSVP reminders never reach a player who already answered (owner
// 2026-09-19: "i got guys who set going asking if there is a game").
//   no person_id  ONE group message — plain link to the game's Game
//                 Center, no magic link.  scope 'changed' keeps it to
//                 whoever was never told or has moved role since.
//   person_id     that player's own message (mig 384): names their role,
//                 and the magic link lands on the game.
Response RsvpBoardController::handleSquadNotice(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    long long matchId = 0, personId = 0;
    std::string channel, reach;
    try {
        matchId  = body.value("match_id", 0LL);
        personId = body.value("person_id", 0LL);
        channel  = body.value("channel", std::string{});
        reach    = body.value("scope", std::string("all"));
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "match_id and person_id must be numbers, channel and scope strings");
    }
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match_id required");
    if (channel != "sms" && channel != "email")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'sms' or 'email'");
    if (reach != "all" && reach != "changed")
        return jsonError(HttpStatus::BAD_REQUEST, "scope must be 'all' or 'changed'");

    try {
        auto ctx = model_->squadNoticeContext(matchId);
        if (!ctx.found) return jsonError(HttpStatus::NOT_FOUND, "That game is not on the calendar.");
        if (ctx.recipients.empty())
            return jsonError(HttpStatus::CONFLICT, "Nobody is in the squad yet — set Starting, Bench or Alternates first.");

        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        MessageCopy copy;

        if (personId > 0) {
            auto it = std::find_if(ctx.recipients.begin(), ctx.recipients.end(),
                [&](const RsvpBoard::SquadRecipient& r) { return r.personId == personId; });
            if (it == ctx.recipients.end())
                return jsonError(HttpStatus::CONFLICT, "That player is not in the squad for this game.");
            // Contact comes from the DB, never the request: the message
            // carries the recipient's sign-in credential.
            const std::string contact = channel == "sms" ? it->phone : it->email;
            if (contact.empty())
                return jsonError(HttpStatus::CONFLICT, channel == "sms" ? "No mobile number on file." : "No email on file.");
            const bool parent = it->recipientPersonId != it->personId;
            const auto minted = MagicLinkService::mint(it->recipientPersonId, channel, contact, scope.userId, 0, matchId);
            const auto msg = copy.render("squad_notice", it->zone + (parent ? "_parent" : "_adult"), {
                {"first", it->recipientFirstName}, {"child", it->playerFirstName},
                {"event", ctx.line}, {"where", ctx.where}, {"arrival", ctx.arrival},
                {"link", minted.url}, {"sender", senderName}});
            if (!msg.ok())
                return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "squad_notice template missing (migration 384)");
            model_->logSquadNotice(matchId, *it, channel, contact, scope.userId);
            json out = {{"expires_at", minted.expiresIso}, {"status", model_->squadNoticeStatus(matchId)}};
            copy.addComposeHrefs(out, channel, contact, msg.subject, msg.body, msg.body);
            return jsonOut(HttpStatus::CREATED, out);
        }

        if (reach == "changed") {
            ctx.recipients.erase(std::remove_if(ctx.recipients.begin(), ctx.recipients.end(),
                [](const RsvpBoard::SquadRecipient& r) { return r.toldZone == r.zone; }), ctx.recipients.end());
            if (ctx.recipients.empty())
                return jsonError(HttpStatus::CONFLICT, "Everyone in the squad has been told the role they have now.");
        }

        // Parents are the recipients as soon as one player has one.
        const bool youth = std::any_of(ctx.recipients.begin(), ctx.recipients.end(),
            [](const RsvpBoard::SquadRecipient& r) { return r.recipientPersonId != r.personId; });
        const std::string link = MagicLinkService::publicBaseUrl() + "/#game-center/"
                               + std::to_string(matchId) + "/starters_bench";
        const auto msg = copy.render("squad_notice", youth ? "group_parent" : "group_adult",
            {{"event", ctx.line}, {"where", ctx.where}, {"arrival", ctx.arrival},
             {"link", link}, {"sender", senderName}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "squad_notice template missing (migration 383)");

        // Siblings share a parent: one contact, every player logged.
        json contacts = json::array();
        long long noContact = 0;
        for (const auto& r : ctx.recipients) {
            const std::string& contact = channel == "sms" ? r.phone : r.email;
            if (contact.empty()) { ++noContact; continue; }
            if (std::find(contacts.begin(), contacts.end(), json(contact)) == contacts.end())
                contacts.push_back(contact);
            model_->logSquadNotice(matchId, r, channel, contact, scope.userId);
        }
        if (contacts.empty())
            return jsonError(HttpStatus::CONFLICT, channel == "sms"
                ? "Nobody in the squad has a mobile number on file." : "Nobody in the squad has an email on file.");

        return jsonOut(HttpStatus::CREATED, {
            {"channel",    channel},
            {"subject",    msg.subject},
            {"body",       channel == "sms" ? copy.withSmsLinkHint(msg.body) : msg.body},
            {"contacts",   contacts},
            {"no_contact", noContact},
            {"status",     model_->squadNoticeStatus(matchId)},
        });
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleSquadNotice: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the game reminder");
    }
}

// GET /squad-notice?match_id= — has the squad been told, and how many
// have not been told the role they hold now.
Response RsvpBoardController::handleSquadNoticeStatus(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    long long matchId = 0;
    try { matchId = std::stoll(request.getQueryParam("match_id")); } catch (const std::exception&) {}
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match_id required");
    try {
        return jsonOut(HttpStatus::OK, {{"status", model_->squadNoticeStatus(matchId)}});
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleSquadNoticeStatus: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the game reminder status");
    }
}
