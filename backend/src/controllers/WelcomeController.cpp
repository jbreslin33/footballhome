#include "WelcomeController.h"

#include <cctype>
#include <iostream>
#include <sstream>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../models/WelcomeLog.h"
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
    : model_(std::make_unique<WelcomeLog>()) {}
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
    // DOCS reminder when the placement is already known.  The form URL
    // travels with the request so the frontend's DOCS_FORM_URL stays the
    // single source of truth.
    const bool needsDocs = body.contains("needs_docs") && body["needs_docs"].is_boolean()
                           && body["needs_docs"].get<bool>();
    const std::string docsFormUrl = readStr(body, "docs_form_url");
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
        if (firstName.empty()) firstName = "there";

        // Youth: the child the message is about.  A player_person_id that
        // equals the recipient is an adult welcoming themselves — no child.
        const std::string childName = (playerPersonId > 0 && playerPersonId != personId)
            ? firstNameOf(db, playerPersonId) : std::string{};
        const bool youth = !childName.empty();

        // Sign-off: the sending admin's own name (users → persons), falling
        // back to the club signature the LINK buttons already use.
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
        const std::string signOff = senderName.empty()
            ? std::string("— Lighthouse Soccer")
            : "— " + senderName + "\nSoccer Director\nLighthouse 1893 SC";

        const auto minted = MagicLinkService::mint(personId, channel, contact, adminUserId);

        // ── Copy ───────────────────────────────────────────────────
        // Parent copy names the child; adult copy is first-person.  Same
        // structure as the LINK invite so the two read as one voice.
        const std::string whose    = youth ? childName + "'s" : "your";
        const std::string subject  = "Welcome to Lighthouse 1893 SC!";

        std::ostringstream b;
        b << "Hi " << firstName << ",\n\n"
          << "Welcome to Lighthouse 1893 — we're glad "
          << (youth ? childName + " is" : "you're") << " playing with us.\n\n"
          << "footballhome.org is where each week's practices, games and pickups are posted, "
          << "and where you set " << whose << " availability so the coaches know who's coming. "
          << "Tap the link below on your phone — no password needed — and you'll land on "
          << whose << " schedule:\n"
          << minted.url << "\n\n"
          << "On the page you can:\n"
          << "  • RSVP YES / NO for each practice and game\n"
          << "  • Set default availability by day so the page fills itself in\n"
          << "  • Add it to your home screen — it works like an app\n\n"
          << "The link signs you in automatically and expires in 72 hours. "
          << "If it has expired by the time you open it, just reply and I'll send a fresh one.\n\n";
        const bool docsAsk = youth && needsDocs && !docsFormUrl.empty();
        if (docsAsk) {
            b << "One more thing: since " << childName << " is on a travel team, the Philadelphia "
              << "Parks & Rec league needs a copy of " << childName << "'s birth certificate and a "
              << "headshot. Please upload both here when you get a chance — travel spots are "
              << "confirmed as forms come in:\n"
              << docsFormUrl << "\n\n";
        }
        b << "Reply anytime with questions.\n\n"
          << signOff;
        const std::string bodyText = b.str();

        std::string smsBody =
            "Hi " + firstName + " — welcome to Lighthouse 1893! Practices, games and pickups are "
            "posted at footballhome.org. Tap to see " + whose + " schedule and set availability "
            "(no password needed): " + minted.url;
        if (docsAsk) {
            smsBody += " Also, for " + childName + "'s travel spot please upload a birth certificate + headshot: " + docsFormUrl;
        }

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
        if (channel == "email") {
            out["mailto_href"] = "mailto:" + fh::crypto::urlEncode(contact)
                               + "?subject=" + fh::crypto::urlEncode(subject)
                               + "&body="    + fh::crypto::urlEncode(bodyText);
            out["gmail_href"]  = std::string("https://mail.google.com/mail/?")
                               + "view=cm&fs=1"
                               + "&authuser=" + fh::crypto::urlEncode("soccer@lighthouse1893.org")
                               + "&to="       + fh::crypto::urlEncode(contact)
                               + "&su="       + fh::crypto::urlEncode(subject)
                               + "&body="     + fh::crypto::urlEncode(bodyText);
        } else {
            out["sms_href"] = "sms:" + fh::crypto::urlEncode(contact)
                            + "?body=" + fh::crypto::urlEncode(smsBody);
        }
        Response r(HttpStatus::CREATED, out.dump());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/welcomes] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
