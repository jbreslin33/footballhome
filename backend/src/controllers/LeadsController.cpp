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
    router.get (prefix + "/unjoined-members", [this](const Request& r){ return handleUnjoinedMembers (r); });
    router.get (prefix + "/analytics",        [this](const Request& r){ return handleAnalytics       (r); });
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
// Lists ALL current Lighthouse members (Men / Women / Boys / Girls).
// The frontend uses this list for two purposes:
//   1. Render the blue "Members" section on the leads screen.
//   2. Cross-reference each lead's email against the union of member
//      emails; any lead that matches a member is hidden from the main
//      leads list (they're already in the club — they aren't a prospect).
//
// Endpoint name retained for backward compat with the original
// "members not in the leads funnel" framing; today's behavior is
// strictly broader (no lead-overlap filtering happens here).
//
// Sources:
//   • Men   — mens_team_assignments → external_person_aliases('leagueapps')
//             → persons → person_emails, with email/phone overlay from
//             a live LA fetch (person_emails is sparse for men).
//   • Women — rosters (left_at IS NULL) → players → persons, restricted to
//             teams.gender_category='womens'.
//   • Boys  — live LA fetch via YouthRoster::run(), club="Boys Club".
//   • Girls — same, club="Girls Club"; emails surface as parentEmail || playerEmail.
// ────────────────────────────────────────────────────────────────────────────
Response LeadsController::handleUnjoinedMembers(const Request& request) {
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

        // 2. Men — mens_team_assignments only counts rostered or pool, both
        //    are members of the club.  We do NOT filter on_roster=true so
        //    bench/pool members are surfaced too.
        //
        //    Email enrichment: person_emails is often empty for men because
        //    the mens-roster sync pre-dates the email-import path.  We do a
        //    live LA fetch and overlay email/phone from the registration
        //    record when the DB column came back blank.  Same LA-derived
        //    email is also checked against leadEmails so a man who DID join
        //    via Meta but never had person_emails populated is correctly
        //    excluded from the "unjoined" list.
        {
            // Build LA user_id -> { email, phone } map.  Failure is
            // non-fatal: we just fall back to the pre-enrichment behavior.
            std::unordered_map<long long, std::pair<std::string, std::string>> laMap;
            try {
                const char* mensProgIdEnv = std::getenv("LEAGUEAPPS_MENS_PROGRAM_ID");
                const int mensProgId = mensProgIdEnv ? std::atoi(mensProgIdEnv) : 5039300;
                auto recs = LeagueAppsService::getInstance()
                                .fetchProgramRegistrations(mensProgId);
                for (const auto& r : recs) {
                    auto uidIt = r.find("userId");
                    if (uidIt == r.end() || uidIt->is_null()) continue;
                    long long uid = 0;
                    try {
                        if (uidIt->is_number_integer()) uid = uidIt->get<long long>();
                        else if (uidIt->is_string())    uid = std::stoll(uidIt->get<std::string>());
                    } catch (...) { continue; }
                    auto strField = [&](const char* k) -> std::string {
                        auto it = r.find(k);
                        if (it == r.end() || !it->is_string()) return {};
                        return it->get<std::string>();
                    };
                    const std::string email = strField("email");
                    const std::string phone = strField("phone");
                    // First-seen wins; LA already dedups by latest reg.
                    laMap.emplace(uid, std::make_pair(email, phone));
                }
            } catch (const std::exception& e) {
                std::cerr << "unjoined-members: men LA fetch failed: "
                          << e.what() << " — continuing without enrichment."
                          << std::endl;
            }

            auto rs = db->query(
                "SELECT t.name AS team_name, p.id AS person_id, "
                "       p.first_name, p.last_name, m.leagueapps_user_id, "
                "       COALESCE((SELECT string_agg(pe.email, ', ' ORDER BY pe.is_primary DESC, pe.email) "
                "                  FROM person_emails pe WHERE pe.person_id = p.id), '') AS emails "
                "  FROM mens_team_assignments m "
                "  JOIN teams t ON t.id = m.team_id "
                "  JOIN external_person_aliases epa "
                "    ON epa.provider = 'leagueapps' "
                "   AND epa.external_user_id = m.leagueapps_user_id::text "
                "  JOIN persons p ON p.id = epa.person_id "
                " ORDER BY t.name, p.last_name, p.first_name");
            for (const auto& row : rs) {
                const long long uid = row["leagueapps_user_id"].as<long long>();
                std::string emails = row["emails"].c_str();
                std::string phone;
                auto laIt = laMap.find(uid);
                if (laIt != laMap.end()) {
                    const std::string& laEmail = laIt->second.first;
                    const std::string& laPhone = laIt->second.second;
                    if (emails.empty() && !laEmail.empty()) emails = laEmail;
                    if (phone.empty()  && !laPhone.empty()) phone  = laPhone;
                }
                emit("Men",
                     row["person_id"].as<int>(),
                     uid,
                     row["first_name"].is_null() ? std::string{} : row["first_name"].c_str(),
                     row["last_name"].is_null()  ? std::string{} : row["last_name"].c_str(),
                     row["team_name"].is_null()  ? std::string{} : row["team_name"].c_str(),
                     emails,
                     phone);
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

        // 5. Catch-all — every LA-linked person surfaced by ANY registration
        //    in the `leagueapps_programs` registry (active + paused sub-
        //    programs).  Paused-membership regs, and any active reg whose
        //    person hasn't landed in a roster table yet, get emitted here
        //    so their email/phone flows into the frontend's suppression
        //    set (a paused member must never be cold-emailed).
        //
        //    Contact info comes from person_emails / person_phones (which
        //    PersonLinker::linkLa now backfills on every sync).  For youth
        //    the child's `parent_person_id` redirects the contact lookup
        //    to the parent's rows.  LA record fields (email / parentEmail
        //    / phoneNumber / parentPhone) are used as a fallback when the
        //    DB tables are still empty.
        try {
            auto progRows = db->query(
                "SELECT program_id, category, variant, program_name "
                "  FROM leagueapps_programs ORDER BY category, variant");
            auto& la = LeagueAppsService::getInstance();
            for (const auto& prog : progRows) {
                const int pid = static_cast<int>(prog["program_id"].as<long long>());
                const std::string cat = prog["category"].is_null() ? std::string{} : prog["category"].c_str();
                const std::string var = prog["variant"].is_null()  ? std::string{} : prog["variant"].c_str();
                const std::string progName = prog["program_name"].is_null() ? std::string{} : prog["program_name"].c_str();

                // Human-friendly labels for the frontend Members card.
                std::string uiCategory;
                if      (cat == "men")   uiCategory = (var == "paused") ? "Men Paused"   : "Men";
                else if (cat == "boys")  uiCategory = (var == "paused") ? "Boys Paused"  : "Boys";
                else if (cat == "girls") uiCategory = (var == "paused") ? "Girls Paused" : "Girls";
                else                     uiCategory = cat;

                std::vector<nlohmann::json> recs;
                try {
                    recs = la.fetchProgramRegistrations(pid);
                } catch (const std::exception& e) {
                    std::cerr << "unjoined-members: LA fetch failed for program="
                              << pid << ": " << e.what() << std::endl;
                    continue;
                }

                for (const auto& r : recs) {
                    // Per user directive 2026-07-01: no registrationStatus
                    // filter — any presence in a sub-program = member.

                    long long uid = 0;
                    auto uidIt = r.find("userId");
                    if (uidIt == r.end() || uidIt->is_null()) continue;
                    try {
                        if      (uidIt->is_number_integer()) uid = uidIt->get<long long>();
                        else if (uidIt->is_string())         uid = std::stoll(uidIt->get<std::string>());
                    } catch (...) { continue; }
                    if (uid <= 0) continue;
                    if (emittedLaUids.count(uid)) continue;

                    // Resolve person via LA alias.  If the alias hasn't
                    // been created yet (linker hasn't seen this rec) fall
                    // back to LA record fields so we still suppress.
                    auto pLookup = db->query(
                        "SELECT p.id AS person_id, p.first_name, p.last_name, "
                        "       p.parent_person_id "
                        "  FROM external_person_aliases a "
                        "  JOIN persons p ON p.id = a.person_id "
                        " WHERE a.provider = 'leagueapps' "
                        "   AND a.external_user_id = $1 LIMIT 1",
                        {std::to_string(uid)});

                    std::optional<int> personId;
                    std::string fn, ln;
                    int contactPersonId = 0;
                    if (!pLookup.empty()) {
                        const auto& row = pLookup[0];
                        personId = row["person_id"].as<int>();
                        contactPersonId = *personId;
                        fn = row["first_name"].is_null() ? std::string{} : row["first_name"].c_str();
                        ln = row["last_name"].is_null()  ? std::string{} : row["last_name"].c_str();
                        if (!row["parent_person_id"].is_null()) {
                            contactPersonId = row["parent_person_id"].as<int>();
                        }
                    }

                    // Fallback names from LA rec if no person row.
                    auto strField = [&](const char* k) -> std::string {
                        auto it = r.find(k);
                        if (it == r.end() || !it->is_string()) return {};
                        return it->get<std::string>();
                    };
                    if (fn.empty()) fn = strField("firstName");
                    if (ln.empty()) ln = strField("lastName");

                    // Contact from person_emails / person_phones (or parent's).
                    std::string emails, phone;
                    if (contactPersonId > 0) {
                        auto ems = db->query(
                            "SELECT COALESCE(string_agg(email, ', ' "
                            "                 ORDER BY is_primary DESC, email), '') AS emails "
                            "  FROM person_emails WHERE person_id = $1::int",
                            {std::to_string(contactPersonId)});
                        if (!ems.empty() && !ems[0]["emails"].is_null()) {
                            emails = ems[0]["emails"].c_str();
                        }
                        auto phs = db->query(
                            "SELECT phone_number FROM person_phones "
                            " WHERE person_id = $1::int "
                            " ORDER BY is_primary DESC, id LIMIT 1",
                            {std::to_string(contactPersonId)});
                        if (!phs.empty() && !phs[0]["phone_number"].is_null()) {
                            phone = phs[0]["phone_number"].c_str();
                        }
                    }
                    // Fallback to LA record fields if DB tables empty.
                    if (emails.empty()) {
                        std::string e = strField("email");
                        if (e.empty()) e = strField("parentEmail");
                        if (!e.empty()) emails = e;
                    }
                    if (phone.empty()) {
                        std::string p = strField("phoneNumber");
                        if (p.empty()) p = strField("phone");
                        if (p.empty()) p = strField("parentPhone");
                        if (!p.empty()) phone = p;
                    }

                    emit(uiCategory, personId, uid, fn, ln, progName, emails, phone);
                }
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
            auto res = mr.run(/*includeAll=*/false);
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
