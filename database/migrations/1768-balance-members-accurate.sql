-- 1768 (2026-11-23): Balance — say exactly who is counted and what a member really brings.
--
-- Owner 2026-11-23: "yes be accurate".  The line under the grant said
-- "{paying} now" for the members who OWE dues (113), though only 94 of them
-- were paid up, and gave one figure for members needed.  Now: members needed
-- at the rate dues are really coming in, and at the full rate; then how many
-- owe dues, how many are paid up and how many are behind (the Tuition page's
-- own statuses, from /api/finances/programs).  Wording only.

BEGIN;
UPDATE message_templates SET updated_at = now(),
       body = 'To need no grant: about {more} more members at the rate dues are really coming in ({per} a member a year after fees) — or about {more_full} if every one paid the full {full} a year.'
 WHERE kind = 'finances' AND tier = 'bl_members_needed';
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — balance: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('members now',          'bl_members_now',  '{owe} members owe dues now: {paid} are paid up, {behind} are behind.', 1016),
    ('members now, no split','bl_members_owe',  '{owe} members owe dues now.', 1017)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('1768-balance-members-accurate.sql') ON CONFLICT DO NOTHING;
COMMIT;
