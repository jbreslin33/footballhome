-- 2202 (2026-11-27): 🏋️ #exercises — every exercise shows its book pages inline
-- (owner only, the books gate).  Owner: "every exercise should show all
-- pictures right?"
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Exercises', 'Exercises — pictures', 'exercises', 'lbl_pictures', 'Diagrams (book pages — tap to enlarge)', 39, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'exercises' AND tier = 'lbl_pictures');
INSERT INTO schema_migrations (filename) VALUES ('2202-exercises-pictures-label.sql') ON CONFLICT DO NOTHING;
COMMIT;
