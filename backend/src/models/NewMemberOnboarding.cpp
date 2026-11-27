#include "NewMemberOnboarding.h"

#include <string>
#include "../database/Database.h"

using nlohmann::json;

NewMemberOnboarding::NewMemberOnboarding() : db_(Database::getInstance()) {}

json NewMemberOnboarding::report() {
    json policy = json::object();
    for (const auto& r : db_->query(
            "SELECT counts_from::text AS counts_from, green_hours, red_hours FROM new_member_onboard_policy WHERE id = 1"))
        policy = {{"counts_from", r["counts_from"].c_str()},
                  {"green_hours", r["green_hours"].as<int>()},
                  {"red_hours",   r["red_hours"].as<int>()}};
    json members = json::array();
    if (policy.empty()) return {{"policy", nullptr}, {"members", members}};

    // Cheap filters first (feedback: cheap SQL filters before per-person work):
    // the policy date + live active memberships, then the per-person checks.
    const auto rows = db_->query(R"SQL(
        WITH pol AS (SELECT counts_from, green_hours, red_hours FROM new_member_onboard_policy WHERE id = 1),
        reg AS (
            SELECT m.person_id,
                   MIN(m.la_registered_at)                         AS reg_at,
                   SUM(COALESCE(m.la_amount_owed_cents, 0))        AS billed_cents,
                   BOOL_OR(m.la_payment_status = 'NA_FREE')        AS free,
                   (array_agg(lp.category ORDER BY m.la_registered_at DESC NULLS LAST))[1] AS category
              FROM person_la_memberships m
              JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
              JOIN pol ON m.la_registered_at >= pol.counts_from
             WHERE m.ended_at IS NULL
               AND lp.variant = 'active'
             GROUP BY m.person_id),
        x AS (
            SELECT r.*, p.first_name, p.last_name,
                   (SELECT MIN(fr.responded_at) FROM fh_event_rsvps fr WHERE fr.person_id = r.person_id) AS rsvp_at,
                   (r.free OR r.billed_cents > 100
                     OR EXISTS (SELECT 1 FROM club_volunteers v WHERE v.person_id = r.person_id)
                     OR EXISTS (SELECT 1 FROM prorate_dismissals d WHERE d.person_id = r.person_id)) AS prorate_ok,
                   EXTRACT(EPOCH FROM (now() - r.reg_at)) / 3600.0 AS age_hours
              FROM reg r
              JOIN persons p ON p.id = r.person_id
             WHERE NOT EXISTS (SELECT 1 FROM new_member_onboard_dismissals d WHERE d.person_id = r.person_id))
        SELECT x.person_id, COALESCE(x.first_name, '') AS first_name, COALESCE(x.last_name, '') AS last_name,
               CASE x.category WHEN 'men' THEN 'mens' WHEN 'women' THEN 'womens' ELSE x.category END AS section,
               TO_CHAR(x.reg_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS reg_iso,
               TO_CHAR(x.rsvp_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS rsvp_iso,
               x.rsvp_at IS NOT NULL AS rsvp_ok, x.prorate_ok,
               (x.rsvp_at IS NOT NULL AND x.prorate_ok) AS onboarded,
               x.billed_cents, x.age_hours::float8 AS age_hours,
               CASE WHEN x.age_hours < pol.green_hours THEN 'green'
                    WHEN x.age_hours < pol.red_hours   THEN 'yellow' ELSE 'red' END AS tone,
               COALESCE((SELECT jsonb_agg(DISTINCT t.name)
                           FROM team_persons tp JOIN teams t ON t.id = tp.team_id
                          WHERE tp.person_id = x.person_id AND tp.removed_at IS NULL), '[]'::jsonb)::text AS teams
          FROM x CROSS JOIN pol
         ORDER BY (x.rsvp_at IS NOT NULL AND x.prorate_ok), x.reg_at, x.person_id
    )SQL");
    for (const auto& r : rows) {
        json teams = json::array();
        try { teams = json::parse(r["teams"].c_str()); } catch (...) {}
        members.push_back({
            {"person_id",     r["person_id"].as<long long>()},
            {"first_name",    r["first_name"].c_str()},
            {"last_name",     r["last_name"].c_str()},
            {"section",       r["section"].is_null() ? "" : r["section"].c_str()},
            {"registered_at", r["reg_iso"].is_null() ? json(nullptr) : json(r["reg_iso"].c_str())},
            {"rsvp_at",       r["rsvp_iso"].is_null() ? json(nullptr) : json(r["rsvp_iso"].c_str())},
            {"rsvp_ok",       r["rsvp_ok"].as<bool>()},
            {"prorate_ok",    r["prorate_ok"].as<bool>()},
            {"onboarded",     r["onboarded"].as<bool>()},
            {"billed_usd",    r["billed_cents"].as<long long>() / 100.0},
            {"age_hours",     r["age_hours"].as<double>()},
            {"tone",          r["tone"].c_str()},
            {"teams",         teams},
        });
    }
    return {{"policy", policy}, {"members", members}};
}

int NewMemberOnboarding::dismiss(const std::vector<long long>& personIds, long long byUserId) {
    int n = 0;
    for (long long pid : personIds) {
        if (pid <= 0) continue;
        db_->query(
            "INSERT INTO new_member_onboard_dismissals (person_id, dismissed_by_user) "
            "SELECT $1::int, NULLIF($2, '')::int WHERE EXISTS (SELECT 1 FROM persons WHERE id = $1::int) "
            "ON CONFLICT (person_id) DO NOTHING",
            {std::to_string(pid), byUserId > 0 ? std::to_string(byUserId) : std::string{}});
        ++n;
    }
    return n;
}
