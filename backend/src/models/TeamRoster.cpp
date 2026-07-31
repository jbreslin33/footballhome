#include "TeamRoster.h"

TeamRoster::TeamRoster() : db_(Database::getInstance()) {
    if (!db_) {
        throw std::runtime_error("TeamRoster: Database instance is null");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// add — ensure a players row exists (other surfaces key off players.id),
// then open a team_persons membership if none is active.  Group model:
// membership IS RSVP eligibility, so this single write replaces the old
// roster row + eligibility-trigger pair.  Single CTE so both land
// together (no app-level transaction needed).
// ────────────────────────────────────────────────────────────────────────────
TeamRoster::Result TeamRoster::add(int teamId, int personId) {
    static const std::string kSql = R"SQL(
        WITH player AS (
            INSERT INTO players (person_id) VALUES ($2::int)
            ON CONFLICT (person_id) DO UPDATE
                SET person_id = EXCLUDED.person_id
            RETURNING id
        ),
        inserted AS (
            INSERT INTO team_persons (team_id, person_id, on_roster)
            SELECT $1::int, $2::int, true
              FROM player
             WHERE NOT EXISTS (
                 SELECT 1 FROM team_persons
                  WHERE team_id   = $1::int
                    AND person_id = $2::int
                    AND removed_at IS NULL
             )
            RETURNING id
        )
        SELECT (SELECT id FROM player)::int               AS player_id,
               (SELECT count(*) FROM inserted)::int       AS rows_affected
    )SQL";

    pqxx::result rs = db_->query(kSql,
        {std::to_string(teamId), std::to_string(personId)});
    if (rs.empty()) {
        throw std::runtime_error("TeamRoster::add: no row returned");
    }
    Result out;
    out.playerId     = rs[0]["player_id"].as<int>();
    out.rowsAffected = rs[0]["rows_affected"].as<int>();
    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// remove — close any currently-open roster row for this (team, player).  The
// players-upsert is kept (matches Node behaviour) so the player_id in the
// response is always meaningful, even when the person has never been a
// player before.
// ────────────────────────────────────────────────────────────────────────────
TeamRoster::Result TeamRoster::remove(int teamId, int personId) {
    static const std::string kSql = R"SQL(
        WITH player AS (
            INSERT INTO players (person_id) VALUES ($2::int)
            ON CONFLICT (person_id) DO UPDATE
                SET person_id = EXCLUDED.person_id
            RETURNING id
        ),
        ended AS (
            UPDATE team_persons
               SET removed_at = NOW(),
                   removed_reason = 'admin_remove'
             WHERE team_persons.team_id   = $1::int
               AND team_persons.person_id = $2::int
               AND team_persons.removed_at IS NULL
            RETURNING team_persons.id
        )
        SELECT (SELECT id FROM player)::int               AS player_id,
               (SELECT count(*) FROM ended)::int          AS rows_affected
    )SQL";

    pqxx::result rs = db_->query(kSql,
        {std::to_string(teamId), std::to_string(personId)});
    if (rs.empty()) {
        throw std::runtime_error("TeamRoster::remove: no row returned");
    }
    Result out;
    out.playerId     = rs[0]["player_id"].as<int>();
    out.rowsAffected = rs[0]["rows_affected"].as<int>();
    return out;
}
