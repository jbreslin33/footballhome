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
// the team-reconciliation screen.  Replaces meta-leads-webhook's
//   GET /api/teams/:teamId/reconciliation
// route 1:1, including telemetry keys.
//
// Steps (in order, mirroring Node):
//   1. Live-refresh every active GroupMe chat for the team.
//   2. If the team is "mens" (club_id == MENS_CLUB_ID AND name not matching
//      women/pickup/training/pool), live-fetch the LA mens program AND run
//      PersonLinker over every active registration to self-heal persons +
//      external_person_aliases.
//   3. Auto-marry any newly-refreshed chat members whose external_username
//      is exactly "First Last" and matches a unique persons row by name.
//   4. Run the big bucketing CTE (la_persons / gm_persons / coach_persons →
//      player | laOnly | gmOnly | coach).
//   5. Append the unlinkedChatMembers list (gm members with no person_id).
//   6. Wrap it all in the response JSON.
// ────────────────────────────────────────────────────────────────────────────
class TeamReconciliation {
public:
    struct ChatRefreshReport {
        int         chatId       = 0;
        std::string externalId;
        bool        ok           = false;
        bool        nameChanged  = false;
        int         added        = 0;
        int         kept         = 0;
        int         removed      = 0;
        std::string error;
    };

    struct Result {
        nlohmann::json body;  // fully-shaped response body
    };

    TeamReconciliation();
    ~TeamReconciliation();

    // Runs all reconciliation steps for the team.  Throws on transport-fatal
    // errors (DB down).  Per-chat refresh failures are reported in
    // body.refresh.groupme[]; LA refresh failures degrade gracefully to an
    // empty active set (and surface as supported=false).
    Result run(int teamId);

private:
    Database*                       db_;
    std::unique_ptr<PersonLinker>   linker_;
    int                             mensClubId_;   // env LEAGUEAPPS_MENS_CLUB_ID
    int                             mensProgramId_;// env LEAGUEAPPS_MENS_PROGRAM_ID

    // Step 1.
    std::vector<ChatRefreshReport> refreshGroupMeChats(int teamId);
    ChatRefreshReport refreshOneChat(int chatId,
                                     const std::string& externalId,
                                     const std::string& currentName);

    // Step 2.
    bool teamIsMens(int teamId);
    struct LaSnapshot {
        std::vector<std::string>             activeUserIds;
        std::map<std::string, std::string>   statusByUser;
    };
    std::optional<LaSnapshot> syncMensLa();   // nullopt if team isn't mens

    // Step 3.
    int autoMarryGmChatMembers(int teamId);

    // Step 4.  Builds the per-person rows and stuffs them into `out`.
    void bucketTeamPersons(int teamId,
                           const std::optional<LaSnapshot>& la,
                           nlohmann::json& out);

    // Step 5.
    nlohmann::json unlinkedChatMembers(int teamId);
};
