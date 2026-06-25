#include "TeamCoach.h"
#include <stdexcept>
#include <string>

TeamCoach::TeamCoach() : db_(Database::getInstance()) {
    if (!db_) {
        throw std::runtime_error("TeamCoach: Database instance is null");
    }
}

TeamCoach::AssignResult TeamCoach::assign(int teamId, int personId) {
    // Single-statement upsert chain:
    //   1. Find-or-create the coaches row (UNIQUE on person_id).
    //   2. If a soft-ended team_coaches row exists for this (team, coach),
    //      clear its ended_at (reactivate).
    //   3. Otherwise insert a fresh team_coaches row (collision-safe via the
    //      partial-unique index on (team_id, coach_id) WHERE ended_at IS NULL).
    // The final SELECT returns the coachId and whether step 2 fired.
    static const std::string kSql = R"SQL(
        WITH coach AS (
            INSERT INTO coaches (person_id)
                 VALUES ($2::int)
            ON CONFLICT (person_id) DO UPDATE
                SET person_id = EXCLUDED.person_id
            RETURNING id
        ),
        reactivated AS (
            UPDATE team_coaches
               SET ended_at = NULL
             WHERE team_id  = $1::int
               AND coach_id = (SELECT id FROM coach)
               AND ended_at IS NOT NULL
            RETURNING team_id
        ),
        inserted AS (
            INSERT INTO team_coaches (team_id, coach_id)
            SELECT $1::int, (SELECT id FROM coach)
             WHERE NOT EXISTS (SELECT 1 FROM reactivated)
            ON CONFLICT (team_id, coach_id) WHERE ended_at IS NULL DO NOTHING
            RETURNING team_id
        )
        SELECT (SELECT id FROM coach)                            AS coach_id,
               (SELECT count(*) FROM reactivated) > 0            AS reactivated
    )SQL";

    pqxx::result rs = db_->query(kSql, {std::to_string(teamId), std::to_string(personId)});
    if (rs.empty()) {
        throw std::runtime_error("TeamCoach::assign: no row returned");
    }

    AssignResult out;
    out.coachId     = rs[0]["coach_id"].as<int>();
    out.reactivated = rs[0]["reactivated"].as<bool>();
    return out;
}

int TeamCoach::unassign(int teamId, int personId) {
    static const std::string kSql = R"SQL(
        UPDATE team_coaches tc
           SET ended_at = now()
          FROM coaches c
         WHERE c.id        = tc.coach_id
           AND tc.team_id  = $1::int
           AND c.person_id = $2::int
           AND tc.ended_at IS NULL
        RETURNING tc.team_id
    )SQL";

    pqxx::result rs = db_->query(kSql, {std::to_string(teamId), std::to_string(personId)});
    return static_cast<int>(rs.size());
}
