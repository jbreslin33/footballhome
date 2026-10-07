#include "ContactsController.h"

#include <algorithm>
#include <iostream>
#include <map>

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
    router.get (prefix + "/summary", [this](const Request& r) { return handleSummary(r); });
    router.post(prefix + "/export",  [this](const Request& r) { return handleExport(r); });
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
