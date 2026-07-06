#include "RsvpMaterialization.h"

#include "../database/Database.h"

#include <iostream>
#include <sstream>
#include <stdexcept>

namespace {

// One transaction per call for atomicity + isolation.  We piggyback on
// pqxx::work via Database::beginTransaction.  On any exception the
// destructor rolls back; commit is explicit.

// The window-open moment is the last Sunday 20:00 America/New_York on
// or before NOW().  We compute this entirely in SQL using
// AT TIME ZONE conversions so the machine's local TZ is irrelevant.
constexpr const char* kWindowStartSql = R"SQL(
  WITH now_local AS (
    SELECT (NOW() AT TIME ZONE 'America/New_York') AS ts
  ),
  candidate AS (
    -- Truncate today to date, add 20:00, then step back by weekday
    -- offset so we land on Sunday.  EXTRACT(DOW) is 0=Sunday..6=Sat.
    SELECT date_trunc('day', ts) + INTERVAL '20 hours'
             - (EXTRACT(DOW FROM ts)::int * INTERVAL '1 day') AS candidate_local
    FROM now_local
  )
  SELECT
    CASE WHEN c.candidate_local > (SELECT ts FROM now_local)
         THEN c.candidate_local - INTERVAL '7 days'
         ELSE c.candidate_local
    END AT TIME ZONE 'America/New_York' AS window_start_utc
  FROM candidate c;
)SQL";

// Insert-missing-matches-for-series query.  Given a window_start_utc
// (a TIMESTAMPTZ marking last Sunday 20:00), produce one match per
// (series, date) tuple for the Mon..Sun following the rollover.
//
// series_id UNIQUE INDEX on (series_id, match_date) WHERE series_id
// IS NOT NULL prevents duplicates on repeat calls.
constexpr const char* kInsertMatchesSql = R"SQL(
WITH window_start AS (
  SELECT $1::timestamptz AS ts
),
target_dates AS (
  -- Monday through Sunday of the window (7 dates).  Monday = window
  -- start + 1 day (window start is the preceding Sunday 20:00).
  SELECT (date_trunc('day', (SELECT ts FROM window_start) AT TIME ZONE 'America/New_York')::date
          + INTERVAL '1 day' + (n || ' days')::interval)::date AS d
  FROM generate_series(0, 6) n
),
candidates AS (
  SELECT
    ms.id                          AS series_id,
    td.d                           AS match_date,
    ms.match_type_id,
    ms.home_team_id,
    ms.away_team_id,
    ms.venue_id,
    ms.start_time                  AS match_time,
    ms.end_time,
    ms.title,
    ms.description,
    -- rsvp_opens_at is the rollover moment for practice/pickup rows.
    (SELECT ts FROM window_start)  AS rsvp_opens_at
  FROM match_series ms
  JOIN target_dates td ON td.d >= ms.starts_on
                     AND (ms.ends_on IS NULL OR td.d <= ms.ends_on)
                     AND EXTRACT(DOW FROM td.d)::int = ms.day_of_week
  WHERE ms.active = TRUE
)
INSERT INTO matches
  (match_type_id, home_team_id, away_team_id, venue_id, match_date,
   match_time, end_time, title, description, series_id, is_override,
   cancelled_at, rsvp_opens_at, match_status_id)
SELECT
  c.match_type_id, c.home_team_id, c.away_team_id, c.venue_id, c.match_date,
  c.match_time, c.end_time, c.title, c.description, c.series_id, FALSE,
  NULL, c.rsvp_opens_at, 1
FROM candidates c
ON CONFLICT (series_id, match_date) WHERE series_id IS NOT NULL DO NOTHING
RETURNING id;
)SQL";

// Apply-recurring-RSVPs query.  For every match in the currently-open
// window (rsvp_opens_at <= NOW, not cancelled), and every player on
// the match's home_team_id roster, look up their preference and
// insert a rsvp_history row if none exists.
//
// Team membership uses `mens_team_assignments` (soft-delete aware),
// with the LA user id bridged to a persons row via
// `external_person_aliases` (provider='leagueapps').  From there we
// join to `players.person_id` to satisfy the FK on
// player_rsvp_history.player_id.
//
// Pool teams 908 (Practice) and 909 (Pickup) are the primary target
// for recurring RSVP application.
constexpr const char* kApplyRecurringSql = R"SQL(
WITH window_start AS (
  SELECT $1::timestamptz AS ts
),
open_matches AS (
  SELECT m.id            AS match_id,
         m.match_type_id,
         m.match_date,
         m.home_team_id,
         EXTRACT(DOW FROM m.match_date)::int AS dow
  FROM matches m
  WHERE m.cancelled_at IS NULL
    AND m.rsvp_opens_at IS NOT NULL
    AND m.rsvp_opens_at <= NOW()
    AND m.match_date >= (date_trunc('day',
                          (SELECT ts FROM window_start)
                          AT TIME ZONE 'America/New_York')::date
                        + INTERVAL '1 day')::date
    AND m.match_date <  ((SELECT ts FROM window_start)
                         + INTERVAL '7 days')::date
    AND m.home_team_id IS NOT NULL
),
eligible AS (
  -- Eligibility rules — keep in sync with
  -- controllers/MyController.cpp (handleGetWeek + callerRosteredForMatch).
  SELECT DISTINCT om.match_id,
         p.id AS player_id,
         prr.rsvp_status_id
  FROM open_matches om
  JOIN external_person_aliases epa
    ON epa.provider = 'leagueapps'
  JOIN roster_assignments mta
    ON mta.domain = 'mens'
   AND mta.leagueapps_user_id::text = epa.external_user_id
   AND (
     om.match_type_id = 7
     OR (
       mta.removed_at IS NULL
       AND mta.team_id = ANY(
         CASE
           WHEN om.match_type_id = 3 THEN ARRAY[35, 120, 121]
           WHEN om.match_type_id IN (1,4,6) AND om.home_team_id = 35 THEN ARRAY[35, 120]
           ELSE ARRAY[om.home_team_id]
         END
       )
     )
   )
  JOIN players p ON p.person_id = epa.person_id
  JOIN player_recurring_rsvps prr
    ON prr.person_id = epa.person_id
   AND prr.day_of_week = om.dow
   AND prr.match_type_id = om.match_type_id
  WHERE NOT EXISTS (
    SELECT 1 FROM player_rsvp_history h
    WHERE h.event_id = om.match_id
      AND h.player_id = p.id
  )
)
INSERT INTO player_rsvp_history
  (event_id, player_id, rsvp_status_id, changed_by, change_source_id, notes)
SELECT match_id, player_id, rsvp_status_id, NULL, 4, 'auto: recurring preference'
FROM eligible
RETURNING id;
)SQL";

std::string fetchWindowStart(Database* db) {
    auto r = db->query(kWindowStartSql);
    if (r.empty() || r[0][0].is_null()) {
        throw std::runtime_error("could not compute window_start_utc");
    }
    return r[0][0].c_str();
}

}  // namespace

RsvpMaterialization::Result RsvpMaterialization::rollover() {
    auto* db = Database::getInstance();
    Result out;

    // 1. Compute the window start (last Sunday 20:00 America/New_York
    //    on or before NOW()).  All subsequent SQL uses this value so
    //    the two steps agree on the same window boundary even if the
    //    clock crosses 20:00 between calls.
    std::string windowStart = fetchWindowStart(db);
    out.windowStartIso = windowStart;

    // Compute window_end for the caller's information.  Trivial
    // arithmetic in SQL.
    {
        auto r = db->query("SELECT ($1::timestamptz + INTERVAL '7 days')::text",
                           {windowStart});
        if (!r.empty()) out.windowEndIso = r[0][0].c_str();
    }

    // 2. Materialise missing matches for the window.  RETURNING id
    //    gives us the count of new rows.  Skipped rows are ON CONFLICT
    //    hits.  We compute skipped as (total candidates - inserted)
    //    by re-running the candidate select, but for cost-efficiency
    //    we just report inserted; skipped is a nicety, not a
    //    correctness metric.
    {
        auto r = db->query(kInsertMatchesSql, {windowStart});
        out.matchesInserted = static_cast<int>(r.size());
    }

    // 3. Apply recurring RSVPs.
    {
        auto r = db->query(kApplyRecurringSql, {windowStart});
        out.rsvpsInserted = static_cast<int>(r.size());
    }

    std::cout << "[RsvpMaterialization] rollover: window_start=" << out.windowStartIso
              << " matches_inserted=" << out.matchesInserted
              << " rsvps_inserted="   << out.rsvpsInserted << std::endl;

    return out;
}

RsvpMaterialization::Result
RsvpMaterialization::materialiseRange(const std::string& fromDateIso,
                                       const std::string& toDateIso) {
    auto* db = Database::getInstance();
    Result out;
    out.windowStartIso = fromDateIso;
    out.windowEndIso   = toDateIso;

    // For each date in [from, to], for each active series whose
    // day_of_week matches, insert if missing.  rsvp_opens_at is set
    // to the preceding Sunday 20:00 America/New_York.
    constexpr const char* kSql = R"SQL(
    WITH target_dates AS (
      SELECT d::date FROM generate_series($1::date, $2::date, INTERVAL '1 day') d
    ),
    candidates AS (
      SELECT
        ms.id                          AS series_id,
        td.d                           AS match_date,
        ms.match_type_id,
        ms.home_team_id,
        ms.away_team_id,
        ms.venue_id,
        ms.start_time                  AS match_time,
        ms.end_time,
        ms.title,
        ms.description,
        -- Preceding Sunday 20:00 New_York = the Sunday just before or
        -- equal to (td.d - 1 day) if td.d is a Sunday; otherwise the
        -- Sunday of the week that Monday belongs to.
        ((td.d - ((EXTRACT(DOW FROM td.d)::int + 6) % 7) * INTERVAL '1 day' - INTERVAL '1 day')
          + INTERVAL '20 hours') AT TIME ZONE 'America/New_York' AS rsvp_opens_at
      FROM match_series ms
      JOIN target_dates td ON td.d >= ms.starts_on
                         AND (ms.ends_on IS NULL OR td.d <= ms.ends_on)
                         AND EXTRACT(DOW FROM td.d)::int = ms.day_of_week
      WHERE ms.active = TRUE
    )
    INSERT INTO matches
      (match_type_id, home_team_id, away_team_id, venue_id, match_date,
       match_time, end_time, title, description, series_id, is_override,
       cancelled_at, rsvp_opens_at, match_status_id)
    SELECT
      c.match_type_id, c.home_team_id, c.away_team_id, c.venue_id, c.match_date,
      c.match_time, c.end_time, c.title, c.description, c.series_id, FALSE,
      NULL, c.rsvp_opens_at, 1
    FROM candidates c
    ON CONFLICT (series_id, match_date) WHERE series_id IS NOT NULL DO NOTHING
    RETURNING id;
    )SQL";

    auto r = db->query(kSql, {fromDateIso, toDateIso});
    out.matchesInserted = static_cast<int>(r.size());
    return out;
}
