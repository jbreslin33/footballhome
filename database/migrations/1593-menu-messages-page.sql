-- 1593 — 💬 Messages gets its own pill under 📣 Marketing.
--
-- Owner 2026-11-19: "we need a messages screen and it needs to
-- navigatable to" (the #messages helper — LA Program Description and the
-- lead snippets with 📋 Copy — had no way in but typing the URL; it was
-- only listed in Club Admin's screens[] to keep that group lit).
-- Sits next to 📋 Leads; Club Admin stops claiming the screen.

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, href, new_tab, download, is_active)
SELECT 'messages', 'marketing', 'Messages', '💬', 'marketing', 4, '{messages}', NULL, false, false, true
 WHERE NOT EXISTS (SELECT 1 FROM menu_pages WHERE code = 'messages');

UPDATE menu_pages SET screens = array_remove(screens, 'messages')
 WHERE code = 'club-admin';
