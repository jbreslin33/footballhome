-- 1429 (2026-11-16) — the menu groups are a bar on top of every page
-- (owner: "the main menu doesn't make sense anymore. players don't need
-- it. i have to hit back all the time … having 7 pills at top of site is
-- way to go" / "lets do it").  Everyone lands on the 📅 Calendar; the old
-- #main-menu is 👤 Account (sign out, view-as).  Words only — the bar
-- itself reads menu_groups / menu_pages as before.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Main menu', 'Top bar — the account pill (sign out, view-as)', 'main_menu', 'account_pill', NULL, '👤 Account', 4, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'main_menu' AND t.tier = 'account_pill');

UPDATE message_templates SET body = 'Your account', label = 'Account page — under the welcome', updated_at = now()
 WHERE kind = 'main_menu' AND tier = 'subtitle' AND body = 'Where to?';

-- ☰ Menu pill is gone (the groups are always on top).
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'main_menu' AND tier = 'home_pill';

UPDATE message_templates SET body = 'Account', updated_at = now()
 WHERE tier = 'screen_main_menu' AND body = 'Main menu';
