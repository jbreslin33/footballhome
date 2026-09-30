#pragma once
#include <string>
#include "../core/Controller.h"
#include "../third_party/json.hpp"

// OfficialRosterController — the league's own roster sheet for a game,
// behind the 🖨 panel on the squad pills of #game-center (migration 501).
// Owner 2026-09-30: "make a print roster from game center screen for apsl
// … it has to be the official exact roster from site … downloading it and
// storing it in db tied to that game. every new request would overwrite the
// old … printed fresh for each game … to prove the roster is current to refs".
//
//   GET  /api/official-roster/:matchId          { available, league, season, saved: { fetchedAt,
//                                                 fetchedBy, byteSize } | null }
//                                               available = one of the game's teams has an active
//                                               official_roster_sources row.
//   POST /api/official-roster/:matchId/refresh  pulls the sheet from the league site right now
//                                               (services/TeamPassRoster) and replaces the game's
//                                               row in match_official_rosters → the same body.
//   GET  /api/official-roster/:matchId/pdf      the stored bytes.
//
// All three are for the game's teams — coaches, everyone on their rosters
// (owner 2026-09-30: "i need all players to see it so we can ask one to
// print it if we forget") — and club admins.  The sheet carries every
// player's date of birth and league ID, so nobody outside those teams: a
// signed-in caller who is none of them gets 403, never 401 (the SPA logs
// out on 401).
class OfficialRosterController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    struct Access { long long userId = 0; long long personId = 0; bool allowed = false; };
    Access access(const Request& request, long long matchId);
    bool gate(const Request& request, long long matchId, Access* who, Response* error);
    nlohmann::json state(long long matchId);

    Response handleGet(const Request& request);
    Response handleRefresh(const Request& request);
    Response handlePdf(const Request& request);
};
