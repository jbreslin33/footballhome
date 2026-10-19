-- 603 (2026-10-19) — A weekday GAME posts the week 7 days out; the flat
-- 72-hour RSVP rule comes back.
--
-- Owner: "i think we need to detect if there is a weekday game the next
-- week and if so that should get posted 7 days out … practice is never a
-- surprise but a weekday game is … then we can keep the 72 hour rule in
-- place."
--
-- Mig 596 shortened weekday-game deadlines to 2 days because the Sunday
-- 8 PM release left no runway (a Tuesday game's Sunday-midnight deadline
-- landed FOUR HOURS after release).  This flips the fix around: give
-- notice instead of shrinking the deadline.
--
--   1. schedule_release_policies grows weekday_game_notice_days (7).
--      When the coming week holds a Mon–Fri MATCH (kind='match' only —
--      practices never trigger it), the week opens at kickoff minus that
--      many days, if that beats the Sunday cutover and any manual early
--      release.  Club-wide on purpose: the week posts as one unit, so a
--      men's Tuesday game opens the youth/women's week early too —
--      harmless, their weekday events are practices.
--   2. rsvp_deadline_policies: new rows effective 2026-10-22 drop
--      days_before_weekday_game — every game is 3 days (72 h) again.
--      The 10/21 Medford game keeps its announced 2-day deadline
--      (tonight) under the mig-596 rows, so no on-time record moves.
--
-- The mig-507 opens-guard in fh_rsvp_deadline_info needs no change: it
-- already voids a deadline that falls before the week opens, and the
-- early open now comes from the same fh_schedule_week_opens_at.
--
--   Tue 10/27 Desert Hawks: posts Tue 10/20 19:00, due Fri midnight.
--   Sun game: still posts Sunday 8 PM, due Thursday midnight.

ALTER TABLE schedule_release_policies
  ADD COLUMN IF NOT EXISTS weekday_game_notice_days smallint
  CHECK (weekday_game_notice_days IS NULL OR weekday_game_notice_days > 0);
COMMENT ON COLUMN schedule_release_policies.weekday_game_notice_days IS
  'mig 603: a Mon–Fri match in the coming week opens that week at kickoff minus this many days when that is earlier than the cutover (weekday games are a surprise; practices are not). NULL = cutover only.';

-- New standing row from today, carrying the in-force cutover forward.
INSERT INTO schedule_release_policies
       (club_id, club_section_id, cutover_weekday, cutover_time, time_zone, effective_from, weekday_game_notice_days)
SELECT p.club_id, NULL, p.cutover_weekday, p.cutover_time, p.time_zone, CURRENT_DATE, 7
  FROM fh_schedule_policy(134, NULL, now()) p
 WHERE p.id IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM schedule_release_policies q
                    WHERE q.club_id = 134 AND q.club_section_id IS NULL
                      AND q.weekday_game_notice_days IS NOT NULL);

-- Third leg on the week's open moment: earliest Mon–Fri match in the
-- week, minus the notice days.  LEAST ignores a NULL leg, so weeks
-- without a weekday game (and policies without the knob) are unchanged.
CREATE OR REPLACE FUNCTION fh_schedule_week_opens_at(p_club_id int, p_section_id int, p_week_start date)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT LEAST(
           fh_schedule_policy_opens_at(p_club_id, p_section_id, p_week_start),
           (SELECT r.released_at
              FROM fh_schedule_week_release(p_club_id, p_section_id, p_week_start) r
             WHERE r.id IS NOT NULL),
           (SELECT (SELECT MIN(gg.starts_at)
                      FROM fh_events fe
                      JOIN gcal_events gg ON gg.id = fe.gcal_event_id
                                         AND gg.deleted_at IS NULL
                                         AND gg.status IS DISTINCT FROM 'cancelled'
                     WHERE fe.kind = 'match'
                       AND (gg.starts_at AT TIME ZONE pol.time_zone)::date
                             BETWEEN p_week_start AND p_week_start + 6
                       AND extract(isodow FROM gg.starts_at AT TIME ZONE pol.time_zone) BETWEEN 1 AND 5)
                   - make_interval(days => pol.weekday_game_notice_days)
              FROM fh_schedule_policy(p_club_id, p_section_id,
                     (p_week_start::timestamp AT TIME ZONE 'America/New_York')) pol
             WHERE pol.weekday_game_notice_days IS NOT NULL)
         )
$$;
COMMENT ON FUNCTION fh_schedule_week_opens_at(int, int, date) IS
  'When the week starting p_week_start (a Monday) opens: earliest of the policy cutover, a manual early release (mig 334), and — mig 603 — a weekday match''s kickoff minus weekday_game_notice_days.';

-- Back to one rule all week.  The mig-596 rows stay as the record for
-- games on 10/21 only.
INSERT INTO rsvp_deadline_policies (club_id, club_section_id, days_before_game, days_before_weekday_game, effective_from, late_blocks_start)
SELECT 134, NULL, 3, NULL, DATE '2026-10-22', false
 WHERE NOT EXISTS (SELECT 1 FROM rsvp_deadline_policies
                    WHERE club_id = 134 AND club_section_id IS NULL AND effective_from = DATE '2026-10-22');
INSERT INTO rsvp_deadline_policies (club_id, club_section_id, days_before_game, days_before_weekday_game, effective_from, late_blocks_start)
SELECT 134, cs.id, 3, NULL, DATE '2026-10-22', true
  FROM club_sections cs
 WHERE cs.code = 'M'
   AND NOT EXISTS (SELECT 1 FROM rsvp_deadline_policies p
                    WHERE p.club_id = 134 AND p.club_section_id = cs.id AND p.effective_from = DATE '2026-10-22');
