#include "ProrateLog.h"

#include <string>
#include "../database/Database.h"

using nlohmann::json;

ProrateLog::ProrateLog() : db_(Database::getInstance()) {}

json ProrateLog::dueList() {
    json out = json::array();
    const auto rows = db_->query(R"SQL(
        WITH m AS (
            SELECT m.person_id,
                   MIN(m.la_registered_at)                         AS reg_at,
                   SUM(COALESCE(m.la_amount_owed_cents, 0))        AS billed_cents,
                   SUM(COALESCE(m.la_amount_paid_cents, 0))        AS paid_cents,
                   string_agg(DISTINCT COALESCE(lp.program_name, lp.category), ' · ') AS programs,
                   (array_agg(lp.category ORDER BY m.la_registered_at DESC NULLS LAST))[1] AS category
              FROM person_la_memberships m
              JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
             WHERE m.ended_at IS NULL
               AND lp.variant = 'active'
               AND COALESCE(m.la_amount_owed_cents, 0) <= 100
               AND COALESCE(m.la_payment_status, '') <> 'NA_FREE'
             GROUP BY m.person_id)
        SELECT p.id, COALESCE(p.first_name, '') AS first_name, COALESCE(p.last_name, '') AS last_name,
               CASE m.category WHEN 'men' THEN 'mens' WHEN 'women' THEN 'womens' ELSE m.category END AS section,
               p.la_user_id,
               TO_CHAR(m.reg_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS reg_iso,
               m.billed_cents, m.paid_cents, m.programs
          FROM m JOIN persons p ON p.id = m.person_id
         WHERE NOT EXISTS (SELECT 1 FROM club_volunteers v WHERE v.person_id = p.id)
           AND NOT EXISTS (SELECT 1 FROM prorate_dismissals d WHERE d.person_id = p.id)
         ORDER BY m.reg_at DESC NULLS LAST, p.id
    )SQL");
    for (const auto& r : rows) {
        out.push_back({
            {"person_id",     r["id"].as<long long>()},
            {"first_name",    r["first_name"].c_str()},
            {"last_name",     r["last_name"].c_str()},
            {"section",       r["section"].is_null() ? "" : r["section"].c_str()},
            {"la_user_id",    r["la_user_id"].is_null() ? "" : r["la_user_id"].c_str()},
            {"registered_at", r["reg_iso"].is_null() ? json(nullptr) : json(r["reg_iso"].c_str())},
            {"billed_usd",    r["billed_cents"].as<long long>() / 100.0},
            {"paid_usd",      r["paid_cents"].as<long long>() / 100.0},
            {"programs",      r["programs"].is_null() ? "" : r["programs"].c_str()},
        });
    }
    return out;
}

int ProrateLog::dismiss(const std::vector<long long>& playerIds, long long byUserId) {
    int n = 0;
    for (long long pid : playerIds) {
        if (pid <= 0) continue;
        db_->query(
            "INSERT INTO prorate_dismissals (person_id, dismissed_by_user) "
            "SELECT $1::int, NULLIF($2, '')::int WHERE EXISTS (SELECT 1 FROM persons WHERE id = $1::int) "
            "ON CONFLICT (person_id) DO NOTHING",
            {std::to_string(pid), byUserId > 0 ? std::to_string(byUserId) : std::string{}});
        ++n;
    }
    return n;
}
