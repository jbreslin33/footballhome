-- 508 (2026-10-01) — A late game RSVP costs the start for Men only.
--
-- Owner, after mig 507 put the rule on every section: "only have this for
-- men. not pertinent for youth because roster too small".
--
-- The deadline itself stays club-wide ("this is for youth or adult") and
-- every reminder still states it; what becomes a Men's-section fact is the
-- consequence.  rsvp_deadline_policies gains late_blocks_start: the
-- club-wide row keeps it off, a Men's row turns it on.  Where it is off the
-- reminder prints the deadline without the "eligible to start" words and
-- Game Center shows no Game RSVP criterion.

ALTER TABLE rsvp_deadline_policies
  ADD COLUMN IF NOT EXISTS late_blocks_start boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN rsvp_deadline_policies.late_blocks_start IS
  'mig 508: true = a game RSVP not in by the deadline makes the player ineligible to start (Game Center''s second criterion). false = the deadline is only stated in reminders.';

INSERT INTO rsvp_deadline_policies (club_id, club_section_id, days_before_game, effective_from, late_blocks_start)
SELECT 134, cs.id, 3, DATE '2026-10-04', true
  FROM club_sections cs
 WHERE cs.code = 'M'
   AND NOT EXISTS (SELECT 1 FROM rsvp_deadline_policies p WHERE p.club_id = 134 AND p.club_section_id = cs.id);

-- The deadline and its consequence for one game.  No row when the event is
-- not a game, no policy covers it, or the deadline would fall before that
-- week's RSVPs open (see mig 507).
CREATE OR REPLACE FUNCTION fh_rsvp_deadline_info(p_fh_event_id bigint)
RETURNS TABLE (deadline timestamptz, blocks_start boolean) LANGUAGE sql STABLE AS $$
  WITH ev AS (
    SELECT fe.id, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE fe.id = p_fh_event_id AND fe.kind = 'match'
  ), pol AS (
    SELECT p.days_before_game, p.time_zone, p.late_blocks_start, t.club_id, t.club_section_id
      FROM ev
      JOIN fh_event_teams fet ON fet.fh_event_id = ev.id
      JOIN teams t ON t.id = fet.team_id
      JOIN rsvp_deadline_policies p
        ON p.club_id = t.club_id
       AND (p.club_section_id IS NULL OR p.club_section_id = t.club_section_id)
       AND p.effective_from <= (ev.starts_at AT TIME ZONE p.time_zone)::date
     ORDER BY (p.club_section_id IS NOT NULL) DESC, p.effective_from DESC, p.id DESC
     LIMIT 1
  ), d AS (
    SELECT (((ev.starts_at AT TIME ZONE pol.time_zone)::date - pol.days_before_game + 1)::timestamp
              AT TIME ZONE pol.time_zone) AS deadline,
           pol.late_blocks_start,
           fh_schedule_week_opens_at(pol.club_id, pol.club_section_id,
                                     fh_week_start(ev.starts_at, pol.time_zone)) AS opens
      FROM ev, pol
  )
  SELECT d.deadline, d.late_blocks_start FROM d WHERE d.opens IS NULL OR d.opens < d.deadline
$$;
COMMENT ON FUNCTION fh_rsvp_deadline_info(bigint) IS
  'A game''s RSVP deadline (start of the day after the deadline day) and whether missing it costs the start (mig 507/508). No row = no deadline applies.';

CREATE OR REPLACE FUNCTION fh_rsvp_deadline(p_fh_event_id bigint)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT i.deadline FROM fh_rsvp_deadline_info(p_fh_event_id) i
$$;

-- The reminder's line under a game: tier 'deadline' / 'deadline_passed'
-- where a late answer costs the start, 'deadline_plain' /
-- 'deadline_plain_passed' where it does not.  {day} = "Thu Oct 1".
CREATE OR REPLACE FUNCTION fh_rsvp_deadline_note(p_fh_event_id bigint)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT replace(m.body, '{day}',
                 to_char((i.deadline AT TIME ZONE 'America/New_York')::date - 1, 'Dy Mon FMDD'))
    FROM fh_rsvp_deadline_info(p_fh_event_id) i
    JOIN message_templates m
      ON m.kind = 'rsvp_reminder' AND m.is_active
     AND m.tier = 'deadline' || CASE WHEN i.blocks_start THEN '' ELSE '_plain' END
                             || CASE WHEN now() < i.deadline THEN '' ELSE '_passed' END
   ORDER BY m.sort_order, m.id
   LIMIT 1
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — game deadline, still ahead (no starter rule)', 'rsvp_reminder', 'deadline_plain', NULL,
       'Deadline to answer: {day} midnight.', 22
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'deadline_plain');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — game deadline, passed (no starter rule)', 'rsvp_reminder', 'deadline_plain_passed', NULL,
       'The deadline to answer was {day} midnight — please answer now.', 23
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'deadline_plain_passed');
