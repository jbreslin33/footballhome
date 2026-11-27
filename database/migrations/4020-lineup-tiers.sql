-- 4020 Lineup tiers: T1 ⭐ Starter · T2 🔁 Sub early · T3 ⏱ Sub late ·
-- T4 🧱 Depth (no role) — 🔄 Reserve stays Liga 1's APSL call-up pool,
-- outside the tiers. Owner 11/27: "have a sub early, sub late, depth …
-- allows for diff levels of subs?" · "or we could list as tier 1 to 4?" ·
-- "use ur suggestion" · "this allows for more than 11 starters cause guys
-- don't show" (no cap on T1). lineup_roles: 'bench' (2) is shown as Sub early;
-- new 'sub_late' (4) sorts between it and reserve. (Gap number.)
BEGIN;
INSERT INTO lineup_roles (id, name, description, sort_order)
SELECT 4, 'sub_late', 'T3 Sub late — last 10–20 minutes', 3
 WHERE NOT EXISTS (SELECT 1 FROM lineup_roles WHERE name = 'sub_late');
UPDATE lineup_roles SET description = 'T1 Starter — the XI (more than 11 allowed: no-shows)' WHERE name = 'starter';
UPDATE lineup_roles SET description = 'T2 Sub early — first off the bench, around the hour' WHERE name = 'bench';
UPDATE lineup_roles SET sort_order = 4 WHERE name = 'reserve';

UPDATE message_templates SET body = '⭐ T1 · Starters'  WHERE kind = 'roster_sheet' AND tier = 'tc_seg_starter';
UPDATE message_templates SET body = '🔁 T2 · Sub early', label = '#teams team card: segment header — T2 sub early (lineup role bench)' WHERE kind = 'roster_sheet' AND tier = 'tc_seg_bench';
UPDATE message_templates SET body = '🧱 T4 · Depth'      WHERE kind = 'roster_sheet' AND tier = 'tc_seg_none';
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Roster sheet', '#teams team card: segment header — T3 sub late', 'roster_sheet', 'tc_seg_sub_late', '⏱ T3 · Sub late', 914, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'roster_sheet' AND tier = 'tc_seg_sub_late');

INSERT INTO schema_migrations (filename) VALUES ('4020-lineup-tiers.sql') ON CONFLICT DO NOTHING;
COMMIT;
