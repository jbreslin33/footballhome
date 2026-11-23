#include "LeagueEntryController.h"

#include <functional>
#include <iostream>

#include "../models/LeagueEntry.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
long long num(const json& b, const char* k) { return b.contains(k) && b[k].is_number_integer() ? b[k].get<long long>() : 0; }
}  // namespace

LeagueEntryController::LeagueEntryController() {}

bool LeagueEntryController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "League registration is for club admins.");
    return false;
}

void LeagueEntryController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) {
        Response denied; if (!gate(r, &denied)) return denied;
        try { return jsonOut(HttpStatus::OK, LeagueEntry::board()); }
        catch (const std::exception& e) {
            std::cerr << "[LeagueEntryController::board] " << e.what() << std::endl;
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load league registration");
        }
    });
    // every write answers the board again
    auto write = [this, &router, prefix](const std::string& path, std::function<std::string(const Request&, const json&, json*)> fn) {
        router.post(prefix + path, [this, fn](const Request& r) {
            Response denied; if (!gate(r, &denied)) return denied;
            json b;
            try { b = r.getBody().empty() ? json::object() : json::parse(r.getBody()); }
            catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "Invalid JSON"); }
            try {
                json extra = json::object();
                const std::string err = fn(r, b, &extra);
                if (!err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
                json board = LeagueEntry::board();
                for (auto it = extra.begin(); it != extra.end(); ++it) board[it.key()] = it.value();
                return jsonOut(HttpStatus::OK, board);
            } catch (const std::exception& e) {
                std::cerr << "[LeagueEntryController] " << e.what() << std::endl;
                return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save");
            }
        });
    };
    write("/team", [](const Request&, const json& b, json*) { return LeagueEntry::saveTeam(num(b, "id"), b.value("fields", json::object())); });
    write("/entry", [](const Request&, const json& b, json*) { return LeagueEntry::saveEntry(num(b, "id"), b.value("fields", json::object())); });
    write("/item", [this](const Request& r, const json& b, json*) {
        return LeagueEntry::tick(num(b, "id"), b.value("done", false), bearerUserId(r));
    });
    write("/send", [this](const Request& r, const json& b, json* extra) {
        std::vector<LeagueEntry::File> files;
        if (b.contains("files") && b["files"].is_array())
            for (const auto& f : b["files"])
                if (f.is_object()) files.push_back({f.value("filename", std::string()), f.value("file", std::string())});
        int sent = 0;
        const std::string err = LeagueEntry::send(num(b, "id"), files, bearerUserId(r), &sent);
        (*extra)["sent_files"] = sent;
        return err;
    });
}
