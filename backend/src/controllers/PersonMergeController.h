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
//   POST /api/persons/link-scraped      body: { keepPersonId, scrapedPersonId }
//   GET  /api/persons/:personId/scraped-match-candidates
//   GET  /api/persons/:personId/merges
//
// link-scraped is the admin-confirmed identity-resolution path: keep a
// Lighthouse person, drop a scraped-only person (no open LA membership),
// reusing PersonMerge so the link is reversible via unmerge.
// ────────────────────────────────────────────────────────────────────────────
class PersonMergeController : public Controller {
public:
    PersonMergeController();
    ~PersonMergeController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonMerge> model_;

    Response handleMerge   (const Request& request, const LaSyncMap& sync);
    Response handleUnmerge (const Request& request, const LaSyncMap& sync);
    Response handleListMerges(const Request& request, const LaSyncMap& sync);
    Response handleScrapedMatchCandidates(const Request& request, const LaSyncMap& sync);
    Response handleLinkScraped(const Request& request, const LaSyncMap& sync);

    // Path parsers — return false if the path doesn't match.
    bool extractMergeId (const std::string& path, int& mergeId) const;
    bool extractPersonId(const std::string& path, int& personId) const;
    bool extractScrapedCandidatesPersonId(const std::string& path, int& personId) const;

    // Body parser for {laPersonId, gmPersonId}.  Returns false if either
    // is missing or not a valid integer.
    bool extractMergeBody(const std::string& body,
                          int& laPersonId, int& gmPersonId) const;
    // Body parser for { keepPersonId, scrapedPersonId }.
    bool extractLinkScrapedBody(const std::string& body,
                                int& keepPersonId, int& scrapedPersonId) const;

    // Same X-User-Id header convention as PersonOverrideController.
    std::optional<int> extractActingUserId(const Request& request) const;


    // JSON-rendering helpers (no JSON lib in this project — same pattern
    // as TeamCoach/PersonOverride controllers).
    static std::string jsonEscape(const std::string& in);
    static std::string jsonOrNull(const std::optional<std::string>& v);
    static std::string jsonOrNull(const std::optional<int>& v);
    static std::string renderCounts(const PersonMerge::TableCounts& counts);
    static std::string renderMergeRow(const PersonMerge::MergeRow& row);
};
