-- 562 (2026-10-10) — Men's practice criterion counts only the game week's
-- typical practice days, never the week before.
--
-- Owner: "new rule for practice for men. only count the typical 5 days.
-- tue, wed, thu, fri, sat. if a day is cancelled then players only need 1
-- day for eligiblity. if 2 days are cancelled or don't take place for
-- whatever reason then 0 days are needed. make sense? so we don't go back
-- to previouse week."
--
-- eligibility_policies grows typical_practice_dows.  NULL keeps the old
-- behaviour (last lookback_count sessions, weekday-game extension — youth
-- and women stay on it).  When set — the men's section row gets
-- {2,3,4,5,6}, Tue–Sat — fh_starter_window() returns only the sessions on
-- those days inside the game's own week (for a Sunday game, the Tue–Sat
-- just finished; for any other day, the current week up to kickoff), and
-- the new fh_starter_needed() lowers the bar one for every typical day
-- with no session before kickoff:
--
--   all 5 days held            need min_sessions_to_start (2)
--   1 day cancelled / missing  need 1
--   2 or more                  need 0 — everyone passes the criterion
--
-- "Don't take place for whatever reason" includes days after a midweek
-- kickoff, so a Wednesday game needs 0 by construction, which retires the
-- mig 456/505 weekday-game window extension for the men: the Sunday after
-- a Wednesday game just counts its own Tue–Sat, and the game day's missing
-- practice already lowers the bar.  In this mode both the held days and a
-- player's attendance are counted in DAYS, not sessions — a practice and a
-- pickup on the same Saturday are one day.
--
-- The game RSVP deadline criterion (mig 507/508) is untouched.

ALTER TABLE eligibility_policies
  ADD COLUMN IF NOT EXISTS typical_practice_dows INT[] DEFAULT NULL;

COMMENT ON COLUMN eligibility_policies.typical_practice_dows IS
  'mig 562: NULL = last lookback_count sessions (+ weekday extension). Set (days 0=Sun…6=Sat) = count only these days of the game''s own week; fh_starter_needed() lowers min_sessions_to_start by one per listed day with no session before kickoff.';

-- ── fh_starter_window: week mode ─────────────────────────────────────────
-- New output column week_mode; a cancelled gcal event now never counts as a
-- session in either mode (it previously only had to be deleted).
DROP FUNCTION IF EXISTS fh_starter_window(INT[], TIMESTAMPTZ, INT);
CREATE FUNCTION fh_starter_window(p_team_ids INT[], p_kickoff TIMESTAMPTZ, p_match_id INT)
RETURNS TABLE (fh_event_id BIGINT, kind TEXT, starts_at TIMESTAMPTZ, extended BOOLEAN, cutoff TIMESTAMPTZ, week_mode BOOLEAN)
LANGUAGE plpgsql STABLE AS $function$
DECLARE
  pol      eligibility_policies;
  v_dow    INT;
  v_cutoff TIMESTAMPTZ := NULL;
  v_wk     TIMESTAMPTZ;
  v_game_teams INT[] := p_team_ids;   -- whose weekday game widens the window
  v_game_date  DATE;
  v_ws         DATE;                  -- week-mode: first day of the counted week
BEGIN
  pol := fh_starter_policy(p_team_ids, p_match_id);
  IF pol.id IS NULL THEN
    pol.lookback_count := 5; pol.pickup_counts_as_session := true; pol.game_counts_as_session := false;
    pol.weekday_game_extends_window := true; pol.week_cutoff_dow := 6; pol.weekday_game_section_wide := false;
    pol.typical_practice_dows := NULL;
  END IF;

  -- Week mode (mig 562): only the game's own week counts.  The week runs
  -- from the day after week_cutoff_dow (Sunday, with the Saturday default);
  -- a game ON that first day belongs to the week that just ended, so a
  -- Sunday game counts the Tue–Sat before it and never reaches further back.
  IF pol.typical_practice_dows IS NOT NULL THEN
    v_game_date := (p_kickoff AT TIME ZONE 'America/New_York')::date;
    v_dow := EXTRACT(DOW FROM v_game_date)::int;
    v_ws := v_game_date - ((v_dow - ((pol.week_cutoff_dow + 1) % 7) + 7) % 7);
    IF v_ws = v_game_date THEN v_ws := v_ws - 7; END IF;
    RETURN QUERY
    SELECT DISTINCT fe.id, fe.kind::text, ge.starts_at, false, NULL::timestamptz, true
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
     WHERE fet.team_id = ANY(p_team_ids)
       AND ge.deleted_at IS NULL
       AND ge.status IS DISTINCT FROM 'cancelled'
       AND ge.starts_at < p_kickoff
       AND (ge.starts_at AT TIME ZONE 'America/New_York')::date BETWEEN v_ws AND v_ws + 6
       AND EXTRACT(DOW FROM (ge.starts_at AT TIME ZONE 'America/New_York')::date)::int = ANY(pol.typical_practice_dows)
       AND (fe.kind IN ('practice', 'barn night')
            OR (fe.kind = 'pickup' AND pol.pickup_counts_as_session)
            OR (fe.kind = 'match'  AND pol.game_counts_as_session))
     ORDER BY 3;
    RETURN;
  END IF;

  IF pol.weekday_game_extends_window THEN
    v_dow := EXTRACT(DOW FROM p_kickoff AT TIME ZONE 'America/New_York')::int;
    IF v_dow BETWEEN 1 AND 5 THEN
      v_cutoff := fh_week_cutoff(p_kickoff, pol.week_cutoff_dow);
    ELSE
      -- Weekend game: the most recent weekday game within the past 7 days
      -- lends its cutoff — a game of these teams, or (section-wide policy,
      -- mig 505) of any team in their club section.
      IF pol.weekday_game_section_wide THEN
        SELECT COALESCE(array_agg(DISTINCT s.id), p_team_ids) INTO v_game_teams
          FROM teams t
          JOIN teams s ON s.club_id = t.club_id AND s.club_section_id = t.club_section_id
         WHERE t.id = ANY(p_team_ids);
      END IF;
      SELECT ge.starts_at INTO v_wk
        FROM fh_events fe
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE fe.kind = 'match' AND ge.deleted_at IS NULL
         AND ge.starts_at > p_kickoff - INTERVAL '7 days' AND ge.starts_at < p_kickoff
         AND EXTRACT(DOW FROM ge.starts_at AT TIME ZONE 'America/New_York')::int BETWEEN 1 AND 5
         AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = ANY(v_game_teams))
       ORDER BY ge.starts_at DESC LIMIT 1;
      IF v_wk IS NOT NULL THEN v_cutoff := fh_week_cutoff(v_wk, pol.week_cutoff_dow); END IF;
    END IF;
  END IF;

  RETURN QUERY
  WITH sessions AS (
    SELECT DISTINCT fe.id AS fh_event_id, fe.kind::text AS kind, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
     WHERE fet.team_id = ANY(p_team_ids)
       AND ge.deleted_at IS NULL
       AND ge.status IS DISTINCT FROM 'cancelled'
       AND ge.starts_at < p_kickoff
       AND (fe.kind IN ('practice', 'barn night')
            OR (fe.kind = 'pickup' AND pol.pickup_counts_as_session)
            OR (fe.kind = 'match'  AND pol.game_counts_as_session))
  ),
  picked AS (
    SELECT s.* FROM (
      SELECT s.* FROM sessions s
       WHERE v_cutoff IS NULL OR s.starts_at < v_cutoff
       ORDER BY s.starts_at DESC
       LIMIT pol.lookback_count
    ) s
    UNION
    SELECT s.* FROM sessions s WHERE v_cutoff IS NOT NULL AND s.starts_at >= v_cutoff
  )
  SELECT p.fh_event_id, p.kind, p.starts_at, (v_cutoff IS NOT NULL), v_cutoff, false
    FROM picked p ORDER BY p.starts_at;
END;
$function$;

COMMENT ON FUNCTION fh_starter_window(INT[], TIMESTAMPTZ, INT) IS
  'Sessions counted for starter eligibility at a game: last lookback_count before kickoff or the weekday-game extended window (mig 456/505), or — typical_practice_dows set (mig 562) — only those days of the game''s own week.';

-- ── fh_starter_needed: how many sessions this game actually requires ─────
-- Week mode lowers min_sessions_to_start by one per typical day with no
-- session before kickoff; otherwise it is simply the policy's number.
CREATE OR REPLACE FUNCTION fh_starter_needed(p_team_ids INT[], p_kickoff TIMESTAMPTZ, p_match_id INT)
RETURNS TABLE (needed INT, base_needed INT, typical_days INT, held_days INT, missed_days INT, week_mode BOOLEAN)
LANGUAGE plpgsql STABLE AS $function$
DECLARE
  pol    eligibility_policies;
  v_base INT;
  v_typ  INT;
  v_held INT;
BEGIN
  pol := fh_starter_policy(p_team_ids, p_match_id);
  v_base := COALESCE(pol.min_sessions_to_start, 2);
  IF pol.id IS NULL OR pol.typical_practice_dows IS NULL THEN
    RETURN QUERY SELECT v_base, v_base, NULL::int, NULL::int, NULL::int, false;
    RETURN;
  END IF;
  SELECT count(DISTINCT d) INTO v_typ FROM unnest(pol.typical_practice_dows) d;
  SELECT count(DISTINCT (w.starts_at AT TIME ZONE 'America/New_York')::date) INTO v_held
    FROM fh_starter_window(p_team_ids, p_kickoff, p_match_id) w;
  RETURN QUERY SELECT GREATEST(0, v_base - GREATEST(0, v_typ - v_held)),
                      v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true;
END;
$function$;

COMMENT ON FUNCTION fh_starter_needed(INT[], TIMESTAMPTZ, INT) IS
  'Practices required to start this game (mig 562): the policy''s min_sessions_to_start, lowered one per typical practice day of the game week with no session before kickoff when typical_practice_dows is set.';

-- ── The men's section switches to the week rule ──────────────────────────
UPDATE eligibility_policies
   SET typical_practice_dows = '{2,3,4,5,6}',   -- Tue, Wed, Thu, Fri, Sat
       notes = 'Men''s section (mig 562): only the game week''s typical practice days (Tue–Sat) count — never the week before. Need 2; one day cancelled/missing → 1; two or more → 0. Replaces the mig 505 weekday-game window extension for the men.'
 WHERE club_section_id IN (SELECT id FROM club_sections WHERE name = 'Mens')
   AND team_id IS NULL AND match_id IS NULL;

-- ── Player-facing rule explainer for the week mode ───────────────────────
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('eligibility', 'rule_week', 'Game Center — starter rule explainer (week rule, all days held)',
  'Only this week''s usual practice days (Tue–Sat) count — last week''s don''t. You need {needed} of the {typical} days to start; attendance is taken at every practice, and a Going RSVP shows as projected until you are marked present.', 31);
SELECT pg_temp.add_client_tpl('eligibility', 'rule_week_reduced', 'Game Center — starter rule explainer (week rule, a day missing)',
  '{missed} of the usual {typical} practice days (Tue–Sat) didn''t happen this week, so you only need {needed} to start. Last week''s practices don''t count.', 32);
SELECT pg_temp.add_client_tpl('eligibility', 'rule_week_zero', 'Game Center — starter rule explainer (week rule, two+ days missing)',
  '{missed} of the usual {typical} practice days (Tue–Sat) didn''t happen this week, so no practices are needed to start this game.', 33);
