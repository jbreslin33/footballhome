-- 🗻 A group pill that opens its pills row first (James 11/25 "yes" to: "🗻 Pyramids opens
-- its pills row on the page you're on, and only goes to the pyramid when you pick one").
-- The pyramid page hides the top bar (a display page, 11/24), so the All · MLS · USL …
-- pills could never be seen there.  main_menu.pills_first_groups = the group codes, space
-- separated, whose pill shows its pages row in place instead of opening the last page.
-- Another group = edit this row.

BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Main menu', 'Top bar — groups whose pill shows its pages first (group codes, space separated)', 'main_menu', 'pills_first_groups', NULL, 'pyramids', 5, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'main_menu' AND t.tier = 'pills_first_groups');
COMMIT;
