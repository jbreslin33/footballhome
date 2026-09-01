#include "MyController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../services/WebPushService.h"
#include "../third_party/json.hpp"

#include <exception>
#include <iostream>
#include <map>
#include <optional>
#include <string>
#include <thread>
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

// Decode a JWT payload, look for the string "userId" claim (which is
// what AuthController emits at login time), then map users.id →
// persons.id.  Returns 0 on any failure.  Only called after the
// signature has been verified by verifyJwtHS256.
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

struct SessionGate {
    std::optional<SessionService::ResolvedSession> session;
    std::optional<Response>                        error;
};

// Accepts either the fh_sess cookie session OR a JWT bearer.  MyController
// endpoints are called from both the magic-link flow (cookie) and the
// regular password/OAuth flow (JWT), so we transparently support both.
//
// SECURITY: When BOTH a Bearer JWT and an fh_sess cookie are present we
// prefer the Bearer JWT.  The JWT is scoped to localStorage of the
// specific browser/tab that just logged in via OAuth, while the cookie
// can bleed across users on shared devices (e.g. someone clicked a
// different user's magic-link email on this phone earlier).  Preferring
// the JWT prevents the "logged in as A but seeing B's data" class of
// bug — the 2026-07-06 incident that motivated this comment.
SessionGate requireSession(const Request& request) {
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long personId = personIdFromJwtPayload(payloadJson);
            if (personId > 0) {
                SessionService::ResolvedSession synth;
                synth.sessionId = "";
                synth.personId  = personId;
                return {std::move(synth), std::nullopt};
            }
        }
    }

    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (resolved) {
        return {std::move(resolved), std::nullopt};
    }

    return {std::nullopt,
            jsonError(HttpStatus::UNAUTHORIZED,
                      sessVal.empty() ? "Not signed in" : "Session expired")};
}

// ─── View-as / impersonation (2026-07-11) ───────────────────────────
// If `?asPersonId=N` is set in the query string, this helper swaps the
// caller's own person_id for N so reads render exactly what that
// person would see.  Gated to admins only, and refused on writes —
// writes always execute as the actual caller.
std::optional<Response> applyImpersonation(const Request& request,
                                            long long authPersonId,
                                            bool allowImpersonation,
                                            long long* effectivePersonId) {
    *effectivePersonId = authPersonId;
    const std::string q = request.getQueryParam("asPersonId");
    if (q.empty()) return std::nullopt;
    long long target = 0;
    try { target = std::stoll(q); } catch (...) { target = 0; }
    if (target <= 0 || target == authPersonId) return std::nullopt;

    if (!allowImpersonation) {
        return jsonError(HttpStatus::FORBIDDEN,
                          "view-as is read-only — write endpoints must run as the actual caller");
    }

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
        std::cerr << "[applyImpersonation] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                          "view-as check failed");
    }
    *effectivePersonId = target;
    return std::nullopt;
}

// ─── Club chat helpers ───────────────────────────────────────────────
//
// Three club-wide chats: mens, womens, and youth (boys + girls
// combined — teams.gender_category has no 'girls' value, and LA
// tracks Boys/Girls Club as separate but sibling memberships).
//
// Membership is driven by active LA registration (person_la_memberships
// joined to leagueapps_programs), not FH's own team_persons roster —
// LA is the source of truth, and this is exactly the kind of
// membership-gated feature that must never run on stale FH-side data.
// Checked in order below; the first slug a caller matches is "their"
// chat, so priority only matters for the (rare) person who'd otherwise
// match more than one.
// Database::query() only takes string params, so the pattern list
// travels as a single Postgres array literal — {"a","b"} — cast to
// text[] at the call site.
std::string pgTextArrayLiteral(const std::vector<std::string>& items) {
    std::string out = "{";
    for (size_t i = 0; i < items.size(); ++i) {
        if (i > 0) out += ',';
        out += '"';
        out += items[i];
        out += '"';
    }
    out += '}';
    return out;
}

struct ChatRule {
    const char* slug;
    const char* pushLabel;
    std::vector<std::string> laProgramPatterns;  // ILIKE ANY patterns
    bool includesChildren;   // also match via persons.parent_person_id
    bool adminFallback;      // admins with no matching membership land here
};

const std::vector<ChatRule>& chatRules() {
    static const std::vector<ChatRule> rules = {
        {"mens",   "Men's Chat",   {"Lighthouse Men%Club%"},                          false, true},
        {"womens", "Women's Chat", {"Lighthouse Women%Club%"},                        false, false},
        {"youth",  "Youth Chat",   {"Lighthouse Boys%Club%", "Lighthouse Girl%Club%"}, true,  false},
    };
    return rules;
}

const ChatRule* chatRuleForSlug(const std::string& slug) {
    for (const auto& rule : chatRules()) {
        if (slug == rule.slug) return &rule;
    }
    return nullptr;
}

long long chatIdForSlug(const std::string& slug) {
    static std::map<std::string, long long> cache;
    auto it = cache.find(slug);
    if (it != cache.end()) return it->second;
    long long id = 0;
    try {
        auto* db = Database::getInstance();
        auto r = db->query("SELECT id FROM chats WHERE slug = $1 LIMIT 1", {slug});
        if (!r.empty() && !r[0]["id"].is_null()) {
            id = r[0]["id"].as<long long>();
        }
    } catch (...) {}
    cache[slug] = id;
    return id;
}

bool isAdmin(long long personId) {
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
            " WHERE u.person_id = $1::int LIMIT 1",
            {std::to_string(personId)});
        return !r.empty();
    } catch (...) {
        return false;
    }
}

// Return true if the caller is allowed to read/post in the given chat.
bool isChatMember(long long personId, const std::string& slug) {
    if (personId <= 0) return false;
    const ChatRule* rule = chatRuleForSlug(slug);
    if (!rule) return false;
    if (rule->adminFallback && isAdmin(personId)) return true;
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT EXISTS ("
            "  SELECT 1 FROM person_la_memberships plm "
            "    JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "   WHERE plm.person_id = $1::int AND plm.ended_at IS NULL "
            "     AND lp.program_name ILIKE ANY($2::text[]) "
            "     AND lp.program_name NOT ILIKE '%Inactive%' "
            "  UNION ALL "
            "  SELECT 1 FROM person_la_memberships plm "
            "    JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "    JOIN persons child ON child.id = plm.person_id "
            "   WHERE $3::bool AND child.parent_person_id = $1::int "
            "     AND plm.ended_at IS NULL "
            "     AND lp.program_name ILIKE ANY($2::text[]) "
            "     AND lp.program_name NOT ILIKE '%Inactive%'"
            ") AS is_member",
            {std::to_string(personId),
             pgTextArrayLiteral(rule->laProgramPatterns),
             rule->includesChildren ? "true" : "false"});
        return !r.empty() && r[0]["is_member"].as<bool>();
    } catch (const std::exception& e) {
        std::cerr << "[isChatMember] " << e.what() << std::endl;
        return false;
    }
}

// Which chat should this viewer's single "My" chat box show? Empty
// string means they're not eligible for any club chat.
std::string chatSlugForPerson(long long personId) {
    for (const auto& rule : chatRules()) {
        if (isChatMember(personId, rule.slug)) return rule.slug;
    }
    return {};
}

// Everyone currently eligible for the given chat, minus the sender —
// the push fan-out list for a new chat message.
std::vector<long long> chatMemberPersonIds(const std::string& slug, long long excludePersonId) {
    std::vector<long long> out;
    const ChatRule* rule = chatRuleForSlug(slug);
    if (!rule) return out;
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT DISTINCT person_id FROM ("
            "  SELECT plm.person_id FROM person_la_memberships plm "
            "    JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "   WHERE plm.ended_at IS NULL AND lp.program_name ILIKE ANY($1::text[]) "
            "     AND lp.program_name NOT ILIKE '%Inactive%' "
            "  UNION "
            "  SELECT child.parent_person_id FROM person_la_memberships plm "
            "    JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "    JOIN persons child ON child.id = plm.person_id "
            "   WHERE $2::bool AND child.parent_person_id IS NOT NULL "
            "     AND plm.ended_at IS NULL AND lp.program_name ILIKE ANY($1::text[]) "
            "     AND lp.program_name NOT ILIKE '%Inactive%' "
            "  UNION "
            "  SELECT u.person_id FROM admins a JOIN users u ON u.id = a.user_id "
            "   WHERE $3::bool "
            ") AS members "
            "WHERE person_id != $4::int",
            {pgTextArrayLiteral(rule->laProgramPatterns),
             rule->includesChildren ? "true" : "false",
             rule->adminFallback ? "true" : "false",
             std::to_string(excludePersonId)});
        out.reserve(r.size());
        for (const auto& row : r) {
            if (!row["person_id"].is_null()) out.push_back(row["person_id"].as<long long>());
        }
    } catch (const std::exception& e) {
        std::cerr << "[chatMemberPersonIds] " << e.what() << std::endl;
    }
    return out;
}

// users.id for caller.  chat_messages.user_id is NOT NULL, so a
// missing users row means "cannot post" (403).
std::string usersIdForPerson(long long personId) {
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT id FROM users WHERE person_id = $1::int LIMIT 1",
            {std::to_string(personId)});
        if (!r.empty() && !r[0]["id"].is_null()) {
            return std::to_string(r[0]["id"].as<long long>());
        }
    } catch (...) {}
    return {};
}

std::string trimCopy(const std::string& s) {
    auto b = s.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return {};
    auto e = s.find_last_not_of(" \t\r\n");
    return s.substr(b, e - b + 1);
}

}  // namespace

MyController::MyController() = default;
MyController::~MyController() = default;

void MyController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix is "/api/my".
    router.get (prefix + "/chat/messages",  [this](const Request& r) { return handleGetChatMessages(r); });
    router.post(prefix + "/chat/messages",  [this](const Request& r) { return handlePostChatMessage(r); });
    router.post(prefix + "/events/push-remind", [this](const Request& r) { return handlePushRemind(r); });
    router.post(prefix + "/push-test", [this](const Request& r) { return handlePushTest(r); });
}

// GET /api/my/chat/messages?since_id=<int>
Response MyController::handleGetChatMessages(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    long long personId = gate.session->personId;
    if (auto err = applyImpersonation(request, personId, /*allowImpersonation=*/true, &personId))
        return *err;

    const std::string slug = chatSlugForPerson(personId);
    if (slug.empty()) {
        return jsonError(HttpStatus::FORBIDDEN, "Not a member of any club chat");
    }

    const long long chatId = chatIdForSlug(slug);
    if (chatId <= 0) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "chat not configured");
    }

    long long sinceId = 0;
    const std::string sinceStr = request.getQueryParam("since_id");
    if (!sinceStr.empty()) {
        try { sinceId = std::stoll(sinceStr); } catch (...) { sinceId = 0; }
    }

    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT cm.id, cm.user_id, u.person_id, "
            "       p.first_name, p.last_name, cm.message, "
            "       TO_CHAR(cm.created_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at "
            "  FROM chat_messages cm "
            "  JOIN users   u ON u.id = cm.user_id "
            "  JOIN persons p ON p.id = u.person_id "
            " WHERE cm.chat_id = $1::int "
            "   AND cm.id > $2::int "
            " ORDER BY cm.created_at DESC, cm.id DESC "
            " LIMIT 200",
            {std::to_string(chatId), std::to_string(sinceId)});

        std::vector<json> messages;
        messages.reserve(r.size());
        for (auto it = r.rbegin(); it != r.rend(); ++it) {
            const auto& row = *it;
            messages.push_back({
                {"id",                row["id"].as<long long>()},
                {"user_id",           row["user_id"].as<long long>()},
                {"person_id",         row["person_id"].as<long long>()},
                {"author_first_name", row["first_name"].is_null() ? std::string{} : row["first_name"].as<std::string>()},
                {"author_last_name",  row["last_name"].is_null()  ? std::string{} : row["last_name"].as<std::string>()},
                {"message",           row["message"].as<std::string>()},
                {"created_at",        row["created_at"].as<std::string>()},
            });
        }
        const std::string viewerIdStr = usersIdForPerson(personId);
        const long long   viewerId    = viewerIdStr.empty() ? 0 : std::stoll(viewerIdStr);

        return jsonOk({
            {"chat_id",        chatId},
            {"viewer_user_id", viewerId},
            {"messages",       messages},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/my/chat/messages] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/my/chat/messages
Response MyController::handlePostChatMessage(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    long long personId = gate.session->personId;
    if (auto err = applyImpersonation(request, personId, /*allowImpersonation=*/false, &personId))
        return *err;

    const std::string slug = chatSlugForPerson(personId);
    if (slug.empty()) {
        return jsonError(HttpStatus::FORBIDDEN, "Not a member of any club chat");
    }

    const long long chatId = chatIdForSlug(slug);
    if (chatId <= 0) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "chat not configured");
    }

    const std::string userIdStr = usersIdForPerson(personId);
    if (userIdStr.empty()) {
        return jsonError(HttpStatus::FORBIDDEN, "no users row for caller");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    if (!body.contains("message") || !body["message"].is_string()) {
        return jsonError(HttpStatus::BAD_REQUEST, "message string required");
    }
    const std::string trimmed = trimCopy(body["message"].get<std::string>());
    if (trimmed.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "message cannot be blank");
    }
    if (trimmed.size() > 2000) {
        return jsonError(HttpStatus::BAD_REQUEST, "message too long (max 2000 chars)");
    }

    try {
        auto* db = Database::getInstance();

        // Rate limit: caller has posted <3 rows to this chat in the
        // last 10 seconds.  Cheap query — chat_messages is indexed
        // by (chat_id) and (user_id).
        auto rl = db->query(
            "SELECT COUNT(*) AS n FROM chat_messages "
            " WHERE chat_id = $1::int "
            "   AND user_id = $2::int "
            "   AND created_at > NOW() - INTERVAL '10 seconds'",
            {std::to_string(chatId), userIdStr});
        const long long recent = rl.empty() ? 0 : rl[0]["n"].as<long long>();
        if (recent >= 3) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "slow down — 3 messages / 10 sec limit");
        }

        auto ins = db->query(
            "INSERT INTO chat_messages (chat_id, user_id, message) "
            "VALUES ($1::int, $2::int, $3) "
            "RETURNING id, "
            "  TO_CHAR(created_at AT TIME ZONE 'UTC', "
            "          'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at",
            {std::to_string(chatId), userIdStr, trimmed});

        if (ins.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "insert failed");
        }

        auto meta = db->query(
            "SELECT p.first_name, p.last_name, u.person_id "
            "  FROM users u JOIN persons p ON p.id = u.person_id "
            " WHERE u.id = $1::int LIMIT 1",
            {userIdStr});

        json out = {
            {"id",         ins[0]["id"].as<long long>()},
            {"user_id",    std::stoll(userIdStr)},
            {"message",    trimmed},
            {"created_at", ins[0]["created_at"].as<std::string>()},
        };
        std::string senderFirstName = "Someone";
        if (!meta.empty()) {
            out["author_first_name"] = meta[0]["first_name"].is_null() ? std::string{} : meta[0]["first_name"].as<std::string>();
            out["author_last_name"]  = meta[0]["last_name"].is_null()  ? std::string{} : meta[0]["last_name"].as<std::string>();
            out["person_id"]         = meta[0]["person_id"].as<long long>();
            if (!meta[0]["first_name"].is_null()) senderFirstName = meta[0]["first_name"].as<std::string>();
        }

        // Push fan-out — fire-and-forget on a detached thread so a slow
        // or unreachable push service never delays the chat POST
        // response. Recipients: current membership of this chat (same
        // rule as isChatMember), minus the sender.
        {
            const ChatRule* rule = chatRuleForSlug(slug);
            const std::string pushTitle = senderFirstName + " — " + (rule ? rule->pushLabel : "Club Chat");
            std::string pushBody = trimmed;
            if (pushBody.size() > 160) pushBody = pushBody.substr(0, 157) + "...";
            auto recipients = chatMemberPersonIds(slug, personId);
            std::thread([recipients, pushTitle, pushBody]() {
                for (long long recipientId : recipients) {
                    WebPushService::getInstance().sendToPerson(recipientId, pushTitle, pushBody, "/#my");
                }
            }).detach();
        }

        return jsonOk(out);
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/chat/messages] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/my/events/push-remind — {fh_event_id, person_id}
Response MyController::handlePushRemind(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    long long callerPersonId = gate.session->personId;
    if (auto err = applyImpersonation(request, callerPersonId, /*allowImpersonation=*/false, &callerPersonId))
        return *err;

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    long long fhEventId = 0, targetPersonId = 0;
    if (body.contains("fh_event_id") && body["fh_event_id"].is_number_integer())
        fhEventId = body["fh_event_id"].get<long long>();
    if (body.contains("person_id") && body["person_id"].is_number_integer())
        targetPersonId = body["person_id"].get<long long>();
    if (fhEventId <= 0 || targetPersonId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id and person_id required");
    }

    try {
        auto* db = Database::getInstance();

        // Same gate as CalendarController::isEventCoachOrAdmin (club
        // admin, or a coach of one of the event's teams) — duplicated
        // here rather than shared across controllers, same call as
        // that function's own doc comment on why.
        auto canRemindRows = db->query(
            "SELECT ("
            "  EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id WHERE u.person_id = $2::int)"
            "  OR EXISTS ("
            "    SELECT 1 FROM fh_event_teams fet "
            "    JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL "
            "    JOIN coaches co ON co.id = tc.coach_id "
            "    WHERE fet.fh_event_id = $1::bigint AND co.person_id = $2::int"
            "  )"
            ") AS can_remind",
            {std::to_string(fhEventId), std::to_string(callerPersonId)});
        if (canRemindRows.empty() || !canRemindRows[0]["can_remind"].as<bool>()) {
            return jsonError(HttpStatus::FORBIDDEN,
                             "Only a coach or admin can send an RSVP reminder for this event");
        }

        // Target must be on the event's roster (player or coach on one
        // of its teams) AND have no response on file yet — a stale UI
        // can't re-ping someone who already answered, and this can't be
        // used to push arbitrary people who aren't even on the event.
        auto targetRows = db->query(
            "SELECT ge.summary, fe.kind "
            "  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            " WHERE fe.id = $1::bigint "
            "   AND EXISTS ("
            "     SELECT 1 FROM fh_event_teams fet "
            "     WHERE fet.fh_event_id = fe.id AND ("
            "       EXISTS (SELECT 1 FROM team_persons tp WHERE tp.team_id = fet.team_id "
            "               AND tp.person_id = $2::int AND tp.removed_at IS NULL) "
            "       OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
            "                  WHERE tc.team_id = fet.team_id AND tc.ended_at IS NULL AND co.person_id = $2::int) "
            "     )"
            "   ) "
            "   AND NOT EXISTS (SELECT 1 FROM fh_event_rsvps r "
            "                    WHERE r.fh_event_id = fe.id AND r.person_id = $2::int "
            "                      AND r.response IS NOT NULL)",
            {std::to_string(fhEventId), std::to_string(targetPersonId)});
        if (targetRows.empty()) {
            return jsonError(HttpStatus::CONFLICT,
                             "That person already responded, or isn't on this event's roster");
        }

        std::string eventLabel = targetRows[0]["summary"].is_null()
            ? std::string() : targetRows[0]["summary"].as<std::string>();
        if (eventLabel.empty()) {
            eventLabel = targetRows[0]["kind"].is_null()
                ? std::string("an upcoming event") : targetRows[0]["kind"].as<std::string>();
        }
        const std::string pushBody = "Don't forget to RSVP for " + eventLabel + "!";

        const int sent = WebPushService::getInstance()
            .sendToPerson(targetPersonId, "RSVP needed", pushBody, "/#my");
        return jsonOk({{"sent", sent}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/events/push-remind] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/my/push-test — no body. Always targets the CALLER's own
// person_id, never anyone else — see MyController.h doc on why this
// has no target param at all (push-remind is the only path that can
// reach another person, and it's coach/admin-gated).
Response MyController::handlePushTest(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = gate.session->personId;

    try {
        const int sent = WebPushService::getInstance().sendToPerson(
            personId, "Test notification",
            "Push notifications are working! 🎉", "/#my");
        return jsonOk({{"sent", sent}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/push-test] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
