-- 985 (2026-11-03) — #finances Money in & out: roll-ups.
-- Owner 2026-11-03: "no easy way to check math. like a ref roll up. league
-- due roll up. player reg rollup. i am focused on apsl check right now. but
-- what we fix and learn can be used for all".
-- Every line of money now carries a category (invoice_line_categories, plus
-- dues and rentals coming in); the planned rows get theirs here.
BEGIN;
ALTER TABLE cash_flow_planned ADD COLUMN IF NOT EXISTS category TEXT REFERENCES invoice_line_categories(code);
UPDATE cash_flow_planned SET category = CASE
    WHEN label ~* 'player adds'                 THEN 'registrations'
    WHEN label ~* 'league (balance|payment)'    THEN 'league_dues'
    WHEN label ~* 'referee'                     THEN 'referees'
    WHEN label ~* 'coach pay'                   THEN 'labor'
    WHEN label ~* 'paint'                       THEN 'facilities'
    ELSE 'other' END
 WHERE category IS NULL;
ALTER TABLE cash_flow_planned ALTER COLUMN category SET NOT NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', v.l, 'cash_flow', v.t, NULL, v.b, v.o, true, true FROM (VALUES
    ('rollup_title', 'Roll-up heading',            'Roll-up', 50),
    ('rollup_note',  'Roll-up note',               'Each kind of money for what the pills show. Tap one to see every line that makes it up.', 51),
    ('rollup_cols',  'Roll-up columns',            'Kind|Actual|Ahead|Year', 52),
    ('cat_dues',     'Roll-up — dues in',          'Dues (LeagueApps)', 53),
    ('cat_rental',   'Roll-up — rentals in',       'Field rentals', 54),
    ('cat_labor',    'Roll-up — coach pay',        'Coach pay', 55),
    ('ahead_tag',    'Roll-up line — projected',   'ahead', 56)
) AS v(t, l, b, o)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cash_flow' AND m.tier = v.t);
COMMIT;
