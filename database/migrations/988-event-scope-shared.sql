-- 988 (2026-11-03) — an event shared by several of our teams (men's practice =
-- APSL + Liga 1; a youth practice for several ages) lands on their section on
-- #finances, not on the highest team; one team's event stays on that team.
CREATE OR REPLACE FUNCTION cash_flow_event_scope(p_event bigint, p_category text, p_league text) RETURNS text LANGUAGE sql STABLE AS $$
  WITH t AS (SELECT DISTINCT s.code, s.parent FROM fh_event_teams et JOIN cash_flow_scopes s ON s.team_id = et.team_id WHERE et.fh_event_id = p_event)
  SELECT COALESCE(
    CASE WHEN (SELECT count(*) FROM t) = 1 THEN (SELECT code FROM t) END,
    CASE WHEN (SELECT count(DISTINCT parent) FROM t) = 1 THEN (SELECT parent FROM t LIMIT 1) END,
    cash_flow_scope(p_category, p_league)) $$;
