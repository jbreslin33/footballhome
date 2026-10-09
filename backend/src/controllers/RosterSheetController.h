#pragma once
#include <string>
#include "../core/Controller.h"

// RosterSheetController — the league roster sheet for a game (mig 561) and
// the coaches-with-status list the team boards edit (mig 560).
//
//   GET /api/roster-sheet/:matchId        the sheet: team header (team_roster_sheets),
//                                         coaches on roster (team_coaches.roster_status_id),
//                                         players with jersey / birth year / starter
//   GET /api/team-coaches/:teamId         [{ person_id, name, role, role_label, status, status_label }]
//   PUT /api/team-coaches/:teamId/:personId   { rosterStatus: code | null, coachRole: name | null }
//
// The sheet is for the game's teams (coaches, their rosters) and club
// admins, like the official roster; the coach list is for anyone signed
// in, the PUT for a coach of the team or an admin.
class RosterSheetController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleSheet(const Request& request);
    Response handleCoaches(const Request& request);
    Response handlePutCoach(const Request& request);
};
