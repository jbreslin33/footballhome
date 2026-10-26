-- 709 (2026-10-26) — 📅 invoice calendar flags billed stints whose clock
-- times cross on the same day (owner: "check for overlap in time we give
-- them green credit for. so we don't over invoice").  Copy only.
CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('invoices', 'cal_overlap', 'Invoices — overlapping billed hours (totals strip)',
                   '⚠ {hours} h billed twice ({amount}) — overlapping times; ✏️ or ✗ one', 146);
SELECT pg_temp.tpl('invoices', 'cal_overlap_tip', 'Invoices — overlapping chip tooltip',
                   'Overlaps {list} — the same hours billed twice', 147);
