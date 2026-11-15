-- 1382 (2026-11-14) — the restricted grant counts as it is used, on the
-- internal reports (the standard way): Budget vs Actual's grant actual and the
-- Cash Flow Forecast's grant receipts = what is spent on its purposes (coaching,
-- referees, equipment) month by month, up to the award — the same "released
-- from restrictions" the Statement of Activities shows. The statements are
-- unchanged (a guaranteed grant is revenue when promised, mig 1380).
--
-- Owner 2026-11-14: "can we disperse the 50k acrros the year … " → "do it
-- like standard i guess".

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Cash Flow Forecast: grant drawn as used', 'cf_grant_used', 'Grant — drawn as it is spent on its purposes', 270),
    ('Finances — BvA: grant counts as used (note)', 'var_grant_used', 'A restricted grant counts as it is spent on what it may pay for (released from restriction), up to the award — not when Lighthouse receives it.', 271)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
