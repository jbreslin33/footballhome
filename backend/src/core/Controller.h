#pragma once
#include "Router.h"
#include "Request.h"
#include "Response.h"
#include <memory>

// Forward declaration to avoid circular dependency
class Router;

class Controller {
public:
    Controller() = default;
    virtual ~Controller() = default;
    
    // Pure virtual method that subclasses must implement
    virtual void registerRoutes(Router& router, const std::string& prefix) = 0;
    
protected:
    // Utility methods for controllers
    Response jsonResponse(const std::string& json);
    Response jsonResponse(HttpStatus status, const std::string& json);
    Response errorResponse(HttpStatus status, const std::string& message);
    Response successResponse(const std::string& message = "Success");
    
    // Request parsing helpers
    bool validateJsonRequest(const Request& request, Response& error_response);
    std::string extractJsonField(const std::string& json, const std::string& field);
    
    // Path parameter extraction (for future enhancement)
    std::string getPathParam(const Request& request, const std::string& param_name);

    // ──────────────────────────────────────────────────────────────────────
    // Shared helpers consolidated from per-controller duplicates.
    // Subclasses get these for free via inheritance; their old per-class
    // copies have been deleted.
    // ──────────────────────────────────────────────────────────────────────

    // Build the canonical `{success,message[,data]}` JSON envelope used by
    // most REST handlers.  `data` is inlined verbatim (assumed to be valid
    // JSON already) so callers can splice in pre-built objects/arrays.
    static std::string createJSONResponse(bool success,
                                          const std::string& message,
                                          const std::string& data = "");

    // Escape a string for embedding in a JSON value.  Escapes control
    // characters and the JSON metacharacters; high bytes (UTF-8 cont.
    // bytes) are passed through unchanged.
    static std::string escapeJson(const std::string& input);

    // Historical name aliases so legacy call sites compile unchanged.
    static std::string escapeJSON(const std::string& input)       { return escapeJson(input); }
    static std::string escapeJsonString(const std::string& input) { return escapeJson(input); }

    // Bearer-token presence gate.  Returns true iff the Authorization
    // header (case-insensitive) starts with "Bearer ".  Does NOT validate
    // the token — handlers that need claims still parse it themselves.
    static bool requireBearer(const Request& request);
};