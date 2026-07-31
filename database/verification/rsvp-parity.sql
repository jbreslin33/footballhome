-- ─────────────────────────────────────────────────────────────────────
-- rsvp-parity.sql — the "no disruption" gate for the group-model
-- migration (ADR 2026-07-30, Cutover verification section).
--
-- For every involved person × every non-cancelled event in the next
-- 30 days, computes RSVP eligibility BOTH ways:
--   old — the current CalendarController logic:
--         admin OR, over the event's fh_event_teams:
--         player_rsvp_eligibility (via LA alias) OR active team_coaches
--   new — the group model:
--         admin OR, over the event's fh_event_teams:
--         active team_persons membership OR active team_coaches,
--         minus active rsvp_suspensions
--
-- Prints per-row diffs, then a summary.  Expected diffs (per ADR):
--   (a) cross-team hand grants on events whose gcal description does
--       not (yet) tag the matching reserves group;
--   (b) stale grants for lapsed members (eligibility never cleaned up)
--       which the backfill deliberately does not carry.
-- Anything outside those two buckets blocks the Phase 2 cutover.
--
-- Run:  psql < database/verification/rsvp-parity.sql
-- ─────────────────────────────────────────────────────────────────────

WITH events AS (
    SELECT fe.id AS fh_event_id, ge.summary, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE ge.deleted_at IS NULL
       AND ge.status <> 'cancelled'
       AND ge.starts_at >= now()
       AND ge.starts_at <  now() + interval '30 days'
),
involved AS (                    -- anyone either model could deem eligible
    SELECT DISTINCT epa.person_id
      FROM player_rsvp_eligibility ple
      JOIN external_person_aliases epa
        ON epa.provider = 'leagueapps'
       AND epa.external_user_id = ple.leagueapps_user_id::text
    UNION
    SELECT DISTINCT person_id FROM team_persons WHERE removed_at IS NULL
    UNION
    SELECT DISTINCT co.person_id
      FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
     WHERE tc.ended_at IS NULL
    UNION
    SELECT DISTINCT u.person_id
      FROM admins a JOIN users u ON u.id = a.user_id
     WHERE u.person_id IS NOT NULL
),
pairs AS (
    SELECT e.fh_event_id, e.summary, e.starts_at, i.person_id,
        EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id
                 WHERE u.person_id = i.person_id)                     AS is_admin,
        EXISTS (SELECT 1
                  FROM fh_event_teams fet
                 WHERE fet.fh_event_id = e.fh_event_id
                   AND (EXISTS (SELECT 1
                                  FROM player_rsvp_eligibility ple
                                  JOIN external_person_aliases epa
                                    ON epa.provider = 'leagueapps'
                                   AND epa.external_user_id = ple.leagueapps_user_id::text
                                 WHERE ple.team_id = fet.team_id
                                   AND epa.person_id = i.person_id)
                     OR EXISTS (SELECT 1
                                  FROM team_coaches tc
                                  JOIN coaches co ON co.id = tc.coach_id
                                 WHERE tc.team_id = fet.team_id
                                   AND tc.ended_at IS NULL
                                   AND co.person_id = i.person_id)))  AS old_team_path,
        EXISTS (SELECT 1
                  FROM fh_event_teams fet
                 WHERE fet.fh_event_id = e.fh_event_id
                   AND (EXISTS (SELECT 1 FROM team_persons tp
                                 WHERE tp.team_id = fet.team_id
                                   AND tp.person_id = i.person_id
                                   AND tp.removed_at IS NULL)
                     OR EXISTS (SELECT 1
                                  FROM team_coaches tc
                                  JOIN coaches co ON co.id = tc.coach_id
                                 WHERE tc.team_id = fet.team_id
                                   AND tc.ended_at IS NULL
                                   AND co.person_id = i.person_id)))  AS new_team_path,
        EXISTS (SELECT 1 FROM rsvp_suspensions s
                 WHERE s.person_id = i.person_id
                   AND s.starts_at <= e.starts_at
                   AND (s.ends_at IS NULL OR s.ends_at > e.starts_at)
                   AND (s.team_id IS NULL
                        OR s.team_id IN (SELECT team_id FROM fh_event_teams
                                          WHERE fh_event_id = e.fh_event_id))) AS suspended
      FROM events e CROSS JOIN involved i
),
graded AS (
    SELECT *,
           (is_admin OR old_team_path)                        AS old_eligible,
           (is_admin OR (new_team_path AND NOT suspended))    AS new_eligible
      FROM pairs
)
SELECT g.fh_event_id, left(g.summary, 40) AS event, g.starts_at::date AS date,
       g.person_id,
       (SELECT p.first_name || ' ' || p.last_name
          FROM persons p WHERE p.id = g.person_id)  AS person,
       g.old_eligible, g.new_eligible,
       CASE
         WHEN g.old_eligible AND NOT g.new_eligible THEN 'LOST'
         WHEN g.new_eligible AND NOT g.old_eligible THEN 'GAINED'
       END AS change
  FROM graded g
 WHERE g.old_eligible <> g.new_eligible
 ORDER BY g.starts_at, g.fh_event_id, g.person_id;

-- Summary
WITH events AS (
    SELECT fe.id AS fh_event_id, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE ge.deleted_at IS NULL
       AND ge.status <> 'cancelled'
       AND ge.starts_at >= now()
       AND ge.starts_at <  now() + interval '30 days'
)
SELECT (SELECT count(*) FROM events) AS events_in_window;
