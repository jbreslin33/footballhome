#pragma once
#include <string>
#include <unordered_map>

class Database;

// WelcomeMessage — assembles the roster-card welcome (migration 364).
//
// No copy lives here: every sentence is a message_templates row
// (kind 'welcome' / 'welcome_sms' skeletons + 'welcome_*' blocks, tier
// 'adult' | 'parent') and every fact comes from the DB:
//
//   • events    released events still to come for the player's teams —
//               the same visibility #my uses (team_persons not removed,
//               not suspended, inside fh_schedule_window_end()).
//   • schedule  the "usual week", derived from what repeats in gcal over
//               the next four weeks (release window ignored on purpose —
//               it names a pattern, never a specific unreleased event).
//   • release   when next week's schedule opens for the player's section
//               (fh_schedule_week_opens_at — policy + early releases).
//   • forms     external links the copy names as {form:<code>} come from
//               club_forms (migration 365).
//
// Which block is used is decided by those facts, not by section: a men's
// player with practices left gets the list, an intramural child welcomed
// on a Friday gets "nothing left this week … posts Sunday".
class WelcomeMessage {
public:
    struct Facts {
        bool        onTeam = false;
        // Not on a team yet, but young enough to assume one: the club's
        // intramural side for the child's age band (owner 2026-09-23:
        // "if a new player is not on a team assume intramural and send
        // them that schedule").  Its events/schedule fill the blocks and
        // welcome_assumed_team names it.  "" when nothing fits.
        std::string assumedTeam;
        std::string events;        // one "• …" line per event, "" when none
        std::string schedule;      // one "• …" line per pattern, "" when none
        std::string releaseDay;    // "Sunday"
        std::string releaseTime;   // "8:00 PM"
    };

    struct Rendered {
        std::string subject;
        std::string body;
        bool ok() const { return !body.empty(); }
    };

    struct Tokens {
        std::string first;     // recipient's first name
        std::string child;     // player's first name (youth only)
        std::string link;      // magic link
        std::string sender;    // sending admin
        bool        docsAsk = false;  // youth travel column → docs block
    };

    WelcomeMessage();

    // playerPersonId is who the schedule belongs to — the child for a
    // youth welcome, the recipient themselves for adults.
    Facts factsFor(long long playerPersonId, int clubId);

    // channel "email" → kind 'welcome', anything else → 'welcome_sms'.
    // Rendered.body is empty when the skeleton row is missing.  Form
    // links ({form:<code>}, club_forms — migration 365) are resolved for
    // clubId; a docs block whose form is missing is dropped rather than
    // sent with a dead token.
    Rendered render(const std::string& channel, bool youth, int clubId,
                    const Facts& facts, const Tokens& tokens);

private:
    struct Template { std::string subject, body; };
    using TemplateMap = std::unordered_map<std::string, Template>;

    TemplateMap loadTemplates(const std::string& tier);
    std::string fillFormLinks(const std::string& text, int clubId);

    Database* db_;
};
