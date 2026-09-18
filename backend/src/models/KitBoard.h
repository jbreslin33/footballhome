#pragma once
#include <optional>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

// KitBoard — the #kit board: uniform numbers (team_persons.jersey_number,
// per team membership) and kit handed out (person_kit_issues, per person;
// what can be handed out is kit_items — migration 373).
class KitBoard {
public:
    // Active Lighthouse board teams; scopeTeamIds empty = all (admin).
    nlohmann::json teams(const std::vector<long long>& scopeTeamIds);

    // Active kit items, in board order.
    nlohmann::json items();

    // The team's active roster with number + issued item ids.
    nlohmann::json roster(long long teamId);

    bool onTeam(long long teamId, long long personId);

    // Who (other than personId) already wears `number` on the team — "" when free.
    std::string numberHolder(long long teamId, long long personId, const std::string& number);

    // number "" clears it.
    void setNumber(long long teamId, long long personId, const std::string& number);

    // issued=false removes the row.  False when kitItemId is not an active item.
    bool setIssued(long long personId, long long kitItemId, bool issued, long long byUserId);
};
