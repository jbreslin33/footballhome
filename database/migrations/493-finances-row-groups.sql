-- 493 (2026-09-29) — one grid row per thing on #finances.  Owner: "we should
-- not have extra rows for league dues or kits etc. combine when we can for
-- totals like u8 fall winter spring all one line but it does it monthly
-- right?"  The months stay as they are; rows sharing a group_label are
-- summed into one line.  Different leagues stay apart (APSL, Liga 1, Tri
-- County dues); seasons and sections of the same thing merge.
ALTER TABLE budget_lines     ADD COLUMN IF NOT EXISTS group_label TEXT;
ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS group_label TEXT;

UPDATE budget_lines SET group_label = 'U8 league dues'          WHERE club_id = 134 AND label LIKE 'U8 league dues%';
UPDATE budget_lines SET group_label = 'U10 league dues'         WHERE club_id = 134 AND label LIKE 'U10 league dues%';
UPDATE budget_lines SET group_label = 'U12 league dues'         WHERE club_id = 134 AND label LIKE 'U12 league dues%';
UPDATE budget_lines SET group_label = 'Kits'                    WHERE club_id = 134 AND label LIKE 'Kits — %';
UPDATE budget_lines SET group_label = 'Field paint'             WHERE club_id = 134 AND label LIKE 'Field paint — %';
UPDATE budget_lines SET group_label = 'Generator gas (lights)'  WHERE club_id = 134 AND label LIKE 'Generator gas (lights) — %';
UPDATE ref_fee_policies SET group_label = 'Parks & Rec'         WHERE club_id = 134 AND label LIKE 'Parks & Rec %';

-- Then (same day): "we could have it roll up. so it can show by default
-- League Dues which would include all teams totaled per month. then click
-- expand it shows the teams. do that for all categories … use major
-- categories. like league dues, player registrations, ref fees, field
-- rentals, facilities (paint, gas, new lights, generators), equipment
-- (balls, cones), kits (shirts, socks, numbers)".  The major categories are
-- invoice_line_categories; this row is the order they roll up in.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', 'Finances — category order (codes)', 'finances', 'category_order', NULL, 'league_dues|registrations|referees|field_rentals|facilities|equipment|uniforms|other', 20, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'category_order');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', 'Finances — expand hint', 'finances', 'expand_hint', NULL, 'Tap a category to see what is in it.', 21, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'expand_hint');
