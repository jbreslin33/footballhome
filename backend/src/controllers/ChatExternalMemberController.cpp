#include "ChatExternalMemberController.h"

#include <cmath>
#include <iostream>
#include <sstream>

#include "../models/ChatExternalMemberLinker.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// parseInt-style: number or numeric string only.  Empty string or
// non-numeric → fail (Node treats NaN as falsy).
bool readInt(const json& j, const char* key, long long& out) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return false;
    if (it->is_number_integer())  { out = it->get<long long>();                                  return true; }
    if (it->is_number_unsigned()) { out = static_cast<long long>(it->get<unsigned long long>()); return true; }
    if (it->is_number_float())    {
        const double d = it->get<double>();
        if (!std::isfinite(d)) return false;
        out = static_cast<long long>(d);
        return true;
    }
    if (it->is_string()) {
        try {
            size_t pos = 0;
            out = std::stoll(it->get<std::string>(), &pos);
            return pos > 0;
        } catch (const std::exception&) { return false; }
    }
    return false;
}

std::string readStrTrimmed(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    std::string s = it->get<std::string>();
    size_t a = 0;
    size_t b = s.size();
    while (a < b && std::isspace(static_cast<unsigned char>(s[a]))) ++a;
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

std::string jsonEscape(const std::string& s) { return json(s).dump(); }

Response badRequest(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::BAD_REQUEST, body.str());
}

Response notFound(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::NOT_FOUND, body.str());
}

Response internalErr(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::INTERNAL_SERVER_ERROR, body.str());
}

} // namespace

ChatExternalMemberController::ChatExternalMemberController()
    : model_(std::make_unique<ChatExternalMemberLinker>()) {}

ChatExternalMemberController::~ChatExternalMemberController() = default;

void ChatExternalMemberController::registerRoutes(Router& router,
                                                    const std::string& prefix) {
    router.post(prefix + "/link", [this](const Request& req) {
        return this->handleLink(req);
    });
}

Response ChatExternalMemberController::handleLink(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long chatIdLL = 0, personIdLL = 0;
    const bool chatOk    = readInt(body, "chatId",    chatIdLL);
    const std::string externalUserId = readStrTrimmed(body, "externalUserId");
    const bool personOk  = readInt(body, "personId",  personIdLL);

    if (!chatOk || externalUserId.empty() || !personOk) {
        return badRequest("chatId (int), externalUserId (string), and personId (int) are required");
    }

    try {
        auto linked = model_->link(static_cast<int>(chatIdLL),
                                    externalUserId,
                                    static_cast<int>(personIdLL));
        if (!linked) {
            return notFound("Chat member not found (chatId + externalUserId did not match any row)");
        }
        // Manual JSON build — preserve Node's insertion order
        // {linked: {chat_id, external_user_id, person_id}}.
        std::ostringstream out;
        out << "{\"linked\":{"
            <<   "\"chat_id\":"          << linked->chatId
            << ",\"external_user_id\":"  << jsonEscape(linked->externalUserId)
            << ",\"person_id\":"         << linked->personId
            << "}}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "ChatExternalMemberController::handleLink error: "
                  << e.what() << std::endl;
        return internalErr(e.what());
    }
}

bool ChatExternalMemberController::requireBearer(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    return h.size() > 7 && h.compare(0, 7, "Bearer ") == 0;
}
