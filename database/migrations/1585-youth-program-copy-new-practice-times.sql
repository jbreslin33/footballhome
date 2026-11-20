-- 1585 — youth LA description: the new practice times, and no season on
-- the travel squads.
--
-- Owner 2026-11-19: "we need a new la descrripoton for youth since we
-- changed practice times" + "its not birth year. its close to school year"
-- + "dont say any season".
--
-- Practice = what the calendar runs now: Mon/Wed/Fri at the Community
-- Center in three age groups (U5–U8 4:00–4:45, U9–U10 4:45–5:45,
-- U11–U15 5:45–7:00) and U16 with the men 7:00–8:45.  Ages are written as
-- school grades: the FH age chart is US Club Soccer Aug 1 – Jul 31
-- (mig 1044), which tracks the school year, so U8 ≈ 2nd grade.
-- The Teams block loses "(Fall 2026)".

UPDATE message_templates
   SET body = E'- **Practice — Mondays, Wednesdays & Fridays:**\n'
              '  - Pre-K through 2nd grade (U5–U8) — 4:00–4:45pm\n'
              '  - 3rd & 4th grade (U9–U10) — 4:45–5:45pm\n'
              '  - 5th through 9th grade (U11–U15) — 5:45–7:00pm\n'
              '  - 10th grade (U16) — trains with our Men''s Club, 7:00–8:45pm\n'
              '- **Why multiple days:** We know families are busy, so we offer practice three days a week — the goal is that every player can make at least one. There''s no requirement to attend all of them; come to as many as work for your schedule.',
       updated_at = now()
 WHERE kind = 'program_schedule' AND tier = 'youth';

UPDATE message_templates
   SET body = replace(body,
                      'we also field select travel squads (Fall 2026):',
                      'we also field select travel squads:'),
       updated_at = now()
 WHERE kind = 'program_teams' AND tier = 'youth';
