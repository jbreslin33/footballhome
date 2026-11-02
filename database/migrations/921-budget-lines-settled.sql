-- 921 (2026-10-31) — #finances: budget lines can be edited and settled.
--
-- Owner: "we would need to check them off and be able to edit them for true
-- cost right?"  Most budget lines are estimates, and an invoice under the
-- estimate left the difference projected forever.  ✓ Settled means the bill is
-- finished: the true cost is what was invoiced and nothing more is projected.
-- The amount stays the estimate; the true cost lives on the invoice lines.

ALTER TABLE budget_lines ADD COLUMN IF NOT EXISTS settled_at TIMESTAMP WITH TIME ZONE;

CREATE OR REPLACE FUNCTION pg_temp.tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, 'finances', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = p_tier);
$$;

SELECT pg_temp.tpl('budget_title',   'Finances — budget lines heading', '🧾 Budget lines', 60);
SELECT pg_temp.tpl('budget_note',    'Finances — budget lines note',
  'Change an estimate here. The true cost comes from the invoice lines that count toward it. ✓ Settled means the bill is finished, so nothing more is projected.', 61);
SELECT pg_temp.tpl('budget_columns', 'Finances — budget lines columns', 'Budget line|Estimate|Invoiced|Still to come|Settled', 62);
SELECT pg_temp.tpl('budget_per_member', 'Finances — per member', 'per member × {units}', 63);
SELECT pg_temp.tpl('budget_per_week',   'Finances — per week',   'per week × {units} ahead', 64);
SELECT pg_temp.tpl('budget_settled_hint', 'Finances — settled hint', 'settled at {amount}', 65);
