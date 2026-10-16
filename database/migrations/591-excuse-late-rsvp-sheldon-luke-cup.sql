-- 591 (2026-10-16) — Excuse the late game RSVPs of Sheldon Rhoden and
-- Luke Breslin for Sunday's USASA Cup game.
--
-- Owner: "change late rsvp flag for sheldon and luke".
--
-- Both answered Going for the Sun Oct 18 cup game (fh_event 75714620) on
-- Fri Oct 16, after the Thu Oct 15 midnight deadline (mig 507), so the
-- starter rule (mig 508) read them as "Game RSVP late · ineligible".
-- The on-time fact is fh_event_rsvp_first_answers.first_responded_at vs
-- fh_rsvp_deadline(); backdating their first answer to one minute before
-- the deadline makes them "answered on time" for this one game and
-- touches nothing else.  Their actual answers (yes) are untouched.

UPDATE fh_event_rsvp_first_answers fa
   SET first_responded_at = fh_rsvp_deadline(fa.fh_event_id) - interval '1 minute'
 WHERE fa.fh_event_id = 75714620
   AND fa.person_id IN (3463, 22433)   -- Luke Breslin, Sheldon Rhoden
   AND fa.first_responded_at >= fh_rsvp_deadline(fa.fh_event_id);
