#include "PersonOverrideController.h"
#include <cctype>
#include <iostream>
#include <regex>
#include <sstream>
#include <stdexcept>

PersonOverrideController::PersonOverrideController()
    : model_(std::make_unique<PersonOverride>()) {}

void PersonOverrideController::registerRoutes(Router& router, const std::string& prefix) {
    // GET /api/persons/:personId/overrides
    router.get(prefix + "/:personId/overrides", [this](const Request& request) {
        return this->handleList(request);
    });

    // POST /api/persons/:personId/overrides
    router.post(prefix + "/:personId/overrides", [this](const Request& request) {
        return this->handleUpsert(request);
    });

    // DELETE /api/persons/:personId/overrides/:field
    router.del(prefix + "/:personId/overrides/:field", [this](const Request& request) {
        return this->handleClear(request);
    });
}

// ────────────────────────────────────────────────────────────────────────────
// GET — list every override for a person.
// ────────────────────────────────────────────────────────────────────────────
Response PersonOverrideController::handleList(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    if (!extractPersonId(request.getPath(), personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid personId");
    }

    try {
        auto rows = model_->listFor(personId);

        std::ostringstream json;
        json << "{\"personId\":" << personId << ",\"overrides\":[";
        for (size_t i = 0; i < rows.size(); ++i) {
            if (i) json << ',';
            json << renderOverride(rows[i]);
        }
        json << "]}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "PersonOverrideController::handleList error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST — upsert.  Body forwarded as JSONB; model handles field extraction.
// ────────────────────────────────────────────────────────────────────────────
Response PersonOverrideController::handleUpsert(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    if (!extractPersonId(request.getPath(), personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid personId");
    }

    try {
        auto row = model_->upsert(personId, request.getBody(),
                                  extractSetByUserId(request));

        std::ostringstream json;
        json << "{\"personId\":" << personId
             << ",\"override\":" << renderOverride(row) << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::invalid_argument& e) {
        // Missing `field` etc. — client error.
        return errorResponse(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonOverrideController::handleUpsert error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// DELETE — clear one override.  Returns { personId, field, cleared } where
// `cleared` is the boolean from the model (false if no row existed).
// ────────────────────────────────────────────────────────────────────────────
Response PersonOverrideController::handleClear(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    std::string field;
    if (!extractPersonAndField(request.getPath(), personId, field)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
                             "Invalid personId or missing field name");
    }

    try {
        bool cleared = model_->clear(personId, field);

        std::ostringstream json;
        json << "{\"personId\":" << personId
             << ",\"field\":\""  << jsonEscape(field) << "\""
             << ",\"cleared\":"  << (cleared ? "true" : "false") << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "PersonOverrideController::handleClear error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Path parsers.
// ────────────────────────────────────────────────────────────────────────────
bool PersonOverrideController::extractPersonId(const std::string& path,
                                               int& personId) const {
    static const std::regex re(R"(/api/persons/(\d+)/overrides)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try {
        personId = std::stoi(m[1].str());
    } catch (const std::exception&) {
        return false;
    }
    return true;
}

bool PersonOverrideController::extractPersonAndField(const std::string& path,
                                                     int& personId,
                                                     std::string& field) const {
    // Capture everything after /overrides/ as the field name (anchored to
    // end-of-string).  This intentionally keeps any path-legal characters
    // such as ':' so event-scoped overrides like "rsvp:12345" survive.
    static const std::regex re(R"(/api/persons/(\d+)/overrides/([^/?#]+))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try {
        personId = std::stoi(m[1].str());
    } catch (const std::exception&) {
        return false;
    }
    field = percentDecode(m[2].str());
    return !field.empty();
}

// ────────────────────────────────────────────────────────────────────────────
// Auth + identity helpers.
// ────────────────────────────────────────────────────────────────────────────
bool PersonOverrideController::requireBearer(const Request& request) const {
    std::string h = request.getHeader("Authorization");
    if (h.empty()) h = request.getHeader("authorization");
    return h.size() > 7 && h.substr(0, 7) == "Bearer ";
}

std::optional<int>
PersonOverrideController::extractSetByUserId(const Request& request) const {
    std::string h = request.getHeader("X-User-Id");
    if (h.empty()) h = request.getHeader("x-user-id");
    if (h.empty()) return std::nullopt;
    try {
        return std::stoi(h);
    } catch (const std::exception&) {
        return std::nullopt;
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Encoding helpers.
// ────────────────────────────────────────────────────────────────────────────
std::string PersonOverrideController::percentDecode(const std::string& in) {
    std::string out;
    out.reserve(in.size());
    for (size_t i = 0; i < in.size(); ++i) {
        const char c = in[i];
        if (c == '%' && i + 2 < in.size()
                     && std::isxdigit(static_cast<unsigned char>(in[i + 1]))
                     && std::isxdigit(static_cast<unsigned char>(in[i + 2]))) {
            auto fromHex = [](char h) -> int {
                if (h >= '0' && h <= '9') return h - '0';
                if (h >= 'a' && h <= 'f') return 10 + (h - 'a');
                if (h >= 'A' && h <= 'F') return 10 + (h - 'A');
                return 0;
            };
            out.push_back(static_cast<char>(
                (fromHex(in[i + 1]) << 4) | fromHex(in[i + 2])));
            i += 2;
        } else if (c == '+') {
            // Path segments do NOT treat '+' as space (that's query-string
            // rules), but real-world callers sometimes encode that way; we
            // mirror the relaxed Express/Node behaviour and pass it through.
            out.push_back('+');
        } else {
            out.push_back(c);
        }
    }
    return out;
}

std::string PersonOverrideController::jsonEscape(const std::string& in) {
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

std::string PersonOverrideController::jsonOrNull(const std::optional<std::string>& v) {
    if (!v.has_value()) return "null";
    return "\"" + jsonEscape(*v) + "\"";
}

std::string PersonOverrideController::jsonOrNull(const std::optional<int>& v) {
    if (!v.has_value()) return "null";
    return std::to_string(*v);
}

// ────────────────────────────────────────────────────────────────────────────
// Render a single Row to the JSON shape the frontend expects.  Mirrors the
// Node response 1:1 so the screens don't need to change.
// ────────────────────────────────────────────────────────────────────────────
std::string PersonOverrideController::renderOverride(const PersonOverride::Row& row) {
    std::ostringstream o;
    o << "{"
      << "\"fieldName\":\""  << jsonEscape(row.field) << "\","
      << "\"value\":"        << jsonOrNull(row.value)         << ","
      << "\"sourceWas\":"    << jsonOrNull(row.sourceWas)     << ","
      << "\"originalValue\":"<< jsonOrNull(row.originalValue) << ","
      << "\"note\":"         << jsonOrNull(row.note)          << ","
      << "\"setByUserId\":"  << jsonOrNull(row.setByUserId)   << ","
      << "\"setAt\":"
      << (row.setAt.empty() ? std::string("null")
                            : "\"" + jsonEscape(row.setAt) + "\"")
      << "}";
    return o.str();
}
