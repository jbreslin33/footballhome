#include "LockupController.h"

#include <sys/stat.h>
#include <chrono>
#include <ctime>
#include <fstream>
#include <iostream>
#include <sstream>

#include "../core/Crypto.h"
#include "../models/FacilityLockup.h"
#include "../models/MessageCopy.h"
#include "../services/LockupScheduler.h"
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
bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}
std::string strField(const json& body, const char* key) {
    return (body.contains(key) && body[key].is_string()) ? body[key].get<std::string>() : std::string();
}
long long intField(const json& body, const char* key) {
    if (!body.contains(key)) return 0;
    if (body[key].is_number_integer()) return body[key].get<long long>();
    if (body[key].is_string()) { try { return std::stoll(body[key].get<std::string>()); } catch (...) {} }
    return 0;
}

std::string esc(const std::string& s) {
    std::string o;
    for (char c : s) {
        switch (c) {
            case '&': o += "&amp;"; break; case '<': o += "&lt;"; break;
            case '>': o += "&gt;"; break; case '"': o += "&quot;"; break;
            default: o.push_back(c);
        }
    }
    return o;
}

// Standard base64 (the data: URL alphabet), whitespace ignored.
std::string base64Decode(const std::string& in) {
    static int table[256];
    static bool init = false;
    if (!init) {
        for (int& v : table) v = -1;
        const char* a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        for (int i = 0; i < 64; ++i) table[static_cast<unsigned char>(a[i])] = i;
        init = true;
    }
    std::string out;
    out.reserve(in.size() * 3 / 4);
    int val = 0, bits = -8;
    for (unsigned char c : in) {
        if (c == '=') break;
        if (table[c] < 0) continue;
        val = (val << 6) + table[c];
        bits += 6;
        if (bits >= 0) { out.push_back(static_cast<char>((val >> bits) & 0xFF)); bits -= 8; }
    }
    return out;
}

// The landing pages: structure only — every word is a lockup/page_* row.
// `form` is the upload control on the page_upload page (empty otherwise).
Response htmlPage(const std::string& title, const std::string& body, const std::string& form = "") {
    std::ostringstream h;
    h << "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
         "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
         "<meta name=\"robots\" content=\"noindex\">"
         "<title>" << esc(title) << "</title>"
         "<link rel=\"icon\" href=\"/images/lighthouse-1893-crest.png\" type=\"image/png\">"
         "<style>body{margin:0;background:#0b1c3d;color:#f6f8fc;font:18px/1.5 -apple-system,BlinkMacSystemFont,"
         "'Segoe UI',Roboto,sans-serif}main{max-width:560px;margin:0 auto;padding:40px 20px}"
         "h1{color:#ffcc00;font-size:28px;margin:0 0 16px}p{margin:0 0 12px}a{color:#ffcc00}"
         ".cam{display:block;text-align:center;margin:24px 0;padding:18px;border-radius:14px;background:#4ade80;"
         "color:#0b1c3d;font-weight:800;font-size:20px;cursor:pointer}.cam input{display:none}"
         ".busy{opacity:.5;pointer-events:none}#msg{min-height:1.5em}img.prev{max-width:100%;border-radius:12px;margin-top:12px}"
         "</style></head><body><main><h1 id=\"ttl\">" << esc(title) << "</h1><div id=\"body\">";
    std::istringstream lines(body);
    std::string line;
    while (std::getline(lines, line)) if (!line.empty()) h << "<p>" << esc(line) << "</p>";
    h << "</div>" << form << "<p id=\"msg\"></p><p><a href=\"/\">footballhome.org</a></p></main></body></html>";
    Response r(HttpStatus::OK, h.str());
    r.setHeader("Content-Type", "text/html; charset=utf-8");
    r.setHeader("Cache-Control", "no-store");
    return r;
}

}  // namespace

LockupController::LockupController() : model_(std::make_unique<FacilityLockup>()) {}
LockupController::~LockupController() = default;

void LockupController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",     [this](const Request& r) { return handleBoard(r); });
    router.post(prefix + "/photo",     [this](const Request& r) { return handlePhoto(r); });
    router.get (prefix + "/tap",       [this](const Request& r) { return handleTap(r); });
    router.post(prefix + "/tap-photo", [this](const Request& r) { return handleTapPhoto(r); });
    router.post(prefix + "/test",      [this](const Request& r) { return handleTest(r); });
}

bool LockupController::resolveScope(const Request& request, Scope* scope, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    scope->userId   = bearerUserId(request);
    scope->personId = model_->personForUser(scope->userId);
    scope->isAdmin  = model_->isAdminUser(scope->userId);
    if (!model_->canView(scope->personId, scope->isAdmin)) {
        *error = jsonError(HttpStatus::FORBIDDEN, "Security is for club admins, coaches and the people on the lock-up list.");
        return false;
    }
    return true;
}

std::string LockupController::savePhoto(long long lockupId, const std::string& dataUrl,
                                        std::string* mime, long long* byteSize, std::string* error) {
    const std::size_t comma = dataUrl.find(',');
    if (dataUrl.rfind("data:image/", 0) != 0 || comma == std::string::npos) {
        *error = "expected a data:image/… upload";
        return "";
    }
    const std::string bytes = base64Decode(dataUrl.substr(comma + 1));
    if (bytes.size() < 64) { *error = "empty image"; return ""; }
    if (bytes.size() > 12 * 1024 * 1024) { *error = "image over 12 MB"; return ""; }
    std::string ext;
    if (bytes.compare(0, 3, "\xFF\xD8\xFF") == 0) { ext = "jpg"; *mime = "image/jpeg"; }
    else if (bytes.compare(0, 8, "\x89PNG\r\n\x1a\n") == 0) { ext = "png"; *mime = "image/png"; }
    else if (bytes.compare(0, 4, "RIFF") == 0 && bytes.size() > 12 && bytes.compare(8, 4, "WEBP") == 0) { ext = "webp"; *mime = "image/webp"; }
    else { *error = "not a JPEG, PNG or WebP"; return ""; }

    const std::string dir = "/app/images/security";
    mkdir(dir.c_str(), 0755);
    const auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    char stamp[32];
    std::strftime(stamp, sizeof stamp, "%Y%m%d-%H%M%S", std::gmtime(&now));
    const std::string name = "lockup-" + std::to_string(lockupId) + "-" + stamp + "-" +
                             fh::crypto::randomTokenB64Url(6).substr(0, 8) + "." + ext;
    std::ofstream f(dir + "/" + name, std::ios::binary);
    if (!f.is_open()) { *error = "could not write the photo"; return ""; }
    f.write(bytes.data(), static_cast<std::streamsize>(bytes.size()));
    f.close();
    *byteSize = static_cast<long long>(bytes.size());
    return "/images/security/" + name;
}

Response LockupController::handleBoard(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    try {
        model_->syncToday();
        json today = json::array();
        for (const auto& l : model_->todays()) today.push_back(model_->toJson(l));
        json hist = json::array();
        for (const auto& l : model_->history(30)) hist.push_back(model_->toJson(l));
        return jsonOut(HttpStatus::OK, {
            {"today", today}, {"history", hist}, {"people", model_->peopleJson()},
            {"is_admin", scope.isAdmin}, {"person_id", scope.personId},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/security/board] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response LockupController::handlePhoto(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const long long id = intField(body, "lockup_id");
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "lockup_id required");
    try {
        FacilityLockup::Lockup l;
        if (!model_->get(id, &l)) return jsonError(HttpStatus::NOT_FOUND, "no such night");
        std::string mime, err;
        long long size = 0;
        const std::string path = savePhoto(id, strField(body, "image"), &mime, &size, &err);
        if (path.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
        model_->addPhoto(id, scope.personId, path, mime, size);
        model_->get(id, &l);
        return jsonOut(HttpStatus::OK, {{"lockup", model_->toJson(l)}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/security/photo] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response LockupController::handleTap(const Request& request) {
    const std::string raw = request.getQueryParam("t");
    FacilityLockup::Lockup l;
    std::string tier, firstName;
    try {
        const auto t = model_->lookupToken(raw);
        firstName = t.firstName;
        // A used link on a night that is already locked says so, rather
        // than "expired" — that is what the second tap usually means.
        if (!t.found || !model_->get(t.lockupId, &l)) tier = "page_invalid";
        else if (l.confirmed()) tier = "page_already";
        else if (!t.live || t.used) tier = "page_invalid";
        else tier = "page_upload";
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/security/tap] " << e.what() << std::endl;
        tier = "page_invalid";
    }
    const auto copy = MessageCopy().render("lockup", tier, model_->tokens(l, firstName, "", 0));
    if (!copy.ok()) return htmlPage("Football Home", "lockup/" + tier + " copy missing (migration 424)");
    if (tier != "page_upload") return htmlPage(copy.subject, copy.body);

    // The one control on the page: open the camera, shrink, post, swap
    // the words for what the server answers.  Button labels are copy too
    // (kind='lockup', tiers ui_*), read by the page script.
    MessageCopy ui;
    const auto btn  = ui.render("lockup", "ui_upload_button", {});
    const auto busy = ui.render("lockup", "ui_uploading", {});
    const auto fail = ui.render("lockup", "ui_upload_failed", {});
    std::ostringstream form;
    form << "<label class=\"cam\" id=\"cam\">" << esc(btn.ok() ? btn.body : "Upload photo")
         << "<input type=\"file\" accept=\"image/*\" id=\"file\"></label>"
         << "<script src=\"/js/lib/photo-shrink.js?v=20260924a\"></script><script>"
         << "(function(){var f=document.getElementById('file'),cam=document.getElementById('cam'),msg=document.getElementById('msg');"
         << "f.addEventListener('change',async function(){if(!f.files||!f.files[0])return;cam.classList.add('busy');"
         << "msg.textContent=" << json(busy.ok() ? busy.body : "Uploading…").dump() << ";"
         << "try{var img=await window.shrinkPhoto(f.files[0],1600,0.82);"
         << "var res=await fetch('/api/security/tap-photo?t='+encodeURIComponent(" << json(raw).dump() << "),"
         << "{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({image:img})});"
         << "var d=await res.json().catch(function(){return{}});if(!res.ok)throw new Error(d.error||('HTTP '+res.status));"
         << "document.getElementById('ttl').textContent=d.title||'';var b=document.getElementById('body');b.innerHTML='';"
         << "(d.body||'').split('\\n').forEach(function(t){if(t){var p=document.createElement('p');p.textContent=t;b.appendChild(p);}});"
         << "var pv=document.createElement('img');pv.className='prev';pv.src=img;b.appendChild(pv);cam.remove();msg.textContent='';}"
         << "catch(e){cam.classList.remove('busy');msg.textContent=" << json(fail.ok() ? fail.body : "Upload failed: ").dump() << "+(e.message||'');}});})();"
         << "</script>";
    return htmlPage(copy.subject, copy.body, form.str());
}

Response LockupController::handleTapPhoto(const Request& request) {
    json body;
    Response error(HttpStatus::OK, "");
    if (!parseBody(request, &body, &error)) return error;
    try {
        const auto t = model_->lookupToken(request.getQueryParam("t"));
        FacilityLockup::Lockup l;
        if (!t.found || !t.live || t.used || !model_->get(t.lockupId, &l))
            return jsonError(HttpStatus::FORBIDDEN, "This link has expired");
        std::string mime, err;
        long long size = 0;
        const std::string path = savePhoto(l.id, strField(body, "image"), &mime, &size, &err);
        if (path.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
        model_->addPhoto(l.id, t.personId, path, mime, size);
        model_->markTokenUsed(t.id);
        model_->get(l.id, &l);
        const auto copy = MessageCopy().render("lockup", "page_uploaded", model_->tokens(l, t.firstName, "", 0));
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"title", copy.subject}, {"body", copy.body}, {"url", path}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/security/tap-photo] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response LockupController::handleTest(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    if (!scope.isAdmin) return jsonError(HttpStatus::FORBIDDEN, "Admins only");
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string channel = strField(body, "channel");
    if (channel != "email" && channel != "sms" && channel != "call")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be email, sms or call");
    try {
        model_->syncToday();
        FacilityLockup::Lockup target;
        bool have = false;
        for (const auto& l : model_->todays()) if (l.id > 0) { target = l; have = true; break; }
        if (!have) return jsonError(HttpStatus::CONFLICT, "No lock-up tonight to test with (no events at a lock-up facility today).");
        FacilityLockup::Recipient me;
        for (const auto& r : model_->recipients(target.id, "escalation")) if (r.personId == scope.personId) me = r;
        for (const auto& r : model_->recipients(target.id, "closer"))     if (r.personId == scope.personId && me.personId == 0) me = r;
        if (me.personId == 0) return jsonError(HttpStatus::CONFLICT, "You are not on the lock-up list for this facility (facility_lockup_people).");
        auto out = LockupScheduler::deliver(*model_, target, me, "test", channel, target.alertCount + 1);
        return jsonOut(HttpStatus::OK, {{"ok", out.ok}, {"contact", out.contact}, {"error", out.error},
                                        {"lockup", model_->toJson(target)}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/security/test] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
