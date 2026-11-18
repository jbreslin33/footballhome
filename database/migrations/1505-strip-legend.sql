-- 1505 (2026-11-18) — Key to the mini calendar in each player's box on the
-- live game card (owner 11/18 "mini calendar on each box with green check
-- mark for made it. and yellow for projected … and total at end" → "then we
-- wouldn't need words?").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', 'Lineup boxes — mini calendar key', 'eligibility', 'strip_legend', NULL,
       '✓ made · ● said Going · ✗ not going / no-show · · no answer · last box = total / needed',
       78, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'eligibility' AND tier = 'strip_legend');
