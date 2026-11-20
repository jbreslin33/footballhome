-- 1626 (2026-11-20) — Menu review, round 1 (owner 11/20: "going through the
-- menu items … what can be rooted out … improved … and what needs moving"
-- → "yes do your suggestions and commit and push").
--   Coach Schedule → People   (about coaches, not the week)
--   Security       → Club     (gate / lock-up alerts = club operations)
--   Game, Club Logos, Proposals → Club
--   Profiles       → Marketing (exhibit pages face outward)
--   Contacts       → off the menu (FH Assistant keeps Google contacts in sync;
--                    #contacts still opens by link for a one-off .vcf)
--   Texts          → "Text Opt-ins" (it is the opt-in board)
--   Admin          → "System Admin" (Club Admin is the Lighthouse hub)
UPDATE menu_pages SET group_code = 'people', sort_order = 7  WHERE code = 'coach-schedule';
UPDATE menu_pages SET group_code = 'club',   sort_order = 1  WHERE code = 'security';
UPDATE menu_pages SET group_code = 'club',   sort_order = 2  WHERE code = 'proposals';
UPDATE menu_pages SET group_code = 'club',   sort_order = 8  WHERE code = 'game';
UPDATE menu_pages SET group_code = 'club',   sort_order = 9  WHERE code = 'logos';
UPDATE menu_pages SET group_code = 'marketing', sort_order = 6 WHERE code = 'profiles';
UPDATE menu_pages SET is_active = false WHERE code = 'contacts';
UPDATE menu_pages SET label = 'Text Opt-ins' WHERE code = 'texts';
UPDATE menu_pages SET label = 'System Admin', icon = '🛠' WHERE code = 'admin';
