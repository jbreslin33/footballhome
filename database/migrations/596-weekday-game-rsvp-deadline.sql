-- 596 (2026-10-19) — Weekday games get a shorter RSVP runway.
--
-- Owner: "rsvp for wednesday game has to be tonight midnight. 48 hours.
-- normally we would do 72 hours for a game on saturday or sunday. but
-- weekday game is tough."
--
-- Under the flat 3-day rule a Wednesday game's deadline landed Sunday
-- midnight — four hours after the Sunday 8 PM schedule release.
-- rsvp_deadline_policies grows days_before_weekday_game: games on
-- Mon–Fri use it, Sat/Sun games keep days_before_game, NULL means one
-- rule all week (every older row).  New club-wide + Men's rows effective
-- 2026-10-21 (the Medford game) carry 3 weekend / 2 weekday, so no past
-- game's on-time record moves:
--
--   Sun game   3 → due Thursday midnight (72 h, unchanged)
--   Wed game   2 → due Monday midnight (~48 h)
--
-- A TUESDAY game still lands tight by construction (2 days = Sunday
-- midnight, four hours after release); the mig-507 opens-guard only
-- voids a deadline that falls BEFORE the release.  Flagged to the owner.

ALTER TABLE rsvp_deadline_policies
  ADD COLUMN IF NOT EXISTS days_before_weekday_game smallint
  CHECK (days_before_weekday_game IS NULL OR days_before_weekday_game >= 0);
COMMENT ON COLUMN rsvp_deadline_policies.days_before_weekday_game IS
  'mig 596: days before a Mon–Fri game that the answer is due (weekday games are tough to fill). NULL = days_before_game covers every day. Sat/Sun games always use days_before_game.';

-- New rows from the Wednesday game on; the mig 507/508 rows stay as the
-- record for games before 2026-10-21.
INSERT INTO rsvp_deadline_policies (club_id, club_section_id, days_before_game, days_before_weekday_game, effective_from, late_blocks_start)
SELECT 134, NULL, 3, 2, DATE '2026-10-21', false
 WHERE NOT EXISTS (SELECT 1 FROM rsvp_deadline_policies
                    WHERE club_id = 134 AND club_section_id IS NULL AND effective_from = DATE '2026-10-21');
INSERT INTO rsvp_deadline_policies (club_id, club_section_id, days_before_game, days_before_weekday_game, effective_from, late_blocks_start)
SELECT 134, cs.id, 3, 2, DATE '2026-10-21', true
  FROM club_sections cs
 WHERE cs.code = 'M'
   AND NOT EXISTS (SELECT 1 FROM rsvp_deadline_policies p
                    WHERE p.club_id = 134 AND p.club_section_id = cs.id AND p.effective_from = DATE '2026-10-21');

-- fh_rsvp_deadline_info picks the day count by the game's local weekday.
CREATE OR REPLACE FUNCTION fh_rsvp_deadline_info(p_fh_event_id bigint)
RETURNS TABLE (deadline timestamptz, blocks_start boolean) LANGUAGE sql STABLE AS $$
  WITH ev AS (
    SELECT fe.id, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE fe.id = p_fh_event_id AND fe.kind = 'match'
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
           fh_schedule_week_opens_at(pol.club_id, pol.club_section_id,
                                     fh_week_start(ev.starts_at, pol.time_zone)) AS opens
      FROM ev, pol
  )
  SELECT d.deadline, d.late_blocks_start FROM d WHERE d.opens IS NULL OR d.opens < d.deadline
$$;
COMMENT ON FUNCTION fh_rsvp_deadline_info(bigint) IS
  'A game''s RSVP deadline (start of the day after the deadline day) and whether missing it costs the start (mig 507/508/596: Mon–Fri games use days_before_weekday_game when set). No row = no deadline applies.';
