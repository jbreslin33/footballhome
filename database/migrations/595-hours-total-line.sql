-- 595 (2026-10-19) — The hours-from-the-calendar breakdown closes with its
-- own total row, named for the issuer's duty (owner: "manager of soccer
-- duties should show total at end of hours").  Dollars still only add up
-- at the very bottom of the sheet; this is the hours sum alone, the same
-- number the labor line carries.

CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.tpl('invoices', 'hours_total_line', 'Invoices — hours total row',
                   '{duty} — total', 105);
