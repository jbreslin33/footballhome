-- 986 (2026-11-03) — which #finances pill a budget line belongs to.
-- Owner 2026-11-03: "could we just do pills and not diff pages … like on
-- summary if i could break down by pills for just apsl it would really help
-- me check math" / "more control with pills and then we can pull back".
-- A budget line made of one team's fees → that team; else its section; else
-- club-wide.  (Invoice lines: cash_flow_invoice_line_scope, mig 979.)
CREATE OR REPLACE FUNCTION cash_flow_budget_line_scope(p_line int) RETURNS text LANGUAGE sql STABLE AS $$
  WITH t AS (SELECT DISTINCT e.team_id FROM budget_line_fees bf JOIN team_season_entries e ON e.id = bf.entry_id WHERE bf.budget_line_id = p_line)
  SELECT COALESCE(
    CASE WHEN (SELECT count(*) FROM t) = 1 THEN cash_flow_team_scope((SELECT team_id FROM t)) END,
    (SELECT s.code FROM budget_lines b JOIN club_sections cs ON cs.id = b.club_section_id JOIN cash_flow_scopes s ON s.section_code = cs.code WHERE b.id = p_line LIMIT 1),
    'club') $$;
