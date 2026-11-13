#pragma once
#include <optional>
#include <string>
#include <vector>

// StarterCriteria — the practice criterion to start a game (migs 456/562):
// how many practice days a player needs in the game's window, how many he
// has, and how many more he said Going to.
//
// statsSql() is the one query Game Center's criteria card reads
// (EligibilityController GET /api/eligibility/lineup/:matchId) —
// $1 match id, $2 roster team ids (int[] literal), $3 person id or ''.
// forPerson() runs it for one player and his next game he is Going to,
// for the 📇 Practice criteria message (mig 1342).
class StarterCriteria {
public:
    static const std::string& statsSql();

    struct Practice {
        std::string when;     // club-local "Thu Nov 19, 7:00 PM"
        bool future = false;
        std::string rsvp;     // yes | no | maybe | ''
        std::string status;   // attendance: present | late | excused | absent | ''
        bool counted = false; // attended (past) or Going (future)
    };

    struct Result {
        long long matchId = 0;
        long long fhEventId = 0;
        std::string game;     // "vs Desert Hawks" ('' = no opponent named)
        std::string when;     // kickoff, club-local
        long long needed = 0, attended = 0, projected = 0;
        // The Game Center card's states (_criteriaState): exceeding,
        // exceeding_projected, met, projected, needs, not_met.
        std::string state;
        std::vector<Practice> practices;
    };

    // nullopt: no game in the next 8 days he is Going to and rostered for.
    std::optional<Result> forPerson(long long personId);
};
