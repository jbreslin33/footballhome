#pragma once
#include "../core/Controller.h"
#include "../models/PersonOverride.h"
#include <memory>
#include <optional>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// PersonOverrideController — REST surface for person_field_overrides.
//
// Routes (registered under prefix "/api/persons"):
//   GET    /api/persons/:personId/overrides
//   POST   /api/persons/:personId/overrides
//   DELETE /api/persons/:personId/overrides/:field
//
// All routes require a Bearer Authorization header (presence check only;
// JWT verification is the responsibility of a future shared service — see
// the same TODO in TeamCoachController).
// ────────────────────────────────────────────────────────────────────────────
class PersonOverrideController : public Controller {
public:
    PersonOverrideController();
    ~PersonOverrideController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonOverride> model_;

    Response handleList   (const Request& request);
    Response handleUpsert (const Request& request);
    Response handleClear  (const Request& request);

    // Path parsers.  Return false if the path doesn't match the expected
    // shape (which should only happen if the router and these regexes drift).
    bool extractPersonId   (const std::string& path, int& personId) const;
    bool extractPersonAndField(const std::string& path, int& personId,
                               std::string& field) const;

    // Bearer presence check (no signature verification — see header).
    bool requireBearer(const Request& request) const;

    // Best-effort decoder for the optional setByUserId, taken from a
    // request header (`X-User-Id`) when present.  Returns nullopt if the
    // header is missing or not a valid integer.  The Node version reads
    // `req.userId` which is populated by its `requireAuth` middleware
    // from the JWT; until that lands in C++ we accept the upstream
    // proxy-set header as the same source of truth.
    std::optional<int> extractSetByUserId(const Request& request) const;

    // Percent-decode a URL path segment.  Needed because field names can
    // be event-scoped (e.g. "rsvp:12345" → "rsvp%3A12345" if the client
    // encodes the colon).
    static std::string percentDecode(const std::string& in);

    // Render std::optional<string> or std::optional<int> into a JSON
    // value fragment, including the JSON `null` literal when absent.
    static std::string jsonOrNull(const std::optional<std::string>& v);
    static std::string jsonOrNull(const std::optional<int>& v);
    // Escape a raw string for embedding inside a JSON double-quoted string.
    static std::string jsonEscape(const std::string& in);

    // Build the {fieldName, value, ...} object shared by GET and POST.
    static std::string renderOverride(const PersonOverride::Row& row);
};
