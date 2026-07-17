#include "LeadsController.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstring>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <regex>
#include <set>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "../database/Database.h"
#include "../models/Lead.h"
#include "../models/LeadContact.h"
#include "../models/MensRoster.h"
#include "../models/YouthRoster.h"
#include "../services/LeagueAppsService.h"
#include "../services/MetaLeadsService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// ── JSON-byte helpers ──────────────────────────────────────────────────────
// nlohmann::json sorts keys alphabetically when dumping; the Node webhook
// emits keys in SELECT/insert order.  Every response that needs byte-parity
// is built manually with ostringstream + the helpers below.

std::string jsonEscape(const std::string& s) { return json(s).dump(); }

std::string jsonStr(const std::string& s) {
    return jsonEscape(s);
}

std::string jsonOrNull(const std::optional<std::string>& v) {
    return v.has_value() ? jsonEscape(*v) : std::string{"null"};
}

std::string jsonInt(int v)         { return std::to_string(v); }
std::string jsonLong(long long v)  { return std::to_string(v); }
std::string jsonBool(bool v)       { return v ? "true" : "false"; }

// Compact JSON-ify a parsed jsonb value, falling back to "null" when
// the model carries an unparsable / SQL NULL value.
std::string jsonValue(const json& v) {
    if (v.is_null()) return "null";
    return v.dump();
}

// ── Error responses (byte-equal to Node) ───────────────────────────────────
Response errJson(HttpStatus code, const std::string& msg) {
    std::ostringstream b;
    b << "{\"error\":" << jsonEscape(msg) << "}";
    Response r(code, b.str());
    r.setHeader("Content-Type", "application/json");
    return r;
}

Response errOk(HttpStatus code, const std::string& bodyJson) {
    Response r(code, bodyJson);
    r.setHeader("Content-Type", "application/json");
    return r;
}

// ── Lead → JSON (single row, key order matches Node SELECT) ────────────────
std::string serializeLead(const Lead& l) {
    std::ostringstream o;
    o << "{"
      <<  "\"id\":"                << jsonInt(l.id)
      << ",\"leadgen_id\":"        << jsonStr(l.leadgenId)
      << ",\"form_id\":"           << jsonStr(l.formId)
      << ",\"page_id\":"           << jsonOrNull(l.pageId)
      << ",\"ad_id\":"             << jsonOrNull(l.adId)
      << ",\"name\":"              << jsonOrNull(l.name)
      << ",\"email\":"             << jsonOrNull(l.email)
      << ",\"phone\":"             << jsonOrNull(l.phone)
      << ",\"raw_fields\":"        << jsonValue(l.rawFields)
      << ",\"preferred_channel\":" << jsonOrNull(l.preferredChannel)
      << ",\"created_at\":"        << jsonStr(l.createdAtIso)
      << ",\"email_count\":"       << jsonInt(l.emailCount)
      << ",\"text_count\":"        << jsonInt(l.textCount)
      << ",\"call_count\":"        << jsonInt(l.callCount)
      << ",\"last_email_at\":"     << jsonOrNull(l.lastEmailAtIso)
      << ",\"last_text_at\":"      << jsonOrNull(l.lastTextAtIso)
      << ",\"last_call_at\":"      << jsonOrNull(l.lastCallAtIso)
      << ",\"last_email_template\":" << jsonOrNull(l.lastEmailTemplate)
      << ",\"last_text_template\":"  << jsonOrNull(l.lastTextTemplate)
      << ",\"last_call_template\":"  << jsonOrNull(l.lastCallTemplate)
      << ",\"converted_at\":"      << jsonOrNull(l.convertedAtIso)
      << ",\"converted_source\":"  << jsonOrNull(l.convertedSource)
      << ",\"converted_note\":"    << jsonOrNull(l.convertedNote)
      << ",\"needs_followup\":"    << jsonBool(l.needsFollowup)
      << ",\"dead_at\":"           << jsonOrNull(l.deadAtIso)
      << ",\"status_override\":"   << jsonOrNull(l.statusOverride)
      << ",\"status\":"            << jsonStr(l.status)
      << "}";
    return o.str();
}

// ── vCard generation ──────────────────────────────────────────────────────
std::string vcardEscape(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i];
        if (c == '\\')      out += "\\\\";
        else if (c == ',')  out += "\\,";
        else if (c == ';')  out += "\\;";
        else if (c == '\r') {
            if (i + 1 < s.size() && s[i + 1] == '\n') { out += "\\n"; ++i; }
            else                                      { out += "\\n"; }
        } else if (c == '\n') out += "\\n";
        else out.push_back(c);
    }
    return out;
}

struct VCardOpts {
    std::optional<std::string> phone;
    std::optional<std::string> email;
    std::optional<std::string> note;
};

std::string buildVCard(const std::string& displayName,
                       const std::string& fn,
                       const std::string& ln,
                       const VCardOpts&   opts) {
    std::ostringstream o;
    o << "BEGIN:VCARD\r\n"
      << "VERSION:3.0\r\n"
      << "FN:" << vcardEscape(displayName) << "\r\n"
      << "N:"  << vcardEscape(ln) << ";" << vcardEscape(fn) << ";;;\r\n";
    if (opts.phone)  o << "TEL;TYPE=CELL:"      << vcardEscape(*opts.phone) << "\r\n";
    if (opts.email)  o << "EMAIL;TYPE=INTERNET:" << vcardEscape(*opts.email) << "\r\n";
    o << "ORG:" << vcardEscape("Lighthouse 1893 SC") << "\r\n";
    if (opts.note)   o << "NOTE:" << vcardEscape(*opts.note) << "\r\n";
    o << "END:VCARD";
    return o.str();
}

// Trim helper for body strings.
std::string trimStr(const std::string& s) {
    size_t a = 0, b = s.size();
    while (a < b && std::isspace(static_cast<unsigned char>(s[a]))) ++a;
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

// Split fullName on whitespace, mirroring Node's `String#split(/\s+/)`.
std::pair<std::string, std::string>
splitName(const std::string& fullName) {
    std::vector<std::string> parts;
    std::string cur;
    for (char c : fullName) {
        if (std::isspace(static_cast<unsigned char>(c))) {
            if (!cur.empty()) { parts.push_back(cur); cur.clear(); }
        } else cur.push_back(c);
    }
    if (!cur.empty()) parts.push_back(cur);
    if (parts.empty()) return {"", ""};
    std::string first = parts[0];
    std::string last;
    for (size_t i = 1; i < parts.size(); ++i) {
        if (i > 1) last += " ";
        last += parts[i];
    }
    return {first, last};
}

// Replace runs of whitespace with underscore.  Used to build the .vcf
// filename, matching Node's `fullName.replace(/\s+/g, '_')`.
std::string slashWsToUnderscore(const std::string& s) {
    std::string out;
    bool inWs = false;
    for (char c : s) {
        if (std::isspace(static_cast<unsigned char>(c))) {
            if (!inWs) { out.push_back('_'); inWs = true; }
        } else { out.push_back(c); inWs = false; }
    }
    return out;
}

// ── JWT bearer payload decoder (no signature verify) ──────────────────────
// Mirrors the Node `requireAuth` middleware which base64url-decodes the
// payload segment and reads `userId`.  Returns std::nullopt on any parse
// failure so the contact handler falls back to inserting NULL.
std::optional<int> decodeUserIdFromBearer(const std::string& bearer) {
    if (bearer.size() < 8 || bearer.compare(0, 7, "Bearer ") != 0) {
        return std::nullopt;
    }
    const std::string token = bearer.substr(7);
    size_t firstDot = token.find('.');
    size_t lastDot  = token.find('.', firstDot == std::string::npos ? 0 : firstDot + 1);
    if (firstDot == std::string::npos || lastDot == std::string::npos) {
        return std::nullopt;
    }
    std::string payload = token.substr(firstDot + 1, lastDot - firstDot - 1);
    // base64url → base64
    for (char& c : payload) {
        if (c == '-') c = '+';
        else if (c == '_') c = '/';
    }
    while (payload.size() % 4) payload.push_back('=');
    // Manual base64 decode (small, std-only).
    static const int8_t T[256] = {
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,
        52,53,54,55,56,57,58,59,60,61,-1,-1,-1, 0,-1,-1,
        -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,
        15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,
        -1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
        41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    };
    std::string decoded;
    decoded.reserve((payload.size() * 3) / 4);
    int val = 0, bits = -8;
    for (unsigned char c : payload) {
        if (c == '=') break;
        int v = T[c];
        if (v < 0) return std::nullopt;
        val = (val << 6) | v;
        bits += 6;
        if (bits >= 0) {
            decoded.push_back(static_cast<char>((val >> bits) & 0xFF));
            bits -= 8;
        }
    }
    try {
        auto j = json::parse(decoded);
        if (!j.contains("userId")) return std::nullopt;
        const auto& u = j["userId"];
        if (u.is_number_integer())  return u.get<int>();
        if (u.is_number_unsigned()) return static_cast<int>(u.get<unsigned long long>());
        if (u.is_string()) {
            try { return std::stoi(u.get<std::string>()); }
            catch (const std::exception&) { return std::nullopt; }
        }
    } catch (const std::exception&) { return std::nullopt; }
    return std::nullopt;
}

// ── ISO timestamp formatter for the sync response ─────────────────────────
// "new Date(ms).toISOString()" → YYYY-MM-DDTHH:MM:SS.sssZ
std::string isoFromMs(long long ms) {
    using namespace std::chrono;
    std::time_t t = static_cast<std::time_t>(ms / 1000);
    int millis = static_cast<int>(ms % 1000);
    std::tm tmv{};
    gmtime_r(&t, &tmv);
    char buf[40];
    std::snprintf(buf, sizeof(buf),
                  "%04d-%02d-%02dT%02d:%02d:%02d.%03dZ",
                  tmv.tm_year + 1900, tmv.tm_mon + 1, tmv.tm_mday,
                  tmv.tm_hour, tmv.tm_min, tmv.tm_sec, millis);
    return buf;
}

} // namespace

// ────────────────────────────────────────────────────────────────────────────
// Routing
// ────────────────────────────────────────────────────────────────────────────

void LeadsController::registerRoutes(Router& router, const std::string& prefix) {
    // Bare list (no trailing slash, no suffix).
    router.get (prefix,                       [this](const Request& r){ return handleList            (r); });
    router.post(prefix + "/sync",             [this](const Request& r){ return handleSync            (r); });
    router.get (prefix + "/contact-stats",    [this](const Request& r){ return handleContactStats    (r); });
    router.get (prefix + "/next-pickup",      [this](const Request& r){ return handleNextPickup      (r); });
    // /unjoined-members renders the "Members" section which is 100% LA
    // membership state (Men / Women / Boys / Girls, active + paused +
    // pickup).  Route through laGet(dynamic) so LaProgramSync::run() is
    // called once per LA program in parallel BEFORE the handler runs —
    // the handler then reads everything from Postgres (persons +
    // aliases + person_la_memberships + person_emails + person_phones,
    // all freshly refreshed).  This eliminates the previous BANNED
    // inline `la.fetchProgramRegistrations(pid)` loop.
    laGet(router, prefix + "/unjoined-members",
        [](const Request&) { return Controller::allLaProgramIds(); },
        [this](const Request& r, const LaSyncMap& sync) {
            return handleUnjoinedMembers(r, sync);
        });
    router.get (prefix + "/analytics",        [this](const Request& r){ return handleAnalytics       (r); });
    // Public (no bearer) — landing form at /pickup posts here.  Must be
    // registered before the `:id` routes so the literal wins.
    router.post(prefix + "/guest-signup",     [this](const Request& r){ return handleGuestSignup     (r); });
    // `:id` routes go last so the literal suffixes above win.
    router.post(prefix + "/:id/contact",        [this](const Request& r){ return handleLogContact     (r); });
    router.get (prefix + "/:id/contacts",       [this](const Request& r){ return handleListContacts   (r); });
    router.del (prefix + "/:id/contacts/:cid",  [this](const Request& r){ return handleDeleteContact  (r); });
    router.get (prefix + "/:id/vcard",          [this](const Request& r){ return handleVcard          (r); });
    router.post(prefix + "/:id/mark-converted", [this](const Request& r){ return handleMarkConverted  (r); });
    router.del (prefix + "/:id/mark-converted", [this](const Request& r){ return handleUnmarkConverted(r); });
    router.post(prefix + "/:id/mark-dead",      [this](const Request& r){ return handleMarkDead       (r); });
    router.del (prefix + "/:id/mark-dead",      [this](const Request& r){ return handleUnmarkDead     (r); });
    router.post(prefix + "/:id/status-override",[this](const Request& r){ return handleSetStatusOverride(r); });
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/leads/sync?force=1
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleSync(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    const std::string force = request.getQueryParam("force");
    const bool forceFlag = (force == "1" || force == "true");

    try {
        auto r = MetaLeadsService::getInstance().syncAll(forceFlag);

        // Build {ok, syncedRows, skippedByTtl, formsSynced, formsTotal,
        //         failedForms, durationMs, lastSyncAt} in Node's key order.
        std::ostringstream b;
        b << "{\"ok\":true"
          << ",\"syncedRows\":"   << jsonInt(r.syncedRows)
          << ",\"skippedByTtl\":" << jsonBool(r.skippedByTtl)
          << ",\"formsSynced\":"  << jsonInt(r.formsSynced)
          << ",\"formsTotal\":"   << jsonInt(r.formsTotal)
          << ",\"failedForms\":[";
        for (size_t i = 0; i < r.failedForms.size(); ++i) {
            if (i) b << ",";
            b << "{\"formId\":"  << jsonStr(r.failedForms[i].formId)
              << ",\"error\":"   << jsonStr(r.failedForms[i].error)
              << "}";
        }
        b << "]"
          << ",\"durationMs\":"   << jsonLong(r.durationMs)
          << ",\"lastSyncAt\":"   << jsonStr(isoFromMs(r.lastSyncAtMs))
          << "}";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Meta leads sync failed: " << e.what() << std::endl;
        std::ostringstream b;
        b << "{\"ok\":false,\"error\":" << jsonStr(e.what()) << "}";
        return errOk(HttpStatus::BAD_GATEWAY, b.str());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleList(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    try {
        auto leads = Lead::listAll();
        std::ostringstream b;
        b << "[";
        for (size_t i = 0; i < leads.size(); ++i) {
            if (i) b << ",";
            b << serializeLead(leads[i]);
        }
        b << "]";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error fetching leads from DB: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to fetch leads");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/leads/:id/contact
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleLogContact(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST,
            "leadId + channel(text|email|whatsapp|call) required");
    }

    std::string channel;
    std::optional<std::string> messageBody;
    std::optional<std::string> status;
    std::optional<std::string> templateId;
    try {
        auto body = json::parse(request.getBody());
        if (body.contains("channel") && body["channel"].is_string())
            channel = body["channel"].get<std::string>();
        if (body.contains("message_body") && body["message_body"].is_string())
            messageBody = body["message_body"].get<std::string>();
        if (body.contains("status") && body["status"].is_string())
            status = body["status"].get<std::string>();
        if (body.contains("template") && body["template"].is_string()) {
            auto t = body["template"].get<std::string>();
            if (!t.empty()) templateId = t;
        }
    } catch (const std::exception&) {
        // Node treats unparseable body as missing channel → 400 below.
    }

    static const std::vector<std::string> kValid = {"text", "email", "whatsapp", "call"};
    if (std::find(kValid.begin(), kValid.end(), channel) == kValid.end()) {
        return errJson(HttpStatus::BAD_REQUEST,
            "leadId + channel(text|email|whatsapp|call) required");
    }

    try {
        auto userId = extractUserIdJwt(request);

        // ─── Sibling fan-out ───────────────────────────────────────
        // Some people fill out multiple lead forms (e.g. same email
        // signs up for both Boys Club AND Men's).  When the coach
        // emails or texts that person, conceptually they've contacted
        // ALL of those lead rows in one outbound touch.  Insert a
        // contact row for each so per-lead aggregates + status all
        // flip together.
        //
        // Match key per channel:
        //   email channel → leads with the same email (case-insensitive)
        //   text  channel → leads with the same phone (raw equality —
        //                   Meta hands us normalized E.164 already)
        //   other         → original lead only (no fan-out)
        //
        // The original lead_id is always included even if its email/
        // phone is NULL (defensive — a lead with no email could still
        // have a manual touch logged).
        auto db = Database::getInstance();
        std::vector<int> affectedIds;
        try {
            std::string match;
            if (channel == "email") {
                match =
                    "SELECT id FROM leads "
                    "WHERE id = $1::int "
                    "   OR (email IS NOT NULL AND email <> '' "
                    "       AND LOWER(email) = LOWER( (SELECT email FROM leads WHERE id = $1::int) ) )";
            } else if (channel == "text") {
                match =
                    "SELECT id FROM leads "
                    "WHERE id = $1::int "
                    "   OR (phone IS NOT NULL AND phone <> '' "
                    "       AND phone = (SELECT phone FROM leads WHERE id = $1::int) )";
            }
            if (!match.empty()) {
                auto rs = db->query(match, { std::to_string(leadId) });
                for (const auto& row : rs) affectedIds.push_back(row[0].as<int>());
            }
        } catch (const std::exception&) {
            // Fan-out lookup failed — fall back to original lead only.
        }
        if (affectedIds.empty()) affectedIds.push_back(leadId);

        // Insert a contact row per affected lead.  The first insert
        // (the originally-clicked lead) is the canonical row whose
        // id/sent_at we echo back at the top level so existing
        // callers that only read those fields keep working.
        LeadContact::Row canonical{};
        bool canonicalSet = false;
        for (int aid : affectedIds) {
            auto row = LeadContact::insert(aid, channel, userId, messageBody, status, templateId);
            if (aid == leadId || !canonicalSet) {
                canonical = row;
                canonicalSet = true;
            }
        }

        std::ostringstream b;
        b << "{\"id\":"      << jsonInt(canonical.id)
          << ",\"lead_id\":" << jsonInt(canonical.leadId)
          << ",\"channel\":" << jsonStr(canonical.channel)
          << ",\"sent_at\":" << jsonStr(canonical.sentAtIso)
          << ",\"status\":"  << jsonOrNull(canonical.status)
          << ",\"affected_lead_ids\":[";
        for (size_t i = 0; i < affectedIds.size(); ++i) {
            if (i > 0) b << ',';
            b << affectedIds[i];
        }
        b << "]}";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error logging contact: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to log contact");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads/:id/contacts
//
// Recent touches for one lead (newest first, capped at 20).  Drives the
// "Recent touches" list inside the Edit modal so the operator can audit
// the log and delete accidental clicks.
//
// Response: {"contacts": [
//   {"id":123, "channel":"email", "sent_at":"...", "status":"sent",
//    "template":"touch1"}, ...
// ]}
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleListContacts(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    try {
        auto rows = LeadContact::listForLead(leadId, 20);
        std::ostringstream b;
        b << "{\"contacts\":[";
        for (size_t i = 0; i < rows.size(); ++i) {
            if (i) b << ',';
            b << "{\"id\":"        << jsonInt(rows[i].id)
              << ",\"lead_id\":"   << jsonInt(rows[i].leadId)
              << ",\"channel\":"   << jsonStr(rows[i].channel)
              << ",\"sent_at\":"   << jsonStr(rows[i].sentAtIso)
              << ",\"status\":"    << jsonOrNull(rows[i].status)
              << ",\"template\":"  << jsonOrNull(rows[i].templateId)
              << "}";
        }
        b << "]}";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error listing contacts: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to list contacts");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// DELETE /api/leads/:id/contacts/:cid
//
// Remove a logged touch.  If the touch came in via a duplicate-email or
// duplicate-phone fan-out, the sibling rows go with it so the per-lead
// counts stay in lock-step.
//
// Response: {"deleted":true, "affected_lead_ids":[27400, 51960]}
// 404 when the (lead_id, contact_id) pair doesn't match an existing row.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleDeleteContact(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0, contactId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }
    if (!extractContactId(request.getPath(), contactId) || contactId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "contactId required");
    }

    try {
        auto affected = LeadContact::removeWithFanout(contactId, leadId);
        if (affected.empty()) {
            return errJson(HttpStatus::NOT_FOUND, "Contact not found");
        }
        std::ostringstream b;
        b << "{\"deleted\":true,\"affected_lead_ids\":[";
        for (size_t i = 0; i < affected.size(); ++i) {
            if (i) b << ',';
            b << affected[i];
        }
        b << "]}";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error deleting contact: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to delete contact");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/leads/:id/mark-converted   body: {source?, note?}
// DELETE /api/leads/:id/mark-converted
//
// Manual signed-up flag.  Body fields are optional; if omitted, `source`
// defaults to "manual" and `note` is left NULL.  Returns the refreshed
// lead row (same JSON shape as /api/leads).
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleMarkConverted(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    std::string source = "manual";
    std::optional<std::string> note;
    try {
        auto body = json::parse(request.getBody());
        if (body.contains("source") && body["source"].is_string()) {
            auto s = body["source"].get<std::string>();
            if (!s.empty()) source = s;
        }
        if (body.contains("note") && body["note"].is_string()) {
            auto n = body["note"].get<std::string>();
            if (!n.empty()) note = n;
        }
    } catch (const std::exception&) {
        // Empty / unparseable body is fine — treat as defaults.
    }

    // Cap source length to the column's VARCHAR(16) so a typo in the
    // client can't push us into a database error.
    if (source.size() > 16) source.resize(16);

    try {
        auto refreshed = Lead::markConverted(leadId, source, note);
        if (!refreshed) return errJson(HttpStatus::NOT_FOUND, "Lead not found");
        return errOk(HttpStatus::OK, serializeLead(*refreshed));
    } catch (const std::exception& e) {
        std::cerr << "Error marking lead converted: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to mark converted");
    }
}

Response LeadsController::handleUnmarkConverted(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    try {
        auto refreshed = Lead::unmarkConverted(leadId);
        if (!refreshed) return errJson(HttpStatus::NOT_FOUND, "Lead not found");
        return errOk(HttpStatus::OK, serializeLead(*refreshed));
    } catch (const std::exception& e) {
        std::cerr << "Error unmarking lead converted: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to unmark converted");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST   /api/leads/:id/mark-dead   — closed-lost flag (migration 074)
// DELETE /api/leads/:id/mark-dead   — clear the flag (revive)
//
// No body fields in v1 — pure boolean lifecycle flip.  Frontend issues
// the request without a confirm prompt because the lead stays visible
// in the "All" + "Dead" tabs and the action is one-click reversible.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleMarkDead(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    try {
        auto refreshed = Lead::markDead(leadId);
        if (!refreshed) return errJson(HttpStatus::NOT_FOUND, "Lead not found");
        return errOk(HttpStatus::OK, serializeLead(*refreshed));
    } catch (const std::exception& e) {
        std::cerr << "Error marking lead dead: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to mark dead");
    }
}

Response LeadsController::handleUnmarkDead(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    try {
        auto refreshed = Lead::unmarkDead(leadId);
        if (!refreshed) return errJson(HttpStatus::NOT_FOUND, "Lead not found");
        return errOk(HttpStatus::OK, serializeLead(*refreshed));
    } catch (const std::exception& e) {
        std::cerr << "Error unmarking lead dead: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to unmark dead");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/leads/:id/status-override   body: {status: '<one of>' | null}
//
// Manual display override (migration 075).  Pure visual flag — does
// NOT mutate converted_at / dead_at / last_email_at.  Allowed values:
// 'new' | 'responded' | 'signedup' | 'dead' | null (clears override).
// Any other value (including missing key) is treated as a clear so
// the client can post `{"status": null}` or `{}` to reset.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleSetStatusOverride(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    std::optional<std::string> status;
    try {
        auto body = json::parse(request.getBody());
        if (body.contains("status") && body["status"].is_string()) {
            auto s = body["status"].get<std::string>();
            // Whitelist — anything else falls through as a clear.
            if (s == "new" || s == "responded" || s == "signedup" || s == "dead") {
                status = s;
            }
        }
        // body["status"] == null or missing → clear (status stays nullopt).
    } catch (const std::exception&) {
        // Empty / unparseable body == clear override.
    }

    try {
        auto refreshed = Lead::setStatusOverride(leadId, status);
        if (!refreshed) return errJson(HttpStatus::NOT_FOUND, "Lead not found");
        return errOk(HttpStatus::OK, serializeLead(*refreshed));
    } catch (const std::exception& e) {
        std::cerr << "Error setting lead status override: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to set status override");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads/contact-stats
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleContactStats(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    try {
        auto stats = LeadContact::fetchStats();
        std::ostringstream b;
        b << "{\"per_lead\":{";
        // perLead map is keyed by int — match Node which keys by lead_id as
        // a string property.  std::map iterates in ascending key order;
        // Node builds the object by iterating the SQL rows (no defined
        // order).  Sort by lead_id for stability — frontend doesn't care.
        bool first = true;
        for (const auto& [leadId, p] : stats.perLead) {
            if (!first) b << ",";
            first = false;
            b << jsonStr(std::to_string(leadId)) << ":{"
              <<  "\"text_count\":"     << jsonInt(p.textCount)
              << ",\"email_count\":"    << jsonInt(p.emailCount)
              << ",\"last_text_at\":"   << jsonOrNull(p.lastTextAtIso)
              << ",\"last_email_at\":"  << jsonOrNull(p.lastEmailAtIso)
              << "}";
        }
        b << "},\"aggregates\":{"
          <<  "\"texts_5min\":"  << jsonInt(stats.aggregates.texts5min)
          << ",\"texts_hour\":"  << jsonInt(stats.aggregates.textsHour)
          << ",\"texts_day\":"   << jsonInt(stats.aggregates.textsDay)
          << ",\"texts_week\":"  << jsonInt(stats.aggregates.textsWeek)
          << ",\"emails_day\":"  << jsonInt(stats.aggregates.emailsDay)
          << ",\"emails_week\":" << jsonInt(stats.aggregates.emailsWeek)
          << "}}";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error fetching contact stats: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to fetch contact stats");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads/next-pickup
//   chat_id = 5 (Philadelphia Pickup ⚽️)
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleNextPickup(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    constexpr int kPickupChatId = 5;
    try {
        auto db = Database::getInstance();
        // Mirror Node's SELECT exactly: same column list + same start_at
        // computed expression + same ORDER BY 6 + same filter.
        auto rs = db->query(
            "SELECT id, title, location, location_address, external_id, "
            "       to_char(COALESCE(start_at, "
            "                        (event_date + COALESCE(event_time, '00:00'::time)) "
            "                          AT TIME ZONE 'America/New_York') "
            "                 AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS start_at, "
            "       to_char(end_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS end_at "
            "  FROM chat_events "
            " WHERE chat_id = $1::int "
            "   AND COALESCE(is_active, true) = true "
            "   AND COALESCE(start_at, "
            "                (event_date + COALESCE(event_time, '00:00'::time)) "
            "                  AT TIME ZONE 'America/New_York') > NOW() "
            " ORDER BY COALESCE(start_at, "
            "                   (event_date + COALESCE(event_time, '00:00'::time)) "
            "                     AT TIME ZONE 'America/New_York') ASC "
            " LIMIT 1",
            { std::to_string(kPickupChatId) });

        std::ostringstream b;
        if (rs.empty()) {
            b << "{\"event\":null}";
        } else {
            const auto& row = rs[0];
            auto cellOrNull = [&](const char* name) -> std::string {
                return row[name].is_null() ? std::string{"null"}
                                            : jsonStr(row[name].c_str());
            };
            b << "{\"event\":{"
              <<  "\"id\":"               << jsonInt(row["id"].as<int>())
              << ",\"title\":"            << cellOrNull("title")
              << ",\"location\":"         << cellOrNull("location")
              << ",\"location_address\":" << cellOrNull("location_address")
              << ",\"external_id\":"      << cellOrNull("external_id")
              << ",\"start_at\":"         << cellOrNull("start_at")
              << ",\"end_at\":"           << cellOrNull("end_at")
              << "}}";
        }
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error fetching next pickup: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to fetch next pickup");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads/unjoined-members
//
// Lists ALL current Lighthouse members (Men / Women / Boys / Girls / all
// LA sub-programs including paused + pickup).  The frontend uses this
// list for two purposes:
//   1. Render the blue "Members" section on the leads screen.
//   2. Cross-reference each lead's email against the union of member
//      emails; any lead that matches a member is hidden from the main
//      leads list (they're already in the club — they aren't a prospect).
//
// Endpoint name retained for backward compat with the original
// "members not in the leads funnel" framing; today's behavior is
// strictly broader (no lead-overlap filtering happens here).
//
// Membership sources (post-refactor 2026-07-17):
//   • Registered through laGet(dynamic) → LaProgramSync::run() has
//     ALREADY fired for every LA program in `leagueapps_programs`
//     (parallel fan-out) before this handler is called.  That call
//     upserts persons, aliases, person_la_memberships,
//     person_emails and person_phones — so the handler reads
//     everything from Postgres and NEVER calls LA directly (which
//     was the previous BANNED pattern that filled section 5 with
//     an inline `la.fetchProgramRegistrations()` loop).
//   • Men   — mens_team_assignments → external_person_aliases('leagueapps')
//             → persons → person_emails (freshly synced this request).
//   • Women — rosters (left_at IS NULL) → players → persons, restricted to
//             teams.gender_category='womens'.
//   • Boys / Girls / paused / pickup — the catch-all section 5 below
//             walks EVERY open person_la_memberships row, resolves each
//             to a person + LA userId + contact + program-name, and
//             emits it in a single JOIN query.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleUnjoinedMembers(const Request& request, const LaSyncMap& sync) {
    (void)sync;   // LA fetch was executed by laGet(); this handler reads DB only.
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    try {
        auto db = Database::getInstance();

        std::ostringstream b;
        b << "[";
        bool first = true;

        // LA userIds we've already surfaced via a roster-shaped section
        // (Men from mens_team_assignments, Boys/Girls from YouthRoster).
        // The trailing catch-all sweep (section 5, added 2026-07-01) uses
        // this to avoid duplicating a person who is BOTH on a roster AND
        // in the LA program registration feed.
        std::set<long long> emittedLaUids;

        auto emit = [&](const std::string& category,
                        std::optional<int> personId,
                        std::optional<long long> laUserId,
                        const std::string& firstName,
                        const std::string& lastName,
                        const std::string& teamName,
                        const std::string& emails,
                        const std::string& phone = {}) {
            if (!first) b << ",";
            first = false;
            b << "{"
              <<  "\"category\":"            << jsonStr(category)
              << ",\"person_id\":"           << (personId.has_value() ? jsonInt(*personId) : std::string{"null"})
              << ",\"league_apps_user_id\":" << (laUserId.has_value() ? jsonLong(*laUserId) : std::string{"null"})
              << ",\"first_name\":"          << jsonStr(firstName)
              << ",\"last_name\":"           << jsonStr(lastName)
              << ",\"team_name\":"           << jsonStr(teamName)
              << ",\"emails\":"              << (emails.empty() ? std::string{"null"} : jsonStr(emails))
              << ",\"phone\":"               << (phone.empty()  ? std::string{"null"} : jsonStr(phone))
              << "}";
            if (laUserId.has_value() && *laUserId > 0) {
                emittedLaUids.insert(*laUserId);
            }
        };

        // 2. Men — mens_team_assignments (any presence = member; bench,
        //    pool, on-roster all counted).  Email + phone come from
        //    person_emails / person_phones which PersonLinker.linkLa
        //    keeps in sync every request (see laGet wrapper on this
        //    route).  The old code fetched LA registrations inline to
        //    overlay email/phone because person_emails was sparse for
        //    men; that predates the 2026-07-01 contact-backfill and
        //    the 2026-07-17 laGet wiring — both now guarantee this
        //    read is fresh.
        {
            auto rs = db->query(
                "SELECT t.name AS team_name, p.id AS person_id, "
                "       p.first_name, p.last_name, m.leagueapps_user_id, "
                "       COALESCE((SELECT string_agg(pe.email, ', ' ORDER BY pe.is_primary DESC, pe.email) "
                "                  FROM person_emails pe WHERE pe.person_id = p.id), '') AS emails, "
                "       COALESCE((SELECT pp.phone_number FROM person_phones pp "
                "                  WHERE pp.person_id = p.id "
                "                  ORDER BY pp.is_primary DESC, pp.id LIMIT 1), '') AS phone "
                "  FROM roster_assignments m "
                "  JOIN teams t ON t.id = m.team_id "
                "  JOIN external_person_aliases epa "
                "    ON epa.provider = 'leagueapps' "
                "   AND epa.external_user_id = m.leagueapps_user_id::text "
                "  JOIN persons p ON p.id = epa.person_id "
                " ORDER BY t.name, p.last_name, p.first_name");
            for (const auto& row : rs) {
                emit("Men",
                     row["person_id"].as<int>(),
                     row["leagueapps_user_id"].as<long long>(),
                     row["first_name"].is_null() ? std::string{} : row["first_name"].c_str(),
                     row["last_name"].is_null()  ? std::string{} : row["last_name"].c_str(),
                     row["team_name"].is_null()  ? std::string{} : row["team_name"].c_str(),
                     row["emails"].c_str(),
                     row["phone"].c_str());
            }
        }

        // 3. Women — rosters via players, filtered to womens-category teams.
        {
            auto rs = db->query(
                "SELECT t.name AS team_name, p.id AS person_id, "
                "       p.first_name, p.last_name, "
                "       COALESCE((SELECT string_agg(pe.email, ', ' ORDER BY pe.is_primary DESC, pe.email) "
                "                  FROM person_emails pe WHERE pe.person_id = p.id), '') AS emails "
                "  FROM rosters r "
                "  JOIN teams t ON t.id = r.team_id "
                "  JOIN players pl ON pl.id = r.player_id "
                "  JOIN persons p ON p.id = pl.person_id "
                " WHERE r.left_at IS NULL "
                "   AND t.gender_category = 'womens' "
                " ORDER BY t.name, p.last_name, p.first_name");
            for (const auto& row : rs) {
                emit("Women",
                     row["person_id"].as<int>(),
                     std::nullopt,
                     row["first_name"].is_null() ? std::string{} : row["first_name"].c_str(),
                     row["last_name"].is_null()  ? std::string{} : row["last_name"].c_str(),
                     row["team_name"].is_null()  ? std::string{} : row["team_name"].c_str(),
                     row["emails"].c_str());
            }
        }

        // 4. Boys / Girls — live LA fetch.  Adds latency to the page load
        //    (two LA HTTP calls) but matches user requirement "checked on
        //    every load".  On any LA failure we silently skip youth so the
        //    Men/Women section still renders.
        try {
            YouthRoster yr;
            auto result = yr.run(YouthRoster::defaultSeasonEndYear(), /*includeAll=*/false);
            if (result.error.empty() && result.body.contains("buckets")) {
                auto handleYouthRow = [&](const nlohmann::json& row,
                                          const std::string& bucketLabel) {
                    const std::string club = row.value("club", std::string{});
                    const std::string category = (club == "Boys Club") ? "Boys" : "Girls";
                    const std::string firstName  = row.value("firstName", std::string{});
                    const std::string lastName   = row.value("lastName",  std::string{});
                    auto strOrEmpty = [&](const char* k) -> std::string {
                        auto it = row.find(k);
                        if (it == row.end() || !it->is_string()) return {};
                        return it->get<std::string>();
                    };
                    const std::string parentEmail = strOrEmpty("parentEmail");
                    const std::string playerEmail = strOrEmpty("playerEmail");
                    const std::string parentPhone = strOrEmpty("parentPhone");

                    // LA user id may be number or string.
                    std::optional<long long> laUid;
                    auto laIt = row.find("leagueAppsUserId");
                    if (laIt != row.end() && !laIt->is_null()) {
                        try {
                            if (laIt->is_number_integer()) laUid = laIt->get<long long>();
                            else if (laIt->is_string())    laUid = std::stoll(laIt->get<std::string>());
                        } catch (...) { /* ignore */ }
                    }

                    std::string emails;
                    if (!parentEmail.empty()) emails = parentEmail;
                    if (!playerEmail.empty()) {
                        if (!emails.empty()) emails += ", ";
                        emails += playerEmail;
                    }

                    emit(category, std::nullopt, laUid, firstName, lastName,
                         bucketLabel, emails, parentPhone);
                };

                for (auto it = result.body["buckets"].begin();
                     it != result.body["buckets"].end(); ++it) {
                    if (!it.value().is_array()) continue;
                    for (const auto& row : it.value()) {
                        handleYouthRow(row, it.key());
                    }
                }
                if (result.body.contains("unbucketed") && result.body["unbucketed"].is_array()) {
                    for (const auto& row : result.body["unbucketed"]) {
                        handleYouthRow(row, "(unbucketed)");
                    }
                }
            } else if (!result.error.empty()) {
                std::cerr << "unjoined-members: youth fetch skipped: "
                          << result.error << std::endl;
            }
        } catch (const std::exception& e) {
            std::cerr << "unjoined-members: youth fetch threw: "
                      << e.what() << " — continuing without youth." << std::endl;
        }

        // 5. Catch-all — every LA-linked person who currently has an
        //    OPEN person_la_memberships row for ANY program (active,
        //    paused, pickup, everything).  Handled in a single query
        //    because laGet(dynamic, allLaProgramIds) already refreshed
        //    every LA program's state into person_la_memberships +
        //    person_emails + person_phones before this handler ran.
        //    The old implementation looped over `leagueapps_programs`
        //    and called `la.fetchProgramRegistrations(pid)` inline for
        //    each — a direct violation of the STRICT rule (§ Membership
        //    Data Flow, "shape response cards from the in-memory LA
        //    response" is BANNED).
        //
        //    Contact resolution mirrors the pre-refactor behavior:
        //    youth records (persons.parent_person_id IS NOT NULL) use
        //    the PARENT's email/phone rows because CHILD LA regs carry
        //    contact info on the parent, not the child.  Adults use
        //    their own rows.
        //
        //    `emittedLaUids` (populated by sections 2 + 4) is honored so
        //    a person who was already surfaced under Men or Boys/Girls
        //    isn't double-emitted here under their (same) active
        //    program.  Different LA sub-programs for the same person
        //    (e.g. Men active AND Men pickup) DO surface as separate
        //    rows because the frontend uses this list to enumerate
        //    which sub-programs each member belongs to.
        try {
            auto rs = db->query(
                "SELECT lp.category, "
                "       lp.variant, "
                "       lp.program_name, "
                "       p.id                              AS person_id, "
                "       p.first_name, "
                "       p.last_name, "
                "       epa.external_user_id              AS la_user_id, "
                "       COALESCE(p.parent_person_id, p.id) AS contact_person_id, "
                "       COALESCE((SELECT string_agg(pe.email, ', ' "
                "                                   ORDER BY pe.is_primary DESC, pe.email) "
                "                   FROM person_emails pe "
                "                  WHERE pe.person_id = COALESCE(p.parent_person_id, p.id)), '') AS emails, "
                "       COALESCE((SELECT pp.phone_number FROM person_phones pp "
                "                  WHERE pp.person_id = COALESCE(p.parent_person_id, p.id) "
                "                  ORDER BY pp.is_primary DESC, pp.id LIMIT 1), '')             AS phone "
                "  FROM person_la_memberships plm "
                "  JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
                "  JOIN persons p              ON p.id           = plm.person_id "
                "  LEFT JOIN external_person_aliases epa "
                "    ON epa.person_id = p.id AND epa.provider = 'leagueapps' "
                " WHERE plm.ended_at IS NULL "
                " ORDER BY lp.category, lp.variant, p.last_name, p.first_name, plm.la_program_id");

            for (const auto& row : rs) {
                std::optional<long long> laUid;
                if (!row["la_user_id"].is_null()) {
                    try { laUid = std::stoll(row["la_user_id"].c_str()); }
                    catch (...) { /* orphaned membership without alias — leave null */ }
                }
                // Skip anyone already emitted by sections 2/3/4 for the
                // SAME base category (Men from mens roster, Boys/Girls
                // from YouthRoster).  We only skip when the underlying
                // LA userId already produced a row — different sub-
                // programs deserve their own line.
                if (laUid.has_value() && emittedLaUids.count(*laUid)) continue;

                const std::string cat = row["category"].is_null() ? std::string{} : row["category"].c_str();
                const std::string var = row["variant"].is_null()  ? std::string{} : row["variant"].c_str();
                const std::string progName = row["program_name"].is_null()
                                                ? std::string{}
                                                : row["program_name"].c_str();

                // Human-friendly labels for the frontend Members card.
                std::string uiCategory;
                if      (cat == "men")   uiCategory = (var == "paused") ? "Men Paused"   : "Men";
                else if (cat == "boys")  uiCategory = (var == "paused") ? "Boys Paused"  : "Boys";
                else if (cat == "girls") uiCategory = (var == "paused") ? "Girls Paused" : "Girls";
                else if (cat == "women") uiCategory = (var == "paused") ? "Women Paused" : "Women";
                else                     uiCategory = cat;

                std::optional<int> personId = row["person_id"].as<int>();
                const std::string fn = row["first_name"].is_null() ? std::string{} : row["first_name"].c_str();
                const std::string ln = row["last_name"].is_null()  ? std::string{} : row["last_name"].c_str();
                const std::string emails = row["emails"].c_str();
                const std::string phone  = row["phone"].c_str();

                emit(uiCategory, personId, laUid, fn, ln, progName, emails, phone);
            }
        } catch (const std::exception& e) {
            std::cerr << "unjoined-members: catch-all sweep failed: "
                      << e.what() << std::endl;
        }

        b << "]";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "Error fetching unjoined members: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to fetch unjoined members");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads/analytics
//
// Cross-references every lead + every logged email/text/whatsapp touch
// against the live LeagueApps registration data (Mens + Youth) to answer:
// "of the leads we touched, which actually registered?"
//
// Sources joined:
//   • leads             — all lead rows
//   • lead_contacts     — touch log (channel + sent_at); touch # derived
//                         via ROW_NUMBER() over (lead_id ORDER BY sent_at)
//   • MensRoster.run()  — live LA fetch, exposes email + phone for adults
//   • YouthRoster.run() — live LA fetch, exposes parentEmail/playerEmail
//                         + parentPhone for boys/girls (K-12)
//
// Match rule: normalised email (lower-case) OR normalised phone (last 10
// digits) equality between lead and any LA registration row.
//
// Response shape (top-level keys):
//   generatedAt, laFetchOk, summary, byFunnel, byTouchCount,
//   bySecondTouchGap, recentActivity, matchedUnmarked
//
// This endpoint is intended for the Club Admin → Leads Analytics screen
// and is NOT called on every load; it's opened deliberately.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleAnalytics(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    using nlohmann::json;

    auto toLower = [](std::string s) {
        std::transform(s.begin(), s.end(), s.begin(),
                       [](unsigned char c){ return std::tolower(c); });
        return s;
    };
    // Normalise a phone to its trailing 10 digits (US numbers).  Empty
    // string if fewer than 10 digits are present.
    auto normPhone = [](const std::string& raw) -> std::string {
        std::string digits;
        digits.reserve(raw.size());
        for (char c : raw) if (c >= '0' && c <= '9') digits.push_back(c);
        if (digits.size() < 10) return {};
        return digits.substr(digits.size() - 10);
    };

    try {
        auto db = Database::getInstance();

        // ── 1. Load LA registration email + phone sets ────────────────
        // Both live-fetched.  Each is wrapped in its own try so a single
        // failure doesn't kill the whole page.
        std::unordered_set<std::string> laEmails;
        std::unordered_set<std::string> laPhones;
        bool mensFetchOk = false;
        bool youthFetchOk = false;

        auto ingestRow = [&](const json& row) {
            auto tryField = [&](const char* k) {
                auto it = row.find(k);
                if (it == row.end() || !it->is_string()) return;
                const std::string v = it->get<std::string>();
                if (v.empty()) return;
                if (std::strstr(k, "mail") != nullptr) {
                    laEmails.insert(toLower(v));
                } else {
                    const auto p = normPhone(v);
                    if (!p.empty()) laPhones.insert(p);
                }
            };
            tryField("email");
            tryField("phone");
            tryField("parentEmail");
            tryField("playerEmail");
            tryField("parentPhone");
        };

        // Mens (live LA fetch)
        try {
            MensRoster mr;
            auto res = mr.run(/*includeAll=*/false, /*refreshLa=*/true);
            if (res.error.empty() && res.body.contains("buckets")) {
                for (auto it = res.body["buckets"].begin();
                     it != res.body["buckets"].end(); ++it) {
                    if (!it.value().is_array()) continue;
                    for (const auto& row : it.value()) ingestRow(row);
                }
                if (res.body.contains("unassigned") && res.body["unassigned"].is_array()) {
                    for (const auto& row : res.body["unassigned"]) ingestRow(row);
                }
                mensFetchOk = true;
            } else if (!res.error.empty()) {
                std::cerr << "analytics: mens LA fetch: " << res.error << std::endl;
            }
        } catch (const std::exception& e) {
            std::cerr << "analytics: mens LA threw: " << e.what() << std::endl;
        }

        // Youth (live LA fetch)
        try {
            YouthRoster yr;
            auto res = yr.run(YouthRoster::defaultSeasonEndYear(), /*includeAll=*/false);
            if (res.error.empty() && res.body.contains("buckets")) {
                for (auto it = res.body["buckets"].begin();
                     it != res.body["buckets"].end(); ++it) {
                    if (!it.value().is_array()) continue;
                    for (const auto& row : it.value()) ingestRow(row);
                }
                if (res.body.contains("unbucketed") && res.body["unbucketed"].is_array()) {
                    for (const auto& row : res.body["unbucketed"]) ingestRow(row);
                }
                youthFetchOk = true;
            } else if (!res.error.empty()) {
                std::cerr << "analytics: youth LA fetch: " << res.error << std::endl;
            }
        } catch (const std::exception& e) {
            std::cerr << "analytics: youth LA threw: " << e.what() << std::endl;
        }

        // ── 2. Load all leads + touch summaries in one pass ──────────
        // We include a per-lead: email, phone, form_id, created_at,
        // converted_at, dead_at, touch_count, first_touch_at, second_touch_at.
        auto rs = db->query(
            "WITH t AS ( "
            "  SELECT lead_id, "
            "         COUNT(*) AS touch_count, "
            "         MIN(sent_at) FILTER (WHERE channel='email') AS first_email_at, "
            "         MIN(sent_at) FILTER (WHERE channel='email' "
            "                              AND sent_at > (SELECT MIN(sent_at) FROM lead_contacts x "
            "                                             WHERE x.lead_id = lead_contacts.lead_id AND x.channel='email')) AS second_email_at, "
            "         MAX(sent_at) AS last_touch_at "
            "    FROM lead_contacts "
            "   GROUP BY lead_id "
            ") "
            "SELECT l.id, "
            "       COALESCE(l.name, '')     AS name, "
            "       LOWER(COALESCE(l.email, '')) AS email, "
            "       COALESCE(l.phone, '')    AS phone, "
            "       COALESCE(l.form_id, '')  AS form_id, "
            "       to_char(l.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS created_date, "
            "       (l.converted_at IS NOT NULL) AS is_converted, "
            "       (l.dead_at IS NOT NULL)      AS is_dead, "
            "       COALESCE(t.touch_count, 0)   AS touch_count, "
            "       to_char(t.first_email_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SSZ') AS first_email_at, "
            "       to_char(t.second_email_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SSZ') AS second_email_at, "
            "       to_char(t.last_touch_at   AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SSZ') AS last_touch_at "
            "  FROM leads l "
            "  LEFT JOIN t ON t.lead_id = l.id");

        struct LeadRow {
            int id = 0;
            std::string name;
            std::string email;      // already lower-cased
            std::string phoneNorm;  // last-10 digits
            std::string phoneRaw;
            std::string formId;
            std::string createdDate;
            bool isConverted = false;
            bool isDead = false;
            int touchCount = 0;
            std::string firstEmailAt;   // iso, may be empty
            std::string secondEmailAt;  // iso, may be empty
            std::string lastTouchAt;    // iso, may be empty
            bool matchedLa = false;
        };
        std::vector<LeadRow> leadRows;
        leadRows.reserve(rs.size());
        for (const auto& row : rs) {
            LeadRow lr;
            lr.id            = row["id"].as<int>();
            lr.name          = row["name"].c_str();
            lr.email         = row["email"].c_str();
            lr.phoneRaw      = row["phone"].c_str();
            lr.phoneNorm     = normPhone(lr.phoneRaw);
            lr.formId        = row["form_id"].c_str();
            lr.createdDate   = row["created_date"].c_str();
            lr.isConverted   = row["is_converted"].as<bool>();
            lr.isDead        = row["is_dead"].as<bool>();
            lr.touchCount    = row["touch_count"].as<int>();
            lr.firstEmailAt  = row["first_email_at"].is_null()  ? std::string{} : row["first_email_at"].c_str();
            lr.secondEmailAt = row["second_email_at"].is_null() ? std::string{} : row["second_email_at"].c_str();
            lr.lastTouchAt   = row["last_touch_at"].is_null()   ? std::string{} : row["last_touch_at"].c_str();

            lr.matchedLa = (!lr.email.empty() && laEmails.count(lr.email))
                        || (!lr.phoneNorm.empty() && laPhones.count(lr.phoneNorm));

            leadRows.push_back(std::move(lr));
        }

        // ── 3. Aggregations ──────────────────────────────────────────
        // 3a. Summary
        int totalLeads          = static_cast<int>(leadRows.size());
        int leadsWithEmail      = 0;
        int leadsWithPhone      = 0;
        int leadsTouched        = 0;
        int leadsMarked         = 0;
        int leadsMatchedLa      = 0;
        int matchedNotMarked    = 0;
        int matchedAndMarked    = 0;
        int leadsDead           = 0;
        for (const auto& l : leadRows) {
            if (!l.email.empty())     ++leadsWithEmail;
            if (!l.phoneNorm.empty()) ++leadsWithPhone;
            if (l.touchCount > 0)     ++leadsTouched;
            if (l.isConverted)        ++leadsMarked;
            if (l.isDead)             ++leadsDead;
            if (l.matchedLa)          ++leadsMatchedLa;
            if (l.matchedLa && !l.isConverted) ++matchedNotMarked;
            if (l.matchedLa &&  l.isConverted) ++matchedAndMarked;
        }

        // 3b. By funnel (form_id)
        struct FunnelAgg {
            int leads = 0;
            int touched = 0;
            int matched = 0;
            int marked = 0;
        };
        std::map<std::string, FunnelAgg> byFunnel;
        for (const auto& l : leadRows) {
            auto& f = byFunnel[l.formId];
            ++f.leads;
            if (l.touchCount > 0) ++f.touched;
            if (l.matchedLa)      ++f.matched;
            if (l.isConverted)    ++f.marked;
        }

        // 3c. By touch count bucket
        struct TouchAgg {
            int leads = 0;
            int matched = 0;
            int marked = 0;
        };
        std::map<std::string, TouchAgg> byTouch;   // ordered: 0, 1, 2, 3, 4+
        auto touchBucket = [](int n) -> std::string {
            if (n == 0) return "0";
            if (n == 1) return "1";
            if (n == 2) return "2";
            if (n == 3) return "3";
            return "4+";
        };
        for (const auto& l : leadRows) {
            auto& t = byTouch[touchBucket(l.touchCount)];
            ++t.leads;
            if (l.matchedLa)   ++t.matched;
            if (l.isConverted) ++t.marked;
        }

        // 3d. By second-touch gap (only leads with a 2nd email)
        struct GapAgg {
            int leads = 0;
            int matched = 0;
            int marked = 0;
        };
        std::map<std::string, GapAgg> byGap;      // <1d, 1-3d, 3-7d, 7-14d, 14-30d, 30d+
        auto gapBucket = [](long long seconds) -> std::string {
            const long long day = 86400;
            if (seconds < 1  * day) return "<1d";
            if (seconds < 3  * day) return "1-3d";
            if (seconds < 7  * day) return "3-7d";
            if (seconds < 14 * day) return "7-14d";
            if (seconds < 30 * day) return "14-30d";
            return "30d+";
        };
        auto parseIsoToSecs = [](const std::string& iso) -> long long {
            if (iso.size() < 19) return 0;
            std::tm tmv{};
            // YYYY-MM-DDTHH:MI:SSZ
            tmv.tm_year = std::atoi(iso.substr(0, 4).c_str()) - 1900;
            tmv.tm_mon  = std::atoi(iso.substr(5, 2).c_str()) - 1;
            tmv.tm_mday = std::atoi(iso.substr(8, 2).c_str());
            tmv.tm_hour = std::atoi(iso.substr(11, 2).c_str());
            tmv.tm_min  = std::atoi(iso.substr(14, 2).c_str());
            tmv.tm_sec  = std::atoi(iso.substr(17, 2).c_str());
            return static_cast<long long>(timegm(&tmv));
        };
        for (const auto& l : leadRows) {
            if (l.firstEmailAt.empty() || l.secondEmailAt.empty()) continue;
            const long long a = parseIsoToSecs(l.firstEmailAt);
            const long long b_ = parseIsoToSecs(l.secondEmailAt);
            if (a == 0 || b_ == 0 || b_ <= a) continue;
            auto& g = byGap[gapBucket(b_ - a)];
            ++g.leads;
            if (l.matchedLa)   ++g.matched;
            if (l.isConverted) ++g.marked;
        }

        // 3e. Recent daily activity (last 30 days).  Count touches + new leads.
        auto daily = db->query(
            "WITH d AS ( "
            "  SELECT to_char(sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS day, "
            "         COUNT(*) FILTER (WHERE channel='email') AS emails, "
            "         COUNT(*) FILTER (WHERE channel='text')  AS texts "
            "    FROM lead_contacts "
            "   WHERE sent_at > NOW() - INTERVAL '30 days' "
            "   GROUP BY 1 "
            "), n AS ( "
            "  SELECT to_char(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS day, "
            "         COUNT(*) AS new_leads "
            "    FROM leads "
            "   WHERE created_at > NOW() - INTERVAL '30 days' "
            "   GROUP BY 1 "
            ") "
            "SELECT COALESCE(d.day, n.day) AS day, "
            "       COALESCE(d.emails, 0)  AS emails, "
            "       COALESCE(d.texts,  0)  AS texts, "
            "       COALESCE(n.new_leads, 0) AS new_leads "
            "  FROM d FULL OUTER JOIN n ON n.day = d.day "
            " ORDER BY day DESC");

        // 3f. Matched-but-not-marked list (actionable — these registered
        // but nobody clicked "Signed up" so the flag is stale).
        struct ActRow {
            int id;
            std::string name;
            std::string email;
            std::string phone;
            std::string formId;
            std::string lastTouchAt;
            int touchCount;
        };
        std::vector<ActRow> matchedUnmarked;
        for (const auto& l : leadRows) {
            if (l.matchedLa && !l.isConverted) {
                matchedUnmarked.push_back({
                    l.id, l.name, l.email, l.phoneRaw, l.formId,
                    l.lastTouchAt, l.touchCount
                });
            }
        }
        // Sort so most-recently-touched-and-unmarked show first.
        std::sort(matchedUnmarked.begin(), matchedUnmarked.end(),
                  [](const ActRow& a, const ActRow& b) {
                      return a.lastTouchAt > b.lastTouchAt;
                  });

        // ── 4. Build response JSON ──────────────────────────────────
        json body;
        body["generatedAt"] = isoFromMs(std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()).count());
        body["laFetchOk"] = { {"mens", mensFetchOk}, {"youth", youthFetchOk} };
        body["laRegistrationCounts"] = {
            {"emails", static_cast<int>(laEmails.size())},
            {"phones", static_cast<int>(laPhones.size())}
        };

        body["summary"] = {
            {"totalLeads",           totalLeads},
            {"leadsWithEmail",       leadsWithEmail},
            {"leadsWithPhone",       leadsWithPhone},
            {"leadsTouched",         leadsTouched},
            {"leadsDead",            leadsDead},
            {"leadsMarkedConverted", leadsMarked},
            {"leadsMatchedLa",       leadsMatchedLa},
            {"matchedAndMarked",     matchedAndMarked},
            {"matchedNotMarked",     matchedNotMarked}
        };

        json byFunnelArr = json::array();
        for (const auto& [formId, a] : byFunnel) {
            byFunnelArr.push_back({
                {"formId",  formId},
                {"leads",   a.leads},
                {"touched", a.touched},
                {"matched", a.matched},
                {"marked",  a.marked}
            });
        }
        body["byFunnel"] = std::move(byFunnelArr);

        json byTouchArr = json::array();
        for (const auto& key : std::vector<std::string>{"0","1","2","3","4+"}) {
            auto it = byTouch.find(key);
            if (it == byTouch.end()) continue;
            byTouchArr.push_back({
                {"touches", key},
                {"leads",   it->second.leads},
                {"matched", it->second.matched},
                {"marked",  it->second.marked}
            });
        }
        body["byTouchCount"] = std::move(byTouchArr);

        json byGapArr = json::array();
        for (const auto& key : std::vector<std::string>{"<1d","1-3d","3-7d","7-14d","14-30d","30d+"}) {
            auto it = byGap.find(key);
            if (it == byGap.end()) continue;
            byGapArr.push_back({
                {"bucket",  key},
                {"leads",   it->second.leads},
                {"matched", it->second.matched},
                {"marked",  it->second.marked}
            });
        }
        body["bySecondTouchGap"] = std::move(byGapArr);

        json dailyArr = json::array();
        for (const auto& row : daily) {
            dailyArr.push_back({
                {"day",      row["day"].c_str()},
                {"emails",   row["emails"].as<int>()},
                {"texts",    row["texts"].as<int>()},
                {"newLeads", row["new_leads"].as<int>()}
            });
        }
        body["recentActivity"] = std::move(dailyArr);

        json matchedArr = json::array();
        for (const auto& r : matchedUnmarked) {
            matchedArr.push_back({
                {"id",           r.id},
                {"name",         r.name},
                {"email",        r.email},
                {"phone",        r.phone},
                {"formId",       r.formId},
                {"lastTouchAt",  r.lastTouchAt.empty() ? json(nullptr) : json(r.lastTouchAt)},
                {"touchCount",   r.touchCount}
            });
        }
        body["matchedUnmarked"] = std::move(matchedArr);

        return errOk(HttpStatus::OK, body.dump());
    } catch (const std::exception& e) {
        std::cerr << "Error building leads analytics: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to build analytics");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/leads/:id/vcard?kind=self|parent|player|youth-pair
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleVcard(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    int leadId = 0;
    if (!extractLeadId(request.getPath(), leadId) || leadId <= 0) {
        return errJson(HttpStatus::BAD_REQUEST, "leadId required");
    }

    std::string kind = request.getQueryParam("kind");
    if (kind.empty()) kind = "self";

    try {
        auto lead = Lead::findById(leadId);
        if (!lead.has_value()) {
            return errJson(HttpStatus::NOT_FOUND, "Lead not found");
        }

        const std::string fullName = trimStr(lead->name.value_or(std::string{}));
        const auto [firstName, lastName] = splitName(fullName);

        // dateStr = lead.created_at.toISOString().slice(0, 10) — first 10 chars.
        const std::string dateStr = lead->createdAtIso.size() >= 10
            ? lead->createdAtIso.substr(0, 10)
            : std::string{};

        // Lead phone/email may be empty strings or absent; vCard helper
        // uses presence (optional) to decide whether to emit the line.
        auto present = [](const std::optional<std::string>& v) -> std::optional<std::string> {
            if (!v.has_value() || v->empty()) return std::nullopt;
            return v;
        };
        const auto phoneOpt = present(lead->phone);
        const auto emailOpt = present(lead->email);

        std::vector<std::string> cards;
        std::string downloadName;

        const std::string parentDisplay  = fullName + " Lighthouse Parent ";
        const std::string playerLast     = lastName.empty() ? fullName : lastName;
        const std::string playerDisplay  = playerLast + " Player Lighthouse ";

        // Notes match Node string templates verbatim — including the
        // optional phone literal that comes from `lead.phone || ''`.
        auto parentNote = [&]() {
            return std::string{"Youth lead signup "} + dateStr
                 + std::string{". Edit name + add birth year after contact."};
        };
        auto playerNote = [&]() {
            return std::string{"Youth player placeholder. Parent: "} + fullName
                 + std::string{" ("} + phoneOpt.value_or(std::string{}) + std::string{"). "}
                 + std::string{"Fill in first name + birth year after first contact."};
        };

        if (kind == "parent") {
            cards.push_back(buildVCard(parentDisplay, firstName, lastName,
                { phoneOpt, emailOpt, parentNote() }));
            downloadName = slashWsToUnderscore(fullName) + "_Parent.vcf";
        } else if (kind == "player") {
            cards.push_back(buildVCard(playerDisplay, std::string{}, playerLast,
                { std::nullopt, std::nullopt, playerNote() }));
            downloadName = slashWsToUnderscore(playerLast) + "_PlayerPlaceholder.vcf";
        } else if (kind == "youth-pair") {
            cards.push_back(buildVCard(parentDisplay, firstName, lastName,
                { phoneOpt, emailOpt, parentNote() }));
            cards.push_back(buildVCard(playerDisplay, std::string{}, playerLast,
                { std::nullopt, std::nullopt, playerNote() }));
            downloadName = slashWsToUnderscore(fullName) + "_Youth.vcf";
        } else {
            // self — adult funnels.
            std::string note = std::string{"Lead signup "} + dateStr
                             + std::string{". Add birth year after confirming."};
            cards.push_back(buildVCard(fullName + " Lighthouse ",
                firstName, lastName, { phoneOpt, emailOpt, note }));
            downloadName = slashWsToUnderscore(fullName) + "_Lighthouse.vcf";
        }

        std::string body;
        for (size_t i = 0; i < cards.size(); ++i) {
            if (i) body += "\r\n";
            body += cards[i];
        }
        body += "\r\n";

        Response r(HttpStatus::OK, body);
        r.setHeader("Content-Type", "text/vcard; charset=utf-8");
        r.setHeader("Content-Disposition",
                    std::string{"attachment; filename=\""} + downloadName + "\"");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "Error building vCard: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to build vCard");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────


std::optional<int>
LeadsController::extractUserIdJwt(const Request& request) {
    std::string h = request.getHeader("Authorization");
    if (h.empty()) h = request.getHeader("authorization");
    return decodeUserIdFromBearer(h);
}

bool LeadsController::extractLeadId(const std::string& path, int& leadId) {
    // /api/leads/<id>/contact | /contacts[/<cid>] | /vcard | /mark-converted | /mark-dead | /status-override
    static const std::regex re(R"(/api/leads/(\d+)/(?:contact|contacts|vcard|mark-converted|mark-dead|status-override))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { leadId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool LeadsController::extractContactId(const std::string& path, int& contactId) {
    // /api/leads/<id>/contacts/<cid>
    static const std::regex re(R"(/api/leads/\d+/contacts/(\d+))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { contactId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/leads/guest-signup  (PUBLIC — no bearer)
//
// Landing page at /pickup posts here.  We synthesize a Meta-shaped lead row
// so the existing admin Leads UI + LeagueApps reconciliation pipeline treat
// it identically to a real Meta submission:
//
//   leadgen_id = "guest-<epoch_ms>-<8-hex>"  (unique, satisfies UNIQUE NOT NULL)
//   form_id    = "pickup-funnel"
//   ad_id      = <ad key from body, e.g. "u23-mens" — or NULL>
//   raw_fields = JSON array shaped like Meta's field_data so serializeLead()
//                and the Leads screen render the extra fields with zero
//                changes required in the UI layer.
//
// Rate-limit / spam guard: if the same normalised phone OR email posted in
// the last 5 min, we short-circuit with the existing lead id (idempotent
// double-submit protection).  No IP-based limits — sits behind nginx and
// is low-volume; can be tightened later if spam becomes a problem.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleGuestSignup(const Request& request) {
    // 1) Parse body
    json body;
    try {
        body = json::parse(request.getBody());
        if (!body.is_object()) throw std::runtime_error("not an object");
    } catch (const std::exception& e) {
        return errJson(HttpStatus::BAD_REQUEST, "invalid JSON body");
    }

    auto readStr = [&](const std::string& k) -> std::string {
        if (!body.contains(k) || !body[k].is_string()) return {};
        return trimStr(body[k].get<std::string>());
    };

    const std::string name        = readStr("name");
    const std::string phoneRaw    = readStr("phone");
    const std::string email       = readStr("email");
    const std::string ad          = readStr("ad");
    const std::string ageGroup    = readStr("age_group");
    const std::string gender      = readStr("gender");
    const std::string experience  = readStr("experience");
    const std::string position    = readStr("position");
    const std::string notes       = readStr("notes");

    // Basic validation: name is required; at least one contact method
    // is required so the coach can actually follow up.
    if (name.empty()) {
        return errJson(HttpStatus::BAD_REQUEST, "name is required");
    }
    if (phoneRaw.empty() && email.empty()) {
        return errJson(HttpStatus::BAD_REQUEST, "phone or email is required");
    }

    // Reject obviously bogus payloads — the frontend enforces reasonable
    // lengths but we double-check server-side to blunt scripted spam.
    if (name.size() > 200 || phoneRaw.size() > 40 || email.size() > 200 ||
        ad.size() > 60    || ageGroup.size() > 40 || gender.size() > 20 ||
        experience.size() > 40 || position.size() > 60 || notes.size() > 2000) {
        return errJson(HttpStatus::BAD_REQUEST, "field too long");
    }

    // Normalise phone: strip non-digits for the duplicate check but keep
    // the coach-friendly formatted version in the DB.
    std::string phoneDigits;
    for (char c : phoneRaw) if (c >= '0' && c <= '9') phoneDigits.push_back(c);

    try {
        auto db = Database::getInstance();

        // 2) Idempotent double-submit guard.  We look for a row created in
        //    the last 5 minutes matching either the phone (by digits) or
        //    email (case-insensitive), from the pickup funnel.  If found,
        //    return that id so the client shows the success screen either
        //    way — no leaked info about whether the row is new.
        if (!phoneDigits.empty() || !email.empty()) {
            const std::string phoneParam = phoneDigits.empty() ? std::string{} : phoneDigits;
            const std::string emailParam = email;
            auto dup = db->query(
                "SELECT id FROM leads "
                " WHERE form_id = 'pickup-funnel' "
                "   AND created_at > NOW() - INTERVAL '5 minutes' "
                "   AND ("
                "        ($1 <> '' AND regexp_replace(COALESCE(phone,''), '[^0-9]', '', 'g') = $1) "
                "     OR ($2 <> '' AND LOWER(COALESCE(email,'')) = LOWER($2)) "
                "       ) "
                " ORDER BY id DESC LIMIT 1",
                {phoneParam, emailParam});
            if (!dup.empty()) {
                const int existingId = dup[0][0].as<int>();
                std::ostringstream b;
                b << "{\"ok\":true,\"id\":" << existingId
                  << ",\"duplicate\":true"
                  << ",\"message\":\"Already received — we'll be in touch.\"}";
                return errOk(HttpStatus::OK, b.str());
            }
        }

        // 3) Build the synthetic leadgen_id.  Uniqueness is enforced by the
        //    UNIQUE constraint; collisions here would be a near-impossible
        //    accident (millisecond timestamp + 32-bit random hex).
        const auto nowMs = std::chrono::duration_cast<std::chrono::milliseconds>(
                              std::chrono::system_clock::now().time_since_epoch()).count();
        char randHex[9]; randHex[8] = '\0';
        std::srand(static_cast<unsigned>(nowMs) ^ static_cast<unsigned>(std::rand()));
        for (int i = 0; i < 8; ++i) {
            const int nib = std::rand() & 0xF;
            randHex[i] = static_cast<char>(nib < 10 ? ('0' + nib) : ('a' + nib - 10));
        }
        const std::string leadgenId = "guest-" + std::to_string(nowMs) + "-" + randHex;

        // 4) Build raw_fields as a Meta-shaped array so the admin UI's
        //    generic field renderer picks up ad/age/gender/experience/
        //    position/notes without any UI changes.  Each entry is
        //    {name, values:[value]}.
        json rawFields = json::array();
        auto pushField = [&](const char* n, const std::string& v) {
            if (v.empty()) return;
            rawFields.push_back({{"name", n}, {"values", json::array({v})}});
        };
        pushField("full_name",      name);
        pushField("phone_number",   phoneRaw);
        pushField("email",          email);
        pushField("ad",             ad);
        pushField("age_group",      ageGroup);
        pushField("gender",         gender);
        pushField("experience",     experience);
        pushField("position",       position);
        pushField("notes",          notes);
        const std::string rawFieldsJson = rawFields.dump();

        // 5) Insert.  Same NULLIF pattern as Lead::upsertFromMeta so
        //    empty-strings become SQL NULL and the row is compatible with
        //    the listAll() SELECT.
        db->query(
            "INSERT INTO leads (leadgen_id, form_id, page_id, ad_id, "
            "                   name, email, phone, raw_fields, "
            "                   preferred_channel, created_at) "
            "VALUES ($1, 'pickup-funnel', NULL, NULLIF($2, ''), "
            "        NULLIF($3, ''), NULLIF($4, ''), NULLIF($5, ''), "
            "        $6::jsonb, NULL, NOW())",
            {leadgenId, ad, name, email, phoneRaw, rawFieldsJson});

        auto idRow = db->query(
            "SELECT id FROM leads WHERE leadgen_id = $1",
            {leadgenId});
        const int newId = idRow.empty() ? 0 : idRow[0][0].as<int>();

        std::cerr << "[leads] guest signup id=" << newId
                  << " ad=" << (ad.empty() ? "(none)" : ad)
                  << " name=" << name
                  << " phone=" << (phoneRaw.empty() ? "-" : phoneRaw)
                  << " email=" << (email.empty()    ? "-" : email)
                  << std::endl;

        std::ostringstream b;
        b << "{\"ok\":true,\"id\":" << newId
          << ",\"message\":\"Got it — Coach James will reach out shortly.\"}";
        return errOk(HttpStatus::OK, b.str());
    } catch (const std::exception& e) {
        std::cerr << "[leads] guest signup failed: " << e.what() << std::endl;
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "signup failed");
    }
}
