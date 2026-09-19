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
            {"next_games",   model_->nextGames(def->code, scope.coachTeamIds)},
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
        if (ctx.events.empty())
            return jsonError(HttpStatus::CONFLICT, "Nothing to remind — every event this week is answered.");

        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        const auto minted = MagicLinkService::mint(ctx.recipientPersonId, channel, contact, scope.userId);

        // kind 'rsvp_reminder' (migration 363); empty names fall back to
        // the kind='fallback' words (migration 366).  An event that
        // already happened gets the tier='missed_line' suffix (mig 379).
        MessageCopy copy;
        std::string events;
        size_t openCount = 0;
        for (const auto& ev : ctx.events) {
            std::string line = ev.line;
            if (ev.missed) {
                const auto m = copy.render("rsvp_reminder", "missed_line", {{"line", ev.line}});
                if (m.ok()) line = m.body;
            } else {
                ++openCount;
            }
            events += "• " + line + "\n";
        }
        if (!events.empty()) events.pop_back();

        const auto msg = copy.render("rsvp_reminder", ctx.youth ? "parent" : "adult", {
            {"first", ctx.recipientFirstName}, {"child", ctx.playerFirstName},
            {"events", events}, {"link", minted.url}, {"sender", senderName}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "rsvp_reminder template missing (migration 363)");

        json lastReminder = model_->logReminder(personId, ctx.recipientPersonId, channel, contact,
                                                scope.userId, ctx.events);

        json out = {
            {"url",           minted.url},
            {"expires_at",    minted.expiresIso},
            {"event_count",   ctx.events.size()},
            {"open_count",    openCount},
            {"missed_count",  ctx.events.size() - openCount},
            {"last_reminder", lastReminder},
        };
        copy.addComposeHrefs(out, channel, contact, msg.subject, msg.body, msg.body);
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleRemind: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the reminder");
    }
}
