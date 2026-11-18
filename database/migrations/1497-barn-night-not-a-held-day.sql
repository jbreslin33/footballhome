-- 1497 (2026-11-18) — 🍺 Barn night: attending counts, but its day is not a
-- practice day "held" for everyone.  Owner 11/18: "you should know this is a
-- barn night. and attending that counts … but since only 21 age and older
-- can go its officially 4 practices so they need 1 of the 4 or barn night."
--
-- The week rule (mig 805) needs days held − free_practice_days (Men: 3).
-- This week: Tue / Wed / Thu / Sat practices + Friday barn night (mig 1496
-- put it on the schedule).  Held must be 4 (→ 1 needed), not 5 (→ 2): a day
-- with a session of a kind in eligibility_policies.held_excludes_kinds no
-- longer counts as held.  The barn night stays in fh_starter_window, so
-- attending it is a day made, the same as a practice.
BEGIN;

ALTER TABLE eligibility_policies ADD COLUMN IF NOT EXISTS held_excludes_kinds text[];
COMMENT ON COLUMN eligibility_policies.held_excludes_kinds IS
  'mig 1497: session kinds whose day is not counted as a practice day held (Men: barn night — 21+ only). Attending them still counts.';
UPDATE eligibility_policies SET held_excludes_kinds = '{barn night}' WHERE club_section_id = 1;

CREATE OR REPLACE FUNCTION public.fh_starter_needed(p_team_ids integer[], p_kickoff timestamp with time zone, p_match_id integer)
 RETURNS TABLE(needed integer, base_needed integer, typical_days integer, held_days integer, missed_days integer, week_mode boolean, reason text)
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
    RETURN QUERY SELECT v_base, v_base, NULL::int, NULL::int, NULL::int, false, 'policy'::text;
    RETURN;
  END IF;
  SELECT count(DISTINCT d) INTO v_typ FROM unnest(pol.typical_practice_dows) d;
  -- Mig 1497: a day with a session of an excluded kind (Men: barn night —
  -- 21+ only) is not a practice day "held" for everyone; attending it still
  -- counts (owner 11/18 "only 21 age and older can go its officially 4
  -- practices so they need 1 of the 4 or barn night").
  SELECT count(DISTINCT (w.starts_at AT TIME ZONE 'America/New_York')::date) INTO v_held
    FROM fh_starter_window(p_team_ids, p_kickoff, p_match_id) w
   WHERE NOT EXISTS (SELECT 1 FROM fh_starter_window(p_team_ids, p_kickoff, p_match_id) x
                      WHERE x.kind = ANY (COALESCE(pol.held_excludes_kinds, '{}'))
                        AND (x.starts_at AT TIME ZONE 'America/New_York')::date = (w.starts_at AT TIME ZONE 'America/New_York')::date);

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
      RETURN QUERY SELECT pol.weekday_game_week_needed, v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true, 'weekday_game'::text;
      RETURN;
    END IF;
  END IF;

  -- Mig 805: days held − free_practice_days, never below 0.
  IF pol.free_practice_days IS NOT NULL THEN
    RETURN QUERY SELECT GREATEST(0, v_held - pol.free_practice_days), v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true, 'days'::text;
    RETURN;
  END IF;

  RETURN QUERY SELECT GREATEST(0, v_base - GREATEST(0, v_typ - v_held)),
                      v_base, v_typ, v_held, GREATEST(0, v_typ - v_held), true, 'missed'::text;
END;
$function$;

COMMIT;
