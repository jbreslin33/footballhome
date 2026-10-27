-- 761 — Waive the game RSVP deadline for one game.
--
-- Owner 2026-10-27: "take off late rsvp for todays game." — Tue 10/27
-- Liga 1 vs Desert Hawks FC (fh_event 75728094, match 9355).  Its
-- deadline (mig 507/603) was Sat 10/24 midnight and all 13 Going answers
-- came after it, so the starter rule (mig 508) read every one of them
-- as "Game RSVP late".
--
-- Mig 591 excused two people by backdating their first answers; for a
-- whole game that would still mark anyone answering later today as late.
-- A row here makes fh_rsvp_deadline_info() return no deadline for the
-- event, so nobody on it is late and the reminder prints no deadline.
-- Answers and first-answer stamps are untouched; deleting the row brings
-- the deadline back.

CREATE TABLE IF NOT EXISTS rsvp_deadline_waivers (
  fh_event_id bigint PRIMARY KEY REFERENCES fh_events(id) ON DELETE CASCADE,
  reason      text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE rsvp_deadline_waivers IS
  'Games whose RSVP deadline is waived (mig 761): fh_rsvp_deadline_info() returns no deadline, so nobody is late. Delete the row to restore it.';

CREATE OR REPLACE FUNCTION public.fh_rsvp_deadline_info(p_fh_event_id bigint)
 RETURNS TABLE(deadline timestamp with time zone, blocks_start boolean)
 LANGUAGE sql
 STABLE
AS $function$
  WITH ev AS (
    SELECT fe.id, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE fe.id = p_fh_event_id AND fe.kind = 'match'
       -- Waived for this game (mig 761): no deadline at all.
       AND NOT EXISTS (SELECT 1 FROM rsvp_deadline_waivers w WHERE w.fh_event_id = fe.id)
  ), pol AS (
    SELECT CASE WHEN extract(dow FROM (ev.starts_at AT TIME ZONE p.time_zone)) IN (0, 6)
                THEN p.days_before_game
                ELSE COALESCE(p.days_before_weekday_game, p.days_before_game)
           END AS days_before,
           p.time_zone, p.late_blocks_start, t.club_id, t.club_section_id
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
    SELECT (((ev.starts_at AT TIME ZONE pol.time_zone)::date - pol.days_before + 1)::timestamp
              AT TIME ZONE pol.time_zone) AS deadline,
           pol.late_blocks_start,
           -- LEAST ignores a NULL leg: the event's own early open (mig
           -- 627) counts as its open moment, so the guard below no
           -- longer voids the early weekday game's deadline.
           LEAST(fh_schedule_week_opens_at(pol.club_id, pol.club_section_id,
                                           fh_week_start(ev.starts_at, pol.time_zone)),
                 fh_event_early_open_at(pol.club_id, pol.club_section_id, ev.starts_at, 'match')) AS opens
      FROM ev, pol
  )
  SELECT d.deadline, d.late_blocks_start FROM d WHERE d.opens IS NULL OR d.opens < d.deadline
$function$;

INSERT INTO rsvp_deadline_waivers (fh_event_id, reason)
VALUES (75728094, 'Owner 10/27: take off late RSVP for Liga 1 vs Desert Hawks FC')
ON CONFLICT (fh_event_id) DO NOTHING;
