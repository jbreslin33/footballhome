-- 563 (2026-10-11) — Gian Maldonado excused for the week of the 10/11 APSL
-- game: away at trials in Germany.
--
-- Owner: "gian is absolved due to trip to trials in germany."
--
-- The mechanism is the existing 'excused' attendance status: this row set
-- marks him excused at every practice of the game week he has no attendance
-- for (he RSVP'd no to all of them), and from this deploy the backend
-- counts 'excused' toward the starter practice criterion — for everyone,
-- so the next absolution is a coach marking Excused on #attendance, no
-- migration needed.  Excused stays OUT of fines (mig 460 already treats it
-- as not-a-no-show), attendance reports, and the payments activity trail.
--
-- Gian = person 14454 (team 35, APSL).  The game's counted practices come
-- from fh_starter_window at run time (the week rule, mig 562).

INSERT INTO fh_event_attendance (fh_event_id, person_id, status)
SELECT w.fh_event_id, 14454, 'excused'
  FROM fh_events fe
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id,
       LATERAL fh_starter_window('{35,938}'::int[], ge.starts_at, fe.match_id) w
 WHERE fe.match_id = 9324
   AND w.starts_at < now()
ON CONFLICT (fh_event_id, person_id) DO NOTHING;
