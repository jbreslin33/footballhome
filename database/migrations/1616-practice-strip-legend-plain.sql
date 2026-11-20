-- 1616 (2026-11-20) — The key under a youth / women's game card's practice
-- boxes: the same marks as men's, no criterion colours.
--
-- Owner: "it shold look like men. it can even show attendance even though
-- it doesn't have criteria. same with women" → "all youth should show
-- practice attendance right for games?"  Men keep strip_legend (made it /
-- on pace / short); a game with no criterion shows its recent practices
-- and a plain total.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'System', 'Game card key: practice boxes with no criterion (youth / women)', 'eligibility', 'strip_legend_plain',
       '✓ green made · ✓ yellow said Going · ✗ not going / no-show · blank no answer · last box = made + Going',
       COALESCE((SELECT sort_order FROM message_templates WHERE kind = 'eligibility' AND tier = 'strip_legend'), 0) + 1, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'eligibility' AND tier = 'strip_legend_plain');

COMMIT;
