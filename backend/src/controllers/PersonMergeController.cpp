#include "PersonMergeController.h"
#include <cstdio>
#include <iostream>
#include <regex>
#include <sstream>
#include <stdexcept>

PersonMergeController::PersonMergeController()
    : model_(std::make_unique<PersonMerge>()) {}

void PersonMergeController::registerRoutes(Router& router, const std::string& prefix) {
    // POST /api/persons/merge
    router.post(prefix + "/merge", [this](const Request& request) {
        return this->handleMerge(request);
    });
    // POST /api/persons/unmerge/:mergeId
    router.post(prefix + "/unmerge/:mergeId", [this](const Request& request) {
        return this->handleUnmerge(request);
    });
    // GET  /api/persons/:personId/merges
    router.get(prefix + "/:personId/merges", [this](const Request& request) {
        return this->handleListMerges(request);
    });
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/persons/merge — { laPersonId, gmPersonId }
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleMerge(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int laPersonId = 0, gmPersonId = 0;
    if (!extractMergeBody(request.getBody(), laPersonId, gmPersonId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
            "laPersonId and gmPersonId are required integers");
    }

    try {
        auto r = model_->merge(laPersonId, gmPersonId, extractActingUserId(request));

        std::ostringstream json;
        json << "{"
             << "\"mergeId\":"          << r.mergeId
             << ",\"mergedAt\":\""      << jsonEscape(r.mergedAt) << "\""
             << ",\"kept\":"            << r.kept
             << ",\"dropped\":"         << r.dropped
             << ",\"reparented\":"      << renderCounts(r.reparented)
             << ",\"deletedConflicts\":"<< renderCounts(r.deletedConflicts)
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::invalid_argument& e) {
        return errorResponse(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleMerge error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/persons/unmerge/:mergeId
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleUnmerge(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int mergeId = 0;
    if (!extractMergeId(request.getPath(), mergeId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid mergeId");
    }

    try {
        auto r = model_->unmerge(mergeId, extractActingUserId(request));

        std::ostringstream json;
        json << "{"
             << "\"mergeId\":"     << r.mergeId
             << ",\"kept\":"       << r.kept
             << ",\"restored\":"   << r.restored
             << ",\"movedBack\":"  << renderCounts(r.movedBack)
             << ",\"reinserted\":" << renderCounts(r.reinserted)
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::invalid_argument& e) {
        return errorResponse(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleUnmerge error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/persons/:personId/merges
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleListMerges(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    if (!extractPersonId(request.getPath(), personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid personId");
    }

    try {
        auto rows = model_->listForPerson(personId);

        std::ostringstream json;
        json << "{\"personId\":" << personId << ",\"merges\":[";
        for (size_t i = 0; i < rows.size(); ++i) {
            if (i) json << ',';
            json << renderMergeRow(rows[i]);
        }
        json << "]}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleListMerges error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Path / body parsing.
// ────────────────────────────────────────────────────────────────────────────
bool PersonMergeController::extractMergeId(const std::string& path,
                                           int& mergeId) const {
    static const std::regex re(R"(/api/persons/unmerge/(\d+))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { mergeId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::extractPersonId(const std::string& path,
                                            int& personId) const {
    static const std::regex re(R"(/api/persons/(\d+)/merges)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { personId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::extractMergeBody(const std::string& body,
                                             int& laPersonId,
                                             int& gmPersonId) const {
    static const std::regex laRe(R"rx("laPersonId"\s*:\s*(\d+))rx");
    static const std::regex gmRe(R"rx("gmPersonId"\s*:\s*(\d+))rx");
    std::smatch m;
    if (!std::regex_search(body, m, laRe)) return false;
    try { laPersonId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    if (!std::regex_search(body, m, gmRe)) return false;
    try { gmPersonId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::requireBearer(const Request& request) const {
    std::string h = request.getHeader("Authorization");
    if (h.empty()) h = request.getHeader("authorization");
    return h.size() > 7 && h.substr(0, 7) == "Bearer ";
}

std::optional<int>
PersonMergeController::extractActingUserId(const Request& request) const {
    std::string h = request.getHeader("X-User-Id");
    if (h.empty()) h = request.getHeader("x-user-id");
    if (h.empty()) return std::nullopt;
    try { return std::stoi(h); }
    catch (const std::exception&) { return std::nullopt; }
}

// ────────────────────────────────────────────────────────────────────────────
// JSON helpers.
// ────────────────────────────────────────────────────────────────────────────
std::string PersonMergeController::jsonEscape(const std::string& in) {
    std::string out;
    out.reserve(in.size() + 2);
    for (char c : in) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\b': out += "\\b";  break;
            case '\f': out += "\\f";  break;
            case '\n': out += "\\n";  break;
            case '\r': out += "\\r";  break;
            case '\t': out += "\\t";  break;
            default:
                if (static_cast<unsigned char>(c) < 0x20) {
                    char buf[8];
                    std::snprintf(buf, sizeof(buf), "\\u%04x", c);
                    out += buf;
                } else {
                    out.push_back(c);
                }
        }
    }
    return out;
}

std::string PersonMergeController::jsonOrNull(const std::optional<std::string>& v) {
    if (!v.has_value()) return "null";
    return "\"" + jsonEscape(*v) + "\"";
}
std::string PersonMergeController::jsonOrNull(const std::optional<int>& v) {
    if (!v.has_value()) return "null";
    return std::to_string(*v);
}

// Render { "table_a": N, "table_b": M, ... } in iteration order.  An empty
// counts vector becomes "{}" so the JSON shape is stable (matches Node).
std::string PersonMergeController::renderCounts(const PersonMerge::TableCounts& counts) {
    std::ostringstream o;
    o << "{";
    for (size_t i = 0; i < counts.size(); ++i) {
        if (i) o << ',';
        o << "\"" << jsonEscape(counts[i].first) << "\":" << counts[i].second;
    }
    o << "}";
    return o.str();
}

std::string PersonMergeController::renderMergeRow(const PersonMerge::MergeRow& row) {
    std::ostringstream o;
    o << "{"
      << "\"id\":"                   << row.id
      << ",\"kept_person_id\":"      << row.keptPersonId
      << ",\"dropped_person_id\":"   << row.droppedPersonId
      << ",\"merged_at\":\""         << jsonEscape(row.mergedAt) << "\""
      << ",\"merged_by_user_id\":"   << jsonOrNull(row.mergedByUserId)
      << ",\"reversed_at\":"         << jsonOrNull(row.reversedAt)
      << ",\"reversed_by_user_id\":" << jsonOrNull(row.reversedByUserId)
      << ",\"dropped_first_name\":"  << jsonOrNull(row.droppedFirstName)
      << ",\"dropped_last_name\":"   << jsonOrNull(row.droppedLastName)
      << "}";
    return o.str();
}
