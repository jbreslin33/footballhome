#pragma once
#include "../database/Database.h"
#include <stdexcept>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// TeamRoster — owns a person's open membership row in `rosters` for a given
// team.
//
// Membership lives in two tables:
//   players (id, person_id, ...)                    UNIQUE(person_id)
//   rosters (id, team_id, player_id, joined_at, left_at)
//     "currently on the roster" ≡ exactly one row with left_at IS NULL per
//     (team_id, player_id).
//
// Two operations, both idempotent:
//   add(teamId, personId)    — ensure a players row exists, then open a
//                              roster row if none is currently open.
//   remove(teamId, personId) — close the currently-open roster row (set
//                              left_at = NOW()).  No-op if already left or
//                              never on the team.
//
// Each call runs as a single CTE statement against Database::query() — the
// players-upsert and the roster mutation are atomic together without an
// explicit transaction.
// ────────────────────────────────────────────────────────────────────────────
class TeamRoster {
public:
    struct Result {
        int  playerId   = 0;     // id of the players row (now guaranteed to exist)
        int  rowsAffected = 0;   // 1 when a new row was inserted (add) or closed
                                 // (remove); 0 when the call was a no-op.
    };

    TeamRoster();

    // Idempotently add the person to the team roster.  rowsAffected == 0 means
    // the person already had an open roster row for this team.
    Result add   (int teamId, int personId);

    // Idempotently remove the person from the team roster.  rowsAffected == 0
    // means there was no open roster row to close.
    Result remove(int teamId, int personId);

private:
    Database* db_;
};
