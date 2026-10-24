#include "RsvpBoardController.h"

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <iostream>
#include <map>
#include <set>
#include <sstream>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../models/RsvpBoard.h"
#include "../models/PersonFines.h"
#include "../models/MessageCopy.h"
#include "../models/WelcomeLog.h"
#include "../services/MagicLinkService.h"
#include "../services/GroupMeService.h"
#include "../services/TwilioService.h"
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

// Which of a player's recipients a personal send goes to (mig 682): the
// body's recipient_person_ids if given (each must be one of them), else
// every one — a kid with two parents gets two separate messages.
// Returns false on a bad pick.
bool pickRecipients(const std::vector<RsvpBoard::Recipient>& all, const json& body,
                    std::vector<RsvpBoard::Recipient>* out) {
    out->clear();
    if (!body.contains("recipient_person_ids") || !body["recipient_person_ids"].is_array()) {
        *out = all;
        return true;
    }
    for (const auto& v : body["recipient_person_ids"]) {
        if (!v.is_number_integer()) return false;
        auto it = std::find_if(all.begin(), all.end(),
                               [&](const RsvpBoard::Recipient& r) { return r.personId == v.get<long long>(); });
        if (it == all.end()) return false;
        if (std::none_of(out->begin(), out->end(), [&](const RsvpBoard::Recipient& r) { return r.personId == it->personId; }))
            out->push_back(*it);
    }
    return !out->empty();
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
    router.post(prefix + "/roll-call",    [this](const Request& r) { return handleRollCall(r); });
    router.get(prefix + "/reminders", [this](const Request& r) { return handleReminders(r); });
    router.post(prefix + "/squad-notice", [this](const Request& r) { return handleSquadNotice(r); });
    router.post(prefix + "/dues-note",    [this](const Request& r) { return handleDuesNote(r); });
    router.get(prefix + "/squad-notice", [this](const Request& r) { return handleSquadNoticeStatus(r); });
    router.get(prefix + "/text-marks", [this](const Request& r) { return handleTextMarks(r); });
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

// club_sections.rsvp_roll_call for a section code (mig 543).
static bool rollCallOn(const std::string& sectionCode) {
    if (sectionCode.empty()) return false;
    auto r = Database::getInstance()->query(
        "SELECT rsvp_roll_call FROM club_sections WHERE code = $1", {sectionCode});
    return !r.empty() && r[0]["rsvp_roll_call"].as<bool>();
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
            {"roll_call",    rollCallOn(def->code)},  // migration 543
            {"people",       std::move(people)},
        });
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleList: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

// The fines section of a player's reminder (message_templates kind
// 'rsvp_reminder_fines', mig 463): the rules in force for their section,
// then the fines they have earned in the months not yet posted.  '' when
// their section has no rates.

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
        // One reminder per parent, each with their own words, link and log
        // row (mig 682) — owner 2026-10-24: "any text should go out
        // separate to both".
        std::vector<RsvpBoard::Recipient> recipients;
        if (!pickRecipients(model_->messageRecipients(personId), body, &recipients))
            return jsonError(HttpStatus::BAD_REQUEST, "recipient_person_ids must be this player's parents");
        json sends = json::array();
        std::string firstErr;
        HttpStatus firstCode = HttpStatus::CONFLICT;
        const auto skip = [&](HttpStatus c, const std::string& m) { if (firstErr.empty()) { firstErr = m; firstCode = c; } };
        for (const auto& rcp : recipients) {
        auto ctx = model_->reminderContext(personId, rcp.personId);
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
        if (contact.empty()) {
            skip(HttpStatus::CONFLICT, channel == "sms" ? "No mobile number on file." : "No email on file.");
            continue;
        }
        // The board's day pills narrow the cards, not the message: a
        // reminder always lists every still-answerable event of the week
        // (owner 2026-09-22).
        if (ctx.openEvents.empty()) {
            skip(HttpStatus::CONFLICT, "Nothing to remind — nothing left to answer this week.");
            continue;
        }

        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        // The link lands on the live roll call card for the household's
        // teams (mig 544), signed in, with their own Going / Not Going.
        std::string landing;
        {
            std::vector<long long> covered = {personId, ctx.recipientPersonId};
            for (const auto& ev : ctx.openEvents) covered.push_back(ev.playerId);
            std::string sectionCode;
            const auto teams = model_->boardTeamsOf(covered, &sectionCode);
            const std::string url = model_->rollCallLink(sectionCode, teams, scope.userId);
            if (auto at = url.find("/rc/"); at != std::string::npos) landing = url.substr(at + 1);
        }
        const auto minted = MagicLinkService::mint(ctx.recipientPersonId, channel, contact, scope.userId, 0, 0, landing);

        // Only events that can still be answered — one that already went
        // by would just confuse the player (owner 2026-09-19).
        std::string events;
        for (const auto& ev : ctx.openEvents)
            events += "• " + (ctx.siblings.empty() ? std::string{} : ev.playerFirstName + ": ") + ev.line + "\n";
        if (!events.empty()) events.pop_back();

        // kind 'rsvp_reminder' (migration 363); empty names fall back to
        // the kind='fallback' words (migration 366).
        MessageCopy copy;
        // {missing}: how many game / practice RSVPs are open, not which
        // (mig 538) — owner 2026-10-07: "leave out what rsvp is missing ...
        // just say your missing practice rsvps, or games and practice or
        // game rsvp depening on what they are missing ... list total
        // missing ... the message seems robotic".  Tiers missing_games /
        // missing_practices / missing_both; "a" for one, the number past
        // that.  {events} still lists them for any template that wants it.
        const auto count = [](int n) { return n == 1 ? std::string("a") : std::to_string(n); };
        const auto missingFor = [&](int games, int practices) {
            const MessageCopy::Tokens countTokens = {
                {"games", count(games)}, {"games_s", games == 1 ? "" : "s"},
                {"practices", count(practices)}, {"practices_s", practices == 1 ? "" : "s"},
                {"total", std::to_string(games + practices)}};
            return copy.render("rsvp_reminder",
                games && practices ? "missing_both" : games ? "missing_games" : "missing_practices", countTokens).body;
        };
        int games = 0, practices = 0;
        std::string deadline;
        // Per child, in the order they came (the clicked child first) —
        // one parent, one message (mig 542).
        std::vector<long long> childOrder;
        std::map<long long, std::pair<int, int>> perChild;   // id → {games, practices}
        std::map<long long, std::string> childName;
        for (const auto& ev : ctx.openEvents) {
            if (ev.kind == "practice") ++practices; else ++games;
            if (deadline.empty() && ev.kind != "practice") deadline = ev.deadline;
            if (!perChild.count(ev.playerId)) { childOrder.push_back(ev.playerId); childName[ev.playerId] = ev.playerFirstName; }
            auto& pc = perChild[ev.playerId];
            if (ev.kind == "practice") ++pc.second; else ++pc.first;
        }
        const std::string missing = missingFor(games, practices);
        // {children}: "Alex, Angel and Ryan" (the recipient themself as
        // "you"); {per_child}: a line each (tier child_line) — only when more
        // than one person has something open, so one child, or one adult,
        // still reads as before.
        std::string children, perChildLines;
        const bool multi = childOrder.size() > 1;
        if (multi) {
            const std::string andWord = copy.render("rsvp_reminder", "and_word", {}).body;
            const std::string youWord = copy.render("rsvp_reminder", "you_word", {}).body;
            for (size_t i = 0; i < childOrder.size(); ++i) {
                const auto id = childOrder[i];
                const std::string name = id == ctx.recipientPersonId ? (youWord.empty() ? "you" : youWord) : childName[id];
                if (i) children += (i + 1 == childOrder.size() ? " " + (andWord.empty() ? "and" : andWord) + " " : ", ");
                children += name;
                perChildLines += copy.render("rsvp_reminder", "child_line",
                                             {{"child", name},
                                              {"missing", missingFor(perChild[id].first, perChild[id].second)}}).body + "\n";
            }
            if (!perChildLines.empty()) perChildLines.pop_back();
        }
        // {fine_note}: one line for a player whose section fines missed
        // RSVPs (Men, mig 460) — owner 2026-10-07: "for men just lmk its a
        // fine for missed rsvps".  Empty elsewhere, so its [[ ]] drops.
        std::string fineNote;
        {
            std::string practiceFine, gameFine;
            for (const auto& r : PersonFines().rulesFor(static_cast<int>(personId))) {
                const std::string kind = r.value("kind", "");
                char buf[32];
                const double v = r.value("amount", 0.0);
                if (std::fabs(v - std::round(v)) < 0.005) std::snprintf(buf, sizeof buf, "$%.0f", v);
                else std::snprintf(buf, sizeof buf, "$%.2f", v);
                if (kind == "missed_rsvp_practice") practiceFine = buf;
                else if (kind == "missed_rsvp_game") gameFine = buf;
            }
            if (!practiceFine.empty() || !gameFine.empty())
                fineNote = copy.render("rsvp_reminder", "fine_note",
                                       {{"practice_fine", practiceFine}, {"game_fine", gameFine}}).body;
        }
        // {travel}: the extra line when a travel team's game is on the list
        // (tier 'travel', mig 509) — owner 2026-10-02: "travel spots carry
        // extra responsibilty".  Empty otherwise, so its [[ ]] drops.
        const std::string travel = ctx.travelGame ? copy.render("rsvp_reminder", "travel", {}).body : std::string{};
        const auto msg = copy.render("rsvp_reminder", multi ? "multi" : ctx.youth ? "parent" : "adult", {
            {"first", ctx.recipientFirstName}, {"child", ctx.playerFirstName},
            {"children", children}, {"per_child", perChildLines},
            {"events", events}, {"missing", missing}, {"deadline", deadline},
            {"link", minted.url}, {"sender", senderName},
            {"fine_note", fineNote}, {"travel", travel}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "rsvp_reminder template missing (migration 363/542)");

        // One send, logged against every child it covered, each with their
        // own events — the board dims every sibling's card (mig 542).
        json lastReminder;
        json also = json::array();
        for (const auto id : childOrder) {
            std::vector<RsvpBoard::OpenEvent> theirs;
            for (const auto& ev : ctx.openEvents) if (ev.playerId == id) theirs.push_back(ev);
            json lr = model_->logReminder(id, ctx.recipientPersonId, channel, contact, scope.userId, theirs);
            if (id == personId) lastReminder = lr;
            else also.push_back({{"person_id", id}, {"last_reminder", lr}});
        }
        if (lastReminder.is_null())
            lastReminder = model_->logReminder(personId, ctx.recipientPersonId, channel, contact, scope.userId, {});

        json out = {
            {"url",           minted.url},
            {"expires_at",    minted.expiresIso},
            {"token_id",      minted.tokenId},
            {"event_count",   ctx.openEvents.size()},
            {"last_reminder", lastReminder},
            {"also",          also},
            {"recipient_person_id", ctx.recipientPersonId},
            {"recipient_name",      ctx.recipientFirstName},
            {"contact",             contact},
        };
        copy.addComposeHrefs(out, channel, contact, msg.subject, msg.body, msg.body);
        sends.push_back(std::move(out));
        }
        if (sends.empty()) return jsonError(firstCode, firstErr.empty() ? "Nothing to send." : firstErr);
        // Top level = the first send (callers that predate mig 682);
        // sends[] = one per parent.
        json out = sends[0];
        out["sends"] = sends;
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleRemind: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the reminder");
    }
}

// POST /roll-call { section, fh_event_id, team_ids, channel: sms|groupme|copy }
// The roll call for one game (mig 543) — owner 2026-10-07: "a message …
// that has the going and not going list but shows the non respondants".
// Players only, first name + initial.  sms → the body + every expected
// player's phone (the whole squad sees it); groupme → posted to the
// section's chat; copy → the body.  Every send is a rsvp_roll_calls row.
Response RsvpBoardController::handleRollCall(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    const long long fhEventId = body.value("fh_event_id", 0LL);
    const std::string channel = body.value("channel", std::string("copy"));
    const SectionDef* def = findSection(body.value("section", std::string{}));
    if (!def) return jsonError(HttpStatus::BAD_REQUEST, "section must be mens, womens, boys or girls");
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id required");
    if (channel != "sms" && channel != "groupme" && channel != "copy")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be sms, groupme or copy");
    if (!rollCallOn(def->code)) return jsonError(HttpStatus::FORBIDDEN, "The roll call is not on for this section.");
    std::vector<long long> teamIds = scope.coachTeamIds;
    if (body.contains("team_ids") && body["team_ids"].is_array()) {
        std::vector<long long> picked;
        for (const auto& v : body["team_ids"]) if (v.is_number()) picked.push_back(v.get<long long>());
        for (long long t : picked)
            if (!scope.isAdmin && std::find(teamIds.begin(), teamIds.end(), t) == teamIds.end())
                return jsonError(HttpStatus::FORBIDDEN, "That is not a team you coach.");
        if (!picked.empty()) teamIds = picked;
    }
    try {
        const auto rc = model_->rollCall(def->code, fhEventId, teamIds);
        if (!rc.found) return jsonError(HttpStatus::NOT_FOUND, "Nobody is expected on that event under these teams.");
        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int", {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        MessageCopy copy;
        const std::string nobody = copy.render("rsvp_roll_call", "nobody", {}).body;
        std::string sep = copy.render("rsvp_roll_call", "name_sep", {}).body;
        if (sep.empty()) sep = ", ";
        const auto join = [&](const std::vector<std::string>& v) {
            if (v.empty()) return nobody.empty() ? std::string("nobody") : nobody;
            std::string out;
            for (size_t i = 0; i < v.size(); ++i) out += (i ? sep : "") + v[i];
            return out;
        };
        const auto msg = copy.render("rsvp_roll_call", "body", {
            {"event", rc.line}, {"deadline", rc.deadline}, {"sender", senderName},
            {"link", model_->rollCallLink(def->code, teamIds, scope.userId)},
            {"n_going", std::to_string(rc.going.size())},     {"going", join(rc.going)},
            {"n_not",   std::to_string(rc.notGoing.size())},  {"not_going", join(rc.notGoing)},
            {"n_none",  std::to_string(rc.noResponse.size())}, {"no_response", join(rc.noResponse)}});
        if (!msg.ok()) return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "rsvp_roll_call template missing (migration 543)");

        std::string externalId;
        if (channel == "groupme") {
            auto chat = Database::getInstance()->query(
                "SELECT ci.external_id FROM club_sections cs "
                "  JOIN chats c ON c.slug = cs.rsvp_roll_call_chat_slug "
                "  JOIN chat_integrations ci ON ci.chat_id = c.id AND ci.post_messages "
                "  JOIN chat_providers p ON p.id = ci.provider_id AND p.name = 'groupme' AND p.is_active "
                " WHERE cs.code = $1 LIMIT 1", {def->code});
            if (chat.empty()) return jsonError(HttpStatus::CONFLICT, "This section has no GroupMe to post to.");
            externalId = GroupMeService::getInstance().postMessage(chat[0]["external_id"].c_str(), msg.body);
            if (externalId.empty()) return jsonError(HttpStatus::BAD_GATEWAY, "GroupMe did not take the post.");
        }
        Database::getInstance()->query(
            "INSERT INTO rsvp_roll_calls (fh_event_id, channel, sent_by_user_id, going, not_going, no_response, body, external_id) "
            "VALUES ($1::bigint, $2, NULLIF($3::int, 0), $4::int, $5::int, $6::int, $7, NULLIF($8, ''))",
            {std::to_string(fhEventId), channel, std::to_string(scope.userId),
             std::to_string(rc.going.size()), std::to_string(rc.notGoing.size()), std::to_string(rc.noResponse.size()),
             msg.body, externalId});
        json out = {
            {"body", msg.body}, {"channel", channel},
            {"going", rc.going.size()}, {"not_going", rc.notGoing.size()}, {"no_response", rc.noResponse.size()},
            {"contacts", rc.phones}, {"kids", rc.phoneKids}, {"posted", !externalId.empty()},
        };
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleRollCall: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the roll call");
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
    std::string channel, sectionKey, reach, role;
    try {
        fhEventId  = body.value("fh_event_id", 0LL);
        role       = body.value("role", std::string("all"));   // #rsvps Who pill (mig 530)
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
    if (role != "all" && role != "player" && role != "coach" && role != "staff")
        return jsonError(HttpStatus::BAD_REQUEST, "role must be all, player, coach or staff");

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
        auto ctx = model_->groupReminderContext(def ? def->code : "", fhEventId, teamIds, role);
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
        const std::string rollCallUrl = model_->rollCallLink(def ? def->code : "", teamIds, scope.userId);   // mig 544
        std::string eventLines;
        for (const auto& ev : ctx.weekEvents) eventLines += "• " + ev.line + "\n";
        if (!eventLines.empty()) eventLines.pop_back();
        MessageCopy copy;
        // {travel}: as in the one-player reminder (mig 509).
        const std::string travel = ctx.travelGame ? copy.render("rsvp_reminder", "travel", {}).body : std::string{};
        const auto msg = copy.render("rsvp_reminder",
            std::string(week ? "group_week_" : "group_") + (youth ? "parent" : "adult"),
            {{"event", ctx.line}, {"events", eventLines}, {"sender", senderName}, {"travel", travel},
             {"roll_call", rollCallUrl}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "group rsvp_reminder template missing (migration 380 / 381)");

        // Siblings share a parent: one contact, every player logged.  Both
        // parents of a kid are in (mig 682); "kids" lets the group-text
        // chunker keep them in separate threads.
        json contacts = json::array();
        json kids = json::object();
        json reminded = json::object();
        std::set<long long> reached, players;
        const std::vector<RsvpBoard::OpenEvent> events = {{fhEventId, ctx.line}};
        for (const auto& r : ctx.recipients) {
            players.insert(r.personId);
            const std::string& contact = channel == "sms" ? r.phone : r.email;
            if (contact.empty()) continue;
            reached.insert(r.personId);
            if (std::find(contacts.begin(), contacts.end(), json(contact)) == contacts.end())
                contacts.push_back(contact);
            kids[contact].push_back(r.personId);
            reminded[std::to_string(r.personId)] =
                model_->logReminder(r.personId, r.recipientPersonId, channel, contact, scope.userId,
                                    week ? r.weekEvents : events, true);
        }
        const long long noContact = static_cast<long long>(players.size() - reached.size());
        if (contacts.empty())
            return jsonError(HttpStatus::CONFLICT, channel == "sms"
                ? "Nobody unanswered has a mobile number on file." : "Nobody unanswered has an email on file.");

        return jsonOut(HttpStatus::CREATED, {
            {"channel",    channel},
            {"subject",    msg.subject},
            {"body",       msg.body},
            {"contacts",   contacts},
            {"kids",       kids},          // contact → player ids (mig 682)
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
    // club_sms (mig 647): the club number sends it — one player only,
    // opted in only, and Game Center shows sent → delivered → opened.
    if (channel != "sms" && channel != "email" && channel != "club_sms")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'sms', 'email' or 'club_sms'");
    if (channel == "club_sms" && personId <= 0)
        return jsonError(HttpStatus::BAD_REQUEST, "club_sms reaches one player — person_id required");
    if (reach != "all" && reach != "changed")
        return jsonError(HttpStatus::BAD_REQUEST, "scope must be 'all' or 'changed'");

    try {
        auto ctx = model_->squadNoticeContext(matchId);
        if (!ctx.found) return jsonError(HttpStatus::NOT_FOUND, "That game is not on the calendar.");
        // An empty squad only blocks the GROUP notice — a personal game
        // link reaches any player of the game, role or not (mig 593).
        if (personId <= 0 && ctx.recipients.empty())
            return jsonError(HttpStatus::CONFLICT, "Nobody is in the squad yet — set Starting, Bench or Alternates first.");

        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        MessageCopy copy;
        // Short and urgent (mig 685; owner 2026-10-24: "the game one needs
        // urgency but short and sweet. if game is tomorrow it needs to
        // stress that"): {when} = TODAY / TOMORROW / Sat + time, {urgent}
        // = the role's nudge, only when the game is today or tomorrow.
        const std::string dayWord = ctx.soon ? copy.render("squad_notice", "day_" + ctx.day, {}).body : ctx.day;
        const std::string when = (dayWord.empty() ? ctx.day : dayWord) + " " + ctx.time;
        const auto urgentFor = [&](const std::string& zone) {
            return ctx.soon ? copy.render("squad_notice", "nudge_" + zone, {}).body : std::string{};
        };

        if (personId > 0) {
            // One game link per parent, each with their own sign-in link
            // and log row (mig 682); the body's recipient_person_ids narrows it.
            std::vector<RsvpBoard::Recipient> recipients;
            if (!pickRecipients(model_->messageRecipients(personId), body, &recipients))
                return jsonError(HttpStatus::BAD_REQUEST, "recipient_person_ids must be this player's parents");
            const bool club = channel == "club_sms";
            json sends = json::array();
            std::string firstErr;
            HttpStatus firstCode = HttpStatus::CONFLICT;
            const auto skip = [&](HttpStatus c, const std::string& m) { if (firstErr.empty()) { firstErr = m; firstCode = c; } };
            for (const auto& rcp : recipients) {
                auto it = std::find_if(ctx.recipients.begin(), ctx.recipients.end(),
                    [&](const RsvpBoard::SquadRecipient& r) { return r.personId == personId && r.recipientPersonId == rcp.personId; });
                // No squad role is no longer a refusal: any player of the game
                // — rostered or an invited call-up — gets the pool message, the
                // same personal link with no role named (mig 593, owner
                // 2026-10-16: "ALL PLayers need email and text link
                // personalized to invite to game").
                RsvpBoard::SquadRecipient pool;
                const RsvpBoard::SquadRecipient* who = it != ctx.recipients.end() ? &*it
                    : (model_->poolRecipient(matchId, personId, &pool, rcp.personId) ? &pool : nullptr);
                if (!who)
                    return jsonError(HttpStatus::CONFLICT, "That player is not on this game.");
                // Contact comes from the DB, never the request: the message
                // carries the recipient's sign-in credential.
                const std::string contact = channel == "email" ? who->email : who->phone;
                if (contact.empty()) {
                    skip(HttpStatus::CONFLICT, channel == "email" ? "No email on file." : "No mobile number on file.");
                    continue;
                }
                if (club) {
                    auto c = Database::getInstance()->query(
                        "SELECT fh_sms_consented_at($1::int) IS NOT NULL AS ok", {std::to_string(who->recipientPersonId)});
                    if (c.empty() || !c[0]["ok"].as<bool>()) { skip(HttpStatus::CONFLICT, "not_opted_in"); continue; }
                }
                const bool parent = who->recipientPersonId != who->personId;
                const auto minted = MagicLinkService::mint(who->recipientPersonId, club ? "sms" : channel, contact, scope.userId, 0, matchId);
                const auto msg = copy.render("squad_notice", who->zone + (parent ? "_parent" : "_adult"), {
                    {"first", who->recipientFirstName}, {"child", who->playerFirstName},
                    {"event", ctx.shortEvent}, {"when", when}, {"urgent", urgentFor(who->zone)},
                    {"where", ctx.where}, {"arrival", ctx.arrival},
                    {"link", minted.url}, {"sender", senderName}});
                if (!msg.ok())
                    return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "squad_notice template missing (migration 384/593)");
                json one = {{"recipient_person_id", who->recipientPersonId},
                            {"recipient_name", who->recipientFirstName}, {"contact", contact}};
                if (club) {
                    // Brand first, opt-out last — the A2P campaign promises both.
                    const auto pre  = copy.render("club_sms", "prefix", {});
                    const auto foot = copy.render("club_sms", "footer", {});
                    const auto sent = TwilioService::getInstance().sendSms(
                        TwilioService::normalizeUs(contact), pre.body + msg.body + foot.body,
                        "game_link:" + std::to_string(matchId), who->personId, minted.tokenId);
                    if (!sent.ok) { skip(HttpStatus::BAD_GATEWAY, "The club text did not go out: " + sent.error); continue; }
                    model_->logSquadNotice(matchId, *who, "sms", contact, scope.userId);
                    one["sent"] = true;
                    one["sid"] = sent.sid;
                } else {
                    model_->logSquadNotice(matchId, *who, channel, contact, scope.userId);
                    // token_id: an FH Texter send carries it so the card's
                    // opened ✓ works for phone texts too (mig 673).
                    one["expires_at"] = minted.expiresIso;
                    one["token_id"] = minted.tokenId;
                    copy.addComposeHrefs(one, channel, contact, msg.subject, msg.body, msg.body);
                }
                sends.push_back(std::move(one));
            }
            if (sends.empty()) return jsonError(firstCode, firstErr.empty() ? "Nothing to send." : firstErr);
            // Top level = the first send (callers that predate mig 682).
            json out = sends[0];
            out["sends"] = sends;
            if (!firstErr.empty()) out["skipped"] = firstErr;
            out["status"] = model_->squadNoticeStatus(matchId);
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
            {{"event", ctx.shortEvent}, {"when", when}, {"urgent", urgentFor("group")},
             {"where", ctx.where}, {"arrival", ctx.arrival},
             {"link", link}, {"sender", senderName}});
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "squad_notice template missing (migration 383)");

        // Siblings share a parent: one contact, every player logged.  A kid
        // with two parents puts both in (mig 682); "kids" says which
        // players each contact came through, so a group text never puts
        // two parents of the same kid in one thread.
        json contacts = json::array();
        json kids = json::object();
        std::set<long long> reached, players;
        for (const auto& r : ctx.recipients) {
            players.insert(r.personId);
            const std::string& contact = channel == "sms" ? r.phone : r.email;
            if (contact.empty()) continue;
            reached.insert(r.personId);
            if (std::find(contacts.begin(), contacts.end(), json(contact)) == contacts.end())
                contacts.push_back(contact);
            kids[contact].push_back(r.personId);
            model_->logSquadNotice(matchId, r, channel, contact, scope.userId);
        }
        const long long noContact = static_cast<long long>(players.size() - reached.size());
        if (contacts.empty())
            return jsonError(HttpStatus::CONFLICT, channel == "sms"
                ? "Nobody in the squad has a mobile number on file." : "Nobody in the squad has an email on file.");

        return jsonOut(HttpStatus::CREATED, {
            {"channel",    channel},
            {"subject",    msg.subject},
            {"body",       channel == "sms" ? copy.withSmsLinkHint(msg.body) : msg.body},
            {"contacts",   contacts},
            {"kids",       kids},
            {"no_contact", noContact},
            {"status",     model_->squadNoticeStatus(matchId)},
        });
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleSquadNotice: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the game reminder");
    }
}

// POST /dues-note {match_id, person_id, channel: sms|email, recipient_person_ids?}
// Why a player who owes dues is an alternate for this game (mig 687;
// owner 2026-10-24: "a message for players who owe money and were put on
// as alternates … should be universal … explains that system puts them
// as alternates if we have enough dues paying players").  Personal: one
// per parent, each with their own sign-in link (lands on #my, where the
// balance and Pay button are).  Only for a player the dues rule flags
// (fh_dues_alternate) — the amount stays private to them.
Response RsvpBoardController::handleDuesNote(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const long long matchId = body.value("match_id", 0LL), personId = body.value("person_id", 0LL);
    const std::string channel = body.value("channel", std::string{});
    if (matchId <= 0 || personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match_id and person_id required");
    if (channel != "sms" && channel != "email") return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'sms' or 'email'");
    try {
        auto* db = Database::getInstance();
        auto d = db->query(
            "SELECT fh_dues_alternate($1::int, $2::int) AS alt, fh_dues_balance_usd($1::int) AS bal",
            {std::to_string(personId), std::to_string(WelcomeLog::kLighthouseClubId)});
        if (d.empty() || !d[0]["alt"].as<bool>())
            return jsonError(HttpStatus::CONFLICT, "That player doesn't owe dues on a team with the alternate rule.");
        char amount[32];
        std::snprintf(amount, sizeof amount, "$%.2f", d[0]["bal"].is_null() ? 0.0 : d[0]["bal"].as<double>());
        const auto ctx = model_->squadNoticeContext(matchId);
        if (!ctx.found) return jsonError(HttpStatus::NOT_FOUND, "That game is not on the calendar.");
        std::vector<RsvpBoard::Recipient> recipients;
        if (!pickRecipients(model_->messageRecipients(personId), body, &recipients))
            return jsonError(HttpStatus::BAD_REQUEST, "recipient_person_ids must be this player's parents");
        std::string senderName;
        {
            auto s = db->query("SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int",
                               {std::to_string(scope.personId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        auto pf = db->query("SELECT COALESCE(first_name,'') AS fn FROM persons WHERE id = $1::int", {std::to_string(personId)});
        const std::string playerFirst = pf.empty() ? "" : pf[0]["fn"].c_str();
        MessageCopy copy;
        const std::string when = ctx.day + " " + ctx.time;
        json sends = json::array();
        for (const auto& rcp : recipients) {
            const bool parent = rcp.personId != personId;
            auto c = db->query(std::string("SELECT fh_recipient_") + (channel == "email" ? "email" : "phone")
                               + "($1::int, $2::int) AS c", {std::to_string(rcp.personId), std::to_string(personId)});
            const std::string contact = c.empty() || c[0]["c"].is_null() ? "" : c[0]["c"].c_str();
            if (contact.empty()) continue;
            const auto minted = MagicLinkService::mint(rcp.personId, channel, contact, scope.userId);
            const auto msg = copy.render("dues_alternate_note", parent ? "parent" : "adult", {
                {"first", rcp.firstName}, {"child", playerFirst}, {"amount", amount},
                {"when", when}, {"event", ctx.shortEvent}, {"link", minted.url}, {"sender", senderName}});
            if (!msg.ok()) return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "dues_alternate_note template missing (migration 687)");
            json one = {{"recipient_person_id", rcp.personId}, {"recipient_name", rcp.firstName},
                        {"contact", contact}, {"token_id", minted.tokenId}};
            copy.addComposeHrefs(one, channel, contact, msg.subject, msg.body, msg.body);
            sends.push_back(std::move(one));
        }
        if (sends.empty()) return jsonError(HttpStatus::CONFLICT, channel == "email" ? "No email on file." : "No mobile number on file.");
        json out = sends[0];
        out["sends"] = sends;
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleDuesNote: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the dues note");
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

// GET /text-marks?match_id= — Game Center's per-card club-text marks (mig
// 647): the latest club-number text per player and kind (game_link /
// reg_link) with its delivery state and first real open, plus who can be
// texted from the club number at all (opted in — the parent for youth).
Response RsvpBoardController::handleTextMarks(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    long long matchId = 0;
    try { matchId = std::stoll(request.getQueryParam("match_id")); } catch (const std::exception&) {}
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match_id required");
    try {
        auto* db = Database::getInstance();
        auto ev = db->query("SELECT id FROM fh_events WHERE match_id = $1::int ORDER BY id LIMIT 1", {std::to_string(matchId)});
        if (ev.empty()) return jsonOut(HttpStatus::OK, {{"marks", json::object()}, {"opted_in", json::array()}});
        const std::string fhEventId = ev[0]["id"].c_str();
        json marks = json::object();
        for (const auto& r : db->query(
                "SELECT person_id, kind, status, error_code, error_text, "
                "       to_char(sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS sent_at, "
                "       to_char(opened_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS opened_at, via, "
                "       recipient_person_id "
                "  FROM fh_game_text_marks($1::int, $2::bigint) ORDER BY sent_at", {std::to_string(matchId), fhEventId})) {
            json m = json::object();
            for (const char* k : {"status", "error_code", "error_text", "sent_at", "opened_at", "via"})
                m[k] = r[k].is_null() ? json(nullptr) : json(r[k].c_str());
            m["recipient_person_id"] = r["recipient_person_id"].is_null() ? json(nullptr) : json(r["recipient_person_id"].as<long long>());
            // [pid][kind] = the newest (compat); [pid][kind + "_by"] = one per
            // parent, so a two-parent card shows both (mig 683).
            marks[r["person_id"].c_str()][r["kind"].c_str()] = m;
            marks[r["person_id"].c_str()][std::string(r["kind"].c_str()) + "_by"].push_back(m);
        }
        // Each card's contact state (mig 649): who a text reaches (the
        // parent for a child account), opted in / STOPped / neither, their
        // mobile and email, and the latest reply to the club number.
        json people = json::object();
        json optedIn = json::array();
        for (const auto& r : db->query(
                "SELECT person_id, recipient_person_id, recipient_name, consent, phone, email, reply_body, "
                "       to_char(reply_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS reply_at "
                "  FROM fh_game_contact_states($1::bigint) ORDER BY person_id, ord", {fhEventId})) {
            json p = json::object();
            for (const char* k : {"consent", "phone", "email", "reply_body", "reply_at", "recipient_name"})
                p[k] = r[k].is_null() ? json(nullptr) : json(r[k].c_str());
            p["recipient_person_id"] = r["recipient_person_id"].as<long long>();
            // One row per parent (mig 683): the card's top-level fields are
            // the primary's (as before); recipients[] holds every parent.
            const std::string pid = r["person_id"].c_str();
            if (!people.contains(pid)) {
                people[pid] = p;
                if (std::string(r["consent"].c_str()) == "in") optedIn.push_back(r["person_id"].as<long long>());
            }
            people[pid]["recipients"].push_back(p);
        }
        return jsonOut(HttpStatus::OK, {{"marks", marks}, {"opted_in", optedIn}, {"people", people}});
    } catch (const std::exception& e) {
        std::cerr << "RsvpBoardController::handleTextMarks: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the text marks");
    }
}
