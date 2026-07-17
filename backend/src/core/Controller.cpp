#include "Controller.h"
#include "Crypto.h"
#include "../database/Database.h"
#include <cstdio>
#include <chrono>
#include <future>
#include <sstream>
#include <regex>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

Response Controller::jsonResponse(const std::string& json) {
    return Response::json(json);
}

Response Controller::jsonResponse(HttpStatus status, const std::string& json) {
    Response response(status);
    response.setJson(json);
    return response;
}

Response Controller::errorResponse(HttpStatus status, const std::string& message) {
    std::ostringstream json;
    json << "{\"success\":false,\"error\":\"" << message << "\"}";
    return jsonResponse(status, json.str());
}

Response Controller::successResponse(const std::string& message) {
    std::ostringstream json;
    json << "{\"success\":true,\"message\":\"" << message << "\"}";
    return jsonResponse(json.str());
}

bool Controller::validateJsonRequest(const Request& request, Response& error_response) {
    if (!request.isJson()) {
        error_response = errorResponse(HttpStatus::BAD_REQUEST, "Content-Type must be application/json");
        return false;
    }
    
    if (request.getBody().empty()) {
        error_response = errorResponse(HttpStatus::BAD_REQUEST, "Request body is required");
        return false;
    }
    
    return true;
}

std::string Controller::extractJsonField(const std::string& json, const std::string& field) {
    // Simple JSON field extraction using regex
    // For production use, consider a proper JSON library like nlohmann/json
    
    // Try string value first: "field": "value"
    std::string strPattern = "\"" + field + "\"\\s*:\\s*\"([^\"]+)\"";
    std::regex str_regex(strPattern);
    std::smatch match;
    
    if (std::regex_search(json, match, str_regex)) {
        std::string raw = match[1].str();
        // Unescape JSON escape sequences
        std::string result;
        result.reserve(raw.size());
        for (size_t i = 0; i < raw.size(); i++) {
            if (raw[i] == '\\' && i + 1 < raw.size()) {
                switch (raw[i + 1]) {
                    case 'n':  result += '\n'; i++; break;
                    case 'r':  result += '\r'; i++; break;
                    case 't':  result += '\t'; i++; break;
                    case '\\': result += '\\'; i++; break;
                    case '"':  result += '"';  i++; break;
                    case '/':  result += '/';  i++; break;
                    default:   result += raw[i]; break;
                }
            } else {
                result += raw[i];
            }
        }
        return result;
    }
    
    // Try numeric/bool/null value: "field": 123 or "field": true
    std::string numPattern = "\"" + field + "\"\\s*:\\s*([^,}\\s]+)";
    std::regex num_regex(numPattern);
    
    if (std::regex_search(json, match, num_regex)) {
        std::string val = match[1].str();
        if (val != "null") return val;
    }
    
    return "";
}

std::string Controller::getPathParam(const Request& request, const std::string& param_name) {
    // This is a placeholder for path parameter extraction
    // Would need to be implemented with proper route matching
    // For now, return empty string
    return "";
}

// ────────────────────────────────────────────────────────────────────────────
// Shared helpers (previously duplicated in 8+ controllers).
// ────────────────────────────────────────────────────────────────────────────

std::string Controller::createJSONResponse(bool success,
                                           const std::string& message,
                                           const std::string& data) {
    std::ostringstream out;
    out << "{\"success\":" << (success ? "true" : "false")
        << ",\"message\":\"" << escapeJson(message) << "\"";
    if (!data.empty()) {
        out << ",\"data\":" << data;
    }
    out << "}";
    return out.str();
}

std::string Controller::escapeJson(const std::string& input) {
    std::string out;
    out.reserve(input.size() + 8);
    for (char c : input) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\b': out += "\\b";  break;
            case '\f': out += "\\f";  break;
            case '\n': out += "\\n";  break;
            case '\r': out += "\\r";  break;
            case '\t': out += "\\t";  break;
            default:
                // Cast to unsigned char so UTF-8 multi-byte sequences (high bytes
                // 0x80-0xFF) are passed through unchanged.  Using signed `char`
                // would treat them as negative and incorrectly escape them as
                // control characters, mangling emoji and non-ASCII text.
                if (static_cast<unsigned char>(c) < 0x20) {
                    char buf[8];
                    std::snprintf(buf, sizeof(buf), "\\u%04x",
                                  static_cast<unsigned int>(static_cast<unsigned char>(c)));
                    out += buf;
                } else {
                    out += c;
                }
        }
    }
    return out;
}

bool Controller::requireBearer(const Request& request) {
    std::string h = request.getHeader("Authorization");
    if (h.empty()) h = request.getHeader("authorization");
    if (h.size() <= 7 || h.compare(0, 7, "Bearer ") != 0) return false;

    // Verify signature + exp against the process JWT secret.  This is the
    // ONLY authentication gate on the server — no route may skip it.  If
    // this returns false the token is malformed, forged, has the wrong
    // alg, or has expired; the handler will emit a 401 without leaking
    // which of those failed.
    const std::string token = h.substr(7);
    std::string payload;
    if (!fh::crypto::verifyJwtHS256(token, &payload)) return false;

    // ── Activity heartbeat ────────────────────────────────────────
    // On every successfully-authenticated request bump users.last_seen_at
    // so club admins can spot dormant accounts on the Members screen.
    // Rules:
    //   • Skip when `?asPersonId=` is set — that's an admin view-as
    //     session; falsifying either the admin's OR the target's
    //     activity would corrupt the dormancy ledger.  (See
    //     MyController::applyImpersonation.)
    //   • Throttle to once per minute per user via the WHERE clause so
    //     a page burst doesn't hammer the DB.
    //   • Fire-and-forget: never let a bump failure break auth.  If the
    //     column is missing (pre-migration) or the query throws we
    //     swallow it and continue — the request has already been
    //     authenticated by the JWT check above.
    if (request.getQueryParam("asPersonId").empty()) {
        // Pull "userId":"NNN" from the JWT payload.  Payload is minted by
        // AuthController::generateJWT / OAuthController::generateJWT in a
        // byte-compatible shape — quoted string, not a bare integer.
        static const std::regex uidRe("\"userId\"\\s*:\\s*\"([0-9]+)\"");
        std::smatch m;
        if (std::regex_search(payload, m, uidRe) && m.size() > 1) {
            try {
                auto* db = Database::getInstance();
                std::vector<std::string> params;
                params.push_back(m[1].str());
                db->query(
                    "UPDATE users SET last_seen_at = NOW() "
                    " WHERE id = $1::int "
                    "   AND (last_seen_at IS NULL "
                    "        OR last_seen_at < NOW() - INTERVAL '1 minute')",
                    params);
            } catch (const std::exception& e) {
                // Log once and move on — auth already succeeded.
                std::cerr << "[requireBearer] last_seen_at bump failed: "
                          << e.what() << std::endl;
            }
        }
    }

    return true;
}
// ────────────────────────────────────────────────────────────────────────────
// LA-sync route primitives.  See doc block in Controller.h.
//
// Pattern:  every la<Verb>(router, path, programs, handler) call registers
// a route whose dispatch is:
//   1. Run LaProgramSync::run() for each programId in `programs` — in
//      PARALLEL when there is more than one (std::async).  This satisfies
//      the STRICT rule: LA is queried on every request that renders
//      LA-derived state, DB gets upserted, then the handler reads the DB.
//   2. Aggregate results into an LaSyncMap keyed by programId.  Programs
//      whose sync threw are absent from the map (already logged); the
//      handler decides whether to serve stale DB state or 5xx.
//   3. Invoke handler(req, syncMap).
//
// Handlers must never fetch LA directly — the whole point is that this
// wrapper is the only path.  scripts/enforce-la-sync.sh flags handlers
// that read person_la_memberships without going through a la* wrapper.
// ────────────────────────────────────────────────────────────────────────────

Controller::LaSyncMap Controller::syncPrograms(const std::vector<int>& programs) {
    LaSyncMap out;
    if (programs.empty()) return out;

    // Single-program fast path skips thread setup / joining overhead —
    // by far the common case (rosters + payments per-tab endpoints).
    if (programs.size() == 1) {
        try {
            LaProgramSync sync;
            out.emplace(programs[0], sync.run(programs[0]));
        } catch (const std::exception& e) {
            std::cerr << "[laSync program=" << programs[0]
                      << "] failed: " << e.what() << std::endl;
        }
        return out;
    }

    // Multi-program fan-out.  A 4-program screen now takes MAX(single) not
    // SUM(all four) — payments-tabs are the biggest beneficiary.  We
    // std::launch::async so the runtime creates real threads (deferred
    // launch here would serialise the .get()s).
    std::vector<std::future<std::pair<int, LaProgramSync::Result>>> futures;
    futures.reserve(programs.size());
    for (int pid : programs) {
        futures.push_back(std::async(std::launch::async, [pid]() {
            LaProgramSync sync;
            return std::make_pair(pid, sync.run(pid));
        }));
    }
    for (auto& f : futures) {
        try {
            auto p = f.get();
            out.emplace(p.first, std::move(p.second));
        } catch (const std::exception& e) {
            std::cerr << "[laSync] parallel branch failed: "
                      << e.what() << std::endl;
        }
    }
    return out;
}

// Enumerate every LA program in the registry.  Used by dynamic-programs
// laGet() sites (profile page, admin backfill, cross-category rosters)
// that need to guarantee membership state is fresh across every category
// before rendering.  Order: active variant first (most common lookups),
// then everything else by program_id — deterministic so debug logs and
// timing traces line up run-to-run.
std::vector<int> Controller::allLaProgramIds() {
    std::vector<int> out;
    try {
        auto rows = Database::getInstance()->query(
            "SELECT program_id FROM leagueapps_programs "
            " WHERE program_id IS NOT NULL "
            " ORDER BY (variant = 'active') DESC, program_id");
        out.reserve(rows.size());
        for (const auto& r : rows) {
            if (!r["program_id"].is_null()) {
                out.push_back(r["program_id"].as<int>());
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "[Controller::allLaProgramIds] enumerate failed: "
                  << e.what() << std::endl;
    }
    return out;
}

// Wrap a router.<verb>() registration with an automatic LA sync before
// dispatch.  `programs` is captured by value so the handler always sees
// the exact list its author declared, even if the caller's local mutates.

void Controller::laGet(Router& router, const std::string& path,
                       std::vector<int> programs, LaHandler handler) {
    router.get(path, [programs = std::move(programs),
                      handler  = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programs);
        return handler(req, sync);
    });
}
void Controller::laPost(Router& router, const std::string& path,
                        std::vector<int> programs, LaHandler handler) {
    router.post(path, [programs = std::move(programs),
                       handler  = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programs);
        return handler(req, sync);
    });
}
void Controller::laPut(Router& router, const std::string& path,
                       std::vector<int> programs, LaHandler handler) {
    router.put(path, [programs = std::move(programs),
                      handler  = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programs);
        return handler(req, sync);
    });
}
void Controller::laDel(Router& router, const std::string& path,
                       std::vector<int> programs, LaHandler handler) {
    router.del(path, [programs = std::move(programs),
                      handler  = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programs);
        return handler(req, sync);
    });
}

// ── Dynamic-programs overloads (programs decided at request time) ──────────

void Controller::laGet(Router& router, const std::string& path,
                       LaProgramsForRequest programsForRequest, LaHandler handler) {
    router.get(path, [programsForRequest = std::move(programsForRequest),
                      handler            = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programsForRequest(req));
        return handler(req, sync);
    });
}
void Controller::laPost(Router& router, const std::string& path,
                        LaProgramsForRequest programsForRequest, LaHandler handler) {
    router.post(path, [programsForRequest = std::move(programsForRequest),
                       handler            = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programsForRequest(req));
        return handler(req, sync);
    });
}
void Controller::laPut(Router& router, const std::string& path,
                       LaProgramsForRequest programsForRequest, LaHandler handler) {
    router.put(path, [programsForRequest = std::move(programsForRequest),
                      handler            = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programsForRequest(req));
        return handler(req, sync);
    });
}
void Controller::laDel(Router& router, const std::string& path,
                       LaProgramsForRequest programsForRequest, LaHandler handler) {
    router.del(path, [programsForRequest = std::move(programsForRequest),
                      handler            = std::move(handler)](const Request& req) {
        auto sync = Controller::syncPrograms(programsForRequest(req));
        return handler(req, sync);
    });
}
