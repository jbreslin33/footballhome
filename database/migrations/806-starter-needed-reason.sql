-- 806: The practice criterion says WHY it is what it is (owner 2026-10-28:
-- "we need this rule in code or db whatever is most normalized").
--
-- The rule stays data + one function: eligibility_policies holds the
-- numbers (typical_practice_dows Mon–Sat, free_practice_days 3,
-- weekday_game_week_needed 0 — migs 562/804/805) and fh_starter_needed()
-- is the only place they are applied.  It now also returns `reason`:
--   weekday_game — a Mon–Fri game this week set the bar (mig 804)
--   days         — practice days held − free_practice_days (mig 805)
--   missed       — min_sessions_to_start minus missed days (mig 562)
--   policy       — a plain number (no week mode)
-- so Game Center's explainer names the rule that applied; its wording is
-- message_templates kind=eligibility, rewritten here for Mon–Sat / − 3.
DROP FUNCTION IF EXISTS fh_starter_needed(integer[], timestamp with time zone, integer);
CREATE FUNCTION public.fh_starter_needed(p_team_ids integer[], p_kickoff timestamp with time zone, p_match_id integer)
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

UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('rule_week',      'This week''s practice days (Mon–Sat) count — last week''s don''t. {held} practice days this week, so you need {needed} to start (practice days minus 3). Attendance is taken at every practice; a Going RSVP shows as projected until you are marked present.'),
    ('rule_week_zero', 'Only {held} practice days this week (Mon–Sat), so no practices are needed to start this game (practice days minus 3).')
  ) AS v(t, b)
 WHERE kind = 'eligibility' AND tier = v.t;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', 'Practice rule — week with a weekday game (mig 804)', 'eligibility', 'rule_week_weekday_game', NULL,
       'There''s a weekday game this week, so no practices are needed to start this game.', 
       COALESCE((SELECT max(sort_order) FROM message_templates WHERE kind = 'eligibility'), 0) + 1, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'eligibility' AND tier = 'rule_week_weekday_game');
