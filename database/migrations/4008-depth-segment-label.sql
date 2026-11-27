-- 4008 The no-lineup-role segment is called "Depth". Owner 11/27 "if you
-- need a name its 'depth'". (Gap number below the max.)
BEGIN;
UPDATE message_templates SET body = '🧱 Depth', label = '#teams team card: segment header — depth (on the team, not starter/bench)'
 WHERE kind = 'roster_sheet' AND tier = 'tc_seg_none';
INSERT INTO schema_migrations (filename) VALUES ('4008-depth-segment-label.sql') ON CONFLICT DO NOTHING;
COMMIT;
