#include "ClubLogoController.h"

#include <algorithm>
#include <cctype>
#include <iostream>

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../models/ClubLogo.h"
#include "../models/ClubLogoSearch.h"
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

}  // namespace

ClubLogoController::ClubLogoController() : model_(std::make_unique<ClubLogo>()) {}
ClubLogoController::~ClubLogoController() = default;

void ClubLogoController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",    [this](const Request& r) { return handleBoard(r); });
    router.post(prefix + "/upload",   [this](const Request& r) { return handleUpload(r); });
    router.post(prefix + "/from-url", [this](const Request& r) { return handleFromUrl(r); });
    router.post(prefix + "/alias",    [this](const Request& r) { return handleSetAlias(r); });
    router.del (prefix + "/alias",    [this](const Request& r) { return handleRemoveAlias(r); });
    router.post(prefix + "/search",        [this](const Request& r) { return handleSearch(r); });
    router.post(prefix + "/search/reject", [this](const Request& r) { return handleRejectSearch(r); });
}

bool ClubLogoController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Club logos are for club admins.");
    return false;
}

long long ClubLogoController::callerPersonId(const Request& request) {
    const long long userId = bearerUserId(request);
    if (userId <= 0) return 0;
    auto rows = Database::getInstance()->query("SELECT person_id FROM users WHERE id = $1::int",
                                               {std::to_string(userId)});
    if (rows.empty() || rows[0]["person_id"].is_null()) return 0;
    return rows[0]["person_id"].as<long long>();
}

long long ClubLogoController::clubFromBody(const json& body, bool* created, Response* error) {
    *created = false;
    const long long clubId = intField(body, "club_id");
    if (clubId > 0) {
        if (!model_->clubExists(clubId)) { *error = jsonError(HttpStatus::NOT_FOUND, "no such club"); return 0; }
        return clubId;
    }
    const std::string name = trim(strField(body, "club_name"));
    if (name.empty()) { *error = jsonError(HttpStatus::BAD_REQUEST, "club_id or club_name required"); return 0; }
    if (name.size() > 120) { *error = jsonError(HttpStatus::BAD_REQUEST, "club_name too long"); return 0; }
    long long id = model_->resolveClub(name);
    if (id > 0) return id;
    id = model_->createClub(name);
    if (id <= 0) { *error = jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "could not create the club"); return 0; }
    *created = true;
    return id;
}

Response ClubLogoController::handleBoard(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    try {
        json board = model_->board();
        board["searches"] = ClubLogoSearch().recent(40);
        return jsonOut(HttpStatus::OK, board);
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/club-logos/board] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubLogoController::handleUpload(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string dataUrl = strField(body, "image");
    const std::size_t comma = dataUrl.find(',');
    if (dataUrl.rfind("data:image/", 0) != 0 || comma == std::string::npos) {
        return jsonError(HttpStatus::BAD_REQUEST, "expected a data:image/… upload");
    }
    try {
        bool created = false;
        const long long clubId = clubFromBody(body, &created, &error);
        if (clubId <= 0) return error;
        const std::string bytes = base64Decode(dataUrl.substr(comma + 1));
        const auto saved = model_->save(clubId, bytes, "upload", "", strField(body, "filename"),
                                        callerPersonId(request));
        if (!saved.ok()) return jsonError(HttpStatus::BAD_REQUEST, saved.error);
        return jsonOut(HttpStatus::OK, {{"club_id", clubId}, {"created_club", created},
                                        {"logo_id", saved.logoId}, {"logo_url", saved.filePath}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/club-logos/upload] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubLogoController::handleFromUrl(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string url = trim(strField(body, "url"));
    if (url.rfind("https://", 0) != 0 && url.rfind("http://", 0) != 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "url must start with http:// or https://");
    }
    // Admin-only and one URL at a time, but still: no loopback / private hosts.
    {
        std::string host = url.substr(url.find("//") + 2);
        host = host.substr(0, host.find_first_of("/:?#"));
        std::transform(host.begin(), host.end(), host.begin(), [](unsigned char c) { return std::tolower(c); });
        if (host.empty() || host == "localhost" || host.rfind("127.", 0) == 0 || host.rfind("10.", 0) == 0 ||
            host.rfind("192.168.", 0) == 0 || host.rfind("172.", 0) == 0 || host.rfind("169.254.", 0) == 0 ||
            host.find(".") == std::string::npos) {
            return jsonError(HttpStatus::BAD_REQUEST, "that host is not allowed");
        }
    }
    try {
        bool created = false;
        const long long clubId = clubFromBody(body, &created, &error);
        if (clubId <= 0) return error;
        HttpClient http;
        auto res = http.get(url, {{"Accept", "image/*,*/*;q=0.8"}});
        if (!res.ok()) {
            return jsonError(HttpStatus::BAD_GATEWAY,
                             res.error.empty() ? "the site answered HTTP " + std::to_string(res.status)
                                               : "could not fetch: " + res.error);
        }
        if (!ClubLogo::sniff(res.body).ok) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "that URL is not an image (PNG, JPEG, WebP, GIF or SVG) — use the image's own address, not the page it sits on");
        }
        const std::string filename = url.substr(url.find_last_of('/') + 1).substr(0, 120);
        const auto saved = model_->save(clubId, res.body, "url", url, filename, callerPersonId(request));
        if (!saved.ok()) return jsonError(HttpStatus::BAD_REQUEST, saved.error);
        return jsonOut(HttpStatus::OK, {{"club_id", clubId}, {"created_club", created},
                                        {"logo_id", saved.logoId}, {"logo_url", saved.filePath}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/club-logos/from-url] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubLogoController::handleSetAlias(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    try {
        bool created = false;
        const long long clubId = clubFromBody(body, &created, &error);
        if (clubId <= 0) return error;
        std::string err;
        const long long id = model_->setAlias(strField(body, "alias"), clubId, &err);
        if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, err.empty() ? "could not save the alias" : err);
        return jsonOut(HttpStatus::OK, {{"alias_id", id}, {"club_id", clubId}, {"created_club", created}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/club-logos/alias] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubLogoController::handleRemoveAlias(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    long long id = 0;
    try { id = std::stoll(request.getQueryParam("id")); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        if (!model_->removeAlias(id)) return jsonError(HttpStatus::NOT_FOUND, "no such alias");
        return jsonOut(HttpStatus::OK, {{"removed", id}});
    } catch (const std::exception& e) {
        std::cerr << "[DELETE /api/club-logos/alias] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubLogoController::handleSearch(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string opponent = trim(strField(body, "opponent"));
    if (opponent.empty()) return jsonError(HttpStatus::BAD_REQUEST, "opponent required");
    try {
        const long long id = ClubLogoSearch().enqueue(opponent, callerPersonId(request), true);
        return jsonOut(HttpStatus::OK, {{"search_id", id}, {"opponent", opponent}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/club-logos/search] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response ClubLogoController::handleRejectSearch(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!gate(request, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const long long id = intField(body, "id");
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        if (!ClubLogoSearch().reject(id, callerPersonId(request))) {
            return jsonError(HttpStatus::NOT_FOUND, "no found crest to reject");
        }
        return jsonOut(HttpStatus::OK, {{"rejected", id}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/club-logos/search/reject] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
