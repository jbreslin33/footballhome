#include "PayReminderLogController.h"

#include <cctype>
#include <cmath>
#include <iostream>
#include <limits>
#include <sstream>

#include "../models/PayReminderLog.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

bool readInt(const json& j, const char* key, long long& out) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return false;
    if (it->is_number_integer())  { out = it->get<long long>();                                  return true; }
    if (it->is_number_unsigned()) { out = static_cast<long long>(it->get<unsigned long long>()); return true; }
    if (it->is_number_float())    { out = static_cast<long long>(it->get<double>());             return true; }
    if (it->is_string()) {
        try { out = std::stoll(it->get<std::string>()); return true; }
        catch (const std::exception&) { return false; }
    }
    return false;
}

bool readDouble(const json& j, const char* key, double& out) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return false;
    if (it->is_number()) { out = it->get<double>(); return std::isfinite(out); }
    if (it->is_string()) {
        try {
            size_t pos = 0;
            out = std::stod(it->get<std::string>(), &pos);
            return std::isfinite(out);
        } catch (const std::exception&) { return false; }
    }
    return false;
}

std::string readStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

std::string jsonEscape(const std::string& s) { return json(s).dump(); }

Response badRequest(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::BAD_REQUEST, body.str());
}

} // namespace

PayReminderLogController::PayReminderLogController()
    : model_(std::make_unique<PayReminderLog>()) {}

PayReminderLogController::~PayReminderLogController() = default;

void PayReminderLogController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix, [this](const Request& req) { return this->handleCreate(req); });
}

Response PayReminderLogController::handleCreate(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("invalid json body");
    }

    long long laUserId = 0;
    if (!readInt(body, "leagueAppsUserId", laUserId) || laUserId <= 0) {
        return badRequest("leagueAppsUserId required");
    }

    const std::string method = readStr(body, "method");
    if (method != "sms" && method != "email") {
        return badRequest("method must be 'sms' or 'email'");
    }

    std::string club = readStr(body, "club");
    if (!club.empty() && club != "mens" && club != "boys") {
        club.clear();
    }
    const std::string tier = readStr(body, "tier");

    double amount = std::numeric_limits<double>::quiet_NaN();
    readDouble(body, "amount", amount);

    long long daysOverdue = -1;
    readInt(body, "daysOverdue", daysOverdue);
    int daysInt = (daysOverdue >= 0 && daysOverdue < 100000) ? static_cast<int>(daysOverdue) : -1;

    try {
        model_->record(laUserId, method, /*senderUserId=*/0, club, tier, amount, daysInt);
    } catch (const std::exception& e) {
        std::cerr << "PayReminderLogController::handleCreate insert failed: " << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, "log insert failed");
    }

    return Response(HttpStatus::CREATED, "{\"ok\":true}");
}
