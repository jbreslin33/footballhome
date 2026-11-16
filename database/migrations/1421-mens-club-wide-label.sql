-- 1421 (2026-11-16): 💵 Men's money band "Men's — general (every team)" →
-- "Men's club wide" (owner: "rename men's general to men's club wide" +
-- "mens club wide don't confuse me"). Words only.
BEGIN;
UPDATE message_templates SET body = 'Men''s club wide' WHERE kind = 'finances' AND tier = 'pm_general';
INSERT INTO schema_migrations (filename) VALUES ('1421-mens-club-wide-label.sql') ON CONFLICT DO NOTHING;
COMMIT;
