-- 805: Men's practice criterion = practice days − 3, Monday counts
-- (owner 2026-10-28: "no weekday game then you calc based on number of
-- practices. num practices - 3 = criteria so 5 = 2, 4 = 1, 3 = 0, all
-- the rest are 0"; "monday should count too").
--
-- typical_practice_dows gains Monday: {1..6} = Mon–Sat.  The bar becomes
-- days held − eligibility_policies.free_practice_days (3), never below 0
-- — 6 days need 3, 5 need 2, 4 need 1, 3 or fewer need 0.  NULL keeps
-- mig 562's "min_sessions_to_start minus missed days".  A week with a
-- weekday game still needs weekday_game_week_needed (0, mig 804) first.
ALTER TABLE eligibility_policies ADD COLUMN IF NOT EXISTS free_practice_days int
  CHECK (free_practice_days IS NULL OR free_practice_days >= 0);
COMMENT ON COLUMN eligibility_policies.free_practice_days IS
  'mig 805: needed = practice days held in the counted week − this, never below 0; NULL = min_sessions_to_start minus missed days (mig 562).';

UPDATE eligibility_policies
   SET typical_practice_dows = '{1,2,3,4,5,6}', free_practice_days = 3
 WHERE club_section_id = 1;   -- Men

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

  -- Mig 805: days held − free_practice_days, never below 0.
  IF pol.free_practice_days IS NOT NULL THEN
    RETURN QUERY SELECT GREATEST(0, v_held - pol.free_practice_days), v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true;
    RETURN;
  END IF;

  RETURN QUERY SELECT GREATEST(0, v_base - GREATEST(0, v_typ - v_held)),
                      v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true;
END;
$function$;
