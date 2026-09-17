#include "WelcomeController.h"

#include <cctype>
#include <iostream>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../models/WelcomeLog.h"
#include "../models/WelcomeMessage.h"
#include "../models/MessageCopy.h"
#include "../services/MagicLinkService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

long long readInt(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return 0;
    if (it->is_number_integer())  return it->get<long long>();
    if (it->is_number_unsigned()) return static_cast<long long>(it->get<unsigned long long>());
    if (it->is_number_float())    return static_cast<long long>(it->get<double>());
    if (it->is_string()) {
        try { return std::stoll(it->get<std::string>()); } catch (...) { return 0; }
    }
    return 0;
}

std::string readStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    std::string s = it->get<std::string>();
    auto issp = [](unsigned char c) { return std::isspace(c) != 0; };
    while (!s.empty() && issp(static_cast<unsigned char>(s.front()))) s.erase(s.begin());
    while (!s.empty() && issp(static_cast<unsigned char>(s.back())))  s.pop_back();
    return s;
}

std::string lower(std::string s) {
    for (auto& c : s) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    return s;
}

Response jsonError(HttpStatus s, const std::string& message) {
    json body = {{"error", message}};
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

std::string firstNameOf(Database* db, long long personId) {
    if (personId <= 0) return {};
    auto rows = db->query(
        "SELECT COALESCE(first_name, '') AS fn FROM persons WHERE id = $1::int LIMIT 1",
        {std::to_string(personId)});
    return rows.empty() ? std::string{} : std::string(rows[0]["fn"].c_str());
}

} // namespace

WelcomeController::WelcomeController()
    : model_(std::make_unique<WelcomeLog>()),
      message_(std::make_unique<WelcomeMessage>()) {}
WelcomeController::~WelcomeController() = default;

void WelcomeController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix, [this](const Request& r) { return handleCreate(r); });
}

Response WelcomeController::handleCreate(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    const long long adminUserId = bearerUserId(request);

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const long long personId       = readInt(body, "person_id");
    const long long playerPersonId = readInt(body, "player_person_id");
    const std::string channel      = lower(readStr(body, "channel"));
    const std::string contact      = readStr(body, "contact");
    // Youth travel columns only (frontend decides via columnNeedsDocs):
    // append the travel-documents ask so the coach can skip the separate
    // DOCS reminder when the placement is already known.  The form link
    // itself is a club_forms row the copy names (migration 365).
    const bool needsDocs = body.contains("needs_docs") && body["needs_docs"].is_boolean()
                           && body["needs_docs"].get<bool>();
    if (personId <= 0)                           return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    if (channel != "email" && channel != "sms") return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'email' or 'sms'");
    if (contact.empty())                         return jsonError(HttpStatus::BAD_REQUEST, "contact required");

    auto* db = Database::getInstance();
    try {
        auto personRow = db->query(
            "SELECT COALESCE(first_name, '') AS fn FROM persons WHERE id = $1::int LIMIT 1",
            {std::to_string(personId)});
        if (personRow.empty()) return jsonError(HttpStatus::NOT_FOUND, "Person not found");
        std::string firstName = personRow[0]["fn"].c_str();

        // Youth: the child the message is about.  A player_person_id that
        // equals the recipient is an adult welcoming themselves — no child.
        const std::string childName = (playerPersonId > 0 && playerPersonId != personId)
            ? firstNameOf(db, playerPersonId) : std::string{};
        const bool youth = !childName.empty();

        // Sign-off: the sending admin's own name (users → persons), else
        // the club's.
        std::string senderName;
        if (adminUserId > 0) {
            try {
                auto s = db->query(
                    "SELECT TRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS nm "
                    "  FROM users u JOIN persons p ON p.id = u.person_id WHERE u.id = $1::int LIMIT 1",
                    {std::to_string(adminUserId)});
                if (!s.empty() && !s[0]["nm"].is_null()) senderName = s[0]["nm"].c_str();
            } catch (...) {}
        }
        if (senderName.empty()) {
            auto c = db->query("SELECT COALESCE(name,'') AS nm FROM clubs WHERE id = $1::int",
                               {std::to_string(WelcomeLog::kLighthouseClubId)});
            if (!c.empty()) senderName = c[0]["nm"].c_str();
        }

        // ── Copy ───────────────────────────────────────────────────
        // Every sentence is a message_templates row and every fact comes
        // from the player's schedule (WelcomeMessage, migration 364).
        const auto facts = message_->factsFor(youth ? playerPersonId : personId,
                                              WelcomeLog::kLighthouseClubId);

        const auto minted = MagicLinkService::mint(personId, channel, contact, adminUserId);

        MessageCopy copy;
        WelcomeMessage::Tokens tokens;
        tokens.first    = firstName.empty() ? copy.render("fallback", "first", {}).body : firstName;
        tokens.child    = childName;
        tokens.link     = minted.url;
        tokens.sender   = senderName;
        tokens.docsAsk  = youth && needsDocs;
        const auto msg = message_->render(channel, youth, WelcomeLog::kLighthouseClubId, facts, tokens);
        if (!msg.ok())
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "welcome template missing (migration 364)");
        const std::string subject  = msg.subject;
        const std::string bodyText = msg.body;

        model_->record(personId, youth ? playerPersonId : 0, channel, contact, adminUserId);

        // Fresh "last sent" for the card so the button can repaint without
        // a roster reload.
        auto nowRow = db->query(
            "SELECT TO_CHAR(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS iso");
        json welcome = {
            {"due",         false},
            {"lastSentAt",  nowRow.empty() ? json(nullptr) : json(std::string(nowRow[0]["iso"].c_str()))},
            {"lastChannel", channel},
            {"lastContact", contact},
        };

        json out = {
            {"url",        minted.url},
            {"expires_at", minted.expiresIso},
            {"welcome",    welcome},
        };
        copy.addComposeHrefs(out, channel, contact, subject, bodyText, bodyText);
        Response r(HttpStatus::CREATED, out.dump());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/welcomes] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
