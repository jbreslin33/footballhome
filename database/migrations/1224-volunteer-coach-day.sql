-- 1224: 🙋 An approved volunteer's evening shows on #my under 📋 Coach
-- (owner 2026-11-10: "tell them once approved for a day of volunteering
-- that it will show up in their fh home page under the coach tab so they
-- will have a coach and player role right? is that how we do it?" → yes,
-- the coach schedule; "Every youth team that day").
--
-- The Mon / Wed / Fri 5–7 PM shifts are youth practice time.  Approving a
-- pick (VolunteerShifts::decide) now also makes him an assistant coach on
-- every active team of the section the shift helps (volunteer_shifts
-- .helps_section_id — Boys, where the girls play too) with a coach
-- schedule of just his day, so #my shows those practices under 📋 Coach
-- and his own men's events under ⚽ Player.
--
--  * coach_schedules.practices_only: games are off for this coach too —
--    the coach schedule only ever filtered practices ("games never
--    change", mig 955), which would have put every youth game on a
--    volunteer's page.  fh_coach_off_schedule now answers true for a
--    non-practice event when the flag is on; every caller already asks it
--    per event (RsvpBoard's practice-only guard is dropped in code).
--  * Copy: the commitment, the pending and the approved lines say where
--    the day will show.

BEGIN;

ALTER TABLE coach_schedules ADD COLUMN IF NOT EXISTS practices_only boolean NOT NULL DEFAULT false;

ALTER TABLE volunteer_shifts ADD COLUMN IF NOT EXISTS helps_section_id integer REFERENCES club_sections(id);
UPDATE volunteer_shifts SET helps_section_id = (SELECT id FROM club_sections WHERE name = 'Boys')
 WHERE helps_section_id IS NULL;
ALTER TABLE volunteer_shifts ALTER COLUMN helps_section_id SET NOT NULL;

CREATE OR REPLACE FUNCTION public.fh_coach_off_schedule(p_person_id integer, p_team_id integer, p_fh_event_id bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT EXISTS (
    SELECT 1
      FROM coach_schedules s
      JOIN coaches c ON c.id = s.coach_id AND c.person_id = p_person_id
      JOIN teams t ON t.id = p_team_id AND t.club_section_id = s.club_section_id
      JOIN fh_events fe ON fe.id = p_fh_event_id
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE ge.starts_at >= s.starts_at
       AND CASE WHEN fe.kind = 'practice'
                THEN NOT EXISTS (SELECT 1 FROM coach_schedule_days d
                                  WHERE d.coach_schedule_id = s.id
                                    AND d.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int)
                ELSE s.practices_only END)   -- mig 1224: a volunteer's schedule is practices only
$function$;

UPDATE message_templates SET body =
  'You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once the club approves your day, it shows on your Football Home page under 📋 Coach — you''ll RSVP to those practices like any coach. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'You picked {shift}, every week. Once the club approves it, it shows on this page under 📋 Coach — until then your dues still stand.'
 WHERE kind = 'volunteer_shift' AND tier = 'pending';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift}, every week — your practices are on this page under 📋 Coach. Be there on time, and let us know ahead of time if you can''t make it.'
 WHERE kind = 'volunteer_shift' AND tier = 'approved';

COMMIT;
