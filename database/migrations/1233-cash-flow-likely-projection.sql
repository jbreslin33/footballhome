-- #finances Money in & out: a third projection, Likely — every month ahead
-- brings in what actually came in last month, team by team, so the people
-- who quit or don't pay are already out of it.  Owner 2026-11-10: pills read
-- Current · Likely · Full.
UPDATE message_templates SET body = 'Current' WHERE kind = 'cash_flow' AND tier = 'pill_paid_up';
UPDATE message_templates SET body = 'Full'    WHERE kind = 'cash_flow' AND tier = 'pill_paying';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Finances', l, 'cash_flow', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('pill_likely', 'Projection pill', 'Likely', 6),
    ('likely_note', 'Projection note, Likely pill ({month})',
     'Likely: every month ahead brings in what came in from dues in {month}, team by team — whoever quit or didn''t pay that month stays out.', 19)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cash_flow' AND m.tier = v.t);
