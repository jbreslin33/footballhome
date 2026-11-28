-- 5032 (2026-11-27): 📜 Rules moves from the Calendar menu group to Club.
-- Owner: "why is rules in cal lol" · "rules should be in club or have its own menu".
-- Audience stays 'everyone', so players still get it, now under ⚙️ Club.
BEGIN;
UPDATE menu_pages SET group_code = 'club', sort_order = 1 WHERE code = 'rules';
INSERT INTO schema_migrations (filename) VALUES ('5032-rules-to-club-menu.sql') ON CONFLICT DO NOTHING;
COMMIT;
