-- 1384 (2026-11-14) — Operating Budget: a restricted grant is budgeted at this
-- year's costs it may pay for (coaching, referees, equipment), up to the award;
-- whatever is left is shown as not used, never counted.
--
-- Owner 2026-11-14: "for now actually just use the grant for refs, coach pay,
-- equipment. then any excess grant money don't use it at all. i can see total
-- used at end right? … so just use "grant" money for all refs, coach pay and
-- equipment and lets see it".

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Budget: restricted grant used ({used}, {award})', 'plan_grant_used', '{used} of {award}, for what it may pay for', 273),
    ('Finances — Budget: restricted grant not used ({left})', 'plan_grant_left', '{left} not used', 274)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

UPDATE message_templates SET body = replace(body, 'contributed = grants (restricted to their purpose) and sponsors.',
       'contributed = grants and sponsors; a restricted grant counts only up to this year''s costs it may pay for (coaching, referees, equipment) — the rest is not used.')
 WHERE kind = 'finances' AND tier = 'plan_note';

UPDATE message_templates SET body = 'A restricted grant counts as it is spent on what it may pay for (released from restriction), up to the award — not when Lighthouse receives it. Its budget is this year''s costs it may pay for; anything left of the award is not used.'
 WHERE kind = 'finances' AND tier = 'var_grant_used';
