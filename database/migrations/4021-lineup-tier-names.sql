-- 4021 Tier names: T1 Starter · T2 Starter/Sub · T3 Sub · T4 Depth. Owner
-- 11/27 "maybe starter, starter/sub, sub, depth?" · the tiers are flexible
-- categories, not a numbered rule ("i will try to honor it but not be
-- beholden"). Codes unchanged: starter / bench / sub_late / (none).
-- (Gap number.)
BEGIN;
UPDATE lineup_roles SET description = 'T1 Starter' WHERE name = 'starter';
UPDATE lineup_roles SET description = 'T2 Starter/Sub — first in when starters are missing' WHERE name = 'bench';
UPDATE lineup_roles SET description = 'T3 Sub' WHERE name = 'sub_late';
UPDATE message_templates SET body = '⭐ T1 · Starters'      WHERE kind = 'roster_sheet' AND tier = 'tc_seg_starter';
UPDATE message_templates SET body = '🔁 T2 · Starter/Sub', label = '#teams team card: segment header — T2 starter/sub (lineup role bench)' WHERE kind = 'roster_sheet' AND tier = 'tc_seg_bench';
UPDATE message_templates SET body = '🪑 T3 · Subs', label = '#teams team card: segment header — T3 sub (lineup role sub_late)' WHERE kind = 'roster_sheet' AND tier = 'tc_seg_sub_late';
UPDATE message_templates SET body = '🧱 T4 · Depth'         WHERE kind = 'roster_sheet' AND tier = 'tc_seg_none';
INSERT INTO schema_migrations (filename) VALUES ('4021-lineup-tier-names.sql') ON CONFLICT DO NOTHING;
COMMIT;
