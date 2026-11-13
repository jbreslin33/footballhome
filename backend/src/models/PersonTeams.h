#pragma once
#include <optional>
#include <string>

#include "../third_party/json.hpp"

// PersonTeams — the ⚽ Teams pills on the player sheet (mig 1307, owner
// 2026-11-13: "a move section that has pills for all the teams. then if i
// click another team it asks do we want to move or add" / "have
// consistency between screens").  One pill per active board team
// (teams.board_sort_order set) of the sections he plays in — every
// section when he is on no team yet.  The sheet draws the same pills on
// every screen that opens it.
//
// The writes go through MensTeamAssignments (team_persons), the same rows
// the #teams boards' move list wrote.
class PersonTeams {
public:
    // {personId, teams: [{teamId, domain, label, short, on, locked,
    //  canManage}]} in section → board order.  locked = on the league's
    // own online list (fh_on_league_list) — only the league takes him off.
    // canManage mirrors Controller::canManageTeam for this viewer.
    nlohmann::json board(long long personId, long long viewerUserId);

    // The team's gender_category when it is an active board team.
    std::optional<std::string> boardDomain(int teamId);

    bool onTeam(long long personId, int teamId);
    bool onLeagueList(long long personId, int teamId);
};
