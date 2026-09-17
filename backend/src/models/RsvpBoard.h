#pragma once
#include <string>
#include <vector>
#include "../third_party/json.hpp"

// RsvpBoard — the data behind #rsvps (owner 2026-09-17): one card per
// rostered player with how well they answer RSVPs, what is still
// unanswered in the released week, when they were last active, their dues
// standing and last payment, and when they were last reminded.
//
// "Expected" events are the practices / games / intrasquads tagged to a
// team the player is on, from the day they joined it, inside the schedule
// release window (mig 334), while not suspended and while their roster
// status shows in RSVP.  Pickup, meetings and cancelled events never count.
// "Answered" is any fh_event_rsvps row (yes or no; players are not offered
// maybe), manual or standing.
//
// Reads person_la_memberships (dues, boys/girls split) — callers must have
// run the LA sync first (RsvpBoardController registers through laGet).
class RsvpBoard {
public:
    // sectionCode: club_sections.code ('M','W','B','G').
    // windowStart: ISO date/timestamp, or "" for all time.
    // scopeTeamIds: teams the caller may see; empty = every team (admin).
    nlohmann::json list(const std::string& sectionCode,
                        const std::string& windowStart,
                        const std::string& kind,          // all | games | practices
                        const std::vector<long long>& scopeTeamIds);

    // Each team's next game (owner 2026-09-17: "focus on game as its most
    // important") with how its roster has answered.  `released` is false
    // when the game is still beyond the schedule release window — players
    // cannot answer it yet, so nobody is counted as unanswered.
    nlohmann::json nextGames(const std::string& sectionCode,
                             const std::vector<long long>& scopeTeamIds);

    // Everything a reminder for one player needs.
    struct OpenEvent { long long fhEventId; std::string line; };
    struct ReminderContext {
        bool        found = false;
        std::string playerFirstName;
        long long   recipientPersonId = 0;   // parent for youth, else the player
        std::string recipientFirstName;
        bool        youth = false;
        std::string phone;                   // recipient's, "" when none
        std::string email;
        std::vector<long long> teamIds;      // player's active board teams
        std::vector<OpenEvent> openEvents;   // unanswered, not yet ended, released
    };
    ReminderContext reminderContext(long long personId);

    // The copy itself is message_templates kind='rsvp_reminder', tier
    // 'adult' | 'parent', rendered by MessageCopy.

    // Writes rsvp_reminders + rsvp_reminder_events; returns the card's
    // fresh last_reminder object.
    nlohmann::json logReminder(long long personId, long long recipientPersonId,
                               const std::string& channel, const std::string& contact,
                               long long sentByUserId,
                               const std::vector<OpenEvent>& events);
};
