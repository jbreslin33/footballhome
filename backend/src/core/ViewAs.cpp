#include "ViewAs.h"

#include <ctime>
#include <iostream>
#include <regex>
#include <string>

#include "Crypto.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

namespace {

Response jsonDeny(HttpStatus status, const std::string& message) {
    nlohmann::json body = {{"success", false}, {"message", message}, {"error", message}, {"viewAs", true}};
    Response r(status, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

// users.id from a verified bearer, or "" when missing/invalid.
std::string realUserId(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    if (h.size() <= 7 || h.compare(0, 7, "Bearer ") != 0) return "";
    std::string payload;
    if (!fh::crypto::verifyJwtHS256(h.substr(7), &payload)) return "";
    static const std::regex uidRe("\"userId\"\\s*:\\s*\"([0-9]+)\"");
    std::smatch m;
    if (!std::regex_search(payload, m, uidRe) || m.size() < 2) return "";
    return m[1].str();
}

}  // namespace

std::optional<Response> ViewAs::apply(Request& request) {
    const std::string raw = request.getHeader("X-View-As");
    if (raw.empty()) return std::nullopt;
    long long target = 0;
    try { target = std::stoll(raw); } catch (...) { target = 0; }
    if (target <= 0) return std::nullopt;

    const std::string uid = realUserId(request);
    if (uid.empty()) return std::nullopt;   // the handler's own 401 path

    try {
        auto* db = Database::getInstance();
        auto admin = db->query(
            "SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
            " WHERE a.user_id = $1::int AND al.name IN ('club', 'super') LIMIT 1",
            {uid});
        if (admin.empty()) return std::nullopt;   // not allowed: runs as themselves

        if (!request.isGet()) {
            return jsonDeny(HttpStatus::FORBIDDEN,
                            "Viewing as someone is read-only — exit view-as to change anything.");
        }

        // Their own login: the most recently seen users row for the person.
        auto u = db->query(
            "SELECT u.id, COALESCE(u.email, '') AS email, COALESCE(al.name, '') AS role "
            "  FROM users u "
            "  LEFT JOIN admins a ON a.user_id = u.id "
            "  LEFT JOIN admin_levels al ON al.id = a.admin_level_id "
            " WHERE u.person_id = $1::int "
            " ORDER BY u.last_seen_at DESC NULLS LAST, u.id DESC LIMIT 1",
            {std::to_string(target)});
        if (u.empty()) {
            return jsonDeny(HttpStatus::CONFLICT,
                            "This person has never signed in, so there is nothing to view as — view as their parent instead.");
        }

        // Same payload shape as AuthController::generateJWT (key order matters).
        const std::time_t now = std::time(nullptr);
        nlohmann::json esc = u[0]["email"].as<std::string>();
        nlohmann::json role = u[0]["role"].as<std::string>();
        const std::string payload =
            std::string("{\"userId\":\"") + u[0]["id"].as<std::string>() + "\","
            + "\"email\":" + esc.dump() + ","
            + "\"role\":" + role.dump() + ","
            + "\"iat\":" + std::to_string(now) + ","
            + "\"exp\":" + std::to_string(now + 300) + "}";
        request.setHeader("Authorization", "Bearer " + fh::crypto::signJwtHS256(payload));
        request.setHeader("Cookie", "");            // no session cookie may win over it
        request.setHeader("X-FH-View-As-Active", "1");
        return std::nullopt;
    } catch (const std::exception& e) {
        std::cerr << "[ViewAs] " << e.what() << std::endl;
        return jsonDeny(HttpStatus::INTERNAL_SERVER_ERROR, "View-as check failed.");
    }
}
