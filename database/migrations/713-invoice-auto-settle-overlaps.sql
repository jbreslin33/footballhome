-- 713 (2026-10-26) — overlapping billed stints settle by themselves, as the
-- default (owner: "part of it should auto complete but let edit. so just
-- figure it out with continuos but no overlap" … "as the defualt").
-- Invoice::syncLabor first restores every auto-adjusted stint to the times
-- it had before (auto_from_*), re-applies the youth lead-in, then walks
-- each day in start order: a stint that starts inside the running window
-- starts where it ends instead, and one wholly inside it is "covered"
-- (flat 0 h).  So ✗ or ✏️ on one event re-settles the day from the real
-- times; a ✏️ edit clears the flag and becomes the stint's own truth.
ALTER TABLE invoice_work_shifts
    ADD COLUMN IF NOT EXISTS auto_adjusted   boolean NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS auto_from_start time,
    ADD COLUMN IF NOT EXISTS auto_from_end   time,
    ADD COLUMN IF NOT EXISTS auto_from_hours numeric(6,2);

CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('invoices', 'cal_trimmed_tip', 'Invoices — auto-trimmed chip tooltip',
                   '↔ Starts when the event before it ends, so no hour is paid twice (calendar: {was})', 152);
SELECT pg_temp.tpl('invoices', 'cal_covered_tip', 'Invoices — covered chip tooltip',
                   '↔ Inside the event before it — its time is already paid there (calendar: {was})', 153);
UPDATE message_templates SET body = '⚠ {hours} h billed twice ({amount}) — times that can''t be placed; ✏️ or ✗ one'
 WHERE kind = 'invoices' AND tier = 'cal_overlap';
UPDATE message_templates SET is_active = false
 WHERE kind = 'invoices' AND tier IN ('cal_resolve', 'cal_resolve_all', 'cal_resolve_tip');
