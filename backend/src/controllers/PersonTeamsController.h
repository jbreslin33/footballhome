#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PersonTeams;

// PersonTeamsController — the ⚽ Teams pills on the player sheet (mig 1307).
//
//   GET  /api/person-teams?person_id=N
//        PersonTeams::board for this viewer.  403 when the viewer manages
//        none of the teams shown (players never get the pills).
//
//   POST /api/person-teams  { person_id, team_id, action, from_team_id? }
//        action add    — onto team_id (he stays on his other teams)
//               remove — off team_id
//               move   — onto team_id and off from_team_id, one transaction
//        Each team touched needs Controller::canManageTeam; a team whose
//        league list has him (fh_on_league_list) can't be left — 409.
//        Answers the fresh board.
class PersonTeamsController : public Controller {
public:
    PersonTeamsController();
    ~PersonTeamsController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonTeams> model_;

    Response handleBoard(const Request& request);
    Response handleChange(const Request& request);
};
