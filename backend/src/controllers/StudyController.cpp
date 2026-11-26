#include "StudyController.h"

#include <functional>
#include <iostream>

#include "../models/Study.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
long long num(const json& b, const char* k) { return b.contains(k) && b[k].is_number_integer() ? b[k].get<long long>() : 0; }
}  // namespace

StudyController::StudyController() {}

void StudyController::registerRoutes(Router& router, const std::string& prefix) {
    // The signed-in person, if they have a plan; else 0 and *denied set.
    auto me = [this](const Request& r, Response* denied) -> long long {
        if (!requireBearer(r)) { *denied = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized"); return 0; }
        const long long pid = Study::personForUser(bearerUserId(r));
        if (pid > 0 && Study::hasPlan(pid)) return pid;
        *denied = jsonError(HttpStatus::FORBIDDEN, "You don't have a study plan.");
        return 0;
    };

    router.get(prefix, [me](const Request& r) {
        Response denied; const long long pid = me(r, &denied); if (!pid) return denied;
        try { return jsonOut(HttpStatus::OK, Study::board(pid)); }
        catch (const std::exception& e) {
            std::cerr << "[StudyController::board] " << e.what() << std::endl;
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load your study plan");
        }
    });

    // Every write answers the board again, plus whatever the write adds.
    auto write = [&router, prefix, me](const std::string& path, std::function<std::string(long long, const json&, json*)> fn) {
        router.post(prefix + path, [me, fn](const Request& r) {
            Response denied; const long long pid = me(r, &denied); if (!pid) return denied;
            json b;
            try { b = r.getBody().empty() ? json::object() : json::parse(r.getBody()); }
            catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "Invalid JSON"); }
            try {
                json extra = json::object();
                const std::string err = fn(pid, b, &extra);
                if (!err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
                json out = Study::board(pid);
                for (auto it = extra.begin(); it != extra.end(); ++it) out[it.key()] = it.value();
                return jsonOut(HttpStatus::OK, out);
            } catch (const std::exception& e) {
                std::cerr << "[StudyController] " << e.what() << std::endl;
                return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save");
            }
        });
    };
    write("/answer", [](long long pid, const json& b, json* extra) {
        std::string err;
        json res = Study::answer(pid, num(b, "question_id"), b.value("given", json()), &err);
        if (!err.empty()) return err;
        for (auto it = res.begin(); it != res.end(); ++it) (*extra)[it.key()] = it.value();
        return std::string();
    });
    write("/mark", [](long long pid, const json& b, json*) {
        return Study::mark(pid, num(b, "topic_id"), b.value("status", std::string()));
    });
    write("/date", [](long long pid, const json& b, json*) {
        return Study::setTestDate(pid, num(b, "plan_id"), b.value("date", std::string()));
    });
}
