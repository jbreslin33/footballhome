-- 627 (2026-10-21) — The weekday game posts alone; its week waits.
--
-- Owner: "the rule should be if there is a weekday [game] show the
-- weekday game but not the other stuff until sunday 8pm."
--
-- Mig 603 opened the WHOLE week 7 days before a weekday match ("the
-- week posts as one unit"), which quietly posted next week's weekend
-- games too — on 10/21 the Tue 10/27 Desert Hawks game had the entire
-- week through Sun 11/1 showing.  This flips the early open from the
-- week to the EVENT:
--
--   * fh_schedule_week_opens_at loses the weekday leg (back to mig
--     334's two: the Sunday cutover and a manual early release).
--   * fh_event_early_open_at — a Mon–Fri MATCH opens by itself at
--     kickoff minus weekday_game_notice_days (practices never).
--   * fh_event_posted / fh_event_window_end — the per-event visibility
--     every consumer now asks: inside the released window, OR that
--     event's own early open has passed.
--   * fh_rsvp_deadline_info's opens-guard counts the event's early
--     open, so the early-posted weekday game keeps its 72h deadline
--     (the guard otherwise voids a deadline that lands before the
--     week opens).

CREATE OR REPLACE FUNCTION fh_schedule_week_opens_at(p_club_id int, p_section_id int, p_week_start date)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT LEAST(
           fh_schedule_policy_opens_at(p_club_id, p_section_id, p_week_start),
           (SELECT r.released_at
              FROM fh_schedule_week_release(p_club_id, p_section_id, p_week_start) r
             WHERE r.id IS NOT NULL)
         )
$$;
COMMENT ON FUNCTION fh_schedule_week_opens_at(int, int, date) IS
  'When the week starting p_week_start (a Monday) opens: the policy cutover or a manual early release (mig 334). The mig-603 weekday leg moved to fh_event_early_open_at (mig 627) — a weekday game posts alone now.';

CREATE OR REPLACE FUNCTION fh_event_early_open_at(p_club_id int, p_section_id int, p_starts timestamptz, p_kind text)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN p_kind = 'match'
               AND pol.weekday_game_notice_days IS NOT NULL
               AND extract(isodow FROM p_starts AT TIME ZONE pol.time_zone) BETWEEN 1 AND 5
              THEN p_starts - make_interval(days => pol.weekday_game_notice_days)
         END
    FROM fh_schedule_policy(p_club_id, p_section_id, p_starts) pol
$$;
COMMENT ON FUNCTION fh_event_early_open_at(int, int, timestamptz, text) IS
  'mig 627: when this ONE event posts early — a Mon–Fri match at kickoff minus weekday_game_notice_days; NULL for everything else ("a weekday game is a surprise; practices are not").';

CREATE OR REPLACE FUNCTION fh_event_posted(p_club_id int, p_section_id int, p_starts timestamptz, p_kind text)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT p_starts < fh_schedule_window_end(p_club_id, p_section_id, now())
      OR now() >= fh_event_early_open_at(p_club_id, p_section_id, p_starts, p_kind)
$$;
COMMENT ON FUNCTION fh_event_posted(int, int, timestamptz, text) IS
  'mig 627: is this event visible to players right now — inside the released window, or past its own weekday-match early open.';

CREATE OR REPLACE FUNCTION fh_event_window_end(p_club_id int, p_section_id int, p_starts timestamptz, p_kind text)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT GREATEST(
           fh_schedule_window_end(p_club_id, p_section_id, now()),
           CASE WHEN now() >= fh_event_early_open_at(p_club_id, p_section_id, p_starts, p_kind)
                THEN p_starts + interval '1 minute' END
         )
$$;
COMMENT ON FUNCTION fh_event_window_end(int, int, timestamptz, text) IS
  'mig 627: the released window as it applies to this ONE event — stretched just far enough to cover the event itself when its weekday early open has passed. Feeds hand this to clients whose posted-check compares starts_at <= window_end.';

-- The deadline guard: an early-opened weekday game's deadline stands.
CREATE OR REPLACE FUNCTION fh_rsvp_deadline_info(p_fh_event_id bigint)
RETURNS TABLE(deadline timestamptz, blocks_start boolean) LANGUAGE sql STABLE AS $$
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
           -- LEAST ignores a NULL leg: the event's own early open (mig
           -- 627) counts as its open moment, so the guard below no
           -- longer voids the early weekday game's deadline.
           LEAST(fh_schedule_week_opens_at(pol.club_id, pol.club_section_id,
                                           fh_week_start(ev.starts_at, pol.time_zone)),
                 fh_event_early_open_at(pol.club_id, pol.club_section_id, ev.starts_at, 'match')) AS opens
      FROM ev, pol
  )
  SELECT d.deadline, d.late_blocks_start FROM d WHERE d.opens IS NULL OR d.opens < d.deadline
$$;
