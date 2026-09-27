-- 458 — Practice Criteria, everyone's row (owner 2026-09-26: "instagram
-- view at top but under should be full detail of everyone … themselves
-- criteria status should be highlighted but the other players criteria
-- status should show").  Short per-row wording for the roster list under
-- the card on the player's Game Center; the long "Practice Criteria: …"
-- pill (mig 457) stays on the viewer's own card.
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.add_client_tpl('eligibility', 'row_met',                'Game Center — roster row: met',                'Met {attended}/{needed}', 21);
SELECT pg_temp.add_client_tpl('eligibility', 'row_exceeding',          'Game Center — roster row: exceeding',          'Met {attended}/{needed} · exceeding', 22);
SELECT pg_temp.add_client_tpl('eligibility', 'row_exceeding_projected','Game Center — roster row: projected to exceed','Met {attended}/{needed} · projected to exceed', 23);
SELECT pg_temp.add_client_tpl('eligibility', 'row_projected',          'Game Center — roster row: projected',          'Projected {attended}+{projected}/{needed}', 24);
SELECT pg_temp.add_client_tpl('eligibility', 'row_needs',              'Game Center — roster row: needs more',         'Needs {remaining}', 25);
SELECT pg_temp.add_client_tpl('eligibility', 'row_not_met',            'Game Center — roster row: not met',            'Not met {attended}/{needed}', 26);
SELECT pg_temp.add_client_tpl('eligibility', 'roster_heading',         'Game Center — roster criteria heading',        'Practice Criteria — everyone', 27);
