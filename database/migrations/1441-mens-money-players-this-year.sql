-- 1441 (2026-11-17) — 💵 Men's money: paying men per plan season THIS year too
-- (owner "i should have option to increase paid player numbers even for the
-- current year" + "allowing diff totals fall, spring etc"). Fall is real; the
-- typed men over the default add their dues on top of the Year plan's. Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: dues detail when paying men are set ({seasons})', 'pm_dues_set', 'with {seasons} paying', 416)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
COMMIT;
