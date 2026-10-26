-- 710 (2026-10-26) — ⚠ Resolve on the 📅 invoice calendar (owner: "if
-- there is over lap we can have a resolve button that makes sure it
-- doesn't overlap but gives credit for begin of 1st event and end of last
-- event in question").  The earliest stint of an overlapping cluster takes
-- first start → last end; the others stay billed (green) at 0 h, "covered"
-- — so a flat-hours row may now be 0.
ALTER TABLE invoice_work_shifts DROP CONSTRAINT invoice_work_shifts_times_or_hours;
ALTER TABLE invoice_work_shifts ADD CONSTRAINT invoice_work_shifts_times_or_hours CHECK (
       (start_at IS NOT NULL AND end_at IS NOT NULL AND end_at > start_at AND hours IS NULL)
    OR (start_at IS NULL AND end_at IS NULL AND hours IS NOT NULL AND hours >= 0));

CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('invoices', 'cal_resolve', 'Invoices — resolve overlaps button',
                   'Resolve', 148);
SELECT pg_temp.tpl('invoices', 'cal_resolve_all', 'Invoices — resolve all overlaps button',
                   'Resolve all — pay first start to last end once', 149);
SELECT pg_temp.tpl('invoices', 'cal_resolve_tip', 'Invoices — resolve tooltip',
                   'Pay this day''s overlapping times once: first start to last end; the others stay ticked at 0 h', 150);
SELECT pg_temp.tpl('invoices', 'cal_covered', 'Invoices — chip covered by a merged window',
                   'covered', 151);
