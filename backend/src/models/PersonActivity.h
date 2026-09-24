#pragma once
#include <string>
#include <unordered_map>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PersonActivity — read-only roll-up of a person's RSVP + attendance trail
// (fh_event_rsvps, fh_event_attendance, both keyed on fh_events) for the
// #payments cards.
//
// Owner 2026-09-24: "we need the financial page to show some attendance
// and rsvp data so we can see if the player is a ghost and over due and
// maybe just drop them ... like last rsvp and last attended event".
//
// One bulk query per screen load (same shape as PayReminderLog::latestFor):
//   • lastRsvp      newest response by responded_at, with the event it was
//                   for (kind + start) so the card reads "yes · practice
//                   9/24"
//   • lastAttended  newest PAST event they were marked present/late at
//   • lastMarked    newest past event with ANY attendance mark (present,
//                   late, absent) — a run of absents is a ghost signal too
//   • 30-day tallies (rsvpYes/rsvpNo/attended/absent) so the frontend can
//                   decide "no sign of life" without a second round-trip
// People with no rows are simply not present in the map.
// ────────────────────────────────────────────────────────────────────────────
class PersonActivity {
public:
    struct EventRef {
        std::string status;       // rsvp response or attendance status
        std::string atIso;        // when they responded / were marked (UTC ISO)
        std::string eventKind;    // fh_events.kind (practice/match/…)
        std::string eventStartIso;// fh_events.start_at (UTC ISO)
        std::string opponent;     // fh_events.opponent, may be empty
        bool present() const { return !status.empty(); }
    };
    struct Summary {
        EventRef lastRsvp;
        EventRef lastAttended;
        EventRef lastMarked;
        int rsvpYes30  = 0;
        int rsvpNo30   = 0;
        int attended30 = 0;   // present + late
        int absent30   = 0;
        int rsvpTotal  = 0;
        int attendedTotal = 0;
    };
    using Map = std::unordered_map<int, Summary>;   // person_id → summary

    PersonActivity();

    // Bulk per-person roll-up. Ids ≤ 0 are ignored; an empty list is a no-op.
    Map latestFor(const std::vector<int>& personIds, int windowDays = 30);

private:
    Database* db_;
};
