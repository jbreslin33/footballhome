-- 1793 (2026-11-24) — 🔺 #apsl-pyramid: the ☰ menu is gone (pill page since
-- commit 4a1f864f), so its wording rows go too — nothing reads them.
BEGIN;
DELETE FROM message_templates
 WHERE kind = 'apsl_pyramid'
   AND tier IN ('menu_button', 'menu_home', 'menu_back', 'menu_actions', 'menu_show_none', 'view_soon');
COMMIT;
