#pragma once
#include <string>

#include "../third_party/json.hpp"

// PersonHealth — the health setting on a roster card (migration 510):
// Healthy, or an injury with a time frame.  While an injury lasts the
// player owes no RSVP and is not fined (fh_person_injured_at, read by the
// #rsvps board and fh_person_fines()).
//
// Owner 2026-10-02: "we need an injured check box or setting in the drop
// down … Healthy, short term injury, long term injury. or allow for
// setting time frame … this way we can avoid sending practice reminders
// and fining them."
class PersonHealth {
public:
    // {statuses: [...health_statuses], copy: {tier: body}, people: {id: entry}}
    // — people holds only who is injured right now.
    nlohmann::json board();

    // The person's current injury as the board shows it, or null (healthy).
    nlohmann::json current(long long personId);

    // statusCode: a health_statuses code.  A not-injured one ends the
    // current injury; an injured one updates the current injury or starts
    // one.  since / until are club-local YYYY-MM-DD: since "" = keep (or
    // now, for a new injury), until "" = until set Healthy.
    // Throws std::invalid_argument with a message for the caller.
    nlohmann::json set(long long personId, const std::string& statusCode,
                       const std::string& since, const std::string& until, long long userId);

    // Does this user coach a team the person is on?
    bool coachCovers(long long userId, long long personId);
};
