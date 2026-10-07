#pragma once
#include <string>
#include <vector>
#include "../third_party/json.hpp"

// SmsOptInBoard — the #texts board (migration 537): who on a team has
// consented to club texts, and the nudges sent to the rest.
//
// A row is a player; the mobile is the one we would text — the parent's
// for a youth player (persons.parent_person_id), as every reminder does.
// "Opted in" = fh_sms_consented_at() for the player or the recipient: an
// sms_opt_ins row tied to the person or carrying one of their numbers.
class SmsOptInBoard {
public:
    // The board teams — the same list as #kit (teams.board_sort_order).
    nlohmann::json teams(const std::vector<long long>& scopeTeamIds);
    nlohmann::json roster(long long teamId);
    bool onTeam(long long teamId, long long personId);

    struct Person {
        bool        found = false;
        bool        youth = false;
        long long   recipientPersonId = 0;
        std::string playerFirstName;
        std::string recipientFirstName;
        std::string phone;          // "" when none
    };
    Person person(long long personId);

    // Writes sms_opt_in_nudges; returns {count, last_at} for the row.
    nlohmann::json logNudge(long long personId, long long recipientPersonId,
                            const std::string& channel, const std::string& contact,
                            long long sentByUserId);
};
