#include "ChargeFlagsController.h"

#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>

#include <pqxx/pqxx>

#include "../models/ChargeFlags.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonErr(HttpStatus status, const std::string& msg) {
    json j = json::object();
    j["error"] = msg;
    return Response(status, j.dump());
}

json toJson(const ChargeFlags::Row& r) {
    json j = json::object();
    j["id"]           = r.id;
    j["laUserId"]     = r.laUserId;
    j["laProgramId"]  = r.laProgramId;
    j["amountCents"]  = r.amountCents;
    j["amount"]       = r.amountCents / 100.0;    // convenience for UI
    j["reason"]       = r.reason;
    j["status"]       = r.status;
    j["createdBy"]    = r.createdBy;
    j["createdAt"]    = r.createdAt;
    j["resolvedBy"]   = r.hasResolvedBy ? json(r.resolvedBy) : json(nullptr);
    j["resolvedAt"]   = r.resolvedAt.empty()  ? json(nullptr) : json(r.resolvedAt);
    j["resolvedNote"] = r.resolvedNote;
    j["firstName"]    = r.firstName;
    j["lastName"]     = r.lastName;
    return j;
}

// Extract the trailing `:id` segment from `/api/charge-flags/<id>`.
// Returns 0 on parse failure.
long long extractIdFromPath(const std::string& path) {
    const auto pos = path.find_last_of('/');
    if (pos == std::string::npos) return 0;
    const std::string tail = path.substr(pos + 1);
    if (tail.empty()) return 0;
    try { return std::stoll(tail); }
    catch (const std::exception&) { return 0; }
}

// base64url → bytes for a JWT payload segment.
std::string b64urlDecode(std::string in) {
    for (auto& c : in) {
        if      (c == '-') c = '+';
        else if (c == '_') c = '/';
    }
    while (in.size() % 4) in.push_back('=');

    static int tab[256];
    static bool initted = false;
    if (!initted) {
        for (int i = 0; i < 256; ++i) tab[i] = -1;
        const char* a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        for (int i = 0; i < 64; ++i) tab[static_cast<unsigned char>(a[i])] = i;
        initted = true;
    }
    std::string out;
    int val = 0, valb = -8;
    for (unsigned char c : in) {
        if (c == '=') break;
        int v = tab[c];
        if (v < 0) continue;
        val   = (val << 6) | v;
        valb += 6;
        if (valb >= 0) {
            out.push_back(static_cast<char>((val >> valb) & 0xFF));
            valb -= 8;
        }
    }
    return out;
}

} // namespace

ChargeFlagsController::ChargeFlagsController()
    : flags_(std::make_unique<ChargeFlags>()) {}

ChargeFlagsController::~ChargeFlagsController() = default;

int ChargeFlagsController::bearerUserId(const Request& req) {
    std::string h = req.getHeader("Authorization");
    if (h.empty()) h = req.getHeader("authorization");
    if (h.size() < 8 || h.compare(0, 7, "Bearer ") != 0) return 0;

    const std::string token = h.substr(7);
    const auto dot1 = token.find('.');
    if (dot1 == std::string::npos) return 0;
    const auto dot2 = token.find('.', dot1 + 1);
    if (dot2 == std::string::npos) return 0;

    const std::string payload = b64urlDecode(token.substr(dot1 + 1, dot2 - dot1 - 1));
    try {
        const json j = json::parse(payload);
        if (!j.contains("userId")) return 0;
        const auto& u = j["userId"];
        if (u.is_number_integer())  return static_cast<int>(u.get<long long>());
        if (u.is_number_unsigned()) return static_cast<int>(u.get<unsigned long long>());
        if (u.is_string()) {
            try { return std::stoi(u.get<std::string>()); }
            catch (const std::exception&) { return 0; }
        }
        return 0;
    } catch (...) {
        return 0;
    }
}

void ChargeFlagsController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix, [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleCreate(r);
    });

    router.get(prefix, [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleList(r);
    });

    router.get(prefix + "/:id", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetById(r);
    });

    router.put(prefix + "/:id", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handlePatch(r);
    });
}

Response ChargeFlagsController::handleCreate(const Request& req) {
    const int userId = bearerUserId(req);
    if (userId <= 0) return jsonErr(HttpStatus::UNAUTHORIZED, "Missing userId claim");

    json body;
    try {
        body = req.getBody().empty() ? json::object() : json::parse(req.getBody());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }

    ChargeFlags::CreateInput in;
    in.createdBy = userId;

    auto readLong = [&](const char* key) -> long long {
        if (!body.contains(key) || body[key].is_null()) return 0;
        const auto& v = body[key];
        if (v.is_number_integer())  return v.get<long long>();
        if (v.is_number_unsigned()) return static_cast<long long>(v.get<unsigned long long>());
        if (v.is_string()) {
            try { return std::stoll(v.get<std::string>()); }
            catch (...) { return 0; }
        }
        return 0;
    };
    auto readInt = [&](const char* key) -> int {
        long long v = readLong(key);
        return (v > 0 && v <= 2'000'000'000) ? static_cast<int>(v) : 0;
    };

    in.laUserId    = readLong("laUserId");
    in.laProgramId = readLong("laProgramId");
    // Accept either "amountCents" (canonical) or "amount" (dollars) for
    // operator convenience — round to nearest cent.
    if (body.contains("amountCents")) {
        in.amountCents = readInt("amountCents");
    } else if (body.contains("amount") && body["amount"].is_number()) {
        const double d = body["amount"].get<double>();
        in.amountCents = static_cast<int>(d * 100.0 + (d >= 0 ? 0.5 : -0.5));
    }
    if (body.contains("reason") && body["reason"].is_string()) {
        in.reason = body["reason"].get<std::string>();
    }

    if (in.laUserId    <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "laUserId required");
    if (in.laProgramId <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "laProgramId required");
    if (in.amountCents <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "amount required");

    try {
        auto row = flags_->create(in);
        return Response(HttpStatus::CREATED, toJson(row).dump());
    } catch (const pqxx::unique_violation& e) {
        // Partial-unique index on (la_user_id, la_program_id) WHERE
        // status='pending' — a pending flag already exists.
        return jsonErr(HttpStatus::CONFLICT,
                       "A pending charge flag already exists for this member");
    } catch (const std::invalid_argument& e) {
        return jsonErr(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "[ChargeFlags::create] " << e.what() << std::endl;
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("Failed to create charge flag: ") + e.what());
    }
}

Response ChargeFlagsController::handleList(const Request& req) {
    long long programId = 0;
    const std::string pq = req.getQueryParam("program");
    if (!pq.empty()) {
        try { programId = std::stoll(pq); }
        catch (...) { return jsonErr(HttpStatus::BAD_REQUEST, "invalid program"); }
    }
    const std::string status = req.getQueryParam("status");
    if (!status.empty() && status != "pending" && status != "ran" && status != "canceled") {
        return jsonErr(HttpStatus::BAD_REQUEST,
                       "status must be pending / ran / canceled");
    }

    try {
        auto rows = flags_->list(programId, status);
        // Summary counts help the UI badge the queue in the sidebar.
        int cPending = 0, cRan = 0, cCanceled = 0;
        int totalPendingCents = 0;
        json arr = json::array();
        for (const auto& r : rows) {
            if      (r.status == "pending")  { ++cPending;  totalPendingCents += r.amountCents; }
            else if (r.status == "ran")        ++cRan;
            else if (r.status == "canceled")   ++cCanceled;
            arr.push_back(toJson(r));
        }
        json out = json::object();
        out["total"]  = rows.size();
        out["counts"] = json::object({
            {"pending",  cPending},
            {"ran",      cRan},
            {"canceled", cCanceled},
        });
        out["totalPendingCents"] = totalPendingCents;
        out["totalPending"]      = totalPendingCents / 100.0;
        out["flags"] = std::move(arr);
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("Failed to list charge flags: ") + e.what());
    }
}

Response ChargeFlagsController::handleGetById(const Request& req) {
    const long long id = extractIdFromPath(req.getPath());
    if (id <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "invalid id");
    try {
        return Response(HttpStatus::OK, toJson(flags_->getById(id)).dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::NOT_FOUND, e.what());
    }
}

Response ChargeFlagsController::handlePatch(const Request& req) {
    const int userId = bearerUserId(req);
    if (userId <= 0) return jsonErr(HttpStatus::UNAUTHORIZED, "Missing userId claim");

    const long long id = extractIdFromPath(req.getPath());
    if (id <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "invalid id");

    json body;
    try {
        body = req.getBody().empty() ? json::object() : json::parse(req.getBody());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }

    std::string newStatus;
    if (body.contains("status") && body["status"].is_string()) {
        newStatus = body["status"].get<std::string>();
    }
    if (newStatus != "ran" && newStatus != "canceled") {
        return jsonErr(HttpStatus::BAD_REQUEST,
                       "status must be 'ran' or 'canceled'");
    }
    std::string note;
    if (body.contains("note") && body["note"].is_string()) {
        note = body["note"].get<std::string>();
    }

    try {
        auto row = flags_->updateStatus(id, newStatus, userId, note);
        return Response(HttpStatus::OK, toJson(row).dump());
    } catch (const std::exception& e) {
        // updateStatus() throws when the WHERE fails (not found OR already
        // resolved) — 409 is the honest answer.
        return jsonErr(HttpStatus::CONFLICT, e.what());
    }
}
