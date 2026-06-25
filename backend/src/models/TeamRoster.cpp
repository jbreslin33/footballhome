#include "TeamRoster.h"

TeamRoster::TeamRoster() : db_(Database::getInstance()) {
    if (!db_) {
        throw std::runtime_error("TeamRoster: Database instance is null");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// add — ensure a players row exists, then open a roster row if none is
// currently open.  Single CTE so the upsert and the conditional insert are
// committed together (no app-level transaction needed).
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
            INSERT INTO rosters (team_id, player_id, joined_at)
            SELECT $1::int, p.id, NOW()
              FROM player p
             WHERE NOT EXISTS (
                 SELECT 1 FROM rosters
                  WHERE team_id   = $1::int
                    AND player_id = p.id
                    AND left_at IS NULL
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
            UPDATE rosters
               SET left_at = NOW()
              FROM player p
             WHERE rosters.team_id   = $1::int
               AND rosters.player_id = p.id
               AND rosters.left_at IS NULL
            RETURNING rosters.id
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
