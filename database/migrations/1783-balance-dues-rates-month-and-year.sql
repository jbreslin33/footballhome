-- 1783 (2026-11-23): Balance — the dues now and the dues proposed, each a month and a year.
--
-- Owner 2026-11-23: "show current rate what that is yearly and proposed rate
-- and what that is yearly".  Mig 1781's raise-dues fact becomes two rows —
-- "Dues now" and "Or, with no new members: dues at" — each "{month} a month ·
-- {year} a year".  Wording only.

BEGIN;
UPDATE message_templates SET sort_order = sort_order + 2
 WHERE kind = 'finances' AND tier IN ('bl_f_raise', 'bl_f_raise_note', 'bl_f_now', 'bl_f_now_note', 'bl_f_split');
UPDATE message_templates SET body = 'Or, with no new members: dues at', updated_at = now()
 WHERE kind = 'finances' AND tier = 'bl_f_raise';
UPDATE message_templates SET body = 'Up {pct}%, for a full year, the same members paying the way they pay now.', updated_at = now()
 WHERE kind = 'finances' AND tier = 'bl_f_raise_note';
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — balance fact: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('dues now',                 'bl_f_dues_now',   'Dues now', 1023),
    ('a rate, a month and a year', 'bl_f_rate_value', '{month} a month · {year} a year', 1024)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('1783-balance-dues-rates-month-and-year.sql') ON CONFLICT DO NOTHING;
COMMIT;
