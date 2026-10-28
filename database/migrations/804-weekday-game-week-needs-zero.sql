-- 804: A week with a men's weekday game needs 0 practices to start
-- (owner 2026-10-28: "this is a weekday game week. so practice criteria
-- is 0"; "we had weekday game for liga 1 or apsl means 0 practice
-- criteria").
--
-- Mig 562's week mode only lowered the bar one per missed typical day, so
-- a Tuesday game (one missed day) left the Sunday games needing 1.  Now:
-- eligibility_policies.weekday_game_week_needed — when set, any game whose
-- counted week (the same Sun–Sat week fh_starter_window counts) holds a
-- Mon–Fri game of a team in the policy's section needs exactly that many.
-- Men's section policy = 0.  NULL keeps mig 562's per-day rule.
ALTER TABLE eligibility_policies ADD COLUMN IF NOT EXISTS weekday_game_week_needed int
  CHECK (weekday_game_week_needed IS NULL OR weekday_game_week_needed >= 0);
COMMENT ON COLUMN eligibility_policies.weekday_game_week_needed IS
  'mig 804: sessions needed for every game in a week holding a Mon–Fri game of the section''s teams; NULL = off.';

UPDATE eligibility_policies SET weekday_game_week_needed = 0
 WHERE club_section_id = 1 AND weekday_game_week_needed IS NULL;   -- Men

CREATE OR REPLACE FUNCTION public.fh_starter_needed(p_team_ids integer[], p_kickoff timestamp with time zone, p_match_id integer)
 RETURNS TABLE(needed integer, base_needed integer, typical_days integer, held_days integer, missed_days integer, week_mode boolean)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  pol    eligibility_policies;
  v_base INT;
  v_typ  INT;
  v_held INT;
  v_game_date DATE;
  v_dow  INT;
  v_ws   DATE;
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

  -- Mig 804: a weekday game in the counted week sets the bar outright.
  -- Same week as fh_starter_window's week mode (a game on the week's first
  -- day belongs to the week just ended).
  IF pol.weekday_game_week_needed IS NOT NULL THEN
    v_game_date := (p_kickoff AT TIME ZONE 'America/New_York')::date;
    v_dow := EXTRACT(DOW FROM v_game_date)::int;
    v_ws := v_game_date - ((v_dow - ((pol.week_cutoff_dow + 1) % 7) + 7) % 7);
    IF v_ws = v_game_date THEN v_ws := v_ws - 7; END IF;
    IF EXISTS (
      SELECT 1
        FROM fh_events fe
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
        JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
        JOIN teams t ON t.id = fet.team_id
       WHERE fe.kind = 'match'
         AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
         AND (ge.starts_at AT TIME ZONE 'America/New_York')::date BETWEEN v_ws AND v_ws + 6
         AND EXTRACT(ISODOW FROM (ge.starts_at AT TIME ZONE 'America/New_York')::date) BETWEEN 1 AND 5
         AND t.club_section_id IN (SELECT club_section_id FROM teams WHERE id = ANY(p_team_ids)))
    THEN
      RETURN QUERY SELECT pol.weekday_game_week_needed, v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true;
      RETURN;
    END IF;
  END IF;

  RETURN QUERY SELECT GREATEST(0, v_base - GREATEST(0, v_typ - v_held)),
                      v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true;
END;
$function$;
