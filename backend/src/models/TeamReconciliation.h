#pragma once
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class Database;
class PersonLinker;

// ────────────────────────────────────────────────────────────────────────────
// TeamReconciliation — orchestrates the live-refresh + bucketing that backs
// the team-reconciliation screen.
//
// Steps:
//   1. If the team is "mens" (club_id == MENS_CLUB_ID AND name not matching
//      women/pickup/training/pool), live-fetch the LA mens program AND run
//      PersonLinker over every active registration to self-heal persons +
//      external_person_aliases.
//   2. Bucket every person attached to the team into players | coaches |
//      laOnly.
// ────────────────────────────────────────────────────────────────────────────
class TeamReconciliation {
public:
    struct Result {
        nlohmann::json body;  // fully-shaped response body
    };

    TeamReconciliation();
    ~TeamReconciliation();

    // Runs all reconciliation steps for the team.  Throws on transport-fatal
    // errors (DB down).  LA refresh failures degrade gracefully to an empty
    // active set (and surface as supported=false).
    Result run(int teamId);

private:
    Database*                       db_;
    std::unique_ptr<PersonLinker>   linker_;
    int                             mensClubId_;   // env LEAGUEAPPS_MENS_CLUB_ID
    int                             mensProgramId_;// env LEAGUEAPPS_MENS_PROGRAM_ID

    bool teamIsMens(int teamId);
    struct LaSnapshot {
        std::vector<std::string>             activeUserIds;
        std::map<std::string, std::string>   statusByUser;
    };
    std::optional<LaSnapshot> syncMensLa();   // nullopt if team isn't mens

    void bucketTeamPersons(int teamId,
                           const std::optional<LaSnapshot>& la,
                           nlohmann::json& out);
};
