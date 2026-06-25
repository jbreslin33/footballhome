#pragma once
#include "../core/Controller.h"
#include "../models/PersonMerge.h"
#include <memory>
#include <optional>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// PersonMergeController — REST surface for the person_merges audit table.
//
// Routes (registered under prefix "/api/persons"):
//   POST /api/persons/merge             body: { laPersonId, gmPersonId }
//   POST /api/persons/unmerge/:mergeId
//   GET  /api/persons/:personId/merges
//
// All routes require a Bearer Authorization header (presence check only;
// JWT verification is the same TODO as the other Phase 1/2 controllers).
// ────────────────────────────────────────────────────────────────────────────
class PersonMergeController : public Controller {
public:
    PersonMergeController();
    ~PersonMergeController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonMerge> model_;

    Response handleMerge   (const Request& request);
    Response handleUnmerge (const Request& request);
    Response handleListMerges(const Request& request);

    // Path parsers — return false if the path doesn't match.
    bool extractMergeId (const std::string& path, int& mergeId) const;
    bool extractPersonId(const std::string& path, int& personId) const;

    // Body parser for {laPersonId, gmPersonId}.  Returns false if either
    // is missing or not a valid integer.
    bool extractMergeBody(const std::string& body,
                          int& laPersonId, int& gmPersonId) const;

    // Same X-User-Id header convention as PersonOverrideController.
    std::optional<int> extractActingUserId(const Request& request) const;

    bool requireBearer(const Request& request) const;

    // JSON-rendering helpers (no JSON lib in this project — same pattern
    // as TeamCoach/PersonOverride controllers).
    static std::string jsonEscape(const std::string& in);
    static std::string jsonOrNull(const std::optional<std::string>& v);
    static std::string jsonOrNull(const std::optional<int>& v);
    static std::string renderCounts(const PersonMerge::TableCounts& counts);
    static std::string renderMergeRow(const PersonMerge::MergeRow& row);
};
