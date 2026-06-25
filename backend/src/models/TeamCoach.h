#pragma once
#include "../database/Database.h"
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// TeamCoach — models the (team, coach) relationship.
//
// Tables touched:
//   coaches        (id PK, person_id UNIQUE NOT NULL, …)
//   team_coaches   (team_id, coach_id, started_at, ended_at NULL = active)
//
// A `coaches` row is the durable identity of "this person can be a coach".
// `team_coaches` is the time-bounded assignment of that coach to a team.
// Removing a coach from a team SOFT-ENDS the team_coaches row (sets
// ended_at = now()); the underlying `coaches` row survives so historical
// references (lineups, assessments, etc.) stay intact.
//
// Each operation runs as a single parameterised statement via the Database
// connection pool — atomic without an explicit transaction.
// ────────────────────────────────────────────────────────────────────────────
class TeamCoach {
public:
    struct AssignResult {
        int  coachId = 0;     // id of the durable coaches row
        bool reactivated = false;  // true ⇢ ended_at cleared; false ⇢ fresh insert
    };

    TeamCoach();

    // Idempotent: assigns `personId` as a coach of `teamId`. If they
    // already have an active team_coaches row, this is a no-op that
    // still returns the coachId. If a soft-ended row exists it is
    // reactivated. Otherwise a fresh row is inserted.
    //
    // Throws on DB error.
    AssignResult assign(int teamId, int personId);

    // Soft-ends the team_coaches row for (teamId, personId). Returns the
    // number of rows ended (0 if no active assignment existed).
    //
    // Throws on DB error.
    int unassign(int teamId, int personId);

private:
    Database* db_;
};
