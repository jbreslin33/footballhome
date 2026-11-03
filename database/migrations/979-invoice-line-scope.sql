-- 979 (2026-11-03) — an invoice line that counts toward a budget line lands on
-- that budget line's team on #finances (one team) — e.g. "APSL League Dues"
-- → APSL; otherwise the description rules (mig 897), then the budget line's
-- section, then club-wide.
CREATE OR REPLACE FUNCTION cash_flow_invoice_line_scope(p_line int) RETURNS text LANGUAGE sql STABLE AS $$
  WITH l AS (
    SELECT l.id, l.description, COALESCE(l.budget_line_id, p.budget_line_id) AS bl
      FROM invoice_lines l LEFT JOIN invoice_installment_plans p ON p.id = l.plan_id WHERE l.id = p_line
  ), teams_of AS (
    SELECT DISTINCT e.team_id FROM l JOIN budget_line_fees bf ON bf.budget_line_id = l.bl JOIN team_season_entries e ON e.id = bf.entry_id
  )
  SELECT COALESCE(
    CASE WHEN (SELECT count(*) FROM teams_of) = 1 THEN cash_flow_team_scope((SELECT team_id FROM teams_of)) END,
    (SELECT r.scope FROM cash_flow_line_rules r, l WHERE l.description ~* r.pattern ORDER BY r.sort_order LIMIT 1),
    (SELECT s.code FROM l JOIN budget_lines b ON b.id = l.bl JOIN club_sections cs ON cs.id = b.club_section_id
       JOIN cash_flow_scopes s ON s.section_code = cs.code LIMIT 1),
    'club') $$;
