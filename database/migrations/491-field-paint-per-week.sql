-- 491 (2026-09-29) — field paint: $100 a week in fall, spring and summer.
-- Owner: "Estimate during Fall, Spring and summer we spend $50 a week on
-- paint … for fields … actually be safe and make it $100 … that is 6 cans
-- for big pitch and 6 cans for youth."  A new budget_lines amount_per = 'week': the projection is the
-- amount × the weeks still ahead in the period (forward only), spread
-- evenly over the period's remaining months; invoice lines that count
-- toward it burn it down like any other budget line.
ALTER TABLE budget_lines DROP CONSTRAINT IF EXISTS budget_lines_amount_per_check;
ALTER TABLE budget_lines ADD CONSTRAINT budget_lines_amount_per_check CHECK (amount_per IN ('fixed', 'member', 'week'));

CREATE OR REPLACE FUNCTION pg_temp.paint(p_label text, p_from date, p_to date, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end, spread, is_assumed, sort_order, note)
  SELECT 134, NULL, 'facilities', p_label, 100.00, 'week', p_from, p_to, 'even', true, p_sort, 'Owner estimate 2026-09-29: $100 a week — 6 cans for the big pitch and 6 for youth — in fall, spring and summer'
   WHERE NOT EXISTS (SELECT 1 FROM budget_lines WHERE club_id = 134 AND label = p_label AND period_start = p_from);
$$;
SELECT pg_temp.paint('Field paint — Fall',   '2026-09-01', '2026-11-30', 40);
SELECT pg_temp.paint('Field paint — Spring', '2027-03-01', '2027-05-31', 41);
SELECT pg_temp.paint('Field paint — Summer', '2027-06-01', '2027-08-31', 42);

-- Same rows if they were made at the first estimate.
UPDATE budget_lines SET amount_usd = 100.00, note = 'Owner estimate 2026-09-29: $100 a week — 6 cans for the big pitch and 6 for youth — in fall, spring and summer'
 WHERE club_id = 134 AND label LIKE 'Field paint — %' AND amount_per = 'week';
