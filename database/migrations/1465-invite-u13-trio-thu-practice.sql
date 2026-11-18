-- 1465 (2026-11-18) — Thursday 11/19 7:00 PM practice (fh_event 75821984,
-- U15+ / men): add the three U13 players whose parents said "going" to the
-- 5:30 U13–U16 practice that the venue edit cancelled (old event 75814969,
-- see mig 1462).  Owner: "don't move them over i think they might get
-- confused … put them as unanswered".  So: invited (🎟, from U13), NO RSVP
-- row → they sit in the event's No response group and get the normal
-- reminder.  Their old "yes" stays on the cancelled event.
-- recipient = the parent who answered for them (answered_by_person_id).
BEGIN;

INSERT INTO event_person_sees (fh_event_id, person_id, sees, from_team_id, recipient_person_id, set_by_user_id, note)
SELECT 75821984, r.person_id, true, 947, r.answered_by_person_id, 1,
       'U13 from the cancelled 5:30 practice (mig 1465)'
  FROM fh_event_rsvps r
 WHERE r.fh_event_id = 75814969
   AND r.person_id IN (22465, 22664, 22690)
ON CONFLICT (fh_event_id, person_id) DO NOTHING;

COMMIT;
