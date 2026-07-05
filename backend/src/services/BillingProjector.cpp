#include "BillingProjector.h"

#include <iostream>

#include "../database/Database.h"

namespace {

// Count SQL-side "inserted vs updated" by using WITH … INSERT
// … RETURNING (xmax = 0) — Postgres' idiomatic trick.  xmax=0 on the
// returned row means the row was freshly inserted; xmax≠0 means it hit
// the ON CONFLICT UPDATE branch.  We aggregate both counts client-side.
int countTaggedInserts(const pqxx::result& r) {
    int inserted = 0;
    for (const auto& row : r) {
        if (!row["was_inserted"].is_null() && row["was_inserted"].as<bool>()) {
            ++inserted;
        }
    }
    return inserted;
}

} // namespace

BillingProjector::BillingProjector() = default;

BillingProjector::Summary
BillingProjector::run(int horizonDays, int backfillDays) {
    Summary s;

    auto* db = Database::getInstance();

    // ── 1. Advisory lock so two runs can't race.  Uses a session-level
    //       (not transaction-level) lock via pg_try_advisory_lock, and we
    //       explicitly release it before returning.  If we can't get it,
    //       another projector run is already in flight; report and bail.
    {
        auto lockRes = db->query(
            "SELECT pg_try_advisory_lock($1::bigint) AS locked",
            {std::to_string(kLockKey)});
        const bool locked = !lockRes.empty()
                            && !lockRes[0]["locked"].is_null()
                            && lockRes[0]["locked"].as<bool>();
        if (!locked) {
            s.didRun     = false;
            s.skipReason = "another projector run is already in flight";
            return s;
        }
    }

    try {
        // ── 2. Window bounds.  Compute in America/NY so "today" matches
        //        what an operator sees in the UI, even if the DB server
        //        is running in UTC.  We hand these back to the caller as
        //        plain YYYY-MM-DD strings for logging.
        std::string todayIso;
        std::string startIso;
        std::string endIso;
        {
            auto res = db->query(
                "SELECT "
                "  TO_CHAR((now() AT TIME ZONE 'America/New_York')::date, 'YYYY-MM-DD') AS today, "
                "  TO_CHAR(((now() AT TIME ZONE 'America/New_York')::date - ($1::int * INTERVAL '1 day'))::date, 'YYYY-MM-DD') AS start, "
                "  TO_CHAR(((now() AT TIME ZONE 'America/New_York')::date + ($2::int * INTERVAL '1 day'))::date, 'YYYY-MM-DD') AS finish",
                {std::to_string(backfillDays), std::to_string(horizonDays)});
            todayIso = res[0]["today" ].c_str();
            startIso = res[0]["start" ].c_str();
            endIso   = res[0]["finish"].c_str();
        }
        s.horizonStart = startIso;
        s.horizonEnd   = endIso;

        // ── 3. Count active members for the summary.
        {
            auto res = db->query(
                "SELECT COUNT(*)::int AS n "
                "  FROM person_la_memberships plm "
                "  JOIN external_person_aliases epa "
                "    ON epa.person_id = plm.person_id "
                "   AND epa.provider  = 'leagueapps' "
                " WHERE plm.ended_at IS NULL "
                "   AND epa.external_user_id ~ '^\\d+$'");
            s.activeMembers = res.empty() ? 0 : res[0]["n"].as<int>();
        }

        // ── 4. Project.
        s.monthlyInserted = projectMonthly(startIso, endIso);
        s.prorateInserted = projectProrate(startIso, endIso);

        // ── 5. Timestamp the run for the response.
        {
            auto res = db->query(
                "SELECT TO_CHAR(now() AT TIME ZONE 'UTC', "
                "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS ts");
            s.ranAt = res[0]["ts"].c_str();
        }

        s.didRun = true;
    } catch (const std::exception& e) {
        std::cerr << "[BillingProjector::run] " << e.what() << std::endl;
        s.didRun     = false;
        s.skipReason = std::string("exception: ") + e.what();
    }

    // Always release the lock even if a step threw.
    try {
        db->query("SELECT pg_advisory_unlock($1::bigint)",
                  {std::to_string(kLockKey)});
    } catch (const std::exception& e) {
        std::cerr << "[BillingProjector::run] unlock failed: "
                  << e.what() << std::endl;
    }

    return s;
}

// ────────────────────────────────────────────────────────────────────────────
// projectMonthly — one $35 line per active member per 1st-Friday-of-month
//                  in the horizon that is on-or-after the member's LA
//                  registration date (or unconditional when the reg date
//                  is NULL — "established fallback").
//
// The whole thing runs in one SQL statement so it's an atomic write and
// the round-trip cost is one query per projector run, regardless of
// active-member count.
// ────────────────────────────────────────────────────────────────────────────
int BillingProjector::projectMonthly(const std::string& startIso,
                                     const std::string& endIso) {
    auto* db = Database::getInstance();

    const std::string sql =
        "WITH fridays AS ( "
        "  SELECT d::date AS friday "
        "    FROM generate_series($1::date, $2::date, '1 day'::interval) AS gs(d) "
        "   WHERE EXTRACT(dow FROM d) = 5 "
        "     AND EXTRACT(day FROM d) <= 7 "
        "), "
        "active AS ( "
        "  SELECT plm.la_program_id, "
        "         plm.la_registered_at, "
        "         (epa.external_user_id)::bigint AS leagueapps_user_id "
        "    FROM person_la_memberships plm "
        "    JOIN external_person_aliases epa "
        "      ON epa.person_id = plm.person_id "
        "     AND epa.provider  = 'leagueapps' "
        "   WHERE plm.ended_at IS NULL "
        "     AND epa.external_user_id ~ '^\\d+$' "
        "), "
        "ins AS ( "
        "  INSERT INTO billing_expectations "
        "      (leagueapps_user_id, la_program_id, charge_date, kind, expected_amount) "
        "  SELECT a.leagueapps_user_id, a.la_program_id, f.friday, 'monthly', 35.00 "
        "    FROM active a "
        "    CROSS JOIN fridays f "
        "   WHERE a.la_registered_at IS NULL "
        "      OR (a.la_registered_at AT TIME ZONE 'America/New_York')::date <= f.friday "
        "  ON CONFLICT (leagueapps_user_id, la_program_id, charge_date) DO UPDATE "
        "     SET kind            = EXCLUDED.kind, "
        "         expected_amount = EXCLUDED.expected_amount "
        "  RETURNING (xmax = 0) AS was_inserted "
        ") "
        "SELECT was_inserted FROM ins";

    const auto res = db->query(sql, {startIso, endIso});
    return countTaggedInserts(res);
}

// ────────────────────────────────────────────────────────────────────────────
// projectProrate — $8.75 lines on every Friday strictly between the
//                  member's registration date and F1, skipping if the gap
//                  (F1 - R) is ≤ 5 days.  Only fires for members whose
//                  `la_registered_at` is populated — established members
//                  (NULL) never generate pro-rate lines.
//
// F1 is computed per-member with a lateral subquery.  In practice F1 is
// always within 7 days of `la_registered_at` so the sub-query is cheap.
// ────────────────────────────────────────────────────────────────────────────
int BillingProjector::projectProrate(const std::string& startIso,
                                     const std::string& endIso) {
    auto* db = Database::getInstance();

    const std::string sql =
        "WITH fridays AS ( "
        "  SELECT d::date AS friday "
        "    FROM generate_series($1::date, $2::date, '1 day'::interval) AS gs(d) "
        "   WHERE EXTRACT(dow FROM d) = 5 "
        "), "
        "active AS ( "
        "  SELECT plm.la_program_id, "
        "         (plm.la_registered_at AT TIME ZONE 'America/New_York')::date AS reg_date, "
        "         (epa.external_user_id)::bigint AS leagueapps_user_id "
        "    FROM person_la_memberships plm "
        "    JOIN external_person_aliases epa "
        "      ON epa.person_id = plm.person_id "
        "     AND epa.provider  = 'leagueapps' "
        "   WHERE plm.ended_at IS NULL "
        "     AND plm.la_registered_at IS NOT NULL "
        "     AND epa.external_user_id ~ '^\\d+$' "
        "), "
        "active_f1 AS ( "
        "  SELECT a.*, "
        "         ( SELECT gs.d::date "
        "             FROM generate_series(a.reg_date, "
        "                                  a.reg_date + INTERVAL '40 days', "
        "                                  '1 day'::interval) AS gs(d) "
        "            WHERE EXTRACT(dow FROM gs.d) = 5 "
        "              AND EXTRACT(day FROM gs.d) <= 7 "
        "              AND gs.d::date >= a.reg_date "
        "            ORDER BY gs.d "
        "            LIMIT 1 "
        "         ) AS f1 "
        "    FROM active a "
        "), "
        "ins AS ( "
        "  INSERT INTO billing_expectations "
        "      (leagueapps_user_id, la_program_id, charge_date, kind, expected_amount) "
        "  SELECT a.leagueapps_user_id, a.la_program_id, f.friday, 'prorate', 8.75 "
        "    FROM active_f1 a "
        "    CROSS JOIN fridays f "
        "   WHERE a.f1 IS NOT NULL "
        "     AND (a.f1 - a.reg_date) > 5 "
        "     AND f.friday >  a.reg_date "
        "     AND f.friday <  a.f1 "
        "  ON CONFLICT (leagueapps_user_id, la_program_id, charge_date) DO UPDATE "
        "     SET kind            = EXCLUDED.kind, "
        "         expected_amount = EXCLUDED.expected_amount "
        "  RETURNING (xmax = 0) AS was_inserted "
        ") "
        "SELECT was_inserted FROM ins";

    const auto res = db->query(sql, {startIso, endIso});
    return countTaggedInserts(res);
}
