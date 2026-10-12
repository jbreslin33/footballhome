-- 568 (2026-10-12) — the submitted USASA Amateur Cup squad is invited to
-- the Sun 2026-10-18 12:00 cup tie at Phoenix SCM.
-- Owner: "i submitted the roster you have access to it. we should only be
-- allowing those players to rsvp to it … 12pm kickoff sunday oct 18th …
-- its away."
--
-- Run AFTER the gcal event has synced and classified (the cup team of
-- mig 567 carries no players, so these invite rows are the only way the
-- game reaches anyone).  Idempotent: inserts nothing until the fh_events
-- row exists, and never duplicates an open invite — re-run `make migrate`
-- once the event is on the calendar if this applied too early.

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, invited_by_user_id, note)
SELECT e.id, crp.person_id,
       (SELECT id FROM teams WHERE club_id = 134 AND name = 'USASA Cup'),
       (SELECT id FROM users WHERE person_id = 1),
       'USASA Amateur Cup squad (sheet 2026-10-11, mig 568)'
  FROM fh_events e
  JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL
  CROSS JOIN cup_roster_players crp
 WHERE crp.cup_roster_id = 2
   AND e.kind = 'match'
   AND e.league ILIKE '%usasa%'
   AND (g.starts_at AT TIME ZONE 'America/New_York')::date = '2026-10-18'
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = e.id AND i.person_id = crp.person_id AND i.revoked_at IS NULL);
