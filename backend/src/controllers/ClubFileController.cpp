#include "ClubFileController.h"

#include <algorithm>
#include <cctype>
#include <iostream>

#include "../database/Database.h"
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

long long intField(const json& body, const char* key) {
    if (!body.contains(key)) return 0;
    if (body[key].is_number_integer()) return body[key].get<long long>();
    if (body[key].is_string()) { try { return std::stoll(body[key].get<std::string>()); } catch (...) {} }
    return 0;
}

std::string strField(const json& body, const char* key) {
    return body.contains(key) && body[key].is_string() ? body[key].get<std::string>() : "";
}

std::string trim(std::string s) {
    auto notSpace = [](unsigned char c) { return !std::isspace(c); };
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), notSpace));
    s.erase(std::find_if(s.rbegin(), s.rend(), notSpace).base(), s.end());
    return s;
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

// Content-Disposition with an ASCII fallback and an RFC 5987 UTF-8 name.
std::string disposition(bool inl, const std::string& filename) {
    std::string ascii, enc;
    static const char* hx = "0123456789ABCDEF";
    for (unsigned char c : filename) {
        const bool plain = std::isalnum(c) || c == '.' || c == '-' || c == '_';
        ascii.push_back(plain ? static_cast<char>(c) : '_');
        if (plain) enc.push_back(static_cast<char>(c));
        else { enc.push_back('%'); enc.push_back(hx[c >> 4]); enc.push_back(hx[c & 15]); }
    }
    if (ascii.empty()) ascii = "file";
    return std::string(inl ? "inline" : "attachment") + "; filename=\"" + ascii + "\"; filename*=UTF-8''" + enc;
}

// /api/files/dl/12/anything → 12
long long idFromPath(const std::string& path) {
    const std::string key = "/dl/";
    const auto at = path.find(key);
    if (at == std::string::npos) return 0;
    std::string rest = path.substr(at + key.size());
    const auto slash = rest.find('/');
    if (slash != std::string::npos) rest = rest.substr(0, slash);
    try { return std::stoll(rest); } catch (...) { return 0; }
}

}  // namespace

ClubFileController::ClubFileController() : model_(std::make_unique<ClubFile>()) {}
ClubFileController::~ClubFileController() = default;

void ClubFileController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/list",          [this](const Request& r) { return handleList(r); });
    router.post(prefix + "/upload",        [this](const Request& r) { return handleUpload(r); });
    router.post(prefix + "/update",        [this](const Request& r) { return handleUpdate(r); });
    router.del (prefix,                    [this](const Request& r) { return handleDelete(r); });
    router.get (prefix + "/dl/:id",        [this](const Request& r) { return handleDownload(r); });
    router.get (prefix + "/dl/:id/:name",  [this](const Request& r) { return handleDownload(r); });
}

ClubFile::Viewer ClubFileController::viewer(const Request& request) {
    ClubFile::Viewer v;
    const long long userId = bearerUserId(request);
    if (userId <= 0) return v;
    v.signedIn = true;
    v.admin  = requireAdminLevel(request, {"club", "super"});
    v.super_ = requireAdminLevel(request, {"super"});
    auto rows = Database::getInstance()->query("SELECT person_id FROM users WHERE id = $1::int", {std::to_string(userId)});
    if (!rows.empty() && !rows[0]["person_id"].is_null()) v.personId = rows[0]["person_id"].as<long long>();
    return v;
}

bool ClubFileController::gateAdmin(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Uploading files is for club admins.");
    return false;
}

Response ClubFileController::handleList(const Request& request) {
    const ClubFile::Viewer v = viewer(request);
    if (!v.signedIn) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in to see files.");
    try {
        return jsonOut(HttpStatus::OK, {
            {"files", model_->list(v)},
            {"visibilities", model_->visibilities()},
            {"can_manage", v.admin},
            {"is_super", v.super_},
            {"person_id", v.personId},
            {"max_bytes", ClubFile::MAX_BYTES},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/files/list] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubFileController::handleUpload(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gateAdmin(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string dataUrl = strField(body, "file");
    const std::size_t comma = dataUrl.find(',');
    if (dataUrl.rfind("data:", 0) != 0 || comma == std::string::npos) {
        return jsonError(HttpStatus::BAD_REQUEST, "expected a data: URL upload");
    }
    try {
        const ClubFile::Viewer v = viewer(request);
        const std::string bytes = base64Decode(dataUrl.substr(comma + 1));
        std::string visibility = trim(strField(body, "visibility"));
        if (visibility.empty()) visibility = "private";
        const auto saved = model_->save(bytes, trim(strField(body, "filename")), trim(strField(body, "title")),
                                        trim(strField(body, "note")), visibility, v.personId);
        if (!saved.ok()) return jsonError(HttpStatus::BAD_REQUEST, saved.error);
        const ClubFile::Meta m = model_->meta(saved.id);
        return jsonOut(HttpStatus::OK, {{"id", saved.id}, {"mime", m.mime}, {"byte_size", m.byteSize}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/files/upload] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubFileController::handleUpdate(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gateAdmin(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const long long id = intField(body, "id");
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        const ClubFile::Meta cur = model_->meta(id);
        if (cur.id == 0) return jsonError(HttpStatus::NOT_FOUND, "no such file");
        std::string visibility = trim(strField(body, "visibility"));
        if (visibility.empty()) visibility = cur.visibility;
        const std::string title = body.contains("title") ? trim(strField(body, "title")) : cur.title;
        const std::string note  = body.contains("note")  ? trim(strField(body, "note"))  : cur.note;
        if (!model_->update(id, title, note, visibility)) return jsonError(HttpStatus::BAD_REQUEST, "unknown visibility");
        return jsonOut(HttpStatus::OK, {{"id", id}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/files/update] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubFileController::handleDelete(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gateAdmin(request, &error)) return error;
    long long id = 0;
    try { id = std::stoll(request.getQueryParam("id")); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        if (!model_->remove(id)) return jsonError(HttpStatus::NOT_FOUND, "no such file");
        return jsonOut(HttpStatus::OK, {{"deleted", id}});
    } catch (const std::exception& e) {
        std::cerr << "[DELETE /api/files] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubFileController::handleDownload(const Request& request) {
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such file");
    try {
        const ClubFile::Meta m = model_->meta(id);
        if (m.id == 0) return jsonError(HttpStatus::NOT_FOUND, "no such file");
        const ClubFile::Viewer v = viewer(request);
        if (!model_->canSee(m, v, model_->uploadedBy(id))) {
            // A stranger and a signed-in member both get 404 here rather
            // than a hint that the file exists; a signed-in caller never
            // sees 401 (the SPA would log them out).
            return jsonError(v.signedIn ? HttpStatus::FORBIDDEN : HttpStatus::NOT_FOUND, "no such file");
        }
        const bool inl = m.inlineOk && request.getQueryParam("download").empty();
        Response r(HttpStatus::OK, model_->bytes(id));
        r.setHeader("Content-Type", m.mime);
        r.setHeader("Content-Disposition", disposition(inl, m.filename));
        r.setHeader("X-Content-Type-Options", "nosniff");
        r.setHeader("Content-Security-Policy", "sandbox; default-src 'none'; img-src 'self'; style-src 'unsafe-inline'");
        r.setHeader("Cache-Control", m.visibility == "public" ? "public, max-age=300" : "private, no-store");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/files/dl] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
