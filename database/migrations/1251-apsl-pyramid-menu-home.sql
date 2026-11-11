-- 1251 (2026-11-11) — #apsl-pyramid ☰: "🏠 Main menu" replaces "← Back".
-- Owner: "need on hamburger a way to leave screen to main menu".  The
-- action goes straight to the main menu (navigation.home()), not one step
-- back.  Shown to signed-in viewers only (a visitor has no main menu).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — menu: go to the main menu', 'apsl_pyramid', 'menu_home', NULL, '🏠 Main menu', 197, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'menu_home');
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'menu_back';
