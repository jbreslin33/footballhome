#include "ContactsController.h"

#include <algorithm>
#include <iostream>
#include <map>

#include "PhoneRelayController.h"
#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../models/Contacts.h"
#include "../models/MessageCopy.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

const std::vector<std::string> kGroups = {"members", "parents", "coaches", "staff", "leads", "opponents"};

// vCard 3.0 text value: \ , ; and newlines escaped.
std::string vEsc(const std::string& in) {
    std::string out;
    for (char c : in) {
        if (c == '\\') out += "\\\\";
        else if (c == ',') out += "\\,";
        else if (c == ';') out += "\;";
        else if (c == '\n') out += "\\n";
        else if (c != '\r') out.push_back(c);
    }
    return out;
}

std::string noteFor(MessageCopy& copy, const Contacts::Row& r) {
    const std::string g = r.groups.empty() ? "" : r.groups.front();
    MessageCopy::Rendered t;
    if (g == "members")        t = copy.render("contacts", "note_member",   {{"teams", r.teams}});
    else if (g == "coaches")   t = copy.render("contacts", "note_coach",    {{"teams", r.teams}});
    else if (g == "staff")     t = copy.render("contacts", "note_staff",    {});
    else if (g == "parents")   t = copy.render("contacts", "note_parent",   {{"kids", r.kids}});
    else if (g == "leads")     t = copy.render("contacts", "note_lead",     {{"since", r.since}});
    else if (g == "opponents") t = copy.render("contacts", "note_opponent", {{"club", r.org}, {"role", r.role}});
    std::string note = t.body;
    // A member who also coaches, a coach who is also a parent: the other hats.
    if (r.groups.size() > 1) {
        for (size_t i = 1; i < r.groups.size(); ++i) {
            const auto& og = r.groups[i];
            const auto label = copy.render("contacts", "group_" + og, {}).body;
            if (!label.empty()) note += " · " + label;
            if (og == "parents" && !r.kids.empty()) note += " of " + r.kids;
        }
    }
    return note;
}

std::string vcard(MessageCopy& copy, const std::string& org, const Contacts::Row& r) {
    std::string s = "BEGIN:VCARD\r\nVERSION:3.0\r\n";
    const std::string fn = r.last.empty() ? r.first : r.first + " " + r.last;
    s += "N:" + vEsc(r.last) + ";" + vEsc(r.first) + ";;;\r\n";
    s += "FN:" + vEsc(fn) + "\r\n";
    const std::string orgLine = r.kind == "club_contact" && !r.org.empty() ? r.org : org;
    if (!orgLine.empty()) s += "ORG:" + vEsc(orgLine) + "\r\n";
    if (!r.role.empty()) s += "TITLE:" + vEsc(r.role) + "\r\n";
    for (const auto& p : r.phones) s += "TEL;TYPE=CELL,VOICE:" + vEsc(p) + "\r\n";
    for (const auto& e : r.emails) s += "EMAIL;TYPE=INTERNET:" + vEsc(e) + "\r\n";
    std::string cats = org.empty() ? "" : vEsc(org);
    for (const auto& g : r.groups) {
        const auto label = copy.render("contacts", "group_" + g, {}).body;
        if (!label.empty()) cats += (cats.empty() ? "" : ",") + vEsc(label);
    }
    if (!cats.empty()) s += "CATEGORIES:" + cats + "\r\n";
    const std::string note = noteFor(copy, r);
    if (!note.empty()) s += "NOTE:" + vEsc(note) + "\r\n";
    s += "UID:fh-" + r.kind + "-" + std::to_string(r.refId) + "@footballhome.org\r\n";
    s += "END:VCARD\r\n";
    return s;
}

}  // namespace

ContactsController::ContactsController() : model_(std::make_unique<Contacts>()) {}
ContactsController::~ContactsController() = default;

bool ContactsController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Contacts are for club admins.");
    return false;
}

void ContactsController::registerRoutes(Router& router, const std::string& prefix) {
    // LA → DB → render (mig 1615: the list reads LA pickup memberships).
    laGet (router, prefix + "/summary", [](const Request&) { return Controller::allLaProgramIds(); },
           [this](const Request& r, const LaSyncMap&) { return handleSummary(r); });
    laPost(router, prefix + "/export",  [](const Request&) { return Controller::allLaProgramIds(); },
           [this](const Request& r, const LaSyncMap&) { return handleExport(r); });
    // 👤 FH Assistant (mig 1615): the paired phone pulls changed contacts in
    // batches; only the first batch of a run ({first: true}) syncs LA.
    laPost(router, prefix + "/device/pending",
           [](const Request& r) {
               bool first = false;
               try { auto b = json::parse(r.getBody().empty() ? "{}" : r.getBody()); first = b.value("first", false); } catch (...) {}
               return first ? Controller::allLaProgramIds() : std::vector<int>{};
           },
           [this](const Request& r, const LaSyncMap&) { return handleDevicePending(r); });
    router.post(prefix + "/device/ack", [this](const Request& r) { return handleDeviceAck(r); });
}

Response ContactsController::handleSummary(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    try {
        const long long userId = bearerUserId(request);
        const auto rows = model_->list(userId);
        json groups = json::object();
        for (const auto& g : kGroups) groups[g] = {{"new", 0}, {"changed", 0}, {"all", 0}};
        for (const auto& r : rows) {
            for (const auto& g : r.groups) {
                groups[g]["all"] = groups[g]["all"].get<int>() + 1;
                if (r.state == "new")     groups[g]["new"]     = groups[g]["new"].get<int>() + 1;
                if (r.state == "changed") groups[g]["changed"] = groups[g]["changed"].get<int>() + 1;
            }
        }
        return jsonOut(HttpStatus::OK, {{"groups", groups}, {"last_export", model_->lastExport(userId)}});
    } catch (const std::exception& e) {
        std::cerr << "ContactsController::handleSummary: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /export { groups: [..], scope: new|changed|all, dry_run?: bool }
// A contact in several picked groups goes once.  Not a dry run → the rows
// are logged as exported by this operator and the body is the .vcf.
Response ContactsController::handleExport(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }

    std::vector<std::string> groups;
    if (body.contains("groups") && body["groups"].is_array())
        for (const auto& g : body["groups"]) if (g.is_string()) groups.push_back(g.get<std::string>());
    if (groups.empty()) groups = kGroups;
    const std::string scope  = body.value("scope", "new");
    const bool        dryRun = body.value("dry_run", false);
    if (scope != "new" && scope != "changed" && scope != "all") return jsonError(HttpStatus::BAD_REQUEST, "scope must be new, changed or all");

    try {
        const long long userId = bearerUserId(request);
        std::vector<Contacts::Row> picked;
        for (auto& r : model_->list(userId)) {
            const bool inGroup = std::any_of(r.groups.begin(), r.groups.end(), [&](const std::string& g) {
                return std::find(groups.begin(), groups.end(), g) != groups.end(); });
            if (!inGroup) continue;
            if (scope == "new" && r.state != "new") continue;
            if (scope == "changed" && r.state == "done") continue;   // changed = new + changed
            picked.push_back(std::move(r));
        }
        MessageCopy copy;
        const std::string org = copy.render("contacts", "org", {}).body;
        std::string vcf;
        for (const auto& r : picked) vcf += vcard(copy, org, r);

        if (dryRun) {
            json sample = json::array();
            for (size_t i = 0; i < picked.size() && i < 3; ++i) sample.push_back(vcard(copy, org, picked[i]));
            return jsonOut(HttpStatus::OK, {{"count", picked.size()}, {"bytes", vcf.size()}, {"sample", sample}});
        }
        model_->logExport(userId, picked);
        Response r(HttpStatus::OK, vcf);
        r.setHeader("Content-Type", "text/vcard; charset=utf-8");
        r.setHeader("Content-Disposition", "attachment; filename=\"" +
                    (copy.render("contacts", "filename", {}).body.empty() ? std::string("contacts.vcf")
                                                                         : copy.render("contacts", "filename", {}).body) + "\"");
        r.setHeader("X-Contact-Count", std::to_string(picked.size()));
        return r;
    } catch (const std::exception& e) {
        std::cerr << "ContactsController::handleExport: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ── 👤 FH Assistant contacts (mig 1615) ─────────────────────────────────
// Owner 11/20: "make fh texter just fh assistant … an app that takes all
// leads and members pickup and regular and adds them to my phone
// contacts(google)" + "i just want all contacts … i dont' think we need to
// group them".  Every #contacts row, one card per row; the phone writes
// them into the Google account it picked and acks what it saved.  A card
// goes again when anything on it changes (name, numbers, emails, note).
namespace {
json deviceCard(MessageCopy& copy, const std::string& org, const Contacts::Row& r) {
    const std::string orgLine = r.kind == "club_contact" && !r.org.empty() ? r.org : org;
    json c = {
        {"uid",    "fh-" + r.kind + "-" + std::to_string(r.refId)},
        {"first",  r.first}, {"last", r.last},
        {"org",    orgLine}, {"title", r.role},
        {"phones", r.phones}, {"emails", r.emails},
        {"note",   noteFor(copy, r)},
    };
    c["fp"] = fh::crypto::sha256Hex(c.dump()).substr(0, 32);
    return c;
}

// The paired phone of a club admin, else *error.
bool adminDevice(const Request& request, long long* deviceId, Response* error) {
    long long personId = 0;
    if (!PhoneRelayController::deviceFromRequest(request, deviceId, &personId)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "This phone is not paired.");
        return false;
    }
    auto ok = Database::getInstance()->query(
        "SELECT 1 FROM users u JOIN admins a ON a.user_id = u.id JOIN admin_levels al ON al.id = a.admin_level_id "
        " WHERE u.person_id = $1::int AND al.name IN ('club', 'super') LIMIT 1", {std::to_string(personId)});
    if (ok.empty()) { *error = jsonError(HttpStatus::FORBIDDEN, "Contacts are for club admins' phones."); return false; }
    return true;
}
}  // namespace

// POST /device/pending {limit?, first?} → {contacts: [...], remaining}
Response ContactsController::handleDevicePending(const Request& request) {
    long long deviceId = 0;
    Response error(HttpStatus::OK, "");
    if (!adminDevice(request, &deviceId, &error)) return error;
    int limit = 200;
    try { auto b = json::parse(request.getBody().empty() ? "{}" : request.getBody()); limit = b.value("limit", 200); } catch (...) {}
    limit = std::max(1, std::min(limit, 500));
    try {
        std::map<std::string, std::string> have;
        for (const auto& r : Database::getInstance()->query(
                 "SELECT uid, fp FROM phone_contact_sync WHERE device_id = $1::int", {std::to_string(deviceId)}))
            have[r["uid"].c_str()] = r["fp"].c_str();
        MessageCopy copy;
        const std::string org = copy.render("contacts", "org", {}).body;
        json out = json::array();
        int remaining = 0;
        for (const auto& r : model_->list(0)) {
            json c = deviceCard(copy, org, r);
            auto it = have.find(c["uid"].get<std::string>());
            if (it != have.end() && it->second == c["fp"].get<std::string>()) continue;
            if (static_cast<int>(out.size()) < limit) out.push_back(std::move(c)); else ++remaining;
        }
        Database::getInstance()->query("UPDATE phone_relay_devices SET last_seen_at = now() WHERE id = $1::int", {std::to_string(deviceId)});
        return jsonOut(HttpStatus::OK, {{"contacts", out}, {"remaining", remaining}});
    } catch (const std::exception& e) {
        std::cerr << "ContactsController::handleDevicePending: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not list contacts");
    }
}

// POST /device/ack {done: [{uid, fp}]} — saved on the phone.
Response ContactsController::handleDeviceAck(const Request& request) {
    long long deviceId = 0;
    Response error(HttpStatus::OK, "");
    if (!adminDevice(request, &deviceId, &error)) return error;
    json body;
    try { body = json::parse(request.getBody().empty() ? "{}" : request.getBody()); }
    catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    if (!body.contains("done") || !body["done"].is_array()) return jsonError(HttpStatus::BAD_REQUEST, "done must be an array");
    int n = 0;
    try {
        auto* db = Database::getInstance();
        for (const auto& d : body["done"]) {
            if (!d.is_object() || !d.contains("uid") || !d.contains("fp") || !d["uid"].is_string() || !d["fp"].is_string()) continue;
            db->query("INSERT INTO phone_contact_sync (device_id, uid, fp) VALUES ($1::int, $2, $3) "
                      "ON CONFLICT (device_id, uid) DO UPDATE SET fp = EXCLUDED.fp, synced_at = now()",
                      {std::to_string(deviceId), d["uid"].get<std::string>().substr(0, 80), d["fp"].get<std::string>().substr(0, 64)});
            ++n;
        }
        return jsonOut(HttpStatus::OK, {{"saved", n}});
    } catch (const std::exception& e) {
        std::cerr << "ContactsController::handleDeviceAck: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not record");
    }
}
