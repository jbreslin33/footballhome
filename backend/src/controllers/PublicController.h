#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"

// PublicController
// -----------------------------------------------------------------------------
// Unauthenticated read endpoints that power the per-team public share URLs:
//   GET /api/public/teams/:slug             -> team summary + live match pointer
//   GET /api/public/teams/:slug/gameday     -> 18/20 man roster (or "hidden" placeholder)
//   GET /api/public/teams/:slug/lineup      -> starters / bench / pitch (anonymized when hidden)
//   GET /api/public/teams/:slug/schedule    -> full team schedule, marks live match
//
// "Live match" resolution lives here in resolveLiveMatchId(): manually pinned
// match wins, else earliest non-completed/cancelled match for the team, else
// most recent completed match as fallback.

class PublicController : public Controller {
private:
    Database* db_;

public:
    PublicController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetTeam(const Request& request);
    Response handleGetGameday(const Request& request);
    Response handleGetLineup(const Request& request);
    Response handleGetSchedule(const Request& request);

    // Resolver: returns matches.id for the team's "live" match, or 0 if none exists.
    int resolveLiveMatchId(int team_id);

    // Loads a team row by slug; returns false (and sets team_id=0) if no match.
    bool loadTeamBySlug(const std::string& slug,
                       int& team_id, std::string& team_name, std::string& logo_url,
                       bool& live_pinned, int& pinned_match_id);

    // Builds the match JSON snippet (object literal, no enclosing key) used by
    // multiple endpoints. Returns empty string if the match cannot be loaded.
    std::string buildMatchJson(int match_id, int home_team_id);

    // Path/JSON helpers
    std::string extractSlugFromPath(const std::string& path);
};
