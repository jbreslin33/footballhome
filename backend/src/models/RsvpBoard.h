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
// The card splits the released week's unanswered events into open (still
// answerable) and missed (already happened); REMIND works off both.
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
    // missed: already happened and never answered — listed in the
    // reminder (with the kind='rsvp_reminder' tier='missed_line' suffix,
    // mig 379) so a player below 100% for the week can still be nudged.
    struct OpenEvent { long long fhEventId; std::string line; bool missed = false; };
    struct ReminderContext {
        bool        found = false;
        std::string playerFirstName;
        long long   recipientPersonId = 0;   // parent for youth, else the player
        std::string recipientFirstName;
        bool        youth = false;
        std::string phone;                   // recipient's, "" when none
        std::string email;
        std::vector<long long> teamIds;      // player's active board teams
        std::vector<OpenEvent> events;       // unanswered in the released week, by start; see missed
    };
    ReminderContext reminderContext(long long personId);

    // One still-open event, and everybody in the section (optionally one
    // team) who has not answered it — for ONE group text / BCC email
    // (mig 380).  Contacts are the parent's for youth, like the cards.
    struct GroupRecipient {
        long long   personId = 0;
        long long   recipientPersonId = 0;
        std::string phone;                   // "" when none
        std::string email;
        std::vector<OpenEvent> weekEvents;   // everything still open this week (incl. the event)
    };
    struct GroupReminderContext {
        std::string line;                    // "" = nobody owes this event an answer
        std::vector<GroupRecipient> recipients;
        // Every still-open event any recipient owes, by start — the
        // "whole week" group message (Game Center, mig 381).
        std::vector<OpenEvent> weekEvents;
    };
    // sectionCode "" = any section (the caller scopes by event / team).
    GroupReminderContext groupReminderContext(const std::string& sectionCode, long long fhEventId,
                                              const std::vector<long long>& teamIds);

    // The copy itself is message_templates kind='rsvp_reminder', tier
    // 'adult' | 'parent' (one player, magic link) or 'group_adult' |
    // 'group_parent' (one event, no link) or 'group_week_adult' |
    // 'group_week_parent' (the week, no link), rendered by MessageCopy.

    // Writes rsvp_reminders + rsvp_reminder_events; returns the card's
    // fresh last_reminder object.
    nlohmann::json logReminder(long long personId, long long recipientPersonId,
                               const std::string& channel, const std::string& contact,
                               long long sentByUserId,
                               const std::vector<OpenEvent>& events,
                               bool isGroup = false);
};
