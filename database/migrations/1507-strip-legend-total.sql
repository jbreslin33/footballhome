-- 1507 (2026-11-18) — The box total is one number (made + said Going) in the
-- verdict's colour; day marks only when answered, blank when not (owner 11/18
-- "final tally at end to add up the actual and projected … single number …
-- green because they made 1 actual and only needed 1 … 0 actual and like 3
-- projected it would be a 3 and it would be yellow … if it was not set at all
-- then just make it clear blank").
UPDATE message_templates
   SET body = '✓ green made · ✓ yellow said Going · ✗ not going / no-show · blank no answer · last box = made + Going (green made it, yellow on pace, red short)'
 WHERE kind = 'eligibility' AND tier = 'strip_legend';
