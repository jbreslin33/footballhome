-- 492 (2026-09-29) — gas for the generators that run the lights: $30 a week
-- in fall and part of spring.  Owner: "add for fall and part of spring $30
-- a week in gas for generators to run lights".  "Part of spring" is taken
-- as March to mid-April, until the evenings are light enough (assumed —
-- move period_end by migration if the lights run longer).
CREATE OR REPLACE FUNCTION pg_temp.gas(p_label text, p_from date, p_to date, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end, spread, is_assumed, sort_order, note)
  SELECT 134, NULL, 'facilities', p_label, 30.00, 'week', p_from, p_to, 'even', true, p_sort, 'Owner estimate 2026-09-29: $30 a week of gas for the generators that run the lights, fall and part of spring'
   WHERE NOT EXISTS (SELECT 1 FROM budget_lines WHERE club_id = 134 AND label = p_label AND period_start = p_from);
$$;
SELECT pg_temp.gas('Generator gas (lights) — Fall',   '2026-09-01', '2026-11-30', 43);
SELECT pg_temp.gas('Generator gas (lights) — Spring', '2027-03-01', '2027-04-15', 44);
