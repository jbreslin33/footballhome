-- 716 (2026-10-26) — 📅 invoice calendar chips say WHAT is paid (owner:
-- "i having trouble telling being at game and paying refs for it lol. you
-- need to show 'coached' 'payed refs' as lables since on mine they show
-- 2x per event").
CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('invoices', 'cal_tag_coached', 'Invoices — chip tag: coaching hours', 'Coached', 155);
SELECT pg_temp.tpl('invoices', 'cal_tag_refs', 'Invoices — chip tag: referee fee', 'Paid refs', 156);
SELECT pg_temp.tpl('invoices', 'cal_tag_worked', 'Invoices — chip tag: other worked hours (CASA, hand-added)', 'Worked', 157);
