-- 4009 "Bench" is called "Subs". Owner 11/27 "instead of bench call it subs".
-- Team-card segment header; the List card role dropdown reads "1st Team Subs"
-- (lineup_roles.name stays 'bench' — the code, not the word). (Gap number.)
BEGIN;
UPDATE message_templates SET body = '🪑 Subs', label = '#teams team card: segment header — subs (lineup role bench)'
 WHERE kind = 'roster_sheet' AND tier = 'tc_seg_bench';
INSERT INTO schema_migrations (filename) VALUES ('4009-bench-is-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
