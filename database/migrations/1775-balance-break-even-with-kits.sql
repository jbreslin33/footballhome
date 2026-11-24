-- 1775 (2026-11-23): Balance — members to break even without the grant, counting each new member's kit.
--
-- Owner 2026-11-23: "on balance can we show how many members needed to break
-- even (non grant) also considering no new costs except kits and current non
-- pay rate continues".  A new member brings the average really collected per
-- member (after LeagueApps' fees — the non-pay rate carried on) less one kit
-- (the uniforms line's price per new member); nothing else is assumed to
-- grow.  Wording only.

BEGIN;
UPDATE message_templates SET updated_at = now(),
       body = 'To break even without the grant: about {more} more members. Each brings {per} a year at the rate dues are really coming in (after fees), less a {kit} kit = {net}; no other new costs. About {more_full} if every one paid the full {full} a year.'
 WHERE kind = 'finances' AND tier = 'bl_members_needed';
-- … and by practice slot (owner: "break it by practice slots … men, 4pm, 445, 545. so prob 26 for each"): evenly
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — balance: members needed by practice slot', 'finances', 'bl_members_split', 'Spread over the practice slots that is {list}.', 1018, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'bl_members_split');
INSERT INTO schema_migrations (filename) VALUES ('1775-balance-break-even-with-kits.sql') ON CONFLICT DO NOTHING;
COMMIT;
