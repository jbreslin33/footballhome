#pragma once
#include <string>
#include <unordered_map>
#include <vector>

#include "../third_party/json.hpp"

class Database;

// WelcomeLog — person_welcomes + welcome_outreach_policies (migration 339).
//
// Mirrors PayReminderLog: bulk "latest per person" for the roster boards,
// plus record() for the POST.  attach() is the one place the "due" rule
// lives, so Boys / Mens / Womens rosters all agree on it:
//
//   due = no welcome ever sent to the target person
//         AND membership la_registered_at::date >= policy cutoff
//
// The target person is who RECEIVES the welcome — the parent for youth,
// the player for adults — so one welcome covers every sibling.
class WelcomeLog {
public:
    struct Latest {
        std::string channel;   // "sms" | "email"
        std::string contact;
        std::string sentAtIso; // "YYYY-MM-DDTHH:MM:SS.mmmZ" (UTC)
    };
    using Map = std::unordered_map<long long, Latest>;

    WelcomeLog();

    void record(long long          personId,
                long long          playerPersonId,   // <= 0 → NULL
                const std::string& channel,
                const std::string& contact,
                long long          senderUserId);    // <= 0 → NULL

    Map latestFor(const std::vector<long long>& personIds);

    // "YYYY-MM-DD" from the latest welcome_outreach_policies row for the
    // club, or "" when no policy exists (then nothing is ever due).
    std::string policyCutoff(int clubId);

    // Sets row["welcome"] = {due, lastSentAt, lastChannel, lastContact}
    // (or null when there is no target person).  laRegisteredAt is the
    // roster row's ISO timestamp (json string or null).
    static void attach(nlohmann::json&        row,
                       long long              targetPersonId,
                       const nlohmann::json&  laRegisteredAt,
                       const Map&             latest,
                       const std::string&     cutoffYmd);

    // Post-pass over a finished roster payload: walks every row in
    // `unassigned` and every array in `buckets`, resolves the target
    // person (parentPersonId ?? personId when `youth`, else personId),
    // loads latest welcomes + the policy in two queries, and attach()es.
    // Non-fatal: on any DB error rows simply carry welcome:null.
    void attachToRoster(std::vector<nlohmann::json>& unassigned, nlohmann::json& buckets, bool youth);

    static constexpr int kLighthouseClubId = 134;

private:
    Database* db_;
};
