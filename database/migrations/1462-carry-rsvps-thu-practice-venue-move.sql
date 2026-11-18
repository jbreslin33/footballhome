-- 1462 (2026-11-18) — Thursday 11/19 7:00–8:30 PM men's/U15–U16 practice:
-- carry its RSVPs onto the re-made event (owner "since its same time as the
-- original we need to transfer the rsvps right?").
--
-- The venue was changed in Google (Erie Ave → 141 W Somerset St, ~1.5 mi)
-- together with the title ("Soccer Sport Court Practice u17+ Winter" →
-- "Soccer Practice u15+ Winter").  Google split the series: old event
-- 75810452 cancelled 08:10 ET with 36 answers (14 yes / 22 no), new event
-- 75821984 started empty.  gcal-classify's split carry-forward did not fire
-- because it needs the same title AND location.  Same day, same start and
-- end, and the old teams are a subset of the new ones (Men's 1893, Liga 1,
-- U16; the new one adds U15).  Only 11/19 of that series had answers.
--
-- ON CONFLICT DO NOTHING: anyone who already answered the new event
-- (1 person, 09:05 ET) keeps that newer answer.  First-answer times first
-- (mig 507), as Pass C does.
BEGIN;

INSERT INTO fh_event_rsvp_first_answers (fh_event_id, person_id, first_responded_at)
SELECT 75821984, f.person_id, f.first_responded_at
  FROM fh_event_rsvp_first_answers f
 WHERE f.fh_event_id = 75810452
ON CONFLICT (fh_event_id, person_id) DO NOTHING;

INSERT INTO fh_event_rsvps (fh_event_id, person_id, response, responded_at, created_via,
                            arrive_at, leave_at, role_choice, answered_by_person_id)
SELECT 75821984, r.person_id, r.response, r.responded_at, r.created_via,
       r.arrive_at, r.leave_at, r.role_choice, r.answered_by_person_id
  FROM fh_event_rsvps r
 WHERE r.fh_event_id = 75810452
ON CONFLICT (fh_event_id, person_id) DO NOTHING;

COMMIT;
