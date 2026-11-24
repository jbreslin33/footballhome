-- 1781 (2026-11-23): Balance — the other way to break even: raise dues.
--
-- Owner 2026-11-23: "give another option to. put raise dues to this amount
-- and then we don't need new players".  One more fact row under mig 1779's:
-- the monthly dues that close the gap before the grant over a full year with
-- the same members paying the way they pay now (every section's dues up by
-- the same share; nobody new, nobody leaving).  Wording only.

BEGIN;
UPDATE message_templates SET sort_order = sort_order + 2
 WHERE kind = 'finances' AND tier IN ('bl_f_now', 'bl_f_now_note', 'bl_f_split');
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — balance fact: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('raise dues instead',       'bl_f_raise',      'Or, with no new members: dues a month at', 1023),
    ('raise dues instead, note', 'bl_f_raise_note', 'Now {now} — up {pct}%, for a full year, the same members paying the way they pay now.', 1024)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('1781-balance-raise-dues-fact.sql') ON CONFLICT DO NOTHING;
COMMIT;
