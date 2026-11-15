-- 1385 (2026-11-14) — dues from reality, not headcount × rate.
--
-- Owner 2026-11-14: "so we are projecting too much in collected dues right?"
-- → "i thought your were gonna deal with reality?" → "wait we only took in
-- 1898 in oct?" (the page dropped youth dues: U8/U10/U12/U19 sit under Youth in
-- the scope tree, not Boys — dues now go by the LA program's section).
--
-- Operating Budget dues = collected so far (what LeagueApps paid out, after its
-- fees) + the last three finished months' average × the months left; next
-- year = that average × 12. Cash Flow Forecast: past months actual, ahead =
-- the same average. The collection-rate guess (mig 1381) is gone from the
-- budget; the allowance stays on the statements.

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('plan_rev_dues_unit', 'collected so far (after LeagueApps fees) + the last 3 months'' average × the months left'),
    ('var_dues_net', 'Dues are what LeagueApps paid out after its fees (it keeps about {pct}) — in the budget too.')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

UPDATE message_templates SET body = replace(body, 'dues (paying members × dues × 12 × the share expected to be collected)',
       'dues (collected so far after LeagueApps fees + the last 3 months'' average × the months left)')
 WHERE kind = 'finances' AND tier = 'plan_note';

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Budget: dues from reality ({so_far}, {rate}, {left})', 'plan_dues_real', '{so_far} so far + {rate}/mo × {left}', 275),
    ('Finances — Budget: next year dues from reality ({rate})', 'plan_dues_real_next', '{rate}/mo × 12', 276),
    ('Finances — Budget: dues by headcount (no history yet)', 'plan_rev_dues_unit_heads', 'paying members × dues a month × 12 months', 277)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
