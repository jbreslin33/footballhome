#include "PersonBillingController.h"

#include <cmath>
#include <iostream>
#include <limits>
#include <regex>
#include <sstream>

#include "../models/PersonBilling.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// Tolerant int extractor: accepts JSON number or numeric string, mirroring
// Node's parseInt(body?.field, 10) which trims, parses leading digits, and
// returns NaN otherwise (falsy → fails the !userId check).
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

// Node's `Number(amtRaw)` semantics for the amount field:
//   number  → itself
//   string  → parsed (empty/whitespace → 0; non-numeric → NaN)
//   true    → 1, false → 0, null → 0, undefined → NaN, object/array → NaN
// We only need a "got a finite number?" signal — if not, the caller
// returns the same 400 Node would.
bool readNumber(const json& j, const char* key, double& out) {
    auto it = j.find(key);
    if (it == j.end()) { out = std::numeric_limits<double>::quiet_NaN(); return false; }
    if (it->is_null())            { out = 0.0;                                   return true; }
    if (it->is_boolean())         { out = it->get<bool>() ? 1.0 : 0.0;           return true; }
    if (it->is_number())          { out = it->get<double>();                     return std::isfinite(out); }
    if (it->is_string()) {
        std::string s = it->get<std::string>();
        size_t a = 0;
        size_t b = s.size();
        while (a < b && std::isspace(static_cast<unsigned char>(s[a]))) ++a;
        while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
        const std::string t = s.substr(a, b - a);
        if (t.empty()) { out = 0.0; return true; }
        try {
            size_t pos = 0;
            out = std::stod(t, &pos);
            if (pos != t.size()) { out = std::numeric_limits<double>::quiet_NaN(); return false; }
            return std::isfinite(out);
        } catch (const std::exception&) {
            out = std::numeric_limits<double>::quiet_NaN();
            return false;
        }
    }
    out = std::numeric_limits<double>::quiet_NaN();
    return false;
}

std::string jsonEscape(const std::string& s) { return json(s).dump(); }

Response badRequest(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::BAD_REQUEST, body.str());
}

Response internalErr(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::INTERNAL_SERVER_ERROR, body.str());
}

// JS JSON.stringify writes integer-valued numbers without a decimal
// (35.00 → "35").  nlohmann::json with `double` writes "35.0".  Produce
// the exact bytes JS would emit so {leagueAppsUserId,nextBillDate,
// nextBillAmount} byte-matches the Node handler.
std::string jsNumberStr(double v) {
    if (!std::isfinite(v)) return "null";
    const double r = std::round(v);
    if (v == r &&
        v >= static_cast<double>(std::numeric_limits<long long>::min()) &&
        v <= static_cast<double>(std::numeric_limits<long long>::max())) {
        std::ostringstream o; o << static_cast<long long>(r); return o.str();
    }
    // Strip trailing zeros after the decimal so 0.5 → "0.5" not "0.500000".
    std::ostringstream o; o.precision(15); o << v;
    return o.str();
}

// Assemble the response body in insertion order
// {leagueAppsUserId, nextBillDate, nextBillAmount} — nlohmann::json uses
// std::map and would sort the keys alphabetically, which would change
// the byte output to {leagueAppsUserId, nextBillAmount, nextBillDate}.
std::string buildResponse(long long userId,
                           const std::string& nextBillDate,
                           double             nextBillAmount) {
    std::ostringstream o;
    o << "{\"leagueAppsUserId\":" << userId
      << ",\"nextBillDate\":" << jsonEscape(nextBillDate)
      << ",\"nextBillAmount\":" << jsNumberStr(nextBillAmount)
      << "}";
    return o.str();
}

} // namespace

PersonBillingController::PersonBillingController()
    : model_(std::make_unique<PersonBilling>()) {}

PersonBillingController::~PersonBillingController() = default;

void PersonBillingController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix,                 [this](const Request& req) { return this->handleUpsert(req);     });
    router.post(prefix + "/mark-billed", [this](const Request& req) { return this->handleMarkBilled(req); });
}

Response PersonBillingController::handleUpsert(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        // Node treats no-body / unparseable as missing fields → 400 on
        // the leagueAppsUserId check.  Mirror that error message.
        return badRequest("leagueAppsUserId required");
    }

    long long userId = 0;
    if (!readInt(body, "leagueAppsUserId", userId) || userId <= 0) {
        return badRequest("leagueAppsUserId required");
    }

    const std::string date = readStrTrimmed(body, "nextBillDate");
    static const std::regex iso8601(R"(^\d{4}-\d{2}-\d{2}$)");
    if (!std::regex_match(date, iso8601)) {
        return badRequest("nextBillDate must be YYYY-MM-DD");
    }

    double amount = 0.0;
    if (!readNumber(body, "nextBillAmount", amount) ||
        !std::isfinite(amount) || amount < 0.0 || amount > 999999.0) {
        return badRequest("nextBillAmount must be a non-negative number");
    }

    try {
        auto row = model_->upsert(userId, date, amount);
        return Response(HttpStatus::OK,
                        buildResponse(userId, row.nextBillDate, row.nextBillAmount));
    } catch (const std::exception& e) {
        std::cerr << "PersonBillingController::handleUpsert error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update billing: ") + e.what());
    }
}

Response PersonBillingController::handleMarkBilled(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("leagueAppsUserId required");
    }

    long long userId = 0;
    if (!readInt(body, "leagueAppsUserId", userId) || userId <= 0) {
        return badRequest("leagueAppsUserId required");
    }

    try {
        auto row = model_->markBilled(userId);
        return Response(HttpStatus::OK,
                        buildResponse(userId, row.nextBillDate, row.nextBillAmount));
    } catch (const std::exception& e) {
        std::cerr << "PersonBillingController::handleMarkBilled error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to mark billed: ") + e.what());
    }
}

bool PersonBillingController::requireBearer(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    return h.size() > 7 && h.compare(0, 7, "Bearer ") == 0;
}
