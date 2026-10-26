-- 714 (2026-10-26) — every instalment line prints its plan total (owner:
-- "top soil 3 of 4 at 397 lol you need to put the increment and total
-- from. it looks like 4 payments of 397").  Was only when the plan's
-- show_total was ticked (Veo alone).  Printed via MessageCopy in
-- Invoice::get; {total} is "$1,588" style.
CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, false
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('invoices', 'plan_line', 'Invoices — instalment line on the sheet',
                   '{description} {k} of {n} · {total} total', 154);
