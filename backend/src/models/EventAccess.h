#pragma once
#include <string>

class Database;

// EventAccess — how much one person gets on one event (docs/event-center-
// design.md, slice 1).  Player/parent → Coach → Admin, each tier a strict
// superset of the one below.  The ONE permission answer for "coach of this
// event or admin"; the SQL function fh_event_viewer_tier (mig 1362) holds the
// rule so the calendar feed computes the same answer per row.
//
// Owner 2026-11-14: "the coach screen should just be more enhanced then
// player/parent. the admin just more enhanced then coach".
//
// The tier is per event: a U10 coach is Coach on U10 events and Player on
// their kid's U12 game.  Pass the EFFECTIVE person (after view-as) so an
// admin viewing as someone gets exactly that person's tier.
class EventAccess {
public:
    enum class Tier { Player = 0, Coach = 1, Admin = 2 };

    static Tier tierFor(Database* db, long long personId, long long fhEventId);

    // Coach or above — may mark attendance, invite, remind, edit groups.
    static bool canCoach(Database* db, long long personId, long long fhEventId) {
        return tierFor(db, personId, fhEventId) >= Tier::Coach;
    }

    // "player" | "coach" | "admin" — the viewer_tier the frontend reads.
    static std::string name(Tier t);
    static Tier parse(const std::string& s);
};
