#pragma once
#include <string>
#include "../core/Controller.h"

// AwardsController — /api/awards, behind the #awards page (mig 800).
//
// All-Stars and end-of-season awards (Most Improved, Most Dedicated…),
// per team, per season (year_terms term + the year it started).  League
// awards (award_types.is_league — All-Star) go to the team's league
// director (team_league_directors → club_contacts); the page builds the
// email / text from message_templates kind=awards and records each send
// here so it shows "sent ✓".
//
//   GET  /api/awards/board?term=&year=   types, the season's teams, players, awards, sends
//   POST /api/awards/toggle  { person_id, team_id, award_code, term, year, on }
//   POST /api/awards/sent    { team_id, award_code, term, year, channel }
//
// Admins and active coaches only.
class AwardsController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    bool gate(const Request& request, Response* error, long long* personId);

    Response handleBoard(const Request& request);
    Response handleToggle(const Request& request);
    Response handleSent(const Request& request);
};
