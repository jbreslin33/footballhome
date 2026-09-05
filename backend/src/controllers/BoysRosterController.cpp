#include "BoysRosterController.h"

#include <cctype>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <unordered_map>

#include "../database/Database.h"
#include "../models/MensTeamAssignments.h"
#include "../models/MensTeamColumns.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// Tolerant int extractor: accepts number or numeric string from JSON body.
bool readInt(const json& j, const char* key, long long& out) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return false;
    if (it->is_number_integer())  { out = it->get<long long>(); return true; }
    if (it->is_number_unsigned()) { out = static_cast<long long>(it->get<unsigned long long>()); return true; }
    if (it->is_number_float())    { out = static_cast<long long>(it->get<double>()); return true; }
    if (it->is_string()) {
        try { out = std::stoll(it->get<std::string>()); return true; }
        catch (const std::exception&) { return false; }
    }
    return false;
}

bool readBool(const json& j, const char* key, bool fallback) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return fallback;
    if (it->is_boolean()) return it->get<bool>();
    if (it->is_number())  return it->get<double>() != 0.0;
    if (it->is_string()) {
        const std::string s = it->get<std::string>();
        return s == "true" || s == "1";
    }
    return fallback;
}

std::string readStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

std::string jsonEscape(const std::string& s) {
    return json(s).dump();
}

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

BoysRosterController::BoysRosterController()
    : model_      (std::make_unique<BoysRoster>()),
      columns_    (std::make_unique<MensTeamColumns>("boys")),
      assignments_(std::make_unique<MensTeamAssignments>("boys")) {}

BoysRosterController::~BoysRosterController() = default;

void BoysRosterController::registerRoutes(Router& router, const std::string& prefix) {
    // STRICT rule (§ Membership Data Flow): every LA-derived response
    // MUST run LaProgramSync on every feeding program BEFORE the
    // handler.  laGet(static) syncs boys + girls programs in parallel,
    // hands the resulting recs to the handler, which forwards them to
    // the model.  Model no longer touches LA directly.
    // Pickup programs ride along (2026-08-25): a card can now carry an
    // "also a pickup member" flag, and the STRICT rule applies to it too —
    // the flag must be as fresh as the membership beside it. The dynamic
    // overload reads the pickup ids from the registry per request rather
    // than pinning them at startup. All programs sync in parallel, so this
    // costs no extra wall-clock.
    laGet(router, prefix,
          [this](const Request&) {
              std::vector<int> programs{model_->boysProgramId(), model_->girlsProgramId()};
              const auto pickup = Controller::laPickupProgramIds();
              programs.insert(programs.end(), pickup.begin(), pickup.end());
              return programs;
          },
          [this](const Request& req, const LaSyncMap& sync) {
              return this->handleGet(req, sync);
          });
    router.post(prefix + "/assign", [this](const Request& req) {
        return this->handleAssign(req);
    });
    router.post(prefix + "/roster-status", [this](const Request& req) {
        return this->handleRosterStatus(req);
    });
    router.post(prefix + "/reorder", [this](const Request& req) {
        return this->handleReorder(req);
    });
    router.get(prefix + "/columns", [this](const Request& req) {
        return this->handleColumns(req);
    });
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/boys-roster/columns
// ────────────────────────────────────────────────────────────────────────────
Response BoysRosterController::handleColumns(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    try {
        json out = json::array();
        for (const auto& col : columns_->loadAll()) {
            json c = json::object();
            c["teamId"]     = col.teamId;
            c["label"]      = col.label;
            c["shortLabel"] = col.shortLabel;
            c["color"]      = col.color;
            c["mutexGroup"] = col.mutexGroup;
            c["fieldSize"]  = col.hasFieldSize ? json(col.fieldSize) : json(nullptr);
            out.push_back(std::move(c));
        }
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        std::cerr << "BoysRosterController::handleColumns error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to load columns: ") + e.what());
    }
}

Response BoysRosterController::handleGet(const Request& request, const LaSyncMap& sync) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    const bool includeAll = (request.getQueryParam("includeAll") == "1");
    const bool refreshLa  = (request.getQueryParam("refreshLa")  == "1");
    const bool includeInactive = (request.getQueryParam("includeInactive") == "1");
    try {
        // Per-load enforcement (migration 108): LA membership is source
        // of truth.  Sweep out non-compliant roster rows before serving.
        try {
            auto* db = Database::getInstance();
            db->query("SELECT fn_sweep_invalid_rosters()");
        } catch (const std::exception& e) {
            std::cerr << "[boys-roster] roster sweep failed: " << e.what() << std::endl;
        }

        // Recs already fetched + persons/aliases/memberships upserted
        // by the framework's laGet wrapper.  Model just reads.
        static const std::vector<nlohmann::json> kEmpty;
        const auto boysIt  = sync.find(model_->boysProgramId());
        const auto girlsIt = sync.find(model_->girlsProgramId());
        const auto& boysRecs  = (boysIt  != sync.end()) ? boysIt->second.recs  : kEmpty;
        const auto& girlsRecs = (girlsIt != sync.end()) ? girlsIt->second.recs : kEmpty;

        std::unordered_map<std::string, long long> personIdByUserId;
        if (boysIt  != sync.end()) personIdByUserId.insert(boysIt->second.personIdByUserId.begin(),  boysIt->second.personIdByUserId.end());
        if (girlsIt != sync.end()) personIdByUserId.insert(girlsIt->second.personIdByUserId.begin(), girlsIt->second.personIdByUserId.end());

        auto result = model_->run(includeAll, refreshLa, boysRecs, girlsRecs, personIdByUserId, includeInactive);
        if (result.noColumns) {
            std::ostringstream body;
            body << "{\"error\":" << jsonEscape(result.error) << "}";
            return Response(HttpStatus::CONFLICT, body.str());
        }
        return Response(HttpStatus::OK, result.body.dump());
    } catch (const std::exception& e) {
        std::cerr << "BoysRosterController::handleGet error: " << e.what() << std::endl;
        std::ostringstream body;
        body << "{\"error\":" << jsonEscape(std::string("Failed to fetch boys roster: ") + e.what()) << "}";
        return Response(HttpStatus::BAD_GATEWAY, body.str());
    }
}

Response BoysRosterController::handleAssign(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) { return badRequest("Invalid JSON body"); }

    long long userId = 0;
    long long teamIdLL = 0;
    long long personId = 0;
    readInt(body, "personId", personId);  // optional — see doc below
    if (!readInt(body, "leagueAppsUserId", userId) ||
        !readInt(body, "teamId",            teamIdLL) ||
        userId <= 0 || teamIdLL <= 0) {
        return badRequest("leagueAppsUserId, teamId, action(add|remove) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    std::string action = readStr(body, "action");
    for (auto& c : action) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    if (action != "add" && action != "remove") {
        return badRequest("leagueAppsUserId, teamId, action(add|remove) required");
    }

    if (!canManageTeam(request, teamId)) {
        return errorResponse(HttpStatus::FORBIDDEN, "Not authorized to manage this team");
    }

    try {
        auto col = columns_->findByTeamId(teamId);
        if (!col) {
            // Boys domain has no pool teams — every valid target must be
            // a configured column.  Anything else is a stale UI.
            return notFound("Team not configured as a boys column");
        }
        const std::string mutexGroup = col->mutexGroup;

        // Prefer personId when the frontend sent one (attached to the
        // row from LaProgramSync::Result::personIdByUserId at render
        // time — see MensTeamAssignments.h). It's immune to LA's
        // live-userId drift; leagueAppsUserId-only requests fall back
        // to the old (drift-vulnerable) persons.la_user_id lookup.
        std::vector<int> teamIds;
        if (action == "remove") {
            teamIds = personId > 0
                ? assignments_->removeAssignmentForPerson(personId, teamId)
                : assignments_->removeAssignment(userId, teamId);
        } else {
            teamIds = personId > 0
                ? assignments_->addAssignmentForPerson(personId, teamId, mutexGroup)
                : assignments_->addAssignment(userId, teamId, mutexGroup);
        }

        json out;
        out["leagueAppsUserId"] = userId;
        out["teamIds"]          = teamIds;
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        std::cerr << "BoysRosterController::handleAssign error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update assignment: ") + e.what());
    }
}

Response BoysRosterController::handleRosterStatus(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) { return badRequest("Invalid JSON body"); }

    long long userId = 0;
    long long teamIdLL = 0;
    if (!readInt(body, "leagueAppsUserId", userId) ||
        !readInt(body, "teamId",            teamIdLL) ||
        userId <= 0 || teamIdLL <= 0) {
        return badRequest("leagueAppsUserId and teamId required");
    }
    const int  teamId   = static_cast<int>(teamIdLL);
    const bool onRoster = readBool(body, "onRoster", false);

    if (!canManageTeam(request, teamId)) {
        return errorResponse(HttpStatus::FORBIDDEN, "Not authorized to manage this team");
    }

    try {
        auto result = assignments_->setRosterStatus(userId, teamId, onRoster);
        if (!result) return notFound("No assignment exists for that player on that team");
        std::ostringstream out;
        out << "{\"leagueAppsUserId\":" << userId
            << ",\"teamId\":"          << teamId
            << ",\"onRoster\":"        << (*result ? "true" : "false")
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "BoysRosterController::handleRosterStatus error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update roster status: ") + e.what());
    }
}

Response BoysRosterController::handleReorder(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) { return badRequest("Invalid JSON body"); }

    long long teamIdLL = 0;
    if (!readInt(body, "teamId", teamIdLL) || teamIdLL <= 0) {
        return badRequest("teamId (positive int) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    if (!canManageTeam(request, teamId)) {
        return errorResponse(HttpStatus::FORBIDDEN, "Not authorized to manage this team");
    }

    auto it = body.find("userIds");
    if (it == body.end() || !it->is_array()) {
        return badRequest("userIds (array of ints) required");
    }
    std::vector<long long> ordered;
    ordered.reserve(it->size());
    for (const auto& e : *it) {
        long long v = 0;
        if (e.is_number_integer())          v = e.get<long long>();
        else if (e.is_number_unsigned())    v = static_cast<long long>(e.get<unsigned long long>());
        else if (e.is_number_float())       v = static_cast<long long>(e.get<double>());
        else if (e.is_string()) {
            try { v = std::stoll(e.get<std::string>()); }
            catch (const std::exception&) { return badRequest("userIds contains a non-numeric entry"); }
        } else {
            return badRequest("userIds entries must be integers");
        }
        if (v <= 0) return badRequest("userIds entries must be positive");
        ordered.push_back(v);
    }

    // Optional personIds[] parallel array — immune to LA's live-userId
    // drift (see MensTeamAssignments.h doc on the person_id-keyed write
    // path / addAssignmentForPerson). When present and the same length
    // as userIds, prefer it; a drifted la_user_id would otherwise match
    // zero rows for that one card and it'd silently snap back to its old
    // position after the reload ("I can't drag <player>").
    std::vector<long long> orderedPersonIds;
    if (auto pit = body.find("personIds"); pit != body.end() && pit->is_array()
        && pit->size() == ordered.size()) {
        orderedPersonIds.reserve(pit->size());
        for (const auto& e : *pit) {
            long long v = 0;
            if (e.is_number_integer())       v = e.get<long long>();
            else if (e.is_number_unsigned()) v = static_cast<long long>(e.get<unsigned long long>());
            if (v <= 0) { orderedPersonIds.clear(); break; }
            orderedPersonIds.push_back(v);
        }
    }

    try {
        const long long touched = orderedPersonIds.size() == ordered.size()
            ? assignments_->reorderTeamForPersons(teamId, orderedPersonIds)
            : assignments_->reorderTeam(teamId, ordered);
        std::ostringstream out;
        out << "{\"teamId\":" << teamId
            << ",\"touched\":" << touched
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "BoysRosterController::handleReorder error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to reorder team: ") + e.what());
    }
}
