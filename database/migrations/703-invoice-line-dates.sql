-- 703 (2026-10-26) — Every invoice line has a date, and the 📅 period
-- calendar is the whole editor (owner: "everything should have a date even
-- if artificial … if not sure we just put 1st date of invoice"; "i am
-- proposing no line item section").  line_date NULL, or outside the
-- window, reads as the window's first day — so no backfill: every existing
-- expense lands on its sheet's opening Friday until someone moves it.
-- Labor keeps its days in invoice_work_shifts; referee fees keep theirs in
-- ref_fee_payments.game_on.

ALTER TABLE invoice_lines ADD COLUMN IF NOT EXISTS line_date date;

CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.tpl('invoices', 'cal_add_tip', 'Invoices — calendar ＋ on a day',
                   'Add an expense or hours on this day', 140);
SELECT pg_temp.tpl('invoices', 'cal_add_title', 'Invoices — add-on-a-day popup title',
                   'Add to {day}', 141);
SELECT pg_temp.tpl('invoices', 'cal_date_hint', 'Invoices — expense date hint',
                   'Not sure of the day? Leave it on the first day of the invoice.', 142);
SELECT pg_temp.tpl('invoices', 'cal_mismatch', 'Invoices — day sums disagree with the total',
                   '⚠ The days add up to {days} but the invoice says {total}', 143);
SELECT pg_temp.tpl('invoices', 'cal_rows', 'Invoices — printed rows count',
                   '{n} of {max} rows on the sheet', 144);
SELECT pg_temp.tpl('invoices', 'cal_detail_tip', 'Invoices — chip details zone',
                   'Details — RSVP, attendance, part hours, edit', 145);
